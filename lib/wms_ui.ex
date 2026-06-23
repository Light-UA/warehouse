defmodule WMS.UI do
  require NITRO

  def show_error(target_id, message) do
    :nitro.clear(target_id)

    :nitro.insert_bottom(
      target_id,
      NITRO.panel(
        class: :validation_error,
        body: message
      )
    )
  end
end
