class Admin::AdminsController < ApplicationController
  include Admin::AdminAuthentication

  layout 'admin'

  def applicants
    @pending_applicants ||= User.in_state(:pending).order('transition1.created_at')
  end

  def reservations_to_match
    @reservations_to_match ||= ReservationStatistics.get_all_valid_reservations
  end

  helper_method :applicants
  helper_method :reservations_to_match
end
