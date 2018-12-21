local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"

local wsLinkArr = {}
local handler = {}
function handler.on_open(ws)
    print(string.format("%d::open", ws.id))
    table.insert(wsLinkArr, ws)
end

function handler.on_message(ws, message)
    print(string.format("%d receive:%s", ws.id, message))
    -- ws:send_text(message)
    -- ws:close()
    -- for i=1, #wsLinkArr do
    --     wsLinkArr[i]:send_text(message)
    -- end

    -- 将玩家的操作数据保存，下一帧发送下去
end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
    for i=1, #wsLinkArr do
        if wsLinkArr[i] == ws then 
            table.remove(wsLinkArr, i)
            break
        end
    end
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        if header.upgrade == "websocket" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end
end

skynet.start(function()
    local address = "0.0.0.0:8001"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
end)
