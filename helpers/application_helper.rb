module ApplicationHelper

  def view(template, options = {})
    content_type :json
    jbuilder template.to_sym, options
  end
  
end