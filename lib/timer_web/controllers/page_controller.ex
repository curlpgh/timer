defmodule TimerWeb.PageController do
  use TimerWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
