json.array!(@challenges) do |challenge|
  json.extract! challenge, :id, :challenger_id, :challenged_id, :amount, :state_id
  json.url challenge_url(challenge, format: :json)
end
