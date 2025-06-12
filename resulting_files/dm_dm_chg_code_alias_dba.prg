CREATE PROGRAM dm_dm_chg_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET x = 0
 SET z = 0
 SET reply->status_data.status = "F"
 SET qual_size = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET stat = alterlist(reply->qual,qual_size)
 SET contrib_source_cd = 0.00
 SET dm_display = fillstring(40," ")
 SET dm_display_key = fillstring(40," ")
 SET dm_cdf_meaning = fillstring(12," ")
 SET dm_active_ind = 0
 SET display_dup_ind = 0
 SET display_key_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET dm_contrib_display = fillstring(40," ")
#startloop
 FOR (x = 1 TO qual_size)
   SET dm_code_value = 0.00
   SET cva_del_ind = 0
   SET contrib_source_cd = 0.00
   SELECT INTO "nl:"
    c.code_value, c.delete_ind
    FROM dm_adm_code_value c
    WHERE (c.code_set=request->qual[x].code_set)
     AND datetimediff(c.schema_date,cnvtdatetime(request->schema_date))=0
     AND c.cki=trim(request->qual[x].cki)
    DETAIL
     dm_code_value = c.code_value, cva_del_ind = c.delete_ind
    WITH nocounter
   ;end select
   IF (((cva_del_ind=1) OR ((request->qual[x].delete_ind=1))) )
    SET cva_del_ind = 1
   ENDIF
   IF (curqual > 0)
    FREE SET r1
    RECORD r1(
      1 rdate = dq8
    )
    SET r1->rdate = 0
    SELECT INTO "NL:"
     dac.schema_date
     FROM dm_adm_code_value dac
     WHERE dac.code_set=73
      AND dac.display=trim(request->qual[x].contributor_source_disp)
     DETAIL
      IF ((dac.schema_date > r1->rdate))
       r1->rdate = dac.schema_date
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     c.code_value
     FROM dm_adm_code_value c
     WHERE c.code_set=73
      AND c.display=trim(request->qual[x].contributor_source_disp)
      AND datetimediff(c.schema_date,cnvtdatetime(r1->rdate))=0
     DETAIL
      contrib_source_cd = c.code_value
     WITH nocounter
    ;end select
    IF (contrib_source_cd > 0)
     INSERT  FROM dm_adm_code_value_alias cva
      SET cva.schema_date = cnvtdatetime(request->schema_date), cva.alias_type_meaning = request->
       qual[x].alias_type_meaning, cva.alias = request->qual[x].alias,
       cva.contributor_source_cd = contrib_source_cd, cva.code_set = request->qual[x].code_set, cva
       .code_value = dm_code_value,
       cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->
       updt_id,
       cva.updt_task = reqinfo->updt_task, cva.updt_applctx = reqinfo->updt_applctx, cva.delete_ind
        = cva_del_ind
      WITH nocounter
     ;end insert
     SET reply->qual[x].status = "S"
    ELSE
     SET reply->qual[x].status = "C"
    ENDIF
   ELSE
    SET reply->qual[x].status = "X"
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
END GO
