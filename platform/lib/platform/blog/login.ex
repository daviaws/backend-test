defmodule Platform.Blog.Login do
  import Ecto.Changeset

  alias Platform.Blog.User
  alias Platform.Repo

  @required [:email, :password]

  def changeset(attrs) do
    %User{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_email_is_filled(attrs)
    |> validate_password_is_filled(attrs)
  end

  def validate(attrs) do
    changeset = changeset(attrs)

    if changeset.valid? do
      user = Repo.get_by(User, email: changeset.changes.email)
      changeset = validate_email_registered(changeset, user)
      {user, changeset}
    else
      {nil, changeset}
    end
  end

  def validate_email_is_filled(changeset, attrs) do
    case Map.get(attrs, "email") do
      "" ->
        update_in(
          changeset.errors,
          &Enum.map(
            &1,
            fn {:email, {"can't be blank", [validation: :required]}} ->
              {:email, {"is not allowed to be empty", []}}
            end
          )
        )

      _ ->
        changeset
    end
  end

  def validate_password_is_filled(changeset, attrs) do
    case Map.get(attrs, "password") do
      "" ->
        update_in(
          changeset.errors,
          &Enum.map(
            &1,
            fn {:password, {"can't be blank", [validation: :required]}} ->
              {:password, {"is not allowed to be empty", []}}
            end
          )
        )

      _ ->
        changeset
    end
  end

  def validate_email_registered(changeset, user) do
    case user do
      %User{} -> changeset
      nil -> add_error(changeset, :message, "Campos inválidos")
    end
  end
end
