class Admin::ApplicantsController < Admin::AdminsController
  include Admin::AdminTracking

  before_filter :check_applicant_is_valid, only: [:show, :accept, :accept_member, :reject, :reject_member]

  def index
    if params[:location]
      @presenter = ListApplicantsPresenter.new({ location: params[:location], gender: params[:gender],
        page: params[:page] })
    else
      @presenter = ListApplicantsPresenter.new
    end
  end

  def show
    @user_decorator = UserDecorator.new(applicant)
    applicant.update_images
  end

  def export_applicant
    if params[:location].present?
      applicants = User.applicants_by_location(params[:location])
      respond_to do |format|
        format.csv { send_data applicants.to_csv, filename: "#{params[:location]}_applicant_details.csv"}
      end
    end
  end

  def accept_selected
    if params["user_ids"].present?
      params["user_ids"].each do |id|
        @applicant = User.friendly.find(id)
        @applicant.accept!(current_admin)
        track_applicant_event(@applicant, EVENT_APPLICANT_ACCEPTED, { acceptance_date: Chronic.parse('today').strftime('%Y-%m-%d') })
      end
    end
    render text: "accepted"
  end

  def reject_selected
    if params["user_ids"].present?
      params["user_ids"].each do |id|
        @applicant = User.friendly.find(id)
        @applicant.reject!(current_admin, "admin_rejected")
        @applicant.reservations.each do |reservation|
          cancel_booking(reservation.slug)
        end
        track_applicant_event(applicant, EVENT_APPLICANT_REJECTED, { rejection_reason: params[:reason], rejection_date: Chronic.parse('today').strftime('%Y-%m-%d') })
      end
    end
    render text: "rejected"
  end

  def accept
    @accept_applicant_presenter = AcceptApplicantPresenter.new(applicant)
  end

  def accept_member
    applicant.membership_type = params[:user][:membership_type].downcase
    applicant.user_info.work_category = params[:user][:work_category]
    applicant.user_info.lifestyle =  params[:user][:lifestyle]
    applicant.user_info.linkedin_link = params[:user][:linkedin_link]

    unless params[:user][:note].blank?
      applicant.user_notes << UserNote.new(content: params[:user][:note])
    end

    if applicant.save(validate: false)
      applicant.accept!(current_admin)

      track_applicant_event(applicant, EVENT_APPLICANT_ACCEPTED, { acceptance_date: Chronic.parse('today').strftime('%Y-%m-%d') })

      redirect_to admin_member_url(params[:id])
    else
      flash.now[:error] = applicant.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def reject_member
    if params[:reason].blank?
      @error_message = I18n.t('admin.applicants.reason_for_rejection_error')
      render :reject
    else
      @applicant.reject!(current_admin, params[:reason])
      @applicant.reservations.each do |reservation|
        cancel_booking(reservation.slug)
      end
      track_applicant_event(applicant, EVENT_APPLICANT_REJECTED, { rejection_reason: params[:reason], rejection_date: Chronic.parse('today').strftime('%Y-%m-%d') })

      redirect_to admin_member_url(params[:id])
    end
  end

  private

  def cancel_booking(slug)
    reservation = Reservation.where("slug = ?", slug).first
    payment_processor = PaymentProcessor.new(reservation)
    result = payment_processor.refund_total_amount
    if result && reservation.cancel!
      # ReservationMailer.notify_about_cancel_reservation(reservation.id).deliver_later
    end
  end

  def applicant
    @applicant ||= User.friendly.find(params[:id])
  end

  def check_applicant_is_valid
    not_found if applicant.blank? || !applicant.pending?
  end

  def track_applicant_event(applicant, event_name, options = {})
    user = UserDecorator.new(@applicant)
    event_properties = {
      title: @applicant.current_work,
      company: @applicant.current_employer,
      education: @applicant.studied_at,
      height: @applicant.height,
      referred: user.referred
    }.merge(options)
    track_event(applicant, event_name, options)
  end
end
