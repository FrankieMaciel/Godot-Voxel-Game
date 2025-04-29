using Godot;
using System;

public partial class TallGrass : Block_Base
{
    public override bool isTransparent => true;
    public override bool hasCollision => false;
    public override bool isSolid {get;} = false;
    public override short GetTexture(Vector3 normal)
    {
        return 7;
    }
    public override Vector3[][] getVertices() {
        Vector3 a = new(0, 1, 0);
        Vector3 b = new(1, 1, 1);
        Vector3 c = new(1, 0, 1);
        Vector3 d = new(0, 0, 0);

        Vector3 g = new(1, 1, 0);
        Vector3 h = new(0, 1, 1);
        Vector3 i = new(0, 0, 1);
        Vector3 j = new(1, 0, 0);

        Vector3[] k = createPlane(a,b,c,d);
        Vector3[] l = createPlane(a,b,c,d, true);

        Vector3[] m = createPlane(g,h,i,j);
        Vector3[] n = createPlane(g,h,i,j, true);

        return [k,l,m,n];
    }
    public override bool[] getSides() {
        return [false,true,false,true];
    }

}
