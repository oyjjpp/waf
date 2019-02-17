--[[
--@desc:syslog library
--@author
--@date 2019-02-16
--]]

local ffi = require("ffi")

--log level
local LOG_EMERG = 0
local LOG_ALERT = 1
local LOG_CRIT = 2
local LOG_ERR = 3
local LOG_WARNING = 4
local LOG_NOTICE = 5
local LOG_INFO = 6
local LOG_DEBUG = 7

--log type
--kernel messages
local LOG_KERN = 0
--generic user-level messages
local LOG_USER = 8
--mail subsystem
local LOG_MAIL = 16

--security/authorization messages (private)
local LOG_LOCAL6 = 176


--syslog function
ffi.cdef[[
    void openlog(const char *ident, int option, int facility);
    void syslog(int priority, const char *format, ...);
    void closelog(void);
]]

--log type
local log_type = {
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
local log_level = {
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

local function writeLog(logMessage)
    ffi.C.openlog("PHP_BIZ_ERRLOG", 1, log_type["local6"])
    ffi.C.syslog(log_level["err"], " JSON:"..logMessage)
    ffi.C.closelog()
end

local logMessage = [[{"header":{"topic":"waf","key":"waf_log","rate":0,"interval":0,"url":"http:\/\/127.0.0.1\/index.php","time":1550224968,"logId":1550224968},"body":{"msg":"this is test message"}}]]
writeLog(logMessage)

return {
    openlog = openlog,
    syslog = syslog,
    closelog = closelog,
    log_type = log_type,
    log_level = log_level
}
