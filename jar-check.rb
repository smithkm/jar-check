#!/usr/bin/ruby

require 'rubygems'
require 'zip'

class NoManifestError < StandardError
end

class BadManifestError < StandardError
end

def jar_manifest(jar_stream)
  i = 0
  begin
    manifest = {}
    last=nil
    Zip::File.open_buffer(jar_stream) do |jar_file|
      i = jar_file.glob("*").size
      jar_file.get_entry("META-INF/MANIFEST.MF").get_input_stream do |man_stream|
        man_stream.each_line do |line|
          case line.chomp!
          when /^\s*$/
            # Do nothing
          when /^([^:]+): (.*)$/
            manifest[$1]=$2
            last=$1
          when /^ (.*)$/
            raise BadManifestError, "Manifest continuation can not be first line" if last.nil?
            manifest[last]+=$1
          else
            raise BadManifestError, "Manifest contains invalid line: #{line}"
          end
        end
      end
    end
    return manifest
  rescue Errno::ENOENT
    puts i
    raise NoManifestError
  end
end

WAR_LIB_PATH = "WEB-INF/lib/"

def war_libs(war_stream)
  Zip::File.open_buffer(war_stream) do |war_file|
    war_file.glob("#{WAR_LIB_PATH}*.jar") do |jar_entry|
      if /^#{WAR_LIB_PATH}(.*?).jar$/ =~ jar_entry.name
        jar_name=$1
        Tempfile.open(jar_name) do |jar_file|
          begin
            jar_entry.extract(jar_file.path) {true}
            yield jar_name, jar_manifest(jar_file)
          rescue NoManifestError
            $stderr.puts "#{jar_name} has no manifest, ignoring"
          end
        end
      end
    end
  end
end

def check_war(path, rules)
  failed = false
  open(path) do |war_stream|
    war_libs(war_stream) do |jar_name, manifest|
      rules.each do |pattern, restrictions|
        if(pattern === jar_name)
          restrictions.each do |key, restriction|
            if restriction === manifest[key]
              # OK
            else
              $stderr.puts "#{jar_name} #{key} expected to be #{restriction} but was #{manifest[key]}"
              failed = true
            end
          end
        end
      end
    end
  end
  return failed
end

#RULES = {
#  /^gs-.*/ => {
#    "Implementation-Version" => "2.7-SNAPSHOT",
#    "Git-Revision" => "8e84a8a356073d09ed44b831c96ac4a2656e82eg"
#  }
#}
#
#check_war(ARGV[0], RULES)
