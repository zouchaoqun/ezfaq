class Faq < ActiveRecord::Base
  set_locking_column :version
  include GLoc

  belongs_to :category, :class_name => 'FaqCategory', :foreign_key => 'category_id'
  
  validates_presence_of :question, :project, :difficulty
  validates_length_of :question, :maximum => 255

  acts_as_attachable
  
  acts_as_versioned :class_name => 'FaqVersion'
  self.non_versioned_columns << 'viewed_count'
  self.non_versioned_columns << 'created_on'
  self.non_versioned_columns << 'author_id'
  
  class FaqVersion
    belongs_to :category, :class_name => 'FaqCategory', :foreign_key => 'category_id'
    
    def updater
      updater_id ? User.find(:first, :conditions => "users.id = #{updater_id}") : nil
    end

    def assigned_to
      assigned_to_id ? User.find(:first, :conditions => "users.id = #{assigned_to_id}") : nil
    end
      
    def issue
      related_issue_id ? Issue.find(:first, :conditions => "issues.project_id = #{project_id} and issues.id = #{related_issue_id}") : nil
    end

    def message
      related_message_id ? Message.find(:first, :conditions => ["messages.id = #{related_message_id}", "Message.Board.project_id = #{project_id}"]) : nil
    end

    def related_version
      related_version_id ? Version.find(:first, :conditions => "versions.project_id = #{project_id} and versions.id = #{related_version_id}") : nil
    end
    
  end
  
  
  def assigned_to
    assigned_to_id ? User.find(:first, :conditions => "users.id = #{assigned_to_id}") : nil
  end
  
  def author
    author_id ? User.find(:first, :conditions => "users.id = #{author_id}") : nil
  end
  
  def updater
    updater_id ? User.find(:first, :conditions => "users.id = #{updater_id}") : nil
  end
  
  def issue
    related_issue_id ? Issue.find(:first, :conditions => "issues.project_id = #{project_id} and issues.id = #{related_issue_id}") : nil
  end

  def message
    related_message_id ? Message.find(:first, :conditions => ["messages.id = #{related_message_id}", "Message.Board.project_id = #{project_id}"]) : nil
  end
  
  def related_version
    related_version_id ? Version.find(:first, :conditions => "versions.project_id = #{project_id} and versions.id = #{related_version_id}") : nil
  end
  
  def project
    Project.find(:first, :conditions => "projects.id = #{project_id}")
  end
  
  def <=>(faq)
    if Setting.default_language.to_s == 'zh'
      @ic ||= Iconv.new('GBK', 'UTF-8')
      @ic.iconv(question) <=> @ic.iconv(faq.question)
    else
      question <=> faq.question
    end
  end
  
  def to_s
    "##{id}: #{question}"
  end

end
