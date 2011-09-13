#!/usr/bin/ruby

require "right_aws"
require "yaml"
require "optparse"

options = {}

parser = OptionParser.new do |opts|

  opts.banner = "run.rb [options] image-id"

  options[:spot] = false

  opts.on '-s', 'runs spot instance' do 
    options[:spot] = true
  end

  options[:type] = "m1.small"

  opts.on '-t', '--type TYPE', 'instance type' do |type|
    options[:type] = type
  end

  options[:key] = nil

  opts.on '-k', '--key KEY', 'security key name' do |key|
    options[:key] = key
  end

  opts.on '-h', '--help' do
    puts opts
    exit
  end

end

parser.parse!
image_id = ARGV[0]

path = File.join File.dirname( __FILE__ )

require 'logger'

`[ ! -x ./log ] && mkdir ./log`
logger = Logger.new File.join(path,"log","log.txt"), 'daily' 
logger.level = Logger::INFO

cfg = YAML.load( File.read( File.join path, "config.yml" ))  

ec2 = RightAws::Ec2.new cfg["access_key_id"], cfg["secret_access_key"], :logger => logger   

if options[:spot]

  spot = ec2.request_spot_instances({

    :image_id => image_id, 
    :spot_price => 1, 
    :instance_type => options[:type],
    :key_name => options[:key]

  })

else 

  ec2.launch_instances( image_id, 
  
    :key_name => options[:key],
    :instance_type => options[:type] 

  )

end

