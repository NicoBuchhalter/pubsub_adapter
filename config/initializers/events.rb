ActiveSupport::Notifications.subscribe 'job_performed.pubsub' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  JobMetric.update_metrics(1, event.payload[:duration])
end