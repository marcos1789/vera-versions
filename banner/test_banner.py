# Simulates several VERA resources (each its own environment) on one server.
import json, sys
from lupa.lua54 import LuaRuntime
lua = LuaRuntime(unpack_returned_tuples=True)
src = open('vera_banner.lua', encoding='utf-8').read()
lua.globals().SRC = src
lua.globals().pyjson_decode = lambda s: lua.table_from(json.loads(s)) if False else None
lua.execute(r'''
clock=0; handlers={}; threads={}; timers={}; out={}; httpBody=nil; httpCode=200; versionsMeta={}
function GetGameTimer() return clock end
function IsDuplicityVersion() return true end
function GetConvar(k,d) return convars and convars[k] or d end
convars={['sv_projectName']='^2NEXA RP'}
function AddEventHandler(name,fn) handlers[name]=handlers[name] or {}; table.insert(handlers[name],{fn=fn,env=_ENV}) end
depth=0; maxDepth=0
function TriggerEvent(name,...) depth=depth+1; if depth>maxDepth then maxDepth=depth end; assert(depth<=3,'nested events: '..name); for _,h in ipairs(handlers[name] or {}) do h.fn(...) end; depth=depth-1 end
order={}
function GetNumResources() return #order end
function GetResourceByFindIndex(i) return order[i+1] end
function GetNumResourceMetadata(n,k) return k=='server_script' and 1 or 0 end
states={}
function GetResourceState(n) return states[n] or 'missing' end
function GetResourceMetadata(n,k,i) if n=='qbx_core' then return '1.22.4' end if k=='server_script' then return 'vera_banner.lua' end return versionsMeta[n] end
Citizen={Trace=function(s) out[#out+1]=s end}
function PerformHttpRequest(url,cb) timers[#timers+1]={at=clock+200,fn=function() cb(httpCode,httpBody) end} end
function SetTimeout(ms,fn) timers[#timers+1]={at=clock+ms,fn=fn} end
function Wait(ms) coroutine.yield(ms) end
function CreateThread(fn) local co=coroutine.create(fn); threads[#threads+1]={co=co,at=clock} end
json={decode=function(s) return decodeJson(s) end}
function startResource(name, version, setup)
  order[#order+1]=name; versionsMeta[name]=version
  local env=setmetatable({}, {__index=_G})
  env.GetCurrentResourceName=function() return name end
  local chunk=assert(load(SRC,'@'..name,'t',env))
  chunk()
  if setup then setup(env) end
  states[name]='started'
  TriggerEvent('onServerResourceStart', name)
  return env
end
function run(ms)
  local stop=clock+ms
  while clock<stop do
    clock=clock+50
    for _,t in ipairs(threads) do
      if coroutine.status(t.co)~='dead' and t.at<=clock then
        local ok,w=coroutine.resume(t.co); assert(ok,w); t.at=clock+(w or 0)
      end
    end
    for i=#timers,1,-1 do local t=timers[i]; if t.at<=clock then table.remove(timers,i); t.fn() end end
  end
end
''')
def decode(s):
    try: return lua.table_from(json.loads(s), recursive=True)
    except Exception: raise
lua.globals().decodeJson = decode
lua.globals().httpBody = json.dumps({"download":"https://keymaster.fivem.net","changelog":"https://github.com/marcos1789/vera-versions#novedades",
  "resources":{"vera-qbox-ui":{"version":"1.2.1"},"vera-qbox-hud":{"version":"4.2.0","notes":"Diseño D."},
  "vera-qbox-keys":{"version":"0.9.2","security":True,"notes":"Corrige la ganzúa."},"vera-qbox-chat":{"version":"1.5.1","notes":"Arreglos."}}})
lua.execute(r'''
startResource('vera-qbox-ui','1.2.1')
startResource('vera-qbox-hud','4.1.1')
run(1000)
startResource('vera-qbox-keys','0.9.1', function(env) env.VERABanner.warn('Falta vera-qbox-ui · notificaciones de ox_lib') end)
startResource('vera-qbox-chat','1.5.0')
run(8000)
''')
out = [str(x) for x in lua.eval('out').values()]
text = ''.join(out)
print(text.replace('^7','').replace('^5','').replace('^2','').replace('^3','').replace('^1','').replace('^6',''))
assert text.count('┌') == 1, 'one banner only'
assert '1 al día' in text and '3 actualizaciones' in text, 'summary'
for name in ['vera-qbox-ui','vera-qbox-hud','vera-qbox-keys','vera-qbox-chat']:
    assert text.count(name+' ') >= 1, name
assert 'Parche de seguridad 0.9.2' in text and 'Actualización 4.2.0' in text and 'Parche 1.5.1' in text and 'Al día' in text
assert text.count('vera-qbox-ui ') == 1, 'printer listed once'
# late joiner after the banner
lua.execute("startResource('vera-qbox-admin','0.7.1'); run(5000)")
text2 = ''.join(str(x) for x in lua.eval('out').values())
assert text2.count('┌') == 1 and 'vera-qbox-admin 0.7.1' in text2, 'late resource adds one line'
# offline: no versions
lua.execute("order={}; states={}; out={}; handlers={}; threads={}; timers={}; clock=200000; httpCode=0; httpBody=''; startResource('vera-qbox-ui','1.2.1'); run(8000)")
t3=''.join(str(x) for x in lua.eval('out').values())
assert 'vera-qbox-ui 1.2.1' in t3 and 'Correcto' in t3, t3
# off
lua.execute("order={}; states={}; out={}; handlers={}; threads={}; timers={}; clock=0; httpCode=200; convars={['vera:banner']='apagado'}; startResource('vera-qbox-ui','1.2.1'); run(8000)")
assert len(lua.eval('out'))==0, 'apagado prints nothing'
assert lua.eval('maxDepth') <= 2, lua.eval('maxDepth')
# 16 resources at once: still one banner, no deep nesting
lua.execute("order={}; states={}; out={}; handlers={}; threads={}; timers={}; clock=0; maxDepth=0; convars={}; for i=1,16 do startResource(('vera-qbox-r%02d'):format(i),'1.0.0') end; run(9000)")
t4=''.join(str(x) for x in lua.eval('out').values())
assert t4.count('┌')==1 and t4.count('vera-qbox-r')>=16 and lua.eval('maxDepth')<=2, 'sixteen resources'
print('PASS banner: one shared block, statuses, security/update/patch, late joiner line, offline, off')
