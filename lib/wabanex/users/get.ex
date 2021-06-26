defmodule Wabanex.Users.Get do
  import Ecto.Query

  alias Wabanex.{User, Repo, Training}
  alias Ecto.UUID

  def call(id) do
    id
    |> UUID.cast()
    |> IO.inspect()
    |> handle_response()
  end

  defp handle_response(:error) do
    {:error, "Invalid UUID"}
  end

  defp handle_response({:ok, uuid}) do
    case Repo.get(User, uuid) do
      nil -> {:error, "User not found"}
      user -> {:ok, load_training(user)}
    end
  end

  defp load_training(user) do
    today = Date.utc_today()

    query =
      from train in Training,
        where: ^today >= train.start_date and ^today <= train.end_date

    Repo.preload(user, trainings: {first(query, :inserted_at), :exercises})
  end
end
