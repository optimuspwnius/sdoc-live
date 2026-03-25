require "puma/plugin"

# Puma plugin that runs SDoc Live in a forked child process during development.
#
# Activated by adding <tt>plugin :sdoc_live</tt> to +config/puma.rb+.
#
# After Puma boots, it forks a child that calls
# +SdocLive::Generator#build_watch+ (initial build + file watching).
# Bidirectional lifecycle monitoring ensures both processes stay in sync:
#
# - If Puma dies, the SDoc child exits.
# - If the SDoc child dies, Puma is stopped.
Puma::Plugin.create do

  attr_reader :puma_pid, :sdoc_pid, :log_writer

  # Called by Puma during plugin registration. Sets up the forked SDoc
  # process after boot and registers a shutdown hook.
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

  # Sends INT to the SDoc child process and waits for it to exit.
  def stop_sdoc
    Process.waitpid(sdoc_pid, Process::WNOHANG)
    log "Stopping SdocLive..."
    Process.kill(:INT, sdoc_pid) if sdoc_pid
    Process.wait(sdoc_pid)
  rescue Errno::ECHILD, Errno::ESRCH
  end

  # Monitors the Puma parent process from the SDoc child.
  def monitor_puma
    monitor(:puma_dead?, "Detected Puma has gone away, stopping SdocLive...")
  end

  # Monitors the SDoc child process from the Puma parent.
  def monitor_sdoc
    monitor(:sdoc_dead?, "Detected SdocLive has gone away, stopping Puma...")
  end

  # Polls +process_dead+ every 2 seconds. When the monitored process is
  # detected as dead, logs the message and sends INT to the current process.
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

  # Returns +true+ if the SDoc child process has exited.
  def sdoc_dead?
    Process.waitpid(sdoc_pid, Process::WNOHANG)
    false
  rescue Errno::ECHILD, Errno::ESRCH
    true
  end

  # Returns +true+ if the Puma parent process has been replaced (i.e. died).
  def puma_dead?
    Process.ppid != puma_pid
  end

  def log(...)
    log_writer.log(...)
  end

end
