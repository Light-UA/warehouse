-ifndef(ITSM_CI_HRL).
-define(ITSM_CI_HRL, "itsm_ci_hrl").

-record(itsm_ci, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    name = <<>>,
    type = hardware,    %% hardware, software, network, doc
    status = active,    %% active, decommissioned, maintenance
    dependencies = [],  %% list of dependent CI IDs
    serial_number = <<>>,
    owner = <<>>
}).

-endif.
