# frozen_string_literal: true

class CronsController < ApplicationController
  SCRIPT_PATH = Rails.root.join('cron')
  CRON_DEFINITIONS = Rails.root.join('cron.yaml')

  def configured_job_names
    YAML.load_file(CRON_DEFINITIONS)['cron'].map { |d| d['name'] }
  end

  def runnable?
    request.local? && configured_job_names.include?(script_name)
  end

  def script_name
    request.headers['X-Aws-Sqsd-Taskname']
  end

  def create
    return head(:forbidden) unless runnable?
    system('./' + script_name, chdir: SCRIPT_PATH)
    render(plain: "Unable to run #{script_name}", status: 500) unless $CHILD_STATUS.success?
  end
end
