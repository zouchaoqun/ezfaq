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

class EzfaqController < ApplicationController
  unloadable
  
  layout 'base'  
  before_filter :find_project, :authorize
  
  helper :attachments
  include AttachmentsHelper
  helper :messages
  include MessagesHelper
  helper :sort
  include SortHelper
  
  def index
    @category_count = FaqCategory.count(:conditions => "project_id = #{@project.id} and faqs_count > 0")
    @categorized_faqs = Faq.find(:all, :conditions => "project_id = #{@project.id} and category_id is not null")
    @not_categorized_faqs = Faq.find(:all, :conditions => "project_id = #{@project.id} and category_id is null", :order => "question")

  end

  def show
    @faq = Faq.find(params[:faq_id])
  end
  
  def new
    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}")
    @faq = Faq.new(params[:faq])
    @faq.project_id = @project.id

    if request.get? || request.xhr?
      @faq.difficulty = 5
      
    else
      @faq.author_id = User.current.id
      @faq.is_valid = true
      @faq.viewed_count = 0
      if @faq.save
        attach_files(@faq, params[:attachments])
        flash[:notice] = l(:notice_successful_create)
        #Mailer.deliver_issue_add(@issue) if Setting.notified_events.include?('issue_added')
        redirect_to :controller => 'ezfaq', :action => 'show', :id => @project, :faq_id => @faq
        return
      end		
    end
  end
  
  def add_faq_category
    @category = FaqCategory.new(params[:category])
    @category.project_id = @project.id
    if request.post? and @category.save
  	  respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_create)
          redirect_to :action => 'index', :id => @project
        end
        format.js do
          faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}")
          render(:update) {|page| page.replace "faq_category_id",
            content_tag('select', '<option></option>' + options_from_collection_for_select(faq_categories, 'id', 'name', @category.id), :id => 'faq_category_id', :name => 'faq[category_id]')
          }
        end
      end
    end
  end  
  
  def edit
    
  end
  
  def answer
    
  end
  
  def destroy_attachment
    @faq = Faq.find(params[:faq_id])
    a = @faq.find_attachment(params[:attachment_id])
    if a then a.destroy end
    redirect_to :action => 'show', :id => @project, :faq_id => @faq
  end
  
private
  def find_project   
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
