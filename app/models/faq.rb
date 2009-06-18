class Faq < ActiveRecord::Base
  unloadable
  set_locking_column :version

  belongs_to :category, :class_name => 'FaqCategory', :foreign_key => 'category_id'
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :question, :project, :difficulty
  validates_length_of :question, :maximum => 255

  acts_as_attachable

  acts_as_searchable :columns => ["#{table_name}.question", "#{table_name}.answer"],
                        :include => [:project]

  acts_as_event :title => Proc.new {|o| "#{l(:label_title_ezfaq)} ##{o.id}: #{o.question}" },
                  :description => Proc.new {|o| "#{o.answer}"},
                  :datetime => :created_on,
                  :type => 'faqs',
                  :url => Proc.new {|o| {:controller => 'ezfaq', :action => 'show', :id => o.project, :faq_id => o.id} }

  acts_as_versioned :class_name => 'FaqVersion'
  self.non_versioned_columns << 'viewed_count'
  self.non_versioned_columns << 'created_on'
  self.non_versioned_columns << 'author_id'

  class FaqVersion
    belongs_to :category, :class_name => 'FaqCategory', :foreign_key => 'category_id'

    acts_as_event :title => Proc.new {|o| "#{l(:label_title_ezfaq)}: #{o.question} (##{o.version})" },
                  :description => Proc.new {|o| "#{o.answer}"},
                  :datetime => :updated_on,
                  :author => :updater,
                  :type => 'faqs',
                  :url => Proc.new {|o| o.next ?
                            {:controller => 'ezfaq', :action => 'show_history_version', :id => o.project, :faq_id => o.faq_id, :version => o.version } :
                            {:controller => 'ezfaq', :action => 'show', :id => o.project, :faq_id => o.faq_id } }

    acts_as_activity_provider :type => 'faqs',
                              :timestamp => "#{Faq.versioned_table_name}.updated_on",
                              :author_key => "#{Faq.versioned_table_name}.updater_id",
                              :permission => :view_faqs,
                              :find_options => {:joins => "LEFT JOIN #{Project.table_name} ON #{Project.table_name}.id = #{FaqVersion.table_name}.project_id"}


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

    def project
      Project.find(:first, :conditions => "projects.id = #{project_id}")
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

  # Copies a faq in current project or to a new project
  def copy(new_project)
    faq = self.clone
    if (faq.project_id != new_project.id)
      faq.project_id = new_project.id
      faq.category = nil
    end
    faq.save
  end

end
