WMS: Weapon Management System
=============================

[![Hex pm](https://img.shields.io/hexpm/v/exosculat.svg?style=flat)](https://hex.pm/packages/exosculat)
[![Actions Status](https://github.com/erpuno/exo/workflows/mix/badge.svg)](https://github.com/erpuno/exo/actions)

WMS: Weapon Management System is an automated system for service accounting, rating, and billing.
WMS is a universal account manager (customer accounts) that contains a history of rated transactions.
Accounts are controlled by BPMN processes whose activities are defined by Erlang functions.
EXO, as an example of [ERP.UNO](https://erp.uno), can be used as a prototype for building billing systems, banks, and other accounting systems.

Getting Started
---------------

BPE (Business Process Engine) defines the infrastructure for orchestrating business processes according to the BPMN standard and declarative rule-based systems. BPE transactionally stores all steps of business processes in KVS, a modern RocksDB-based database system.

```
$ sudo apt install erlang elixir build-essential cmake
```

```
$ git clone https://github.com/erpuno/warehouse
$ cd warehouse
$ mix deps.get
$ iex -S mix
> EXO.boot
```

In parallel, open:

```
$ open http://localhost:8004/app/login.htm
```

This is an educational example of a preparatory course for interns, used to acquire skills in programming systems using the [N2O.DEV](https://n2o.dev/) libraries.

Educational Materials
---------------------

* [N2O FAQ](https://tonpa.guru/stream/2019/2019-07-31%20N2O%20FAQ.htm)
* [PhoenixFramework vs N2O](https://tonpa.guru/stream/2016/2016-01-29%20PhoenixFramework%20vs%20N2O.htm)
* [N2O Book](https://n2o.dev/ua/books/vol.2/index.html)
* [ERP Book](https://n2o.dev/ua/books/vol.3/index.html)
* [Web Framework Architecture and the EXO Example](https://tonpa.guru/stream/2022/2022-11-17%20%D0%A1%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%B0%20%D0%B2%D0%B5%D0%B1-%D1%84%D1%80%D0%B5%D0%B9%D0%BC%D0%B2%D0%BE%D1%80%D0%BA%D1%96%D0%B2.htm)

Contributors
------------

* Maxim Sokhatsky

