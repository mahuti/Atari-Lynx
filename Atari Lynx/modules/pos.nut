/////////////////////////////////////////////////////////
//
// Attract-Mode Frontend - Pos (Layout Scaling) Module
//
/////////////////////////////////////////////////////////
// Pos (Position) module helps position, scale or stretch items to fit a wide variety of screen dimensions using easy-to-reference pixel values. 
// 
// I made this module so that I could just look at the pixel dimensions of objects in my Photoshop design of a layout 
// without having to do any further calculations and scale easily to multiple layout resolutions
// 
// Layouts using this module can easily stretch or scale to vertical, 4:3 and 16:9 (or other) screen sizes
// The Pos module can responsively position items from the right and bottom of the screen
// so that elements in your layout can float depending on the screen size.
// This module can also be used in tandem with the PreserveArt (and similar) modules 
//
// Usage:
//
// create an array containing any values you want to set. You only need to pass the items you want. Any item not passed in will use a default 
// you can use multiple instances. I use one for scaled and one for stretched items. This example will generate stretched values

// fe.load_module("pos"); 
//
// local posData =  {
//     base_width = 480.0, /* the width of the layout as you designed it */ 
//     base_height = 640.0, /* the height of the layout as you designed it */ 
//     layout_width = fe.layout.width, /* usually not necessary, but allows you to override the layout width and height */ 
//     layout_height = fe.layout.height, 
//     rotate = 90, /* setting to 90, -90 will rotate the layout, otherwise leave at 0 */  
//     scale= "stretch" /* stretch, scale, none. Stretch scales without preserving aspect ratio. Scale preserves aspect ratio */
// }
//
// local pos = Pos(posData)
// 
//	local vid = fe.add_artwork( "snap", pos.x(10), pos.y(20), pos.width(480), pos.height(640) ); /* my design file shows the image 10x, 20y, 480wide, 640tall */	
//	vid.preserve_aspect_ratio = false;
//
// 	local instruction_card = fe.add_image("instruction_card_bg.png" , pos.x(10), pos.y(20), pos.width(1440), pos.height(1080));
//	instruction_card.x = pos.x(272, "right", instruction_card.width); /* this is for an image whose right edge is 272 pixels from the right edge of my design */ 
//  
//  /* used with PreserveArt/PreserveImage */ 
// 
// fe.load_module("preserve-art");  
//
// local bg = PreserveImage( "image.png", pos.x(20), pos.y(20), pos.width(300), pos.height(400) );
// bg.set_fit_or_fill( "fill" );
// bg.set_anchor( ::Anchor.Top );

::Posdata <-
{
    base_width = 640.0,
    base_height = 480.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    rotate =0, 
    scale= "stretch",
    debug= false,
}
 
// scale can be stretch, scale, none
// rotate can be 0, 90, -90 ( any other value will trigger -90)

class Pos
{
    VERSION = 1.0
    pos_debug = false
    xconv = 1
    yconv = 1
    pos_scale = "stretch"
    pos_layout_width = ::fe.layout.width
    pos_layout_height = ::fe.layout.height
    pos_base_width = 640.0
    pos_base_height = 480.0
    pos_rotate = 0
    
    constructor( properties )
    {
        foreach(key, value in properties) {
            try {
                switch (key) {
                    case "base_width":
                        pos_base_width = value.tofloat()
                        break
                    case "base_height":
                        pos_base_height = value.tofloat()
                        break
                    case "layout_width":
                        pos_layout_width = value.tofloat()
                        break
                    case "layout_height":
                        pos_layout_height = value.tofloat()
                        break
                    case "rotate":
                        pos_rotate = value.tofloat()
                        break
                    case "scale":
                        switch(value){
                            case "scale": 
                                pos_scale = "scale"
                                break
                            case "none":
                                pos_scale = "none"
                                break
                            default:
                                pos_scale = "stretch"   
                        }
                        break
                   case "debug":
                        if (value==true){pos_debug = true }
                        break
                }
            }
            catch(e) { if (pos_debug) printLine("Error setting property: " + key); } 
        }
        
        rotate(pos_rotate)
            
        // width conversion factor
        xconv = pos_layout_width / pos_base_width 
        
        // height conversion factor
        yconv = pos_layout_height / pos_base_height
            
        if (pos_scale=="scale")
        {
            if (pos_layout_width > pos_layout_height)
            {
                xconv = yconv 
            }
            else
            {
                yconv = xconv 
            }
        }
        if (pos_scale=="none")
        {
            xconv = 1 
            yconv = 1
        }
    
        printLine("xconv", xconv)
        printLine("yconv", yconv)

    }

    // Print line
    function printLine(lineheader, x) {
        if (pos_debug){
            if (!lineheader)
            {
                lineheader = "key" 
            }
            print("\n"+lineheader + ": " + x + " \n")            
        }
    }

    
    function rotate(rotation)
    {
        if (rotation.tofloat() != 0)
        {
            if (::fe.layout.orient  == 0 ) // only do anything if it's not already rotated
            {
                local templayout_w = pos_layout_width
                local templayout_h = pos_layout_height
                ::fe.layout.width = pos_layout_width = templayout_h
                ::fe.layout.height= pos_layout_height = templayout_w

                if (rotation==90)
                {
                    ::fe.layout.orient=RotateScreen.Right
                }
                else
                {
                    ::fe.layout.orient=RotateScreen.Left
                }
            }
        }  
        return false
    }
    
    // get a width value converted using conversion factor
    // allow_stretch=false will cause the value to use the scaling, not stretching values. Handy when an item shouldn't be stretched (like a Logo)
    function width(num)
    {	
        return num * xconv
    }

    // get a height value converted using conversion factor
    function height ( num)
    {
        return num * yconv
    }
    
    /*
        set_font_height is used to adjust text objects to use relatively scaled type
        
        height= height of your type in your design
        text_object = name of a text object you've already created
        text_align = how the type should be aligned in your text object (uses standard AM alignment names)
        text_margin = if you'd like a margin set, add it, otherwise this defaults to zero
        
        Example usage: 
        create a text object. THEN call something like this: 
        
        pos.set_font_height(24,my_text_label, "Centre")
        
        This will create a relatively sized text object with have margins removed and the text aligned to it's vertical and horizontal center
        
    */ 
    function set_font_height(height, text_object, text_align="TopLeft" , text_margin=0)
    {
        if ( typeof text_object == typeof fe.Text())
        {
            text_object.charsize = charsize(height)
            text_object.margin=0
            
            // printLine("fontstuff", text_object.glyph_size)

            if (text_margin){
                 text_object.margin=text_margin
            }   
            switch (text_align) {
                case "TopCentre":
                   text_object.align = Align.TopCentre 
                    break
                case "TopRight":
                   text_object.align = Align.TopRight 
                    break
                case "Left":
                   text_object.align = Align.Left 
                    break
                case "Centre":
                   text_object.align = Align.Centre 
                    break
                case "Right":
                   text_object.align = Align.Right 
                    break
                case "BottomLeft":
                   text_object.align = Align.BottomLeft 
                    break
                case "BottomCentre":
                   text_object.align = Align.BottomCentre 
                    break
                case "BottomRight":
                   text_object.align = Align.BottomRight 
                    break
               default:
                    text_object.align = Align.TopLeft
            }
        }
        return false
    }
    
    /*
        charsize is used to set a relative typesize for an existing text object
        
        example usage: 
        
        local info_text = fe.add_text("Hello World", pos.x(10), pos.y(10), pos.width(100), pos.height(100))
        info_text.charsize = pos.charsize(18)
    */ 
    function charsize(num)
    {
        local charsize_conv = 1
        local wth = pos_layout_width / pos_layout_height // vertical screens
            
        if ( wth <=1 )
        {
            charsize_conv = wth
        }
        local gs = num * yconv * charsize_conv
        return gs.tointeger()
    }
    
    function x(num, anchor="left", object = null, relative_object= null, align_to=null)
    {
       return xy(num, anchor, object, relative_object,"x",align_to)
    }
    
    function y(num, anchor="top", object = null, relative_object= null, align_to=null)
    {
        return xy(num, anchor, object, relative_object,"y",align_to)
    }
    /* 
    get x or y position converted to a scaled value using conversion factor

    num:float/int
    
    anchor: string  
        acceptable values: left,right,center,centre,middle,top,bottom
        anchor position of the object, or if object is not available, postion relative to screen
    
    object: float/int/object
        acceptable values: 
            object:  if an object is present, it will be positioned relative to the screen
            float/int: will be used in place of object's width/height. xy coordinate assumed to be 0
            
    relative_object: float/int/object
        acceptable values: 
            object: if an relative_object is present, the object will be positioned relative to this instead of the screen
            float/int: will be used in place of relative_object's width/height. xy coordinat assumed to be 0
    
    type: string
        acceptable values: x,y
        needed to figure out whether the x/y width/height values should be returned. this argument is not present in standard x/y functions
        
    align_to: string
        acceptible values: left,right,center,centre,middle,top,bottom
        if an object is present, it will be aligned relative to relative_object (if available) otherwise to the screen
    */ 
    function xy(num, anchor="top", object = null, relative_object= null, type="x",align_to=null)
    {
        anchor = anchor.tolower()

        local object_wh = get_object_wh(type,object)
        local object_xy = get_object_xy(type,object)
        local relative_object_wh = get_object_wh(type,relative_object)
        local relative_object_xy = get_object_xy(type,relative_object)
            
        local object_msg = "" //only used for debugging

        if (type=="y")
        {
            num = num * yconv
        }
        else
        {
            num = num * xconv
        }
    
        // not much data, factor against the screen
        if (object == null && relative_object ==null)
        {
            return relative_xy(type, num, 0,0, anchor,null,null, align_to)
        }

        if (pos_debug){
            try { object_msg = object.msg } catch (e) {}
            
            local coord = relative_xy(type, num, object_xy, object_wh, anchor,relative_object_xy, relative_object_wh, align_to)
                
            printLine("RELATIVE XY", "\nmessage: " + object_msg + 
                      "\ntype: " + type + 
                      "\nanchor: " + anchor +
                      "\nalign_to: " +align_to +
                      "\nscreen WxH: " + pos_layout_width + " x " + pos_layout_height +
                      "\nnum: " + num + 
                      "\nobject_xy:" + object_xy + 
                      "\nobject_wh:" + object_wh + 
                      "\nrelative_object_xy: " + relative_object_xy +
                      "\nrelative_object_wh: " + relative_object_wh + 
                      "\nnew xy coord: " + coord + 
                     "" )
                
            return coord
        }
        return relative_xy(type, num, object_xy, object_wh, anchor,relative_object_xy, relative_object_wh, align_to)
    }
    function vertical_space_between(object,object2=null,padding=0)
    {
        return xy_space_between(object,object2,padding,type="y")
    }
    function horizontal_space_between(object,object2=null,padding = 0)
    {
        return xy_space_between(object,object2,padding,type="x")
    }
    function xy_space_between(object = null, object2 = null, padding = 0, type="x")
    {
        if (object2 == null )
        {
            object2 = pos_layout_width
            if (type=="y")
            {
                object2 = pos_layout_height
            }
        }
        else
        {
            object2 = get_object_xy(type,object2)
        }

        if (padding!=0)
        {
            if (type=="y")
            {
                padding = padding * yconv
            }
            else
            {
                padding = padding * xconv
            }
        }
        printLine("padding" , padding)
        printLine("object2 size", object2)
        printLine("object2", get_object_xy(type,object2))
        printLine("object1", get_object_xy2(type,object))
        return object2 - padding - padding - get_object_xy2(type,object)
    }
    // get the right or bottom coordinate
    function get_object_xy2(type="x", object=null)
    {
        if(object != null)
        {
           return get_object_wh(type,object) + get_object_xy(type,object) 
        }
        return null
    }
    function get_object_wh(type="x",object=null)
    {
        if (object != null)
        {
            try 
            {
                if (type=="y")
                {
                    return object.height
                }
                else
                {
                    return object.width
                }
            }
            catch (e) 
            {
                if (typeof object =="float" || typeof object =="integer")
                {
                    if (type=="y")
                    {
                        return object * yconv
                    }
                    return object * xconv
                }
            }
        }
        return null
    }
    function get_object_xy(type="x",object = null)
    {
        if (object != null)
        {
            try 
            {
                if (type=="y")
                {
                    return object.y
                }
                else
                {
                    return object.x
                }
            }
            catch (e) 
            {
                if (typeof object =="float" || typeof object =="integer")
                {
                    if (type=="y")
                    {
                        return object * yconv
                    }
                    return object * xconv
                }
            }
        }
        return null
    }
        
    function relative_xy(type="x", num=0, xy=0, wh=1, anchor="top", rel_xy=null, rel_wh=null, align_to=null)
    {
        anchor = anchor.tolower()
        local screen_wh = pos_layout_width
        local object_wh = 0 // needed for any calculation that uses an object 

        if (type=="y")
        {
            screen_wh = pos_layout_height
        }
        
        local xy_first = 0 //xy point from top or left corner
        local xy_center = screen_wh/2 //xy point from center
        local xy_last = screen_wh // xy point from bottom or right
            
        if (align_to==null)
        {
            align_to=anchor 
        }
        
        if (anchor == "bottom" || anchor=="right")
        {
            object_wh = wh
        }
        else if (anchor == "middle" || anchor=="centre" || anchor=="center")
        {
            object_wh = wh/2
        }
            
        if (rel_xy!=null && rel_wh!=null){            
            //  set values to offset object from another object
            xy_first = rel_xy
            xy_center = rel_xy + rel_wh/2
            xy_last = rel_xy + rel_wh   
        }
        else if (wh == null){
            // offset number from screen size, no object width available so setting this to zero
            object_wh = 0
        }
        
        if (align_to == "bottom" || align_to=="right")
        {
            return xy_last + num - object_wh
        }
        else if (align_to == "middle" || align_to=="centre" || align_to=="center")
        {
            return xy_center + num - object_wh   
        }
        else 
        {
            return xy_first + num - object_wh
        }
        return null
    }    
}
