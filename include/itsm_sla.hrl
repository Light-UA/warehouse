-ifndef(ITSM_SLA_HRL).
-define(ITSM_SLA_HRL, "itsm_sla_hrl").

-record(itsm_sla, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    service = [],       %% Service ID
    priority = low,     %% low, medium, high, critical
    response_time = 0,  %% in minutes
    resolution_time = 0,%% in minutes
    status = active
}).

-endif.
