require 'sinatra'
require 'sinatra/reloader'



class GameController
    attr_accessor :guesses, :user_word, :answer, :used_letters
    def initialize
        @guesses = 0
        @user_word = ''
        @answer = ''
        @used_letters = []
    end

    public
    def validGuess?(guess)
        if !@used_letters.include?(guess)  and guess =~ /[A-Za-z]/
            return true
        else
            print "hi"
            return false

        end

    end

    def newGame
        @answer = selectWord()
        @guesses = @answer.length + 2
        @user_word = @user_word.rjust(@answer.length, '_').split('')
    end

    def selectWord
        # TODO: Change suitable_words file path to properly access 5desk.txt?
        path = Dir.glob('public/5desk.txt').first
        suitable_words = File.open(path) { |file|
            file.readlines().select { |word|
                 word.strip!()
                 word.length > 5 and word.length < 12
            }
        }
        return suitable_words[rand(suitable_words.length)]
    end



    def play(guess)
        guess = guess.downcase
            @answer.split('').each_with_index { |char, index|
                if guess == char.downcase
                    @user_word[index] = guess
                end
            }
            @used_letters.push(guess)
                @guesses -= 1
            end
    end



$gc = GameController.new
$gc.newGame()
get '/' do


    erb :index, locals:
    {
        used_letters: $gc.used_letters,
        answer: $gc.answer,
        guesses: $gc.guesses,
        error_msg: false
    }
end

post '/round' do
    guess = params['guess'].to_s.downcase

    if $gc.validGuess?(guess)
        $gc.play(guess)
        erb :index, locals:
        {
            used_letters: $gc.used_letters,
            answer: $gc.answer,
            guesses: $gc.guesses,
            error_msg: false
        }
    else
        erb :index, locals:
        {
            used_letters: $gc.used_letters,
            answer: $gc.answer,
            guesses: $gc.guesses,
            error_msg: true
        }
    end
end

    post '/guess' do
        gussed_word = params['guessed_word'].to_s().downcase().strip()
        if gussed_word == $gc.answer
            erb :guess_word, locals: {
                answer: true
            }
        else
            erb :guess_word, locals: {
                answer: false
            }
        end

    end
