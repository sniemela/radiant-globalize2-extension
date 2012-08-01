module Globalize2::Compatibility
  module Archive::ArchivePageExtensions
    def self.included(base)
      base.class_eval do
        def child_url(child)

          @year, @month, @day = $1, ($2 || 1).to_i, ($3 || 1).to_i if child.request and child.request.request_uri =~ %r{/(\d{4})(?:/(\d{2})(?:/(\d{2}))?)?/?$}
          date = (@year ? Date.new(@year.to_i, @month, @day) : (child.published_at || Time.now))

          if ArchiveYearIndexPage === child
            clean_url "#{ url }/#{ date.strftime '%Y' }/"
          elsif ArchiveMonthIndexPage === child
            clean_url "#{ url }/#{ date.strftime '%Y/%m' }/"
          elsif ArchiveDayIndexPage === child
            clean_url "#{ url }/#{ date.strftime '%Y/%m/%d/' }/"
          else
            clean_url "#{ url }/#{ date.strftime '%Y/%m/%d' }/#{ child.slug }"
          end
        end
      end
    end
  end
end
