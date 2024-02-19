class LocationsController < ApplicationController
  def countries
    locations = APP_CONFIG['available_locations']
    respond_to do |format|
      format.json { render json: locations }
    end
  end

  def neighborhoods
    neighborhoods = APP_CONFIG['available_neighborhoods']| [I18n.t('terms.others')]
    respond_to do |format|
      format.json { render json: neighborhoods }
    end
  end
end