CREATE PROGRAM br_datamart_std_rpt_fltr_conf:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_rpt_fltr_conf.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE lvalidx = i4 WITH protect, noconstant(0)
 DECLARE recidx = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 reportid = f8
     2 filterid = f8
     2 baseexistsind = i2
     2 r_existsind = i2
     2 category_id = f8
     2 report_mean = vc
     2 filter_mean = vc
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_report bdr,
   br_datamart_filter bdf,
   br_datamart_category bdc,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdr
   WHERE bdr.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
   JOIN (bdc
   WHERE bdc.br_datamart_category_id=bdr.br_datamart_category_id
    AND bdc.category_mean != "VB_*"
    AND bdc.category_type_flag=6)
   JOIN (bdf
   WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdf.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].reportid = bdr.br_datamart_report_id, br_existsinfo->list_0[d.seq].
   filterid = bdf.br_datamart_filter_id, br_existsinfo->list_0[d.seq].baseexistsind = 1,
   br_existsinfo->list_0[d.seq].category_id = bdr.br_datamart_category_id, br_existsinfo->list_0[d
   .seq].report_mean = requestin->list_0[d.seq].report_mean, br_existsinfo->list_0[d.seq].filter_mean
    = requestin->list_0[d.seq].filter_mean
  WITH nocounter
 ;end select
 SET recidx = locateval(lvalidx,1,cnt,0,br_existsinfo->list_0[lvalidx].baseexistsind)
 IF (recidx > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("No record for report_mean ",requestin->list_0[recidx].
   report_mean," and filter_mean ",requestin->list_0[recidx].filter_mean)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_report_id=br_existsinfo->list_0[d.seq].reportid)
    AND (b.br_datamart_filter_id=br_existsinfo->list_0[d.seq].filterid))
  DETAIL
   br_existsinfo->list_0[d.seq].r_existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_report_filter_r_id = seq(bedrock_seq,nextval), b.br_datamart_report_id =
   br_existsinfo->list_0[d.seq].reportid, b.br_datamart_filter_id = br_existsinfo->list_0[d.seq].
   filterid,
   b.denominator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].denominator_ind),"X",1,0), b
   .numerator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].numerator_ind),"X",1,0), b.updt_cnt
    = 0,
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].r_existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart report filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(cnt))
  SET b.denominator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].denominator_ind),"X",1,0), b
   .numerator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].numerator_ind),"X",1,0), b.updt_cnt
    = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].r_existsind=1))
   JOIN (b
   WHERE (b.br_datamart_report_id=br_existsinfo->list_0[d.seq].reportid)
    AND (b.br_datamart_filter_id=br_existsinfo->list_0[d.seq].filterid))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart report filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 FREE RECORD customreportupdates
 RECORD customreportupdates(
   1 upds[*]
     2 action_flag = i2
     2 report_id = f8
     2 filter_id = f8
     2 category_id = f8
     2 copy_filter_id = f8
     2 filter_mean = vc
     2 denominator_ind = vc
     2 numerator_ind = vc
     2 display = vc
     2 sequence = i4
     2 filter_category_mean = vc
     2 filter_limit = i4
 )
 SET utot_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_report r,
   br_datamart_category c,
   br_datamart_report_filter_r b,
   br_datamart_filter f
  PLAN (d)
   JOIN (r
   WHERE r.report_mean=cnvtupper(br_existsinfo->list_0[d.seq].report_mean))
   JOIN (c
   WHERE c.br_datamart_category_id=r.br_datamart_category_id
    AND c.category_type_flag=1
    AND c.category_mean="VB_*")
   JOIN (b
   WHERE b.br_datamart_report_id=r.br_datamart_report_id)
   JOIN (f
   WHERE (f.br_datamart_filter_id= Outerjoin(b.br_datamart_filter_id))
    AND (f.filter_mean= Outerjoin(cnvtupper(br_existsinfo->list_0[d.seq].filter_mean))) )
  ORDER BY d.seq, r.br_datamart_report_id, f.br_datamart_filter_id
  HEAD REPORT
   ucnt = 0, utot_cnt = 0, stat = alterlist(customreportupdates->upds,100)
  HEAD d.seq
   do_something = 1
  HEAD r.br_datamart_report_id
   filter_found = 0
  DETAIL
   IF (f.br_datamart_filter_id > 0)
    filter_found = 1
   ENDIF
  FOOT  r.br_datamart_report_id
   ucnt += 1, utot_cnt += 1
   IF (ucnt > 100)
    stat = alterlist(customreportupdates->upds,(utot_cnt+ 100)), ucnt = 1
   ENDIF
   customreportupdates->upds[utot_cnt].category_id = c.br_datamart_category_id, customreportupdates->
   upds[utot_cnt].filter_id = f.br_datamart_filter_id, customreportupdates->upds[utot_cnt].report_id
    = r.br_datamart_report_id,
   customreportupdates->upds[utot_cnt].filter_mean = cnvtupper(br_existsinfo->list_0[d.seq].
    filter_mean), customreportupdates->upds[utot_cnt].copy_filter_id = br_existsinfo->list_0[d.seq].
   filterid, customreportupdates->upds[utot_cnt].denominator_ind = requestin->list_0[d.seq].
   denominator_ind,
   customreportupdates->upds[utot_cnt].numerator_ind = requestin->list_0[d.seq].numerator_ind,
   customreportupdates->upds[utot_cnt].action_flag = evaluate(filter_found,1,2,1)
  FOOT REPORT
   stat = alterlist(customreportupdates->upds,utot_cnt)
  WITH nocounter
 ;end select
 IF (utot_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_datamart_rpt_filter_config.prg> script"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(utot_cnt)),
   br_datamart_filter f
  PLAN (d)
   JOIN (f
   WHERE (f.br_datamart_filter_id=customreportupdates->upds[d.seq].copy_filter_id))
  ORDER BY d.seq
  DETAIL
   customreportupdates->upds[d.seq].display = f.filter_display, customreportupdates->upds[d.seq].
   filter_category_mean = f.filter_category_mean, customreportupdates->upds[d.seq].filter_limit = f
   .filter_limit,
   customreportupdates->upds[d.seq].sequence = f.filter_seq
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure getting datamart report filter details >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(utot_cnt))
  SET b.filter_display = customreportupdates->upds[d.seq].display, b.filter_seq = customreportupdates
   ->upds[d.seq].sequence, b.filter_category_mean = cnvtupper(customreportupdates->upds[d.seq].
    filter_category_mean),
   b.filter_limit = customreportupdates->upds[d.seq].filter_limit, b.updt_cnt = (b.updt_cnt+ 1), b
   .updt_dt_tm = cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (customreportupdates->upds[d.seq].action_flag=2))
   JOIN (b
   WHERE (b.br_datamart_filter_id=customreportupdates->upds[d.seq].filter_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating custom datamart report filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(utot_cnt))
  SET b.denominator_ind = evaluate(cnvtupper(customreportupdates->upds[d.seq].denominator_ind),"X",1,
    0), b.numerator_ind = evaluate(cnvtupper(customreportupdates->upds[d.seq].numerator_ind),"X",1,0),
   b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (customreportupdates->upds[d.seq].action_flag=2))
   JOIN (b
   WHERE (b.br_datamart_report_id=customreportupdates->upds[d.seq].report_id)
    AND (b.br_datamart_filter_id=customreportupdates->upds[d.seq].filter_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart report filters relations>> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  j = seq(bedrock_seq,nextval)
  FROM (dummyt d  WITH seq = value(utot_cnt)),
   dual dd
  PLAN (d
   WHERE (customreportupdates->upds[d.seq].action_flag=1))
   JOIN (dd)
  DETAIL
   customreportupdates->upds[d.seq].filter_id = cnvtreal(j)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure generating new ids>> ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(utot_cnt))
  SET b.br_datamart_filter_id = customreportupdates->upds[d.seq].filter_id, b.br_datamart_category_id
    = customreportupdates->upds[d.seq].category_id, b.filter_mean = cnvtupper(customreportupdates->
    upds[d.seq].filter_mean),
   b.filter_display = customreportupdates->upds[d.seq].display, b.filter_seq = customreportupdates->
   upds[d.seq].sequence, b.filter_category_mean = cnvtupper(customreportupdates->upds[d.seq].
    filter_category_mean),
   b.filter_limit = customreportupdates->upds[d.seq].filter_limit, b.updt_cnt = 0, b.updt_dt_tm =
   cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (customreportupdates->upds[d.seq].action_flag=1))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(utot_cnt))
  SET b.br_datamart_report_filter_r_id = seq(bedrock_seq,nextval), b.br_datamart_report_id =
   customreportupdates->upds[d.seq].report_id, b.br_datamart_filter_id = customreportupdates->upds[d
   .seq].filter_id,
   b.denominator_ind = evaluate(cnvtupper(customreportupdates->upds[d.seq].denominator_ind),"X",1,0),
   b.numerator_ind = evaluate(cnvtupper(customreportupdates->upds[d.seq].numerator_ind),"X",1,0), b
   .updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (customreportupdates->upds[d.seq].action_flag=1))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart report filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_rpt_fltr_conf.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
 FREE RECORD customreportupdates
END GO
