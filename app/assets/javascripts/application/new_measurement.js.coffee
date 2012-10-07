$ ->
  sensorSelector = $('select#measurement_sensor_id')
  deviceSelector = $('select#measurement_device_id')

  appendOptionsToSensors = (opt) ->
      sensorSelector.append("<option value=\"" + opt.id + "\">" + opt.name + "</option>")

  populateSensorsForDevice = (device_id) ->
    if window.devices_sensors and device_id
      sensors_array = window.devices_sensors[device_id]
      console.log 'sensors for this device: ' + sensors_array
      sensorSelector
        .find('option')
        .remove()
        .end()
        .attr('disabled', true)
      if sensors_array
        appendOptionsToSensors sensor for sensor in sensors_array
        sensorSelector.attr('disabled', false)

  populateSensorsForDevice deviceSelector.children('option:selected').val()

  deviceSelector.change (event) ->
    dev_id = ($ this).val()
    console.log dev_id
    populateSensorsForDevice dev_id



    

