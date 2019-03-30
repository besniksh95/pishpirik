defmodule Pishpirik.Deck do
  alias __MODULE__

  defmodule Card do
    defstruct [:suit, :value]
  end

  def new() do
    for value <- values(), suit <- suits() do
      %Card{value: value, suit: suit}
    end
    |> Enum.shuffle()
  end

  def deal(new_state, cards) do
    user_cards = Enum.take_random(cards, 4)
    computer_cards = Enum.take_random(cards -- user_cards, 4)
    Map.merge(new_state, %{
      user_cards: user_cards,
      computer_cards: computer_cards,
      cards: (cards -- user_cards) -- computer_cards
      })
  end

  defp to_tuple(%Deck.Card{value: value, suit: suit}),
    do: {value, suit}

  defp values(), do: Enum.to_list(1..13)
  defp suits(), do: [:spades, :diamonds, :clubs, :hearts]
end
