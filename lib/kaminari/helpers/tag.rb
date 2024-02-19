# Force page params to be appended (see: http://stackoverflow.com/questions/5488064/how-to-force-kaminari-to-always-include-page-param)
module Kaminari
  module Helpers
    class Tag
      def page_url_for(page)
        @template.url_for @params.merge(@param_name => (page))
      end
    end
  end
end