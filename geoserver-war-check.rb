#!/usr/bin/ruby

# suite-jar-check path-to-war path-to-suite-repo
# Checks that the jars in the specified war match the git revisions of the submodules in the repository
#
# Set the repository to the commit which should have been used, and update the submodules before running this.

require './jar-check.rb'
require 'open3'

# Autovivificating hash
RULES = Hash.new {|hash, key| hash[key] = Hash.new}

Dir.chdir(ARGV[1]) do 
  Open3.popen3("git", "submodule", "status" , "--recursive") do |stdin, stdout, stderr, wait_thr|
    stdout.each_line do |line|
      /^(.)([\da-f]+) (.+?) \(([^()]*?)\)$/ =~ line
      commit=$2
      path=$3
      case path
      when "geoserver/externals/geoserver-exts"
        # YSLD from the geoserver-exts submodule
        RULES[/^g[st]-ysld.*/]["Git-Revision"]=commit
      when "geoserver/externals/geoserver"
        # The geoserver submodule
        RULES[/^gs-(?!ysld).*/]["Git-Revision"]=commit
      when "geoserver/externals/geotools"
        # The geotools submodule
        RULES[/^gt-(?!ysld).*/]["Git-Revision"]=commit
      when "geoserver/externals/geowebcache"
        # The geowebcache submodule
        RULES[/^gwc-.*/]["Implementation-Version"]=/.*?\/#{commit}/
      end
    end
  end
end



p RULES

exit check_war(ARGV[0], RULES)? 0 : 1
