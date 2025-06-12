CREATE PROGRAM dm_ins_cmb_children
 EXECUTE dm_ins_cmb_children_main value(request->setup_proc[1].env_id)
END GO
