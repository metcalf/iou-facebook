class ListLinkRenderer < WillPaginate::LinkRenderer
  def page_link(page, text, attributes = {})
    "<li>"+@template.link_to(text, url_for(page), attributes)+"</li>"
  end

  def page_span(page, text, attributes = {})
    "<li class=\"current\">"+@template.content_tag(:a, text, attributes)+"</li>"
  end
end