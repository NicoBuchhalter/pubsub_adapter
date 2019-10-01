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

      def self.subscription
        @_subscription ||= pubsub.subscription PubsubAdapter::Application.credentials.google_cloud[:pub_sub_subscription]
      end

      def enqueue(job)
        if job.executions == 3
          return Rails.logger.info "[PubSubQueueAdapter] job #{job.class.name} reached max retries"
        end
      	Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"

				self.class.topic.publish job.class.name, arguments: job.arguments, retry_count: 0, at: Time.zone.now.to_i
      end

    	def self.start
    		Rails.logger.info 'Worker is starting!'

				subscriber = subscription.listen do |message|
				  message.acknowledge!
          if message.attributes['retry_count'].to_i < 3 
            if message.attributes['at'].to_i > Time.zone.now.to_i
              publish_at(message)
            else
    				  Rails.logger.info "Running (#{message.data})"
              begin
                time = Benchmark.measure do 
                  message.data.constantize.perform_now(*Array.class_eval(message.attributes['arguments']))
                end
                ActiveSupport::Notifications.instrument 'job_performed.pubsub', { duration: time.real }
              rescue StandardError => e
                Rails.logger.error "#{message.data} failed with error #{e.message}"
                publish_at(5.seconds.from_now.to_i, message.attributes['retry_count'].to_i + 1, message)
              end
            end
          end
				end

        subscriber.start

        sleep
    	end

      private 

      def self.publish_at(timestamp = nil, retry_count = nil, message)
        timestamp ||= message.attributes['at'].to_i
        retry_count ||= message.attributes['retry_count'].to_i
        arguments = *Array.class_eval(message.attributes['arguments'])
        topic.publish message.data, arguments: arguments, retry_count: retry_count, at: timestamp
      end

    end
  end
end