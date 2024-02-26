class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def parse_date(date_string)
    DateTime.parse(date_string)
  end
  
  def created_at
    if self.attributes["created_at"].is_a?(String)
      DateTime.parse(self.attributes["created_at"])
    else
      self.attributes["created_at"]
    end
  end

  def updated_at
    if self.attributes["updated_at"].is_a?(String)
      DateTime.parse(self.attributes["updated_at"])
    else
      self.attributes["updated_at"]
    end
  end
    
end