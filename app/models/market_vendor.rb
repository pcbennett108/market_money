class MarketVendor < ApplicationRecord 
  belongs_to :market
  belongs_to :vendor

  validate :unique_entry

  def unique_entry
    found = MarketVendor.find_by(market_id: self.market_id, vendor_id: self.vendor_id)
    if !found.nil?
      errors.add(:market_vendor, "association between market with 'id'=#{self.market_id} and vendor with 'id'=#{self.vendor_id} already exists")
    end
  end
end