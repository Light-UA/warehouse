defmodule EXO.User do
   require EXO
   require NITRO

   def event(:init) do
       :nitro.clear(:frms)
       :nitro.clear(:ctrl)
       
       # Add Back button
       :nitro.insert_bottom(:ctrl,
          NITRO.link(id: :back_btn, body: "Назад до списку",
                     href: "domains.htm", class: [:button, :sgreen]))

       bin = :nitro.qc(:p)
       p = if is_binary(bin), do: bin, else: ""
       clients = :kvs.all('/exo/clients')
       client = Enum.find(clients, fn x -> :nitro.to_binary(EXO.client(x, :phone)) == p end)
       
       if is_nil(client) do
           :nitro.insert_bottom(:frms, NITRO.panel(body: "Користувача не знайдено."))
       else
           phone = EXO.client(client, :phone)
           names = EXO.client(client, :names)
           surnames = EXO.client(client, :surnames)
           type = EXO.client(client, :type)
           status = EXO.client(client, :status)
           date = EXO.client(client, :date)

           details = [
               NITRO.panel(class: :td, style: "padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;", body: [
                   NITRO.panel(style: "font-weight: bold; width: 150px;", body: "ПІБ:"),
                   NITRO.panel(body: names <> " " <> surnames)
               ]),
               NITRO.panel(class: :td, style: "padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;", body: [
                   NITRO.panel(style: "font-weight: bold; width: 150px;", body: "Телефон:"),
                   NITRO.panel(body: :nitro.to_binary(phone))
               ]),
               NITRO.panel(class: :td, style: "padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;", body: [
                   NITRO.panel(style: "font-weight: bold; width: 150px;", body: "Тип споживача:"),
                   NITRO.panel(body: :nitro.to_binary(type))
               ]),
               NITRO.panel(class: :td, style: "padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;", body: [
                   NITRO.panel(style: "font-weight: bold; width: 150px;", body: "Статус:"),
                   NITRO.panel(body: :nitro.to_binary(status))
               ]),
               NITRO.panel(class: :td, style: "padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;", body: [
                   NITRO.panel(style: "font-weight: bold; width: 150px;", body: "Дата реєстрації:"),
                   NITRO.panel(body: :nitro.compact(date))
               ])
           ]
           :nitro.insert_bottom(:frms, NITRO.panel(class: :table, style: "background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); overflow: hidden; max-width: 500px; margin-top: 20px;", body: details))
       end
   end

   def event(_), do: :ok
end
