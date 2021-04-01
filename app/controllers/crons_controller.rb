# frozen_string_literal: true

class CronsController < ApplicationController
  SCRIPT_PATH = Rails.root.join('cron')
  CRON_DEFINITIONS = Rails.root.join('cron.yaml')

  def configured_job_names
    YAML.load_file(CRON_DEFINITIONS)['cron'].map { |d| d['name'] }
  end

  def runnable?
    request.local? && configured_job_names.include?(taskname)
  end

  def taskname
    request.headers['X-Aws-Sqsd-Taskname']
  end

  def create
    return head(:forbidden) unless runnable?

    logger.info "Starting cron task: #{taskname}"
    system("./#{taskname}", chdir: SCRIPT_PATH)
    if $CHILD_STATUS.success?
      render json: { status: :ok, taskname: taskname }
    else
      render(plain: "Unable to run #{taskname}", status: 500)
    end
  end
end
