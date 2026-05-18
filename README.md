EXO: Exosculat Exoskeleton
==========================

[![Hex pm](https://img.shields.io/hexpm/v/exosculat.svg?style=flat)](https://hex.pm/packages/exosculat)
[![Actions Status](https://github.com/erpuno/exo/workflows/mix/badge.svg)](https://github.com/erpuno/exo/actions)

EXO (EXOSCULAT, Latin for "account") is an automated system for service accounting, rating, and billing.
EXO is a universal account manager (customer accounts) that contains a history of rated transactions.
Accounts are controlled by BPMN processes whose activities are defined by Erlang functions.
EXO, as an example of [ERP.UNO](https://erp.uno), can be used as a prototype for building billing systems, banks, and other accounting systems.

Getting Started
---------------

BPE (Business Process Engine) defines the infrastructure for orchestrating business processes according to the BPMN standard and declarative rule-based systems. BPE transactionally stores all steps of business processes in KVS, a modern RocksDB-based database system.

```
$ sudo apt install erlang elixir build-essential cmake
```

```
$ git clone https://github.com/erpuno/exo
$ cd exo
$ mix deps.get
$ iex -S mix
> EXO.boot
```

In parallel, open:

```
$ open http://localhost:8004/app/login.htm
```

This is an educational example of a preparatory course for interns, used to acquire skills in programming systems using the [N2O.DEV](https://n2o.dev/) libraries.

Project Structure
-----------------

* Login Page
* Admin: BPE, FORM, KVS, N2O, MNESIA
* Back-office: Reports, Tariffs, Roles
* Consumer Panel: Profile, Consumption, Services

### Static HTML Containers for Consumer

* [profile.htm](priv/static/consumer/profile.htm) Consumer account
* [consume.htm](priv/static/consumer/consume.htm) Service consumption
* [service.htm](priv/static/consumer/service.htm) Service settings and tariffs

### Static HTML Containers for Back-Office

* [reports.htm](priv/static/backoffice/reports.htm) Reports
* [tariffs.htm](priv/static/backoffice/tariffs.htm) Tariff models
* [domains.htm](priv/static/backoffice/domains.htm) Role model

### Static HTML Containers for Admin

* [login.htm](priv/static/admin/login.htm) Login page
* [bpe.htm](priv/static/admin/bpe.htm) All processes page
* [form.htm](priv/static/admin/form.htm) All forms page
* [process.htm](priv/static/admin/process.htm) Process history page
* [kvs.htm](priv/static/admin/kvs.htm) All data chains page
* [n2o.htm](priv/static/admin/n2o.htm) N2O service utility tables page
* [mnesia.htm](priv/static/admin/mnesia.htm) MNESIA database tables page

### Core Modules

* [application.ex](lib/application.ex) Main Erlang/OTP application module
* [schema.ex](lib/schema.ex) Data schema and its configuration
* [routes.ex](lib/routes.ex) Web server HTML route configuration
* [boot.ex](lib/boot.ex) Initial seed of test data

### Form Editors

* [phone_form.ex](lib/forms/phone_form.ex) Authentication form
* [process_form.ex](lib/forms/admin/process_form.ex) Process creation form
* [process_row.ex](lib/forms/admin/process_row.ex) Table row form for process display
* [hist_row.ex](lib/forms/admin/hist_row.ex) Table row form for process step display

### Page Controllers

* [adm_act.ex](lib/pages/admin/adm_act.ex) Process history page controller
* [adm_bpe.ex](lib/pages/admin/adm_bpe.ex) BPE processes list page controller
* [adm_form.ex](lib/pages/admin/adm_form.ex) FORM system forms page controller
* [adm_kvs.ex](lib/pages/admin/adm_kvs.ex) KVS data page controller
* [adm_n2o.ex](lib/pages/admin/adm_n2o.ex) N2O tables page controller
* [adm_mnesia.ex](lib/pages/admin/adm_mnesia.ex) MNESIA data page controller
* [exo_login.ex](lib/pages/exo_login.ex) Authentication page controller
* [exo_tariffs.ex](lib/pages/exo_tariffs.ex) Tariff models configuration page controller
* [exo_domains.ex](lib/pages/exo_domains.ex) System users administration page controller
* [exo_service.ex](lib/pages/exo_service.ex) Consumer service subscription page controller

Authentication
--------------

The authentication and authorization page, along with system sessions, is an important part of every ERP system.
This example provides a PLAIN password HTML form with "1" and "3" working passwords for admin and consumer respectively.

![image](priv/static/img/users.png)

Processes
---------

A page listing BPE processes of the ERP system and a form to create them.

![image](priv/static/img/processes.png)

Forms
-----

A page listing all forms of the ERP system.

![image](priv/static/img/forms.png)

Transactions
------------

A page showing the history of BPE business process steps.

![image](priv/static/img/process-instance.png)

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
