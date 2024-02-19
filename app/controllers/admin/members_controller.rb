class Admin::MembersController < Admin::AdminsController
  before_filter :check_member_is_valid, only: [:show]
   before_filter :get_user, only: [:show, :edit, :update]


  def index
    if params[:location]
      @presenter = ListMembersPresenter.new({ location: params[:location], gender: params[:gender],
        page: params[:page] })
    else
      @presenter = ListMembersPresenter.new
    end
  end

  def show
    @payments_with_voucher = Payment.includes(:reservation, :voucher).joins(card: :user).where(users: { id: member.id })
      .where("(payments.status = 'success' AND payments.method = 'authorize') OR payments.method IN ('capture', 'refund')")
      .where('payments.voucher_id IS NOT NULL')
  end

  def edit
    membership = @user_decorator.user.user_info
    @presenter = EditMembershipPresenter.new(membership)
  end

  def update
    errors = []
    user_info = @user_decorator.user.user_info
    if user_info.update_attributes(member_params)
      flash[:notice] = t('admin.applicants.update.success')
    else
      user_info.errors.messages.each {|key, value| errors << "#{key} : #{value.join(",")}"}
      flash[:error] = errors.join(", ")
    end
    redirect_to :back
  end

  def search
    request.format = "csv" if params[:export].present?
    @search_member_presenter = SearchMemberPresenter.new
    all_records = UserScope.filter_members(member_filter_params)
    @members = all_records.page(params[:page])
    respond_to do |format|
      format.html

      format.csv { send_data all_records.to_csv, filename: 'member_details.csv'}

      format.json { render json: (ActiveModel::ArraySerializer.new(@members, each_serializer: UserSerializer,root: 'members')).to_json }
    end
  end

  def create_note
    if params[:content].present?
      member.user_notes << UserNote.new(content: params[:content])
      unless member.save
        flash[:error] = member.errors.full_messages.to_sentence
      end
    end
    redirect_to :back
  end

  private

  def check_member_is_valid
    not_found if member.pending? || member.new?
  end

  def member
    @member ||= User.friendly.find(params[:id])
  end

  def get_user
    @user_decorator = UserDecorator.new(member)
  end

  def member_params
    params[:user_info][:meet_new_people_ages] ||= []
    params[:user_info][:neighborhoods] ||= []
    params[:user_info][:typical_weekends] ||= []
    params.require(:user_info).permit(:email_address, :gender_to_match, :location, :phone, :current_work, :studied_at, :religion, :ethnicity, :height, :current_employer, :gender, :birthday, :native_place, :hang_out_with, meet_new_people_ages:[], neighborhoods:[], typical_weekends:[])
  end

  def member_filter_params
    params.permit(:location, :gender, :age_min, :age_max, :height_min, :height_max, :ethnicity, :name, :origin, :hang_out_with, meet_new_people_ages:[], neighborhoods:[], typical_weekends:[])
  end
end
