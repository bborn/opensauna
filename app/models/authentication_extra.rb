class AuthenticationExtra
  include Mongoid::Document
  include Mongoid::Timestamps

  field :managed_page_ids, :type => Array, :default => []
  field :screen_name
  field :auth_id, :type => Integer
  field :pages
  field :boards

  validates_uniqueness_of :auth_id

  def managed_pages
    !pages.blank? ? pages.select{|h| self.managed_page_ids.include?(h['id']) } : []
  end

end
