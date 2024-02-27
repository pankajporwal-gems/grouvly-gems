require 'csv'

namespace :data do
  desc "TODO"

  db_file = 'db/grouvly_production_two.sql'
  db_file_init = 'db/grouvly_production.sql'

  task perform_all: :environment do
    Rake::Task['data:restore_data'].invoke
    Rake::Task['data:read_data'].invoke
  end

  task restore_data: :environment do
    system "rake db:drop && rake db:create && psql -U postgres app_development < #{db_file_init}"
    system "pg_dump -U postgres --column-inserts --data-only --table=users app_development > #{db_file}"
    system "pg_dump -U postgres --column-inserts --data-only --table=user_infos --table=user_transitions  --table=versions app_development >> #{db_file}"
    system "rake db:drop && rake db:create && rake db:migrate"
  end

  task read_data: :environment do
    t_file = Tempfile.new('filename_temp.txt')

    File.open(db_file).readlines.each do |line|
      new_line = line

      if line.index('INSERT INTO users')
        new_line = line.gsub(/name/, "first_name, last_name")
        new_line = new_line.split(',')
        name = new_line[13].split(' ')
        first_name = name[0]
        first_name[0] = '' if first_name[0] == "'"
        last_name = name[1]
        last_name[-1] = '' if last_name[-1] == "'"
        new_line.insert(13, "'#{first_name}'")
        new_line.insert(14, "'#{last_name}'")
        new_line.delete_at(15)
        new_line = new_line.join(',')
      elsif line.index('INSERT INTO user_infos')
        new_line = line.gsub(/number/, "phone")
        new_line = new_line.gsub(/like_gender/, 'gender_to_match')
        new_line = new_line.gsub(/religion_importance/, 'importance_of_religion')
        new_line = new_line.gsub(/ethnicity_importance/, 'importance_of_ethnicity')
        new_line = new_line.gsub(/working_as/, 'current_work')
        new_line = new_line.gsub(/working_at/, 'current_employer')
      end

      t_file.puts new_line
    end

    t_file.close
    FileUtils.mv(t_file.path, db_file)
    Rake::Task['db:seed'].invoke
  end

  task export_user: :environment do
    states = ['new', 'pending', 'accepted', 'rejected', 'blocked', 'wing', 'deauthorized']

    states.each do |state|
      @filename = "users_#{state}.csv"
      @entries = User.in_state(state).order(:created_at)

      CSV.open("#{Rails.root.to_s}/#{@filename}", "wb") do |csv|
        csv << ["Date and Time", "Uid", "First Name", "Last Name", "Email", "Phone", "Gender", "Age",
          "Height", "Ethnicity", "Job", "Workplace", "Education", "Location"]

        @entries.each do |e|
          begin
            date = e.user_transitions.present? ? e.user_transitions.last.metadata['occured_on'] : e.created_at
            user_decorator = UserDecorator.new(e)
            csv << [date, e.uid, e.first_name, e.last_name, e.email_address, e.phone, e.gender,
              user_decorator.age, e.height, e.ethnicity, e.current_work, e.studied_at, e.location]
          rescue
            csv << [date, e.uid, e.first_name, e.last_name, '', '', '', '', '', '', '', '', '']
          end
        end
      end
    end
  end

  task export_reservations: :environment do
    users = User.joins('LEFT JOIN reservations ON reservations.user_id=users.id')
      .joins('LEFT JOIN cards on cards.user_id=reservations.user_id')
      .joins('LEFT JOIN payments ON payments.card_id=cards.id')
      .where(payments: { status: 'success' }).uniq

    CSV.open("#{Rails.root.to_s}/paying_members.csv", "wb") do |csv|
      csv << ["Uid", "First Name", "Last Name", "Email", "Phone", "Gender"]

      users.each do |e|
        csv << [e.uid, e.first_name, e.last_name, e.email_address, e.phone, e.gender]
      end
    end
  end

  task import_images: :environment do
    User.all.each do |user|
      unless user.user_info.blank?
        user.update_images
        UpdateFacebookJob.perform_now(user.id)
      end
    end
  end

  task export_dates: :environment do
    matches = MatchedReservation.joins('LEFT JOIN reservations ON reservations.id = matched_reservations.first_reservation_id')
      .group('reservations.schedule').order('reservations.schedule').count

    @filename = "matched_reservations.csv"

    CSV.open("#{Rails.root.to_s}/#{@filename}", "wb") do |csv|
      csv << ["Date and Time", "Count"]

      matches.each do |match|
        csv << [match[0].strftime('%B %d %Y'), match[1]]
      end
    end
  end

  task update_new_users: :environment do
    errors = 0

    User.in_state(:new).each do |user|
      begin
        graph = Koala::Facebook::API.new(user.oauth_token)
        me = graph.get_object('me')

        user_info = user.build_user_info
        user_info_setter = UserInfoSetter.new(user_info)
        user_info_setter.set_default_values(me)
        user_info_setter.set_gender(me)
        user_info_setter.set_education(me)
        user_info_setter.set_work(me)
        user_info_setter.set_birthday(me) if me['birthday']
        user_info.save!(validate: false)
      rescue Exception => e
        user.deauthorized!
      end
    end
  end

  task rejected_to_pending: :environment do
    filename = "#{Rails.root.to_s}/rejected_to_pending.csv"
    file = File.open(filename, 'r:iso-8859-1:utf-8') { |f| f.read }

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      user = User.find(row.to_hash[:id])
      user.pend!
    end
  end
end
