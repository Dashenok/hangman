defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do

    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0

    for l <- game.letters do
      assert l =~ ~r/[a-z]/
    end
  end

  test "state isn't change for :won or :lost state" do
    for state <- [ :won, :lost ] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert { ^game, _ } = Game.make_move(game, "q")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used

    { game, _tally }  = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "guess is a :good_guess" do
    game  = Game.new_game("wally")
    { game, _tally } = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "guessed word is recognized as a :won" do
    game = Game.new_game("wally")

    moves = [
      { "w", :good_guess, 7 },
      { "a", :good_guess, 7 },
      { "l", :good_guess, 7 },
      { "y", :won, 7 },
    ]

    Enum.reduce(moves, game, fn({guess, state, turns_left}, new_game) ->
      { new_game, _tally } = Game.make_move(new_game, guess)
      assert state == new_game.game_state
      assert turns_left == new_game.turns_left
      new_game
    end)
  end

  test "guess is a :bad_guess" do
    game  = Game.new_game("wally")
    { game, _tally } = Game.make_move(game, "q")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "game is :lost after 7 incorrect guesses" do
    game = Game.new_game("wally")

    moves = [
      { "z", :bad_guess, 6 },
      { "x", :bad_guess, 5 },
      { "c", :bad_guess, 4 },
      { "v", :bad_guess, 3 },
      { "b", :bad_guess, 2 },
      { "n", :bad_guess, 1 },
      { "m", :lost, 0 },
    ]

    Enum.reduce(moves, game, fn({guess, state, turns_left}, new_game) ->
      { new_game, _tally } = Game.make_move(new_game, guess)
      assert state == new_game.game_state
      assert turns_left == new_game.turns_left
      new_game
    end)
  end


end