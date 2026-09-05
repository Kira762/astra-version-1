local a1 = {}
a1.__index = a1

export type RequestFn = (...any) -> any

function a1.getRequestFn(a2: any?): RequestFn?
    a2 = a2 or getfenv()
    return a2.request
        or a2.http_request
        or (a2.http and a2.http.request)
        or (a2.syn and a2.syn.request)
        or (a2.fluxus and a2.fluxus.request)
end

return a1
