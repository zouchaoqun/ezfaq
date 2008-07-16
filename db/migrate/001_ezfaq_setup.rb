# ezFAQ plugin migration
# Use rake db:migrate_plugins to migrate installed plugins
class EzfaqSetup < ActiveRecord::Migration
  def self.up
    create_table "faq_categories", :force => true do |t|
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "name", :string, :limit => 30, :default => "", :null => false
      t.column "list_order", :integer, :default => 1, :null => false
      t.column "faqs_count", :ingeger, :default => 0
    end
    
    add_index "faq_categories", ["project_id"], :name => "faq_categories_project_id"
  
    create_table "faqs", :force => true do |t|
      t.column "project_id", :integer, :default => 0, :null => false
      t.column "related_issue_id", :integer
      t.column "related_message_id", :integer
      t.column "related_version_id", :integer
      t.column "category_id", :integer
      t.column "author_id", :integer, :default => 0, :null => false
      t.column "question", :string, :default => "", :null => false
      t.column "answer", :text
      t.column "difficulty", :integer, :default => 5, :null => false
      t.column "viewed_count", :integer, :default => 0, :null => false
      t.column "assigned_to_id", :integer
      t.column "due_date", :date
      t.column "is_valid", :boolean, :default => true, :null => false
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
  
    add_index "faqs", ["project_id"], :name => "faqs_project_id"
    

    
  end

  def self.down
    drop_table :faq_categories
    drop_table :faqs
#    drop_table :faq_answers
  end
end
