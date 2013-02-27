class Post < ActiveRecord::Base
  include FancyBatmanApp::DirtyTracker

  has_many :comments

  attr_accessible :content, :title
  validates_presence_of :content, :title

  def as_json(options ={})
    {
      :id => id,
      :content => content,
      :title => title,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end

end
