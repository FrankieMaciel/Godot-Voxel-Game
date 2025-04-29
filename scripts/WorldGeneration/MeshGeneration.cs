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
    List<Vector3> coll_vec = [];
    List<Vector3> n_coll_vec = [];
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
                short block_at_side = chunk.get_block_at(block_coords + Config.directions[side]);
                bool isSideBlockTransparent = Block.id_to_block[block_at_side].isTransparent;
                bool isBlockTransparent = Block.id_to_block[block_id].isTransparent;
                bool isSolid = Block.id_to_block[block_id].isSolid;
                bool hasSides = (block_id == block_at_side) && isBlockTransparent;
                if (!hasSides && isSideBlockTransparent || !isSolid) {
                    create_block(st, block_coords, side, block_id);
                }
            }
        }
        Mesh = st.Commit();
        StaticBody3D static_body = new StaticBody3D();
        StaticBody3D n_static_body = new StaticBody3D();
        CollisionShape3D collision = new CollisionShape3D();
        CollisionShape3D n_collision = new CollisionShape3D();
        ConcavePolygonShape3D cps = new();
        ConcavePolygonShape3D n_cps = new();
        cps.SetFaces(coll_vec.ToArray<Vector3>());
        n_cps.SetFaces(n_coll_vec.ToArray<Vector3>());
        collision.Shape = cps;
        n_collision.Shape = n_cps;
        static_body.AddChild(collision);
        n_static_body.AddChild(n_collision);
        static_body.CollisionLayer = 1 | 2;
        n_static_body.CollisionLayer = 2;
        collission_ref = collision;
        MaterialOverride = Block.chunk_material;
        AddChild(static_body);
        AddChild(n_static_body);
    }

    public void create_block(SurfaceTool st, Vector3 offset, Config.DirectionsIndexes direction, short block_id) {
        offset -= new Vector3(1,1,1);
        int direction_index = (int)direction;
        Vector3[][] vertices = Block.id_to_block[block_id].getVertices();
        if (direction_index >= vertices.Length) return;
        bool[] isInverted = Block.id_to_block[block_id].getSides();
        Vector2[] UVs = Block.id_to_block[block_id].getUvs(isInverted[direction_index]);
        Vector2 blockUVOffset = getTextureIdexUV(Block.id_to_block[block_id].GetTexture(Config.directions[direction]));
        //GD.Print(blockUVOffset);
        for (int v = 0; v < 6; v++) {
            if (Block.id_to_block[block_id].hasCollision) {
                coll_vec.Add(vertices[direction_index][v] + offset);
            } else {
                n_coll_vec.Add(vertices[direction_index][v] + offset);
            }
            st.SetUV((UVs[v] / 64) + (blockUVOffset / 1024));
            st.SetNormal(Config.directions[direction]);
            st.AddVertex(vertices[direction_index][v] + offset);
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
