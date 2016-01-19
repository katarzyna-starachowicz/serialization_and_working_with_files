require 'yaml'

module Dictionary
  def random_word
    dict = []
    File.open("5desk.txt").readlines.each do |line|
      dict << line.strip if line.strip.length.between?(5, 12)
    end
    dict[rand(dict.length - 1)].upcase
  end
end

class Game
  include Dictionary

  attr_reader :secret_word, :bad_choices, :turns
  
  def initialize
    @secret_word = random_word
    @turns = 12
    @bad_choices = []
  end

  def welcome
    puts "\nWelcome, User!"
    puts "What's Your name?"
    gets.strip
  end

  def underscore_word
    a = ""
    @secret_word.length.times {a << "_"}
    a
  end

  def answer_to_letter(letter, underscore_word)
    if @secret_word.include? letter
      puts "Good choice! You got it!"
      new_word = ""
      index = 0
      underscore_word.each_char do |l|
        new_word[index] = @secret_word[index] == letter ? letter : l
        index += 1     
      end
      new_word
    else
      puts "Baaaaad choice!"
      @turns -= 1
      if @turns == 0
        "__  :-X ..::GAME OVER::.. X-:  __"
      else
        puts "You have lost #{12 - @turns} turns."
        puts "But You still have #{@turns} more incorrect guesses before the game ends."
        @bad_choices << letter
        underscore_word
      end
    end
  end

  def take_letter
    puts "\nGuess a letter, please."
    gets.strip.upcase
  end

  def load_game
    game_file = GameFile.new("saved.yaml")
    yaml = game_file.read
    YAML::load(yaml)
  end
end

class Hangman
  attr_reader :underscore_word, :user_name, :game

  def initialize
    @game = Game.new
    @user_name = @game.welcome
    @underscore_word = @game.underscore_word
  end

  def win?
    if @underscore_word.include? "_"
      false
    else
      true
    end
  end

  def lost
    puts "\nI'm so sorry, #{@user_name}. You have lost all the turns."
    puts "You are a hangman now."
    puts "Creepy, isn't it?".rjust(50)
    puts "\n\n"
  end

  def save_game
    Dir.mkdir('games') unless Dir.exist? 'games'
    filename = 'games/saved.yaml'
    File.open(filename, 'w') do |file|
      file.puts YAML.dump(self)
    end
  end

  def play
    while
      letter = @game.take_letter
      @underscore_word = @game.answer_to_letter(letter, @underscore_word)
      puts @underscore_word
      if win?
        puts "Congratulation, #{@user_name}! You have won!"
        break
      elsif @underscore_word == "__  :-X ..::GAME OVER::.. X-:  __"
        lost
        puts "PS The secret word was: #{@game.secret_word}".rjust(60)
        break
      else
        puts "Misses: #{@game.bad_choices.join(", ").downcase}"
        puts "Do You want to save a game? (y/n)"
        save_game if gets.chomp.downcase == 'y'
        puts "Do You want to break a game? (y/n)"
        break if gets.chomp.downcase == 'y'
      end
    end
  end
end

def load_game
  content = File.open('games/saved.yaml', 'r') { |file| file.read }
  YAML.load(content)
end

puts "Do you want to load previously saved Hangman game (y/n)?"

if gets.chomp.downcase == 'y'
  game = load_game
  puts "Welcome back, #{game.user_name}!"
  puts "It's Your word: #{game.underscore_word}"
  puts "Misses: #{game.game.bad_choices.join(", ").downcase}"
  puts "You have lost #{12 - game.game.turns} turns."
  puts "But You still have #{game.game.turns} more incorrect guesses before the game ends."
  game.play
else
  Hangman.new.play
end