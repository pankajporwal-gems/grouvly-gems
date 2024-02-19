class UserNotesDecorator
  attr_reader :user_notes

  def initialize(user_notes)
    @user_notes ||= user_notes
  end

  def to_list
    str = ''
    @user_notes.each do |note|
      str += "#{note.content} / "
    end
    str
  end
end
