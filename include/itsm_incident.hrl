-ifndef(ITSM_INCIDENT_HRL).
-define(ITSM_INCIDENT_HRL, "itsm_incident_hrl").

-record(itsm_incident, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    req = [],           %% REQ ID
    service = [],       %% Service ID
    priority = low,     %% low, medium, high, critical
    status = new,       %% new, accepted, in_progress, escalated, resolved, closed
    assignee = <<>>,    %% user/admin id
    description = <<>>,
    resolution = <<>>,
    slm_deadline = []
}).

-endif.
