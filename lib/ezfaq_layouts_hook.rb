# Hooks to attach to the Redmine base layouts(for dt.faq style in activity).
class EzfaqLayoutHook < Redmine::Hook::ViewListener

#  def protect_against_forgery?
#    false
#  end

  #dt.faq { background-image: url(../plugin_assets/ezfaq_plugin/images/question.png); }

  def view_layouts_base_html_head(context = { })
    #self.action_name
  end

  def view_layouts_base_body_bottom(context = { })
    #context[:action_name]
    context[:controller].action_name
    #debug(context)
  end

end
