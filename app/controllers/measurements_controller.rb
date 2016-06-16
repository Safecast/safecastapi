class MeasurementsController < ApplicationController

  before_filter :authenticate_user!, :only => [:new, :create, :update, :destroy]

  has_scope :captured_after
  has_scope :unit do |_controller, scope, value|
    scope.by_unit(value)
  end
  has_scope :captured_before
  has_scope :distance do |controller, scope, _value|
    scope.nearby_to(controller.params[:latitude], controller.params[:longitude], controller.params[:distance])
  end
  has_scope :order
  has_scope :original_id do |_controller, scope, value|
    scope.where("original_id = :value OR id = :value", :value => value)
  end
  has_scope :until

  has_scope :device_id do |_controller, scope, value|
    scope.where(:device_id => value)
  end
  has_scope :user_id do |_controller, scope, value|
    scope.where(:user_id => value)
  end
  has_scope :measurement_import_id do |_controller, scope, value|
    scope.where(:measurement_import_id => value)
  end
  has_scope :since
  has_scope :limit

  respond_to :html, :json, :csv

  def index
    # Don't delete these @filename and @streaming. They are for
    # csvbuilder.
    @filename = "measurements.csv"
    @streaming = true

    @measurements = apply_scopes(Measurement).includes(:measurement_import, :user)

    # In Kaminari page an per_page cannot be overriden
    if request.format != :csv
      @measurements = @measurements.page(params[:page]).per(params[:per_page])
    end

    respond_with @measurements
  end
  
  def show
    @measurement = Measurement.find(params[:id])
    respond_with @measurement
  end
  
  def new
    @last_measurement = current_user.measurements.last
    @measurement = if @last_measurement.present?
      @last_measurement.clone
    else
      Measurement.new(
        :location => "POINT(140.47335610000005 37.7607226)",
        :location_name => 'Fukushima City Office'
      )
                   end
    @measurement.captured_at = Time.now.strftime("%d %B %Y, %H:%M:%S")
  end

  def create
    @measurement = current_user.measurements.build(measurement_params)
    ActiveRecord::Base.transaction do
      @measurement.save!
      @measurement.update_attributes!(original_id: @measurement.id)
    end
    respond_with @measurement
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
    respond_with @measurement
  end

  def update
    @measurement = Measurement.find(params[:id])
    @new_measurement = @measurement.revise(measurement_params)

    # respond_with typically doesn't pass the resource for PUT, but since we're being non-destructive, our PUT actually returns a new resource
    # see: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5199-respond_with-returns-on-put-and-delete-verb#ticket-5199-14
    respond_with(@new_measurement) do |format|
      format.json { render :json => @new_measurement.to_json, :status => :accepted }
    end
  end

  def destroy
    @measurement = Measurement.find(params[:id])
    authorize! :delete, @measurement
    @measurement.destroy
    respond_with @measurement
  end

  def count
    @count = {}
    @count[:count] = Measurement.count
    respond_with @count
  end

private

  def measurement_params
    params.fetch(:measurement, {})
      .permit(*%i(value unit location location_name device_id height
                  surface :radiation latitude longitude captured_at
                  devicetype_id sensor_id channel_id station_id))
  end
end
