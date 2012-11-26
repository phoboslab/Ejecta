/* Subset of glMatrix library */
var vec3 = {};
vec3.create = function(vec) {
    var dest = new Array(3);        
    if(vec) {
        dest[0] = vec[0];
        dest[1] = vec[1];
        dest[2] = vec[2];
    }        
    return dest;
};
vec3.subtract = function(vec, vec2, dest) {
    if(!dest || vec == dest) {
        vec[0] -= vec2[0];
        vec[1] -= vec2[1];
        vec[2] -= vec2[2];
        return vec;
    }
    
    dest[0] = vec[0] - vec2[0];
    dest[1] = vec[1] - vec2[1];
    dest[2] = vec[2] - vec2[2];
    return dest;
};
vec3.add = function(vec, vec2, dest) {
    if(!dest || vec == dest) {
        vec[0] += vec2[0];
        vec[1] += vec2[1];
        vec[2] += vec2[2];
        return vec;
    }
    
    dest[0] = vec[0] + vec2[0];
    dest[1] = vec[1] + vec2[1];
    dest[2] = vec[2] + vec2[2];
    return dest;
};
vec3.normalize = function(vec, dest) {
    if(!dest) { dest = vec; }
    
    var x = vec[0], y = vec[1], z = vec[2];
    var len = Math.sqrt(x*x + y*y + z*z);
    
    if (!len) {
        dest[0] = 0;
        dest[1] = 0;
        dest[2] = 0;
        return dest;
    } else if (len == 1) {
        dest[0] = x;
        dest[1] = y;
        dest[2] = z;
        return dest;
    }
    
    len = 1 / len;
    dest[0] = x*len;
    dest[1] = y*len;
    dest[2] = z*len;
    return dest;
};

var mat4 = {};
mat4.create = function(mat) {
    var dest = new Array(16);
    
    if(mat) {
        dest[0] = mat[0];
        dest[1] = mat[1];
        dest[2] = mat[2];
        dest[3] = mat[3];
        dest[4] = mat[4];
        dest[5] = mat[5];
        dest[6] = mat[6];
        dest[7] = mat[7];
        dest[8] = mat[8];
        dest[9] = mat[9];
        dest[10] = mat[10];
        dest[11] = mat[11];
        dest[12] = mat[12];
        dest[13] = mat[13];
        dest[14] = mat[14];
        dest[15] = mat[15];
    }
    return dest;
};
mat4.frustum = function(left, right, bottom, top, near, far, dest) {
    if(!dest) { dest = mat4.create(); }
    var rl = (right - left);
    var tb = (top - bottom);
    var fn = (far - near);
    dest[0] = (near*2) / rl;
    dest[1] = 0;
    dest[2] = 0;
    dest[3] = 0;
    dest[4] = 0;
    dest[5] = (near*2) / tb;
    dest[6] = 0;
    dest[7] = 0;
    dest[8] = (right + left) / rl;
    dest[9] = (top + bottom) / tb;
    dest[10] = -(far + near) / fn;
    dest[11] = -1;
    dest[12] = 0;
    dest[13] = 0;
    dest[14] = -(far*near*2) / fn;
    dest[15] = 0;
    return dest;
};
mat4.perspective = function(fovy, aspect, near, far, dest) {
    var top = near*Math.tan(fovy*Math.PI / 360.0);
    var right = top*aspect;
    return mat4.frustum(-right, right, -top, top, near, far, dest);
};
mat4.identity = function(dest) {
    dest[0] = 1;
    dest[1] = 0;
    dest[2] = 0;
    dest[3] = 0;
    dest[4] = 0;
    dest[5] = 1;
    dest[6] = 0;
    dest[7] = 0;
    dest[8] = 0;
    dest[9] = 0;
    dest[10] = 1;
    dest[11] = 0;
    dest[12] = 0;
    dest[13] = 0;
    dest[14] = 0;
    dest[15] = 1;
    return dest;
};
mat4.translate = function(mat, vec, dest) {
    var x = vec[0], y = vec[1], z = vec[2];
    
    if(!dest || mat == dest) {
        mat[12] = mat[0]*x + mat[4]*y + mat[8]*z + mat[12];
        mat[13] = mat[1]*x + mat[5]*y + mat[9]*z + mat[13];
        mat[14] = mat[2]*x + mat[6]*y + mat[10]*z + mat[14];
        mat[15] = mat[3]*x + mat[7]*y + mat[11]*z + mat[15];
        return mat;
    }
    
    var a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3];
    var a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7];
    var a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11];
    
    dest[0] = a00;
    dest[1] = a01;
    dest[2] = a02;
    dest[3] = a03;
    dest[4] = a10;
    dest[5] = a11;
    dest[6] = a12;
    dest[7] = a13;
    dest[8] = a20;
    dest[9] = a21;
    dest[10] = a22;
    dest[11] = a23;
    
    dest[12] = a00*x + a10*y + a20*z + mat[12];
    dest[13] = a01*x + a11*y + a21*z + mat[13];
    dest[14] = a02*x + a12*y + a22*z + mat[14];
    dest[15] = a03*x + a13*y + a23*z + mat[15];
    return dest;
};
mat4.rotate = function(mat, angle, axis, dest) {
    var x = axis[0], y = axis[1], z = axis[2];
    var len = Math.sqrt(x*x + y*y + z*z);
    if (!len) { return null; }
    if (len != 1) {
        len = 1 / len;
        x *= len; 
        y *= len; 
        z *= len;
    }
    
    var s = Math.sin(angle);
    var c = Math.cos(angle);
    var t = 1-c;
    
    // Cache the matrix values (makes for huge speed increases!)
    var a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3];
    var a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7];
    var a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11];
    
    // Construct the elements of the rotation matrix
    var b00 = x*x*t + c, b01 = y*x*t + z*s, b02 = z*x*t - y*s;
    var b10 = x*y*t - z*s, b11 = y*y*t + c, b12 = z*y*t + x*s;
    var b20 = x*z*t + y*s, b21 = y*z*t - x*s, b22 = z*z*t + c;
    
    if(!dest) { 
        dest = mat 
    } else if(mat != dest) { // If the source and destination differ, copy the unchanged last row
        dest[12] = mat[12];
        dest[13] = mat[13];
        dest[14] = mat[14];
        dest[15] = mat[15];
    }
    
    // Perform rotation-specific matrix multiplication
    dest[0] = a00*b00 + a10*b01 + a20*b02;
    dest[1] = a01*b00 + a11*b01 + a21*b02;
    dest[2] = a02*b00 + a12*b01 + a22*b02;
    dest[3] = a03*b00 + a13*b01 + a23*b02;
    
    dest[4] = a00*b10 + a10*b11 + a20*b12;
    dest[5] = a01*b10 + a11*b11 + a21*b12;
    dest[6] = a02*b10 + a12*b11 + a22*b12;
    dest[7] = a03*b10 + a13*b11 + a23*b12;
    
    dest[8] = a00*b20 + a10*b21 + a20*b22;
    dest[9] = a01*b20 + a11*b21 + a21*b22;
    dest[10] = a02*b20 + a12*b21 + a22*b22;
    dest[11] = a03*b20 + a13*b21 + a23*b22;
    return dest;
};
mat4.rotateZ = function(mat, angle, dest) {
    var s = Math.sin(angle);
    var c = Math.cos(angle);
    
    // Cache the matrix values (makes for huge speed increases!)
    var a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3];
    var a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7];
    
    if(!dest) { 
        dest = mat 
    } else if(mat != dest) { // If the source and destination differ, copy the unchanged last row
        dest[8] = mat[8];
        dest[9] = mat[9];
        dest[10] = mat[10];
        dest[11] = mat[11];
        
        dest[12] = mat[12];
        dest[13] = mat[13];
        dest[14] = mat[14];
        dest[15] = mat[15];
    }
    
    // Perform axis-specific matrix multiplication
    dest[0] = a00*c + a10*s;
    dest[1] = a01*c + a11*s;
    dest[2] = a02*c + a12*s;
    dest[3] = a03*c + a13*s;
    
    dest[4] = a00*-s + a10*c;
    dest[5] = a01*-s + a11*c;
    dest[6] = a02*-s + a12*c;
    dest[7] = a03*-s + a13*c;
    
    return dest;
};
mat4.lookAt = function(eye, center, up, dest) {
    if(!dest) { dest = mat4.create(); }
    
    var eyex = eye[0],
    eyey = eye[1],
    eyez = eye[2],
    upx = up[0],
    upy = up[1],
    upz = up[2],
    centerx = center[0],
    centery = center[1],
    centerz = center[2];
    
    if (eyex == centerx && eyey == centery && eyez == centerz) {
        return mat4.identity(dest);
    }
    
    var z0,z1,z2,x0,x1,x2,y0,y1,y2,len;
    
    //vec3.direction(eye, center, z);
    z0 = eyex - center[0];
    z1 = eyey - center[1];
    z2 = eyez - center[2];
    
    // normalize (no check needed for 0 because of early return)
    len = 1/Math.sqrt(z0*z0 + z1*z1 + z2*z2);
    z0 *= len;
    z1 *= len;
    z2 *= len;
    
    //vec3.normalize(vec3.cross(up, z, x));
    x0 = upy*z2 - upz*z1;
    x1 = upz*z0 - upx*z2;
    x2 = upx*z1 - upy*z0;
    len = Math.sqrt(x0*x0 + x1*x1 + x2*x2);
    if (!len) {
        x0 = 0;
        x1 = 0;
        x2 = 0;
    } else {
        len = 1/len;
        x0 *= len;
        x1 *= len;
        x2 *= len;
    };
    
    //vec3.normalize(vec3.cross(z, x, y));
    y0 = z1*x2 - z2*x1;
    y1 = z2*x0 - z0*x2;
    y2 = z0*x1 - z1*x0;
    
    len = Math.sqrt(y0*y0 + y1*y1 + y2*y2);
    if (!len) {
        y0 = 0;
        y1 = 0;
        y2 = 0;
    } else {
        len = 1/len;
        y0 *= len;
        y1 *= len;
        y2 *= len;
    }
    
    dest[0] = x0;
    dest[1] = y0;
    dest[2] = z0;
    dest[3] = 0;
    dest[4] = x1;
    dest[5] = y1;
    dest[6] = z1;
    dest[7] = 0;
    dest[8] = x2;
    dest[9] = y2;
    dest[10] = z2;
    dest[11] = 0;
    dest[12] = -(x0*eyex + x1*eyey + x2*eyez);
    dest[13] = -(y0*eyex + y1*eyey + y2*eyez);
    dest[14] = -(z0*eyex + z1*eyey + z2*eyez);
    dest[15] = 1;
    
    return dest;
};
mat4.scale = function(mat, vec, dest) {
    var x = vec[0], y = vec[1], z = vec[2];
    
    if(!dest || mat == dest) {
        mat[0] *= x;
        mat[1] *= x;
        mat[2] *= x;
        mat[3] *= x;
        mat[4] *= y;
        mat[5] *= y;
        mat[6] *= y;
        mat[7] *= y;
        mat[8] *= z;
        mat[9] *= z;
        mat[10] *= z;
        mat[11] *= z;
        return mat;
    }
    
    dest[0] = mat[0]*x;
    dest[1] = mat[1]*x;
    dest[2] = mat[2]*x;
    dest[3] = mat[3]*x;
    dest[4] = mat[4]*y;
    dest[5] = mat[5]*y;
    dest[6] = mat[6]*y;
    dest[7] = mat[7]*y;
    dest[8] = mat[8]*z;
    dest[9] = mat[9]*z;
    dest[10] = mat[10]*z;
    dest[11] = mat[11]*z;
    dest[12] = mat[12];
    dest[13] = mat[13];
    dest[14] = mat[14];
    dest[15] = mat[15];
    return dest;
};