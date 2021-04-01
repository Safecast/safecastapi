# frozen_string_literal: true

json.id user.id
json.name user.name
json.measurements_count user.measurements_count
json.authentication_token user.authentication_token if current_user == user
