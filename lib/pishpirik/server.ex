defmodule Pishpirik.Server do
  use GenServer
  alias Pishpirik.{Game, Deck}
  @name __MODULE__
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def battle(pid, this_card) do
    GenServer.call(pid, {:battle, this_card})
  end

  def read(pid) do
    Logger.debug("Server read(pid)")
    GenServer.call(pid, :read)
  end

  def init(list) do
    Logger.debug("Server init(:ok)")
    {:ok, load()}
  end

  def load() do
    Logger.debug("Server load()")

    deck = Deck.new()
    table_cards = Enum.take_random(deck, 4)
    cards = deck -- table_cards

    random_4_for_user = Enum.take_random(cards, 4)
    cards = cards -- random_4_for_user

    random_4_for_computer = Enum.take_random(cards, 4)
    cards = cards -- random_4_for_computer

    Logger.debug("Random 4 for table => #{inspect(table_cards)}")
    Logger.debug("Random 4 for user => #{inspect(random_4_for_user)}")
    Logger.debug("Random 4 for computer => #{inspect(random_4_for_computer)}")
    Logger.debug("ostatok => #{inspect(cards)}")
    Logger.debug("ostatok length #{inspect(length(cards))}")

    %Game{
      table_cards: table_cards |> Enum.map(&to_tuple/1),
      user_cards: random_4_for_user |> Enum.map(&to_tuple/1),
      status: "in progress",
      computer_cards: random_4_for_computer |> Enum.map(&to_tuple/1),
      cards: cards |> Enum.map(&to_tuple/1)
    }
  end

  defp to_tuple(%Deck.Card{value: value, suit: suit}),
    do: {value, suit}

  def handle_call(:read, _from, state) do
    Logger.debug("handle_call - :read")

    {:reply, state, state}
  end

  def handle_call(
        {:battle, _this_card},
        _from,
        %Game{
          user_cards: []
        } = state
      ) do
    Logger.debug("handle_call - :battle - finished won false")
    new_state = Map.merge(state, %{status: "finished", won: false})
    {:reply, "User loses", new_state}
  end

  def handle_call(
        :battle,
        _from,
        %Game{
          computer_cards: []
        } = state
      ) do
    Logger.debug("handle_call - :battle - finished won true")

    new_state = Map.merge(state, %{status: "finished", won: true})
    {:reply, "User wins", new_state}
  end

  def handle_call(
        {:battle, this_card},
        _from,
        %Game{
          user_cards: user_cards,
          computer_cards: [{computer_card, computer_card_suit} | computer_cards_rest],
          table_cards: table_cards,
          user_earned_cards: user_earned_cards,
          computer_earned_cards: computer_earned_cards,
          cards: cards
        } = state
      ) do
    Logger.debug("handle_call - :battle - round")
    Logger.debug("user_earned_cards ---> #{inspect(user_earned_cards)}")
    Logger.debug("cards ---> #{inspect(cards)}")

    Logger.debug("this_card => #{inspect(this_card)}")
    Logger.debug("user_cards => #{inspect(user_cards)}")

    table_card = if table_cards != [] do
      table_card = List.last(table_cards)
      {table_card, _table_card_suit} = table_card
      table_card
    end

    {this_card, this_card_suit} = this_card


    Logger.debug("this_card -> #{inspect(this_card)}")

    if computer_cards_rest == [] do
      Logger.debug("START NEW ROUND")
    end

    cond do
      # Enum.member?(user_cards, this_card) == false ->
      #   {:noreply, "Continue!", state}

      table_card == nil ->
        # Add Card when Table is empty
        new_state =
          Map.merge(state, %{
            table_cards: [{this_card, this_card_suit}, {computer_card, computer_card_suit}]
          })

          new_state= if user_cards -- [{this_card, this_card_suit}] == [] do
            Deck.deal(new_state, cards)
          else
              new_state
          end

        {:reply, "Continue!", new_state}


      this_card != table_card ->
        # Add Card when last card is not same as user card
        new_state =
          Map.merge(state, %{
            user_cards: user_cards -- [{this_card, this_card_suit}],
            computer_cards: computer_cards_rest,
            table_cards:
            table_cards ++ [{this_card, this_card_suit}, {computer_card, computer_card_suit}],
            computer_earned_cards: computer_earned_cards
          })

          new_state = if this_card == computer_card do
            Map.merge(new_state, %{
              user_cards: user_cards -- [{this_card, this_card_suit}],
              computer_cards: computer_cards_rest,
              computer_earned_cards: computer_earned_cards ++ table_cards ++ [{this_card, this_card_suit}, {computer_card, computer_card_suit}],
              table_cards: []
            })
          else
            new_state
          end
          new_state= if user_cards -- [{this_card, this_card_suit}] == [] do
            Deck.deal(new_state, cards)
          else
              new_state
          end

        {:reply, "Continue!", new_state}

      this_card == table_card ->
        # User card is equal with last table card
        # User earn all cards from table
        new_state =
          Map.merge(state, %{
            user_cards: user_cards -- [{this_card, this_card_suit}],
            computer_cards: computer_cards_rest,
            table_cards: [{computer_card, computer_card_suit}],
            user_earned_cards: user_earned_cards ++ table_cards ++ [{this_card, this_card_suit}]
          })

          new_state = if user_cards -- [{this_card, this_card_suit}] == [] do
            Deck.deal(new_state, cards)
          else
              new_state
          end

        {:reply, "Round won by user!", new_state}
    end
  end
end
