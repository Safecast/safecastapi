# frozen_string_literal: true

class BgeigieImportsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include HasOrderScope

  respond_to :html, :json

  before_action :authenticate_user!, only: %i(new create edit update destroy)
  before_action :require_moderator, only: %i(approve fixdrive send_email resolve)

  has_scope :q do |_controller, scope, value|
    scope.filter(value)
  end

  has_scope :by_status
  has_scope :by_user_id
  has_scope :by_rejected
  has_scope :by_user_name
  has_scope :uploaded_after
  has_scope :uploaded_before
  has_scope :rejected_by

  STATUS_CONDITIONS = {
    'approved' => { approved: true },
    'rejected' => { rejected: true },
    'not_moderated' => { approved: false, rejected: false }
  }.freeze

  has_scope :status do |_controller, scope, value|
    condition = STATUS_CONDITIONS[value]
    condition.present? ? scope.where(condition) : scope
  end
  has_scope :subtype do |_controller, scope, value|
    scope.by_subtype(value.split(',').map(&:strip).reject(&:blank?))
  end

  def new
    @bgeigie_import = BgeigieImport.new
  end

  def approve
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.approve!(current_user.name)
    redirect_to @bgeigie_import
  end

  def reject
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.reject!(@bgeigie_import.user == current_user ? '<self>' : current_user.email)
    redirect_to @bgeigie_import
  end

  def send_email
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.send_email(params[:email_body])
    @bgeigie_import.uploader_contact_histories.create!(
      administrator: current_user, previous_status: @bgeigie_import.status
    )
    # use update_columns to avoid validations of presence of cities and credits
    @bgeigie_import.update_columns(status: :awaiting_response)
    redirect_to @bgeigie_import
  end

  def contact_moderator
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.contact_moderator(params[:email_body])
    redirect_to @bgeigie_import
  end

  def fixdrive
    @bgeigie_import = scope.find(params[:id])
    @bgeigie_import.fixdrive!
    redirect_to @bgeigie_import
  end

  def process_button
    @bgeigie_import = scope.find(params[:id])
    @bgeigie_import.process
    redirect_to @bgeigie_import
  end

  def submit
    @bgeigie_import = scope.find(params[:id])
    if @bgeigie_import.would_auto_approve
      @bgeigie_import.approve!('ZBot Auto Approving System')
    else
      @bgeigie_import.update_columns(status: 'submitted', rejected: false, rejected_by: nil)
      Notifications.import_awaiting_approval(@bgeigie_import).deliver_later
    end
    redirect_to @bgeigie_import
  end

  def edit
    @bgeigie_import = current_user.bgeigie_imports.find(params[:id])
  end

  def index
    @bgeigie_imports = apply_scopes(BgeigieImport).page(params[:page])
    respond_with @bgeigie_imports
  end

  def show
    @bgeigie_import = BgeigieImport.find(params[:id])
    render(partial: params[:partial]) && return if params[:partial].present?

    respond_with @bgeigie_import
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { head :not_found }
      format.json { head :not_found }
    end
  end

  def create
    @bgeigie_import = current_user.bgeigie_imports.build(bgeigie_import_params)
    ProcessBgeigieImportJob.perform_later(@bgeigie_import.id) if @bgeigie_import.save
    respond_with @bgeigie_import
  end

  def update
    @bgeigie_import = scope.find(params[:id])
    @bgeigie_import.update_column(:auto_apprv_no_high_cpm, true) if bgeigie_import_params[:subtype] == 'Cosmic'
    @bgeigie_import.update(bgeigie_import_params)
    @bgeigie_import.update_would_approve
    respond_with @bgeigie_import
  end

  def destroy
    bgeigie_import = scope.where(id: params[:id]).first

    return render plain: '404 Not Found', status: :not_found unless bgeigie_import
    return redirect_to :bgeigie_imports, alert: t('.cannot_delete_approved') if bgeigie_import.approved?

    bgeigie_import.destroy
    redirect_to :bgeigie_imports
  end

  def kml
    bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_logs = bgeigie_import.bgeigie_logs.map(&:decorate)

    send_data(
      render_to_string(template: 'bgeigie_imports/bgeigie_logs', formats: [:kml]),
      type: Mime[:kml],
      filename: "#{bgeigie_import.source.filename}.kml"
    )
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  IMAGE_FILES = %w(
    darkOrange.png
    darkRed.png
    green.png
    grey.png
    lightGreen.png
    midgreen.png
    orange.png
    red.png
    white.png
    yellow.png
  ).freeze

  def kmz
    bgeigie_import = BgeigieImport.find(params[:id])
    kos = create_kmz_output_stream(bgeigie_import)

    send_data(
      kos.string,
      type: Mime[:kmz],
      filename: "#{bgeigie_import.source.filename}.kmz"
    )
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def resolve
    @bgeigie_import = scope.find(params[:id])
    history = @bgeigie_import.uploader_contact_histories.last
    @bgeigie_import.update_columns(status: history.previous_status) if history
    redirect_to @bgeigie_import
  end

  private

  def scope
    if current_user.moderator?
      BgeigieImport
    else
      current_user.bgeigie_imports
    end
  end

  def bgeigie_import_params
    params.fetch(:bgeigie_import, {}).permit!
  end

  def create_kmz_output_stream(bgeigie_import)
    @bgeigie_logs = bgeigie_import.bgeigie_logs.map(&:decorate)
    Zip::OutputStream.write_buffer(StringIO.new) do |out|
      out.put_next_entry("#{bgeigie_import.source.filename}.kml")
      out.write(render_to_string(template: 'bgeigie_imports/bgeigie_logs', formats: [:kmz]))
      IMAGE_FILES.each do |image_file|
        out.put_next_entry("images/#{image_file}")
        out.write(Rails.root.join("public/kml/#{image_file}").binread)
      end
    end
  end
end
