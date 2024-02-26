module ApplicationHelper
  def page_id
    "#{controller_name.parameterize.dasherize}-controller"
  end

  def page_class
    "#{action_name.parameterize.dasherize}-action"
  end

  def title(title = nil)
    if title.present?
      content_for :title, title
    else
      content_for?(:title) ? APP_CONFIG['default_title'] + ' | ' + content_for(:title) : APP_CONFIG['default_title']
    end
  end

  def error_messages!(resource)
    return '' if resource.blank?

    if resource.is_a? String
      messages = content_tag(:li, resource)
      error_count = 1
    elsif resource.errors.empty?
      return ''
    else
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      error_count = resource.errors.count
    end

    sentence = I18n.t('errors.messages.not_saved', count: error_count)

    html = <<-HTML
      <div class="alert alert-danger">
        <h4>#{sentence}</h4>

        <ul>
          #{messages}
        </ul>
      </div>
    HTML

    html.html_safe
  end

  def small_profile_picture
    if session[:admin_photo]
      return session[:admin_photo]
    elsif current_user.user_info.present? && current_user.small_profile_picture.present?
      return current_user.small_profile_picture
    else
      return graph.get_picture(me['id'], { type: 'small' })
    end
  end

  def other_location?(array, location, params, type)
    if params.present?
      case type
      when "native_place"
        array.include?(location) && params[:native_place] != t('terms.others')
      when "neighborhood"
        array.include?(location) && params[:neighborhood] != t('terms.others')
      end
    else
      array.include?(location)
    end
  end

  def get_reservation(user, schedule)
    reservation =  user.reservations.where(schedule: schedule).first if schedule.present?
    reservation = user.reservations.build(schedule: schedule) if reservation.blank?
    NewReservationPresenter.new(reservation)
  end

  def is_last_minute_booking?(upcoming_date)
    if upcoming_date.present?
      before_48_hours = upcoming_date - 48.hours
      before_4_hours = upcoming_date - 4.hours
      current_time = Chronic.parse('now')
      current_time >= before_48_hours && current_time < before_4_hours
    else
      false
    end
  end

  def get_url_refferer
    uri = URI.parse(request.url)

    if uri.query.present?
      query_segment = uri.query.split("=")
      return query_segment.last if query_segment.include?("r")
    else
      path_segments = uri.path.split("/")
      return path_segments.last if path_segments.include?("r")
    end
  end

  def get_login_url
    if get_url_refferer.present?
      new_user_login_path(r: get_url_refferer)
    else
      new_user_login_path
    end
  end
end
