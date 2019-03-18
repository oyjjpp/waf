
local log = require("syslog")
header = {["topic"]="waf"}
body = {["message"]="this is test message"}
log.write_log(header, body, log.priority["info"],log.facility["local6"])

log.socket_log(log.facility["local5"], log.priority["info"], header, body)

function write(logfile,msg)
    local fd = io.open(logfile,"ab")
    if fd == nil then return end
    fd:write(msg)
    fd:flush()
    fd:close()
end

--local str = "waf_test_log this is a message "..os.time().."\r\n"
--write("/tmp/waf.log", str)
--write("/tmp/waf.log", "waf_test_log: this is a message too\r\n")
