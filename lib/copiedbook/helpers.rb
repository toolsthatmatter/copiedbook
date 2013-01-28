module Helpers

  def log_this(message, type_of_message="info")
    @log_file.send type_of_message.to_sym, message
    if type_of_message != 'debug' || $debug == true
      puts("#{type_of_message.upcase} : #{message}")
    end
  end

  def run_command(command,error_msg)
    log_this("#{command}",'debug')
    output = `#{command}`
    result=$?.success?
    if result == false
      log_this(error_msg,'error')
      exit(1)
    end
    return output
  end

  def to_sentence(the_array)
    if the_array.length == 1
      return the_array[0]
    else
      return "#{the_array[0, the_array.length-1].join(', ')} and #{the_array.last}"
    end
  end

  def clean_the_log
    log_this('Cleaning log folder!','debug')
    # Get the filenames of log folder on an array sorted by 
    # modification time (oldest first)
    log_files = Dir.glob($log_path + '/*.log').sort_by do 
      |file| File.mtime(file)
    end
    log_this("No log file will be cleaned because the limit hasn't be reached :)", 'debug') if log_files.size <= $log_limit
    # Operate over the array until we reach the established limit 
    # of files for the log path
    while log_files.size > $log_limit
      log_this("Log file will be deleted: #{log_files.first}",'debug')
      File.delete(log_files.first)
	  log_files.delete log_files.first
    end
  end

end
