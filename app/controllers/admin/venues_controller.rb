class Admin::VenuesController < Admin::AdminsController
  before_action :set_venue_presenter

  def index
    @venues_by_location = []
    @location = params[:location]
    if @location
      query = VenueStatistics.query_by_location(@location).page( params[:page])
      @venues_by_location << { location: @location, venues: query }
    else
      APP_CONFIG['available_locations'].each do |location|
        query = VenueStatistics.query_by_location(location).limit(10)
        @venues_by_location << { location: location, venues: query }
      end
    end
  end

  def show
    @read_only_inputs = true
    render :edit
  end

  def create
    venue.valid?
    if venue.save
      respond_to do |format|
        format.html { redirect_to new_admin_venue_path }
        format.js { render json: { venue: venue }, status: :ok }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:error] = venue.errors.full_messages
          render :new
        }
        format.js {
          render json: { error: 'unprocessable_entity', error_description: venue.errors.full_messages },
                 status: :unprocessable_entity
        }
      end
    end
  end

  def update
    venue.valid?
    if venue.update(get_update_params)
      flash.now[:success] = t('admin.venues.edit.information_updated_successfully')
    else
      flash.now[:error] = venue.errors.full_messages.first
    end
    render :edit
  end

  def destroy
    if venue.destroy
      redirect_to admin_venues_path
    else
      flash.now[:error] = venue.errors.full_messages.first
      render :edit
    end
  end

  private

  def venue
    @venue ||= if params[:id]
      Venue.find(params[:id])
    elsif params[:venue]
      Venue.new(venue_params)
    else
      Venue.new
    end
  end

  def set_venue_presenter
    @venue_presenter = VenuePresenter.new(venue)
  end

  def venue_params
    params.require(:venue).permit(:name, :venue_type, :location, :neighborhood, :other_neighborhood,
                                  :owner_name, :owner_email, :owner_phone, :is_free, :map_link, :directions,
                                  :capacity, :manager_name, :manager_email, :manager_phone, :note)
                                  #booking_availability: Venue.stored_attributes[:booking_availability])
  end

  def get_update_params
    if venue_params[:neighborhood] == I18n.t('terms.others')
      parameters = venue_params.except(:neighborhood)
      parameters[:neighborhood] = venue_params[:other_neighborhood]
    else
      parameters = venue_params
    end
    parameters
  end
end