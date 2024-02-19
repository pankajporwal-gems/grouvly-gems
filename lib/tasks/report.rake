require 'csv'

namespace :report do
  desc 'CRON job to list all users with detailed number of grouvlies'
  task users: :environment do
    filename = 'users.csv'
    users = User.all.order('id')

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['ID', 'Country', 'Name', 'Status', 'Sign up Date', 'Registration Date', 'Acceptance Date',
        'Rejection Date', 'Grouvlies Booked', 'Grouvlies Completed', 'Grouvlies as a Wing', 'Total Revenues']

      users.each do |user|
        location = user.user_info.present? ? user.location : ''
        sign_up_date = user.created_at.strftime('%Y-%m-%d')
        registration_date = user.changed_state_on?(:pending) ? user.changed_state_on?(:pending).strftime('%Y-%m-%d') : ''
        acceptance_date = user.changed_state_on?(:accepted) ? user.changed_state_on?(:accepted).strftime('%Y-%m-%d') : ''
        rejection_date = user.changed_state_on?(:rejected) ? user.changed_state_on?(:rejected).strftime('%Y-%m-%d') : ''
        grouvlies_booked = user.total_reservations_as_lead
        grouvlies_completed = user.total_matched_and_paid_reservations.count
        grouvlies_wing = user.total_reservations_as_wing
        total_revenue = user.total_revenue

        csv << [user.id, location, "#{user.first_name} #{user.last_name}", user.current_state,
          sign_up_date, registration_date, acceptance_date, rejection_date, grouvlies_booked,
          grouvlies_completed, grouvlies_wing, total_revenue]
      end
    end

    Refile.store.upload(File.new("#{Rails.root.to_s}/#{filename}"))
  end

  desc 'CRON job to list all grouvlies'
  task grouvlys: :environment do
    filename = 'grouvlies.csv'
    matched_reservations = MatchedReservation.in_state(:new, :completed).order('id')
    not_matched_reservations = Reservation.unmatched.order('id')
    cancelled_reservations = Reservation.in_state(:cancelled)
    countries = { 'HKD' => 'Hong Kong', 'SGD' => 'Singapore' }

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['Grouvly 1 ID', 'Grouvly 2 ID', 'Country', 'Booking Date 1 ', 'Booking Date 2', 'Grouvly Date',
        'Lead 1 - User ID', 'Lead 2 - User ID', 'Total Amount Paid 1', 'Total Amount Paid 2', 'Status 1',
        'Status 2']

      matched_reservations.each do |match|
        begin
          match_one = match.first_reservation
          match_two = match.second_reservation

          first_payment = match_one.all_valid_payments.first
          second_payment = match_two.all_valid_payments.first

          country = countries[first_payment.currency.to_sym]
          schedule = match_one.schedule.strftime('%Y-%m-%d')
          booking_date_one = first_payment.created_at.strftime('%Y-%m-%d')
          booking_date_two = second_payment.created_at.strftime('%Y-%m-%d')

          csv << [match_one.id, match_two.id, country, booking_date_one, booking_date_two, schedule,
            match_one.user.id, match_two.user.id, match_one.total_amount_paid, match_two.total_amount_paid,
            match_one.state_string, match_two.state_string]
        rescue
          if match_one.user.blank?
            match_one.without_versioning :delete
            match.without_versioning :delete
          elsif match_two.user.blank?
            match_two.without_versioning :delete
            match.without_versioing :delete
          end
        end
      end

      not_matched_reservations.each do |reservation|
        country = countries[reservation.all_valid_payments.first.currency.to_sym]
        schedule = reservation.schedule.strftime('%Y-%m-%d')
        booking_date_one = reservation.created_at.strftime('%Y-%m-%d')

        csv << [reservation.id, '', country, booking_date_one, '', schedule, reservation.user.id,
          '', reservation.total_amount_paid, '', 'not matched', '']
      end

      cancelled_reservations.each do |reservation|
        if reservation.user.blank?
          reservation.without_versioning :delete
        else
          payment_object = PaperTrail::Version.where(event: 'destroy', item_type: 'Payment').where_object(reservation_id: reservation.id).first.object
          payment_object = PaperTrail.serializer.load(payment_object)

          country = countries[payment_object['currency'].to_sym]
          schedule = reservation.schedule.strftime('%Y-%m-%d')
          booking_date_one = reservation.created_at.strftime('%Y-%m-%d')

          csv << [reservation.id, '', country, booking_date_one, '', schedule, reservation.user_id, '', 0, '', 'cancelled', '']
        end
      end
    end

    Refile.store.upload(File.new("#{Rails.root.to_s}/#{filename}"))
  end

  desc 'CRON job to list all rejected users with details'
  task rejected_users: :environment do
    filename = 'rejected.csv'
    users = User.in_state(:rejected).order('id')

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['ID', 'Country', 'Name', 'Registration Date', 'Rejection Date', 'Studied At', 'Current Job',
        'Current Employer', 'Education History', 'Work History']

      users.each do |user|
        registration_date = user.changed_state_on?(:pending).strftime('%Y-%m-%d')
        rejection_date = user.changed_state_on?(:rejected).strftime('%Y-%m-%d')
        user_info = UserInfoDecorator.new(user.user_info)

        csv << [user.id, user.location, "#{user.first_name} #{user.last_name}", registration_date,
          rejection_date, user.studied_at, user.current_work, user.current_employer, user_info.education_history,
          user_info.work_history]
      end
    end
  end

  desc 'CRON job to list all users without grouvlys and will be given credits'
  task no_grouvlys_users: :environment do
    filename = 'no_grouvlys_users.csv'
    users = User.in_state(:accepted).order('id')

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['ID', 'Country', 'Name', 'Registration Date', 'Acceptance Date', 'Email']

      users.each do |user|
        if user.total_reservations_as_lead == 0
          registration_date = user.changed_state_on?(:pending).strftime('%Y-%m-%d')
          acceptance_date = user.changed_state_on?(:accepted).strftime('%Y-%m-%d')

          csv << [user.id, user.location, "#{user.first_name} #{user.last_name}", registration_date,
            acceptance_date, user.email_address]
        end
      end
    end
  end

  desc 'CRON job to list credit details'
  task credits: :environment do
    filename = 'credits.csv'
    users = User.in_state(:accepted).order('id')

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['ID', 'Country', 'Name', 'Credit Currency', 'Credit Amount', 'Credit Activity', 'Credit Action', 'Date Credited/Used', 'Email']

      users.each do |user|
        if user.credits.any?
          user.credits.each do |credit|
            csv << [user.id, user.location, "#{user.first_name} #{user.last_name}", credit.currency, credit.amount,
              credit.activity, credit.action, credit.created_at.strftime('%Y-%m-%d'), user.email_address]
          end
        end
      end
    end
  end

  desc 'CRON job to list accepted users'
  task accepted_users: :environment do
    filename = 'accepted_users.csv'
    users = User.in_state(:accepted).order('id')

    CSV.open("#{Rails.root.to_s}/#{filename}", "wb") do |csv|
      csv << ['ID', 'Country', 'Name', 'Email', 'Phone', 'Age', 'Ethinicity', 'Height']

      users.each do |user|
        csv << [user.id, user.location, "#{user.first_name} #{user.last_name}", user.email_address,
          user.phone, user.age, user.ethnicity, user.height]
      end
    end
  end
end
