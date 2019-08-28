defmodule Kun.UserManager do
  @moduledoc """
  The UserManager context.
  """

  import Ecto.Query, warn: false
  alias Kun.Repo

  alias Kun.UserManager.User

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def create_user(attrs \\ %{}) do
    result =
      %User{}
      |> User.registration_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, user} -> {:ok, %User{user | password: nil}}
      _ -> result
    end
  end

  @spec update_user(
          Toltec.Accounts.User.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec change_user(Kun.UserManager.User.t()) :: Ecto.Changeset.t()
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  require Logger
  def authenticate(email, password) do
    user = Repo.get_by(User, email: String.downcase(email))

    case check_password(user, password) do
      true -> {:ok, user}
      _ -> {:error, "Failed to authenticate."}
    end
  end

  def authenticate(_), do: :error

  defp check_password(user, password) do
    case user do
      nil -> Comeonin.Argon2.dummy_checkpw()
      _ -> Comeonin.Argon2.checkpw(password, user.password_hash)
    end
  end




end
