if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage      = :file
    config.store_dir    = Rails.root.join('tmp')
    config.enable_processing = false
  end
else
  CarrierWave.configure do |config|
    config.storage :fog
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
    }
    config.fog_directory    = ENV['AWS_ASSETS_BUCKET']
    config.asset_host       = "http://#{ENV['AWS_ASSETS_BUCKET']}"
    config.fog_public       = true
    config.fog_attributes   = {'Cache-Control'=>'max-age=315576000'}
  end
end
