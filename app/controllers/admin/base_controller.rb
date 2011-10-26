# Checks if user has permission to access administration
class Admin::BaseController < ApplicationController
  skip_before_filter :authenticate_user!, :init_auth, :company_required
  before_filter   :init_admin_auth

    filter_resource_access

  # shouldn't be neccessary as we only have one admin level
  # filter_access_to :all
    puts "BBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCccccccccccc"
  
  protected

  def init_admin_auth
    puts "BBBBBBBBBBBBBBBBBBBB", current_admin, current_user
    if current_admin
        Authorization.current_user = current_admin
    elsif current_user
        if current_user.is_user_admin
            Authorization.current_user = current_user
        end
    end
        
  end
  #~ 
  #~ def
    #~ if current_user
  #~ end

end
