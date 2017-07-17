#HANGMAN GAME
require 'csv'

class Game
  attr_reader :word
  attr_accessor :guess, :lives, :bad_move_ary, :good_move_ary

  def initialize #final
    @word = random_word.chomp.split("") #chomp to remove \n elem from array
    @guess = Array.new(word.length){Letter.new}
  end

  class Letter
    attr_accessor :value

    def initialize(value="") #final
      @value = value
    end
  end

  def print_status #final
    puts @guess.map {|letter| letter.value.empty? ? "_" : letter.value}.join(" ")
  end

  def random_word #final
    dictionary = File.open("/home/bategjorgija/the_odin_project/hangman/words.txt", 'r').readlines
    word = ""
    until word.length.between?(6,13)
      word = dictionary.sample
    end
    word.downcase!
    word
  end

  def get_move(move = gets.chomp) #final
    move
  end

  def set_letter(move) #final
    @word.each_with_index do |letter, index|
      @guess[index].value = move if move == letter
    end
  end

  def check_ok(move) #final
    true if @word.any? {|letter| letter == move}
  end

  def win_check #final
    true if @guess.map {|letter| letter.value}.join("") == word.join("")
  end

  def save_progress

    puts "Enter a name for your save file:"
    name = gets.chomp

    #add a functionality that checks whether a savefile with that name already exists

    time = Time.now

    CSV.open("/home/bategjorgija/the_odin_project/hangman/saves.csv", 'a') do |save_file|

      #adapting for CSV (arrays cant be saved properly)
      @guess = @guess.map {|letter| letter.value.empty? ? "_" : letter.value}.join("")
      @word = @word.join("")
      @bad_move_ary = @bad_move_ary.join("")
      @good_move_ary = @good_move_ary.join("")

      #saving to the CSV
      save_file << [time, name, @word, @guess, lives, bad_move_ary, good_move_ary]
    end

    #format for saving
    #date, savename, word, guess, lives, badletters, goodletters
    puts "Save successful!"
  end

  def load_progress

    puts "You've chosen to load a save file!"
    puts "Printing available save files..."
    save_file = CSV.read "/home/bategjorgija/the_odin_project/hangman/saves.csv", headers: true, header_converters: :symbol

    save_file.each do |save|
      puts print save[:date], "|", save[:savename]
    end

    puts "Insert the exact name of the file you wish to load:"
    name = gets.chomp

    save_file.each do |row|
      if row[:savename] == name
        puts "Loading save with name: #{row[:savename]}, made on date: #{row[:date]}"
        #puts row[:guess]
        @word = row[:word].split("")
        @lives = row[:lives]
        @bad_move_ary = row[:badletters].split("")
        @good_move_ary = row[:goodletters].split("")

        #special procedure
        #to make it somewhat faster row[:guess] should be split only once before these two

        @guess = Array.new(row[:guess].length){Letter.new}
        @guess.each_with_index.map do |letter, index|
          letter.value = row[:guess].split("")[index]
        end
      end
    end
  end

  def delete_saves
    #possibly done after everything else
  end

  def play
    @lives = 6 #can be made relative to word.length
    @good_move_ary = []
    @bad_move_ary = []

    puts "New hangman game started!"
    puts "Choosing a random word..."
    puts "Random word chosen!"
    puts "You have 6 lives, use them wisely!"
    puts "If you want to load a previous save, insert LOAD, else just press enter"
    load_decision = gets.chomp
    if load_decision == "LOAD"
      load_progress
      #repeted from below
      puts "Lives remaining: #{@lives}"
      puts "Wrong letters #{@bad_move_ary}"
      puts "Correct letters #{@good_move_ary}"
    end
    while true
      print_status
      puts "Insert your next letter or SAVE to save your current progress"
      begin
        move = get_move
        if move == "SAVE"
          save_progress
          break
        end
        raise ArgumentError if move.length != 1
        if check_ok(move)
          if @good_move_ary.none? {|x| x == move}
            @good_move_ary.push(move)
            set_letter(move)
          end
        else
          if @bad_move_ary.none? {|x| x == move}
            @bad_move_ary.push(move)
            @lives -= 1
          end
        end
      rescue
        puts "Input not valid, please try again..."
        retry
      end
      puts "Lives remaining: #{@lives}"
      puts "Wrong letters #{@bad_move_ary}"
      puts "Correct letters #{@good_move_ary}"
      if win_check
        puts "Congrats, you won!"
        puts "#{@word.join("").upcase}"
        return
      end
      if @lives == 0
        puts "You got hanged :("
        puts "The correct word was #{@word.join("").upcase}"
        return
      end
    end
  end

end

game = Game.new
game.play

=begin #IF NEED BE, copy these back inside

  def set_piece(move) #not used atm, info in comment inside
    move = move.split("")
    move.each do |piece|
      @word.each_with_index do |letter, index|
        @guess[index].value = piece if piece == letter
        #ex gro from grooming reveals everything...I'll just make it one letter OR full word only for now
      end; end
  end

  def check_ok_MADE_FOR_SET_PIECE(move) #not used atm
    if @word.any? {|letter| letter == move }
      "first case"
    elsif @word.join("").include?(move)
      "second case"
    else
      false
    end
  end

=end
