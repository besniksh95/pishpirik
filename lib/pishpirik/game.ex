defmodule Pishpirik.Game do

  alias Pishpirik.Server

  defstruct user_id: :none,
            table_cards: [],
            user_cards: [],
            user_earned_cards: [],
            computer_cards: [],
            computer_earned_cards: [],
            status: :uninitialized,
            cards: []

  def new() do
    Server.start_link()
  end
end
