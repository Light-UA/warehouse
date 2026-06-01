-ifndef(ITSM_SERVICE_HRL).
-define(ITSM_SERVICE_HRL, "itsm_service_hrl").

-record(itsm_service, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    name = <<>>,
    description = <<>>,
    status = active,    %% active, draft, inactive
    owner = <<>>,
    sla = []            %% SLA ID
}).

-endif.
