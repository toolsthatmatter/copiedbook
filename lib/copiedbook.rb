require "copiedbook/version"
require "copiedbook/helpers"
require "copiedbook/fb_calls"
require "time"

module Copiedbook
  class CopyMachine
    include Helpers
    include FBCalls

    def initialize(log_file)
      @log_file = log_file
      #log_this("\e[1m# Description to show on screen...\e[0m\n")


      # Arguments from command line
      @fanpage_id = ARGV[0]
      @token = ARGV[1]
      @output_file = ARGV[2]

      if(ARGV[3])
        @start_date = Time.parse(ARGV[3])
      else
        @start_date = Time.parse("1970-01-01 0:00:00")
      end

      if(ARGV[4])
        @end_date = Time.parse(ARGV[4])
      else
        @end_date = Time.now
      end



    end

    def info
      puts("\e[1mName:\e[0m Facebook Dumper")
      puts("\e[1mDescription:\e[0m This scripts dumps JSON from a Facebook fanpage")
      puts("\e[1mCreated at:\e[0m 12/12/12")
    end

    def help
      puts "Not enough arguments.\n\n"
      puts "Usage: copiedbook facebook-page-id access-token output-file [start-date] [end-date]\n\n"

      puts "Examples: \n"
      puts " 1) copiedbook 270335753072803 AAACEdEose0cBAIGTvuh38rLhsD...A71rnwxf8RPG3QZA my_file.json"
      puts " 2) copiedbook 270335753072803 AAACEdEose0cBAIGTvuh38rLhsD...A71rnwxf8RPG3QZA my_file.json \"2014-01-01 0:00:00\" \"2014-06-06 23:59:59\"\n\n"
    end

    def main
      puts("\n ---- STARTING COPIEDBOOK, GETTING POSTS ----\n\n")

      puts("\n Searching for all Posts betweet #{@start_date} and #{@end_date}\n\n")

      # Connect to Facebook and get the feed with all posts
      require 'koala'
      @graph = Koala::Facebook::API.new(@token)
      @output = []
      feed = get_feed

      # Iterate through the feed to get all posts
      counter = 1
      until feed == nil
        puts "  We are in page #{counter} of the fanpage's feed"
        counter += 1

        should_end = false;
        cleaned_feed = []
        feed.each do |item|
          item_date = Time.parse(item["created_time"])

          if(@start_date && item_date < @start_date)
            should_end = true
            break
          end

          if(@end_date && item_date > @end_date)
            next
          end

          cleaned_feed.push(item)
        end

        puts "    Posts matching query: #{cleaned_feed.length}"

        @output += cleaned_feed

        break if should_end

        feed = get_next_page(feed)
      end

      # Iterate through the posts to get all comments
      puts "\n\n ---- COPIEDBOOK HAS FINISHED WITH POSTS, NOW GOING FOR COMMENTS ---- \n\n"
      @output.each_with_index do |post, index|
        if post["comments"]
          comments = []
          comment_feed = get_comment_feed(post)
          counter = 1
          until comment_feed == nil
            puts "  Retrieving comments from post #{post["id"]} #{'(page '+counter.to_s + ')' if counter > 1}"
            counter += 1
            comments += comment_feed
            comment_feed = get_next_page(comment_feed)
          end
          post["comments"] = comments
          @output[index] = post
        end
      end

      # Write the file
      File.open(@output_file, 'w') {|f| f.write(@output.to_json) }

      puts("\n\n ---- COPIEDBOOK HAS FINISHED ----\n")
      exit(0)
    end

    def run_it
      if ARGV.size >= 3
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

end



