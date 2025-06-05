defmodule Grimoire.Feeds.FeedTest do
  use Grimoire.DataCase, async: true

  alias Ecto.UUID
  alias Grimoire.Feeds.Feed

  import Grimoire.FeedsFixtures

  describe "changeset/3" do
    test "validates required fields" do
      scope = user_scope()
      valid_changeset = Feed.changeset(%Feed{}, valid_feed_attrs(), scope)
      invalid_changeset = Feed.changeset(%Feed{}, %{}, scope)
      errors = errors_on(invalid_changeset)

      assert valid_changeset.valid?
      refute invalid_changeset.valid?
      assert "can't be blank" in errors.name
      assert "can't be blank" in errors.source_type
      assert "can't be blank" in errors.source_url
    end

    test "sets user_id from scope" do
      user_id = UUID.generate()
      changeset = Feed.changeset(%Feed{}, valid_feed_attrs(), user_scope(user_id))

      assert get_change(changeset, :user_id) == user_id
    end

    test "rejects invalid value for source_type" do
      changeset = Feed.changeset(%Feed{}, %{source_type: :blah}, user_scope())

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).source_type
    end

    test "casts source_url to URI struct" do
      changeset = Feed.changeset(%Feed{}, valid_feed_attrs(), user_scope())

      assert %URI{} = get_change(changeset, :source_url)
    end

    for {name, url} <- [
          {"no scheme", "example.com"},
          {"invalid scheme", "htt://example.com"},
          {"unsupported scheme", "gopher://example.com"}
        ] do
      @tag url: url
      test "validates source_url scheme with #{name}", %{url: url} do
        attrs = valid_feed_attrs(%{source_url: url})

        changeset = Feed.changeset(%Feed{}, attrs, user_scope())

        assert "scheme must be http or https" in errors_on(changeset).source_url
      end
    end

    for {name, url} <- [
          {"no TLD", "http://example/"},
          {"an invalid character", "http://exam_ple.com"},
          {"a hyphen as the first character", "http://-example.com"},
          {"a hyphen as the last character", "http://example-.com"},
          {"a too-long host",
           "http://aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc.ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.com"},
          {"a too-long label",
           "http://www.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com"}
        ] do
      @tag url: url
      test "validates source_url host with #{name}", %{url: url} do
        attrs = valid_feed_attrs(%{source_url: url})

        changeset = Feed.changeset(%Feed{}, attrs, user_scope())

        assert "host is invalid" in errors_on(changeset).source_url
      end
    end

    test "validates soure_url has a path" do
      attrs = valid_feed_attrs(%{source_url: "http://example.com"})

      changeset = Feed.changeset(%Feed{}, attrs, user_scope())

      assert "path can't be blank" in errors_on(changeset).source_url
    end
  end

  defp user_scope(id \\ UUID.generate()), do: %{user: %{id: id}}
end
