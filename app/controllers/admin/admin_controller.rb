class Admin::AdminController < ApplicationController

  filter_access_to :all
  before_filter :custom_flash_display

end
