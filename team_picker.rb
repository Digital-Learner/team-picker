#!/usr/bin/env ruby

require 'active_support/inflector'
require 'action_view'

class Manager

  include ActionView::Helpers::TextHelper

  attr_reader :squad

  def pick_a_team(squad)
    team = Team.new

    # Want a concept of 'formation' and use that to determine the team structure

    formation = { goalkeeper: 1, attacker: 2, midfielder: 4, defender: 4 } # ruby 1.9+ only style
    # formation = { :goalkeeper => 1 } # ruby 1.8 style (works with 1.9+)

    # while a position quata is unfilled add best player for position from remaining pool of players who are eligible
    # loop over the formation hash to fill each position quota
    puts "The formation requires the following number of players for each position"
    formation.each do |position, quota|
      puts "Formation requirement: #{quota} #{position.to_s.pluralize}"
      i = 1
      until i > quota
        team << squad.best_player(position)

        # pluralize(2, "cat")

        position_pluralized = ((quota - i).to_s == 1 ? "#{postion}" : "#{position.to_s.pluralize}")
        puts position_pluralized
        # puts "We still need to add #{quota - i} #{position_pluralized} to the team" unless (quota - i) == 0


        # puts "We need to add another #{position} to the team" unless (quota - i) == 0
        puts "#{quota - i} : = > We still need to add #{quota - i}" + ((quota - i) == 1 ? " #{position} to the team" : " #{position.to_s.pluralize} to the team")
        i += 1
      end
    end

    # puts "Here's the list of players not selected for the Team\n\n"
    # puts squad.players.each { |player| player }    

    # get the best players for every position from the squad
    # and add them to the team
    # team << player # add them to the team
    team
  end
end

class Coach

  def calculate_form(player)
    #puts "Calculating Players (#{player}) form"
    # player.form = player.skill # unless condition
    # use a super sexy ruby ternary operator here
    player.injured == 1 ? (player.form = 0) : (player.form = player.skill)
    # puts "#{player.form}"
  end
  
end

class Player

  attr_accessor :form
  attr_reader :skill, :position, :name, :injured

  def initialize(name, position, skill, injured)
    @name, @position, @skill, @injured = name, position, skill, injured
  end

  def to_s
    # return a string representation of the player
    # e.g. "Defender 5, not injured, skill 4.7"
    "Player Detail: Name: #{@name}, Postion: #{@position}, Skill: #{@skill}, Is Injured?: #{@injured}, Form: #{form}"
  end
end

class Team

  def initialize
    @players = []
  end

  def <<(player)  # how to call it: team << player
    # raise an error if we can't add the player, 
    # e.g. if we already have the position filled
    # raise "Can't add #{position}"
    @players << player
  end

  def to_s
    # return every player and their position
    # iterate over all players and call their .to_s
    @players.each {|p| puts "#{p.name}, #{p.position}"}
  end

end

class Squad

  attr_reader :players

  def initialize
    @players = []
    @coach = Coach.new
  end

  def <<(player)
    @coach.calculate_form(player) 
    @players << player
  end

  def best_player(position)

    player = @players.select{|p| p.position == position}.sort_by{|p| p.form}.last
    @players.delete(player)

    # what if player.nil? maybe raise an exception
    # remove the player from @players
    player
  end

end

def squad_with_players
  # randomise the injury status of players - use 1 for injured, 0 for uninjured
  squad = Squad.new
  2.times do |i|
    squad << Player.new("Goalkeeper #{i}", :goalkeeper, rand(10) + 1, rand(2))
  end
  8.times do |i|
    squad << Player.new("Defender #{i}", :defender, rand(10) + 1, rand(2))
  end
  8.times do |i|
    squad << Player.new("Midfielder #{i}", :midfielder, rand(10) + 1, rand(2))
  end
  4.times do |i|
    squad << Player.new("Attacker #{i}", :attacker, rand(10) + 1, rand(2))
  end  
  squad
end

puts "Starting 'team_picker.rb' run\n"
puts "\nAssigning 22 players to a squad"
squad = squad_with_players

puts "\nHere's the list of players eligible for the Team\n"
# puts squad.players.each { |player| player }

manager = Manager.new()

puts "\nYour manager #{manager} will now pick a team from 'squad'"
team = manager.pick_a_team(squad)
puts "\nOur chosen team:"
puts team



