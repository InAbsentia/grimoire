defmodule GrimoireWeb.FeedLiveTest do
  use GrimoireWeb.ConnCase

  import Phoenix.LiveViewTest
  import Grimoire.FeedsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  defp create_feed(%{scope: scope}) do
    feed = feed_fixture(scope)

    %{feed: feed}
  end

  describe "Index" do
    setup [:create_feed]

    test "lists all feeds", %{conn: conn, feed: feed} do
      {:ok, _index_live, html} = live(conn, ~p"/feeds")

      assert html =~ "Listing Feeds"
      assert html =~ feed.name
    end

    test "saves new feed", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/feeds")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Feed")
               |> render_click()
               |> follow_redirect(conn, ~p"/feeds/new")

      assert render(form_live) =~ "New Feed"

      assert form_live
             |> form("#feed-form", feed: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#feed-form", feed: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/feeds")

      html = render(index_live)
      assert html =~ "Feed created successfully"
      assert html =~ "some name"
    end

    test "updates feed in listing", %{conn: conn, feed: feed} do
      {:ok, index_live, _html} = live(conn, ~p"/feeds")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#feeds-#{feed.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/feeds/#{feed}/edit")

      assert render(form_live) =~ "Edit Feed"

      assert form_live
             |> form("#feed-form", feed: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#feed-form", feed: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/feeds")

      html = render(index_live)
      assert html =~ "Feed updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes feed in listing", %{conn: conn, feed: feed} do
      {:ok, index_live, _html} = live(conn, ~p"/feeds")

      assert index_live |> element("#feeds-#{feed.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#feeds-#{feed.id}")
    end
  end

  describe "Show" do
    setup [:create_feed]

    test "displays feed", %{conn: conn, feed: feed} do
      {:ok, _show_live, html} = live(conn, ~p"/feeds/#{feed}")

      assert html =~ "Show Feed"
      assert html =~ feed.name
    end

    test "updates feed and returns to show", %{conn: conn, feed: feed} do
      {:ok, show_live, _html} = live(conn, ~p"/feeds/#{feed}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/feeds/#{feed}/edit?return_to=show")

      assert render(form_live) =~ "Edit Feed"

      assert form_live
             |> form("#feed-form", feed: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#feed-form", feed: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/feeds/#{feed}")

      html = render(show_live)
      assert html =~ "Feed updated successfully"
      assert html =~ "some updated name"
    end
  end
end
