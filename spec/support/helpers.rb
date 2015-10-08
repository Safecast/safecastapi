module Helpers
  def create_air_v0_station
    air_station = Station.new(id: 1)
    air_unit = air_station.device_units.build(id: 1)
    air_group = air_unit.device_groups.build(id: 1)

    co_2 = {manufacturer: "Alphasense", model: "CO2-D1"}
    air_group.devices.build(co_2.merge(id: 1, unit: "volts", sensor: "working electrode voltage"))
    air_group.devices.build(co_2.merge(id: 2, unit: "volts", sensor: "auxiliary electrode voltage"))
    air_group.devices.build(co_2.merge(id: 3, unit: "ppb",   sensor: "gas concentration"))
    air_group.devices.build(co_2.merge(id: 4, unit: "ppb",   sensor: "gas concentration, lowpass filtered"))
    air_station.save!
    air_station
  end

  def sign_up(email = "paul@rslw.com", name = "Paul Campbell", password = "mynewpassword")
    visit("/users/sign_up")
    fill_in("Email", :with => email)
    fill_in("Name", :with => name)
    fill_in("Password", :with => password)
    fill_in("Password confirmation", :with => password)
    click_button("Register")
  end
  
  def sign_in(user)
    visit("/users/sign_in")
    fill_in("Email", :with => user.email)
    fill_in("Password", :with => user.password)
    click_button("Sign in")
    user
  end
  
  def api_get(*args)
    get(*args)
    ActiveSupport::JSON.decode(response.body)
  end

  def api_post(*args)
    post(*args)
    ActiveSupport::JSON.decode(response.body)
  end
end
