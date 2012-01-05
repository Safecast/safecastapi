class MustachioHandler
  
end

ActionView::Template.register_template_handler 'mustache.haml', MustachioHandler.new
