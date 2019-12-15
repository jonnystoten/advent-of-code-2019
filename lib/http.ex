defmodule AdventOfCode.Http do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://adventofcode.com")

  plug(Tesla.Middleware.Headers, [
    {"cookie", "session=#{Application.get_env(:advent_of_code, :session)}"}
  ])

  def get_input(year, day) do
    with {:ok, response} <- get("/#{year}/day/#{day}/input") do
      response.body
      |> String.trim()
    end
  end
end
