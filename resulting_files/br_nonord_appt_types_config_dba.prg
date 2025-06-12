CREATE PROGRAM br_nonord_appt_types_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_nonord_appt_types_config.prg> script"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 aqual[*]
     2 appointment_type = vc
     2 dept_type_id = f8
     2 match_appt_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  HEAD REPORT
   stat = alterlist(temp->aqual,cnt)
  DETAIL
   temp->aqual[d.seq].appointment_type = requestin->list_0[d.seq].appointment_type, temp->aqual[d.seq
   ].dept_type_id = 0, temp->aqual[d.seq].match_appt_type_cd = 0
  WITH nocounter
 ;end select
 IF (value(size(temp->aqual,5))=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Nothing populated into aqual"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->aqual,5))),
   br_sched_dept_type b
  PLAN (d)
   JOIN (b
   WHERE cnvtupper(b.dept_type_display)=cnvtupper(requestin->list_0[d.seq].department_type))
  DETAIL
   temp->aqual[d.seq].dept_type_id = b.dept_type_id
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM br_sched_appt_type b,
   (dummyt d  WITH seq = value(size(temp->aqual,5)))
  SET b.appt_type_id = seq(bedrock_seq,nextval), b.appt_type_display = temp->aqual[d.seq].
   appointment_type, b.match_appt_type_cd = temp->aqual[d.seq].match_appt_type_cd,
   b.catalog_type_cd = 0, b.orders_based_ind = 0, b.dept_type_id = temp->aqual[d.seq].dept_type_id,
   b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure: ",serrmsg)
  CALL echo(serrmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_nonord_appt_types_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
