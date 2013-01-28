module FBCalls

  def get_feed
    if @token.empty?
      puts "Introduce a new token"
      @token = gets.chomp
    end    
    @graph = Koala::Facebook::API.new(@token)
    begin
      feed = @graph.get_connections(@fanpage_id, "feed")
    rescue Exception => ex
      feed = handle_error(ex)
    end
  end

  def get_next_page(feed,parameters = nil)
    begin
      parameters = feed.next_page_params if parameters == nil 
      return nil if parameters == nil
      feed = @graph.get_page(parameters)
    rescue Exception => ex
      feed = handle_error(ex)
      get_next_page(feed, parameters)
    end
  end
  
  def get_comment_feed(post)
    begin
      comment_feed = @graph.get_connections(post["id"], "comments")
    rescue Exception => ex
      feed = handle_error(ex)
      get_comment_feed
    end
  end
  
  def handle_error(ex)
    File.open(@output_file, 'w') {|f| f.write(@output.to_json) }
    puts "Facebook has returned an error: #{ex.message}"
    @token = ""
    return get_feed
  end
  
end
