using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class MeshGeneration : MeshInstance3D
{
    Vector3 cgp;
    public CollisionShape3D collission_ref;
    public MeshGeneration(Chunk chunk) {
        Connect("tree_entered", Callable.From(add_position_offset));
        cgp = chunk.chunk_position;
        SurfaceTool st = new SurfaceTool();
        st.Begin(Mesh.PrimitiveType.Triangles);
        for (int index = 0; index < chunk.data.Count; index++) {
            Vector3 block_coords = chunk.index_to_coordinates3D(index);
            short block_id = chunk.data[index];
            if (block_id == 0) continue;
            if (chunk.is_on_chunk_border(block_coords)) continue;
            for (int side_idx = 0; side_idx < 6; side_idx ++) {
                Config.DirectionsIndexes side = (Config.DirectionsIndexes)side_idx;
                if (chunk.get_block_at(block_coords + Config.directions[side]) == 0) {
                    create_block(st, block_coords, side, block_id);
                }
            }
        }
        Mesh = st.Commit();
        StaticBody3D static_body = new StaticBody3D();
        CollisionShape3D collision = new CollisionShape3D();
        collision.Shape = Mesh.CreateTrimeshShape();
        static_body.AddChild(collision);
        collission_ref = collision;
        MaterialOverride = Block.chunk_material;
        AddChild(static_body);
    }

    public void create_block(SurfaceTool st, Vector3 offset, Config.DirectionsIndexes direction, short block_id) {
        offset -= new Vector3(1,1,1);
        Vector3 a = new Vector3(0, 1, 0) + offset;
        Vector3 b = new Vector3(1, 1, 0) + offset;
        Vector3 c = new Vector3(1, 0, 0) + offset;
        Vector3 d = new Vector3(0, 0, 0) + offset;
        Vector3 e = new Vector3(0, 1, 1) + offset;
        Vector3 f = new Vector3(1, 1, 1) + offset;
        Vector3 g = new Vector3(1, 0, 1) + offset;
        Vector3 h = new Vector3(0, 0, 1) + offset;

        Vector3[] i = [a,b,f,  a,f,e];
        Vector3[] j = [h,g,c,  h,c,d];
        Vector3[] k = [f,b,c,  f,c,g];
        Vector3[] l = [a,e,h,  a,h,d];
        Vector3[] m = [e,f,g,  e,g,h];
        Vector3[] n = [b,a,d,  b,d,c];

        Vector3[][] vertices = [i,j,k,l,m,n];
        Vector2[] UVs = [
            new Vector2(0,0),
            new Vector2(1,0),
            new Vector2(1,1),
            new Vector2(0,0),
            new Vector2(1,1),
            new Vector2(0,1)
        ];
        int direction_index = (int)direction;
        Vector2 blockUVOffset = getTextureIdexUV(Block.id_to_block[block_id].GetTexture(Config.directions[direction]));
        //GD.Print(blockUVOffset);
        for (int v = 0; v < 6; v++) {
            st.SetUV((UVs[v] / 64) + (blockUVOffset / 1024));
            st.SetNormal(Config.directions[direction]);
            st.AddVertex(vertices[direction_index][v]);
        }
    }

    private Vector2 getTextureIdexUV(short index) {
        Vector2 result = new()
        {
            X = index % 64,
            Y = index / 64
        };
        return result * 16;
    }

    private void add_position_offset()
    {
        GlobalPosition = cgp;
    }
}
