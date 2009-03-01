class FaqSetting < ActiveRecord::Base
  validates_presence_of :pdf_title, :note
  validates_length_of :pdf_title, :maximum => 200
end
