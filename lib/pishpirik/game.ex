defmodule Pishpirik.Game do

  alias Pishpirik.Server

  defstruct user_id: :none,
            table_cards: [],
            user_cards: [],
            computer_cards: [],
            status: :uninitialized

  def new(id) do
    Server.start_link(id)
  end
end
