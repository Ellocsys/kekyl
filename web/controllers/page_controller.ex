defmodule Kekyl.PageController do
  use Kekyl.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
