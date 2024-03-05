# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Timer.Repo.insert!(%Timer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create a user for local use without authenication
case Timer.Repo.get_by(Timer.Accounts.User, email: "timer@timer.com") do
  nil ->
    user_params = %{
      "email" => "timer@timer.com",
      "password" => Application.get_env(:timer, :timer_user_password)
    }

    {:ok, user} = Timer.Accounts.register_user(user_params)
    Timer.Repo.update!(Timer.Accounts.User.confirm_changeset(user))

  user ->
    user
end
