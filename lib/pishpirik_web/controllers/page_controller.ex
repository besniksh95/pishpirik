defmodule PishpirikWeb.PageController do
  use PishpirikWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
