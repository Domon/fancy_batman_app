# = PusherBatch
#
# This simple object temporarily stores a big batch of updates that need
# to be sent out to Pusher.  The PusherBatchWorker is responsible for
# the entire lifecycle of this object.
#
class PusherBatch < ActiveRecord::Base
  attr_accessible :payload

  # have to use JSON as the better MsgPack doesn't support all
  # ruby data types yet...like datetime!
  def arrayed_payload
    JSON.load(self.payload)
  end
end