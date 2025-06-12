CREATE PROGRAM br_pal_columns_config:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_pal_columns_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET error_flag = "N"
 SET failed = "N"
 RECORD temp(
   1 qual[*]
     2 section = vc
     2 column_name = vc
     2 column_name_key = vc
     2 column_meaning = vc
     2 column_cd = f8
     2 column_description = vc
     2 column_type_cd = f8
 )
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET demog_cd = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=25511
    AND c.cdf_meaning="DEMOGFLD"
    AND c.active_ind=1)
  DETAIL
   demog_cd = c.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->qual,cnt)
 FOR (x = 1 TO cnt)
   SET temp->qual[x].section = requestin->list_0[x].section
   SET temp->qual[x].column_name = requestin->list_0[x].column_name
   SET temp->qual[x].column_name_key = cnvtupper(requestin->list_0[x].column_name)
   SET temp->qual[x].column_meaning = requestin->list_0[x].meaning
   IF ((requestin->list_0[x].meaning > " "))
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=6023
       AND (c.cdf_meaning=requestin->list_0[x].meaning)
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_cd = c.code_value
     WITH nocounter
    ;end select
    SET temp->qual[x].column_type_cd = demog_cd
   ENDIF
   SET temp->qual[x].column_description = requestin->list_0[x].column_description
   IF (cnvtupper(requestin->list_0[x].column_name)="ALLERGY INDICATOR")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="ALLERGYIND"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(requestin->list_0[x].column_name)="IV INDICATOR")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="IVIND"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(requestin->list_0[x].column_name)="PROBLEM/DIAGNOSIS INDICATOR")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="PROBLEMIND"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(requestin->list_0[x].column_name)="SCHEDULED EVENTS INDICATOR")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="SCHEDEVENTIN"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(requestin->list_0[x].column_name)="ORDER DETAIL")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="ORDDETAIL"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtupper(requestin->list_0[x].column_name)="CARE PLAN INDICATOR")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=25511
       AND c.cdf_meaning="CAREPLANIND"
       AND c.active_ind=1)
     DETAIL
      temp->qual[x].column_type_cd = c.code_value
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET ierrcode = 0
 INSERT  FROM br_pal_columns b,
   (dummyt d  WITH seq = value(cnt))
  SET b.section = temp->qual[d.seq].section, b.column_name = temp->qual[d.seq].column_name, b
   .column_name_key = temp->qual[d.seq].column_name_key,
   b.column_meaning = temp->qual[d.seq].column_meaning, b.column_cd = temp->qual[d.seq].column_cd, b
   .column_description = temp->qual[d.seq].column_description,
   b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.column_type_cd = temp
   ->qual[d.seq].column_type_cd
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "T"
 ENDIF
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("Unable to insert all rows from pal_column")
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_pal_columns_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_pal_columns_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
