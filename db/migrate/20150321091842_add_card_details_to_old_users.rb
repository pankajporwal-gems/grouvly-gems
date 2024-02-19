class AddCardDetailsToOldUsers < ActiveRecord::Migration
  def change
    Payment.where(card_id: nil).each do |payment|
      card = Card.new({ user_id: payment.user_id, token: 'free', bin: 4111, card_type: 'visa', last_digits: 1111 })
      card.save!
      payment.update_attribute(:card_id, card.id)
    end

    remove_column :payments, :user_id
  end
end
