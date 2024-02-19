module Grouvly
  module ReservationDate
    extend self

    def first_available_date(type=nil)
      #thursday = Chronic.parse('this thursday at 8PM')
      #friday = Chronic.parse('this friday at 9PM')
      #day = friday < thursday ? friday : thursday
      #day_and_one_day = Chronic.parse('today at 9PM') + 1.day

      #if day_and_one_day >= day
        #if day.strftime('%A') == 'Thursday'
          #day = friday
        #else
          #day = Chronic.parse('next week thursday at 8PM')
        #end
      #end

      #day
      # first_day = Chronic.parse('next week thursday at 8PM')
      # earliest_day = Chronic.parse('today at 8PM') + 7.days

      # if earliest_day > first_day
      #     first_day + 7.days
      # end
      first_day = Chronic.parse('this thursday at 8PM')
      today_day = Chronic.parse('today at 8PM')
      if type.present?
        current_time = Chronic.parse('today')
        first_day = today_day if current_time.wday == 4 && current_time < today_day
        first_day = first_day + 7.days if today_day > first_day
      else
        two_days_before = first_day - 2.days
        first_day = first_day + 7.days if today_day > two_days_before
      end
      first_day
    end

    def second_available_date(type=nil)
      generate_date(first_available_date(type))
    end

    def third_available_date(type=nil)
      generate_date(second_available_date(type))
    end

    def fourth_available_date(type=nil)
      generate_date(third_available_date)
    end

    def fifth_available_date(type=nil)
      generate_date(fourth_available_date)
    end

    def custom_available_dates(type=nil)
      temp = generate_date(third_available_date(type))
      dates_ar = []

      dates_ar << [temp.strftime("%A, %B %d"), temp]

      (0..4).each do |a|
        temp = generate_date(temp)
        dates_ar << [temp.strftime("%A, %B %d"), temp]
      end

      dates_ar
    end

    def all_available_dates(type=nil)
      dates_ar = []

      [first_available_date(type), second_available_date(type), third_available_date(type)].each do |temp|
        dates_ar << [temp.strftime("%A, %B %d"), temp]
      end
      dates_ar | custom_available_dates(type)
    end

    def next_five_available_dates(type=nil)
      dates_ar = []

      [first_available_date(type), second_available_date(type), third_available_date(type), fourth_available_date(type),fifth_available_date(type)].each do |temp|
        dates_ar << [temp.strftime("%A, %B %d"), temp]
      end
      dates_ar
    end

    def all_available_dates_with_most_recent
      all_available_dates_with_most_recent = all_available_dates
      #previous_day = all_available_dates.first.last
      #previous_second_day = nil

      #if previous_day.strftime('%A') == 'Thursday'
        #previous_day = previous_day - 7.days
      #else
        #if previous_day > Chronic.parse('today at 9PM')
          #previous_previous_day = previous_day - 193.hours
          #previous_day = previous_previous_day + 25.hours
          #previous_second_day = previous_previous_day + 7.days
        #else
          #previous_day = previous_day - 193.hours
        #end
      #end
      #previous_second_day = previous_day + 25.hours if previous_second_day.blank?

      #all_available_dates_with_most_recent.unshift([previous_second_day.strftime("%A, %B %d"), previous_second_day])
      #all_available_dates_with_most_recent.unshift([previous_day.strftime("%A, %B %d"), previous_day])

      #if previous_previous_day.present?
        #all_available_dates_with_most_recent.unshift([previous_previous_day.strftime("%A, %B %d"), previous_previous_day])
      #end

      previous_day = all_available_dates.first.last - 7.days
      previous_previous_day = previous_day - 7.days
      all_available_dates_with_most_recent.unshift([previous_previous_day.strftime("%A, %B %d"), previous_previous_day])
      all_available_dates_with_most_recent.unshift([previous_day.strftime("%A, %B %d"), previous_day])

      all_available_dates_with_most_recent
    end

    def is_schedule_valid?(schedule, type=nil)
      all_available_dates(type).select { |d| d[1] == schedule }.count > 0
    end

    def is_schedule_with_most_recent_valid?(schedule)
      all_available_dates_with_most_recent.select { |d| d[1] == schedule }.count > 0
    end

    def all_dates(type=nil)
      ReservationDate.all_available_dates(type).map { |d| d[1] }
    end

    def available_valid_dates(user)
      all_dates - user_schedules(user)
    end

    def unavailable_valid_dates(user)
      all_dates - available_admin_valid_dates(user)
    end

    def available_admin_valid_dates(user, user_type=nil)
      all_dates(user_type) - admin_user_schedules(user)
    end

    def admin_available_valid_dates(user)
      dates_ar = []
      available_admin_valid_dates(user, "admin").each do |temp|
        dates_ar << [temp.strftime("%A, %B %d"), temp]
      end
      dates_ar
    end

    def user_available_valid_dates(user)
      dates_ar = []
      available_valid_dates(user).each do |temp|
        dates_ar << [temp.strftime("%A, %B %d"), temp]
      end
      dates_ar
    end

    def last_minute_booking_date(user)
      available_admin_valid_dates(user, "admin").first
    end

    private

    def admin_user_schedules(user)
      user_reservation_scope = UserReservationScope.new(user)
      user_reservation_scope.admin_all_latest_reservations.order('reservations.schedule')
        .select('reservations.schedule').to_a.map(&:schedule)
    end

    def user_schedules(user)
      user_reservation_scope = UserReservationScope.new(user)
      user_reservation_scope.all_latest_reservations.order('reservations.schedule')
        .select('reservations.schedule').to_a.map(&:schedule)
    end

    def generate_date(date)
      #if date.strftime('%A') == 'Thursday'
        #date + 25.hours
      #else
        #date + 143.hours
      #end
      date + 7.days
    end
  end
end
