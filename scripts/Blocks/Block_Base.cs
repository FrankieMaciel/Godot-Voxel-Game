using Godot;
using System;

public abstract partial class Block_Base : Node
{
    virtual public bool isTransparent {get;}
    virtual public bool hasCollision {get;} = true;
    virtual public bool isSolid {get;} = true;
    public abstract short GetTexture(Vector3 normal);
    virtual public Vector3[][] getVertices() {
        Vector3 a = new(0, 1, 0);
        Vector3 b = new(1, 1, 0);
        Vector3 c = new(1, 0, 0);
        Vector3 d = new(0, 0, 0);
        Vector3 e = new(0, 1, 1);
        Vector3 f = new(1, 1, 1);
        Vector3 g = new(1, 0, 1);
        Vector3 h = new(0, 0, 1);

        //Vector3[] i = [a,b,f,  a,f,e];
        Vector3[] i = createPlane(a,b,f,e);
        //Vector3[] j = [h,g,c,  h,c,d];
        Vector3[] j = createPlane(h,g,c,d);
        //Vector3[] k = [f,b,c,  f,c,g];
        Vector3[] k = createPlane(f,b,c,g);
        //Vector3[] l = [a,e,h,  a,h,d];
        Vector3[] l = createPlane(a,e,h,d);
        //Vector3[] m = [e,f,g,  e,g,h];
        Vector3[] m = createPlane(e,f,g,h);
        //Vector3[] n = [b,a,d,  b,d,c];
        Vector3[] n = createPlane(b,a,d,c);

        return [i,j,k,l,m,n];
    }
    virtual public Vector2[] getUvs(bool isInverted = false) {
        if (!isInverted) {
            Vector2[] UVs = [
                new Vector2(0,0),
                new Vector2(1,0),
                new Vector2(1,1),
                new Vector2(0,0),
                new Vector2(1,1),
                new Vector2(0,1)
            ];
            return UVs;
        } else {
            Vector2[] UVs = [
                new Vector2(0,0),
                new Vector2(1,1),
                new Vector2(1,0),
                new Vector2(0,0),
                new Vector2(0,1),
                new Vector2(1,1)
            ];
            return UVs;
        }
    }
    virtual public bool[] getSides() {
        return [false,false,false,false,false,false];
    }

    public Vector3[] createPlane(Vector3 a, Vector3 b, Vector3 c, Vector3 d, bool isInverted = false) {
        if (!isInverted) return [a,b,c,  a,c,d];
        else return [a,c,b,  a,d,c];
    }
}
