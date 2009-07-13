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

require 'redmine'

# Patches to the Redmine core. Will not work in development mode
require 'dispatcher'
require 'attachment_patch'
Dispatcher.to_prepare do
  Attachment.send(:include, AttachmentPatch)
end

# Hooks
require_dependency 'ezfaq_layouts_hook'

Redmine::Plugin.register :ezfaq_plugin do
  name 'ezFAQ plugin'
  author 'Zou Chaoqun'
  description 'This is a FAQ management plugin for Redmine'
  version '0.3.5'
  url 'http://ezwork.techcon.thtf.com.cn/projects/ezwork'
  author_url 'mailto:zouchaoqun@gmail.com'

  project_module :ezfaq do
    permission :view_faqs, {:ezfaq => [:index, :show, :history, :diff, :show_history_version]}, :public => true
    permission :add_faqs, {:ezfaq => [:new, :preview]}, :require => :loggedin
    permission :edit_faqs, {:ezfaq => [:edit, :preview, :copy, :list_invalid_faqs]}, :require => :member
    permission :delete_faqs, {:ezfaq => [:destroy]}, :require => :member
    permission :manage_faq_categories, {:ezfaq => [:add_faq_category], :faq_categories => [:index, :change_order, :edit, :destroy]}, :require => :member
    permission :faq_setting, {:ezfaq => [:faq_setting]}, :require => :member
  end

  menu :project_menu, :ezfaq, { :controller => 'ezfaq', :action => 'index' }, :caption => :label_title_ezfaq

  # Faqs are added to the activity view
  activity_provider :faqs, :class_name => 'Faq::FaqVersion', :default => false

end
