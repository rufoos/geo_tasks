module ApplicationHelper

  def view(template, opt = {}, locals = {})
    jbuilder template.to_sym, opt, locals
  end
  
end