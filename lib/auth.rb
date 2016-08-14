Warden::Strategies.add(:token) do
  def valid?
    token
  end

  def authenticate!
    user = User.authenticate_by_token(token)
    if user
      success!(user)
    end
  end

  def token
    body_token = nil
    request.body.rewind
    req_body = request.body.read
    if req_body.present?
      body_json = JSON.parse(req_body)
      body_token = body_json['token']
    end
    
    body_token || params['token'] || env['AUTH_TOKEN']
  end
end

module Sinatra
  module Auth
    module Helpers
      def sign_in
        env['warden'].authenticate!
      end

      def sign_out
        env['warden'].logout
      end

      def current_user
        env['warden'].user
      end

      def logged_in?
        !current_user.nil?
      end
    end

    def self.registered(app)
      app.helpers Auth::Helpers

      app.use Warden::Manager do |config|
        # config.serialize_into_session{ |user| user.id }
        # config.serialize_from_session{ |id| User.find(id) }

        config.scope_defaults :default,
          strategies: [:token],
          action: '/unauth'
        
        config.failure_app = app
      end

      Warden::Manager.before_failure do |env, opts|
        env['REQUEST_METHOD'] = 'POST'
        env.each do |key, value|
          env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
        end
      end
    end
  end

  register Auth
end