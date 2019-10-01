desc "Run task queue worker"
task pubsub: :environment do
  ActiveJob::QueueAdapters::PubSubQueueAdapter.start
end