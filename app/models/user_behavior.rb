module UserBehavior
  extend ActiveSupport::Concern 

  module ClassMethods
    def mixin_user
      delegate :email, :name, :first_name, :last_name, :address1, :address2,
        :city, :state, :zip, :primary_phone, :secondary_phone, :other_phone,
        :full_address, :password,
        :to => :user
      has_one  :user, :as => :profileable, :validate => false
      accepts_nested_attributes_for :user

      validates_associated :user
    end


  end

end
