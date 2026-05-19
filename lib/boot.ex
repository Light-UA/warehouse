defmodule EXO.Boot do
  require EXO

  def clients() do
    [] = :kvs.all(~c"/exo/clients")
    date = :calendar.now_to_datetime(:erlang.timestamp())
    ids = :lists.map(fn x-> :timer.sleep(1) ; :kvs.seq([],[]) end, :lists.seq(1,6))
    sample = [
      EXO.client(
        id: :lists.nth(1,ids),
        names: "Максим",
        phone: "1",
        surnames: "Сохацький",
        type: :admin,
        status: :online,
        date: date
      ),
      EXO.client(
        id: :lists.nth(2,ids),
        names: "Антон",
        phone: "2",
        surnames: "Волошко",
        type: :admin,
        status: :online,
        date: date
      ),
      EXO.client(
        id: :lists.nth(3,ids),
        names: "МВС",
        phone: "3",
        surnames: "",
        type: :consumer,
        status: :online,
        date: date
      ),
      EXO.client(
        id: :lists.nth(4,ids),
        names: "ГСЦ",
        phone: "4",
        surnames: "",
        type: :consumer,
        status: :online,
        date: date
      ),
      EXO.client(
        id: :lists.nth(5,ids),
        names: "ЦІТ",
        phone: "5",
        surnames: "",
        type: :consumer,
        status: :online,
        date: date
      ),
      EXO.client(
        id: :lists.nth(6,ids),
        names: "ДНДІ",
        phone: "6",
        surnames: "",
        type: :consumer,
        status: :online,
        date: date
      )
    ]

    :lists.map(fn x -> :kvs.append(x, ~c"/exo/clients") end, sample)
  end

  def programs() do
    [] = :kvs.all(~c"/exo/tariffs")
    date = :calendar.now_to_datetime(:erlang.timestamp())

    sample = [
      EXO.program(id: :kvs.seq([], []), name: "БАЗОВИЙ", type: :internet, date: date),
      EXO.program(id: :kvs.seq([], []), name: "СТАНДАРТ", type: :internet, date: date),
      EXO.program(id: :kvs.seq([], []), name: "РОЗРИШЕНИЙ", type: :internet, date: date),
      EXO.program(id: :kvs.seq([], []), name: "БАЗОВИЙ", type: :electricity, date: date),
      EXO.program(id: :kvs.seq([], []), name: "СТАНДАРТ", type: :electricity, date: date),
      EXO.program(id: :kvs.seq([], []), name: "РОЗРИШЕНИЙ", type: :electricity, date: date),
      EXO.program(id: :kvs.seq([], []), name: "БАЗОВИЙ", type: :gas, date: date),
      EXO.program(id: :kvs.seq([], []), name: "СТАНДАРТ", type: :gas, date: date),
      EXO.program(id: :kvs.seq([], []), name: "РОЗРИШЕНИЙ", type: :gas, date: date),
      EXO.program(id: :kvs.seq([], []), name: "БАЗОВИЙ", type: :oil, date: date),
      EXO.program(id: :kvs.seq([], []), name: "СТАНДАРТ", type: :oil, date: date),
      EXO.program(id: :kvs.seq([], []), name: "РОЗРИШЕНИЙ", type: :oil, date: date)
    ]

    :lists.map(fn x -> :kvs.append(x, ~c"/exo/tariffs") end, sample)
  end
end
