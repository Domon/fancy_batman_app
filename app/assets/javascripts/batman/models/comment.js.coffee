class FancyApp.Comment extends FancyApp.Model
  @resourceName: 'comment'
  @storageKey: 'comments'

  # fields
  @encode "content", "id", "post_id"
  @encode "created_at", Batman.Encoders.railsDate
  @encode "updated_at", Batman.Encoders.railsDate

  # validations
  @validate "content", presence: true

  # associations
  @belongsTo 'post', { inverseOf: 'comments'}

  # indicates that rails is nesting resources, shallow!
  @urlNestsUnder 'post'
