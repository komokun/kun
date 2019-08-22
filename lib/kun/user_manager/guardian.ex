defmodule Kun.UserManager.Guardian do
  use Guardian, otp_app: :kun

  alias Kun.UserManager
  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case UserManager.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
