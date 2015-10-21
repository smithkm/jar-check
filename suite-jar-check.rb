#!/usr/bin/ruby

require './jar-check.rb'
require 'open3'

GIT_DIR="/home/smithkm/og-proj/suite"

RULES = Hash.new {|hash, key| hash[key] = Hash.new}

Dir.chdir(GIT_DIR) do 
  Open3.popen3("git", "submodule", "status" , "--recursive") do |stdin, stdout, stderr, wait_thr|
    stdout.each_line do |line|
      /^(.)([\da-f]+) (.+?) \(([^()]*?)\)$/ =~ line
      commit=$2
      path=$3
      case path
      when "geoserver/externals/geoserver-exts"
        RULES[/^g[st]-ysld.*/]["Git-Revision"]=commit
      when "geoserver/externals/geoserver"
        RULES[/^gs-(?!ysld).*/]["Git-Revision"]=commit
      when "geoserver/externals/geotools"
        RULES[/^gt-(?!ysld).*/]["Git-Revision"]=commit
      when "geoserver/externals/geowebcache"
        RULES[/^gwc-.*/]["Implementation-Version"]=/.*?\/#{commit}/
      end
    end
  end
end



p RULES

exit check_war(ARGV[0], RULES)? 0 : 1
