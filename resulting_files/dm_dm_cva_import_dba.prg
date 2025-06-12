CREATE PROGRAM dm_dm_cva_import:dba
 FREE SET request
 RECORD request(
   1 code_set = i4
   1 dm_mode = i2
   1 qual[x]
     2 display = vc
     2 cdf_meaning = vc
     2 active_ind = i2
     2 contributor_source_cd = f8
     2 contributor_source_disp = vc
     2 alias_type_meaning = vc
     2 alias = vc
     2 updt_cnt = i4
 )
 SET request->dm_mode = 0
 SET request->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET request->qual[1].display = requestin->list_0[1].display
 SET request->qual[1].cdf_meaning = requestin->list_0[1].cdf_meaning
 SET request->qual[1].active_ind = requestin->list_0[1].active_ind
 SET request->qual[1].contributor_source_cd = requestin->list_0[1].contributor_source_cd
 SET request->qual[1].contrigutor_source_disp = requestin->list_0[1].field_type
 SET request->qual[1].field_value = requestin->list_0[1].field_value
 SET request->qual[1].field_seq = cnvtreal(requestin->list_0[1].field_seq)
 EXECUTE dm_dm_insert_code_alias
END GO
