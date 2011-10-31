class CommentsController < ApplicationController

  def index
    splash = Splash.find(params[:splash_id])

    render splash.comments
  end

  def create
    @comment = current_user.comments.new(:splash_id => params[:splash_id],
                                          :body => params[:comment][:body])

    if @comment.save
      render :partial => 'comments/comments', :locals => {:splash => @comment.splash.reload}
    else
      render :json => @comment.errors.to_json, :status => :unprocessable_entity
    end
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
