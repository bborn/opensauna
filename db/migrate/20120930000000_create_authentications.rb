class CreateAuthentications < ActiveRecord::Migration

  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      
      t.references :user
      t.timestamps
    end
  end
end