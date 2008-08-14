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

RAILS_DEFAULT_LOGGER.info 'Starting ezFAQ plugin for RedMine'

Redmine::Plugin.register :ezfaq_plugin do
  name 'ezFAQ plugin'
  author 'Zou Chaoqun'
  description 'This is a FAQ management plugin for Redmine'
  version '0.0.2'

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :ezfaq do
    permission :view_faqs, {:ezfaq => [:index, :show, :history, :diff, :show_history_version]}, :public => true
    permission :add_faq, {:ezfaq => [:new]}, :require => :loggedin
    permission :edit_faq, {:ezfaq => [:edit, :destroy, :destroy_attachment, :list_invalid_faqs]}, :require => :member
    permission :manage_faq_categories, {:ezfaq => [:add_faq_category], :faq_categories => [:index, :change_order, :edit, :destroy]}, :require => :member
    permission :faq_setting, {:ezfaq => [:faq_setting]}, :require => :member
  end

  menu :project_menu, :ezfaq, { :controller => 'ezfaq', :action => 'index' }, :caption => 'FAQ'

end
