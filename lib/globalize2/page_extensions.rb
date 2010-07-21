module Globalize2
  module PageExtensions
    def self.included(base)
      base.validate.delete_if { |v| v.options[:scope] == :parent_id }
      base.send(:validate, :unique_slug)
      base.reflections[:children].options[:order] = 'pages.virtual DESC'
      
      base.class_eval do
        def self.locale
          I18n.locale
        end
        
        attr_accessor :reset_translations
        alias_method_chain 'tag:link', :globalize
        alias_method_chain 'tag:children:each', :globalize
        alias_method_chain :url, :globalize
        alias_method_chain :save_translations!, :reset
        
        def self.scope_locale(locale, &block)
          with_scope(:find => { :joins => "INNER JOIN page_translations ptrls ON ptrls.page_id = pages.id", :conditions => ['ptrls.locale = ?', locale] }) do
            yield
          end
        end
      end
    end
    
    def unique_slug      
      options = {
        "pages.parent_id = ?" => self.parent_id,
        "ptrls.slug = ?" => self.slug,
        "ptrls.locale = ?" => self.class.locale.to_s,
        "ptrls.page_id <> ?" => self.id
      }
      conditions_str = []
      conditions_arg = []
      
      options.each do |key, value|
        if value != nil
          conditions_str << key
          conditions_arg << value
        else
          conditions_str << "ptrls.page_id IS NOT NULL"
        end
      end
      
      conditions = [conditions_str.join(" AND "), *conditions_arg]
      if self.class.find(:first, :joins => "INNER JOIN page_translations ptrls ON ptrls.page_id = pages.id", :conditions => conditions )
        errors.add('slug', "must be unique")
      end
      
    end

    def save_translations_with_reset!
      if reset_translations && I18n.locale.to_s != Globalize2Extension.default_language
        self.translations.find_by_locale(I18n.locale.to_s).destroy
        parts.each do |part|
          part.translations.find_by_locale(I18n.locale.to_s).destroy
        end
      else
        save_translations_without_reset!
      end
    end
    
    def url_with_globalize
      unless parent
        '/' + I18n.locale.to_s + url_without_globalize
      else
        url_without_globalize
      end
    end
    
    def clone
      new_page = super
      translations.each do |t|
        new_page.translations << t.clone
      end
      new_page
    end
  end
end