class Market < ApplicationRecord 
  has_many :market_vendors, dependent: :destroy
  has_many :vendors, through: :market_vendors
  validates_presence_of :name,
                        :street,
                        :city,
                        :county,
                        :state,
                        :zip,
                        :lat,
                        :lon

  def vendor_count
    vendors.count
  end

end