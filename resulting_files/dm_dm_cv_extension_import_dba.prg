CREATE PROGRAM dm_dm_cv_extension_import:dba
 FREE SET request
 RECORD request(
   1 code_set = i4
   1 dm_mode = i2
   1 qual[1]
     2 display = vc
     2 active_ind = i2
     2 cdf_meaning = vc
     2 field_name = vc
     2 field_type = i4
     2 field_value = vc
     2 field_seq = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET request->dm_mode = 0
 SET request->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET request->qual[1].display = requestin->list_0[1].display
 SET request->qual[1].active = cnvtint(requestin->list_0[1].active_ind)
 SET request->qual[1].cdf_meaning = requestin->list_0[1].cdf_meaning
 SET request->qual[1].field_name = requestin->list_0[1].field_name
 SET request->qual[1].field_type = requestin->list_0[1].field_type
 SET request->qual[1].field_value = requestin->list_0[1].field_value
 SET request->qual[1].field_seq = cnvtreal(requestin->list_0[1].field_seq)
 EXECUTE dm_dm_insert_cv_extension
END GO
