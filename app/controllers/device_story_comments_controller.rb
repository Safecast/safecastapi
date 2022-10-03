# frozen_string_literal: true

class DeviceStoryCommentsController < ApplicationController
  before_action :set_device_story
  before_action :set_device_story_comment, only: %i(show edit update destroy)

  def index
    @device_story_comments = @device_story.device_story_comments
  end

  def new
    @device_story_comment = @device_story.device_story_comments.build
  end

  def create
    return unless user_signed_in?

    @device_story_comment = @device_story.device_story_comments.build(device_story_comment_params)
    @device_story_comment.user_id = current_user.id
    responder_create
  end

  def update
    return unless user_signed_in? && ((@device_story_comment.user_id == current_user.id) || moderator?(current_user))

    responder_update
  end

  def responder_create # rubocop:disable Metrics/AbcSize
    respond_to do |format|
      if @device_story_comment.save && !@device_story_comment.spam?
        format.html { redirect_to device_story_path(@device_story), notice: t('.success') }
      else
        purge_attached_image_with_error(@device_story_comment)
        flash[:error] = @device_story_comment.errors.full_messages.join(' ')
        format.html { redirect_to device_story_path(@device_story) }
      end
    end
  end

  def responder_update
    respond_to do |format|
      if @device_story_comment.update(device_story_comment_params)
        format.html { redirect_to device_story_path(@device_story), notice: t('.success') }
        format.json { render :show, status: :ok, location: @device_story_comment }
      else
        purge_attached_image_with_error(@device_story_comment)
        format.html { render :edit }
        format.json { render json: @device_story_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    return unless user_signed_in? && ((@device_story_comment.user_id == current_user.id) || moderator?(current_user))

    @device_story_comment.image.purge if @device_story_comment.image.attached?
    @device_story_comment.destroy
    respond_to do |format|
      format.html { redirect_to device_story_path(@device_story), notice: t('.success') }
    end
  end

  private

  def purge_attached_image_with_error(comment)
    comment.image.purge if comment.invalid? && comment.errors.key?(:image) && comment.image.attached?
  end

  def set_device_story_comment
    @device_story_comment = @device_story.device_story_comments.find(params[:id])
  end

  def device_story_comment_params
    params.require(:device_story_comment).permit(:content, :device_story_id, :image, :user_id)
  end

  def set_device_story
    @device_story = DeviceStory.find(params[:device_story_id])
  end
end
