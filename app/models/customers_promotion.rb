# == Schema Information
#
# Table name: customers_promotions
#
#  id           :integer          not null, primary key
#  customer_id  :integer
#  promotion_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  number_used  :integer          default(0)
#
# Indexes
#
#  index_customers_promotions_on_customer_id   (customer_id)
#  index_customers_promotions_on_promotion_id  (promotion_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (promotion_id => promotions.id)
#

class CustomersPromotion < ApplicationRecord
  belongs_to :customer
  belongs_to :promotion
end
