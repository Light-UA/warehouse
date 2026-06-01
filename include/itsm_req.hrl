-ifndef(ITSM_REQ_HRL).
-define(ITSM_REQ_HRL, "itsm_req_hrl").

-record(itsm_req, {
    id = kvs:seq([],[]),
    next = [],
    prev = [],
    initiator = <<>>,   %% client phone or ID
    service = <<>>,     %% service ID
    title = <<>>,
    description = <<>>,
    status = registered, %% registered, under_review, in_progress, resolved, closed, cancelled
    created_at = [],
    closed_at = []
}).

-endif.
