class TagsController < ApplicationController
  MAX_TAGS = 5

  def index
    # TODO: optimize
    tags    = ActsAsTaggableOn::Tag.named_like(params[:q]).limit(MAX_TAGS)
    artists = Artist.filter(params[:q]).limit(MAX_TAGS)
    hashes  = (artists + tags).sort_by(&:name).map { |t|
      {:name => t.name}
    }.first(MAX_TAGS)

    render :json => hashes
  end
end
