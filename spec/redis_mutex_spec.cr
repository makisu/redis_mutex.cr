require "./spec_helper"
require "../src/redis_mutex"

class CustomException < Exception
end

describe RedisMutex do
  it "works with Redis" do
    50.times do
      start_time = Time.utc
      channel = Channel(Int32).new

      spawn do
        RedisMutex::Lock.new("MY_KEY", redis: Redis::Client.from_env("REDIS_URL")).run do
          channel.send(1)
        end
      end

      sleep 0.1

      spawn do
        RedisMutex.run("MY_KEY", redis: Redis::Client.from_env("REDIS_URL")) do
          channel.send(2)
        end
      end

      values = [] of Int32
      2.times { values << channel.receive }

      values.should eq([1, 2])
    end
  end

  it "works with Redis::PooledClient" do
    50.times do
      max_locking_time = 2.seconds
      pooled_client = Redis::Client.new(URI.parse("#{ENV["REDIS_URL"]}/0"))
      start_time = Time.utc
      channel = Channel(Int32).new

      spawn do
        RedisMutex::Lock.new("MY_KEY", max_locking_time: max_locking_time,
          redis: pooled_client).run do
          channel.send(1)
        end
      end

      sleep 0.1

      spawn do
        RedisMutex.run("MY_KEY", max_locking_time: max_locking_time, redis: pooled_client) do
          channel.send(2)
        end
      end

      values = [] of Int32
      2.times { values << channel.receive }

      values.should eq([1, 2])
    end
  end

  it "clears token on exception" do
    redis = Redis::Client.from_env("REDIS_URL")
    redis.get("MY_KEY").should eq nil
    expect_raises(CustomException) do
      begin
        RedisMutex::Lock.new("MY_KEY", redis: redis).run { raise CustomException.new }
      ensure
        redis.get("MY_KEY").should eq nil
      end
    end
  end
end
