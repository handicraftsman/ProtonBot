# Log - for colored logging.
# @!attribute [rw] levels
#   @return [Hash<String>] Colorscheme
# @!attribute [rw] logging
#   @return [Bool] If false, does not write messages.
class ProtonBot::Log
  attr_accessor :levels, :logging

  def initialize
    @pastel = Pastel.new

    @queue = Queue.new

    @fmt  = '[:date|:time] :name ▷ :lvl ▶ :text'
    @dfmt = '%d.%m.%Y'
    @tfmt = '%H:%M:%S'
    @levels = DEFAULT_SCHEME

    @logging = true

    @stop = false

    lloop
  end

  # Use it to get rid of appending name on each log-method-call
  # @param name [String]
  # @return [LogWrapper] wrapper
  # @see ProtonBot::LogWrapper
  def wrap(name)
    ProtonBot::LogWrapper.new(self, name)
  end

  # @!group Logging
  # @param msg [String]
  # @param nam [String] Name
  def info(msg, nam = 'log')
    dat = gsub(msg.to_s, :info, nam)
    @queue << dat
    @pastel.strip(dat)
  end

  # @param msg [String]
  # @param nam [String] Name
  def debug(msg, nam = 'log')
    dat = gsub(msg.to_s, :debug, nam)
    @queue << dat
    @pastel.strip(dat)
  end

  # @param msg [String]
  # @param nam [String] Name
  def warn(msg, nam = 'log')
    dat = gsub(msg.to_s, :warning, nam)
    @queue << dat
    @pastel.strip(dat)
  end

  # @param msg [String]
  # @param nam [String] Name
  def error(msg, nam = 'log')
    dat = gsub(msg.to_s, :error, nam)
    @queue << dat
    @pastel.strip(dat)
  end

  # @param msg [String]
  # @param code [Integer]
  # @param nam [String] Name
  def crash(msg, code = 1, nam = 'log')
    dat = gsub(msg.to_s, :crash, nam)
    @queue << dat
    @pastel.strip(dat)
    exit code
  end
  # @!endgroup

  # @return [String] Output
  def inspect
    %(<#ProtonBot::Log:#{object_id.to_s(16)} @logging=#{@logging}>)
  end

  # Stops log thread
  def stop
    @stop = true
    @thr.join
  end

  private

  # Formats message
  # @param msg [String]
  # @param sname [Symbol] Color-Scheme name
  # @param nam [String] Log-Name
  def gsub(msg, sname, nam)
    dt = DateTime.now

    date = dt.strftime(@dfmt)
    time = dt.strftime(@tfmt)

    dates = @pastel.decorate(date, *@levels[sname][:fmt][:datetime])
    times = @pastel.decorate(time, *@levels[sname][:fmt][:datetime])

    name = @pastel.decorate(nam, *@levels[sname][:fmt][:name])

    lvl = @pastel.decorate(*@levels[sname][:chars],
                           *@levels[sname][:fmt][:lvl])

    @fmt
      .gsub(':date', dates)
      .gsub(':time', times)
      .gsub(':name', name)
      .gsub(':lvl',  lvl)
      .gsub(':text', msg)
      .gsub('▷', @pastel.decorate('▷', *@levels[sname][:fmt][:arrows]))
      .gsub('▶', @pastel.decorate('▶', *@levels[sname][:fmt][:arrows]))
  end

  # Log-loop - reads messages from queue and writes them to STDOUT
  def lloop
    @thr = Thread.new do
      loop do
        break if @stop
        d = begin
              @queue.pop
            rescue
              nil
            end
        print("#{d}\n") if @logging && d
      end
    end
  end

  # Default colorcheme
  DEFAULT_SCHEME = {
    info: {
      chars: 'I',
      fmt: {
        datetime: [:bright_cyan],
        name:     [:cyan],
        lvl:      [:cyan],
        arrows:   [:bright_cyan]
      }
    },
    debug: {
      chars: 'D',
      fmt: {
        datetime: [:bright_green],
        name:     [:green],
        lvl:      [:green],
        arrows:   [:bright_green]
      }
    },
    warning: {
      chars: 'W',
      fmt: {
        datetime: [:bright_yellow],
        name:     [:yellow],
        lvl:      [:yellow],
        arrows:   [:bright_yellow]
      }
    },
    error: {
      chars: 'E',
      fmt: {
        datetime: [:bright_red],
        name:     [:red],
        lvl:      [:red],
        arrows:   [:bright_red]
      }
    },
    crash: {
      chars: 'C',
      fmt: {
        datetime: [:bright_magenta],
        name:     [:magenta],
        lvl:      [:magenta],
        arrows:   [:bright_magenta]
      }
    }
  }.freeze
end
