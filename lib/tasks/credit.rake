namespace :credit do
  desc 'CRON job to credit '
  task reward_sign_up: :environment do
    users = User.in_state(:accepted)

    users.each do |user|
      if user.total_reservations_as_lead == 0
        if user.credits.where({ action: 'add', activity: 'signup' }).count == 0
          credit = Credit.new({ user_id: user.id })
          credit.amount = APP_CONFIG['referral_reward'][user.location]
          credit.action = 'add'
          credit.activity = 'signup'
          credit.actor_id = user.id
          credit.currency = APP_CONFIG['fee_currency'][user.location]
          credit.save!
        end
      end
    end
  end

  desc 'CRON job to expire credits greater than 30 days'
  task expire: :environment do
    start_date = Chronic.parse('30 days ago at 12am')
    end_date = Chronic.parse('30 days ago at 11:59pm')
    credits = Credit.where('created_at <= ? AND created_at >= ?', end_date, start_date)
      .where({ action: 'add', activity: 'signup' })

    credits.each do |credit|
      user = credit.user

      if user.used_credits == 0
        credit_processor = CreditProcessor.new(user)
        credit_processor.expire_credit(credit)
      end
    end
  end

  desc 'CRON job to send credit reminders'
  task remind_credit: :environment do
    days = { 15 => 15, 7 => 23, 3 => 27, 1 => 29 }

    days.each do |index, no_of_days|
      start_date = Chronic.parse("#{no_of_days} days ago at 12am")
      end_date = Chronic.parse("#{no_of_days} days ago at 11:59pm")
      credits = Credit.where('created_at <= ? AND created_at >= ?', end_date, start_date)
        .where({ action: 'add', activity: 'signup' })

      credits.each do |credit|
        user = credit.user

        SendCreditReminderJob.perform_now(index, credit.id) if user.used_credits == 0
      end
    end
  end
end
