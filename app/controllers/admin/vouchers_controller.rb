class Admin::VouchersController < Admin::AdminsController
  def index
    @vouchers = Voucher.all.page(params[:page])
  end

  def new
    @voucher = Voucher.new
  end

  def create
    @voucher = Voucher.new(voucher_params)

    if @voucher.save
      redirect_to edit_admin_voucher_url(@voucher), notice: I18n.t('admin.vouchers.new.voucher_created')
    else
      render :new
    end
  end

  def edit
    @voucher = Voucher.find(params[:id])
  end

  def update
    @voucher = Voucher.find(params[:id])

    if @voucher.update(voucher_params)
      flash.now[:notice] = I18n.t('admin.vouchers.edit.voucher_updated')
    end

    render :edit
  end

  private

  def voucher_params
    params.require(:voucher).permit(:description, :voucher_type, :amount, :start_date, :end_date,
      :quantity, :user_id, :gender, :restriction)
  end
end
