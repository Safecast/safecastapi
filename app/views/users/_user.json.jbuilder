json.id user.id
json.name user.name
json.measurements_count user.measurements_count
if current_user == user
  json.authentication_token user.authentication_token
end