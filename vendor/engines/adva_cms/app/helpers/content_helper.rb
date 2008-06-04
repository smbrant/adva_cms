module ContentHelper  
  def published_at_formatted(article)
    return 'not published' unless article && article.published?
    article.published_at.to_ordinalized_s(article.published_at.year == Time.now.year ? :stub : :mdy)
  end
  
  def content_url(*args)
    request.protocol + request.host_with_port + content_path(*args)
  end
  
  def content_path(content, options = nil)
    case content.section
    when Blog
      article_path content.section, content.full_permalink.merge(options || {})
    when Wiki
      wikipage_path *[content.section, content.permalink, options].compact
    else 
      section_article_path *[content.section, content.permalink, options].compact
    end    
  end
  
  def link_to_content(*args)
    content = args.pop
    text = args.pop || content.title
    link_to text, content_path(content)
  end
  
  def link_to_content_comments_count(content, options = {:total => true})
    total = content.comments.size
    approved = content.approved_comments.size
    return options[:alt] || 'none' if total == 0
    text = if total == approved or !options[:total]
      "#{total.to_s.rjust(2, '0')}"
    else
      "#{approved.to_s.rjust(2, '0')} (#{total.to_s.rjust(2, '0')})"
    end
    link_to_content_comments text, content
  end
  
  def link_to_content_comments(*args)
    text = args.shift if args.first.is_a? String
    content, comment = *args
    return unless content.approved_comments_count > 0 || content.accept_comments?
    text ||= pluralize(content.approved_comments_count, 'comment')
    path = content_path content, :anchor => (comment ? dom_id(comment) : 'comments')
    link_to text, path
  end
  
  def link_to_content_comment(*args)
    args.insert(args.size - 1, args.last.commentable)
    link_to_content_comments(*args)
  end
  
  def link_to_category(*args)
    category = args.pop
    section = args.pop
    route_name = "#{section.class.name.downcase}_category_path"
    link_to args.pop || category.title, send(route_name, :section_id => section.id, :category_id => category.id)
  end
  
  def links_to_content_categories(content, format_string = nil)
    return if content.categories.empty?
    links = content.categories.map{|category| link_to_category content.section, category }
    format_string ? format_string % links.join(', ') : links
  end

  def link_to_tag(*args)
    tag = args.pop
    section = args.pop
    route_name = "#{section.class.name.downcase}_tag_path"
    link_to args.pop || tag.name, send(route_name, :section_id => section.id, :tags => tag)
  end
  
  def links_to_content_tags(content, format_string = nil)
    return if content.tags.empty?
    links = content.tags.map{|tag| link_to_tag content.section, tag }
    format_string ? format_string % links.join(', ') : links
  end
  
  def content_category_checkbox(content, category)
    type = content.type.downcase
    checked = content.categories.include?(category)
    name = "#{type}[category_ids][]"
    id = "#{type}_category_#{category.id}"
    check_box_tag name, category.id, checked, :id => id
  end
end