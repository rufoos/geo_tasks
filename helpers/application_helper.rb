module ApplicationHelper

  def json(data)
    data.to_json
  end

  def parse_body_json_params
    request.body.rewind
    req_body = request.body.read
    if req_body.present?
      params = JSON.parse(req_body)
      @params = params.inject({}){ |memo,(k,v) | memo[k.to_sym] = v; memo }
    end
  end
  
end