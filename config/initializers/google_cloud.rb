require "google/cloud/pubsub"

Google::Cloud::PubSub.configure do |config|
  config.credentials = File.join(Rails.root, 'config', 'google_cloud.keyfile.json')
end