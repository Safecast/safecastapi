class BgeigieImportsController < ApplicationController

  respond_to :html, :json

  before_filter :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :require_moderator, :only => [:approve, :fixdrive]

  has_scope :by_status
  has_scope :by_user_id
  has_scope :order
  has_scope :uploaded_after
  has_scope :uploaded_before
  has_scope :q do |controller, scope, value|
    scope.filter(value)
  end
  has_scope :approved do |controller, scope, value|
    if value == 'yes'
      scope.where(:approved => true)
    elsif value == 'no'
      scope.where(:approved => false)
    else
      scope
    end
  end
  has_scope :subtype do |controller, scope, value|
    scope.by_subtype(value.split(',').map(&:strip).reject(&:blank?))
  end

  def new
    @bgeigie_import = BgeigieImport.new
  end

  def approve
    @bgeigie_import = BgeigieImport.find(params[:id])
    @bgeigie_import.approve!
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
    @bgeigie_import.update_column(:status, 'submitted')
    Notifications.import_awaiting_approval(@bgeigie_import).deliver
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
    render(:partial => params[:partial]) and return if params[:partial].present?
    respond_with @bgeigie_import
  end

  def create
    @bgeigie_import = BgeigieImport.new(params[:bgeigie_import])
    @bgeigie_import.user = current_user
    if @bgeigie_import.save
      @bgeigie_import.process_in_background
    end
    respond_with @bgeigie_import
  end

  def update
    @bgeigie_import = scope.find(params[:id])
    @bgeigie_import.update_attributes(params[:bgeigie_import])
    respond_with @bgeigie_import
  end

  def destroy
    @bgeigie_import = BgeigieImport.where(:id => params[:id]).first
    @bgeigie_import.destroy if @bgeigie_import.present?
    redirect_to :bgeigie_imports
  end

private
  def scope
    if current_user.moderator?
      BgeigieImport
    else
      current_user.bgeigie_imports
    end
  end
end
