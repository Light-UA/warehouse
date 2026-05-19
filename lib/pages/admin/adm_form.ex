defmodule ADM.FORM do
  require N2O
  require NITRO
  require Logger
  require EXO

  def event({:client, {:form, mod, col_id}}) do
    :nitro.insert_bottom(
      col_id,
      NITRO.panel(
        class: "form-card",
        body: [
          NITRO.h3(body: :nitro.to_binary(mod)),
          NITRO.h5(body: mod.doc(), style: "margin-bottom: 10px;"),
          NITRO.panel(:form.new(mod.new(mod, mod.id(), []), mod.id()), class: :form)
        ]
      )
    )
  end

  def event(:init) do
    :nitro.clear(:stand)
    :nitro.insert_bottom(:stand, NITRO.panel(id: :col1, class: "form-column"))
    :nitro.insert_bottom(:stand, NITRO.panel(id: :col2, class: "form-column"))
    :nitro.insert_bottom(:stand, NITRO.panel(id: :col3, class: "form-column"))

    :application.get_env(:form, :registry, [])
    |> Enum.with_index()
    |> Enum.each(fn {mod, index} ->
      col_id =
        case rem(index, 3) do
          0 -> :col1
          1 -> :col2
          2 -> :col3
        end

      send(self(), {:client, {:form, mod, col_id}})
    end)
  end

  def event(x) do
    Logger.info("EVENT: #{inspect(x)}")

    case x do
      {evt, _} when evt in [:CreateClient, :TypeClient] ->
        Logger.info(
          "Client.Form fields: " <>
            "surnames=#{inspect(:nitro.q(:surnames_client_none))}, " <>
            "names=#{inspect(:nitro.q(:names_client_none))}, " <>
            "phone=#{inspect(:nitro.q(:phone_client_none))}, " <>
            "type=#{inspect(:nitro.q(:type_client_none))}"
        )

      {evt, _} when evt in [:CreateTariff, :TypeProgram] ->
        Logger.info(
          "Program.Form fields: " <>
            "name=#{inspect(:nitro.q(:name_program_none))}, " <>
            "type=#{inspect(:nitro.q(:type_program_none))}, " <>
            "date=#{inspect(:nitro.q(:date_program_none))}, " <>
            "formula=#{inspect(:nitro.q(:formula_program_none))}"
        )

      {evt, _} when evt in [:CreateAccount, :TypeAccount, :ProgramAccount] ->
        program_id = :nitro.q(:program_account_none)

        program_record =
          ~c"/exo/tariffs"
          |> :kvs.all()
          |> Enum.find(fn x ->
            :nitro.to_binary(EXO.program(x, :id)) ==
              :nitro.to_binary(program_id)
          end)

        Logger.info(
          "Account.Form fields: " <>
            "name=#{inspect(:nitro.q(:name_account_none))}, " <>
            "edrpou=#{inspect(:nitro.q(:edrpou_account_none))}, " <>
            "type=#{inspect(:nitro.q(:type_account_none))}, " <>
            "program=#{inspect(program_record)}, " <>
            "date=#{inspect(:nitro.q(:date_account_none))}"
        )

      {evt, _} when evt in [:Spawn, :Discard, :TypeProcess] ->
        Logger.info(
          "BPE.Create fields: " <>
            "process_type=#{inspect(:nitro.q(:process_type_process_none))}"
        )

      _ ->
        :ok
    end
  end
end
