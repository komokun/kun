defmodule Kun.UserManagerTest do
  use Kun.DataCase

  alias Kun.UserManager

  describe "users" do
    alias Kun.UserManager.User

    @valid_attrs %{
      name: "some name",
      email: "some@email",
      password: "some password"
    }
    @update_attrs %{
      name: "some updated name",
      email: "updated@email",
      password: "some updated password"
    }

    def user_fixture(attrs \\ %{}) do
      attrs
      |> Enum.into(@valid_attrs)
      |> Kun.UserManager.create_user()
    end

    test "list_users/0 returns all users" do
      assert {:ok, user} = user_fixture()
      assert Kun.UserManager.list_users() == [user]
    end

    test "get_user/1 returns the user with given id" do
      assert {:ok, user} = user_fixture()
      assert Kun.UserManager.get_user(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, user} = user_fixture()
      assert user.name == "some name"
      assert user.email == "some@email"
      refute is_nil(user.password_hash)
      assert Comeonin.Argon2.checkpw("some password", user.password_hash)
    end

    test "create_user/1 requires a name" do
      assert {:error, changeset} = user_fixture(%{name: nil})
      assert "can't be blank" in errors_on(changeset).name

      assert {:error, changeset} = user_fixture(%{name: ""})
      assert "can't be blank" in errors_on(changeset).name
    end

    test "create_user/1 validates that name is at least 2 chars" do
      assert {:error, changeset} = user_fixture(%{name: "a"})
      assert "should be at least 2 character(s)" in errors_on(changeset).name
    end

    test "create_user/1 validates that name is at most 255 chars" do
      assert {:error, changeset} = user_fixture(%{name: long_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).name
    end

    test "create_user/1 requires an email" do
      assert {:error, changeset} = user_fixture(%{email: nil})
      assert "can't be blank" in errors_on(changeset).email

      assert {:error, changeset} = user_fixture(%{email: ""})
      assert "can't be blank" in errors_on(changeset).email
    end

    test "create_user/1 validates that email is at least 5 chars" do
      assert {:error, changeset} = user_fixture(%{email: "a"})
      assert "should be at least 5 character(s)" in errors_on(changeset).email
    end

    test "create_user/1 validates that email is at most 255 chars" do
      assert {:error, changeset} = user_fixture(%{email: long_string(256)})
      assert "should be at most 255 character(s)" in errors_on(changeset).email
    end

    test "create_user/1 validates that email contains the @ char" do
      assert {:error, changeset} = user_fixture(%{email: "abcde"})
      assert "has invalid format" in errors_on(changeset).email
    end

    test "update_user/2 with valid data updates the user" do
      {:ok, user} = user_fixture()
      assert {:ok, user} = Kun.UserManager.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "updated@email"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      {:ok, user} = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Kun.UserManager.update_user(user, %{name: nil})
      assert {:error, %Ecto.Changeset{}} = Kun.UserManager.update_user(user, %{name: ""})
      assert {:error, %Ecto.Changeset{}} = Kun.UserManager.update_user(user, %{email: nil})
      assert {:error, %Ecto.Changeset{}} = Kun.UserManager.update_user(user, %{email: ""})
      assert {:error, %Ecto.Changeset{}} = Kun.UserManager.update_user(user, %{email: "abcde"})
      assert user == Kun.UserManager.get_user(user.id)
    end

    test "update_user/2 doesn't change the password" do
      {:ok, user} = user_fixture()
      assert {:ok, user} = Kun.UserManager.update_user(user, @update_attrs)
      assert Comeonin.Argon2.checkpw("some password", user.password_hash)
    end

    test "delete_user/1 deletes the user" do
      {:ok, user} = user_fixture()
      assert {:ok, %User{}} = Kun.UserManager.delete_user(user)
      assert nil == Kun.UserManager.get_user(user.id)
    end

    test "change_user/1 returns a user changeset" do
      {:ok, user} = user_fixture()
      assert %Ecto.Changeset{} = Kun.UserManager.change_user(user)
    end

    test "change_user/1 doesn't modify the password" do
      {:ok, user} = user_fixture(%{password: "changed password"})
      changeset = Kun.UserManager.change_user(user)
      assert %Ecto.Changeset{} = changeset
      assert get_change(changeset, :password) == nil
    end

    test "authenticate/2 verifies the user exists" do
      {:ok, user} = user_fixture()
      {:ok, auth_user} = Kun.UserManager.authenticate(user.email, "some password")
      assert auth_user == user
    end

    test "authenticate/2 works correctly with no user provided" do
      assert :error = Kun.UserManager.authenticate("other@user", "some password")
    end
  end
end
