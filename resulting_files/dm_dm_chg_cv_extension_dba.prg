CREATE PROGRAM dm_dm_chg_cv_extension:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 field_name = c32
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET number_to_update = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_update)
 SET failures = 0
 SET x = 1
 SET dm_display = fillstring(40," ")
 SET dm_display_key = fillstring(40," ")
 SET dm_cdf_meaning = fillstring(12," ")
 SET dm_active_ind = 0
 SET dm_code_value = 0.00
 SET display_dup_ind = 0
 SET display_key_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
#start_loop
 FOR (x = 1 TO number_to_update)
   SET com_del_ind = 0
   SET cse_del_ind = 1
   SELECT
    cse.delete_ind
    FROM dm_adm_code_set_extension cse
    WHERE cse.field_name=trim(request->qual[x].field_name)
     AND (cse.code_set=request->qual[x].code_set)
     AND datetimediff(cse.schema_date,cnvtdatetime(request->schema_date))=0
    DETAIL
     cse_del_ind = cse.delete_ind
    WITH nocounter
   ;end select
   SET new_code_value = 0.00
   SET cve_del_ind = 1
   SELECT INTO "nl:"
    c.code_value, c.delete_ind
    FROM dm_adm_code_value c
    WHERE (c.code_set=request->qual[x].code_set)
     AND datetimediff(c.schema_date,cnvtdatetime(request->schema_date))=0
     AND c.cki=trim(request->qual[x].cki)
    DETAIL
     dm_code_value = c.code_value, cve_del_ind = c.delete_ind
    WITH nocounter
   ;end select
   IF (((cse_del_ind=1) OR (((cve_del_ind=1) OR (request->qual[x].delete_ind)) )) )
    SET com_del_ind = 1
   ENDIF
   IF (curqual > 0)
    INSERT  FROM dm_adm_code_value_extension c
     (c.code_set, c.code_value, c.field_name,
     c.field_type, c.field_value, c.updt_task,
     c.updt_id, c.updt_cnt, c.updt_dt_tm,
     c.updt_applctx, c.schema_date, c.delete_ind)(SELECT
      request->qual[x].code_set, dm_code_value, cse.field_name,
      request->qual[x].field_type, request->qual[x].field_value, reqinfo->updt_task,
      reqinfo->updt_id, 0, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_applctx, cnvtdatetime(request->schema_date), com_del_ind
      FROM dm_adm_code_set_extension cse
      WHERE cse.field_name=trim(request->qual[x].field_name)
       AND (cse.code_set=request->qual[x].code_set)
       AND datetimediff(cse.schema_date,cnvtdatetime(request->schema_date))=0)
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "S"
    ELSE
     SET reply->qual[x].code_value = request->qual[x].code_value
     SET reply->qual[x].field_name = request->qual[x].field_name
     SET reply->qual[x].status = "I"
    ENDIF
   ELSE
    SET reply->qual[x].code_value = request->qual[x].code_value
    SET reply->qual[x].field_name = request->qual[x].field_name
    SET reply->qual[x].status = "X"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 COMMIT
END GO
