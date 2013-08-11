# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  version :thumb do
    process :resize_to_fill => [200,200]
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # def filename
  #   "#{Moped::BSON::ObjectId.new}#{super}"
  # end

  def filename
    random_token = "#{Moped::BSON::ObjectId.new}"
    ivar = "@#{mounted_as}_secure_token"
    token = model.instance_variable_get(ivar)
    token ||= model.instance_variable_set(ivar, random_token)
    "#{model.id}_#{token}.jpg" if original_filename
  end
 # store! nil's the cache_id after it finishes so we need to remember it for deletion
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end

  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
      FileUtils.rm_rf(File.join(cache_dir, @cache_id_was))
    end
  end



end
