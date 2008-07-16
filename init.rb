# Redmine ezFAQ plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting ezFAQ plugin for RedMine'

Redmine::Plugin.register :ezfaq_plugin do
  name 'ezFAQ plugin'
  author 'Zou Chaoqun'
  description 'This is a FAQ management plugin for Redmine'
  version '0.0.1'
  #settings :default => {'welcome_list_size' => '10'}, :partial => 'settings/settings'

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :ezfaq do
    permission :view_faqs, {:ezfaq => [:index, :show]}, :public => true
    permission :ask_questions, {:ezfaq => [:new]}, :require => :loggedin
    permission :edit_faqs, {:ezfaq => [:edit, :answer, :destroy_attachment]}, :require => :member
    permission :manage_faq_categories, {:ezfaq => [:add_faq_category], :faq_categories => [:index, :edit, :destroy]}, :require => :member

  end

  menu :project_menu, :ezfaq, { :controller => 'ezfaq', :action => 'index' }, :caption => 'FAQ'

end
