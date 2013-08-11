xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title      @dashboard && @dashboard.name || "Sauna"
   xml.link       "http://#{request.host}/"

   @posts.each do |post|
     xml.item do
       xml.title       post.title
       xml.description "#{post.image && image_tag(post.image)} #{post.body}"

       xml.link        "http://#{request.host}/p/#{post.id}"
       xml.guid        "http://#{request.host}/p/#{post.id}"

       xml.pubDate post.created_at.to_s(:rfc822)

       xml.enclosure :url => post.image

     end
   end

 end
end
