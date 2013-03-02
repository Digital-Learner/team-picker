#!/usr/bin/env ruby

require 'active_support/inflector'
require 'action_view'

class Manager

  include ActionView::Helpers::TextHelper

  attr_reader :squad
  def pick_a_team(squad)
    team = Team.new

    formation = Team::THREE_FOUR_THREE

    puts "The formation requires the following number of players for each position"
    puts formation.map {|k,v| (v == 1 ? "#{v} #{k.to_s.humanize}" : "#{v} #{k.to_s.pluralize.humanize}")}

    formation.each do |position, quota|
      raise "There are not enough fit players to field the formation" if squad.eligible_players(position).count < quota
      position_pluralized = (quota == 1 ? "#{position}" : "#{position.to_s.pluralize}")
      dbl_underline = ((position_pluralized.length + 10).times { |i| print "="})

      puts "\nSelecting #{position_pluralized}\n"
     
      i = 1
      until i > quota # loop until the quota is reached
        team << squad.best_player(position)
        puts "#{quota - i} : = > We still need to add #{quota - i}" + ((quota - i) == 1 ? " #{position} to the team" : " #{position.to_s.pluralize} to the team")
        i += 1
      end
    end
    team
  end
end

class Coach

  def calculate_form(player)
    player.is_injured? ? (player.form = 0) : (player.form = player.skill * (rand(10) - 1).abs)
  end
end

class Player

  attr_accessor :form
  attr_reader :skill, :position, :name, :injured

  def initialize(name, position, skill, injured)
    @name, @position, @skill, @injured = name, position, skill, injured
  end

  def is_injured?
    @injured == 1
  end  

  def to_s
    # return a string representation of the player
    # e.g. "Defender 5, not injured, skill 4.7"
    "%16s: Skill:%2d, Form:%2d %s" % [@name, @skill, @form, ("(Injured)" if is_injured?)]
  end
end

class Team

  attr_accessor :squad

  FOUR_FOUR_TWO = { goalkeeper: 1, attacker: 2, midfielder: 4, defender: 4 }
  THREE_FOUR_THREE = { goalkeeper: 1, attacker: 3, midfielder: 4, defender: 3 }

  def initialize
    @players = []
    @eligible_players = []    
  end

  def <<(player)  # how to call it: team << player
    # raise an error if we can't add the player, 
    # e.g. if we already have the position filled
    # raise "Can't add #{position}"
    @eligible_players << player unless player.is_injured?
  end

  def to_s
    # iterate over all players and call their .to_s
    # @players.each {|p| "#{p.name}, #{p.position}"}
    @eligible_players.map(&:to_s).join("\n")
  end
end

class Squad

  attr_reader :players

  def initialize
    @players = []
    @eligible_players = []
    @coach = Coach.new
  end

  def <<(player)
    @coach.calculate_form(player) 
    @players << player #unless player.is_injured?
  end

  def eligible_players(position)
    eligible_players = players.select {|p| p.position == position and !p.is_injured?} 
  end

  def best_player(position)
    player = @players.select{|p| p.position == position}.sort_by{|p| p.form}.last
    @players.delete(player)
    # what if player.nil? maybe raise an exception
    player
  end
end

def squad_with_players
  # randomise the injury status of players - use 1 for injured, 0 for uninjured
  squad = Squad.new
  2.times do |i|
    squad << Player.new("Goalkeeper #{i}", :goalkeeper, rand(10) + 1, rand(5))
  end
  8.times do |i|
    squad << Player.new("Defender #{i}", :defender, rand(10) + 1, rand(5))
  end
  8.times do |i|
    squad << Player.new("Midfielder #{i}", :midfielder, rand(10) + 1, rand(5))
  end
  4.times do |i|
    squad << Player.new("Attacker #{i}", :attacker, rand(10) + 1, rand(5))
  end  
  squad
end


system("clear")
puts "\n============================== \nStarting #{$0} run\n============================== "
puts "\nAssigning 22 players to a squad"
squad = squad_with_players

puts "\nHere's the list of players eligible for the Team\n"
puts squad.players.each { |player| player }

manager = Manager.new()

puts "\nYour manager will now pick a team from 'squad'"
team = manager.pick_a_team(squad)
puts "\nOur chosen team:"
puts team



