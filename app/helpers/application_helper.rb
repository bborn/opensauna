module ApplicationHelper

  def bookmarklet_link(dashboard = '')
    "javascript:(function() {d=document, w=window, e=w.getSelection, k=d.getSelection, x=d.selection, s=(e?e():(k)?k():(x?x.createRange().text:0)), e=encodeURIComponent, document.location='#{root_url}urls/new.bookmark?url[dashboard_ids][]=#{dashboard.id}&url[url]='+e(document.location)+'&url[title]='+e(document.title)+'&url[description]='+e(s);} )();"
  end

  def flash_class(level)
    case level
      when :notice then "alert-info"
      when :error then "alert-error"
      when :alert then "alert-warning"
    end
  end

  def background_image_tag(src, options = {})

    style = "background:url(#{image_path src}) no-repeat; background-size: cover;"
     # "width: 100px; height: 100px"

    ['width', 'height'].each do |dim|
      if val = options.delete(dim.to_sym)
        style += "#{dim}: #{!val.to_i.eql?(0) ? val.to_s+'px' : val };"
      end
    end

    if css = options.delete(:style)
      style += css
    end

    options[:style] = style

    image_tag 's.png', options
  end


end
