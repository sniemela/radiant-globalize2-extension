module Globalize2
  module PagePartExtensions
    def clone
      new_page_part = super
      translations.each do |t|
        new_page_part.translations << t.clone
      end
      new_page_part
    end
  end
end