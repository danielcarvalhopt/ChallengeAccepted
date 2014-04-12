module ApplicationHelper

def is_active?(link_path)
  if current_page?(link_path)
    raw("style='background: #404040;'")
  else
    ""
  end
 end

end
