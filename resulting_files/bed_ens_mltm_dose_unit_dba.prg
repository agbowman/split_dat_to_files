CREATE PROGRAM bed_ens_mltm_dose_unit:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_alias
 RECORD temp_alias(
   1 alias[*]
     2 value = vc
 )
 DECLARE temp_cki = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET list_cnt = 0
 SET tot_cnt = 0
 SET contributor_code_value = 0.0
 SET cnt = size(request->unit_of_measure,5)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="MULTUM"
   AND cv.active_ind=1
  DETAIL
   contributor_code_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   SET temp_cki = " "
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->unit_of_measure[x].code_value)
     AND cv.active_ind=1
    DETAIL
     temp_cki = cv.cki
    WITH nocounter
   ;end select
   IF (temp_cki > " ")
    SELECT INTO "nl:"
     FROM br_name_value b,
      code_value cv
     PLAN (b
      WHERE b.br_nv_key1="MLTM_UOM_ALIAS"
       AND b.br_name=temp_cki)
      JOIN (cv
      WHERE cv.cki=b.br_name
       AND cv.active_ind=1)
     HEAD REPORT
      list_cnt = 0, tot_cnt = 0, stat = alterlist(temp_alias->alias,10)
     DETAIL
      list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (tot_cnt > 10)
       stat = alterlist(temp_alias->alias,(list_cnt+ 10)), tot_cnt = 1
      ENDIF
      temp_alias->alias[list_cnt].value = b.br_value
     FOOT REPORT
      stat = alterlist(temp_alias->alias,list_cnt)
     WITH nocounter
    ;end select
    IF (list_cnt > 0)
     FOR (y = 1 TO list_cnt)
       DELETE  FROM code_value_alias cva
        WHERE (cva.code_value=request->unit_of_measure[x].code_value)
         AND (cva.alias=temp_alias->alias[y].value)
         AND cva.code_set=54
         AND cva.contributor_source_cd=contributor_code_value
        WITH nocoutner
       ;end delete
     ENDFOR
    ENDIF
   ENDIF
   IF ((request->unit_of_measure[x].cki > " "))
    SELECT INTO "nl:"
     FROM br_name_value b
     PLAN (b
      WHERE b.br_nv_key1="MLTM_UOM_ALIAS"
       AND (b.br_name=request->unit_of_measure[x].cki))
     HEAD REPORT
      list_cnt = 0, tot_cnt = 0, stat = alterlist(temp_alias->alias,10)
     DETAIL
      list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (tot_cnt > 10)
       stat = alterlist(temp_alias->alias,(list_cnt+ 10)), tot_cnt = 1
      ENDIF
      temp_alias->alias[list_cnt].value = b.br_value
     FOOT REPORT
      stat = alterlist(temp_alias->alias,list_cnt)
     WITH nocounter
    ;end select
    FOR (y = 1 TO list_cnt)
      DELETE  FROM code_value_alias cva
       WHERE (cva.alias=temp_alias->alias[y].value)
        AND cva.code_set=54
        AND cva.contributor_source_cd=contributor_code_value
       WITH nocoutner
      ;end delete
      INSERT  FROM code_value_alias cva
       SET cva.code_set = 54, cva.contributor_source_cd = contributor_code_value, cva.alias =
        temp_alias->alias[y].value,
        cva.code_value = request->unit_of_measure[x].code_value, cva.primary_ind = 0, cva
        .alias_type_meaning = null,
        cva.updt_applctx = reqinfo->updt_applctx, cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Unable to insert ",trim(cnvtstring(request->unit_of_measure[x].
          code_value))," with alias: ",trim(temp_alias->alias[y].value))
       GO TO exit_script
      ENDIF
    ENDFOR
    DELETE  FROM br_name_value b
     WHERE b.br_nv_key1="MLTM_IGN_UNITS"
      AND (b.br_value=request->unit_of_measure[x].cki)
      AND b.br_name="MLTM_DRC_PREMISE"
     WITH nocounter
    ;end delete
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.cki = request->unit_of_measure[x].cki, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
     .updt_id = reqinfo->updt_id,
     cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
     .updt_cnt+ 1)
    WHERE (cv.code_value=request->unit_of_measure[x].code_value)
     AND cv.code_set=54
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update ",trim(cnvtstring(request->unit_of_measure[x].
       code_value))," into codeset 54.")
    GO TO exit_script
   ENDIF
   SET pharm_unit_insert = 1
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_value=request->unit_of_measure[x].code_value)
      AND cve.field_name="PHARM_UNIT"
      AND cve.code_set=54)
    DETAIL
     pharm_unit_insert = 0
    WITH nocounter
   ;end select
   IF (pharm_unit_insert=1)
    INSERT  FROM code_value_extension c
     SET c.code_value = request->unit_of_measure[x].code_value, c.code_set = 54, c.field_name =
      "PHARM_UNIT",
      c.field_type = 1.00, c.field_value = "0", c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
      c.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert: ",trim(cnvtstring(request->unit_of_measure[x].
        code_value))," into the code_value_extension table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
