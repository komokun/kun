defmodule Kun.UserManager.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :kun,
    error_handler: Kun.UserManager.ErrorHandler,
    module: Kun.UserManager.Guardian

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource
end
