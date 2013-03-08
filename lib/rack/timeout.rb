require RUBY_VERSION < '1.9' && RUBY_PLATFORM != 'java' ? 'system_timer' : 'timeout'
Timeout ||= SystemTimer

module Rack
  class Timeout
    @timeout = 15
    class << self
      attr_accessor :timeout
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      t, path = self.class.timeout, env['ORIGINAL_FULLPATH']
      begin
        log "about to start handling request for '#{path}' with a timeout of #{t} seconds."
        retval = ::Timeout.timeout(self.class.timeout, ::Timeout::Error) { @app.call(env) }
      rescue ::Timeout::Error
        log "request for '#{path}' aborted after a timeout of #{t} seconds."
        raise
      end
      log "request for '#{path}' completed in under #{t} seconds."
      retval
    end

    def log(s)
      $stderr.puts "rack-timeout: #{s}"
    end

  end
end
