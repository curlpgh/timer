defmodule TimerWeb.UploadLogoComponent do
  use TimerWeb, :live_component

  alias Timer.Accounts

  require Logger

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Change the logo on the splash page.
      </.header>

      <h2 class="mt-3">Current Logo:</h2>
      <img src={TimerWeb.Uploaders.Logo.url({@current_user.logo, @current_user}, :logo)} class="h-20" />

      <div class="mt-3">
        <%= for entry <- @uploads.logo.entries do %>
          <%= for err <- upload_errors(@uploads.logo, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
          <div class="mb-5">
            <h2>Preview:</h2>
            <.live_img_preview entry={entry} class="object-contain h-40" />
          </div>
        <% end %>

        <div class="mt-5">
          <.form
            for={@changeset}
            id="upload-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <div phx-drop-target={@uploads.logo.ref} class="mb-5">
              <div class="h-120 p-10 mb-5 border bg-gray-100 rounded-lg text-center text-lg">
                Drag and drop the new logo here or browse to the image file
              </div>
            </div>

            <%= for err <- upload_errors(@uploads.logo) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>

            <.live_file_input upload={@uploads.logo} />

            <%= if length(@uploads.logo.entries) > 0 do %>
              <div class="mt-3">
                <.button phx-disable-with="Saving...">Upload</.button>
              </div>
            <% end %>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def update(%{current_user: current_user} = assigns, socket) do
    changeset = Accounts.change_logo(current_user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:uploaded_files, [])
      |> allow_upload(:logo,
        accept: ~w(.jpg .jpeg .gif .png),
        max_entries: 1,
        max_file_size: 12_000_000
      )

    {:ok, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    consume_uploaded_entries(socket, :logo, fn %{path: path}, entry ->
      # transform %Phoenix.LiveView.UploadEntry into %Plug.Upload and add to attributes so
      # waffle_ecto will save it
      attrs = %{
        "logo" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      }

      Accounts.update_logo(socket.assigns.current_user, attrs)
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Logo updated")
     |> push_redirect(to: socket.assigns.patch)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
