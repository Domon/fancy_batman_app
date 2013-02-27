class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :begin_request
  after_filter :finish_request

  def begin_request
    FancyBatmanApp::DirtyTracker.enable
    FancyBatmanApp::DirtyTracker.inline = true
  end

  def finish_request
    FancyBatmanApp::DirtyTracker.process_pusher
    FancyBatmanApp::DirtyTracker.disable
  end

  # this intercepts the render call in Rails to append batch changes
  # which Batman or another client can process.  See ModelUpdater in Batman
  # and FancyBatmanApp::DirtyTracker for more info.
  def render(options = nil, extra_options = {}, &block)
    options ||= {}
    processed_json = options[:json]
    batch = FancyBatmanApp::DirtyTracker.batch
    if batch.present?
      if processed_json == nil
        processed_json = {}.merge(batch: batch)
      elsif processed_json.is_a?(Array) || processed_json.is_a?(ActiveRecord::Relation)
        processed_json = processed_json.as_json
      else
        processed_json = processed_json.as_json.merge(batch: batch)
      end
    end
    options[:json] = processed_json if options[:json]
    super(options, extra_options, &block)
  end
end
