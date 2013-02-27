# PusherBatchWorker
#
# This worker pulls a batch out of the database (stored because its faster
# than dumping all the jobs into Resque serially), and then spins up the child jobs.
#
class PusherBatchWorker
  @queue = :pusher

  def self.perform(batch_id)
    batch = PusherBatch.find(batch_id)
    batch.arrayed_payload.each do |v|
      PusherWorker.perform_async(PUSHER_CHANNEL,v[0],v[1])
    end
    batch.destroy
    return true
  end

  # purely for demo purposes, in prod i'd
  # async all the things
  def self.perform_sync(batch)
    channel = "fancy"
    batch.arrayed_payload.each do |v|
      PusherWorker.perform(channel,v[0],v[1])
    end
    return true
  end

  # shim to adapt Sidekiq format to Resque
  def self.perform_async(*args)
    Resque.enqueue(PusherBatchWorker,*args)
  end

end