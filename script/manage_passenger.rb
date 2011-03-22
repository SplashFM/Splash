#!/usr/bin/env ruby

# based on https://gist.github.com/851520
# Passenger management script
# By James Smith http://loopj.com
# Based heavily on a similar script by Jon Bettcher
#
# Check memory usage of all passenger child process and kill if grows
# too large.
#
# Also kill off long running passengers to prevent memory leak issues.
#

# Path to the passenger-status and passenger-memory-status binaries
PASSENGER_STATUS = "/usr/bin/passenger-status 2>/dev/null"
PASSENGER_MEMORY_STATS = "/usr/bin/passenger-memory-stats 2>/dev/null"

# Recycle processes after this many requests
MAX_REQUEST_COUNT = 100000

# Hangup processes which use more than this much memory (in mb)
MAX_MEMORY = 300

# Email details on failure
TO_EMAIL = "ops@mojotech.com"
FROM_EMAIL = "noreply@mojotech.com"

class PassengerStatsCollection < Hash
  def expired
    self.map { |k,v| v[:processed] && v[:processed] >= MAX_REQUEST_COUNT ? k : nil }.compact
  end

  def over_memory
    self.map { |k,v| v[:resident] && v[:resident] >= MAX_MEMORY ? k : nil }.compact
  end

  def bad
    (expired + over_memory).uniq
  end

  def any_bad?
    !over_memory.empty? || !expired.empty?
  end
end

# Turns these into seconds:
# 0h 5m
# 3d 5h 3m
# 3m 5s
def parse_uptime(time)
  sec = 0
  time.strip.split(/\s+/).each do |part|
    unit = part[0..-2].to_i
    case part[-1..-1]
    when 'm' :
      unit *= 60
    when 'h' :
      unit *= 3600
    when 'd' :
      unit *= (24*3600)
    end
    sec += unit
  end
  sec
end

def get_status
  pids = PassengerStatsCollection.new

  `#{PASSENGER_STATUS}`.each_line do |line|
    if line =~ /^[ \*]*PID/ then
      parts = line.strip.split(/\s+/)
      pids[parts[1].to_i] = {
        :sessions => parts[3],
        :processed => parts[5].to_i,
        :uptime => parse_uptime(line.match(/Uptime:.*$/).to_s[7..-1])
      }
    end
  end

  `#{PASSENGER_MEMORY_STATS}`.each_line do |line|
    if line =~ /\d+ .*(Rails|Rails)/i then
      parts = line.strip.split(/\s+/)
      pid = parts[0].to_i
      pids[pid] = {} if pids[pid].nil?
      pids[pid].merge!({
        :virtual => parts[1].to_f,
        :resident => parts[3].to_f
      })
    end
  end

  pids
end

# doesn't really email.  intended for use in crontab
def email_on_failure(reason, e)
  #  `echo "#{reason}\n\nException trace:\n#{e.inspect}" | mail #{TO_EMAIL} -F #{FROM_EMAIL} -s "Passenger Management Exception"`
  puts "Passenger Management Exception"
  puts reason
  puts "Exception Trace:\n#{e.inspect}"
end

def main
  status = get_status

  # Nothing to do
  unless status.any_bad?
    # puts "All passenger processes running within operating parameters"
    return
  end

  puts "Passenger Status:"
  status.each do |k, v|
    puts "#{k}: #{v.inspect}"
  end

  # Tell all over memory instances to abort
  over_memory = status.over_memory
  over_memory.each do |pid|
    puts "sending -ABRT to #{pid}"
    Process.kill(:ABRT, pid)
  end

  # Tell all expired instances to shut down gracefully
  expired = status.expired
  (expired - over_memory).each do |pid|
    puts "sending -USR1 to #{pid}"
    Process.kill(:USR1, pid)
  end

  # Give them a chance to die gracefully
  sleep 30

  # Find and kill any pids which are still bad
  (status.bad & get_status.bad).each do |pid|
    puts "killing -9 #{pid}"
    begin
      Process.kill(:KILL, pid)
    rescue
      email_on_failure("Error killing process #{pid}", e)
    end
  end
rescue Exception => e
  email_on_failure("Error in main", e)
end

main
