require "redis"
require "./time_parser"

class RedisMutex::Lock
  property key

  def initialize(@key : String, @redis : Redis::Client, @max_locking_time : Time::Span = RedisMutex::MAX_LOCKING_TIME)
  end

  def create_lock_threshold
    (Time.utc + @max_locking_time).to_unix
  end

  def try_to_lock
    while @redis.setnx(key, create_lock_threshold.to_s) == 0
      stored_value = TimeParser.parse(@redis.get(key))
      if Time.utc - stored_value >= @max_locking_time
        new_lock_threshold = create_lock_threshold
        old_value = @redis.getset(key, new_lock_threshold.to_s)
        old_time = TimeParser.parse(old_value)

        if Time.utc - old_time >= @max_locking_time
          break
        end

        sleep 0.1
      end
    end

    return true
  end

  def unlock
    @redis.del(key)
  end

  def run(&block)
    try_to_lock
    block.call
  ensure
    unlock
  end
end
