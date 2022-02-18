#==============================================================================
# ** AlterRuby v1.0                                                (2022-02-18)
#    by Wreon
#------------------------------------------------------------------------------
#  This class allows you to run Ruby code in parallel by using "||".
#------------------------------------------------------------------------------
#  Example
#  a = true.to_s
#  success = AR('5.times do; sleep(0.2); end; puts("Done: " + a) || sleep(0.1); puts("Test")', binding)
#------------------------------------------------------------------------------
#  License (MIT)
#  Copyright © 2022 Wreon
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
#  IN THE SOFTWARE.
#==============================================================================

class AlterRuby
  @@error_messages = {}
  @unfinished_lines = 0
  
  def initialize
    @id = Unique_ID.new.generate_id.to_s
    @@error_messages[@id] = nil
  end
  
  def run_line(line, binding)
    line = 'instance_id = ' + @id + '
begin
  ' + line + '
rescue StandardError => e
  ' + # Print the error message
  'puts("Error: " + e.to_s)
  
  ' + # Set @@error_messages[class instance id] to the error message
  'current_error_messages = AlterRuby.class_variable_get(:@@error_messages)
  current_error_messages["' + @id + '"] = e.to_s
  AlterRuby.class_variable_set(:@@error_messages, current_error_messages)
end'
    
    Thread.new {
      eval(line, binding)
      @unfinished_lines -= 1
    }
  end
  
  def run(code, binding)
    # Loop through each line of code
    lines = code.split("\n")
    lines.each do |n|
      # Split code snippets by "||"
      threads = n.split("||")
      # Get the number of code snippets that you need to wait for
      @unfinished_lines = threads.length
      # Run each line of code in a new thread
      threads.each do |m|
        run_line(m, binding)
      end
      
      # Wait for all lines of code to finish
      loop do
        if @@error_messages[@id] then
          # Return the error message if there is an error
          error_message = @@error_messages[@id]
          @@error_messages.delete(@id)
          return error_message
        end
        
        # Break the loop if all lines of code have been completed
        break if @unfinished_lines <= 0
        
        # 100 FPS
        sleep(0.01)
      end
    end
    # Return true if it ran successfully
    @@error_messages.delete(@id)
    return true
  end
end

def AR(code, binding)
  return AlterRuby.new.run(code, binding)
end
