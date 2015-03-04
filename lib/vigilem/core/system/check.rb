require 'vigilem/core/stat'

module Vigilem
module Core
  # 
  # 
  module System
    
    # common checks for os and input_system
    # pass `check[:os][/win/]` and it will #=~ against `RbConfig::CONFIG['host_os']`
    # pass a string and it uses #==
    # for input_sysmte_handlers it #find's the input_system_handler with the name that #=~
    # the argument or #== it
    # @return (TruceClass || FalseClass) whether or not the check passed
    def self.check
      @checks ||= {
          :os => lambda do |str_or_regex, os=nil|
                  os ||= Support::System.os
                  !!(str_or_regex.is_a?(Regexp) and 
                    str_or_regex =~ os) or 
                    (str_or_regex.to_s == os.to_s)
                end,
          :input_system => lambda do |name_or_regex|
                  ((name_or_regex.is_a?(Regexp) and 
                    (stats = Stat.all_available).find {|isys| isys.input_system_name =~ name_or_regex }) or
                    (stats.find {|isys| isys.input_system_name.to_s == name_or_regex.to_s })
                  )
                end
        }
    end
  end
end
end