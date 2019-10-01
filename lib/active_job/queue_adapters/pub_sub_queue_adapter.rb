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
      	Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"

				self.class.topic.publish job.class.name, arguments: job.arguments

      end

    	def self.start
    		Rails.logger.info 'Worker is starting!'

				subscriber = subscription.listen do |message|
				  message.acknowledge!

				  Rails.logger.info "Running (#{message.data})"

          message.data.constantize.perform_now Array.class_eval(message.attributes["arguments"])
				end

        subscriber.start

        sleep
    	end
    end
  end
end