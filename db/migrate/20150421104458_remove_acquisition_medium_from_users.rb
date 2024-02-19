class RemoveAcquisitionMediumFromUsers < ActiveRecord::Migration
  def change
    remove_columns :users, :acquisition_medium
  end
end
