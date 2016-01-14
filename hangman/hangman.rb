class Game
  def initialize
  end

  def welcome
    puts "\n Welcome, User!"
    puts "What's Your name?"
    gets.strip
  end
end

module Dictionary
  def random_word
  	dict = []
    File.open("5desk.txt").readlines.each do |line|
      dict << line.strip if line.strip.length.between?(5, 12)
    end
    dict[rand(dict.length - 1)].upcase
  end
end

class Hangman
  include Dictionary
  
  attr_reader :user_name, :word

  def initialize
    @user_name = Game.new.welcome
    @word = random_word
  end
end

a = Hangman.new
puts a.user_name
puts a. word