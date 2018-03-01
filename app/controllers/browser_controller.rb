class BrowserController < ApplicationController
  include ActionController::Live

  def index
    #SSE expects the 'text/event-stream' content type
    response.headers['Content-Type'] = 'text/event-stream'

    sse = SSE.new(response.stream)

    begin

      directories = [
        File.join(Rails.root, 'app', 'assets'),
        File.join(Rails.root, 'app', 'views'),
      ]
      listener = Listen.to(File.join(Rails.root, 'app', 'assets')) do |modified, added, removed|
        sse.write({ :modified => modified, :added => added, :removed => removed }, :event => 'refresh')
      end

      listener.start
      sleep

    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end
end
