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

module EzfaqHelper

  def updated_by(updated, author)
    time_tag = content_tag('acronym', distance_of_time_in_words(Time.now, updated), :title => format_time(updated))
    author_tag = (author.is_a?(User) && !author.anonymous?) ? link_to(h(author), :controller => 'account', :action => 'show', :id => author) : h(author || 'Anonymous')
    l(:label_updated_time_by, author_tag, time_tag)
  end
  
  def will_pagination_links(collection)
    html = ''
    pages = will_paginate(collection, :prev_label => '&#171; ' + l(:label_previous), :next_label => l(:label_next) + ' &#187;', :container => false)
    html << pages if pages
    html << " (#{collection.offset+1}-#{collection.offset+collection.length}/#{@version_count}) | #{l(:label_display_per_page, collection.per_page)}" 
    html
  end
  
end
