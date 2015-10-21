#!/usr/bin/ruby

require 'rubygems'
require 'zip'

def jar_manifest(jar_stream)
  manifest = {}
  Zip::File.open_buffer(jar_stream) do |jar_file|
    jar_file.get_entry("META-INF/MANIFEST.MF").get_input_stream do |man_stream|
      man_stream.each_line do |line|
        /^([^:]+): (.*)$/ =~ line.chomp!
        manifest[$1]=$2
      end
    end
  end
  return manifest
end

WAR_LIB_PATH = "WEB-INF/lib/"

def war_libs(war_stream)
  Zip::File.open_buffer(war_stream) do |war_file|
    war_file.glob("#{WAR_LIB_PATH}*.jar") do |jar_entry|
      if /^#{WAR_LIB_PATH}(.*?).jar$/ =~ jar_entry.name
        jar_name = $1
        Tempfile.open(jar_name) do |jar_file|
          jar_entry.extract(jar_file.path) {true}
          yield jar_name, jar_manifest(jar_file)
        end
      end
    end
  end
end

def check_war(path, rules)
  open(path) do |war_stream|
    war_libs(war_stream) do |jar_name, manifest|
      rules.each do |pattern, restrictions|
        if(pattern === jar_name)
          restrictions.each do |key, restriction|
            if restriction === manifest[key]
              # OK
            else
              puts "#{jar_name} #{key} expected to be #{restriction} but was #{manifest[key]}"
            end
          end
        end
      end
    end
  end
end

#RULES = {
#  /^gs-.*/ => {
#    "Implementation-Version" => "2.7-SNAPSHOT",
#    "Git-Revision" => "8e84a8a356073d09ed44b831c96ac4a2656e82eg"
#  }
#}
#
#check_war(ARGV[0], RULES)
