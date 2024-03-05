defmodule TimerWeb.Uploaders.Logo do
  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  use Waffle.Ecto.Definition

  @versions [:original, :logo]

  # Only allow these extensions
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  # Define the logo transformation:
  def transform(:logo, _) do
    {:convert,
     "-background transparent -strip -thumbnail 100x100^ -gravity center -extent 110x110 -format png -alpha set",
     :png}
  end

  # Override the persisted filenames:
  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, %Timer.Accounts.User{} = user}) do
    "uploads/users/#{user.id}/logo"
  end

  def storage_dir(_version, {_file, user_id}) do
    "uploads/users/#{user_id}/logo"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(_version, _organization) do
    "/images/PCC-logo.png"
  end
end
