class CommentsController < ApplicationController

  def create
    @comment = current_user.comments.new(:splash_id => params[:splash_id],
                                  :body => params[:comment][:body])

    respond_to do |format|
      if @comment.save
        format.html { render @comment.splash.comments }
      else
        format.js { render :json => @comment.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    if comment
      comment.destroy

      head :ok
    else
      render :json => comment.to_json, :status => :unprocessable_entity
    end
  end
end
