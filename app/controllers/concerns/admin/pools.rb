module Admin::Pools
  extend ActiveSupport::Concern

  def first_reservation
    @first_reservation ||= Reservation.where(slug: params[:first_reservation_id]).first
  end

  def second_reservation
    @second_reservation ||= Reservation.where(slug: params[:second_reservation_id]).first
  end

  def previously_matched?
    MatchedReservation.find_each do |matched_reservation|
      if matched_reservation.current_state != "unmatched" && matched_reservation.first_reservation.present? && matched_reservation.second_reservation.present?
       user_arr = [matched_reservation.first_reservation.user.id, matched_reservation.second_reservation.user.id]
       new_matched_arr = [first_reservation.user.id, second_reservation.user.id]
       return true if user_arr.sort == new_matched_arr.sort
      end
    end
  end

  def schedule
    @schedule ||= first_reservation.schedule
  end

  def user_location
    @location ||= first_reservation.user.location
  end

  def matched_reservation
    @matched_reservation ||= MatchedReservation.new
  end

  def reservations_json
    (ActiveModel::ArraySerializer.new(reservations, each_serializer: ::ReservationSerializer))
  end

  def graph
    @graph ||= Koala::Facebook::API.new(first_reservation.user.oauth_token)
  end

  private

  def reservation
    @reservation ||= Reservation.where(slug: params[:id]).first
  end

  def reservations
    @reservations ||= Reservation.find_by_location_gender_and_schedule(reservation).unmatched.page(params[:page])
  end
end
