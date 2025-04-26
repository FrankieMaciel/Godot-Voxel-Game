using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;

public partial class World : Node3D
{
    ConcurrentDictionary<Vector3, Chunk> temp_chunks = [];
    int half_render_dis = (int)Config.render_distance / 2;
    List<Vector3> chunks_positions_to_load = [];
    long task_id = -1;
    Vector3 last_player_pos = Vector3.Zero;
    public List<MeshGeneration> mesh_to_free = [];
    public override void _Ready() {
	    Config.world_node = this;
    }
	
    public override void _Process(double delta) {
	    load_chunks();
    }

    private void create_chunk(int chunk_index) {
        var chunk_position = chunks_positions_to_load[chunk_index];
        Chunk new_chunk = new(chunk_position * Config.Chunk_size);
        new_chunk.Create_mesh();
        temp_chunks[chunk_position] = new_chunk;
    }
        
    public void load_chunks(){
        Vector3 player_chunk = Config.player.GlobalPosition / Config.Chunk_size;
        player_chunk = player_chunk.Floor();
        if (player_chunk == last_player_pos) return;
        last_player_pos = player_chunk;
        foreach (var chunk in temp_chunks) {
            var chunk_ref = chunk.Value;
            if (chunk_ref is null) continue;
            if (!chunk_ref.hasMesh) continue;
            Vector3 chunk_pos = chunk.Key;
            Vector3 dif = player_chunk - chunk_pos;
            dif = dif.Abs();
            if (dif.X > half_render_dis || dif.Y > half_render_dis || dif.Z > half_render_dis) {
                chunk_ref.hide_mesh();
            }
            else {
                if (chunk_ref.hasMesh) chunk_ref.show_mesh();
            }
        }
        
        if (task_id != -1) {
            if (!WorkerThreadPool.IsGroupTaskCompleted(task_id)) return;
        }
        foreach (var mesh in mesh_to_free) {
            mesh.CallDeferredThreadGroup("queue_free");
        }
        mesh_to_free.Clear();
        chunks_positions_to_load.Clear();
        for (int i = 0; i < half_render_dis; i++) {
            for (int x = -i; x < i + 1; x++) {
                for (int z = -i; z < i + 1; z++) {
                    // Teto & chão
                    processChunks(new Vector3(player_chunk.X + x, player_chunk.Y - i, player_chunk.Z + z));
                    processChunks(new Vector3(player_chunk.X + x, player_chunk.Y + i, player_chunk.Z + z));
                    if (z == -i || z == i) continue;
                    // pareide frente & trás
                    processChunks(new Vector3(player_chunk.X + x, player_chunk.Y + z, player_chunk.Z - i));
                    processChunks(new Vector3(player_chunk.X + x, player_chunk.Y + z, player_chunk.Z + i));
                    if (x == -i || x == i) continue;
                    // pareides laterais
                    processChunks(new Vector3(player_chunk.X - i, player_chunk.Y + z, player_chunk.Z + x));
                    processChunks(new Vector3(player_chunk.X + i, player_chunk.Y + z, player_chunk.Z + x));	
                }
            }
        }
        if (chunks_positions_to_load.Count > 0) {
            task_id = WorkerThreadPool.AddGroupTask(Callable.From<int>(create_chunk), chunks_positions_to_load.Count, -1);
        }
    }
                    
    private void processChunks(Vector3 chunk_position) {
        if (temp_chunks.ContainsKey(chunk_position)) return;
        chunks_positions_to_load.Add(chunk_position);
    }
    public void updateChunkBlockInfo(Vector3 pos, Vector3 normal, short block_id) {
        Vector3 iblock_pos;
        if (block_id == 0) {
            iblock_pos = pos - (normal / 2);
        } else {
            iblock_pos = pos + (normal / 2);
        } 
        Vector3 chunkPos = iblock_pos / Config.Chunk_size;
        chunkPos = chunkPos.Floor();
        if (!temp_chunks.ContainsKey(chunkPos)) return;
        Vector3 blockPos = iblock_pos.Floor() - (chunkPos * Config.Chunk_size) + new Vector3(1,1,1);
        if (blockPos == Config.player.playerBlock || blockPos == Config.player.playerBlock + new Vector3(1,1,1)) return;
	    updateBlockInfo(chunkPos, iblock_pos, block_id);
	
        Vector3 adj_chunk = get_border_diference(blockPos, Config.Chunk_size);
        GD.Print(adj_chunk);
        if (adj_chunk != Vector3.Zero) {
            if (adj_chunk[0] != 0) {
                Vector3 adjChunkPos = chunkPos + new Vector3(adj_chunk[0],0,0);
                updateBlockInfo(adjChunkPos, iblock_pos, block_id);
            }
            if (adj_chunk[1] != 0) {
                Vector3 adjChunkPos = chunkPos + new Vector3(0,adj_chunk[1],0);
                updateBlockInfo(adjChunkPos, iblock_pos, block_id);
            }
            if (adj_chunk[2] != 0) {
                Vector3 adjChunkPos = chunkPos + new Vector3(0,0,adj_chunk[2]);
                updateBlockInfo(adjChunkPos, iblock_pos, block_id);
            }
        }
    }
			
    public void updateBlockInfo(Vector3 chunk_position, Vector3 block_position, short block_id) {
        Chunk chunk = temp_chunks[chunk_position];
        GD.Print(chunk);
        Vector3 blockPos = block_position.Floor() - (chunk_position * Config.Chunk_size) + new Vector3(1,1,1);
        chunk.set_block_at(blockPos, block_id);
        chunk.Create_mesh();
    }
        
    public Vector3 get_border_diference(Vector3 pos, int size) {
        int nx = 0;
        int ny = 0;
        int nz = 0;
        if (pos.X == size) nx = 1;
        if (pos.X == 1) nx = -1;
        if (pos.Y == size) ny = 1;
        if (pos.Y == 1) ny = -1;
        if (pos.Z == size) nz = 1;
        if (pos.Z == 1) nz = -1;
        return new Vector3(nx,ny,nz);
    }
    public void _on_h_slider_value_changed(float value) {
        Config.render_distance = (int)value;
        half_render_dis = (int)Config.render_distance / 2;
    }
}
