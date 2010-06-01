ActionController::Routing::Routes.draw do |map|
  map.connect '/:locale/*url', :controller => 'site', :action => 'show_page',
    :locale => Regexp.compile(Globalize2Extension.locales.join("|"))
end