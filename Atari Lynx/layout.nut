//
// Atari Lynx
// Layout by Mahuti
// vs. 1.0 
//
local order = 0
class UserConfig {
	</ label="Lynx Version", 
        help="Choose the version of the Lynx to show", 
        order=order++, 
        options="Original, New" />
        lynx_version="Original";
  
    </ label="Show Logos", 
        help="Shows wheel images when enabled", 
        order=order++, 
        options="Yes, No" />
        show_logos="Yes";
  
    </ label="Show Boxart", 
        help="Shows boxart when enabled", 
        order=order++, 
        options="Yes, No" />
        show_boxart="Yes";
    
 	</ label="Show Playtime", 
        help="The amount of time this game's been played.", 
        order=order++, 
        options="Yes, No, Include Romname" />
        show_playtime="Yes";
    
    </ label="Show Scanlines", 
        help="Shows scanlines when enabled", 
        order=order++, 
        options="Yes, No" />
        show_scanlines="No"; 
    
    </ label="Scratched Text", 
        help="This is some text scratched in the desk, which may not always be visible. Set it to blank to hide it", 
        order=order++
        />
        desk_text="before its time";
}

 
local config = fe.get_config()

fe.do_nut(fe.script_dir + "modules/pos.nut" );
fe.load_module("shadow-glow")

// stretched positioning
local posData =  {
    base_width = 1920.0,
    base_height = 1080.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "stretch",
    rotate= 0
    debug = true,
}
local stretch = Pos(posData)

// scaled positioning
posData =  {
    base_width = 1920.0,
    base_height = 1080.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    scale= "scale",
    rotate=0
    debug = true,
}
local scale = Pos(posData)

    
//Wood Background
local bg = fe.add_image("bg.png", 0, 0, stretch.width(1920), stretch.height(1080))

//local positioning = fe.add_image("template.png", 0, 0, scale.width(1920), scale.height(1080))
//positioning.preserve_aspect_ratio = true
    
local scratch_me = null
if (config["desk_text"] != ""){
    
    local scratch_y = 120
    local scratch_x = 200
    local scratch_width = 1100
    local scratch_height = 200
    local scratch_font_height=44 
    local scratch_rotation = -7
        
    scratch_me = fe.add_text(config["desk_text"], stretch.x(scratch_x), stretch.y(scratch_y), stretch.width(scratch_width), stretch.height(scratch_height) )
    stretch.set_font_height(scratch_font_height,scratch_me, "TopLeft")

    scratch_me.x = scale.x(scratch_x, "left")
    scratch_me.y = scale.y(scratch_y, "top",scratch_me)
    scratch_me.alpha=140
    scratch_me.rotation=scratch_rotation
    scratch_me.set_rgb(150,112,72)
    scratch_me.font = "sugar-death-2-italic.ttf"
        
    local scratch_me2 = fe.add_text(config["desk_text"], stretch.x(scratch_x), stretch.y(scratch_y), stretch.width(scratch_width), stretch.height(scratch_height) )
    scratch_me2.y = scale.y( -2, "top", scratch_me2, scratch_me)
    scratch_me2.x = scale.x( -2, "left", scratch_me2, scratch_me)
    stretch.set_font_height(scratch_font_height,scratch_me2, "TopLeft")
    scratch_me2.alpha=70    
    scratch_me2.rotation=scratch_rotation
    scratch_me2.set_rgb(88,23,41)
    scratch_me2.font = "sugar-death-2-italic.ttf"
    
}
local cassette = fe.add_image("cassette.png", scale.x(1103), scale.y(485), scale.width(1047), scale.height(802))

local ruler = fe.add_image("ruler.png", scale.x(145), scale.y(55), scale.width(1988), scale.height(741))

local playtime = null 
if ( config["show_playtime"] != "No" )
{
    // Playtime   
    if ( config["show_playtime"] == "Yes" )
    {
        playtime = fe.add_text("Playtime: [PlayedTime]", stretch.x(14),0, stretch.width(800), stretch.height(108))
    }
    else
    {
        playtime = fe.add_text("Playtime: [PlayedTime] [Name]", stretch.x(14),0, stretch.width(800), stretch.height(108))
    }
    
    playtime.set_rgb(10, 10, 10)	
}

    
local boxart = null
if ( config["show_boxart"] == "Yes" )
{
    // Boxart
    boxart = fe.add_artwork("boxart", scale.x(-70), scale.y(25), scale.width(750), scale.height(750))
    boxart.preserve_aspect_ratio = true
    boxart.trigger = Transition.EndNavigation
    boxart.rotation = -7.5 
    local ds = DropShadow( boxart, 40, scale.x(20), scale.y(20), 83 )
}

local wheel = null
if ( config["show_logos"] == "Yes" )
{
 	// wheel
	wheel = fe.add_artwork("wheel", scale.x(1250),scale.y(56), scale.width(400), scale.height(216))
    wheel.preserve_aspect_ratio = true
	wheel.trigger = Transition.EndNavigation
    wheel.alpha=170
    wheel.x= scale.x(-200,"right",wheel)
}

local atari_surface = fe.add_surface(scale.width(1920), scale.height(1080))
atari_surface.set_pos(0,0)
// Missing Cartridge Underlay
local nogame_underlay = atari_surface.add_image("game_underlay.png", scale.x(862), scale.y(549), scale.width(457), scale.height(286))
       
// Snap
local snap = atari_surface.add_artwork("snap", scale.x(870), scale.y(553), scale.width(440), scale.height(280))
snap.trigger = Transition.EndNavigation
snap.preserve_aspect_ratio=true

local scanlines
if (config["show_scanlines"] == "Yes" )
{
    // Scanlines
    scanlines = atari_surface.add_image("scanlines.png", scale.x(800), scale.y(450), scale.width(622), scale.height(480) )
    scanlines.preserve_aspect_ratio = true
    scanlines.alpha=160 
}

// Atari Lynx Overlay
local atari_lynx_overlay
if (config["lynx_version"] == "New")
{
    atari_lynx_overlay = atari_surface.add_image("atari_lynx_new.png", scale.x(209), scale.y(346), scale.width(1715), scale.height(738))    
}
else
{
    atari_lynx_overlay = atari_surface.add_image("atari_lynx_old.png", scale.x(209), scale.y(346), scale.width(1715), scale.height(738))
}

/////////////////////////////////////////////////////
//                  Positioning
/////////////////////////////////////////////////////
//atari_lynx_overlay.x=scale.x(180,"middle",atari_lynx_overlay)
nogame_underlay.x=scale.x(22,"middle",nogame_underlay,atari_lynx_overlay,"middle")
nogame_underlay.y=scale.y(-20,"middle",nogame_underlay,atari_lynx_overlay,"middle")
snap.x=scale.x(22,"middle",snap,atari_lynx_overlay,"middle")
snap.y=scale.y(-20,"middle",snap,atari_lynx_overlay,"middle")
local snap_orig_y = snap.origin_y
local snap_orig_x = snap.origin_x
local snap_orig_height = snap.height
local snap_orig_width = snap.width
function artwork_transition( ttype, var, ttime ) 
{   
    if ( ttype == Transition.EndNavigation || ttype == Transition.StartLayout || ttype==Transition.ToNewList || ttype==Transition.FromGame )
    {
        if (snap.subimg_height > snap.subimg_width)
        {
            local w = snap.width
            local h = snap.height
            snap.width = h
            snap.height = w
            snap.origin_y = snap.height
            snap.origin_x = snap.width
            snap.rotation = -90
            snap.x = scale.x(-8,"left",snap,nogame_underlay,"right")
        }
        else
        {
            snap.origin_y = snap_orig_y
            snap.origin_x = snap_orig_x
            snap.rotation = 0
            snap.width= snap_orig_width
            snap.height= snap_orig_height
            snap.x=scale.x(22,"middle",snap,atari_lynx_overlay,"middle")
            snap.y=scale.y(-20,"middle",snap,atari_lynx_overlay,"middle")
        }
    }
    return false
}
fe.add_transition_callback("artwork_transition"); 

atari_surface.rotation = -5
atari_surface.y = scale.y(70,"middle",atari_surface)
atari_surface.x = scale.x(-70,"middle",atari_surface)

    
scanlines.x=scale.x(0,"middle",scanlines,atari_lynx_overlay,"middle")
scanlines.y=scale.y(0,"middle",scanlines,atari_lynx_overlay,"middle")
    
stretch.set_font_height(25,playtime, "BottomLeft")
playtime.y = scale.y(-20,"bottom",playtime)
playtime.x = scale.x(20,"left",playtime)

ruler.x= scale.x(-1600,"right")
cassette.x= scale.x(-850,"right")
cassette.y= scale.y(-600,"bottom")