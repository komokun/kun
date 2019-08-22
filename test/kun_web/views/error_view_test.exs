defmodule KunWeb.ErrorViewTest do
  use KunWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(KunWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "render 500.json" do
    assert render(KunWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "render any other" do
    assert render(KunWeb.ErrorView, "505.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
