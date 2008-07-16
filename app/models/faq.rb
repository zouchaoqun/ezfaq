class Faq < ActiveRecord::Base
#  belongs_to :project
#  belongs_to :issue, :class_name => 'Issue', :foreign_key => 'related_issue_id'
#  belongs_to :message, :class_name => 'Message', :foreign_key => 'related_message_id'
#  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
#  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  belongs_to :category, :class_name => 'FaqCategory', :foreign_key => 'category_id', :counter_cache => true
  
  #has_many :attachments, :as => :container, :dependent => :destroy  
  
  validates_presence_of :question, :project, :difficulty
  validates_length_of :question, :maximum => 255

  #acts_as_searchable :columns => ['question', "#{table_name}.description"]
  
  def assigned_to
    assigned_to_id ? User.find(:first, :conditions => "users.id = #{assigned_to_id}") : nil
  end
  
  def author
    author_id ? User.find(:first, :conditions => "users.id = #{author_id}") : nil
  end
  
  def issue
    related_issue_id ? Issue.find(:first, :conditions => "issues.id = #{related_issue_id}") : nil
  end

  def message
    related_message_id ? Message.find(:first, :conditions => "messages.id = #{related_message_id}") : nil
  end
  
  def attachments
    Attachment.find(:all, :conditions => "attachments.container_type = 'FAQ' and attachments.container_id = #{id}")
  end
  
  def find_attachment(attachment_id)
    Attachment.find(:first, :conditions => "attachments.container_type = 'FAQ' and attachments.container_id = #{id} and attachments.id = #{attachment_id}")
  end
  
  def project
    Project.find(:first, :conditions => "projects.id = #{project_id}")
  end
  
  def to_s
    "##{id}: #{question}"
  end  
end
