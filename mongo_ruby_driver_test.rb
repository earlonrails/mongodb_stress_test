require 'rubygems'
require 'benchmark'
require 'mongo'
require 'record'
require 'java'
require 'yaml'

@count = java.util.concurrent.atomic.AtomicInteger.new

java_import java.util.concurrent.Executors
java_import java.util.concurrent.TimeUnit

@executor = Executors.new_fixed_thread_pool(10)

include Mongo
include Record

File.open('database.yml', 'r') do |f|
  @database_yml = YAML.load(f)
  @settings = @database_yml["test"]
end

replica_set = @settings["host"].split(",")
host = (@settings["host"] || 'localhost')
port = (@settings["port"] || MongoClient::DEFAULT_PORT)
number_of_records = @settings["records"]


if replica_set.size > 1
  puts "Connecting to #{replica_set}"
  @mongo_client = MongoReplicaSetClient.new(replica_set)
else
  puts "Connecting to #{host}:#{port}"
  @mongo_client = MongoClient.new(host, port)
end

@admin      = @mongo_client['admin']
@db         = @mongo_client['stress']
@users      = @db['users']
@users.remove

@admin.profiling_level = @settings["profiling_level"].to_sym

@user_ids = []

Benchmark.bm do |bench_me|
  # inserts
  bench_me.report do
    number_of_records.times do
      @user_ids << @users.insert(random_personal_info)
    end
  end

  # updates
  bench_me.report do
    @user_ids.each do |id|
      @users.update({:_id => id }, random_personal_info)
    end
  end

  # deletes
  bench_me.report do
    @user_ids.each do |id|
      @users.remove({:_id => id })
    end
  end

  @user_ids = []
  # inserts while creating indexes
  bench_me.report do
    @executor.submit do
      number_of_records.times do
        @user.create_index(random_field)
      end
    end
    @executor.submit do
      number_of_records.times do
        @user_ids << @users.insert(random_personal_info)
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end

  # updates while creating indexes
  bench_me.report do
    @executor.submit do
      @user_ids.each do
        @user.create_index(random_field)
      end
    end
    @executor.submit do
      @user_ids.each do |id|
        @users.update({:_id => id }, random_personal_info)
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end

  # deletes while creating indexes
  bench_me.report do
    @executor.submit do
      @user_ids.each do
        @user.create_index(random_field)
      end
    end
    @executor.submit do
      @user_ids.each do |id|
        @users.remove({:_id => id })
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end

  @user_ids = []
  # inserts while dropping indexes
  bench_me.report do
    @executor.submit do
      number_of_records.times do
        @user.drop_index(random_field)
      end
    end
    @executor.submit do
      number_of_records.times do
        @user_ids << @users.insert(random_personal_info)
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end

  # updates while dropping indexes
  bench_me.report do
    @executor.submit do
      @user_ids.each do |id|
        @user.drop_index(random_field)
      end
    end
    @executor.submit do
      @user_ids.each do |id|
        @users.update({:_id => id }, random_personal_info)
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end

  # deletes while dropping indexes
  bench_me.report do
    @executor.submit do
      @user_ids.each do
        @user.drop_index(random_field)
      end
    end
    @executor.submit do
      @user_ids.each do |id|
        @users.remove({:_id => id })
      end
    end
    @executor.await_termination(10, TimeUnit::SECONDS)
  end
end

@executor.shutdown_now

@admin.profiling_level = :off

puts @admin.profiling_info unless @settings["profiling_level"] == "off"

