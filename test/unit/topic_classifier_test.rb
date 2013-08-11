# require 'test_helper'


# class TopicClassifierTest < ActiveSupport::TestCase

#   should "use calais API to generate topics" do
#     text = "The new owners of once red-hot social news sharing service Digg have taken to their blog to reveal that they're ... 'thinking about monetization' and experimenting with several ways to make money, including a 'sponsored app' section on the website."
#     resp = Calais.process_document(
#         :content => text,
#         :content_type => :html,
#         :metadata_enables => Calais::KNOWN_ENABLES,
#         :use_beta => true,
#         :output_format => :json,
#         :license_id => 'ruefjhyz87skgb6xpznyakfs'
#       )

#     puts resp.socialtags.to_json
#   end

# end
