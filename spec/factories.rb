FactoryBot.define do
  factory :market do
    name { "#{Faker::Space.meteorite} Market" }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    county { Faker::Address.community }
    state { Faker::Address.state }
    zip { Faker::Address.zip }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
  end

  factory :vendor do
    name { "#{Faker::Adjective.positive.capitalize} #{Faker::Music.genre} #{Faker::Restaurant.type}"}
    description { Faker::Hipster.sentence(word_count: 9) }
    contact_name { "#{Faker::Military.army_rank} #{Faker::Food.ingredient}" }
    contact_phone { Faker::PhoneNumber.cell_phone }
    credit_accepted { [true, false].sample }
  end

  factory :market_vendor do
    vendor
    market
  end
end