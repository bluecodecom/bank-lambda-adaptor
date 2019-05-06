defmodule BluecodeConnectorWeb.Clearing.PaymentController do
  use BluecodeConnectorWeb, :controller

  def create(conn, params) do
    IO.puts ~s(\n\n!!! params: #{inspect params}\n)
  end
end
