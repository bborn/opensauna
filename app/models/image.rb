class Image

  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :file, ImageUploader
  belongs_to :attachable, :polymorphic => true, :index => true

end
