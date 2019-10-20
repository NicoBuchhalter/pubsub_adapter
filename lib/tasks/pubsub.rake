desc "Run task queue worker"
task pubsub: :environment do
  ActiveJob::QueueRunners::PubSubQueueRunner.start
end