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
    @device_story_comment = @device_story.device_story_comments.build(device_story_comment_params)
    return if @device_story_comment.spam?

    respond_to do |format|
      if @device_story_comment.save
        format.js { render inline: 'location.reload();' }
      else
        format.json { render json: @device_story_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @device_story_comment.update(device_story_comment_params)
        format.html { redirect_to device_story_path(@device_story), notice: 'device_story_comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @device_story_comment }
      else
        format.html { render :edit }
        format.json { render json: @device_story_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @device_story_comment.destroy
    redirect_to device_story_path(@device_story)
  end

  private

  def set_device_story_comment
    @device_story_comment = @device_story.device_story_comments.find(params[:id])
  end

  def device_story_comment_params
    params.inspect
    params.require(:device_story_comment).permit(:content, :device_story_id, :user_id)
  end

  def set_device_story
    @device_story = DeviceStory.find(params[:device_story_id])
  end
end
