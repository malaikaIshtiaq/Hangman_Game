class Game
  def initialize
    puts "Welcome to Hangman!\n\n"
    if File.exist?('./save.dat')
      new_or_load
    else
      new_or_load("NEW")
    end
    puts "\nYou can enter 'save' before any turn to seve your game.\n"
    @game.take_turn
  end

  private
  def new_or_load(game = "")
    game = game
    until (game == "NEW")||(game == "LOAD")
      print "Please enter 'new' to sart a new game, or 'load', to load\nexisting one: "
      game = gets.chomp.upcase
    end
    if game == "NEW"
      puts "You have started a new game."
      @game = Hangman.new
    elsif game == "LOAD"
      puts "You have loaded the game."
      @game = Hangman.load
    end
  end
end

class Hangman
  def initialize
    @word = get_the_word
    @tries = 6
    @misses = []
    @hits = []
  end

  def take_turn
    until game_over? || victory?
      show_gallows
      puts "Word:   #{hide_word.join(' ')}"
      puts "Misses: #{@misses.join(', ')}"
      check_guess guess
    end
    show_gallows
    puts "Word:   #{hide_word.join(' ')}"
    puts "You have lost.\nThe answer is #{@word.join('')}" if game_over?
    puts "You are victorious!" if victory?
  end

  def save
    File.open("./save.dat", "w") do |file|
      file.puts Marshal::dump(self)
    end
  end

  def self.load
    Marshal::load(File.read("./save.dat"))
  end

  private
  # First filters the words array created from '5desk.txt', then
  # gives back an array containing a word
  def get_the_word
    words = File.readlines("5desk.txt")
    words = words.map do |word|
      word.strip
    end
    words = words.select do |word|
      (word.length > 4) && (word.length < 13)
    end
    words.sample.upcase.split("")
  end

  def hide_word
    hidden = @word.map do |e|
      if @hits.include? e
        e
      else
        e = "_"
      end
    end
    hidden
  end

  def guess
    guess = ""
    until (guess.length == 1)&&(!@hits.include? guess)&&(!@misses.include? guess)&&(guess.match(/[A-Z]/))
      if guess == "SAVE"
        puts "Saving..."
        save
        puts "Your game has been saved. You can load it next time."
        exit
      elsif guess.match(/[A-Z]/).nil?
        puts "You need to enter a letter."
      elsif guess.length > 1
        puts "You can guess one letter at a time\n(if you want to save your game, enter 'save')."
      elsif (@hits.include? guess) || (@misses.include? guess)
        puts "You already tried that letter."
      end
      print "Your guess: "
      guess = gets.chomp.upcase

    end
    guess
  end

  def check_guess(letter)
    if @word.include? letter
      @hits << letter
    else
      @misses << letter
      @tries -= 1
    end
  end

  def game_over?
    @tries == 0
  end

  def victory?
    hide_word == @word
  end

  def show_gallows
    puts case @tries
    when 6
      ['   ____', '   |  |', '      |', '      |', '      |', '      |', '______|']
    when 5
      ['   ____', '   |  |', '   O  |', '      |', '      |', '      |', '______|']
    when 4
      ['   ____', '   |  |', '   O  |', '   |  |', '   |  |', '      |', '______|']
    when 3
      ['   ____', '   |  |', '   O  |', '  /|  |', '   |  |', '      |', '______|']
    when 2
      ['   ____', '   |  |', '   O  |', '  /|\ |', '   |  |', '      |', '______|']
    when 1
      ['   ____', '   |  |', '   O  |', '  /|\ |', '   |  |', '  /   |', '______|']
    when 0
      ['   ____', '   |  |', '   O  |', '  /|\ |', '   |  |', '  / \ |', '______|']
    end
  end
end

Game.new
