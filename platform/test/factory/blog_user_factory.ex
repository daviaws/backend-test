defmodule Platform.BlogUserFactory do
  @moduledoc false

  alias Platform.Blog.User

  defmacro __using__(_opts) do
    quote do
      def blog_user_factory do
        %User{
          displayName: Faker.Person.PtBr.name(),
          email: Faker.Internet.email(),
          image: Faker.Internet.image_url(),
          password: String.slice(Faker.Internet.user_name(), 0, 6)
        }
      end
    end
  end
end
