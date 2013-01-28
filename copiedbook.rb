#!/usr/bin/env ruby

# Standard requires
require 'logger'
require 'date'
require 'erb'
require 'fileutils'

# Configuration
# Config variables
debug = false # Set to true to get some debug information
current_path = File.dirname(__FILE__)
$log_limit = 10 # How many log files to store on log path
$log_path = current_path + "/log"
log_file = $log_path + "/main-" + 
  DateTime.now.strftime("%Y%m%d-%H%M%S") + ".log"
log_file = Logger.new(log_file)
CONSTANT = "..."
variable = "..."


# Our requires
Dir.glob(current_path + '/lib/*.rb') {|file| require file}

class MyClass
  include Helpers

  def initialize(log_file)
    @log_file = log_file
    #log_this("\e[1m# Description to show on screen...\e[0m\n")
    
    
    # Arguments from command line
    @fanpage_id = ARGV[0]
    @token = ARGV[1]
    @output_file = ARGV[2]
  end

  def info
    puts("\e[1mName:\e[0m Facebook Dumper")
    puts("\e[1mDescription:\e[0m This scripts dumps JSON from a Facebook fanpage")
    puts("\e[1mCreated at:\e[0m 12/12/12")
  end

  def help
    puts "Not enough arguments. Example: \nruby copiedbook.rb 270335753072803 AAACEdEose0cBAIGTvuh38rLhsDD4jJdJjApGjH8z6uUmZCMH0I0IptiQ3z9qbbzVNITJtLJ2ReL4ZBwJGZCAtHAdpMT1wYlY1Qu9A71rnwxf8RPG3QZA my_file.json"
  end

  def get_feed
    if @token.empty?
      puts "Introduce a new token"
      @token = gets.chomp
    end    
    @graph = Koala::Facebook::API.new(@token)
    begin
      feed = @graph.get_connections(@fanpage_id, "feed")
    rescue Exception => ex
      @token = ""
      puts "Facebook has returned an error: #{ex.message}"
      feed = get_feed
    end
  end

  def get_nextpage(feed,parameters = nil)
    begin
      parameters = feed.next_page_params if parameters == nil 
      return nil if parameters == nil
      feed = @graph.get_page(parameters)
    rescue Exception => ex
      puts "Facebook has returned an error: #{ex.message}"
      @token = ""
      feed = get_feed
      get_nextpage(feed, parameters)
    end
  end

  def main
    puts(" ---- STARTING ----\n\n")
    
    # Connect to Facebook and get the feed with all posts
    require 'koala'
    @graph = Koala::Facebook::API.new(@token)
    output = []

    feed = get_feed

    counter = 1
    until feed == nil
      output += feed
      puts "We are in page #{counter} of the fanpage's feed"
      counter += 1
      feed = get_nextpage(feed)
    end
    
    
    # Iterate through the feed to get all comments
    output.each_with_index do |post, index|
      if post["comments"]["count"] > 0
        puts "  The post #{post["id"]} has #{post["comments"]["count"]} comments. We are going to retrieve them now."
        comments = []
        comment_feed = @graph.get_connections(post["id"], "comments")
        until comment_feed == nil
          comments += comment_feed
          comment_feed = comment_feed.next_page
        end
        post["comments"] = comments
        #puts "We have retrieved #{post["comments"].size} comments"
        output[index] = post
      end
    end

    # Write the file
    File.open(@output_file, 'w') {|f| f.write(output.to_json) }

    puts("\n\n ---- ENDING ----\n")
    clean_the_log 
    exit(0)
  end

  def run_it
    if ARGV.size == 3
      ARGV.clear
      main
    else
      case ARGV[0]
        when "help"
          help
        when "info"
          info
        else
          help
      end
    end
  end

end

myclass = MyClass.new(log_file)
myclass.run_it
