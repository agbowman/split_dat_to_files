CREATE PROGRAM dm_code_cdf_ext_import:dba
 RECORD request(
   1 code_set = f8
   1 cdf_meaning = c12
   1 field_name = c32
   1 field_seq = i4
   1 field_type = i2
   1 field_len = i4
   1 field_prompt = c50
   1 field_in_mask = c50
   1 field_out_mask = c50
   1 val_condition = c100
   1 val_code_set = i4
   1 action_field = c50
   1 field_default = c50
   1 field_help = c100
   1 field_value = c100
 )
 SET request->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET request->cdf_meaning = requestin->list_0[1].cdf_meaning
 SET request->field_name = requestin->list_0[1].field_name
 SET request->field_seq = cnvtint(requestin->list_0[1].field_seq)
 SET request->field_type = cnvtint(requestin->list_0[1].field_type)
 SET request->field_len = cnvtint(requestin->list_0[1].field_len)
 SET request->field_prompt = requestin->list_0[1].field_prompt
 SET request->field_in_mask = requestin->list_0[1].field_in_mask
 SET request->field_out_mask = requestin->list_0[1].field_out_mask
 SET request->val_condition = requestin->list_0[1].val_condition
 SET request->val_code_set = cnvtint(requestin->list_0[1].val_code_set)
 SET request->action_field = requestin->list_0[1].action_field
 SET request->field_default = requestin->list_0[1].field_default
 SET request->field_help = requestin->list_0[1].field_help
 SET request->field_value = requestin->list_0[1].field_value
 EXECUTE dm_code_cdf_ext
END GO
