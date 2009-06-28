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
  before_filter :find_faq, :only => [:show, :edit, :copy, :destroy, :history, :show_history_version]
  
  helper :attachments
  include AttachmentsHelper
  helper :messages
  include MessagesHelper
  helper :sort
  include SortHelper
  include Redmine::Export::PDF
  
  def index
    @categorized_faqs = Faq.find(:all, :conditions => ["project_id = #{@project.id} and category_id is not null and is_valid = ?", true])
    @not_categorized_faqs = Faq.find(:all, :conditions => ["project_id = #{@project.id} and category_id is null and is_valid = ?", true], :order => "question")
    @faq_setting = FaqSetting.find(:first, :conditions => "project_id = #{@project.id}")

    respond_to do |format|
      format.html { render :template => 'ezfaq/index.html.erb', :layout => !request.xhr? }
      format.pdf  { send_data(faqs_to_pdf, :type => 'application/pdf', :filename => "#{@project}-faq.pdf") }
    end
  end
  
  def list_invalid_faqs
    sort_init "updated_on", "desc"
    sort_update %w(id question category_id viewed_count author_id updated_on)
    @invalid_faqs = Faq.find(:all, :conditions => ["project_id = #{@project.id} and is_valid = ?", false], :order => sort_clause)
    
    render(:template => 'ezfaq/list_invalid_faqs.html.erb', :layout => !request.xhr?)
  end

  def show
    @faq.viewed_count += 1
    Faq.update_all("viewed_count = #{@faq.viewed_count}", "id = #{@faq.id}")
    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")

    respond_to do |format|
      format.html { render :template => 'ezfaq/show.html.erb', :layout => !request.xhr? }
      format.pdf  { send_data(faq_to_pdf, :type => 'application/pdf', :filename => "#{@project}-faq-#{@faq.id}.pdf") }
    end
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
        FaqMailer.deliver_faq_add(@project, @faq)
        redirect_to :controller => 'ezfaq', :action => 'show', :id => @project, :faq_id => @faq
        return
      end		
    end
  end

  # Action to preview the FAQ answer
  def preview
    @text = params[:faq][:answer]
    render :partial => 'common/preview'
  end

  def edit
    @faq_categories = FaqCategory.find(:all, :conditions => "project_id = #{@project.id}", :order => "position")
    
    if request.post?
      @faq.attributes = params[:faq]
      @faq.updater_id = User.current.id
      if @faq.save
        attach_files(@faq, params[:attachments])
        flash[:notice] = l(:notice_successful_update)
        FaqMailer.deliver_faq_update(@project, @faq)
        redirect_to :controller => 'ezfaq', :action => 'show', :id => @project, :faq_id => @faq
        return
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
  end

  def copy
    @allowed_projects = []
    # find projects to which the user is allowed to copy the faq
    if User.current.admin?
      # admin is allowed to copy faqs to any active (visible) project
      @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current))
    else
      User.current.memberships.each {|m| @allowed_projects << m.project if m.role.allowed_to?(:edit_faqs)}
    end
    @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
    @target_project ||= @project
    if request.post?
      @faq.copy(@target_project)
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'ezfaq', :action => 'index', :id => @project
      return
    end
    render :layout => false if request.xhr?
  end

  def destroy
    @faq.destroy
    redirect_to :action => 'index', :id => @project
  end
  
  def history
    limit = per_page_option
    @version_count = @faq.versions.count
    @version_pages = Paginator.new self, @version_count, limit, params['page']
    @versions = @faq.versions.find :all, :order => 'version DESC',
                                   :select => 'id, updater_id, updated_on, version',
                                   :limit => limit,
                                   :offset => @version_pages.current.offset

    render :layout => false if request.xhr?
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
      if @faq_setting.save
        redirect_to :action => 'index', :id => @project
        return
      end
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
  rescue
    render_404
  end

  def faq_to_pdf
    faq_setting = FaqSetting.find(:first, :conditions => "project_id = #{@project.id}")

    pdf = IFPDF.new(current_language)
    pdf.SetTitle("#{l(:label_faq)}-#{@faq.question}")
    pdf.SetAuthor('ezFAQ for Redmine')
    pdf.AliasNbPages
    pdf.footer_date = format_date(Date.today)
    pdf.AddPage
    
    pdf.SetFontStyle('B',16)
    pdf.Cell(200,5, faq_setting.pdf_title)
    pdf.Ln(15)

    pdf.SetFontStyle('B',11)
    pdf.Cell(200,5, "#{l(:field_question)}: #{@faq.question}")
    pdf.Ln
    pdf.Line(pdf.GetX, pdf.GetY, 180, pdf.GetY)
    pdf.Ln
    pdf.SetFontStyle('',11)
    pdf.MultiCell(200,5, @faq.answer)
    pdf.Ln

    pdf.Line(pdf.GetX, pdf.GetY, 100, pdf.GetY)
    pdf.SetFontStyle('I',8)
    pdf.Cell(200,5, 'Auto generated faq-document by ezFAQ. Powered by ezWORK & Redmine.')

    pdf.Output
  end

  def faqs_to_pdf
    pdf = IFPDF.new(current_language)
    pdf.SetTitle(@faq_setting.pdf_title) if (@faq_setting && @faq_setting.pdf_title)
    pdf.SetAuthor('ezFAQ for Redmine')
    pdf.AliasNbPages
    pdf.footer_date = format_date(Date.today)
    pdf.AddPage

    pdf.SetFontStyle('B',16)
    if (@faq_setting && @faq_setting.pdf_title)
      pdf.Cell(200,5, @faq_setting.pdf_title)
    else
      pdf.Cell(200,5, l(:text_faq_pdf_title_not_set))
    end
    
    pdf.Ln(10)
    pdf.SetFontStyle('',11)
    pdf.MultiCell(180,5, @faq_setting.note) if (@faq_setting && @faq_setting.note)
    pdf.Ln
    pdf.Line(pdf.GetX, pdf.GetY, 180, pdf.GetY)
    pdf.Ln

    list_number = 1
    if @categorized_faqs.any?
      @categorized_faqs.group_by(&:category).sort.each do |category, faqs|
        pdf.SetFontStyle('BI', 13)
        pdf.Cell(200,5, "#{list_number}. #{category.name}")
        pdf.Ln
        faq_number = 1
        for faq in faqs.sort
          pdf.SetFontStyle('B',11)
          pdf.Cell(200,5, "#{list_number}.#{faq_number} #{faq.question}")
          pdf.Ln
          pdf.SetFontStyle('',11)
          pdf.MultiCell(200,5, faq.answer)
          pdf.Ln
          faq_number += 1
        end
        pdf.Ln
        list_number += 1
      end
    end
    
    if @not_categorized_faqs.any?
      pdf.SetFontStyle('BI', 13)
      pdf.Cell(200,5, "#{list_number}. #{l(:label_not_categorized)}")
      pdf.Ln
      faq_number = 1
      for faq in @not_categorized_faqs.sort
        pdf.SetFontStyle('B',11)
        pdf.Cell(200,5, "#{list_number}.#{faq_number} #{faq.question}")
        pdf.Ln
        pdf.SetFontStyle('',11)
        pdf.MultiCell(200,5, faq.answer)
        pdf.Ln(10)
        faq_number += 1
      end      
    end

    pdf.Line(pdf.GetX, pdf.GetY, 100, pdf.GetY)
    pdf.SetFontStyle('I',8)
    pdf.Cell(200,5, 'Auto generated faq-list by ezFAQ. Powered by ezWORK & Redmine.')

    pdf.Output
  end
end
