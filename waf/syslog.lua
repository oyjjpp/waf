-- Created by IntelliJ IDEA.
-- User: ouyangjun
-- Date: 2019/2/19
-- Time: 17:28
-- To change this template use File | Settings | File Templates.
local ffi = require("ffi")
local json = require("json")
local socket = require("socket")

--syslog function
ffi.cdef[[
    void openlog(const char *ident, int option, int facility);
    void syslog(int priority, const char *format, ...);
    void closelog(void);
]]

--log type
local log_facility = {
    ["kern"] = 0,
    ["user"] = 8,
    ["mail"] = 16,
    ["daemon"] = 24,
    ["auth"] = 32,
    ["syslog"] = 40,
    ["lpr"] = 48,
    ["news"] = 56,
    ["uucp"] = 64,
    ["cron"] = 72,
    ["authoriv"] = 80,
    ["local0"] = 128,
    ["local1"] = 136,
    ["local2"] = 144,
    ["local3"] = 152,
    ["local4"] = 160,
    ["local5"] = 168,
    ["local6"] = 176,
    ["local7"] = 184,
}

--log level
local log_priority = {
    ["emerg"] = 0,
    ["alert"] = 1,
    ["crit"]  = 2,
    ["err"]   = 3,
    ["warning"] = 4,
    ["notice"] = 5,
    ["info"] = 6,
    ["debug"] = 7,
}

--rsyslog openlog function
local function openlog(ident, option, facility)
    ffi.C.openlog(ident, option, facility)
end

--rsyslog syslog function
local function syslog(priority,log)
    ffi.C.syslog(priority,log)
end

--rsyslog closelog function
local function closelog()
    ffi.C.closelog()
end

local function get_log_id()
    math.randomseed(os.time())
    local num = math.random()
    return string.sub(num,-10)
end

--rsyslog write_log function
local function write_log(header, body, level, log_type)
    header["rate"] = header["rate"] or 0
    header["interval"] = header["interval"] or 0
    header["time"] = os.date("%Y-%m-%d %H:%M:%S")
    header["logId"] = header["logId"] or get_log_id()

    local data = {
        ["header"] = header,
        ["body"] = body
    }

    local content = json.encode(data)
    openlog("PHP_BIZ_ERRLOG", 0, log_type)
    syslog(level, " JSON:"..content)
    closelog()
end

--rsyslog socket_log function
local function socket_log(facility, priority, header, body)
    header["rate"] = header["rate"] or 0
    header["interval"] = header["interval"] or 0
    header["time"] = os.date("%Y-%m-%d %H:%M:%S")
    header["logId"] = header["logId"] or get_log_id()

    local data = {
        ["header"] = header,
        ["body"] = body
    }

    local msg = "<" .. (facility + priority) .. ">" .. json.encode(data)

    local udp = socket.udp()
    local host = "127.0.0.1"
    local port = "2514"
    udp:sendto(msg, host, port)
    udp:close()
end

return {
    openlog = openlog,
    syslog = syslog,
    closelog = closelog,
    facility = log_facility,
    priority = log_priority,
    write_log = write_log,
    socket_log = socket_log
}

