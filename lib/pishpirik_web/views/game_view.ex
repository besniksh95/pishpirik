defmodule PishpirikWeb.GameView do
  use PishpirikWeb, :view
  require Logger

  def render_card({value, suit}) do
    "/images/playing_cards/#{value}_of_#{suit}.png"
  end

  def card_to_map({value, suit}) do
    Logger.debug "CARDDDDDD ---- #{inspect value}"

    value
  end
end
