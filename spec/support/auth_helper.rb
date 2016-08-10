module AuthHelper

  def current_user
    last_request.env['warden'].user
  end

end