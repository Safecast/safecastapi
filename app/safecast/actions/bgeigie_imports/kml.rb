# frozen_string_literal: true

module Actions
  module BgeigieImports
    class Kml
      def initialize(bgeigie_logs)
        @bgeigie_logs = bgeigie_logs
      end

      def execute(context, filename = nil)
        context.send_data(kml, send_opts(filename))
      end

      private

      TEMPLATE_FILE =
        'app/views/bgeigie_imports/bgeigie_logs.kml.erb'

      def send_opts(filename)
        opts = { type: Mime::Type.lookup("kml").to_s }
        opts = opts.merge(filename: filename) if filename
        opts
      end

      def kml
        erb.result(binding)
      end

      def erb
        @erb ||= ERB.new(Rails.root.join(TEMPLATE_FILE).read, nil, '-')
      end
    end
  end
end
