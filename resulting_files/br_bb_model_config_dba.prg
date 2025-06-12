CREATE PROGRAM br_bb_model_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_bb_model_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE mcnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE maxcnt = i4 WITH protect, noconstant(0)
 DECLARE model_name = vc
 SET cnt = size(requestin->list_0,5)
 FREE SET model
 RECORD model(
   1 mqual[*]
     2 name = vc
     2 id = f8
     2 cd = f8
     2 aqual[*]
       3 aborh_mean = vc
       3 aborh_cd = f8
       3 alias = vc
 )
 SET model_name = " "
 FOR (x = 1 TO cnt)
   IF ((requestin->list_0[x].model != model_name))
    SET acnt = 1
    SET mcnt = (mcnt+ 1)
    SET stat = alterlist(model->mqual,mcnt)
    SET model->mqual[mcnt].name = requestin->list_0[x].model
    SET model_id = 0.0
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      model_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET model->mqual[mcnt].id = model_id
    SET model_name = requestin->list_0[x].model
    SET stat = alterlist(model->mqual[mcnt].aqual,acnt)
    SET model->mqual[mcnt].aqual[acnt].aborh_mean = cnvtupper(cnvtalphanum(requestin->list_0[x].
      aborh_mean))
    SET model->mqual[mcnt].aqual[acnt].alias = requestin->list_0[x].alias
   ELSE
    SET acnt = (acnt+ 1)
    SET stat = alterlist(model->mqual[mcnt].aqual,acnt)
    SET model->mqual[mcnt].aqual[acnt].aborh_mean = cnvtupper(cnvtalphanum(requestin->list_0[x].
      aborh_mean))
    SET model->mqual[mcnt].aqual[acnt].alias = requestin->list_0[x].alias
    IF (acnt > maxcnt)
     SET maxcnt = acnt
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(mcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE c.code_set=73
    AND c.cdf_meaning="BLOODBANK"
    AND cnvtupper(c.display)=cnvtupper(model->mqual[d.seq].name))
  ORDER BY d.seq
  HEAD d.seq
   model->mqual[d.seq].cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(mcnt)),
   (dummyt d2  WITH seq = 1),
   code_value c
  PLAN (d1
   WHERE maxrec(d2,size(model->mqual[d1.seq].aqual,5)))
   JOIN (d2
   WHERE (model->mqual[d1.seq].aqual[d2.seq].aborh_mean > " "))
   JOIN (c
   WHERE c.code_set=1640
    AND (c.cdf_meaning=model->mqual[d1.seq].aqual[d2.seq].aborh_mean))
  DETAIL
   model->mqual[d1.seq].aqual[d2.seq].aborh_cd = c.code_value
  WITH nocounter
 ;end select
 INSERT  FROM br_bb_model b,
   (dummyt d  WITH seq = value(mcnt))
  SET b.br_bb_model_id = model->mqual[d.seq].id, b.model_cd = model->mqual[d.seq].cd, b.model_name =
   model->mqual[d.seq].name,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting bloodbank models >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_bb_model_alias b,
   (dummyt d1  WITH seq = value(mcnt)),
   (dummyt d2  WITH seq = value(maxcnt))
  SET b.br_bb_model_alias_id = seq(bedrock_seq,nextval), b.br_bb_model_id = model->mqual[d1.seq].id,
   b.aborh_cd = model->mqual[d1.seq].aqual[d2.seq].aborh_cd,
   b.br_bb_model_alias = model->mqual[d1.seq].aqual[d2.seq].alias, b.updt_id = reqinfo->updt_id, b
   .updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx =
   reqinfo->updt_applctx
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(model->mqual[d1.seq].aqual,5))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting model aliases >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_bb_model_config.prg> script"
#exit_script
 FREE RECORD model
END GO
