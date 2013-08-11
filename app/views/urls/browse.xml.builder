xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title      @dashboard && @dashboard.slug && @dashboard.slug.capitalize || "Sauna"
   xml.link       "http://#{request.host}/"

   @urls.each do |url|
     xml.item do
       xml.title       url.title
       xml.description url.image_urls.map{|i| image_tag(i)}.join('<br />') + url.text_for_item

       xml.link        "http://#{request.host}/url/#{url.id}"
       xml.guid        "http://#{request.host}/url/#{url.id}"

       xml.pubDate url.created_at.to_s(:rfc822)

       xml.enclosure :url => url.image_urls.first

     end
   end

 end
end
