using Godot;
using System;

public partial class Flowers : Block_Base
{
    public override bool isTransparent => true;
    public override bool hasCollision => false;
    public override short GetTexture(Vector3 normal)
    {
        if (normal == new Vector3(0,1,0)) return 6;
        else return 0;
    }
    public override Vector3[][] getVertices() {
        Vector3 a = new(0, 0.1f, 0);
        Vector3 b = new(1, 0.1f, 0);
        Vector3 c = new(1, 0, 0);
        Vector3 d = new(0, 0, 0);
        Vector3 e = new(0, 0.1f, 1);
        Vector3 f = new(1, 0.1f, 1);
        Vector3 g = new(1, 0, 1);
        Vector3 h = new(0, 0, 1);

        Vector3[] i = [a,b,f,  a,f,e];
        Vector3[] j = [h,g,c,  h,c,d];
        Vector3[] k = [f,b,c,  f,c,g];
        Vector3[] l = [a,e,h,  a,h,d];
        Vector3[] m = [e,f,g,  e,g,h];
        Vector3[] n = [b,a,d,  b,d,c];

        return [i,j,k,l,m,n];
    }
}
