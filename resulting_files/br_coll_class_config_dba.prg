CREATE PROGRAM br_coll_class_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_coll_class_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET row_cnt = size(requestin->list_0,5)
 SET dup_cnt = 0
 SET default_display_name = fillstring(10," ")
 FOR (x = 1 TO row_cnt)
  SELECT INTO "NL:"
   FROM br_coll_class bcc
   WHERE cnvtupper(bcc.activity_type)=cnvtupper(requestin->list_0[x].activity_type)
    AND cnvtupper(bcc.collection_class)=cnvtupper(requestin->list_0[x].collection_class)
    AND bcc.facility_id=0.0
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_coll_class b
    SET b.activity_type = requestin->list_0[x].activity_type, b.collection_class = requestin->list_0[
     x].collection_class, b.proposed_name_suffix = requestin->list_0[x].proposed_name_suffix,
     b.facility_id = 0.0, b.display_name = default_display_name, b.storage_tracking_ind = 0,
     b.code_value = 0.0, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
  ELSE
   SET dup_cnt = (dup_cnt+ 1)
  ENDIF
 ENDFOR
#exit_script
 IF (dup_cnt <= row_cnt)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_coll_class_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_coll_class_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
