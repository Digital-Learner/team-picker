#!/usr/bin/env ruby

require 'active_support/inflector'
require 'action_view'

class Manager

  include ActionView::Helpers::TextHelper

  attr_reader :squad

  def pick_a_team(squad)
    team = Team.new

    formation = Team::THREE_FIVE_THREE

    # while a position quata is unfilled add best player for position from remaining pool of players who are eligible
    # loop over the formation hash to fill each position quota
    puts "The formation requires the following number of players for each position"
    formation.each do |position, quota|
      puts "Formation requirement: #{quota} " + (quota == 1 ? "#{position}" : "#{position.to_s.pluralize}")
      i = 1
      until i > quota
        team << squad.best_player(position)
        # pluralize(2, "cat")
        position_pluralized = ((quota - i).to_s == 1 ? "#{postion}" : "#{position.to_s.pluralize}")
        # puts "We still need to add #{quota - i} #{position_pluralized} to the team" unless (quota - i) == 0
        # puts "We need to add another #{position} to the team" unless (quota - i) == 0
        puts "#{quota - i} : = > We still need to add #{quota - i}" + ((quota - i) == 1 ? " #{position} to the team" : " #{position.to_s.pluralize} to the team")
        i += 1
      end
    end
    team
  end
end

class Coach

  def calculate_form(player)
    # player.form = player.skill # unless condition
    player.injured == 1 ? (player.form = 0) : (player.form = player.skill)
  end 
end

class Player

  attr_accessor :form
  attr_reader :skill, :position, :name, :injured

  def initialize(name, position, skill, injured)
    @name, @position, @skill, @injured = name, position, skill, injured
  end

  def is_injured?
    @injured == 1 ? true : false
  end  

  def to_s
    # return a string representation of the player
    # e.g. "Defender 5, not injured, skill 4.7"
    "%16s: Skill:%2d, Form:%2d %s" % [@name, @skill, @form, ("(Injured)" if is_injured?)]
    # "Player Detail: Name: #{@name}, Postion: #{@position}, Skill: #{@skill}, Is Injured?: #{@injured}, Form: #{form}"
  end
end

class Team

  FOUR_FOUR_TWO = { goalkeeper: 1, attacker: 2, midfielder: 4, defender: 4 }
  THREE_FIVE_THREE = { goalkeeper: 1, attacker: 3, midfielder: 5, defender: 3 }

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
    # iterate over all players and call their .to_s
    @players.each {|p| "#{p.name}, #{p.position}"}
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


system("clear")
puts "\n============================== \nStarting 'team_picker.rb' run\n============================== "
puts "\nAssigning 22 players to a squad"
squad = squad_with_players

puts "\nHere's the list of players eligible for the Team\n"
puts squad.players.each { |player| player }

manager = Manager.new()

puts "\nYour manager #{manager} will now pick a team from 'squad'"
team = manager.pick_a_team(squad)
puts "\nOur chosen team:"
puts team



