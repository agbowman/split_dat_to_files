CREATE PROGRAM dm_dm_cs_extension_import:dba
 FREE SET request
 RECORD request(
   1 code_set = i4
   1 dm_mode = i2
   1 qual[x]
     2 field_name = c32
     2 old_field_name = c32
     2 field_seq = i4
     2 field_type = i4
     2 old_field_type = i4
     2 field_len = i4
     2 field_prompt = c50
     2 field_in_mask = c50
     2 field_out_mask = c50
     2 validation_condition = vc
     2 validation_code_set = i4
     2 action_field = c50
     2 field_default = c50
     2 field_help = vc
     2 updt_cnt = i4
 )
 SET request->dm_mode = 0
 SET request->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET request->qual[1].field_name = requestin->list_0[1].field_name
 SET request->qual[1].old_field_name = requestin->list_0[1].field_name
 SET request->qual[1].field_seq = requestin->list_0[1].field_seq
 SET request->qual[1].field_type = requestin->list_0[1].field_type
 SET request->qual[1].old_field_type = requestin->list_0[1].field_type
 SET request->qual[1].field_len = requestin->list_0[1].field_len
 SET request->qual[1].field_prompt = requestin->list_0[1].field_prompt
 SET request->qual[1].field_in_mask = " "
 SET request->qual[1].field_out_mask = " "
 SET request->qual[1].validation_condition = " "
 SET request->qual[1].validation_code_set = 0
 SET request->qual[1].action_field = " "
 SET request->qual[1].field_default = requestin->list_0[1].field_default
 SET request->qual[1].field_help = requestin->list_0[1].field_help
 EXECUTE dm_dm_chg_cs_extension
END GO
