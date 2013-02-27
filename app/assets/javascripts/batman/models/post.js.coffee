class FancyApp.Post extends FancyApp.Model
  @resourceName: 'post'
  @storageKey: 'posts'

  # fields
  @encode "title", "content"
  @encode "created_at", Batman.Encoders.railsDate
  @encode "updated_at", Batman.Encoders.railsDate
  @hasMany "comments", {inverseOf: 'post', saveInline: false}

  # validations
  @validate "title", presence: true
  @validate "content", presence: true