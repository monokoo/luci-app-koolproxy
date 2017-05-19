local o="koolproxy"
local i=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local a,t,e
arg[1]=arg[1]or""
a=Map(o,translate("koolproxy Rule Config"))
a.redirect=i.build_url("admin","services","koolproxy")
t=a:section(NamedSection,arg[1],"source","")
t.addremove=false
t.dynamic=false
e=t:option(Flag,"enabled",translate("Enabled"))
e.rmempty=false
e=t:option(Value,"kp_desc",translate("Rule Description"))
e.rmempty=false
e=t:option(Value,"kp_url",translate("Rule Address"))
e.rmempty=false
return a
