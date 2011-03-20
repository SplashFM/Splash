class VisitorsController < ApplicationController
  hide :navigation, :auth_controls

  def new
    @visitor = Visitor.new
  end

  def create
    @visitor = Visitor.new(params[:visitor])
    @visitor.skip_confirmation!

    if @visitor.save
      flash[:notice] = 'You were registered. Thanks!'
      redirect_to :back
    else
      render :new
    end
  end
end
