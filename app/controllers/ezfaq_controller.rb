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
  before_filter :find_faq, :only => [:show, :edit, :destroy, :history, :destroy_attachment, :show_history_version]
  
  helper :attachments
  include AttachmentsHelper
  helper :messages
  include MessagesHelper
  helper :sort
  include SortHelper
  
  def index
    @categorized_faqs = Faq.find(:all, :conditions => "project_id = #{@project.id} and category_id is not null and is_valid = true")
    @not_categorized_faqs = Faq.find(:all, :conditions => "project_id = #{@project.id} and category_id is null and is_valid = true", :order => "question")
    @faq_setting = FaqSetting.find(:first, :conditions => "project_id = #{@project.id}")
  end
  
  def list_invalid_faqs
    sort_init "#{Faq.table_name}.updated_on", "desc"
    sort_update    
    @invalid_faqs = Faq.find(:all, :conditions => "project_id = #{@project.id} and is_valid = false", :order => sort_clause)
    
    render(:template => 'ezfaq/list_invalid_faqs.html.erb', :layout => !request.xhr?)
  end

  def show
    @faq.viewed_count += 1
    Faq.update_all("viewed_count = #{@faq.viewed_count}", "id = #{@faq.id}")

    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")
  end
  
  def new
    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")
    @faq = Faq.new(params[:faq])
    @faq.project_id = @project.id

    if request.get? || request.xhr?
      @faq.difficulty = 5
      
    else
      @faq.author_id = User.current.id
      @faq.updater_id = User.current.id
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
  
  def edit
    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")
    
    if request.post?
      @faq.attributes = params[:faq]
      @faq.updater_id = User.current.id
      if @faq.save
        attach_files(@faq, params[:attachments])
        flash[:notice] = l(:notice_successful_update)
        #Mailer.deliver_issue_add(@issue) if Setting.notified_events.include?('issue_added')
        redirect_to :controller => 'ezfaq', :action => 'show', :id => @project, :faq_id => @faq
        return
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
  end
  
  def destroy
    @faq.destroy
    redirect_to :action => 'index', :id => @project
  end
  
  def history
    @version_count = @faq.versions.count
    
    page_num = params[:page].to_i < 1 ? 1 : params[:page]
    @versions = @faq.versions.paginate :page => page_num, :per_page => per_page_option, :select => 'id, updater_id, updated_on, version', :order => 'version DESC'

    if @versions.out_of_bounds?
      @versions = @faq.versions.paginate :page => 1, :per_page => per_page_option, :select => 'id, updater_id, updated_on, version', :order => 'version DESC'
    end

  end
  
  def show_history_version
    @faq_version = @faq.versions.find_by_version(params[:version])
    render_404 unless @faq_version
  end
  
  def add_faq_category
    @category = FaqCategory.new(params[:category])
    @category.project_id = @project.id
    if request.post? and @category.save
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_create)
          redirect_to :controller => 'faq_categories', :action => 'index', :id => @project
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
  
  def destroy_attachment
    a = @faq.find_attachment(params[:attachment_id])
    if a then a.destroy end
    redirect_to :action => 'show', :id => @project, :faq_id => @faq
  end
  
  def faq_setting
    @faq_setting = FaqSetting.find(:first, :conditions => "project_id = #{@project.id}")
    if !@faq_setting && request.get?
      @faq_setting = FaqSetting.new
    elsif request.post?
      if !@faq_setting 
        @faq_setting = FaqSetting.new(params[:faq_setting])
      else
        @faq_setting.attributes = params[:faq_setting]
      end
      @faq_setting.project_id = @project.id
      @faq_setting.save
      redirect_to :action => 'index', :id => @project
    end
  end
  
private
  def find_project   
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_faq
    @faq = Faq.find(:first, :conditions => "project_id = #{@project.id} and id = #{params[:faq_id]}")
    render_404 unless @faq
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
