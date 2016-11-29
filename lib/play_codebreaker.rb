#require 'rav_codebreaker'
require_relative './rav_codebreaker.rb'

module Test
  extend RavCodebreaker
end

#RavCodebreaker.play(:beginner)
RavCodebreaker::play(:beginner)