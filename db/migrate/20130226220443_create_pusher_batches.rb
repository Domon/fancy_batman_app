class CreatePusherBatches < ActiveRecord::Migration
  def change
    create_table :pusher_batches do |t|
      t.text :payload
      t.timestamps
    end
  end
end
