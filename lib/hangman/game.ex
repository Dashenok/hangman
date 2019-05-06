defmodule Hangman.Game do

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  ) # create a defstructure with defined keys and name = Modulename. Call %Hangman.Game{}

  def new_game(random_word) do
    %Hangman.Game{
      letters: random_word |> String.codepoints
    }
  end

  def new_game() do
    new_game(Dictionary.random_word)
  end

  def make_move(game = %{ game_state: state }, _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    accept_letter(game, guess, guess =~ ~r/[a-z]/)
    |> return_with_tally()
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters:    game.letters |> reveal_guessed(game.used),
      guessed:    game.used,
    }
  end

  ###############

  defp return_with_tally(game), do: {game, tally(game)}

  defp accept_letter(game, guess, _is_valid_symbol = true) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
  end

  defp accept_letter(game, _guess, _is_not_valid_symbol) do
    Map.put(game, :game_state, :invalid_symbol)
  end

  defp accept_move(game, _guess, _already_used = true) do
    Map.put(game, :game_state, :already_used)
  end

  defp accept_move(game, guess, _already_used) do
    Map.put(game, :used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
    |> MapSet.subset?(game.used)
    |> if_won()
    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %{ turns_left: 1 }, _not_good_guess) do
    %{ game |
      game_state: :lost,
      turns_left: 0
    }
  end

  defp score_guess(game = %{ turns_left: turns_left }, _not_good_guess) do
    %{ game |
      game_state: :bad_guess,
      turns_left: turns_left - 1
      }
  end

  defp if_won(true), do: :won
  defp if_won(_), do: :good_guess

  defp reveal_guessed(letters, used_letters) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used_letters, letter)) end)
  end

  defp reveal_letter(letter, _is_used = true), do: letter
  defp reveal_letter(_letter, _not_used), do: "_"

end
