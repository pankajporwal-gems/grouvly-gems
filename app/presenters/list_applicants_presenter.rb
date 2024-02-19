class ListApplicantsPresenter
  attr_reader :location, :total_straight_guys, :total_straight_girls, :total_gay_guys, :total_lesbians,
    :summaries, :applicants, :gender

  def initialize(options={})
    if options[:location]
      @location = options[:location]
      @gender = options[:gender]
      @applicants = ApplicantStatistics.get_applicants(options)

      # Show requested page or last page (default)
      page = options[:page] || (@applicants.count / Kaminari.config.default_per_page.to_f).ceil
      @applicants = @applicants.page(page)
    else
      @data = ApplicantStatistics.get_all_stats
      @total_straight_guys, @total_straight_girls, @total_gay_guys, @total_lesbians, @summaries = @data
    end
  end
end
