class RelaunchEmailWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options queue: 'relaunch_emails'

  def perform user_id, voucher_id
    user = User.find(user_id)
    voucher = Voucher.find(voucher_id)
    CreditMailer.send_relaunch_email(user, voucher).deliver

    UserCache.set_sent_relaunch_email(user_id)
  end
end