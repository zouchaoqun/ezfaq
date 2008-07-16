class FaqAnswer < ActiveRecord::Base
  belongs_to :faq, :counter_cache => true
#  belongs_to :answerer, :class_name => 'User', :foreign_key => 'answerer_id'
  
  validates_presence_of :faq, :answer, :answerer_id
  
  def answerer
    User.find(:first, :conditions => "users.id = #{answerer_id}")
  end
  
  def attachments
    nil
  end
  
end
