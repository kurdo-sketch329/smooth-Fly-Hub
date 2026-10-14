-- Smooth Fly Hub V5 Universal | PC Edition
-- Client-side Roblox Luau. Behavior varies by experience.
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local RS=game:GetService('RunService')
local TS=game:GetService('TweenService')
local Lighting=game:GetService('Lighting')
local Http=game:GetService('HttpService')
local player=Players.LocalPlayer
assert(player,'LocalPlayer unavailable')
local env=(getgenv and getgenv()) or _G
if type(env.SmoothFlyHubV5Cleanup)=='function' then pcall(env.SmoothFlyHubV5Cleanup) end
local cfg={Fly=false,FlySpeed=65,Acceleration=7,Brake=10,VerticalSpeed=45,Boost=true,BoostMultiplier=2,Hover=true,WalkSpeed=16,SprintSpeed=40,JumpPower=50,InfiniteJump=false,Noclip=false,Aim=false,RapidFire=false,RapidFireCPS=12,AimSmooth=8,AimFOV=120,AimPart='Head',AimPriority='Crosshair',TeamCheck=true,WallCheck=true,TargetLock=true,Prediction=false,WallbangTargeting=false,ShowFOV=true,ESP=false,ESPNames=true,ESPDistance=true,ESPHealth=true,ESPHighlight=true,ESPTeamColors=true,CameraFOV=70,Fullbright=false,RGB=false,AutoSave=true,FlyKey='F',SprintKey='LeftShift',MenuKey='RightShift'}
local FILE='SmoothFlyHub_V5_Universal.json'
local allowed={AimPart={Head=true,HumanoidRootPart=true},AimPriority={Crosshair=true,Distance=true}}
local ranges={FlySpeed={10,300},Acceleration={1,30},Brake={1,30},VerticalSpeed={10,200},BoostMultiplier={1,5},WalkSpeed={0,300},SprintSpeed={20,300},JumpPower={0,300},AimSmooth={1,30},RapidFireCPS={2,30},AimFOV={30,400},CameraFOV={40,120}}
local function validKey(name) return type(name)=='string' and Enum.KeyCode[name]~=nil and name~='Unknown' end
local function load()
 if not (readfile and isfile) then return end
 pcall(function()
  if not isfile(FILE) then return end
  local data=Http:JSONDecode(readfile(FILE))
  if type(data)~='table' then return end
  for k,v in pairs(data) do
   if cfg[k]~=nil and type(v)==type(cfg[k]) then
    if ranges[k] then v=math.clamp(v,ranges[k][1],ranges[k][2]) end
    if allowed[k] and not allowed[k][v] then continue end
    if k:sub(-3)=='Key' and not validKey(v) then continue end
    cfg[k]=v
   end
  end
 end)
end
load()
cfg.Fly=false;cfg.Aim=false
local function save()
 if not writefile then return false end
 return pcall(function()
  local data=table.clone(cfg);data.Fly=false;data.Aim=false
  writefile(FILE,Http:JSONEncode(data))
 end)
end
local function changed() if cfg.AutoSave then save() end end
local conns,alive={},true
local function listen(sig,fn) local c=sig:Connect(fn);table.insert(conns,c);return c end
local function make(class,props,parent)
 local o=Instance.new(class)
 for k,v in pairs(props) do o[k]=v end
 o.Parent=parent;return o
end
local function round(o,r) make('UICorner',{CornerRadius=UDim.new(0,r or 8)},o) end
local function tween(o,p,d) TS:Create(o,TweenInfo.new(d or .18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local colors={bg=Color3.fromRGB(16,17,25),panel=Color3.fromRGB(27,29,42),button=Color3.fromRGB(42,44,62),accent=Color3.fromRGB(155,105,255),text=Color3.fromRGB(245,245,255),muted=Color3.fromRGB(160,160,180)}
local function charParts()
 local ch=player.Character
 if not ch then return end
 return ch,ch:FindFirstChildOfClass('Humanoid'),ch:FindFirstChild('HumanoidRootPart')
end
local parent
pcall(function() parent=game:GetService('CoreGui') end)
if not parent then parent=player:WaitForChild('PlayerGui') end
local gui=make('ScreenGui',{Name='SmoothFlyHubV5',ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
local main=make('Frame',{Size=UDim2.fromOffset(610,460),Position=UDim2.new(.5,-305,.5,-230),BackgroundColor3=colors.bg,BorderSizePixel=0,Active=true,Visible=true},gui);round(main,14)
local border=make('UIStroke',{Color=colors.accent,Thickness=1.3,Transparency=.25},main)
local top=make('Frame',{Size=UDim2.new(1,0,0,52),BackgroundColor3=colors.panel,BorderSizePixel=0,Active=true},main);round(top,14)
local title=make('TextLabel',{Size=UDim2.new(1,-120,1,0),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,Text='SMOOTH FLY HUB  /  V5 UNIVERSAL',TextColor3=colors.accent,TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},top)
local function headButton(text,offset,color)
 local b=make('TextButton',{Size=UDim2.fromOffset(32,32),Position=UDim2.new(1,offset,0,10),BackgroundColor3=color,TextColor3=colors.text,Text=text,TextSize=20,Font=Enum.Font.GothamBold},top);round(b,8);return b
end
local minimize=headButton('−',-78,colors.button)
local close=headButton('×',-40,Color3.fromRGB(150,60,80))
local sidebar=make('Frame',{Size=UDim2.fromOffset(140,392),Position=UDim2.fromOffset(10,60),BackgroundTransparency=1},main)
make('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},sidebar)
local content=make('Frame',{Size=UDim2.new(1,-170,1,-70),Position=UDim2.fromOffset(160,60),BackgroundColor3=colors.panel,BorderSizePixel=0},main);round(content,11)
local pages,tabs,refreshers,searchable={},{},{},{}
local function tabSelect(name)
 for n,page in pairs(pages) do
  page.Visible=(n==name)
  tween(tabs[n],{BackgroundColor3=(n==name and colors.accent or colors.button)})
 end
end
for i,name in ipairs({'Fly','Movement','Combat','Visuals','Settings'}) do
 local b=make('TextButton',{Size=UDim2.new(1,0,0,44),LayoutOrder=i,BackgroundColor3=colors.button,TextColor3=colors.text,Text=name,TextSize=14,Font=Enum.Font.GothamBold},sidebar);round(b)
 local page=make('ScrollingFrame',{Size=UDim2.new(1,-20,1,-20),Position=UDim2.fromOffset(10,10),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=colors.accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false},content)
 make('UIListLayout',{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},page)
 pages[name]=page;tabs[name]=b
 listen(b.MouseButton1Click,function() tabSelect(name) end)
end
tabSelect('Fly')
local bubble=make('TextButton',{Size=UDim2.fromOffset(58,58),Position=UDim2.fromOffset(25,180),BackgroundColor3=colors.accent,TextColor3=colors.text,Text='V5',Font=Enum.Font.GothamBold,TextSize=18,Visible=false},gui);round(bubble,15)
local function showMenu(value) main.Visible=value;bubble.Visible=not value end
listen(minimize.MouseButton1Click,function() showMenu(false) end)
listen(bubble.MouseButton1Click,function() showMenu(true) end)
local note=make('TextLabel',{Size=UDim2.fromOffset(310,36),Position=UDim2.new(.5,-155,0,-48),BackgroundColor3=colors.panel,TextColor3=colors.text,TextSize=13,Font=Enum.Font.GothamMedium,Text='',Visible=false},gui);round(note)
local noticeID=0
local function notify(msg)
 noticeID+=1;local id=noticeID
 note.Text=msg;note.Visible=true;note.Position=UDim2.new(.5,-155,0,-48)
 tween(note,{Position=UDim2.new(.5,-155,0,15)},.2)
 task.delay(2,function() if alive and id==noticeID then note.Visible=false end end)
end
local function register(tab,obj,label) table.insert(searchable,{tab=tab,obj=obj,label=label:lower()}) end
local function toggle(tab,label,key,cb)
 local b=make('TextButton',{Size=UDim2.new(1,-5,0,42),BackgroundColor3=colors.button,TextColor3=colors.text,TextSize=13,Font=Enum.Font.GothamMedium},pages[tab]);round(b)
 local function refresh() b.Text=label..'    '..(cfg[key] and 'ON' or 'OFF');tween(b,{BackgroundColor3=(cfg[key] and colors.accent or colors.button)}) end
 listen(b.MouseButton1Click,function() cfg[key]=not cfg[key];if cb then cb() end;refresh();changed() end)
 refreshers[key]=refresh;register(tab,b,label);refresh()
end
local function slider(tab,label,key,min,max,step,cb)
 local holder=make('Frame',{Size=UDim2.new(1,-5,0,65),BackgroundColor3=colors.button},pages[tab]);round(holder)
 local caption=make('TextLabel',{Size=UDim2.new(1,-20,0,25),Position=UDim2.fromOffset(10,3),BackgroundTransparency=1,TextColor3=colors.text,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},holder)
 local track=make('Frame',{Size=UDim2.new(1,-26,0,7),Position=UDim2.fromOffset(13,42),BackgroundColor3=colors.panel,BorderSizePixel=0,Active=true},holder);round(track,5)
 local fill=make('Frame',{Size=UDim2.fromScale(0,1),BackgroundColor3=colors.accent,BorderSizePixel=0},track);round(fill,5)
 local knob=make('Frame',{Size=UDim2.fromOffset(15,15),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),BackgroundColor3=colors.text,BorderSizePixel=0},track);round(knob,20)
 local drag=false
 local function refresh()
  local ratio=math.clamp((cfg[key]-min)/(max-min),0,1)
  caption.Text=label..': '..tostring(cfg[key]);fill.Size=UDim2.fromScale(ratio,1);knob.Position=UDim2.fromScale(ratio,.5)
 end
 local function setX(x)
  local ratio=math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)
  cfg[key]=math.clamp(math.floor((min+(max-min)*ratio)/step+.5)*step,min,max)
  refresh();if cb then cb() end
 end
 listen(track.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;setX(input.Position.X) end end)
 listen(UIS.InputChanged,function(input) if drag and input.UserInputType==Enum.UserInputType.MouseMovement then setX(input.Position.X) end end)
 listen(UIS.InputEnded,function(input) if drag and input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false;changed() end end)
 refreshers[key]=refresh;register(tab,holder,label);refresh()
end
local function cycle(tab,label,key,values)
 local b=make('TextButton',{Size=UDim2.new(1,-5,0,42),BackgroundColor3=colors.button,TextColor3=colors.text,TextSize=13,Font=Enum.Font.GothamMedium},pages[tab]);round(b)
 local function refresh() b.Text=label..': '..tostring(cfg[key]) end
 listen(b.MouseButton1Click,function() local i=table.find(values,cfg[key]) or 1;cfg[key]=values[i%#values+1];refresh();changed() end)
 refreshers[key]=refresh;register(tab,b,label);refresh()
end
local bv,bg,flyHum,velocity=nil,nil,nil,Vector3.zero
local sprintHeld,aimHeld,locked=false,false,nil
local collisions={}
local function restoreCollisions()
 for part,old in pairs(collisions) do if part.Parent then pcall(function() part.CanCollide=old end) end;collisions[part]=nil end
end
local function walk()
 local _,hum=charParts();if hum then hum.WalkSpeed=(sprintHeld and cfg.SprintSpeed or cfg.WalkSpeed) end
end
local function jump()
 local _,hum=charParts();if hum then hum.UseJumpPower=true;hum.JumpPower=cfg.JumpPower end
end
local function stopFly()
 cfg.Fly=false
 if bv then bv:Destroy();bv=nil end
 if bg then bg:Destroy();bg=nil end
 if flyHum and flyHum.Parent then flyHum.PlatformStand=false end
 flyHum=nil;velocity=Vector3.zero
end
local function startFly()
 local _,hum,root=charParts()
 stopFly()
 if not hum or not root then notify('Character not ready');return end
 bv=Instance.new('BodyVelocity');bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.P=10000;bv.Velocity=Vector3.zero;bv.Parent=root
 bg=Instance.new('BodyGyro');bg.MaxTorque=Vector3.new(1e9,1e9,1e9);bg.P=10000;bg.D=500;bg.CFrame=root.CFrame;bg.Parent=root
 flyHum=hum;hum.PlatformStand=true;cfg.Fly=true
end
local function flyToggle() if cfg.Fly then stopFly() else startFly() end;if refreshers.Fly then refreshers.Fly() end end
local oldLight={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,GlobalShadows=Lighting.GlobalShadows}
local oldFOV=(workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView) or 70
local function fullbright()
 if cfg.Fullbright then Lighting.Brightness=3;Lighting.ClockTime=14;Lighting.GlobalShadows=false
 else for k,v in pairs(oldLight) do Lighting[k]=v end end
end
-- Tabs
toggle('Fly','Smooth Fly','Fly',function() local want=cfg.Fly;cfg.Fly=false;if want then startFly() else stopFly() end end)
slider('Fly','Fly Speed','FlySpeed',10,300,5)
slider('Fly','Acceleration','Acceleration',1,30,1)
slider('Fly','Brake','Brake',1,30,1)
slider('Fly','Vertical Speed','VerticalSpeed',10,200,5)
toggle('Fly','Fly Boost','Boost')
slider('Fly','Boost Multiplier','BoostMultiplier',1,5,.5)
toggle('Fly','Hover Mode','Hover')
slider('Movement','Player Speed','WalkSpeed',0,300,5,walk)
slider('Movement','Sprint Speed','SprintSpeed',20,300,5,walk)
slider('Movement','Jump Power','JumpPower',0,300,5,jump)
toggle('Movement','Infinite Jump','InfiniteJump')
toggle('Movement','Noclip','Noclip',function() if not cfg.Noclip then restoreCollisions() end end)
toggle('Combat','Player Aimbot','Aim')
toggle('Combat','Rapid Fire (hold LMB)','RapidFire')
slider('Combat','Rapid Fire Speed (CPS)','RapidFireCPS',2,30,1)
slider('Combat','Aim Smoothness','AimSmooth',1,30,1)
slider('Combat','Aim FOV','AimFOV',30,400,5)
cycle('Combat','Target Part','AimPart',{'Head','HumanoidRootPart'})
cycle('Combat','Target Priority','AimPriority',{'Crosshair','Distance'})
toggle('Combat','FOV Circle','ShowFOV')
toggle('Combat','Team Check','TeamCheck')
toggle('Combat','Wall Check','WallCheck')
toggle('Combat','Target Lock','TargetLock')
toggle('Combat','Prediction','Prediction')
toggle('Combat','Wallbang Targeting','WallbangTargeting')
toggle('Visuals','Player ESP','ESP')
toggle('Visuals','Player Names','ESPNames')
toggle('Visuals','Distance','ESPDistance')
toggle('Visuals','Health Bar','ESPHealth')
toggle('Visuals','Highlight','ESPHighlight')
toggle('Visuals','Team Colors','ESPTeamColors')
slider('Settings','Camera FOV','CameraFOV',40,120,5,function() local c=workspace.CurrentCamera;if c then c.FieldOfView=cfg.CameraFOV end end)
toggle('Settings','Fullbright','Fullbright',fullbright)
toggle('Settings','RGB Theme','RGB')
toggle('Settings','Auto Save','AutoSave')
local keyButtons={}
local capturing=nil
local function keyControl(label,key)
 local b=make('TextButton',{Size=UDim2.new(1,-5,0,44),BackgroundColor3=colors.button,TextColor3=colors.text,TextSize=13,Font=Enum.Font.GothamBold},pages.Settings);round(b)
 local function refresh() b.Text=label..': '..cfg[key];b.BackgroundColor3=colors.button end
 keyButtons[key]=refresh
 listen(b.MouseButton1Click,function()
  capturing=key;b.Text='PRESS A KEY (ESC TO CANCEL)';b.BackgroundColor3=colors.accent
 end)
 register('Settings',b,label);refresh()
end
keyControl('Menu Keybind','MenuKey')
keyControl('Fly Keybind','FlyKey')
keyControl('Sprint Keybind','SprintKey')
local saveButton=make('TextButton',{Size=UDim2.new(1,-5,0,42),BackgroundColor3=colors.accent,TextColor3=colors.text,Text='SAVE CONFIG',TextSize=13,Font=Enum.Font.GothamBold},pages.Settings);round(saveButton)
listen(saveButton.MouseButton1Click,function() notify(save() and 'Settings saved' or 'File saving unavailable') end)
local search=make('TextBox',{Size=UDim2.new(1,0,0,36),BackgroundColor3=colors.button,TextColor3=colors.text,PlaceholderColor3=colors.muted,PlaceholderText='Search features...',Text='',TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false},sidebar);round(search)
listen(search:GetPropertyChangedSignal('Text'),function()
 local q=search.Text:lower();local first
 for _,e in ipairs(searchable) do e.obj.Visible=(q=='' or e.label:find(q,1,true)~=nil);if e.obj.Visible and not first then first=e.tab end end
 if q~='' and first then tabSelect(first) end
end)
local fov=make('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(240,240),BackgroundTransparency=1,Visible=false,ZIndex=20},gui);round(fov,1000)
local fovStroke=make('UIStroke',{Color=colors.accent,Thickness=1.5,Transparency=.15},fov)
local esp={}
local function removeESP(p)
 local o=esp[p];if not o then return end
 if o.billboard then o.billboard:Destroy() end
 if o.highlight then o.highlight:Destroy() end
 esp[p]=nil
end
local function buildESP(p,ch,root)
 removeESP(p)
 local bill=make('BillboardGui',{Name='SmoothV5ESP',Size=UDim2.fromOffset(150,62),StudsOffset=Vector3.new(0,3.5,0),AlwaysOnTop=true,Adornee=root},gui)
 local text=make('TextLabel',{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,TextColor3=colors.text,TextStrokeTransparency=.3,TextSize=12,Font=Enum.Font.GothamBold,TextWrapped=true},bill)
 local back=make('Frame',{Size=UDim2.new(.8,0,0,5),Position=UDim2.new(.1,0,1,-10),BackgroundColor3=Color3.fromRGB(90,30,40),BorderSizePixel=0},bill);round(back,3)
 local health=make('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(80,220,120),BorderSizePixel=0},back);round(health,3)
 local hi=make('Highlight',{Name='SmoothV5Highlight',FillTransparency=.8,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Adornee=ch},gui)
 esp[p]={billboard=bill,text=text,back=back,health=health,highlight=hi,char=ch}
end
local function updateESP()
 if not cfg.ESP then for p in pairs(esp) do removeESP(p) end;return end
 local _,_,mine=charParts()
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=player then
   local ch=p.Character;local root=ch and ch:FindFirstChild('HumanoidRootPart');local hum=ch and ch:FindFirstChildOfClass('Humanoid')
   if not root or not hum or hum.Health<=0 then removeESP(p)
   else
    if not esp[p] or esp[p].char~=ch then buildESP(p,ch,root) end
    local o=esp[p]
    if o then
     local color=(cfg.ESPTeamColors and p.TeamColor and p.TeamColor.Color) or colors.accent
     local lines={}
     if cfg.ESPNames then table.insert(lines,p.DisplayName) end
     if cfg.ESPDistance and mine then table.insert(lines,math.floor((mine.Position-root.Position).Magnitude)..' studs') end
     o.text.Text=table.concat(lines,'\n');o.text.TextColor3=color
     o.back.Visible=cfg.ESPHealth;o.health.Size=UDim2.fromScale(math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1),1)
     o.highlight.Enabled=cfg.ESPHighlight;o.highlight.FillColor=color;o.highlight.OutlineColor=color
    end
   end
  end
 end
end
local function targetPart(p,cam)
 if p==player then return end
 if cfg.TeamCheck and player.Team~=nil and p.Team==player.Team then return end
 local ch=p.Character;local hum=ch and ch:FindFirstChildOfClass('Humanoid')
 local part=ch and ch:FindFirstChild(cfg.AimPart)
 if not hum or hum.Health<=0 or not part then return end
 if cfg.WallCheck and not cfg.WallbangTargeting then
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
  local ignore={};if player.Character then table.insert(ignore,player.Character) end
  params.FilterDescendantsInstances=ignore
  local hit=workspace:Raycast(cam.CFrame.Position,part.Position-cam.CFrame.Position,params)
  if hit and not hit.Instance:IsDescendantOf(ch) then return end
 end
 local point,visible=cam:WorldToViewportPoint(part.Position)
 if not visible or point.Z<=0 then return end
 return part,Vector2.new(point.X,point.Y)
end
local function selectTarget(cam,center)
 if cfg.TargetLock and locked then
  local part,screen=targetPart(locked,cam)
  if part and (screen-center).Magnitude<=cfg.AimFOV then return part end
 end
 locked=nil;local best,bestScore=nil,math.huge
 for _,p in ipairs(Players:GetPlayers()) do
  local part,screen=targetPart(p,cam)
  if part then
   local delta=(screen-center).Magnitude
   if delta<=cfg.AimFOV then
    local score=(cfg.AimPriority=='Distance') and (cam.CFrame.Position-part.Position).Magnitude or delta
    if score<bestScore then best,bestScore,locked=part,score,p end
   end
  end
 end
 return best
end
listen(UIS.InputBegan,function(input,processed)
 if capturing then
  if input.UserInputType~=Enum.UserInputType.Keyboard then return end
  local key=capturing;capturing=nil
  if input.KeyCode~=Enum.KeyCode.Escape and input.KeyCode~=Enum.KeyCode.Unknown then
   local name=input.KeyCode.Name
   if name==cfg.MenuKey and key~='MenuKey' or name==cfg.FlyKey and key~='FlyKey' or name==cfg.SprintKey and key~='SprintKey' then
    notify('Key already assigned')
   else cfg[key]=name;changed();notify(key..': '..name) end
  end
  keyButtons[key]();return
 end
 if processed or UIS:GetFocusedTextBox() then return end
 if input.KeyCode.Name==cfg.MenuKey then showMenu(not main.Visible);return end
 if input.KeyCode.Name==cfg.FlyKey then flyToggle() end
 if input.KeyCode.Name==cfg.SprintKey then sprintHeld=true;walk() end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then aimHeld=true end
 if cfg.InfiniteJump and input.KeyCode==Enum.KeyCode.Space then
  local _,hum=charParts();if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
end)
local rapidHeld=false
listen(UIS.InputBegan,function(input,processed)
 if input.UserInputType==Enum.UserInputType.MouseButton1 and not processed and not UIS:GetFocusedTextBox() then rapidHeld=true end
end)
listen(UIS.InputEnded,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then rapidHeld=false end
end)
task.spawn(function()
 while alive do
  if cfg.RapidFire and rapidHeld and not main.Visible and type(mouse1click)=='function' then
   pcall(mouse1click)
   task.wait(1/math.max(2,cfg.RapidFireCPS))
  else task.wait(0.05) end
 end
end)
listen(UIS.InputEnded,function(input)
 if input.KeyCode.Name==cfg.SprintKey then sprintHeld=false;walk() end
 if input.UserInputType==Enum.UserInputType.MouseButton2 then aimHeld=false end
end)
listen(RS.Heartbeat,function(dt)
 if not alive then return end
 local ch,hum,root=charParts()
 if not ch or not hum or not root then return end
 if cfg.Noclip then
  for _,part in ipairs(ch:GetDescendants()) do
   if part:IsA('BasePart') then
    if collisions[part]==nil then collisions[part]=part.CanCollide end
    part.CanCollide=false
   end
  end
 elseif next(collisions) then restoreCollisions() end
 if not cfg.Fly or not bv or not bg then return end
 local cam=workspace.CurrentCamera;if not cam then return end
 local cf=cam.CFrame;local direction=Vector3.zero
 if UIS:IsKeyDown(Enum.KeyCode.W) then direction+=cf.LookVector end
 if UIS:IsKeyDown(Enum.KeyCode.S) then direction-=cf.LookVector end
 if UIS:IsKeyDown(Enum.KeyCode.A) then direction-=cf.RightVector end
 if UIS:IsKeyDown(Enum.KeyCode.D) then direction+=cf.RightVector end
 local vertical=0
 if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical+=1 end
 if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertical-=1 end
 local horizontal=Vector3.new(direction.X,0,direction.Z)
 if horizontal.Magnitude>0 then horizontal=horizontal.Unit end
 local speed=cfg.FlySpeed*(cfg.Boost and sprintHeld and cfg.BoostMultiplier or 1)
 local desired=horizontal*speed+Vector3.yAxis*vertical*cfg.VerticalSpeed
 if not cfg.Hover and vertical==0 then desired+=Vector3.new(0,-8,0) end
 local smooth=(desired.Magnitude<velocity.Magnitude) and cfg.Brake or cfg.Acceleration
 local alpha=1-math.exp(-smooth*dt)
 velocity=velocity:Lerp(desired,alpha);bv.Velocity=velocity
 local look=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
 if look.Magnitude>.001 then bg.CFrame=bg.CFrame:Lerp(CFrame.lookAt(root.Position,root.Position+look.Unit),alpha) end
end)
local espClock=0
listen(RS.RenderStepped,function(dt)
 if not alive then return end
 local cam=workspace.CurrentCamera;if not cam then return end
 local accent=cfg.RGB and Color3.fromHSV((os.clock()*.12)%1,.7,1) or colors.accent
 title.TextColor3=accent;border.Color=accent;fovStroke.Color=accent;bubble.BackgroundColor3=accent
 espClock+=dt;if espClock>=.12 then espClock=0;updateESP() end
 local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
 fov.Position=UDim2.fromOffset(center.X,center.Y)
 fov.Size=UDim2.fromOffset(cfg.AimFOV*2,cfg.AimFOV*2)
 fov.Visible=cfg.Aim and cfg.ShowFOV
 if not cfg.Aim or not aimHeld then locked=nil;return end
 local part=selectTarget(cam,center);if not part then return end
 local pos=part.Position
 if cfg.Prediction then pos+=part.AssemblyLinearVelocity*.08 end
 local desired=CFrame.lookAt(cam.CFrame.Position,pos)
 cam.CFrame=cam.CFrame:Lerp(desired,1-math.exp(-cfg.AimSmooth*dt))
end)
local dragging,dragStart,startPos,dragInput=false,nil,nil,nil
listen(top.InputBegan,function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;dragStart=input.Position;startPos=main.Position end
end)
listen(top.InputChanged,function(input) if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end end)
listen(UIS.InputChanged,function(input)
 if dragging and input==dragInput then
  local delta=input.Position-dragStart
  main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
 end
end)
listen(UIS.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
listen(player.CharacterAdded,function(ch)
 stopFly();restoreCollisions();if refreshers.Fly then refreshers.Fly() end
 task.spawn(function()
  local hum=ch:WaitForChild('Humanoid',10)
  if not alive or not hum then return end
  hum.UseJumpPower=true;hum.JumpPower=cfg.JumpPower;hum.WalkSpeed=cfg.WalkSpeed
 end)
end)
listen(Players.PlayerRemoving,function(p) removeESP(p);if locked==p then locked=nil end end)
local function cleanup()
 if not alive then return end
 alive=false;stopFly();restoreCollisions()
 for p in pairs(esp) do removeESP(p) end
 for _,c in ipairs(conns) do c:Disconnect() end
 for k,v in pairs(oldLight) do Lighting[k]=v end
 local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=oldFOV end
 gui:Destroy()
 if env.SmoothFlyHubV5Cleanup==cleanup then env.SmoothFlyHubV5Cleanup=nil end
end
listen(close.MouseButton1Click,cleanup)
env.SmoothFlyHubV5Cleanup=cleanup
local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=cfg.CameraFOV end
walk();jump();fullbright();showMenu(true)
notify('Smooth Fly Hub V5 Universal loaded')
print('Smooth Fly Hub V5 Universal | PC Edition')
