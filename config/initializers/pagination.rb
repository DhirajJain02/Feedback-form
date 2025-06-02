# config/initializers/simple_pagination_renderer.rb

class Pagination < WillPaginate::ActionView::LinkRenderer
  protected

  # Wraps the entire pagination in a <nav><ul class="pagination">…</ul></nav>
  def html_container(html)
    @template.tag(:nav,
                  @template.tag(:ul, html, container_attributes.merge(class: 'pagination')),
                  aria: { label: 'Page navigation' }
    )
  end

  # Each page number becomes: <li class="page-item [active]"><a class="page-link">N</a></li>
  def page_number(page)
    if page == current_page
      @template.tag(:li,
                    @template.tag(:span, page, class: 'page-link'),
                    class: 'page-item active'
      )
    else
      @template.tag(:li,
                    link(page, page, rel: rel_value(page), class: 'page-link'),
                    class: 'page-item'
      )
    end
  end

  # “Previous” and “Next” buttons become <li class="page-item [disabled]">…</li>
  def previous_or_next_page(page, text, classname)
    li_class = classname == :previous_page ? 'prev' : 'next'
    if page
      @template.tag(:li,
                    link(text, page, class: 'page-link'),
                    class: "page-item #{li_class}"
      )
    else
      @template.tag(:li,
                    @template.tag(:span, text, class: 'page-link'),
                    class: "page-item #{li_class} disabled"
      )
    end
  end

  # Optionally wrap any other “gap” (ellipsis) elements
  def gap
    @template.tag(:li,
                  @template.tag(:span, '…', class: 'page-link'),
                  class: 'page-item disabled'
    )
  end

  # Ensure each <li> has no extra attributes except class:
  def container_attributes
    { }
  end

  # Ensure each link gets class="page-link"
  def link(text, target, attributes = {})
    attributes[:class] = (attributes[:class] || '') + ' page-link'
    super
  end
end
