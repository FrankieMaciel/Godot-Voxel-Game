using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Chunk : Node
{
	public Vector3 chunk_position = Vector3.Zero;
	public MeshGeneration chunk_mesh_node;
	public List<short> data;
	public bool isEmpty = true;
	public bool isCompletlyEmpty = true;
	public bool isFull = true;
	public bool wasModified = false;
	public bool hasMesh = false;

	public Chunk(Vector3 chunks_pos) {
		chunk_position = chunks_pos;
		_ = new Generate_chunk(this);
	}

	public short get_block_at(Vector3 pos) {
		if (isCompletlyEmpty) return 0;
		int max_i = Config.Chunk_size_with_border;
		int index = ((int)pos.X * max_i * max_i) + ((int)pos.Y * max_i) + (int)pos.Z;
		if (index >= data.Count) {
			return 0;
		} 
		return data[index];
	}
	
	public void set_block_at (Vector3 pos, short id) {
		if (isCompletlyEmpty && id != 0) {
			data = [.. Enumerable.Repeat((short)0, (int)Math.Pow(Config.Chunk_size_with_border, 3))];
			isCompletlyEmpty = false;
		}
		int max_i = Config.Chunk_size_with_border;
		int index = ((int)pos.X * (max_i * max_i)) + ((int)pos.Y * max_i) + (int)pos.Z;
		if (index >= data.Count) { return; } 
		if (id != 0){ isEmpty = false; }
		if (id == 0){ isFull = false; }
		data[index] = id;
	}

	public Vector3 index_to_coordinates3D(int index) {
		int max_i = Config.Chunk_size_with_border;
		int x = index / (max_i * max_i);
		int y = index / max_i % max_i;
		int z = index % max_i;
		return new Vector3(x,y,z);
	}

	public bool is_on_chunk_border(Vector3 block_position) {
		bool xCheck = block_position.X == 0 || block_position.X == Config.Chunk_size_with_border - 1;
		bool yCheck = block_position.Y == 0 || block_position.Y == Config.Chunk_size_with_border - 1;
		bool zCheck = block_position.Z == 0 || block_position.Z == Config.Chunk_size_with_border - 1;
		return xCheck || yCheck || zCheck;
	}

	public void Create_mesh(bool isHided){ 
		remove_mesh();
		if (chunk_position.Y > Config.World_max_y) return;
		if (chunk_position.Y < Config.World_min_y) return;
		if (isEmpty || isFull || hasMesh) return;
		chunk_mesh_node = new MeshGeneration(this);
		this.hasMesh = true;
		if (isHided) hide_mesh();
		Config.world_node.CallDeferredThreadGroup("add_child", chunk_mesh_node);
	}
	
	public void remove_mesh() {
		if (!hasMesh) return;
		hide_mesh();
		chunk_mesh_node.collission_ref.Disabled = true;
		Config.world_node.mesh_to_free.Add(chunk_mesh_node);
		hasMesh = false;
	}

	public void hide_mesh() {
		if (!hasMesh) return;
		chunk_mesh_node.Visible = false;
	}
		
	public void show_mesh() {
		if (!hasMesh) return;
		chunk_mesh_node.Visible = true;
	}
}
