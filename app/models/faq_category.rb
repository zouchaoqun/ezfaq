class FaqCategory < ActiveRecord::Base
  belongs_to :project
  has_many :faqs, :foreign_key => 'category_id', :dependent => :nullify
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:project_id]
  validates_length_of :name, :maximum => 30
  
  def <=>(category)
    list_order <=> category.list_order
  end
  
  def to_s; name end
  
  def before_save
    self.list_order = FaqCategory.maximum(:list_order) + 1
  end
  
end
