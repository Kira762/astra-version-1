local network = {}
network.__index = network

export type RequestFn = (...any) -> any

function network.getRequestFn(a2: any?): RequestFn?
    a2 = a2 or getfenv()
    return a2.request
        or a2.http_request
        or (a2.http and a2.http.request)
        or (a2.syn and a2.syn.request)
        or (a2.fluxus and a2.fluxus.request)
end

return network
