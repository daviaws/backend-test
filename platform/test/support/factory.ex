defmodule Platform.Factory do
  @moduledoc """
  Configure test factories.
  """

  use ExMachina.Ecto, repo: Platform.Repo

  use Platform.BlogPostFactory
  use Platform.BlogUserFactory
end
