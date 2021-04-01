# frozen_string_literal: true

class BgeigieLogDecorator < Draper::Decorator
  CPM_KML_ICON_COLOR = {
    0...35 => 'white',
    35...70 => 'midgreen',
    70...105 => 'green',
    105...175 => 'lightGreen',
    175...280 => 'yellow',
    280...350 => 'orange',
    350...420 => 'darkOrange',
    420...680 => 'red',
    680...1050 => 'darkRed'
  }.freeze

  DEFAULT_ICON_COLOR = 'grey'

  def usv
    format('%.3f uSv/h', object.usv)
  end

  def cpm
    object.cpm.to_s
  end

  def captured_at
    object.captured_at.strftime('%Y/%m/%d %H:%M:%S')
  end

  def icon_color
    CPM_KML_ICON_COLOR.each do |range, color|
      return color if range.include?(object.cpm)
    end
    DEFAULT_ICON_COLOR
  end

  def coordinates
    format('%.11f,%.11f', object.longitude, object.latitude)
  end
end
