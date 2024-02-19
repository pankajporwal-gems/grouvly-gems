# RAILS_ENV=production bundle exec rake mail:send_relaunch_emails > log/send_relaunch_emails_22112016.log
namespace :mail do
  desc 'CRON job to send Relaunch emails'
  task send_relaunch_emails: :environment do
    counter = 0
    max_emails = ENV['SEND_RELAUNCH_MAX_EMAILS'].presence || 1000

    User.not_in_state(:new).joins(:user_info).find_each do |user|
      break if counter >= max_emails

      if UserCache.can_send_relaunch_email_for?(user.id)
        voucher = Voucher.create_voucher(user)
        if voucher.present?
          counter = counter + 1

          UserCache.set_enqued_relaunch_email(user.id)

          RelaunchEmailWorker.perform_async(user.id, voucher.id)
          puts "enqued for : #{user.email_address}"
        else
          puts "user info is not valid for user.id: #{user.id}, email: #{user.email_address}"
        end
      else
        puts "already sent : #{user.email_address}"
      end
    end
  end
end
