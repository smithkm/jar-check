#!/usr/bin/ruby

require './jar-check.rb'
require 'open3'

GIT_DIR="/home/smithkm/og-proj/suite"

RULES = {}

MODULE_MAP = {
  "geoserver/externals/geoserver" => /^gs-.*/,
  "geoserver/externals/geotools" => /^gt-.*/,
  "geoserver/externals/geowebcache" => /^gwc-.*/
}

Open3.popen3("git", "submodule", "status" , "--recursive", :chdir=>GIT_DIR) do |stdin, stdout, stderr, wait_thr|
  stdout.each_line do |line|
    /^(.)([\da-f]+) (.+?) \(([^()]*?)\)$/ =~ line
    commit=$2
    path=$3
    if(MODULE_MAP.has_key? path)
      RULES[MODULE_MAP[path]]={"Git-Revision"=>commit}
    end
  end
end

p RULES

p ARGV[0]

check_war(ARGV[0], RULES)
