# frozen_string_literal: true

class CronsController < ApplicationController
  SCRIPT_PATH = Rails.root.join('cron')
  CRON_DEFINITIONS = Rails.root.join('cron.yaml')

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

  private

  def runnable?
    request.local? && configured_job_names.include?(taskname) && !running_same_job?
  end

  def configured_job_names
    YAML.load_file(CRON_DEFINITIONS)['cron'].pluck('name')
  end

  def taskname
    @taskname ||= request.headers['X-Aws-Sqsd-Taskname']
  end

  def running_same_job?
    res = false
    IO.popen('ps ax') do |io|
      io.each_line do |line|
        if line.chomp.split.last.end_with?(taskname)
          res = true
          break
        end
      end
    end
    res
  end
end
