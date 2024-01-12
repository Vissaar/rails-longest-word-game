require "json"
require "open-uri"

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.shuffle.take(10)
  end

  def score
    @letters = params[:letters].split
    @word = params[:word].upcase

    if is_english_word? && is_valid_word?
      @score = @word.length.fdiv(@letters.length) * 100
    else
      @score = 0
    end
    session[:score] = session[:score].present? ? session[:score] + @score : @score
    @current_score = session[:score]
    @message = create_message
  end

  private

  def is_english_word?
    url = "https://wagon-dictionary.herokuapp.com/#{params[:word]}"
    api_response = URI.open(url).read
    response = JSON.parse(api_response)
    response["found"]
  end

  def is_valid_word?
    @word.chars.all? { |char| @word.count(char) <= @letters.count(char) }
  end

  def create_message
    if is_english_word? && is_valid_word?
      "Congrats #{@word} is a valid word"
    elsif is_english_word? && !is_valid_word?
      "Sorry #{@word} cannot be build with the letters #{@letters}"
    elsif !is_english_word? && is_valid_word?
      "Sorry but #{@word} does not seem to be a valid English word..."
    else
      "Sorry #{@word} cannot be build with the letters #{@letters}"
    end
  end
end
