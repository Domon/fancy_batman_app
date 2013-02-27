# PusherWorker
#
# This worker gets called via PusherBatchWorker.
#
# Call like:
# - PusherWorker.perform_async(channel,'destroyed',packaged_model)
#
# packaged_model for most events looks like:
# { :model_name => v[1].class.to_s,:model_data => v[1].as_json }
#
# flush packages looks like:
# { model_name: model_name, match_key: match_key, match_value: match_value}
class PusherWorker
  @queue = :pusher

  def self.perform(channel,event,packaged_model,exclude_socket = nil)
    if packaged_model.length < 10_000 # Max JSON Size
      Pusher[channel].trigger(event,packaged_model,exclude_socket)
    else
      flush_package = {model_name: packaged_model['model_name'], match_key: 'id', match_value: packaged_model["model_data"]["id"]}
      Pusher[channel].trigger('flushed',flush_package,exclude_socket)
    end
  end

  # shim to adapt Sidekiq format to Resque
  def self.perform_async(*args)
    Resque.enqueue(PusherWorker,*args)
  end

end