class CommentsController < ApplicationController
  respond_to :json

  def index
    splash = Splash.find(params[:splash_id])

    render splash.comments
  end

  def create
    @comment = current_user.comments.create(:splash_id => params[:splash_id],
                                            :body      => params[:body])

    respond_with @comment
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    if comment
      comment.destroy

      render :partial => 'comments/comments', :locals => {:splash => comment.splash}
    else
      render :json => comment.to_json, :status => :unprocessable_entity
    end
  end
end
