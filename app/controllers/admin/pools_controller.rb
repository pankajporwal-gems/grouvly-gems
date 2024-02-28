class Admin::PoolsController < Admin::AdminsController
  include Admin::Pools
  include Admin::Payments

  def index
    if params[:location]
      @presenter = ListPoolsPresenter.new({ location: params[:location] })
    else
      @presenter = ListPoolsPresenter.new
    end
  end

  def show
    @presenter = ShowPoolPresenter.new(params[:id], params[:date], params[:page])
    respond_to do |format|
      format.json { render json: @presenter.reservations_json }
      format.html
    end
  end

  def possible_matches
    render json: { matches: reservations_json, slug: params[:id] }
  end


  def new_grouvly
    if params[:submit].present?
      @users = User.by_email_and_name(params[:email], params[:name].split) if params[:name].present? || params[:email].present?      
      if @users.blank?
        flash.now[:error] = I18n.t('admin.pools.new_grouvly.no_record_found')
      end
    end
  end

  def book_grouvly
    @user = User.where(id: params[:user_id]).first
     BRAINTREE_LOGGER.info("user_id :: #{@user.id}")
    if @user.present? && @user.accepted?
      if new_reservation.save
        new_reservation.update_attribute(:last_minute_booking, true) if params[:last_minute_booking].present?
        @new_payment_presenter = NewPaymentPresenter.new(payment)
        set_other_payment_info
        if payment.save
          grouvly_date = DateTime.parse(params[:schedule]).strftime('%d %b %Y (%a) at %l:%M %p') if params[:schedule].present?
          if payment.status == "success"
            payment_processor = PaymentProcessor.new(payment.reservation)
            result = payment_processor.capture_all_payments
            if result == 0
              BRAINTREE_LOGGER.info("payment_captured :: user => #{@user.id}, amount => #{payment.amount} ")
              payment.reservation.enter_payment! if payment.reservation.user == @user

              BRAINTREE_LOGGER.info("payment :: #{payment.inspect}, payment_status:: success, payment_result: #{result}")
              send_emails
              flash.now[:notice] = I18n.t('admin.pools.new_grouvly.create_reservation', user_name: @user.name, date: grouvly_date)
            else
              payment_error(payment, @user, result)
            end
          elsif payment.status == "pending"
            payment.reservation.pending_peyment! if payment.reservation.user == @user

            send_emails

            BRAINTREE_LOGGER.info("payment :: #{payment.inspect}, payment_status:: pending")

            flash.now[:notice] = I18n.t('admin.pools.new_grouvly.pending_reservation', user_name: @user.name, date: grouvly_date)
          end
        else
          payment_error(payment, @user, "payment_obj_not_saved")
        end
      else
        flash.now[:error] = @reservation.errors.full_messages.join(", ")
      end
    else
      BRAINTREE_LOGGER.info("user_id :: user_unavailable")
      flash.now[:error] = I18n.t('admin.pools.new_grouvly.user_unavailable')
    end
    render :new_grouvly
  end

  def update_reservation_date
    if params["move_reservaton_ids"].present?
      errors = ""
      error_message = ""
      reservation_ids = params["move_reservaton_ids"].split(",").uniq
      reservation_ids.each do |id|
        reservation = Reservation.where(slug: id).first
        unless reservation.update_attributes(schedule: params[:available_date], user_type: "admin")
          reservation.errors.messages.each {|key, value| error_message = value}
          errors << reservation.user.name + "::  #{error_message.first} "
        end
      end
      if errors.present?
        notification = { error:  errors}
      else
        date = DateTime.parse(params[:available_date]).strftime('%d %b %Y (%a) at %l:%M %p')
        notification = { notice:  I18n.t('admin.pools.show.moved_successfully', date: date) }
      end
    else
      notification = { error:  I18n.t('admin.pools.show.please_select_reservations') }
    end
    redirect_to admin_pool_path({id: params[:location_id], date: params[:date] }), flash: notification
  end

  def create
    if first_reservation && second_reservation && first_reservation != second_reservation
      if previously_matched?
        notification = { error: I18n.t('admin.pools.show.previously_matched') }
      else
        matched_reservation.first_reservation_id = first_reservation.id
        matched_reservation.second_reservation_id = second_reservation.id
        matched_reservation.schedule = first_reservation.schedule

        # if graph.get_connections("me", "friends/#{second_reservation.user.uid}").present?
        #   notification = { error: I18n.t('admin.pools.show.already_friends_in_facebook') }
        # elsif matched_reservation.save
        #   matched_reservation.new!(current_admin)
        #   notification = { notice: I18n.t('admin.pools.show.matched_successfully') }
        # else
        #   notification = { error: I18n.t('admin.pools.show.matched_wrongfully') }
        # end

        if matched_reservation.save
          matched_reservation.new!(current_admin)
          notification = { notice: I18n.t('admin.pools.show.matched_successfully') }
        else
          notification = { error: I18n.t('admin.pools.show.matched_wrongfully') }
        end
      end
    else
      notification = { error: I18n.t('admin.pools.show.matched_wrongfully') }
    end
    redirect_to admin_pool_path(user_location, { date: schedule }), flash: notification
  end
end

private

def payment_error(payment, user, result)
  payment.update_attribute(:status, 'error')
  BRAINTREE_LOGGER.info("payment :: #{payment.inspect}, payment_status:: error, payment_errors :: #{payment.errors.full_messages}, payment_result: #{result}")

  if user.errors.any?
    edit_profile_path = "#{request.protocol}#{request.host_with_port}#{edit_admin_member_path(user.id)}"
    flash.now[:error] = I18n.t('admin.pools.new_grouvly.incomplete_profile', edit_profile_url: edit_profile_path)
  else
    flash.now[:error] = I18n.t('admin.pools.new_grouvly.we_cannot_process_your_card', user_name: user.name)
  end
end
