# ezFAQ plugin for redMine
# Copyright (C) 2008-2009  Zou Chaoqun
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class FaqCategoriesController < ApplicationController
  unloadable
  
  layout 'base'
  menu_item :ezfaq, :only => [:index, :edit, :destroy]
  
  before_filter :find_project, :authorize
  verify :method => :post, :only => :destroy

  def index
    @categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}")
  end
  
  def edit
    if request.post? and @category.update_attributes(params[:category])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
    end
  end

  def destroy
#    @issue_count = @category.issues.size
#    if @issue_count == 0
#      # No issue assigned to this category
#      @category.destroy
#      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'categories'
#    elsif params[:todo]
#      reassign_to = @project.issue_categories.find_by_id(params[:reassign_to_id]) if params[:todo] == 'reassign'
#      @category.destroy(reassign_to)
#      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'categories'
#    end
#    @categories = @project.issue_categories - [@category]
  end
  
private
  def find_project   
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
