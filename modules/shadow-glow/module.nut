::sg_directory <- fe.module_dir;
::sg_dir <- sg_directory;

::WhichShader <- {
    "DropShadow": "DROP_SHADOW",
    "FlatColor": "FLAT_COLOR",
    "AmbiGlow": "AMBI_GLOW"
}

class AmbiGlow {
    whichShader = WhichShader.AmbiGlow;
    whichGLSL = sg_dir + "gauss_kernsigma_ag.glsl";

    _picA = null;
    _picB = null;

    // _parent = null; // Not used

    _surfA = null;
    _surfB = null;

    _radius = null;
    _offset = { "x": null, "y": null };
    _alpha = null;
    _downsample = null;

    _blurSize = { "x": null, "y": null };
    _kernel = { "size": null, "sigma": null };

    _shader = { "h": null, "v": null, "c": null };
    
    surface = null;

    constructor (_pA, _sr = 200, _sx = 0, _sy = 0, _sa = 255, _ds = 0.5) {
        try {
            _picA = _pA;
        }
        catch (e) {
            ::print ("Invalid fe.Image instance speficied!" );
            return false;
        }

        _radius = _sr;
        _offset.x = _sx;
        _offset.y = _sy;
        _alpha = _sa;
        _downsample = _ds;

        // Create first surface with safeguards area:
        _surfA = ::fe.add_surface(
            _downsample * (_picA.width + (2 * _sr)),
            _downsample * (_picA.height + (2 * _sr))
        );

        // Add a clone of the picture to the topmost surface:
        _picB = _surfA.add_clone( _picA );
        _picB.set_pos(
            _radius * _downsample,
            _radius * _downsample,
            _picA.width * _downsample,
            _picA.height * _downsample
        );

        // Create second surface:
        _surfB = ::fe.add_surface( _surfA.width, _surfA.height );

        // Nest surfaces:
        _surfA.visible = false;
        _surfA = _surfB.add_clone( _surfA );
        _surfA.visible = true;

        // Define and apply blur shaders:
        _blurSize.x = 1.0 / _surfB.width;
        _blurSize.y = 1.0 / _surfB.height;

        _kernel.size = _downsample * ((_radius * 2) + 1);
        _kernel.sigma = _downsample * (_radius * 0.3);

        _shader.h = ::fe.add_shader( Shader.Fragment, whichGLSL );
        _shader.v = ::fe.add_shader( Shader.Fragment, whichGLSL );

        _shader.h.set_texture_param( "texture" );
        _shader.h.set_param( "kernelData", _kernel.size, _kernel.sigma );
        _shader.h.set_param( "offsetFactor", _blurSize.x, 0.0 );

        _shader.v.set_texture_param( "texture" );
        _shader.v.set_param( "kernelData", _kernel.size, _kernel.sigma );
        _shader.v.set_param( "offsetFactor", 0.0, _blurSize.y );

        _surfA.shader = _shader.h;        
        _surfB.shader = _shader.v;

        switch ( whichShader ) {
            case ::WhichShader.DropShadow:
                ::print ( "DropShadow instantiated!\n" );

                // Can be overridden through set_ds_rgb():
                _surfB.set_rgb( 0, 0, 0 );

                _surfB.blend_mode = BlendMode.Multiply;
                break;

            case ::WhichShader.FlatColor:
                ::print( "FlatColor instantiated!\n" );

                _shader.c = ::fe.add_shader( Shader.Fragment, sg_dir + "flat_color.glsl" );
                _shader.c.set_texture_param( "texture" );
                _picB.shader = _shader.c;

                _surfB.blend_mode = BlendMode.Screen;
                break;

            case ::WhichShader.AmbiGlow:
            default:
                ::print( "AmbiGlow instantiated!\n" );

                _surfB.blend_mode = BlendMode.Screen;
                break;
        }

        // Reposition and upsample surface stack:
        _surfB.set_pos(
            (_picA.x - _radius) + _offset.x,
            (_picA.y - _radius) + _offset.y,
            _picA.width + (2 * _radius),
            _picA.height + (2 * _radius)
        );

        // Apply alpha:
        _picB.alpha = _alpha;

        // Adjust z-order:
        _picA.zorder = _picB.zorder + 1;

        // Public:
        surface = _surfB;
    }
}

class DropShadow extends AmbiGlow {
    whichShader = ::WhichShader.DropShadow;
    whichGLSL = sg_dir + "gauss_kernsigma_ds.glsl";

    function set_ds_rgb (r, g, b) {
        _surfB.set_rgb( r, g, b );
    }
}

class FlatColor extends AmbiGlow {
    whichShader = ::WhichShader.FlatColor;

    function set_fc_rgb (r, g, b) {
        _surfB.set_rgb( r, g, b );
    }
}