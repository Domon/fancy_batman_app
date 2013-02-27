# Keep track of objects that have changed (must include this module).
#
# This then has two outputs:
# 1.  Pusher async jobs (to let secondary clients know about changes to their cache)
# 2.  Inline to the request packaging of all changed objects (for primary client to get updates)
#
# Basically, this supports single-player and multi-player modes.  :)
#
# Batman expects the Rails Server to behave a particular way, so passing back the batch inline
# is tricky, but handled by this module and the autopackaging in application_controller.rb
#
module FancyBatmanApp::DirtyTracker
  extend ActiveSupport::Concern

  mattr_accessor :enabled, :dirty_hash, :dirty_array, :flush_array, :inline

  included do
    after_create :_append_to_created
    after_update :_append_to_updated
    before_destroy :_append_to_destroyed
  end

  # module level for request wide aggregation, not thread safe
  def self.enable
    @@enabled = true unless Rails.env.test?
    @@inline = false
    @@dirty_hash ||= Hash.new
    @@dirty_array ||= nil
    @@flush_array ||= []
    return true
  end

  def self.disable
    @@enabled = false
    @@dirty_hash = Hash.new
    @@dirty_array = nil
    @@flush_array = []
    return true
  end

  def self.get_dirty_array
    @@dirty_array ||= FancyBatmanApp::DirtyTracker.build_array
  end

  def self.build_array
    foo = []

    @@dirty_hash.each do |k,v|
      package = { :model_name => v[1].class.to_s,:model_data => v[1].as_json }
      foo << [v[0],package]
    end

    @@flush_array.each do |f|
      foo << ["flushed",f]
    end

    return foo
  end

  def self.batch
    return unless @@enabled == true
    return FancyBatmanApp::DirtyTracker.get_dirty_array
  end

  def self.process_pusher
    return unless @@enabled == true
    if FancyBatmanApp::DirtyTracker.get_dirty_array.present?
      if @@inline
        batch = PusherBatch.new(:payload => JSON.dump(FancyBatmanApp::DirtyTracker.get_dirty_array))
        PusherBatchWorker.perform_sync(batch)
      else
        batch = PusherBatch.create(:payload => JSON.dump(FancyBatmanApp::DirtyTracker.get_dirty_array))
        PusherBatchWorker.perform_async(batch.id)
      end
    end
    return true
  end

  # allows you to manually throw items into the dirty pile
  # that may not get a callback thrown (bulk updates, etc)
  def self.mark_as_dirty(verb,items)
    items.each do |i|
      FancyBatmanApp::DirtyTracker.append_to_verb(verb,i)
    end
    return true
  end

  # rather than passing potentially 100s of records through Pusher
  # and the response, we can instead tell Batman to flush and re-load
  # all records matching a key-value pair (flush Comment post_id: 54)
  def self.flush(model_name,match_key,match_value)
    return unless @@enabled == true
    @@flush_array << { model_name: model_name, match_key: match_key, match_value: match_value}
    return true
  end

  # general utility for adding to the queue
  def self.append_to_verb(verb,item)
    return unless @@enabled == true
    compound_key = "#{item.class.name}-#{item.id}"
    case verb
    when 'created'
      @@dirty_hash[compound_key] = ['created',item]
    when 'updated'
      @@dirty_hash[compound_key] = ['updated',item] if @@dirty_hash[compound_key].nil? || @@dirty_hash[compound_key].first != "destroyed"
    when 'destroyed'
      @@dirty_hash[compound_key] = ['destroyed',item]
    else
      raise "do not understand what to do with: #{verb}, must be created, updated, or destroyed"
    end
    return true
  end

  private

  # callback related
  def _append_to_created
    FancyBatmanApp::DirtyTracker.append_to_verb('created',self)
  end

  def _append_to_updated
    FancyBatmanApp::DirtyTracker.append_to_verb('updated',self)
  end

  def _append_to_destroyed
    FancyBatmanApp::DirtyTracker.append_to_verb('destroyed',self)
  end
end