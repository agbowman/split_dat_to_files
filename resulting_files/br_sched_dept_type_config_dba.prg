CREATE PROGRAM br_sched_dept_type_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_sched_dept_type_config.prg> script"
 FREE SET requestin2
 RECORD requestin2(
   1 item[*]
     2 department_name = vc
     2 prefix = vc
     2 catalog_type = vc
     2 cat_cdf = vc
     2 activity_type = vc
     2 act_cdf = vc
     2 sub_activity_type1 = vc
     2 sub_act_cdf1 = vc
     2 sub_activity_type2 = vc
     2 sub_act_cdf2 = vc
     2 cat_type_code_value = f8
     2 act_type_code_value = f8
     2 sub_act_type_code_value1 = f8
     2 sub_act_type_code_value2 = f8
     2 update_dept_id = f8
 )
 FREE SET sub_act
 RECORD sub_act(
   1 codes[*]
     2 sub_act_cdf1 = vc
     2 sub_act_cdf2 = vc
     2 sub_act_type_code_value1 = f8
     2 sub_act_type_code_value2 = f8
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET tot_cnt = size(requestin->list_0,5)
 SET stat = alterlist(requestin2->item,tot_cnt)
 SET del_dept_type_id = 0.0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  DETAIL
   requestin2->item[d.seq].department_name = requestin->list_0[d.seq].department_name, requestin2->
   item[d.seq].prefix = requestin->list_0[d.seq].prefix, requestin2->item[d.seq].catalog_type =
   requestin->list_0[d.seq].catalog_type,
   requestin2->item[d.seq].cat_cdf = requestin->list_0[d.seq].cat_cdf, requestin2->item[d.seq].
   activity_type = requestin->list_0[d.seq].activity_type, requestin2->item[d.seq].act_cdf =
   requestin->list_0[d.seq].act_cdf,
   requestin2->item[d.seq].sub_activity_type1 = requestin->list_0[d.seq].sub_activity_type1,
   requestin2->item[d.seq].sub_act_cdf1 = requestin->list_0[d.seq].sub_act_cdf1, requestin2->item[d
   .seq].sub_activity_type2 = requestin->list_0[d.seq].sub_activity_type2,
   requestin2->item[d.seq].sub_act_cdf2 = requestin->list_0[d.seq].sub_act_cdf2, requestin2->item[d
   .seq].cat_type_code_value = 0.0, requestin2->item[d.seq].act_type_code_value = 0.0,
   requestin2->item[d.seq].sub_act_type_code_value1 = 0.0, requestin2->item[d.seq].
   sub_act_type_code_value2 = 0.0, requestin2->item[d.seq].update_dept_id = 0.0
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure loading requestin records:",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d
   WHERE (requestin2->item[d.seq].cat_cdf > " "))
   JOIN (cv
   WHERE cv.code_set=6000
    AND (cv.cdf_meaning=requestin2->item[d.seq].cat_cdf)
    AND cv.active_ind=1)
  DETAIL
   requestin2->item[d.seq].cat_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d
   WHERE (requestin2->item[d.seq].act_cdf > " "))
   JOIN (cv
   WHERE cv.code_set=106
    AND (cv.cdf_meaning=requestin2->item[d.seq].act_cdf)
    AND cv.active_ind=1)
  DETAIL
   requestin2->item[d.seq].act_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d
   WHERE (((requestin2->item[d.seq].sub_act_cdf1 > " ")) OR ((requestin2->item[d.seq].sub_act_cdf2 >
   " "))) )
   JOIN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning IN (requestin2->item[d.seq].sub_act_cdf1, requestin2->item[d.seq].sub_act_cdf2
   )
    AND cv.active_ind=1)
  HEAD REPORT
   stat = alterlist(sub_act->codes,10), subcnt = 0
  DETAIL
   subcnt = (subcnt+ 1)
   IF (mod(subcnt,10)=1
    AND subcnt != 1)
    stat = alterlist(sub_act->codes,(subcnt+ 9))
   ENDIF
   IF ((cv.cdf_meaning=requestin2->item[d.seq].sub_act_cdf1))
    sub_act->codes[subcnt].sub_act_type_code_value1 = cv.code_value, sub_act->codes[subcnt].
    sub_act_cdf1 = requestin2->item[d.seq].sub_act_cdf1
   ENDIF
   IF ((cv.cdf_meaning=requestin2->item[d.seq].sub_act_cdf2))
    sub_act->codes[subcnt].sub_act_type_code_value2 = cv.code_value, sub_act->codes[subcnt].
    sub_act_cdf2 = requestin2->item[d.seq].sub_act_cdf2
   ENDIF
  FOOT REPORT
   stat = alterlist(sub_act->codes,subcnt)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_sched_dept_type b,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d
   WHERE (requestin2->item[d.seq].department_name > " ")
    AND (requestin2->item[d.seq].prefix > " "))
   JOIN (b
   WHERE b.dept_type_display=trim(substring(1,40,requestin2->item[d.seq].department_name)))
  DETAIL
   requestin2->item[d.seq].update_dept_id = b.dept_type_id
  WITH nocounter
 ;end select
 DELETE  FROM br_sched_dept_type_r btr,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET btr.seq = 1
  PLAN (d
   WHERE (requestin2->item[d.seq].update_dept_id > 0.0))
   JOIN (btr
   WHERE (requestin2->item[d.seq].update_dept_id=btr.dept_type_id))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Deleting br_sched_dept_type_r rows:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_sched_dept_type b,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET b.dept_type_prefix = trim(substring(1,4,requestin2->item[d.seq].prefix)), b.updt_cnt = (b
   .updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (requestin2->item[d.seq].update_dept_id > 0.0))
   JOIN (b
   WHERE (requestin2->item[d.seq].update_dept_id=b.dept_type_id)
    AND (requestin2->item[d.seq].prefix != b.dept_type_prefix))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Updating prefix for br_sched_dept_type:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_sched_dept_type b,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET b.dept_type_id = seq(bedrock_seq,nextval), b.dept_type_display = trim(substring(1,40,requestin2
     ->item[d.seq].department_name)), b.dept_type_prefix = trim(substring(1,4,requestin2->item[d.seq]
     .prefix)),
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (requestin2->item[d.seq].update_dept_id=0.0))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed:Inserting into br_sched_dept_type:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "NL:"
  FROM br_sched_dept_type b,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  PLAN (d
   WHERE (requestin2->item[d.seq].update_dept_id=0.0)
    AND (requestin2->item[d.seq].department_name > " ")
    AND (requestin2->item[d.seq].prefix > " "))
   JOIN (b
   WHERE b.dept_type_display=trim(substring(1,40,requestin2->item[d.seq].department_name))
    AND b.dept_type_prefix=trim(substring(1,4,requestin2->item[d.seq].prefix)))
  DETAIL
   requestin2->item[d.seq].update_dept_id = b.dept_type_id
  WITH nocounter
 ;end select
 INSERT  FROM br_sched_dept_type_r btr,
   (dummyt d  WITH seq = value(size(requestin2->item,5))),
   (dummyt d2  WITH seq = value(size(sub_act->codes,5)))
  SET btr.dept_type_id = requestin2->item[d.seq].update_dept_id, btr.catalog_type_cd = requestin2->
   item[d.seq].cat_type_code_value, btr.activity_type_cd = requestin2->item[d.seq].
   act_type_code_value,
   btr.activity_subtype_cd = sub_act->codes[d2.seq].sub_act_type_code_value1, btr.updt_cnt = 0, btr
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   btr.updt_id = reqinfo->updt_id, btr.updt_task = reqinfo->updt_task, btr.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (requestin2->item[d.seq].sub_act_cdf1 > " ")
    AND (requestin2->item[d.seq].cat_type_code_value > 0.0))
   JOIN (d2
   WHERE (requestin2->item[d.seq].sub_act_cdf1=sub_act->codes[d2.seq].sub_act_cdf1))
   JOIN (btr)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed:Inserting sub_act_type_code_value1 into br_sched_dept_type_r:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_sched_dept_type_r btr,
   (dummyt d  WITH seq = value(size(requestin2->item,5))),
   (dummyt d2  WITH seq = value(size(sub_act->codes,5)))
  SET btr.dept_type_id = requestin2->item[d.seq].update_dept_id, btr.catalog_type_cd = requestin2->
   item[d.seq].cat_type_code_value, btr.activity_type_cd = requestin2->item[d.seq].
   act_type_code_value,
   btr.activity_subtype_cd = sub_act->codes[d2.seq].sub_act_type_code_value2, btr.updt_cnt = 0, btr
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   btr.updt_id = reqinfo->updt_id, btr.updt_task = reqinfo->updt_task, btr.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (requestin2->item[d.seq].sub_act_cdf2 > " ")
    AND (requestin2->item[d.seq].cat_type_code_value > 0.0))
   JOIN (d2
   WHERE (requestin2->item[d.seq].sub_act_cdf2=sub_act->codes[d2.seq].sub_act_cdf2))
   JOIN (btr)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed:Inserting sub_act_type_code_value2 into br_sched_dept_type_r:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_sched_dept_type_r btr,
   (dummyt d  WITH seq = value(size(requestin2->item,5)))
  SET btr.dept_type_id = requestin2->item[d.seq].update_dept_id, btr.catalog_type_cd = requestin2->
   item[d.seq].cat_type_code_value, btr.activity_type_cd = requestin2->item[d.seq].
   act_type_code_value,
   btr.activity_subtype_cd = requestin2->item[d.seq].sub_act_type_code_value1, btr.updt_cnt = 0, btr
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   btr.updt_id = reqinfo->updt_id, btr.updt_task = reqinfo->updt_task, btr.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (requestin2->item[d.seq].sub_act_cdf1="")
    AND (requestin2->item[d.seq].sub_act_cdf2="")
    AND (requestin2->item[d.seq].cat_type_code_value > 0.0))
   JOIN (btr)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed:Inserting sub_act_type_code_value1 into br_sched_dept_type_r:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_sched_dept_type_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
