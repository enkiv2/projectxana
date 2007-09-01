#/usr/bin/env lua

io.write(string.gsub(io.read("*all"), "(\nversion%(GNU%) alias(.-)\n)", "\n"))

