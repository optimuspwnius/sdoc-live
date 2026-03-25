require "puma/plugin"

Puma::Plugin.create do

  attr_reader :puma_pid, :sdoc_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $PROCESS_ID

    launcher.events.after_booted do

      @sdoc_pid = fork do

        Thread.new { monitor_puma }

        begin
          trap("INT") { exit 0 }
          trap("TERM") { exit 0 }

          require "sdoc_live"
          generator = SdocLive::Generator.new
          generator.build_watch
        rescue => e
          @log_writer.log "SdocLive error: #{ e.message }"
          @log_writer.log e.backtrace.join("\n")
          exit 1
        end

      end

      in_background do

        monitor_sdoc

      end

    end

    launcher.events.after_stopped { stop_sdoc }
  end

  private

  def stop_sdoc
    Process.waitpid(sdoc_pid, Process::WNOHANG)
    log "Stopping SdocLive..."
    Process.kill(:INT, sdoc_pid) if sdoc_pid
    Process.wait(sdoc_pid)
  rescue Errno::ECHILD, Errno::ESRCH
  end

  def monitor_puma
    monitor(:puma_dead?, "Detected Puma has gone away, stopping SdocLive...")
  end

  def monitor_sdoc
    monitor(:sdoc_dead?, "Detected SdocLive has gone away, stopping Puma...")
  end

  def monitor(process_dead, message)
    loop do

      if send(process_dead)
        log message
        Process.kill(:INT, $PROCESS_ID)
        break
      end
      sleep 2

    end
  end

  def sdoc_dead?
    Process.waitpid(sdoc_pid, Process::WNOHANG)
    false
  rescue Errno::ECHILD, Errno::ESRCH
    true
  end

  def puma_dead?
    Process.ppid != puma_pid
  end

  def log(...)
    log_writer.log(...)
  end

end
