L = {}

/////////////////////////////////////// Font
////////////////////// See "font_en" file

/////////////////////////////////////// General
////////////////////// Translation
L["translation.name"] = "简体中文翻译"
L["translation.authors"] = "TheOnly8Z，WhatUziname7"

--[[
"translation.name" should be changed to "English Translation" but translated
		for example "Deutsche Übersetzung", "Svensk Översättning", etc.

If set to false, both of these will not show.

"translation.authors" should include the list of the translators. For example, "Moka" or "darsu".
--]]

////////////////////// Units of measurement
L["unit.second"] = "秒"
L["unit.meter"] = "米"
L["unit.millimeter"] = "毫米"
L["unit.meterpersecond"] = "米/秒"
L["unit.hammerunit"] = "HU"
L["unit.decibel"] = "分贝"
L["unit.rpm"] = "转速"
L["unit.moa"] = "MOA"
L["unit.dmg"] = "伤害"
L["unit.projectiles"] = "PROJ"

L["unit.inch"] = "in"
L["unit.foot"] = "ft"
L["unit.footpersecond"] = "ft/s"
L["unit.yard"] = "yd"

////////////////////// Ammo types
L["ammo.pistol"] = "手枪弹药"
L["ammo.357"] = "马格南弹药"
L["ammo.smg1"] = "卡宾枪弹药"
L["ammo.ar2"] = "步枪弹药"
L["ammo.buckshot"] = "霰弹枪弹药"
L["ammo.sniperpenetratedround"] = "狙击枪弹药"
L["ammo.smg1_grenade"] = "步枪榴弹"
L["ammo.xbowbolt"] = "弩箭"
L["ammo.rpg_round"] = "火箭"
L["ammo.grenade"] = "手雷"
L["ammo.slam"] = "SLAM"
L["ammo.alyxgun"] = "爱莉克斯的枪支弹药"

/////////////////////////////////////// HUD
L["hud.version"] = "北极HUD系统版本号:"
L["hud.jammed"] = "卡弹!"
L["hud.therm_deco"] = "枪管温度"

L["hud.firemode.single"] = "单发"
L["hud.firemode.burst"] = "点射"
L["hud.firemode.auto"] = "自动"
L["hud.firemode.safe"] = "保险"

L["hud.hint.bash"] = "近战"
L["hud.hint.bipod"] = "切换两脚架"
L["hud.hint.breath"] = "屏气"
L["hud.hint.customize"] = "自定义"
L["hud.hint.cycle"] = "上膛"
L["hud.hint.firemode"] = "切换开火模式"
L["hud.hint.inspect"] = "检现"
L["hud.hint.lean"] = "侧身"
L["hud.hint.peek"] = "窥视"
L["hud.hint.reload"] = "换弹"
L["hud.hint.safe"] = "切换保险"
L["hud.hint.switchsights"] = "开关瞄准镜"
L["hud.hint.toggleatts"] = "切换手电"
L["hud.hint.togglecamos"] = "切换迷彩"
L["hud.hint.ubgl"] = "切换"
L["hud.hint.unjam"] = "解除卡弹"
L["hud.hint.zoom"] = "瞄具缩放"
L["hud.hint.quicknade"] = "快速投掷 \"%s\""
L["hud.hint.quickreload"] = "快速换弹"

L["hud.hint.lowammo"] = "少弹药"
L["hud.hint.noammo"] = "无弹药"

L["hud.error.missingbind"] = "无按键绑定到 %s"
L["hud.error.missingbind_zoom"] = "在游戏设置里绑定 \"防护衣缩放\" !"
L["hud.error.missingbind_context"] = "在游戏设置里绑定 \"打开快捷菜单\" !"
L["hud.error.missingbind_flight"] = "在游戏设置里绑定 \"手电筒\" !"
L["hud.error.missingbind_use"] = "在游戏设置里绑定 \"使用物品\" !"
L["hud.error.missingbind_invnext"] = "在游戏设置里绑定 \"下一个武器.\" !"
L["hud.error.missingbind_invprev"] = "在游戏设置里绑定 \"上一个武器.\" !"

/////////////////////////////////////// Customization menu
L["customize.panel.customize"] = "自定义"
L["customize.panel.personalize"] = "个性化"
L["customize.panel.stats"] = "数据与弹道"
L["customize.panel.trivia"] = "小知识"
L["customize.panel.inspect"] = "检视"
L["customize.panel.presets"] = "预设"

L["customize.stats.aimtime"] = "瞄准速度"
L["customize.stats.ammo"] = "弹药类型"
L["customize.stats.armorpiercing"] = "穿甲"
L["customize.stats.burstdelay"] = "点射延迟"
L["customize.stats.capacity"] = "装填量"
L["customize.stats.cyclic"] = "有效射速"
L["customize.stats.explosive"] = "爆炸伤害"
L["customize.stats.firemodes"] = "开火模式"
L["customize.stats.firepower"] = "火力"
L["customize.stats.freeaim"] = "自由腰射角度"
--L["customize.stats.muzzlevelocity"] = "出膛速度"
L["customize.stats.shootentforce"] = "出膛速度"
L["customize.stats.noise"] = "开火响度"
L["customize.stats.penetration"] = "穿透力"
L["customize.stats.precision"] = "准度"
L["customize.stats.range"] = "射程"
L["customize.stats.ricochet"] = "反弹概率"
L["customize.stats.rof"] = "射速"
L["customize.stats.speed"] = "移动速度"
L["customize.stats.sprinttofire"] = "冲刺恢复速度"
L["customize.stats.supplylimit"] = "补给上限"
L["customize.stats.sway"] = "偏移"
L["customize.stats.triggerdelay"] = "扳机延迟"
L["customize.stats.fusetimer"] = "引信计时器"

L["customize.hint.attach"] = "附加"
L["customize.hint.controller"] = "开启手柄模式"
L["customize.hint.cursor"] = "光标"
L["customize.hint.cycle"] = "切换槽位"
L["customize.hint.delete"] = "删除"
L["customize.hint.deselect"] = "取消选择"
L["customize.hint.expand"] = "配置"
L["customize.hint.export"] = "导出"
L["customize.hint.favorite"] = "加入收藏"
L["customize.hint.import"] = "导入"
L["customize.hint.install"] = "安装"
L["customize.hint.last"] = "上个槽位"
L["customize.hint.lastmode"] = "上个模式"
L["customize.hint.nextmode"] = "下个模式"
L["customize.hint.open"] = "打开"
L["customize.hint.pan"] = "平移"
L["customize.hint.quicksave"] = "快速保存"
L["customize.hint.randomize"] = "随机附加"
L["customize.hint.recalculate"] = "重新计算"
L["customize.hint.recenter"] = "重置视角"
L["customize.hint.rotate"] = "旋转"
L["customize.hint.save"] = "保存"
L["customize.hint.select"] = "选择"
L["customize.hint.unattach"] = "卸下"
L["customize.hint.unfavorite"] = "取消收藏"
L["customize.hint.zoom"] = "缩放"

L["customize.trivia.description"] = "介绍"

L["customize.stats.explain.firepower"] = "近距离攻击时的潜在伤害。"
L["customize.stats.explain.rof"] = "武器的射速。"
L["customize.stats.explain.cyclic"] = "武器的循环射速。忽略连发延迟或装弹要求等因素。"
L["customize.stats.explain.capacity"] = "枪械弹匣 + 弹膛可容纳的弹药数量。"
L["customize.stats.explain.range"] = "枪械造成最小伤害的射程。"
L["customize.stats.explain.precision"] = "武器的精度。以精确度分钟(MOA)为单位。"
--L["customize.stats.explain.muzzlevelocity"] = "这把枪开火子弹的枪口速度。"
L["customize.stats.explain.shootentforce"] = "这把枪开火子弹的枪口速度。"
L["customize.stats.explain.ammo"] = "这把枪使用的弹药类型。"
L["customize.stats.explain.penetration"] = "这把枪可以穿透的物质数量。"
L["customize.stats.explain.ricochet"] = "这把枪子弹跳弹的最大几率。"
L["customize.stats.explain.armorpiercing"] = "这把枪完全无视大多数伤害抗性的伤害量。"
L["customize.stats.explain.explosive"] = "这把枪造成的爆炸伤害量。"
L["customize.stats.explain.speed"] = "使用这把枪时的移动速度。"
L["customize.stats.explain.aimtime"] = "从胯下射击瞄准镜向下瞄准所需的时间。"
L["customize.stats.explain.sprinttofire"] = "退出冲刺并开始射击所需的时间。"
L["customize.stats.explain.firemodes"] = "这把枪可以使用哪些射击模式。"
L["customize.stats.explain.burstdelay"] = "连开火击后，枪械可以再次射击的时间量。"
L["customize.stats.explain.triggerdelay"] = "扣动扳机与开枪之间的延迟时间"
L["customize.stats.explain.noise"] = "枪声的响度。"
L["customize.stats.explain.sway"] = "枪支的摇摆幅度"
L["customize.stats.explain.freeaim"] = "最大自由瞄准角度。越小越好。"
L["customize.stats.explain.supplylimit"] = "枪械可从 ARC9 弹药源获得的弹药数量"
L["customize.stats.explain.fusetimer"] = "投射物引爆前的延迟时间。根据投掷物的不同，计时器可能从引脚拉高时开始，也可能从释放时开始。"

L["customize.bench.dummy"] = "假人伤害测试"
L["customize.bench.effect"] = "测试距离"
L["customize.bench.ballistics"] = "弹道射程测试记录"
L["customize.bench.precision"] = "机械准度测试"

 -- not many space for those strings, be careful
L["customize.bench.ttk"] = "TTK: " -- TTK, Time to kill
L["customize.bench.ttk.instant"] = "即时"
L["customize.bench.ttk.shots"] = "子弹数: " -- STK, Shots to kill, you can use just shots in your language
L["customize.bench.ttk.withoneheadshot"] = "单发爆头:" -- TTK With One Headshot

L["customize.camoslot"] = "迷彩槽 %s"
L["customize.camoslot.none"] = "无迷彩"
L["customize.camoslot.canpaint"] = "\n\n此配件可以 <color=255,224,86>单独装配为</color>."
L["customize.camoslot.nosupport"] = "\n\n此配件可以 <color=255,224,86>单独装配为</color>, 但武器 <color=255,106,0>缺乏对它的支持</color>."
L["customize.camoslot.eftextra"] = "\n使用来自 <color=255,106,0>EFT Extras</color> 的配件来应用 <color=114,255,86>迷彩支持</color>."

L["folder.back"] = "返回"
L["folder.deselect"] = "取消选择"
L["folder.favorites"] = "收藏夹"
L["folder.select"] = "选择"

////////////////////// Numerical
L["number.1"] = "1"
L["number.2"] = "2"
L["number.3"] = "3"
L["number.4"] = "4"
L["number.5"] = "5"
L["number.6"] = "6"
L["number.7"] = "7"
L["number.8"] = "8"
L["number.9"] = "9"
L["number.10"] = "10"

L["number.alt.1"] = "一"
L["number.alt.2"] = "二"
L["number.alt.3"] = "三"
L["number.alt.4"] = "四"
L["number.alt.5"] = "五"
L["number.alt.6"] = "六"
L["number.alt.7"] = "七"
L["number.alt.8"] = "八"
L["number.alt.9"] = "九"
L["number.alt.10"] = "十"

////////////////////// Automatic stats
L["autostat.enable.pre"] = "启用"
L["autostat.disable.pre"] = "禁用"
L["autostat.enable.post"] = ""
L["autostat.disable.post"] = ""

L["autostat.aimdownsightstime"] = "瞄准耗时"
L["autostat.alwaysphysbullet"] = "使用物理弹道"
L["autostat.ammopershot"] = "弹药消耗"
L["autostat.armdamage"] = "手部伤害倍率"
L["autostat.armorpiercing"] = "穿甲强度"
L["autostat.autoburst"] = "自动点射"
L["autostat.autoreload"] = "自动装填"
L["autostat.bash"] = "近战攻击"
L["autostat.bashdamage"] = "近战伤害"
L["autostat.bashlungerange"] = "近战近身距离"
L["autostat.bashrange"] = "近战距离"
L["autostat.bashspeed"] = "近战速度"
L["autostat.bipod"] = "两脚架"
L["autostat.bottomlessclip"] = "无限弹夹"
L["autostat.breathholdtime"] = "屏吸时间"
L["autostat.bulletguidance"] = "制导子弹"
L["autostat.bulletguidanceamount"] = "制导强度"
L["autostat.canfireunderwater"] = "水下开火"
L["autostat.cantpeek"] = "禁用窥视"
L["autostat.chambersize"] = "弹膛装填量"
L["autostat.chestdamage"] = "胸口伤害倍率"
L["autostat.clipsize"] = "弹夹容量"
L["autostat.cycletime"] = "上膛耗时"
L["autostat.damagemax"] = "近距离伤害"
L["autostat.damagemin"] = "远距离伤害"
L["autostat.damagerand"] = "伤害随机性"
L["autostat.deploytime"] = "部署耗时"
L["autostat.distance"] = "子弹距离"
--L["autostat.entitymuzzlevelocity"] = "出膛速度"
L["autostat.shootentforce"] = "弹丸出膛速度"
L["autostat.explosiondamage"] = "爆炸伤害"
L["autostat.explosionradius"] = "爆炸范围"
L["autostat.fixtime"] = "卡弹修理耗时"
L["autostat.freeaimradius"] = "自由腰射角度"
L["autostat.headshotdamage"] = "爆头伤害倍率"
L["autostat.heatcapacity"] = "过热上限"
L["autostat.heatdissipation"] = "散热速度"
L["autostat.heatpershot"] = "开火过热量"
L["autostat.hybridreload"] = "非空单发装填"
L["autostat.impactforce"] = "冲击力"
L["autostat.infiniteammo"] = "无限弹药"
L["autostat.legdamage"] = "腿部伤害倍率"
L["autostat.malfunction"] = "卡弹"
L["autostat.malfunctionmeanshotstofail"] = "平均卡弹率"
L["autostat.malfunctionwait"] = "卡弹等待时间"
L["autostat.manualaction"] = "手动上膛"
L["autostat.manualactionchamber"] = "上膛弹药消耗"
L["autostat.neverphysbullet"] = "不使用物理弹道"
L["autostat.noflash"] = "无枪口火焰"
L["autostat.num"] = "出膛弹量"
L["autostat.overheat"] = "过热"
L["autostat.overheattime"] = "过热修理耗时"
L["autostat.dispersionspread"] = "子弹散射"
L["autostat.penetration"] = "穿透强度"
L["autostat.penetrationdelta"] = "穿透后的伤害"
L["autostat.physbulletdrag"] = "弹道阻力"
L["autostat.physbulletgravity"] = "弹道重力"
L["autostat.physbulletmuzzlevelocity"] = "出膛速度"
L["autostat.postburstdelay"] = "点射延迟"
L["autostat.pushbackforce"] = "后推力"
L["autostat.rangemax"] = "最大射程"
L["autostat.rangemin"] = "最小射程"
L["autostat.recoil"] = "后坐力"
L["autostat.recoilautocontrol"] = "后坐自动控制"
L["autostat.recoildissipationrate"] = "后坐恢复速率"
L["autostat.recoilkick"] = "后坐力强度"
L["autostat.recoilmodifiercap"] = "最大累积后坐力"
L["autostat.recoilpatterndrift"] = "后坐力漂移"
L["autostat.recoilpershot"] = "每次射击的后坐力"
L["autostat.recoilrandomside"] = "随机水平后坐力"
L["autostat.recoilrandomup"] = "随机垂直后坐力"
L["autostat.recoilresettime"] = "后坐重置时间"
L["autostat.recoilside"] = "水平后坐力"
L["autostat.recoilup"] = "垂直后坐力"
L["autostat.reloadtime"] = "装填耗时"
L["autostat.ricochetanglemax"] = "反弹角度"
L["autostat.ricochetchance"] = "反弹概率"
L["autostat.ricochetseeking"] = "窥视反弹"
L["autostat.ricochetseekingangle"] = "窥视反弹角度"
L["autostat.rpm"] = "射速"
L["autostat.runawayburst"] = "不间断点射"
L["autostat.secondarysupplylimit"] = "次要后备弹药上限"
L["autostat.shootvolume"] = "枪火响度"
L["autostat.shootwhilesprint"] = "冲刺时开火"
L["autostat.shotgunreload"] = "单发装填"
L["autostat.speed"] = "移动速度"
L["autostat.spread"] = "散射"
L["autostat.sprinttofiretime"] = "冲刺恢复耗时"
L["autostat.stomachdamage"] = "腹部伤害倍率"
L["autostat.supplylimit"] = "后备弹药上限"
L["autostat.sway"] = "偏移"
L["autostat.triggerdelay"] = "扳机延迟"
L["autostat.triggerdelaytime"] = "扳机延迟时间"
L["autostat.visualrecoil"] = "可视后坐力"
L["autostat.visualrecoilpunch"] = "可视后坐力击退"
L["autostat.visualrecoilroll"] = "可视后坐力横滚"
L["autostat.visualrecoilside"] = "水平可视后坐力"
L["autostat.visualrecoilup"] = "垂直可视后坐力"
L["autostat.rtscopemagnification"] = "瞄准镜放大倍率"
L["autostat.rtscopenew_fpslock"] = "显示帧率"
L["autostat.rtscopenew_pixelation"] = "显示分辨率"


--[[
Secondary autostats are now controlled by string.format.
This means that the above stats are displayed where the "%s" is located.
For example, "%s on Bipod" results in "Spread on Bipod".
Alternatively, "On Bipod: %s" results in "On Bipod: Spread".
]]--

L["autostat.secondary.bipod"] = "在双脚架上时%s"
L["autostat.secondary.crouch"] = "蹲下时%s"
L["autostat.secondary.empty"] = "最后一发子弹时%s"
L["autostat.secondary.evenreload"] = "偶数次装填时%s"
L["autostat.secondary.evenshot"] = "偶数发时%s"
L["autostat.secondary.first"] = "首发时%s"
L["autostat.secondary.firstshot"] = "首发时%s"
L["autostat.secondary.heated"] = "加热时%s"
L["autostat.secondary.hipfire"] = "腰射时%s"
L["autostat.secondary.hot"] = "加热时%s"
L["autostat.secondary.last"] = "最后一发子弹时%s"
L["autostat.secondary.lastshot"] = "最后一发子弹时%s"
L["autostat.secondary.midair"] = "在空中时%s"
L["autostat.secondary.move"] = "移动时%s"
L["autostat.secondary.oddreload"] = "奇数次装填时%s"
L["autostat.secondary.oddshot"] = "奇数发%s"
L["autostat.secondary.recoil"] = "后坐力%s" --"With Each Shot"
L["autostat.secondary.shooting"] = "开火时%s"
L["autostat.secondary.sighted"] = "瞄准时%s"
L["autostat.secondary.sights"] = "瞄准时%s"
L["autostat.secondary.silenced"] = "处于消音时%s"
L["autostat.secondary.sprint"] = " 冲刺时%s"
L["autostat.secondary.true"] = "真实名称开启时%s"
L["autostat.secondary.ubgl"] = "下挂武器时%s"

////////////////////// Blacklist menu
L["blacklist.title"] = "ARC9 配件黑名单"
L["blacklist.desc"] = "在此处选中的配件将被禁止使用"
L["blacklist.blisted"] = "黑名单"
L["blacklist.all"] = "所有"
L["blacklist.id"] = "ID"
L["blacklist.name"] = "名称"
L["blacklist.filter"] = "筛选"
L["blacklist.npc.title"] = "ARC9 武器替换管理器"
L["blacklist.npc.deselect"] = "取消全选"
L["blacklist.npc.select"] = "全选"
L["blacklist.npc.reset"] = "重置"
L["blacklist.npc.notfornpc"] = "（不适用于NPC）"
L["blacklist.npc.pistol"] = "手枪"
L["blacklist.npc.smg"] = "冲锋枪"
L["blacklist.npc.ar"] = "突击步枪"
L["blacklist.npc.shotgun"] = "霰弹枪"
L["blacklist.npc.sniper"] = "狙击枪"
L["blacklist.npc.rpg"] = "爆炸物"
L["blacklist.npc.frag"] = "手榴弹"
L["blacklist.npc.melee"] = "近战"
L["blacklist.npc.misc"] = "其他"

////////////////////// Incompatible addons
L["incompatible.title"] = "ARC9: 不兼容的模组"
L["incompatible.line1"] = "你安装了一些已知无法与 ARC9 配合使用的模组."
L["incompatible.line2"] = "禁用它们，否则就会出现BUG!"
L["incompatible.confirm"] = "明白"
L["incompatible.wait"] = "等待 {time}秒"
L["incompatible.never"] = "不要再警告我"
L["incompatible.never.hover"] = "你是否绝对确定你了解后果?"
L["incompatible.never.confirm"] = "你已选择不再显示不兼容警告。如遇到BUG相关问题，请自行承担责任."

////////////////////// Warning panel
L["badconf.title"] = "ARC9: 糟糕的GMOD设置警告"
L["badconf.line1"] = "某些 Garry's Mod 设置似乎造成了问题."
L["badconf.line2"] = "以下是已检测到的问题和解决方法."
L["badconf.confirm"] = "明白"
L["badconf.wait"] = "等待 {time}秒"

L["badconf.directx.title"] = "DirectX 版本过时"
L["badconf.directx.desc"] = "你目前运行的是 DirectX 8 或8.1。\n现代版 GMod 并不适合运行此版本，\n你可能无法看到大多数武器包上的模型。\n(dx9是21年前推出的！)。"
L["badconf.directx.solution"] = "解决方案：进入 Garry's Mod 的启动选项，\n在启动参数中插入\"-dxlevel 95 +mat_directx 95\"。\n如果那里列出了\"-dxlevel 70/80/85\"，请将其删除。"

L["badconf.tickrate.title"] = "服务器tickrate过低"
L["badconf.tickrate.desc"] = "你所在的服务器运行的 tickrate 很低。\nARC9 的最佳运行率至少为 20(建议 66 以上)。"
L["badconf.tickrate.solution"] = "解决方案：如果你是服务器所有者，\n那么在服务器启动配置中插入\"-tickrate 33\"或任何你想要的值。"

L["badconf.matbumpmap.title"] = "mat_bumpmap被禁用"
L["badconf.matbumpmap.desc"] = "你禁用了凹凸贴图，这会让武器\n看起来更糟糕。\n它还会破坏某些 ARC9 瞄具。"
L["badconf.matbumpmap.solution"] = "解决方法：在控制台中键入\"mat_bumpmap 1\". \n如果你使用的是任意一种 FPS 配置，那么从 \"autoexec.cfg\" 中找到并删除 mat_bumpmap 0 。"

L["badconf.addons.title"] = "模组过多！超过 Lua 文件限制！"
L["badconf.addons.desc"] = "你安装了太多模组，已达到 Lua 文件限制。\n因此 ARC9 无法正常初始化，这意味着配件可能无法使用。"
L["badconf.addons.solution"] = "解决方案：通过游戏内的'插件'菜单\n或Steam创意工坊卸载大型模组(例如其他武器base、JMod、实体包等)。"

L["badconf.warning"] = "警告！你的性能未达到最佳状态！- 悬停查看详情。"
L["badconf.warning.desc"] = "更多帧数总是好的。\n尤其是像这样的武器base。\n\n将光标悬停在下面的\n项目上可查看解决方案。"

L["badconf.x64.title"] = "► 检测到缓慢的 32 位分支"
L["badconf.x64.desc"] = [[你目前运行的是 32 位的 Garry's Mod。
这大大限制了你可以获得的性能。

解决方案：在 Garry's Mod 的"属性"中，
转到“测试版”并更改为"x86-64 - Chromium + 64-bit binaries"。

上网搜“gmod x64位”可以找到在线教程。]]

L["badconf.multicore.title"] = "► 无多核渲染命令"
L["badconf.multicore.desc"] = [[目前禁用了某些多核渲染设置。
这会导致游戏性能下降。

解决方案：你需要在 autoexec.cfg 中输入某些命令

上网搜“gmod multicore 多核渲染”可以找到在线教程。

以下命令都能提高性能：
gmod_mcore_test 1
mat_queue_mode 2
cl_threaded_bone_setup 1
r_threaded_client_shadow_
manager 1
r_threaded_renderables 1]]

////////////////////// Presets
L["customize.presets.atts"] = " 个配件"
L["customize.presets.back"] = "退回"
L["customize.presets.cancel"] = "取消"
L["customize.presets.code"] = "预设代码 (已复制到剪切板)"
L["customize.presets.default"] = "默认"
L["customize.presets.default.long"] = "默认设置"
L["customize.presets.dumb"] = "你弱智吗？"
L["customize.presets.import"] = "导入"
L["customize.presets.invalid"] = "无效字符串！"
L["customize.presets.new"] = "预设名"
L["customize.presets.paste"] = "输入预设代码"
L["customize.presets.random"] = "随机"
L["customize.presets.save"] = "保存"
L["customize.presets.unnamed"] = "未命名"

L["customize.presets.deldef"] = "你确定要删除\"{name}\"默认预设吗？"
L["customize.presets.deldef2"] = "你必须在开发者设置中重置武器才能恢复。"
L["customize.presets.yes"] = "确认"

////////////////////// Tips
L["tips.arc-9"] = "这是ARC9, 不是ARC-9, 更不是Arc9."
L["tips.blacklist"] = "你可以将配件拉入黑名单！更多信息，请参阅 ARC9 创意工坊的说明。"
L["tips.bugs"] = "在官方 Discord 服务器上报告错误，或者最好在 Github 反应问题。"
L["tips.custombinds"] = "ARC9 组合键可以用自定义绑定替换。控制台里键入 +arc9_ 查找可用的绑定！"
L["tips.cyberdemon"] = "要想杀死恐怖分子，就开枪打到他死为止。"
L["tips.description"] = "我们建议你在发评论前阅读模组的说明。"
L["tips.development"] = "想要开发 ARC9 的内容？官方 Discord 服务器有大量资源可以提供帮助！"
L["tips.discord"] = "加入钻石鸽的Discord！链接在 ARC9 说明和设置顶部。"
L["tips.external"] = "如果使用 Github 版本的 ARC9，请确保经常更新！"
L["tips.hints"] = "打开 ARC9 的 HUD，查看控制提示。"
L["tips.lean"] = "要手动侧身，请将按键绑定到 +alt1 和 +alt2。"
L["tips.love"] = "请随时告诉开发人员你对他们工作的赞赏！这对我们的工作很有帮助。"
L["tips.m9k"] = "查看 M9K 枪械！."
L["tips.official"] = "请从官方渠道下载 ARC9。第三方上传的内容可能是有病毒或过时的！"
L["tips.presets"] = "通过导出预设，与朋友分享你最喜欢的预设！"
L["tips.settings"] = "你可以在 ARC9 设置中关闭这些提示，还有更多。点击左上角的按键！"
L["tips.tips"] = "提示有固定的顺序。继续阅读，你最后会看到所有提示。"
L["tips.tolerance"] = "所有武器都能很好地配合使用。没有必要厚此薄彼。"
L["tips.togglehold"] = "如果你拥有大量激光器和手电筒，按住切换键即可打开菜单，轻松调整所有设备."

////////////////////// Other
L["atts.favourites"] = "收藏"
L["atts.filter"] = "筛选"

////////////////////// Spawnmenu
////////// Fancy
L["spawnmenu.spawnpreset"] = "使用预设生成"
L["spawnmenu.spawnpreset.default"] = "使用默认预设生成"
L["spawnmenu.spawnpreset.random"] = "使用随机预设生成"
L["spawnmenu.giveammo"] = "提供全部弹药"
L["spawnmenu.adminonly"] = "仅限管理员"

L["spawnmenu.resetpreset"] = "重置武器预设"
L["spawnmenu.resetpreset.rmb"] = "右键确认"

////////// Options
L["spawnmenu.settings"] = "ARC9 设置"
L["spawnmenu.settings.open"] = "打开 ARC9 设置"

L["spawnmenu.controller.input"] = "输入"
L["spawnmenu.controller.output"] = "输出"
L["spawnmenu.controller.glyphreplace"] = "写入字形应替换的输入"
L["spawnmenu.controller.glyphappear"] = "应显示哪个字形；点击下面的图标"
L["spawnmenu.controller.addapply"] = "添加 & 应用"
L["spawnmenu.controller.remove"] = "移除选择"
L["spawnmenu.controller.filter"] = "按手柄类型筛选"
L["spawnmenu.controller.displayall"] = "! 禁用全部 !"

L["spawnmenu.supermod.info"] = "在任何特殊条件下添加任何修改."
L["spawnmenu.supermod.stat"] = "数据"
L["spawnmenu.supermod.modifier"] = "修改器"
L["spawnmenu.supermod.selectstat"] = "选择要修改的数据"
L["spawnmenu.supermod.selectmod"] = "添加修改类型；某些数据没有这些类型"
L["spawnmenu.supermod.selectspec"] = "特殊情况，如蹲下时"
L["spawnmenu.supermod.selectval"] = "写入一个数值，或者 \"true\" / \"false\""
L["spawnmenu.supermod.result"] = "结果显示在此处"
L["spawnmenu.supermod.examples"] = [[
示例: 
∟ "Overheat" "true" 禁用过热功能
∟ "BottomlessClip" "true" 以启用无限弹药
∟ "RecoilMultCrouch" "0.1" 将蹲下时的后坐力降低到 10%
∟ "RPMMultOddShot" "0.5" 让每一发子弹都以半转速射出
]]

/////////////////////////////////////// Settings menu
////////////////////// Universal
-- Use this method to localize convars in settings menu:
-- settings.convar.title = "Convar Title"
-- settings.convar.desc = "Convar Description"

L["settings.title"] = "ARC9 设置"
L["settings.desc"] = "说明"

L["settings.default_convar"] = "默认值"
L["settings.convar_server"] = "服务器变量"
L["settings.convar_client"] = "客户端变量"

L["settings.disabled"] = "(禁用) "
L["settings.disabled.desc"] = "! 已被服务器管理员禁用 !\n\n"
L["settings.server"] = "\n\n这是一个服务器变量."

////////////////////// Quick Access
L["settings.tabname.quick"] = "快速访问"
L["settings.tabname.quick.desc"] = "在这里快速访问更重要的设置."

L["settings.quick.lang.title"] = "ARC9 语言"
L["settings.quick.lang.desc"] = "更改 ARC9 的显示语言.\n\n注：并非所有武器包\n都支持所有语言!"

L["settings.hud_game.hud_arc9.desc2"] = "在 \"游戏 HUD\"中进行调整\n\n使用 ARC9 武器时，启用自定义 LCD 显示 HUD"

L["settings.tpik.desc2"] = "在 \"视觉效果\"中进行调整\n\n启用 TPIK(第三人称逆运动动画).\n\n影响性能."

L["settings.aimassist.enable.desc2"] = "在 \"游戏性\"中进行调整\n\n启用瞄准辅助功能，如果检测到十字准星附近有有效目标，会将视角移近有效目标."

////////////////////// Reset Settings
L["settings.tabname.reset"] = "重置设置"
L["settings.tabname.reset.desc"] = "按 \"重置\" 按键可将 ARC9 设置完全重置为默认值."

L["settings.client.reset.title"] = "重置客户端设置"
L["settings.client.reset.desc"] = "完全重置所有 ARC9 客户端设置.\n\n警告: 不可逆转."

L["settings.server.reset.title"] = "重置服务器设置"
L["settings.server.reset.desc"] = "完全重置所有 ARC9 服务器设置.\n\n警告: 不可逆转."

L["settings.reset"] = "重置"

////////////////////// Game HUD
L["settings.tabname.hud_game"] = "游戏 HUD"

////////// ARC9 HUD
L["settings.server.hud_game.hud_arc9.title"] = "全面禁用 ARC9 HUD"
L["settings.server.hud_game.hud_arc9.desc"] = "禁用用户使用 ARC9 HUD 的能力."

L["settings.tabname.arc9_hud"] = "ARC9 HUD"
L["settings.tabname.arc9_hud.desc"] = "与 ARC9 的自定义 HUD 及其元素相关的所有内容."

L["settings.hud_game.hud_arc9.title"] = "启用 ARC9 HUD"
L["settings.hud_game.hud_arc9.desc"] = "使用 ARC9 武器时，启用自定义 LCD 显示 HUD."
L["settings.hud_game.hud_compact.title"] = "紧凑模式"
L["settings.hud_game.hud_compact.desc"] = "隐藏 ARC9 HUD 上的某些元素，使外观更紧凑."
L["settings.hud_game.hud_always.title"] = "在非 ARC9 武器上显示"
L["settings.hud_game.hud_always.desc"] = "使用非 ARC9 武器时启用自定义 HUD."

L["settings.hud_game.hints.title"] = "提示行为"
L["settings.hud_game.hints.desc"] = "选择始终显示、淡出或\n完全禁用控制提示."

L["settings.hud_game.hints.off"] = "始终关闭"
L["settings.hud_game.hints.fade"] = "淡出"
L["settings.hud_game.hints.on"] = "始终开启"

L["settings.hud_game.killfeed_enable.title"] = "自动生成击杀菜单图标"
L["settings.hud_game.killfeed_enable.desc"] = "在 ARC9 武器上自动生成击杀图标."
L["settings.hud_game.killfeed_dynamic.title"] = "动态图标"
L["settings.hud_game.killfeed_dynamic.desc"] = "获得击杀或更改配件时\n动态生成图标."
L["settings.hud_game.killfeed_colour.title"] = "色彩显示"
L["settings.hud_game.killfeed_colour.desc"] = "生成全彩而非黑白图标."

L["settings.hud_game.hud_scale.title"] = "HUD 大小"
L["settings.hud_game.hud_scale.desc"] = "更改 ARC9 HUD 和自定义菜单的大小比例.\n\n注：如果设置为 1 以下，ARC9 HUD 将被禁用."

L["settings.hud_game.hud_deadzonex.title"] = "HUD 水平盲区"
L["settings.hud_game.hud_deadzonex.desc"] = "更改 HUD 和自定义菜单的水平盲区。\n数值越大，就越向中心靠拢.\n\n适用于超宽屏显示器."

////////// Glyphs
L["settings.tabname.glyphs"] = "图标"
L["settings.tabname.glyphs.desc"] = "在 HUD 和自定义菜单中选择要显示的图标类型."

L["settings.hud_glyph.type_hud.title"] = "在 HUD 上"
L["settings.hud_glyph.type_hud.desc"] = "在 ARC9 HUD 和提示上使用哪些图标."
L["settings.hud_glyph.type_cust.title"] = "在自定义菜单中"
L["settings.hud_glyph.type_cust.desc"] = "在自定义菜单中使用哪些图标."

L["settings.hud_glyph.light"] = "浅色"
L["settings.hud_glyph.dark"] = "深色"
L["settings.hud_glyph.knockout"] = "击倒"

////////// Display Tooltips
L["settings.tabname.centerhint"] = "显示提示"
L["settings.tabname.centerhint.desc"] = "满足特定条件时，在 HUD 上\n显示提示."

L["settings.centerhint.reload.title"] = "弹药不足时"
L["settings.centerhint.reload.desc"] = "当弹匣达到一定百分比值时\n显示提示.\n\n同时显示要按的按键."
L["settings.centerhint.reload_percent.title"] = "百分比"
L["settings.centerhint.reload_percent.desc"] = "工具提示应在何时以百分比值显示."

L["settings.centerhint.bipod.title"] = "使用双脚架时"
L["settings.centerhint.bipod.desc"] = "在可以使用武器的双脚架时\n显示提示.\n\n同时显示要按的按键."

L["settings.centerhint.jammed.title"] = "卡壳时"
L["settings.centerhint.jammed.desc"] = "武器卡壳时显示提示.\n\n同时显示要按的按键."

L["settings.centerhint.firemode.title"] = "使用循环开火模式时"
L["settings.centerhint.firemode.desc"] = "循环开火模式时显示提示."

L["settings.centerhint.firemode_time.title"] = "显示时间"
L["settings.centerhint.firemode_time.desc"] = "工具提示在屏幕上的停留时间(以秒为单位)."

L["settings.centerhint.overheat.title"] = "过热时"
L["settings.centerhint.overheat.desc"] = "武器即将过热时显示提示."

////////////////////// Visuals
L["settings.tabname.visuals"] = "视觉效果"

////////// TPIK
L["settings.tabname.tpik"] = "TPIK - 第三人称逆运动动画"
L["settings.tabname.tpik.desc"] = "\"第三人称逆运动动画\" 是一个允许大多数武器使用\n第一人称动画和位置\n以第三人称显示的系统."

L["settings.tpik.title"] = "启用 TPIK"
L["settings.tpik.desc"] = "启用 TPIK (第三人称逆运动动画).\n\n影响性能."

L["settings.tpik_others.title"] = "其他玩家的 TPIK"
L["settings.tpik_others.desc"] = "显示其他玩家的 TPIK.\n\n影响性能."

L["settings.tpik_framerate.title"] = "TPIK 帧率"
L["settings.tpik_framerate.desc"] = "TPIK 运行的帧率.\n\n设置为 0 表示无限制.\n\n无限制或更高数值会影响性能."

L["settings.tpik_framerate_local.title"] = "本地玩家 TPIK 帧率"
L["settings.tpik_framerate_local.desc"] = "TPIK 计算在你的设备上运行的具体帧率.\n\n数值越高，对性能的影响越大."

////////// Blur
L["settings.tabname.blur"] = "景深效果"
L["settings.tabname.blur.desc"] = "满足特定条件时，应用模糊效果."

L["settings.blur.cust_blur.title"] = "自定义菜单背景"
L["settings.blur.cust_blur.desc"] = "自定义菜单背景进行模糊处理。"

L["settings.blur.fx_reloadblur.title"] = "装填时景深"
L["settings.blur.fx_reloadblur.desc"] = "装填时模糊背景。"

L["settings.blur.fx_animblur.title"] = "准备武器时景深"
L["settings.blur.fx_animblur.desc"] = "第一次掏出武器时模糊背景。"

L["settings.blur.fx_inspectblur.title"] = "检现时景深"
L["settings.blur.fx_inspectblur.desc"] = "检现武器时模糊背景."

L["settings.blur.fx_rtblur.title"] = "使用准镜时景深"
L["settings.blur.fx_rtblur.desc"] = "有倍率的准镜会模糊准镜外的视野。"

L["settings.blur.fx_adsblur.title"] = "瞄准时景深"
L["settings.blur.fx_adsblur.desc"] = "瞄准时在背景应用模糊效果.\n\n并非所有武器都支持此功能."

L["settings.blur.fx_adsblur_always.title"] = "武器景深始终开启"
L["settings.blur.fx_adsblur_always.desc"] = "与上述选项相同，\n但效果也适用于瞄准状态之外，\n使武器背面看起来像是失焦的。"

////////// Effects
L["settings.tabname.effects"] = "效果"
L["settings.tabname.effects.desc"] = "调整某些视觉效果."

L["settings.effects.eject_fx.title"] = "弹壳弹射烟雾"
L["settings.effects.eject_fx.desc"] = "为弹壳弹射增加额外效果\n(火花和烟雾).\n\n对性能的影响最小."

L["settings.effects.eject_time.title"] = "弹壳弹出时间"
L["settings.effects.eject_time.desc"] = "ARC9 弹射的弹壳应在地面上\n停留多长时间(以秒为单位).\n\n设为 -1 则禁用.\n\n根据值的不同，\n对性能的影响可能微乎其微."

L["settings.effects.muzzle_light.title"] = "枪口光照"
L["settings.effects.muzzle_light.desc"] = "在不使用消音器的情况下开火时，\n照亮周围区域.\n\n对性能的影响最小."

L["settings.effects.muzzle_others.title"] = "其他人的枪口效果"
L["settings.effects.muzzle_others.desc"] = "显示其他玩家 ARC9 武器\n的枪口效果.\n\n对性能的影响最小."

L["settings.effects.allflash.title"] = "其他人的手电筒"
L["settings.effects.allflash.desc"] = "渲染所有玩家的手电筒.\n\n影响性能."

L["settings.effects.lod.title"] = "LOD (细节程度) 距离"
L["settings.effects.lod.desc"] = "你需要离模型多远，它们才会在\n没有配件的情况下变为\n质量较低的变体.\n\n较低的数值会使模型在较低的\n距离上发生变化，从而提高性能.\n\n更高的值可能会影响性能，但可以\n在更远的距离上加载最高质量\n的模型.\n\nTPIK 的距离也会受到影响."

L["settings.effects.indoorsound.title"] = "室内音质"
L["settings.effects.indoorsound.desc"] = "室内音效检查应该有多详细.\n\n较低质量可提高性能，\n但可能导致室内声音不准确."

L["settings.effects.drawprojectedlights.title"] = "在第一人称模型上绘制投影灯光"
L["settings.effects.drawprojectedlights.desc"] = "! 实验性 !\n\n在配件和第一人称模型上\n绘制投影灯光/手电筒光束/级联阴影.\n\n可能影响性能.\n\n当 \"Real CSM\" 模组已启用时自动开启."

////////// Viewmodel Settings
L["settings.tabname.vm"] = "第一人称模型设置"
L["settings.tabname.vm.desc"] = "更改与第一人称模型相关的\n各种设置."

L["settings.vm.vm_bobstyle.title"] = "晃动风格"
L["settings.vm.vm_bobstyle.desc"] = "从ARC9团队(和Valve)慷慨提供的\n各种第一人称模型晃动风格中\n选择一种."

L["settings.vm.fov.title"] = "添加 FOV"
L["settings.vm.fov.desc"] = "将此值添加到第一人称模型的\n视角中.\n\n注意：如果设置过高或过低，\n可能会导致视觉错误."

L["settings.vm.vm_addx.title"] = "第一人称模型 X 轴"
L["settings.vm.vm_addx.desc"] = "左右移动的第一人称模型."

L["settings.vm.vm_addy.title"] = "第一人称模型 Y 轴"
L["settings.vm.vm_addy.desc"] = "上下移动第一人称模型."

L["settings.vm.vm_addz.title"] = "第一人称模型 Z 轴"
L["settings.vm.vm_addz.desc"] = "前后移动第一人称模型."

L["settings.vm.vm_cambob.title"] = "冲刺视角晃动"
L["settings.vm.vm_cambob.desc"] = "让视角在冲刺时晃动."

L["settings.vm.vm_cambobwalk.title"] = "步行视角晃动"
L["settings.vm.vm_cambobwalk.desc"] = "让视角在行走时晃动."

L["settings.vm.vm_cambobintensity.title"] = "力度"
L["settings.vm.vm_cambobintensity.desc"] = "冲刺和步行晃动的力度应该有多大."

L["settings.vm.vm_camstrength.title"] = "第一人称模型视角强度"
L["settings.vm.vm_camstrength.desc"] = "改变武器动画(如装弹或检查时)\n使用的视角移动强度.\n\n有助于减少(或增加)晕车症状.\n\n注意：可能会破坏\n某些武器包的性能."

L["settings.vm.vm_camrollstrength.title"] = "第一人称模型视角滚动强度"
L["settings.vm.vm_camrollstrength.desc"] = "改变武器动画(如装弹或检现时)\n使用的视角滚动强度.\n\n有助于减少(或增加)晕车症状"

L["settings.vm.vm_camrollstrength.title"] = "第一人称模型相机摇摄强度"
L["settings.vm.vm_camrollstrength.desc"] = "调整武器动画\n（例如重新装弹或检现武器时）\n所使用的相机摇摄动作强度.\n\n这有助于减轻（或加重）晕动症"

////////////////////// Crosshair & Scopes
L["settings.tabname.crosshairscopes"] = "十字准星和瞄准镜"
L["settings.tabname.crosshairscopes.desc"] = "调整十字准星和瞄准镜的相关设置."

////////// Crosshair
L["settings.tabname.crosshair"] = "十字准星"
L["settings.tabname.crosshair.desc"] = "调整与十字准星有关的设置."

L["settings.crosshair.cross_enable.title"] = "启用十字准星"
L["settings.crosshair.cross_enable.desc"] = "启用十字准星."

L["settings.crosshair.crosshair_force.title"] = "强制启用十字准星"
L["settings.crosshair.crosshair_force.desc"] = "即使在已禁用十字准星的武器上，\n也会强制启用十字准星."

L["settings.crosshair.crosshair_static.title"] = "静态十字准星"
L["settings.crosshair.crosshair_static.desc"] = "确保射击时十字准星不会移动.\n\n警告: 如果在十字准星不居中的\n武器上使用，\n会出现误差."

L["settings.crosshair.crosshair_target.title"] = "目标上的红色十字准星"
L["settings.crosshair.crosshair_target.desc"] = "悬停在玩家或 NPC 上时，将十字准星的颜色改为红色."

L["settings.crosshair.crosshair_peeking.title"] = "窥视时的十字准星"
L["settings.crosshair.crosshair_peeking.desc"] = "窥视时显示十字准星."

L["settings.crosshair.crosshair_sgstyle.title"] = "霰弹枪十字准星样式"
L["settings.crosshair.crosshair_sgstyle.desc"] = "更改使用同时开火两枚或更多子弹\n的武器时使用的十字准星样式.\n\n最后一个选项绘制的圆点数量\n与开火的射弹数量相等."

L["settings.crosshair.crosshair_sgstyle_fullcircle"] = "封闭式圆环"
L["settings.crosshair.crosshair_sgstyle_four"] = "4个半圆"
L["settings.crosshair.crosshair_sgstyle_two"] = "2个半圆"
L["settings.crosshair.crosshair_sgstyle_dots"] = "圆点"
L["settings.crosshair.crosshair_sgstyle_dots_accurate"] = "Proj. Nr. 点"

L["settings.crosshair.cross.title"] = "十字准星颜色"
L["settings.crosshair.cross.desc"] = "十字准星应该是什么颜色."

L["settings.crosshair.cross_size_mult.title"] = "十字准星尺寸"
L["settings.crosshair.cross_size_mult.desc"] = "将十字准星的大小乘以该值."

L["settings.crosshair.cross_size_dot.title"] = "十字准星圆点尺寸"
L["settings.crosshair.cross_size_dot.desc"] = "将十字准星中心点的大小乘以此值."

L["settings.crosshair.cross_size_prong.title"] = "十字准星棱线宽度"
L["settings.crosshair.cross_size_prong.desc"] = "将十字准星棱线的宽度乘以此值."

////////// Optics
L["settings.tabname.optics"] = "瞄具"
L["settings.tabname.optics.desc"] = "调整与瞄具及其功能相关的设置."

L["settings.gameplay.toggleads.title"] = "切换 ADS"
L["settings.gameplay.toggleads.desc"] = "按下瞄准按键可切换瞄准."

L["settings.gameplay.cheapscopes.title"] = "高性能准镜"
L["settings.gameplay.cheapscopes.desc"] = "通过放大玩家视角来进行瞄具渲染，\n而不是渲染两次。\n在较大的地图上会显著提升性能.\n\n可根据地图大小提高性能.\n\n不兼容 \"通过 RT 渲染武器\"."

L["settings.gameplay.fx_rtvm.title"] = "通过 RT 渲染武器"
L["settings.gameplay.fx_rtvm.desc"] = "! 实验性 !\n\n通过 RT 瞄准镜渲染武器及其配件.\n\n极大影响性能.\n\n不兼容 \"高性能准镜\"."

L["settings.gameplay.compensate_sens.title"] = "动态 ADS 灵敏度"
L["settings.gameplay.compensate_sens.desc"] = "根据武器变焦和倍率\n动态调整瞄准灵敏度."

L["settings.gameplay.sensmult.title"] = "倍增 ADS 灵敏度"
L["settings.gameplay.sensmult.desc"] = "将该值倍增全局瞄准灵敏度.\n\n数值越低，灵敏度越低."

L["settings.gameplay.gradualsens.title"] = "渐变 ADS 灵敏度"
L["settings.gameplay.gradualsens.desc"] = "在进入或退出 ADS 时逐步调整瞄准灵敏度."

L["settings.gameplay.color.reflex.title"] = "反光镜颜色"
L["settings.gameplay.color.reflex.desc"] = "反射式瞄准镜或全息瞄准镜上使用\n的视网膜应是什么颜色.\n\n并非所有瞄具都支持此功能."

L["settings.gameplay.color.scope.title"] = "瞄准镜视网膜颜色"
L["settings.gameplay.color.scope.desc"] = "RT瞄准镜上使用的视网膜\n应是什么颜色.\n\n并非所有瞄具都支持此功能."

L["settings.gameplay.fx_rt_alwaysdraw.title"] = "渲染 RT 瞄准镜预览"
L["settings.gameplay.fx_rt_alwaysdraw.desc"] = "当瞄准镜朝向屏幕中心时，\n即使不在瞄准状态，\n也会绘制带准星的预览图像.\n\n对性能影响不大，\n内部使用了高性能瞄准镜."

L["settings.gameplay.fx_rt_shader.title"] = "RT 瞄准镜中的炫酷着色"
L["settings.gameplay.fx_rt_shader.desc"] = "在RT瞄准镜中绘制炫酷的色差、\n镜头畸变和复杂的视差效果.\n\n不确定是否会影响性能，\n因为它只是一个简单的 GPU 着色器.\n\n基于 shadertoy.com/view/WX2cRd，由 science6uru2 制作."

L["settings.gameplay.fx_rt_fxaa.title"] = "RT 瞄准镜中的 FXAA"
L["settings.gameplay.fx_rt_fxaa.desc"] = "一个简单的快速近似抗锯齿 (FXAA) 着色器，可以让瞄准镜画面更柔和，因为 Source 引擎的 MSAA 在渲染目标视图上不起作用.\n\n由 Evgeny Akabenko 移植，经授权使用."

////////////////////// Gameplay
L["settings.tabname.gameplay"] = "游戏性"

////////// General
L["settings.tabname.general"] = "常规"
L["settings.tabname.general.desc"] = "各种常规游戏设置."

L["settings.gameplay.dtap_sights.title"] = "双击使用键切换循环瞄准器"
L["settings.gameplay.dtap_sights.desc"] = "你可以双击使用键来循环使用瞄具."

L["settings.gameplay.autoreload.title"] = "自动装弹"
L["settings.gameplay.autoreload.desc"] = "武器空弹时自动重新装弹."

L["settings.server.gameplay.recoilshake.title"] = "启用后坐力 FOV 抖动"
L["settings.server.gameplay.recoilshake.desc"] = "射击时固定视野。"

L["settings.server.gameplay.recoilcamshake.title"] = "启用后坐力镜头抖动"
L["settings.server.gameplay.recoilcamshake.desc"] = "射击时摇晃相机滚动角度。"

////////// Functionality
L["settings.tabname.features"] = "功能"
L["settings.tabname.features.desc"] = "调整与 ARC9 各种功能相关的设置."

L["settings.server.gameplay.mod_sway.title"] = "启用武器摇摆"
L["settings.server.gameplay.mod_sway.desc"] = "启用武器摇摆功能\n(如果武器支持该功能).\n\n武器会左右移动，\n导致第一人称模型\n和十字准星偏离屏幕中心."

L["settings.server.gameplay.breath_slowmo.title"] = "屏住呼吸时启用慢动作(单人游戏)"
L["settings.server.gameplay.breath_slowmo.desc"] = "! 仅限单人游戏 !\n屏住呼吸让时间变慢."

L["settings.server.gameplay.breath_infinite.title"] = "无限屏息"
L["settings.server.gameplay.breath_infinite.desc"] = "屏住呼吸不会消耗呼吸量."

L["settings.gameplay.togglebreath.title"] = "切换屏气"
L["settings.gameplay.togglebreath.desc"] = "按下冲刺按键可切换屏住呼吸."

L["settings.centerhint.breath_hud.title"] = "屏住呼吸工具提示"
L["settings.centerhint.breath_hud.desc"] = "屏住呼吸时，\n显示剩余呼吸量的条形图."

L["settings.centerhint.breath_pp.title"] = "屏住呼吸的后期处理"
L["settings.centerhint.breath_pp.desc"] = "憋气时还能应用后期处理效果.\n\n屏住呼吸时需要使用\n武器摇摆或慢动作."

L["settings.server.gameplay.mod_peek.title"] = "启用窥视"
L["settings.server.gameplay.mod_peek.desc"] = "如果武器支持窥视功能，\n则启用窥视功能.\n\n允许用户在瞄准时降低武器，\n同时仍可获得瞄准效果."

L["settings.gameplay.togglepeek.title"] = "切换窥视"
L["settings.gameplay.togglepeek.desc"] = "按下窥视按键可切换窥视功能."

L["settings.gameplay.togglepeek_reset.title"] = "瞄准后重置窥视"
L["settings.gameplay.togglepeek_reset.desc"] = "停止瞄准时禁用窥视."

L["settings.server.aimassist.enable.title"] = "允许瞄准辅助"
L["settings.server.aimassist.enable.desc"] = "使用户能够利用瞄准辅助功能."

L["settings.aimassist.enable.title"] = "启用瞄准辅助"
L["settings.aimassist.enable.desc"] = "启用瞄准辅助功能，如果检测到\n十字准星附近有目标，\n可将视角移近有效目标."

L["settings.aimassist.sensmult.desc"] = "在瞄准有效目标时，如果检测到\n十字准星附近有目标，\n则将瞄准灵敏度乘以此值."

L["settings.server.aimassist.intensity.title"] = "瞄准辅助强度"
L["settings.server.aimassist.intensity.desc"] = "瞄准辅助的强度应该有多大."

L["settings.server.aimassist.cone.title"] = "瞄准辅助锥面"
L["settings.server.aimassist.cone.desc"] = "瞄准辅助应在多大范围内起作用。\n区域越大，有效目标的距离就越远."

L["settings.server.aimassist.heads.title"] = "锁定头部"
L["settings.server.aimassist.heads.desc"] = "启用瞄准辅助是否应瞄准目标头部而非胸部."

L["settings.server.gameplay.manualbolt.title"] = "需要手动循环"
L["settings.server.gameplay.manualbolt.desc"] = "如果用户应通过按下\n手动操作武器的装弹键来\n手动操作武器，则启用该功能."

L["settings.server.gameplay.lean.title"] = "允许侧身"
L["settings.server.gameplay.lean.desc"] = "允许用户向左或向右侧身。也适用于自动侧身."

L["settings.gameplay.autolean.title"] = "自动侧身"
L["settings.gameplay.autolean.desc"] = "靠近掩体时自动尝试侧身."

L["settings.gameplay.togglelean.title"] = "切换侧身"
L["settings.gameplay.togglelean.desc"] = "按下左侧或右侧按键可切换侧身角度."

L["settings.server.gameplay.mod_freeaim.title"] = "启用自由瞄准"
L["settings.server.gameplay.mod_freeaim.desc"] = "如果武器支持自由瞄准，\n则启用该功能.\n\n允许瞄准点与屏幕中心分离."

L["settings.server.gameplay.never_ready.title"] = "禁用准备动画"
L["settings.server.gameplay.never_ready.desc"] = "启用或禁用首次拿出武器时\n的武器准备动画."

L["settings.server.gameplay.infinite_ammo.title"] = "启用无限弹药"
L["settings.server.gameplay.infinite_ammo.desc"] = "武器装弹时不再需要弹药."

L["settings.server.gameplay.mult_defaultammo.title"] = "默认备用弹药"
L["settings.server.gameplay.mult_defaultammo.desc"] = "当武器拿出时，玩家会获得多少个\n备用弹夹或装备."

L["settings.server.gameplay.equipment_generate_ammo.title"] = "为装备生成独特的弹药"
L["settings.server.gameplay.equipment_generate_ammo.desc"] = "起源引擎有255种弹药类型的限制。\n如果你安装了很多模组，\n禁用此选项有助于修复错误.\n\n需要重启."

L["settings.server.gameplay.realrecoil.title"] = "启用物理视觉后坐力"
L["settings.server.gameplay.realrecoil.desc"] = "各种武器都设置了物理枪口升高，\n这意味着它们会在\n第一人称模型指向的位置射击，\n而不是屏幕中心位置.\n\n对某些武器包的平衡方案非常重要."

L["settings.server.gameplay.mod_bodydamagecancel.title"] = "取消身体伤害"
L["settings.server.gameplay.mod_bodydamagecancel.desc"] = "取消默认的身体伤害乘数.\n\n只有在其他模式提供此类功能时才禁用."

////////////////////// Customization
L["settings.tabname.customization"] = "自定义"

////////// Customization Menu
L["settings.tabname.custmenu"] = "自定义菜单"
L["settings.tabname.custmenu.desc"] = "调整与自定义菜单相关的设置."

L["settings.custmenu.hud_color.title"] = "自定义菜单颜色"
L["settings.custmenu.hud_color.desc"] = "更改自定义菜单的颜色."

L["settings.custmenu.hud_lightmode.title"] = "浅色模式"
L["settings.custmenu.hud_lightmode.desc"] = "将自定义菜单的配色方案更改\n为浅色.\n\n原版 ARC9 的配色方案."

L["settings.custmenu.hud_holiday.title"] = "节日模式"
L["settings.custmenu.hud_holiday.desc"] = "更改自定义菜单的配色方案，使其\n与特定节日相匹配.\n\n覆盖 \"自定义菜单颜色\"."

L["settings.custmenu.cust_light.title"] = "启用灯光"
L["settings.custmenu.cust_light.desc"] = "启用灯光，更容易看清武器."

L["settings.custmenu.cust_light_brightness.title"] = "灯光亮度"
L["settings.custmenu.cust_light_brightness.desc"] = "调整灯光亮度."

L["settings.custmenu.cust_hints.title"] = "启用控制提示"
L["settings.custmenu.cust_hints.desc"] = "在自定义菜单右下方显示控制提示."

L["settings.custmenu.cust_tips.title"] = "启用常规提示"
L["settings.custmenu.cust_tips.desc"] = "在自定义菜单左下方显示一般提示."

L["settings.custmenu.cust_exit_reset_sel.title"] = "关闭时重置活动插槽"
L["settings.custmenu.cust_exit_reset_sel.desc"] = "如果启用，重新打开菜单时将\n重置活动\n的自定义槽."

L["settings.custmenu.autosave.title"] = "自动保存配件"
L["settings.custmenu.autosave.desc"] = "退出自定义菜单时自动保存装备的\n配件。在武器重生时自动重新加载."

L["settings.server.gameplay.truenames.title"] = "启用真实名称"
L["settings.server.gameplay.truenames.desc"] = "允许使用真实名称的武器显示\n替代虚构名称.\n\n并非所有武器都支持此功能."

L["settings.fancyspawnmenu.title"] = "启用花式生成菜单"
L["settings.fancyspawnmenu.desc"] = "在所有 ARC9 武器类别中启用更新的\n花式生成菜单.\n\n需要重新加载生成菜单才能应用 (控制台命令: \"spawnmenu_reload\")"

L["settings.custmenu.units.title"] = "显示单位"
L["settings.custmenu.units.desc"] = "在自定义菜单中选择显示\n公制或英制单位."
L["settings.custmenu.units.metric"] = "公制"
L["settings.custmenu.units.imperial"] = "英制"

L["settings.gameplay.font.title"] = "自定义字体"
L["settings.gameplay.font.desc"] = "写入应在 ARC9 上使用的自定义字体.\n\n注 1：字体必须安装在你当前的\n计算机上.\n\n注 2：名称应是 TTF 文件中显示的字体名称，而不是 TTF 的文件名称."

L["settings.gameplay.controller.title"] = "手柄模式"
L["settings.gameplay.controller.desc"] = "启用自定义手柄友好元素."

L["settings.gameplay.controllerglyphs.title"] = "手柄字形"
L["settings.gameplay.controllerglyphs.desc"] = "打开一个单独的菜单，可以更改启用手柄模式时显示的字形."

////////////////////// Attachments & NPCs
L["settings.tabname.attachmentsnpcs"] = "配件和 NPC"

////////// Customization
L["settings.tabname.customization.desc"] = "调整与武器定制相关的设置."

L["settings.server.custmenu.atts_nocustomize.title"] = "禁用自定义"
L["settings.server.custmenu.atts_nocustomize.desc"] = "禁用用户打开自定义菜单的功能.\n\n不影响管理员."

L["settings.server.custmenu.blacklist.title"] = "黑名单菜单"
L["settings.server.custmenu.blacklist.desc"] = "打开一个菜单，允许完全禁用\n某些配件."
L["settings.server.custmenu.blacklist.open"] = "打开菜单"

L["settings.server.custmenu.atts_max.title"] = "最大配件数"
L["settings.server.custmenu.atts_max.desc"] = "用户可装备在武器上的配件\n(包括外观配件)的最大数量."

L["settings.server.custmenu.free_atts.title"] = "免费配件"
L["settings.server.custmenu.free_atts.desc"] = "无需先拾取即可使用配件."

L["settings.server.custmenu.atts_lock.title"] = "无限配件单位"
L["settings.server.custmenu.atts_lock.desc"] = "如果禁用，用户拥有一个配件并将其装备到武器上，则无法将其装备到其他武器上，除非拥有多个该配件."

L["settings.server.custmenu.atts_loseondie.title"] = "因死亡而失去配件"
L["settings.server.custmenu.atts_loseondie.desc"] = "如果用户死亡，他们将丢失所有配件."

L["settings.server.custmenu.atts_generateentities.title"] = "生成配件实体"
L["settings.server.custmenu.atts_generateentities.desc"] = "生成可通过生成菜单生成的实体, 以便在禁用 \"免费配件\" 时拾取配件.\n\n增加加载时间."

////////// NPC Settings
L["settings.tabname.npc"] = "NPC 设置"
L["settings.tabname.npc.desc"] = "调整与 NPC 互动的设置."

L["settings.server.npc.blacklist.title"] = "武器替换管理器"
L["settings.server.npc.blacklist.desc"] = "打开一个菜单，可以单独为每种 HL2 武器排除或包含特定武器到替换池里。"

L["settings.server.npc.npc_autoreplace.title"] = "替换 NPC 武器"
L["settings.server.npc.npc_autoreplace.desc"] = "使用 HL2 武器生成的 NPC 将被替换为 ARC9 武器."

L["settings.server.npc.npc_atts.title"] = "为 NPC 武器提供随机配件"
L["settings.server.npc.npc_atts.desc"] = "使用 ARC9 武器的 NPC 将随机获得一套配件"

L["settings.server.npc.replace_spawned.title"] = "更换掉在地上的武器"
L["settings.server.npc.replace_spawned.desc"] = "用随机选择的 ARC9 武器替换地图或生成的 HL2 武器"

L["settings.server.npc.ground_atts.title"] = "为掉在地上的武器提供随机配件"
L["settings.server.npc.ground_atts.desc"] = "在地面上生成的武器将随机获得一套配件."

L["settings.server.npc.npc_give_weapons.title"] = "允许玩家与 NPC 互换武器"
L["settings.server.npc.npc_give_weapons.desc"] = "允许玩家对 NPC 按使用键，以赠送或交换 ARC9 武器."

L["settings.server.npc.npc_equality.title"] = "启用 NPC 伤害平等"
L["settings.server.npc.npc_equality.desc"] = "NPC 使用 ARC9 武器造成的伤害与玩家相同."

L["settings.server.npc.npc_spread.title"] = "NPC 武器精度"
L["settings.server.npc.npc_spread.desc"] = "当 NPC 的武器开火时，倍增武器精度."

////////////////////// Bullet Physics
L["settings.tabname.bulletphysics"] = "物理子弹"

////////// Bullet Physics
L["settings.tabname.bulletphysics.desc"] = "调整与物理子弹相关的设置."

L["settings.server.bulletphysics.bullet_physics.title"] = "启用物理子弹"
L["settings.server.bulletphysics.bullet_physics.desc"] = "支持此功能的武器可开火物理子弹，\n这些子弹受子弹下落、\n拖曳和移动时间的影响."

L["settings.server.bulletphysics.bullet_gravity.title"] = "子弹重力"
L["settings.server.bulletphysics.bullet_gravity.desc"] = "重力对物理子弹的影响有多大."

L["settings.server.bulletphysics.bullet_drag.title"] = "子弹阻力"
L["settings.server.bulletphysics.bullet_drag.desc"] = "物理子弹的空气阻力有多大."

L["settings.server.bulletphysics.bullet_lifetime.title"] = "子弹消失时间"
L["settings.server.bulletphysics.bullet_lifetime.desc"] = "以秒为单位，一颗实体子弹从存在中消失需要多长时间."

L["settings.server.bulletphysics.bullet_physics_shotguns.title"] = "霰弹枪的物理子弹"
L["settings.server.bulletphysics.bullet_physics_shotguns.desc"] = "霰弹枪也使用物理子弹，否则他们会使用命中扫描."

L["settings.server.bulletphysics.ricochet.title"] = "启用子弹反弹"
L["settings.server.bulletphysics.ricochet.desc"] = "允许子弹从坚硬表面反弹，\n可能击中毫无防备的敌人.\n\n效果取决于武器."

L["settings.server.bulletphysics.mod_penetration.title"] = "启用子弹穿透"
L["settings.server.bulletphysics.mod_penetration.desc"] = "允许子弹穿透掩体，\n可能击中躲在掩体后面的敌人.\n\n效果取决于武器."

////////////////////// Modifiers
L["settings.tabname.modifiers"] = "修改器"

////////// Quick Stat Modifiers
L["settings.tabname.quickstat"] = "快速数据修改"
L["settings.tabname.quickstat.desc"] = "快速调整特定武器修改."

L["settings.server.quickstat.mod_damage.title"] = "伤害"

L["settings.server.quickstat.mod_malfunction.title"] = "故障几率"

L["settings.server.quickstat.mod_damage.desc"] = "倍增武器造成的伤害."
L["settings.server.quickstat.mod_spread.desc"] = "倍增武器的散射范围."
L["settings.server.quickstat.mod_dispersionspread.desc"] = "将霰弹枪的散射范围乘以\n霰弹枪的散射范围."
L["settings.server.quickstat.mod_recoil.desc"] = "倍增武器的后坐力."
L["settings.server.quickstat.mod_visualrecoil.desc"] = "乘以武器的视觉后坐力大小."
L["settings.server.quickstat.mod_adstime.desc"] = "倍增武器进出 ADS 的速度."
L["settings.server.quickstat.mod_sprinttime.desc"] = "倍增武器进入和退出冲刺的速度."
L["settings.server.quickstat.mod_damagerand.desc"] = "倍增伤害差异，\n可随机增加或减少伤害."
L["settings.server.quickstat.mod_muzzlevelocity.desc"] = "倍增物理子弹的移动速度."
L["settings.server.quickstat.mod_rpm.desc"] = "武器开火速度的倍数."
L["settings.server.quickstat.mod_headshotdamage.desc"] = "倍增武器爆头时的伤害值."
L["settings.server.quickstat.mod_malfunction.desc"] = "倍增武器发生故障的可能性."

L["settings.server.gameplay.mod_overheat.title"] = "启用过热"
L["settings.server.gameplay.mod_overheat.desc"] = "如果武器支持该功能，则在\n频繁开火时可能会过热，从而\n导致故障."

L["settings.server.gameplay.mod_nearwall.title"] = "启用贴墙时收起武器功能"
L["settings.server.gameplay.mod_nearwall.desc"] = "启用贴墙时收起武器功能"

L["settings.server.gameplay.supermod.title"] = "超级修改器"
L["settings.server.gameplay.supermod.desc"] = "打开一个单独的菜单，\n可在所有武器上应用任何修改.\n\n警告: 如果操作不当，\n可能导致武器无法继续使用."

////////////////////// Developer
L["settings.tabname.developer"] = "开发者"

////////// Developer Settings
L["settings.tabname.developer.settings"] = "开发者设置"
L["settings.tabname.developer.settings.desc"] = "开发人员的常规设置."

L["settings.server.developer.reloadlangs.title"] = "重新加载语言"
L["settings.server.developer.reloadlangs.desc"] = "重新加载所有 ARC9 语言文件."

L["settings.server.developer.reloadatts.title"] = "重新加载配件"
L["settings.server.developer.reloadatts.desc"] = "重新加载所有 ARC9 配件."

L["settings.server.developer.dev_always_ready.title"] = "始终准备就绪"
L["settings.server.developer.dev_always_ready.desc"] = "启用后，武器将始终播放 \"准备就绪\" 动画."

L["settings.server.developer.dev_benchgun.title"] = "长枪"
L["settings.server.developer.dev_benchgun.desc"] = "启用后，第一人称模型将保持原位，\n与你所处的位置无关."

L["settings.server.developer.dev_crosshair.title"] = "开发人员十字准星"
L["settings.server.developer.dev_crosshair.desc"] = "时髦的十字准星显示精确的瞄准点\n和一些有用的变量.\n\n只对管理员有效；\n不要试图用它作弊."

L["settings.server.developer.dev_show_affectors.title"] = "显示效果"
L["settings.server.developer.dev_show_affectors.desc"] = "在 \"开发人员十字准星\"上，显示当前应用了哪些影响效果."

L["settings.server.developer.dev_show_shield.title"] = "显示盾牌"
L["settings.server.developer.dev_show_shield.desc"] = "显示玩家盾牌的保护模型."

L["settings.server.developer.dev_greenscreen.title"] = "绿幕"
L["settings.server.developer.dev_greenscreen.desc"] = "在自定义菜单中应用绿幕背景.\n\n适用于截图.\n\n如果使用 HDR，不要忘记设置 \"\nmat_bloom_scalefactor_scalar\" 至 0!"

L["settings.server.developer.presets_clear.title"] = "清除武器数据"
L["settings.server.developer.presets_clear.desc"] = "清除当前所持武器的预设、\n图标和默认预设.\n\n警告: 如果在未装备 ARC9 武器的情况下使用，它将清除所有 ARC9 武器的预设、图标和默认设置."

L["settings.server.developer.reload"] = "重新加载"
L["settings.server.developer.clear"] = "清除"

L["settings.developer.ignore_dx.title"] = "忽略 DirectX 警告"
L["settings.developer.ignore_dx.desc"] = "忽略有关当前 DirectX 警告不是 9 的警告，在 linux 或其他系统上有用."

////////// Asset Caching
L["settings.tabname.assetcache"] = "资产缓存"
L["settings.tabname.assetcache.desc"] = "缓存某些资产可防止卡顿，\n使游戏性更舒适.\n\n如果在硬盘上运行，或有大量模组，\n这些选项将改善初始加载时间."

L["settings.server.assetcache.precache_sounds_onfirsttake.title"] = "装备武器时: 预缓存音效"
L["settings.server.assetcache.precache_sounds_onfirsttake.desc"] = "缓存装备的 ARC9 武器的射击音效.\n\n首次装备武器时\n可能会导致游戏小幅卡顿."

L["settings.server.assetcache.precache_attsmodels_onfirsttake.title"] = "装备武器时: 预缓存配件"
L["settings.server.assetcache.precache_attsmodels_onfirsttake.desc"] = "装备任意 ARC9 武器时，缓存所有 ARC9 配件模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache.precache_wepmodels_onfirsttake.title"] = "装备武器时: 预缓存武器模型"
L["settings.server.assetcache.precache_wepmodels_onfirsttake.desc"] = "装备任意 ARC9 武器时，缓存所有 ARC9 第一人称模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache.precache_allsounds_onstartup.title"] = "游戏开始时: 预缓存音效"
L["settings.server.assetcache.precache_allsounds_onstartup.desc"] = "服务器启动时，缓存所有 ARC9 武器的所有射击音效.\n\n可能导致游戏暂时卡顿."

L["settings.server.assetcache.precache_attsmodels_onstartup.title"] = "游戏开始时: 预缓存配件"
L["settings.server.assetcache.precache_attsmodels_onstartup.desc"] = "服务器启动时缓存所有 ARC9 配件模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache.precache_wepmodels_onstartup.title"] = "游戏开始时: 预缓存武器模型"
L["settings.server.assetcache.precache_wepmodels_onstartup.desc"] = "服务器启动时缓存所有 ARC9 第一人称模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache.precache_allsounds.title"] = "预缓存所有音效"
L["settings.server.assetcache.precache_allsounds.desc"] = "缓存所有 ARC9 武器的所有射击音效.\n\n可能导致游戏暂时卡顿."

L["settings.server.assetcache.precache_attsmodels.title"] = "预缓存所有配件模型"
L["settings.server.assetcache.precache_attsmodels.desc"] = "缓存所有 ARC9 配件模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache.precache_wepmodels.title"] = "预缓存所有武器模型"
L["settings.server.assetcache.precache_wepmodels.desc"] = "缓存所有 ARC9 第一人称模型.\n\n可能会导致\n游戏长时间卡顿，这取决于你拥有\n多少 ARC9 武器."

L["settings.server.assetcache"] = "缓存"
L["settings.server.assetcache.all"] = "缓存全部"

////////// Print to Console
L["settings.tabname.printconsole"] = "打印到控制台"
L["settings.tabname.printconsole.desc"] = "在其中任何一个内容上按 \"打印\" 它们就会将请求的内容\n打印到开发者控制台中."

L["settings.server.printconsole.dev_listmyatts.title"] = "打印我的配件"
L["settings.server.printconsole.dev_listmyatts.desc"] = "打印当前配备的所有配件的\n内部名称."

L["settings.server.printconsole.dev_listanims.title"] = "打印动画列表"
L["settings.server.printconsole.dev_listanims.desc"] = "打印完整的内部动画列表，\n包括动画长度."

L["settings.server.printconsole.dev_listbones.title"] = "打印骨骼列表"
L["settings.server.printconsole.dev_listbones.desc"] = "打印第一人称模型骨骼的\n全部骨骼列表."

L["settings.server.printconsole.dev_listbgs.title"] = "打印 Bodygroups"
L["settings.server.printconsole.dev_listbgs.desc"] = "打印第一人称模型 bodygroups 的完整列表."

L["settings.server.printconsole.dev_listatts.title"] = "打印 QCAttachments"
L["settings.server.printconsole.dev_listatts.desc"] = "打印第一人称模型的所有 QCAttachments."

L["settings.server.printconsole.dev_listmats.title"] = "打印材质列表"
L["settings.server.printconsole.dev_listmats.desc"] = "打印第一人称模型上使用的\n所有材质."

L["settings.server.printconsole.dev_export.title"] = "打印导出代码"
L["settings.server.printconsole.dev_export.desc"] = "打印武器当前装备配件的\n导出代码.\n\n可存储或与其他用户\n共享，以快速加载配件列表."

L["settings.server.printconsole.dev_getjson.title"] = "打印武器 JSON"
L["settings.server.printconsole.dev_getjson.desc"] = "打印武器的 JSON 条目."

L["settings.server.printconsole"] = "打印"

////////////////////// ARC9 Premium
L["premium.title"] = "ARC9 高级版"
L["premium.desc"] = "ARC9 高级版允许额外的自定义功能，以感谢用户在经济上对该模组的支持."

L["premium.requires"] = "需要 <color=255,106,0>ARC9 高级版</color>."
L["premium.acquire"] = "订阅 <color=255,106,0>ARC9 高级版</color>"

L["premium.ownedno"] = "<color=255,106,0>ARC9 高级版</color>: <color=255,100,100>未拥有</color>"
L["premium.owned"] = "<color=255,106,0>ARC9 高级版</color>: <color=255,100,100>已拥有</color>"

L["premium.help"] = "什么是 ARC9 高级版?"
L["premium.help.header"] = "关于 ARC9 高级版的指南"
L["premium.help.desc"] = "制作模组需要时间和资源。ARC9一直是免费提供的，今后也将如此。但是，如果你希望在经济上支持基础版，你可以这样做，并因此获得奖励!"

L["premium.help.ownedbutnoaccess"] = "你最近购买了 ARC9 高级版，但无法自动访问？请在钻石鸽的 Discord 服务器上联系我们寻求帮助.\n确保你在联系之前能提供购买证明。仅仅说 \"我买了快给我\" 是不够的."

L["premium.content"] = "包含在 <color=255,106,0>ARC9 高级版</color>:"
L["premium.content.list"] = [[
- 无限定制插槽(增加到 32 个)
- 无限预设插槽(每种武器增加到 10 个)
- 访问超级修改器设置*
- 访问专属的 RGB UI 模式
- 通过Base提供的独家迷彩
- Discord 上的专属支持频道**
- 全新改进的专属生成菜单设计**
- 改进 TPIK 性能和外观**

*如果在服务器上，则需要管理员操作
**不适用于 <color=255,106,0>免费试用版</color>
]]

L["premium.purchased"] = "<color=255,106,0>ARC9 高级版</color> 已购买!"
L["premium.purchased.desc"] = [[
感谢你购买 ARC9 高级版! 你让一只小鸟非常快乐!

收据将发送到你链接的电子邮件.

如果你没有立即获得 ARC9 高级版奖励，请重新加入服务器，或重新开始游戏.

如果你在使用过程中仍遇到问题，或者仍未获得高级会员资格，请访问钻石鸽的 Discord 服务器并提供有效的购买证明，我们会为你修复.
]]

L["premium.freetrial"] = "你已被赠予 <color=255,106,0>ARC9 高级版 (免费试用版)</color>!"
L["premium.freetrial.desc"] = [[
感谢你对 ARC9 的支持! 你让一只小鸟变得非常快乐!

为了表达我们的谢意，我们将向你赠送 ARC9 高级版，用于 <color=255,106,0>3天的时间</color>!

如果你没有立即获得 ARC9 高级版奖励，请重新加入服务器，或重新开始游戏.

如果你在使用过程中仍遇到问题，或者仍未获得高级会员资格，请访问钻石鸽的 Discord 服务器并提供有效的购买证明，我们会为你修复.
]]

L["premium.payment.info"] = [[
购买 ARC9 高级版可在购买时间内立即访问前面列出的所有内容.
你可以再次购买任一选项来延长时间，一旦原定时间到期，时间将自动刷新.
一旦时间已过，且未支付额外费用，ARC9 高级版的访问权限将被取消.

所有自定义选项，包括使用 ARC9 高级版制作的配件插槽、预设和彩色视网膜，都将保持可用，但你不能更改或添加任何其他选项.
]]

L["premium.payment.free.title"] = "ARC9 高级版 (免费试用版)"
L["premium.payment.free.desc"] = [[
价格: <color=100,255,100>免费</color>

获得 ARC9 高级版, <color=255,106,0>3 Days</color>.
]]

L["premium.payment.month.title"] = "ARC9 高级版 (1 个月)"
L["premium.payment.month.desc"] = [[
价格: <color=100,255,100>$5</color>

获得 ARC9 高级版, <color=255,106,0>1 个月</color>.
]]

L["premium.payment.3mon.title"] = "ARC9 高级版 (3 个月)"
L["premium.payment.3mon.desc"] = [[
价格: <color=100,255,100>$15</color>

获得 ARC9 高级版, <color=255,106,0>3 个月</color>.
]]

L["premium.payment.6mon.title"] = "ARC9 高级版 (6 + 1 个月)"
L["premium.payment.6mon.desc"] = [[
价格: <color=100,255,100>$30</color> [ 热门! ]

获得 ARC9 高级版, <color=255,106,0>6 个月</color>.
包括 <color=100,255,100>一个月的免费服务</color>!
]]
