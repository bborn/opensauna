class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
     ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Encryptable
      t.string :password_salt

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      # Token authenticatable
      t.string :authentication_token

      ## Invitable
      t.string   :invitation_token, :limit => 60
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit
      t.integer  :invited_by_id
      t.string   :invited_by_type

      t.timestamps

      t.string :full_name
      t.string :vault_token
      t.references :subscription_plan
      t.references :coupon
      t.boolean :admin, default: false
      t.string :lazy_id
      t.text :dashboards_last_read

      t.timestamps
    end


    add_index :users, :email, :unique => true
    add_index :users, :subscription_plan_id
    add_index :users, :coupon_id
    add_index :users, :vault_token
    add_index :users, :created_at
  end
end
