class Authentication < ActiveRecord::Base

  belongs_to :user, :class_name => '::User'
  validates_uniqueness_of :uid, :scope => [:user_id, :provider], :message => " Error: Another user has already connected using that profile."

  after_destroy do
    self.extra.destroy
  end

  attr_accessor :page_ids

  def extra
    AuthenticationExtra.find_or_create_by(:auth_id => self.id)
  end


end
