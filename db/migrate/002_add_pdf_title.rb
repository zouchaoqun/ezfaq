# ezFAQ plugin migration
# Use rake db:migrate_plugins to migrate installed plugins
class AddPdfTitle < ActiveRecord::Migration
  def self.up
    add_column :faq_settings, :pdf_title, :string, :null => false, :default => 'FAQ'
    
  end

  def self.down
    remove_column :faq_settings, :pdf_title
  end
end
