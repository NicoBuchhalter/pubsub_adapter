require "google/cloud/pubsub"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter
    	RETRY_INTERVAL = 5.minutes

    	def self.pubsub
    		@_pubsub ||= Google::Cloud::Pubsub.new
    	end

      def self.topic
        @_topic ||= pubsub.topic PubsubAdapter::Application.credentials.google_cloud[:pub_sub_topic]
      end

      def self.morgue_topic
        @_morgue_topic ||= pubsub.topic PubsubAdapter::Application.credentials.google_cloud[:pub_sub_morgue_topic]
      end

      def self.subscription
        @_subscription ||= pubsub.subscription PubsubAdapter::Application.credentials.google_cloud[:pub_sub_subscription]
      end

      def enqueue(job)
				enqueue_at(job, Time.zone.now.to_i)
      end

      def enqueue_at(job, timestamp)
        Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"
        self.class.topic.publish job.class.name, arguments: job.arguments, retry_count: 0, at: timestamp
      end

    	def self.start
    		Rails.logger.info 'Worker is starting!'

				subscriber = subscription.listen(deadline: 10) do |message|
          
          if (message.attributes['retry_count'].try(:to_i) || 0) >= 3
            publish_to_morgue(message)
          elsif (message.attributes['at'].try(:to_i) || 0) <= Time.zone.now.to_i 
            run_job(message)
          end
				end

        subscriber.start

        sleep
    	end

      def self.run_job(message)
        Rails.logger.info "Running #{message.data}"
        begin
          time = Benchmark.measure do 
            message.acknowledge!
            message.data.constantize.perform_now(*Array.class_eval(message.attributes['arguments']))
          end
          ActiveSupport::Notifications.instrument 'job_performed.pubsub', { duration: time.real }
        rescue StandardError => error
          handle_error(message , error)
        end
      end

      def self.handle_error(message , error)
        Rails.logger.error "#{message.data} failed with error #{error.message}"
        publish_at(RETRY_INTERVAL.from_now.to_i, message.attributes['retry_count'].to_i + 1, message)
      end

      def self.publish_to_morgue(message)
        Rails.logger.info "Sending #{message.data} to morgue after #{message.attributes['retry_count']} attempts"
        message.acknowledge!
        retry_count ||= message.attributes['retry_count']
        arguments = *Array.class_eval(message.attributes['arguments'])
        morgue_topic.publish message.data, arguments: arguments, retry_count: retry_count
      end

      def self.publish_at(timestamp = nil, retry_count = nil, message)
        timestamp ||= message.attributes['at']
        retry_count ||= message.attributes['retry_count']
        arguments = *Array.class_eval(message.attributes['arguments'])
        topic.publish message.data, arguments: arguments, retry_count: retry_count, at: timestamp
      end
    end
  end
end