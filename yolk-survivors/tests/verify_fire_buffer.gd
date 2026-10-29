extends SceneTree
func _initialize(): call_deferred("verify")
func verify():
	var buffer:=PackedFloat32Array()
	buffer.resize(16)
	root.get_node("GroundFire")._write_instance(buffer,0,Vector2(100,200),Vector2(20,40),0.5,Color(1,2,3,4))
	assert(buffer[0]==20 and buffer[3]==100 and buffer[5]==40 and buffer[7]==200)
	print("PASS fire instance buffer mutates in place")
	quit()
