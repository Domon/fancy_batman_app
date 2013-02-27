class Comment < ActiveRecord::Base
  include FancyBatmanApp::DirtyTracker

  belongs_to :post

  attr_accessible :content
  validates_presence_of :content, :post_id  

  def as_json(options ={})
    {
      :id => id,
      :content => content,
      :post_id => post_id,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end
end
