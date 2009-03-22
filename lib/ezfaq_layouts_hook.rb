# Hooks to attach to the Redmine base layouts(for dt.faq style in activity).
class EzfaqLayoutHook < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = { })
    if context[:controller] && (context[:controller].action_name == 'activity' || context[:controller].controller_name == 'search')
      '<style type="text/css">dt.faqs { background-image: url(/plugin_assets/ezfaq_plugin/images/question.png); }</style>'
    end
  end

end
