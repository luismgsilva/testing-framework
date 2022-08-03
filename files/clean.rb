#!/usr/bin/env ruby

Dir.chdir ARGV[0]

arr = File.readlines(".gitignore")

arr.each { |i| i.chomp! }

arr.each do |folder|
  p "rm -rf #{folder}"
  system  "rm -rf #{folder}"
end
