require "google/cloud/pubsub"

module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def enqueue(job)
        enqueue_at(job, Time.zone.now.to_i)
      end

      def enqueue_at(job, timestamp)
        Rails.logger.info "[PubSubQueueAdapter] enqueue job #{job.inspect}"
        topic.publish job.class.name, arguments: job.arguments, retry_count: 0, scheduled_at: timestamp
      end

      private

      def pubsub
        @_pubsub ||= Google::Cloud::Pubsub.new
      end

      def topic
        @_topic ||= pubsub.topic PubsubAdapter::Application.credentials.google_cloud[:pub_sub_topic]
      end
    end
  end
end