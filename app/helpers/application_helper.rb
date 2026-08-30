module ApplicationHelper
  def app_name
    "京チカ"
  end

  def page_title_tag
    tag.title [ @page_title, app_name ].compact.join(" | ")
  end

  def page_header_tag
    tag.h1 app_name, class: "page-header__title"
  end
end
