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

  def deal(cards) do
    hand = Enum.take_random(cards, 26)

    computer =
      (cards -- hand)
      |> Enum.map(&to_tuple/1)
  end

  defp to_tuple(%Deck.Card{value: value, suit: suit}),
    do: {value, suit}

  defp values(), do: Enum.to_list(1..13)
  defp suits(), do: [:spades, :diamonds, :clubs, :hearts]
end
