defmodule TimerWeb.GameLive.FormComponent do
  use TimerWeb, :live_component

  alias Timer.Clock

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage game timers in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="game-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:sheet]} type="text" label="Name" />
        <.input field={@form[:count_down_minutes]} type="number" label="Count down minutes" />
        <.input field={@form[:number_of_ends]} type="number" label="Number of ends" />
        <.input field={@form[:warning_minutes]} type="number" label="Warning minutes" />
        <span class="text-sm">
          Color changes when this many minutes are left
        </span>
        <.input field={@form[:display_ends]} type="checkbox" label="Display end they should be on" />
        <.input field={@form[:finish_extension]} type="number" label="Finish extension" />
        <span class="text-sm">
          Finish the end being played and play this many more when timer runs out
        </span>
        <.input field={@form[:start_minute]} type="number" label="Start minute" />
        <span class="text-sm">
          Adjust the start minute if a delay is needed
        </span>
        <.input field={@form[:pause]} type="checkbox" label="Pause the timer" />
        <span class="text-sm">
          The timer will start in pause mode
        </span>
        <.input field={@form[:default_game]} type="checkbox" label="Default timer" />
        <span class="text-sm">
          This is the timer that will be displayed on system start
        </span>
        <:actions>
          <.button phx-disable-with="Saving...">Save Timer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{game: game} = assigns, socket) do
    changeset = Clock.change_game(game)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"game" => game_params}, socket) do
    game_params = Map.merge(game_params, %{"user_id" => socket.assigns.current_user.id})

    changeset =
      socket.assigns.game
      |> Clock.change_game(game_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    game_params = Map.merge(game_params, %{"user_id" => socket.assigns.current_user.id})
    save_game(socket, socket.assigns.action, game_params)
  end

  defp save_game(socket, :edit, game_params) do
    case Clock.update_game(socket.assigns.current_user, socket.assigns.game, game_params) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> put_flash(:info, "Game updated successfully")
         |> push_redirect(to: socket.assigns.patch, replace: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_game(socket, :new, game_params) do
    case Clock.create_game(socket.assigns.current_user, game_params) do
      {:ok, game} ->
        notify_parent({:saved, game})

        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
