defmodule Platform.BlogPostFactory do
  @moduledoc false

  alias Platform.Blog.Post

  defmacro __using__(_opts) do
    quote do
      def blog_post_factory do
        %Post{
          title: Faker.StarWars.planet(),
          content: Faker.StarWars.quote(),
          user: build(:blog_user)
        }
      end
    end
  end
end
