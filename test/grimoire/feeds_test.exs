defmodule Grimoire.FeedsTest do
  use Grimoire.DataCase

  alias Grimoire.Feeds
  alias Grimoire.Feeds.Feed

  import Grimoire.AccountsFixtures, only: [user_scope_fixture: 0]
  import Grimoire.FeedsFixtures

  describe "feeds" do
    @invalid_attrs %{name: nil}

    test "list/1 returns all scoped feeds" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)
      other_feed = feed_fixture(other_scope)

      assert Feeds.list(scope) == [feed]
      assert Feeds.list(other_scope) == [other_feed]
    end

    test "get!/2 returns the feed with given id" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      other_scope = user_scope_fixture()

      assert Feeds.get!(scope, feed.id) == feed
      assert_raise Ecto.NoResultsError, fn -> Feeds.get!(other_scope, feed.id) end
    end

    test "create/2 with valid data creates a feed" do
      valid_attrs = valid_feed_attrs()
      scope = user_scope_fixture()

      assert {:ok, %Feed{} = feed} = Feeds.create(scope, valid_attrs)
      assert feed.name == "some name"
      assert feed.user_id == scope.user.id
    end

    test "create/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} = Feeds.create(scope, @invalid_attrs)
    end

    test "update/3 with valid data updates the feed" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Feed{} = feed} = Feeds.update(scope, feed, update_attrs)
      assert feed.name == "some updated name"
    end

    test "update/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert_raise MatchError, fn ->
        Feeds.update(other_scope, feed, %{})
      end
    end

    test "update/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert {:error, %Ecto.Changeset{}} = Feeds.update(scope, feed, @invalid_attrs)
      assert feed == Feeds.get!(scope, feed.id)
    end

    test "delete/2 deletes the feed" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert {:ok, %Feed{}} = Feeds.delete(scope, feed)
      assert_raise Ecto.NoResultsError, fn -> Feeds.get!(scope, feed.id) end
    end

    test "delete/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert_raise MatchError, fn -> Feeds.delete(other_scope, feed) end
    end

    test "change/2 returns a feed changeset" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert %Ecto.Changeset{} = Feeds.change(scope, feed)
    end
  end
end
