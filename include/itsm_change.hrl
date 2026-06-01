-ifndef(ITSM_CHANGE_HRL).
-define(ITSM_CHANGE_HRL, "itsm_change_hrl").

-record(itsm_change, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    req = [],           %% REQ ID
    service = [],       %% Service ID
    title = <<>>,
    description = <<>>,
    risk_level = low,   %% low, medium, high
    impact = low,       %% low, medium, high
    status = new,       %% new, accepted, under_analysis, planning, executing, closed
    change_manager = <<>>,
    backout_plan = <<>>
}).

-endif.
