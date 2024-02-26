class User::ReservationsController < User::UsersController
  include User::Reservations
  include User::ReservationAuthorizations
  include User::VenueNotifications
  include User::UserTracking

  before_filter :get_reservation, only: [:roll, :roll_confirmed, :refund_amount]

  def new
    @new_reservation_presenter = NewReservationPresenter.new(reservation)
    @pending_reservation = pending_reservation
    if @new_reservation_presenter.available_admin_dates.blank?
      flash.now[:error] = t('user.reservations.errors.messages.you_have_reached_maximum_reservation')
    end

    track_page(PAGE_RESERVATION_PICK_DATE)
  end

  def create
    if reservation.new_record?
      reservation.skip_validation = true if reservation.last_minute_booking
      if reservation.save
        redirect_to new_user_payment_url(reservation: reservation.slug) and return
      else
        flash.now[:error] = reservation.errors.full_messages.first
        @new_reservation_presenter = NewReservationPresenter.new(reservation)
        render :new
      end
    else
      redirect_to new_user_payment_url(reservation: reservation.slug)
    end
  end

  def confirmed
    check_user_is_a_participant
    @confirmed_presenter = ConfirmedReservationPresenter.new(reservation, current_user)
    render not_found unless @confirmed_presenter.participants.include?(current_user)
  end

  def invite_wings
    check_user_is_lead
    @invite_wings_presenter = InviteWingsReservationPresenter.new(reservation)

    track_page(PAGE_RESERVATION_CONFIRMATION)
    track_page(PAGE_RESERVATION_NOTIFY)

    render 'invite_wings_mobile' if mobile_device?
  end

  def roll
    @presenter = ShowPoolPresenter.new(@reservation.user.location, @reservation.schedule, 1)
  end

  def roll_confirmed
    if params[:schedule]
      date = params[:schedule].to_datetime.strftime('%d %b %Y (%a) at %l:%M %p')
      is_roll = params[:is_roll].present? ? true : false
      if @reservation.update_attributes(schedule: params[:schedule], is_roll: is_roll)
        if is_roll
          render json: {msg: t('user.reservations.roll.msg_roll_true', date: date)}
        else
          render json: {msg: t('user.reservations.roll.msg_roll_false', date: date)}
        end
      end
    elsif params[:auto_roll]
      @reservation.update_attribute('is_roll', params[:auto_roll])
      redirect_to :back
    end
  end

  def refund_amount
    result = payment_processor.refund_total_amount
    if result
      if reservation.cancel!
        flash[:success] = t('user.reservations.refund_amount.refunded_successfully')
      else
        flash[:error] = reservation.errors.full_messages.to_sentence
      end
    else
      flash[:error] = t('user.reservations.refund_amount.refunded_failed')
    end
    redirect_to :back
  end


  def join
    set_join_grouvly_session
    @presenter = JoinReservationPresenter.new(reservation, current_user)
  end

  def confirm_venue_notification
    if venue_notification
      venue_notification.acknowledge!
    end
    render 'user/reservations/confirm_venue_notification', layout: 'feedback'
  end

  private

  def payment_processor
    PaymentProcessor.new(reservation)
  end

  def get_reservation
    begin
      @reservation ||= Reservation.find_by(slug: params[:id]) || Reservation.find_by(id: params[:id])
    rescue PG::InvalidTextRepresentation => exception
      # Handle the exception appropriately
      puts "Error: #{exception.message}"
    end
    
    # @reservation ||= Reservation.where(id: params[:id]).first
  end
end
