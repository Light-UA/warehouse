defmodule ADM.FORM do
   require N2O
   require NITRO

   def event({:client, {:form, mod, col_id}}) do
       :nitro.insert_bottom(col_id, NITRO.panel(
           class: "form-card",
           body: [
               NITRO.h3(body: :nitro.to_binary(mod)),
               NITRO.h5(body: mod.doc(), style: "margin-bottom: 10px;"),
               NITRO.panel(:form.new(mod.new(mod,mod.id(),[]), mod.id()), class: :form)
           ]
       ))
   end

   def event(:init) do
       :nitro.clear(:stand)
       :nitro.insert_bottom(:stand, NITRO.panel(id: :col1, class: "form-column"))
       :nitro.insert_bottom(:stand, NITRO.panel(id: :col2, class: "form-column"))
       :nitro.insert_bottom(:stand, NITRO.panel(id: :col3, class: "form-column"))

       :application.get_env(:form, :registry, [])
       |> Enum.with_index()
       |> Enum.each(fn {mod, index} ->
           col_id = case rem(index, 3) do
               0 -> :col1
               1 -> :col2
               2 -> :col3
           end
           send(self(), {:client, {:form, mod, col_id}})
       end)
   end

   def event(_), do: :ok

end
