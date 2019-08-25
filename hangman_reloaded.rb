require 'sinatra'
require 'sinatra/reloader'




class GameController
    attr_accessor :guesses, :user_word, :answer, :used_letters
    def initialize
        @guesses = 0
        @user_word = []
        @answer = ''
        @used_letters = []
    end
#
    public
    def validGuess?(guess)
        if !@used_letters.include?(guess)  and guess =~ /[A-Za-z]/ and guess.length == 1
            return true
        else
            return false

        end

    end

    def newGame
        @answer = selectWord()
        @guesses = @answer.length + 2
        @user_word = ''.rjust(@answer.length, '_').split('')
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
        error_msg: false,
        user_word: $gc.user_word
    }
end

post '/round' do
    guess = params['guess'].to_s.downcase()
    if $gc.guesses > 0
        if $gc.validGuess?(guess)
            $gc.play(guess)
            redirect to('/win') if $gc.user_word.join('').downcase == $gc.answer.downcase

            erb :index, locals: {
                used_letters: $gc.used_letters,
                answer: $gc.answer,
                guesses: $gc.guesses,
                error_msg: false,
                user_word: $gc.user_word}
        else
            erb :index, locals:
            {
                used_letters: $gc.used_letters,
                answer: $gc.answer,
                guesses: $gc.guesses,
                error_msg: true,
                user_word: $gc.user_word
            }
        end
    else
        erb :guess_word, locals: {
            answer: $gc.answer
        }
    end

end



    post '/guess' do
        guessed_word = params['guessed_word'].to_s().downcase().strip()

        if guessed_word == $gc.answer.downcase()
            erb :guess_word, locals: {
                answer: true,
                correct_word: $gc.answer
            }
        else
            erb :guess_word, locals: {
                answer: false,
                correct_word: $gc.answer,
                guessed_word: guessed_word
            }
        end


    end

get '/win' do
        erb :win
end
