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
  verify :mothod => :post, :only => :change_order

  def index
    @categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")
  end
  
  def edit
    @category = FaqCategory.find(:first, :conditions => "project_id = #{@project.id} and id = #{params[:category_id]}")
    if request.post? and @category.update_attributes(params[:category])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def change_order
    if request.post? 
      category = FaqCategory.find(:first, :conditions => "project_id = #{@project.id} and id = #{params[:category_id]}")
      case params[:position]
      when 'highest'; category.move_to_top
      when 'higher'; category.move_higher
      when 'lower'; category.move_lower
      when 'lowest'; category.move_to_bottom
      end if params[:position]
      redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def destroy
    @category = FaqCategory.find(:first, :conditions => "project_id = #{@project.id} and id = #{params[:category_id]}")
    @faq_count = @category.faqs.size
    if @faq_count == 0
      @category.destroy
      redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
    elsif params[:todo]
      reassign_to = FaqCategory.find(:first, :conditions => "project_id = #{@project.id} and id = #{params[:reassign_to_id]}") if params[:todo] == 'reassign'
      @category.destroy(reassign_to)
      redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
    end
    @categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}") - [@category]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
private
  def find_project   
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
