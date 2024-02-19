class UpdatePaymentStatus < ActiveRecord::Migration
  def change
    Payment.where(status: nil).each do |payment|
      payment.update_attribute(:status, 'success')
    end
  end
end
