json.extract! audience, :id, :name, :description, :slack_channel, :created_at, :updated_at
json.url audience_url(audience, format: :json)
