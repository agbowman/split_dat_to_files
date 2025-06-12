CREATE PROGRAM br_reg_rpt_filter_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_reg_rpt_filter_config.prg> script"
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
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_report bdr,
   br_datamart_filter bdf,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdr
   WHERE bdr.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
   JOIN (bdf
   WHERE bdf.br_datamart_category_id=bdr.br_datamart_category_id
    AND bdf.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].reportid = bdr.br_datamart_report_id, br_existsinfo->list_0[d.seq].
   filterid = bdf.br_datamart_filter_id, br_existsinfo->list_0[d.seq].baseexistsind = 1
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
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].r_existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 UPDATE  FROM br_datamart_report_filter_r b,
   (dummyt d  WITH seq = value(cnt))
  SET b.denominator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].denominator_ind),"X",1,0), b
   .numerator_ind = evaluate(cnvtupper(requestin->list_0[d.seq].numerator_ind),"X",1,0), b.updt_cnt
    = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
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
  SET readme_data->message = concat("Failure inserting datamart report filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_reg_rpt_filter_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
