module HumanDate
  include ActionView::Helpers::DateHelper
  extend self

  def date_distance(from, to, long_form = true)
    seconds_in_day = 60 * 60 * 24
    days_difference = ((to.beginning_of_day.to_datetime - from.beginning_of_day.to_datetime)).floor

    case days_difference
    when -2
      "day before yesterday"
    when -1
      "yesterday"
    when 0
      "today"
    when 1
      "tomorrow, #{1.day.from_now.strftime("%B %d")}"
    when 2..6
      "this #{day_name(days_difference)}"
    when 7..13
      #"next #{to.strftime("%a")} (#{short_date(days_difference)})"
      "next #{day_name(days_difference)}"
    else
      if days_difference > 0
        "in #{distance_of_time_in_words(from, to)} (#{short_date(days_difference, long_form)})"
      else
        "#{distance_of_time_in_words(from, to)} ago (#{short_date(days_difference, long_form)})"
      end
    end
  end

  def short_date(this_many, include_day=false)
    format_string = "%-b %-d"
    format_string = "%a, #{format_string}" if include_day
    this_many.days.from_now.strftime(format_string)
  end

  def day_name(this_many)
    this_many.days.from_now.strftime("%A, %B %d")
  end
end
