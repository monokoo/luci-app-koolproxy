local a=require"nixio.fs"
local e=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local e=luci.model.uci.cursor()
local n=require"luci.sys"
local d=luci.http
local s="koolproxy"
local o,t,e
local i=luci.sys.exec("/usr/share/koolproxy/koolproxy -v")
local c=luci.sys.exec("head -3 /usr/share/koolproxy/data/rules/koolproxy.txt 2>/dev/null|sed -n 3p| awk -F' ' '{print $3,$4}'")
local r=luci.sys.exec("head -4 /usr/share/koolproxy/data/rules/koolproxy.txt 2>/dev/null|sed -n 4p| awk -F' ' '{print $3,$4}'")
local u=luci.sys.exec("grep -v !x /usr/share/koolproxy/data/rules/koolproxy.txt 2>/dev/null| wc -l")
local h=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/user.txt 2>/dev/null| wc -l")
local j=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/daily.txt 2>/dev/null| wc -l")
local abp=luci.sys.exec("head -4 /usr/share/koolproxy/data/rules/easylistchina.txt 2>/dev/null|sed -n 3p| awk -F' ' '{print $3,$4}'")
local abpcount=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/easylistchina.txt 2>/dev/null| wc -l")
local cf=luci.sys.exec("head -4 /usr/share/koolproxy/data/rules/chengfeng.txt 2>/dev/null|sed -n 3p| awk -F' ' '{print $3,$4}'")
local cfcount=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/chengfeng.txt 2>/dev/null| wc -l")
local fboy=luci.sys.exec("head -4 /usr/share/koolproxy/data/rules/fanboy.txt 2>/dev/null|sed -n 4p| awk -F' ' '{print $3,$4}'")
local fboycount=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/fanboy.txt 2>/dev/null| wc -l")
local k=luci.sys.exec("head -3 /usr/share/koolproxy/data/rules/daily.txt 2>/dev/null|sed -n 3p| awk -F' ' '{print $3,$4}'")
o=Map(s,translate("koolproxy"),translate("A powerful advertisement blocker. <br /><font color=\"red\">Adblock Plus Host list + koolproxy Blacklist mode runs without loss of bandwidth due to performance issues.<br /></font>"))
o.apply_on_parse=true
o.template="koolproxy/index"
t=o:section(TypedSection,"global",translate("Running Status"))
t.anonymous=true
e=t:option(DummyValue,"_status",translate("Transparent Proxy"))
e.template="koolproxy/dvalue"
e.value=translate("Collecting data...")
t=o:section(TypedSection,"global",translate("Global Setting"))
t.anonymous=true
t.addremove=false
t:tab("base",translate("Basic Settings"))
t:tab("cert",translate("Certificate Management"))
t:tab("weblist",translate("Set Blacklist Of Websites"))
t:tab("iplist",translate("Set Blacklist Of IP"))
t:tab("customlist",translate("Set Blacklist Of custom"))
t:tab("about",translate("About Koolproxy"))
t:tab("logs",translate("View the logs"))
e=t:taboption("base",Flag,"enabled",translate("Enable"))
e.default=0
e.rmempty=false
e=t:taboption("base",ListValue,"filter_mode",translate('Default')..translate("Filter Mode"))
e.default="blacklist"
e.rmempty=false
e:value("disable",translate("No Filter"))
e:value("global",translate("Global Filter"))
e:value("globalWithHttps",translate("Global Filter With HTTPS"))
e:value("adblock",translate("Blacklist Filter"))
e:value("adblockWithHttps",translate("Blacklist Filter With HTTPS"))
e:value("fullport",translate("Full Port Filter"))
e=t:taboption("base",Value,"portEx",translate("Exception Port"),translate("全端口模式时可排除指定端口，可输入一个或多个端口（例如“80”或者“80,443”），不含引号。"))
e.placeholder="留空表示全端口过滤"
e=t:taboption("base",Flag,"kp_online_rules",translate("Default Rule"))
e.default=1
e=t:taboption("base",MultiValue,"kp_third_rules",translate("ThirdParty Rules"))
e:value("kp_video_rules",translate("Video Rule"))
e:value("kp_easylist_rules",translate("ABP Rule"))
e:value("kp_abx_rules",translate("ChengFeng Rule"))
e:value("kp_fanboy_rules",translate("Fanboy Rule"))
e=t:taboption("base",Flag,"third_rule_update",translate("Auto Update  Rules"),translate("一般情况下程序会自动更新规则文件！"))
e.default=0
e=t:taboption("base",ListValue,"time_update",translate("Timing update rules"))
for t=0,23 do
e:value(t,translate("每天"..t.."点"))
end
e.default=4
e:depends("third_rule_update",1)
restart=t:taboption("base",Button,"update",translate("Manually Update Rules"))
restart.inputtitle=translate("Update manually")
restart.inputstyle="reload"
restart.write=function()
luci.sys.call("/etc/init.d/koolproxy update")
luci.http.redirect(luci.dispatcher.build_url("admin","services","koolproxy"))
end
e=t:taboption("base",ListValue,"reboot_mode",translate("KoolProxy AutoRestart"))
e.default="disable"
e.rmempty=false
e:value("disable",translate("disable"))
e:value("regular",translate("regular restart"))
e:value("interval",translate("interval restart"))
e=t:taboption("base",ListValue,"regular_time",translate("regular"))
for t=0,23 do
e:value(t,translate("每天"..t.."点"))
end
e.default=5
e.datatype=uinteger
e:depends("reboot_mode","regular")
e=t:taboption("base",Value,"interval_time",translate("interval"))
for t=6,72 do
	e:value(t,translate(t.."小时"))
end
e.default=24
e.datatype=uinteger
e:depends("reboot_mode","interval")
e=t:taboption("about",DummyValue,"status1",translate("</label><div align=\"left\">程序版本<strong>【<font color=\"#660099\">"..i.."</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status2",translate("</label><div align=\"left\">静态规则<strong>【<font color=\"#660099\">"..c.."共"..u.."条</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status3",translate("</label><div align=\"left\">视频规则<strong>【<font color=\"#660099\">"..r.."</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status6",translate("</label><div align=\"left\">ABP规则<strong>【<font color=\"#660099\">"..abp.."共"..abpcount.."条</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status6",translate("</label><div align=\"left\">乘风规则<strong>【<font color=\"#660099\">"..cf.."共"..cfcount.."条</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status6",translate("</label><div align=\"left\">Fanboy规则<strong>【<font color=\"#660099\">"..fboy.."共"..fboycount.."条</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status4",translate("</label><div align=\"left\">每日规则<strong>【<font color=\"#660099\">"..k.."共"..j.."条</font>】</strong></div>"))
e=t:taboption("about",DummyValue,"status5",translate("</label><div align=\"left\">自定规则<strong>【<font color=\"#660099\">"..h.."</font>】</strong></div>"))
e=t:taboption("cert",DummyValue,"c1status",translate("<div align=\"left\">Certificate Restore</div>"))
e=t:taboption("cert",FileUpload,"")
e.template="koolproxy/caupload"
e=t:taboption("cert",DummyValue,"",nil)
e.template="koolproxy/cadvalue"
if nixio.fs.access("/usr/share/koolproxy/data/certs/ca.crt")then
e=t:taboption("cert",DummyValue,"c2status",translate("<div align=\"left\">Certificate Backup</div>"))
e=t:taboption("cert",Button,"certificate")
e.inputtitle=translate("Backup Download")
e.inputstyle="reload"
e.write=function()
luci.sys.call("/usr/share/koolproxy/camanagement backup")
Download()
luci.http.redirect(luci.dispatcher.build_url("admin","services","koolproxy"))
end
end
local i="/etc/dnsmasq.d/kpadblock.conf"
e=t:taboption("weblist",TextValue,"configfile")
e.description=translate("These had been joined websites will use filter,but only blacklist model.Please input the domain names of websites,every line can input only one website domain.For example,google.com.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
return a.readfile(i)or""
end
e.write=function(t,t,e)
a.writefile("/tmp/adblock",e:gsub("\r\n","\n"))
if(luci.sys.call("cmp -s /tmp/adblock /etc/dnsmasq.d/kpadblock.conf")==1)then
a.writefile(i,e:gsub("\r\n","\n"))
--luci.sys.call("/usr/sbin/adblock >/dev/null")
end
a.remove("/tmp/adblock")
end
local i="/etc/gfwlist/adblockip"
e=t:taboption("iplist",TextValue,"adconfigfile")
e.description=translate("These had been joined ip addresses will use proxy,but only GFW model.Please input the ip address or ip address segment,every line can input only one ip address.For example,112.123.134.145/24 or 112.123.134.145.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
return a.readfile(i)or""
end
e.write=function(t,t,e)
a.writefile(i,e:gsub("\r\n","\n"))
end
local i="/usr/share/koolproxy/data/rules/user.txt"
e=t:taboption("customlist",TextValue,"configfile1")
e.description=translate("Enter your custom rules, each row.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
return a.readfile(i)or""
end
e.write=function(t,t,e)
a.writefile(i,e:gsub("\r\n","\n"))
end
local i="/var/log/koolproxy.log"
e=t:taboption("logs",TextValue,"configfile2")
e.description=translate("Koolproxy Logs")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
return a.readfile(i)or""
end
e.write=function(e,e,e)
end
t=o:section(TypedSection,"acl_rule",translate("koolproxy ACLs"),
translate("ACLs is a tools which used to designate specific IP filter mode,The MAC addresses added to the list will be filtered using https"))
t.template="cbi/tblsection"
t.sortable=false
t.anonymous=true
t.addremove=true
e=t:option(Value,"remarks",translate("Client Remarks"))
e.width="30%"
e.rmempty=true
e=t:option(Value,"ipaddr",translate("IP Address"))
e.width="20%"
e.datatype="ip4addr"
luci.ip.neighbors({family = 4}, function(neighbor)
if neighbor.reachable then
	e:value(neighbor.dest:string(), "%s (%s)" %{neighbor.dest:string(), neighbor.mac})
end
end)
e=t:option(Value,"mac",translate("MAC Address"))
e.width="20%"
e.rmempty=true
n.net.mac_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(ListValue,"filter_mode",translate("Filter Mode"))
e.width="20%"
e.default="disable"
e.rmempty=false
e:value("disable",translate("No Filter"))
e:value("global",translate("Global Filter"))
e:value("globalWithHttps",translate("Global Filter With HTTPS"))
e:value("adblock",translate("Blacklist Filter"))
e:value("adblockWithHttps",translate("Blacklist Filter With HTTPS"))
e:value("fullport",translate("Full Port Filter"))
function Download()
local t,e
t=nixio.open("/tmp/upload/koolproxyca.tar.gz","r")
luci.http.header('Content-Disposition','attachment; filename="koolproxyCA.tar.gz"')
luci.http.prepare_content("application/octet-stream")
while true do
e=t:read(nixio.const.buffersize)
if(not e)or(#e==0)then
break
else
luci.http.write(e)
end
end
t:close()
luci.http.close()
end
local t,e
t="/tmp/upload/"
nixio.fs.mkdir(t)
d.setfilehandler(
function(o,a,i)
if not e then
if not o then return end
e=nixio.open(t..o.file,"w")
if not e then
return
end
end
if a and e then
e:write(a)
end
if i and e then
e:close()
e=nil
luci.sys.call("/usr/share/koolproxy/camanagement restore")
end
end
)
return o
