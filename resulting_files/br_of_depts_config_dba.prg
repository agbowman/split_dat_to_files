CREATE PROGRAM br_of_depts_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_of_depts_config.prg> script"
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
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
 )
 DECLARE error_msg = vc WITH protect
 DECLARE row_cnt = i4 WITH protect
 SET row_cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,row_cnt)
 SELECT INTO "nl:"
  FROM br_of_depts b,
   (dummyt d  WITH seq = value(row_cnt))
  PLAN (d)
   JOIN (b
   WHERE (b.of_dept_name=requestin->list_0[d.seq].of_dept_name))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_of_depts b,
   (dummyt d  WITH seq = value(row_cnt))
  SET b.of_dept_id = seq(bedrock_seq,nextval), b.of_dept_name = requestin->list_0[d.seq].of_dept_name,
   b.updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(error_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert BR_OF_DEPTS rows: ",error_msg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully loaded rows"
 COMMIT
#exit_script
 FREE RECORD br_existsinfo
END GO
