class ListMembersPresenter
  attr_reader :location, :total_straight_guys, :total_straight_girls, :total_gay_guys, :total_lesbians,
    :summaries, :members, :gender

  def initialize(options={})
    if options[:location]
      @location = options[:location]
      @gender = options[:gender]
      @members = MemberStatistics.get_members(options)

      # Show requested page or last page (default)
      page = options[:page] || (@members.count / Kaminari.config.default_per_page.to_f).ceil
      @members = @members.page(page)
    else
      @data = MemberStatistics.get_all_stats
      @total_straight_guys, @total_straight_girls, @total_gay_guys, @total_lesbians, @summaries = @data
    end
  end
end
