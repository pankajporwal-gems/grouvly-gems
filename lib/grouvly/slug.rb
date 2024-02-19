module Grouvly
  module Slug
    extend self

    URL_CHARS = ('0'..'9').to_a + %w(b c d f g h j k l m n p q r s t v w x y z) + %w(B C D F G H J K L M N P Q R S T V W X Y Z - _)
    URL_BASE = URL_CHARS.size

    def generate(id)
      count = id
      result = ''

      while count != 0
        rem = count % URL_BASE
        count = (count - rem) / URL_BASE
        result = URL_CHARS[rem] + result
      end

      result
    end
  end
end
