defmodule PishpirikWeb.GameController do
  use PishpirikWeb, :controller
  # alias Pishpirik.Repo
  alias Pishpirik.{Game, Server}
  require Logger

  # def index(conn, _params) do
  #   games = GamePlay.list_games()
  #   render(conn, "index.html", games: games)
  # end

  def new(conn, _params) do
    Logger.debug("CONN battle ---> #{inspect(conn)}")

    case Game.new(Enum.random(1..100)) do
      {:ok, pid} ->
        %Game{
          user_cards: user_cards,
          computer_cards: computer_cards,
          status: status,
          table_cards: table_cards
        } = Server.read(pid)


        Logger.debug("PIDDDDDDDDDDDDDD ---> #{inspect(pid)}")

        Logger.debug("user_cards --> #{inspect(user_cards)}")

        conn
        |> put_session(:game, pid)
        |> render("new.html",
          user_cards: user_cards,
          computer_cards: computer_cards,
          table_cards: table_cards,
          status: status,
          user_points: 0,
          computer_points: 0
        )

      {:error, {:already_started, pid}} ->
        %Game{user_cards: user_hand, computer_cards: comp_hand, status: status} = Server.read(pid)

        conn
        |> render("new.html", user_hand: user_hand, comp_hand: comp_hand, status: status)
    end
  end

  def battle(conn, params) do
    Logger.debug("CONN battle ---> #{inspect(conn)}")
    Logger.debug("Battle Called ---- params ---- #{inspect(params)}")
    card = {String.to_integer(params["value"]), String.to_atom(params["suit"])}
    pid = Map.get(conn.private, :plug_session)["game"]

    Logger.debug "BATTLE PID -> #{inspect pid}"

    case Server.battle(pid, card) do
      "Continue!" ->
        %Game{
          user_cards: user_cards,
          computer_cards: computer_cards,
          table_cards: table_cards,
          status: status,
          user_earned_cards: user_earned_cards,
          computer_earned_cards: computer_earned_cards
        } = Server.read(pid)

        conn
        |> put_flash(:error, "Continue")
        |> render("new.html",
          user_cards: user_cards,
          computer_cards: computer_cards,
          table_cards: table_cards,
          status: status,
          user_points: length(user_earned_cards),
          computer_points: length(computer_earned_cards)
        )

        "Round won by user!" ->
          %Game{
            user_cards: user_cards,
            computer_cards: computer_cards,
            table_cards: table_cards,
            status: status,
            user_earned_cards: user_earned_cards,
            computer_earned_cards: computer_earned_cards
          } = Server.read(pid)

          conn
          |> put_flash(:error, "Round won by user!")
          |> render("new.html",
            user_cards: user_cards,
            computer_cards: computer_cards,
            table_cards: table_cards,
            status: status,
            user_points: length(user_earned_cards),
            computer_points: length(computer_earned_cards)
          )
    end
  end

  # def create(conn, _) do
  #   changeset =
  #     conn.assigns[:current_user]
  #     |> Ecto.build_assoc(:games)
  #   case Repo.insert(changeset) do
  #     {:ok, game} ->
  #       {:ok, pid} = Game.new(game.id)
  #       %Game{user_cards: user_hand, computer_cards: comp_hand, status: status} =
  #       Server.read(pid)
  #       conn
  #       |> put_session(:game, game)
  #       |> render("show.html", user_hand: user_hand, comp_hand: comp_hand, status: status)
  #     {:error, changeset} ->
  #       render(conn, "new.html", changeset: changeset)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   game = GamePlay.get_game!(id)

  #   render(conn, "show.html", game: game)
  # end

  # def edit(conn, %{"id" => id}) do
  #   game = GamePlay.get_game!(id)
  #   changeset = GamePlay.change_game(game)
  #   render(conn, "edit.html", game: game, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "game" => game_params}) do
  #   game = GamePlay.get_game!(id)

  #   case GamePlay.update_game(game, game_params) do
  #     {:ok, game} ->
  #       conn
  #       |> put_flash(:info, "Game updated successfully.")
  #       |> redirect(to: game_path(conn, :show, game))
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", game: game, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   game = GamePlay.get_game!(id)
  #   {:ok, _game} = GamePlay.delete_game(game)

  #   conn
  #   |> put_flash(:info, "Game deleted successfully.")
  #   |> redirect(to: game_path(conn, :index))
  # end
end
