defmodule Grimoire.FeedsTest do
  use Grimoire.DataCase

  alias Grimoire.Feeds

  describe "feeds" do
    alias Grimoire.Feeds.Feed

    import Grimoire.AccountsFixtures, only: [user_scope_fixture: 0]
    import Grimoire.FeedsFixtures

    @invalid_attrs %{name: nil}

    test "list_feeds/1 returns all scoped feeds" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)
      other_feed = feed_fixture(other_scope)
      assert Feeds.list_feeds(scope) == [feed]
      assert Feeds.list_feeds(other_scope) == [other_feed]
    end

    test "get_feed!/2 returns the feed with given id" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      other_scope = user_scope_fixture()
      assert Feeds.get_feed!(scope, feed.id) == feed
      assert_raise Ecto.NoResultsError, fn -> Feeds.get_feed!(other_scope, feed.id) end
    end

    test "create_feed/2 with valid data creates a feed" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Feed{} = feed} = Feeds.create_feed(scope, valid_attrs)
      assert feed.name == "some name"
      assert feed.user_id == scope.user.id
    end

    test "create_feed/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Feeds.create_feed(scope, @invalid_attrs)
    end

    test "update_feed/3 with valid data updates the feed" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Feed{} = feed} = Feeds.update_feed(scope, feed, update_attrs)
      assert feed.name == "some updated name"
    end

    test "update_feed/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)

      assert_raise MatchError, fn ->
        Feeds.update_feed(other_scope, feed, %{})
      end
    end

    test "update_feed/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Feeds.update_feed(scope, feed, @invalid_attrs)
      assert feed == Feeds.get_feed!(scope, feed.id)
    end

    test "delete_feed/2 deletes the feed" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      assert {:ok, %Feed{}} = Feeds.delete_feed(scope, feed)
      assert_raise Ecto.NoResultsError, fn -> Feeds.get_feed!(scope, feed.id) end
    end

    test "delete_feed/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      feed = feed_fixture(scope)
      assert_raise MatchError, fn -> Feeds.delete_feed(other_scope, feed) end
    end

    test "change_feed/2 returns a feed changeset" do
      scope = user_scope_fixture()
      feed = feed_fixture(scope)
      assert %Ecto.Changeset{} = Feeds.change_feed(scope, feed)
    end
  end
end
