CREATE PROGRAM br_datamart_rpt_layout_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_rpt_layout_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, constant(size(requestin->list_0,5))
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 id = f8
     2 layout_flag = i2
     2 exists_ind = i2
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_category c,
   br_datamart_report r
  PLAN (d)
   JOIN (c
   WHERE c.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
   JOIN (r
   WHERE r.br_datamart_category_id=c.br_datamart_category_id
    AND r.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
  ORDER BY d.seq
  HEAD d.seq
   br_existsinfo->list_0[d.seq].id = r.br_datamart_report_id
   IF (cnvtupper(requestin->list_0[d.seq].layout_flag)="10")
    br_existsinfo->list_0[d.seq].layout_flag = 10
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="9")
    br_existsinfo->list_0[d.seq].layout_flag = 9
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="8")
    br_existsinfo->list_0[d.seq].layout_flag = 8
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="7")
    br_existsinfo->list_0[d.seq].layout_flag = 7
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="6")
    br_existsinfo->list_0[d.seq].layout_flag = 6
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="5")
    br_existsinfo->list_0[d.seq].layout_flag = 5
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="4")
    br_existsinfo->list_0[d.seq].layout_flag = 4
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="3")
    br_existsinfo->list_0[d.seq].layout_flag = 3
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="2")
    br_existsinfo->list_0[d.seq].layout_flag = 2
   ELSEIF (cnvtupper(requestin->list_0[d.seq].layout_flag)="1")
    br_existsinfo->list_0[d.seq].layout_flag = 1
   ELSE
    br_existsinfo->list_0[d.seq].layout_flag = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datam_report_layout l
  PLAN (d)
   JOIN (l
   WHERE (l.br_datamart_report_id=br_existsinfo->list_0[d.seq].id))
  ORDER BY d.seq
  HEAD d.seq
   br_existsinfo->list_0[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datam_report_layout l,
   (dummyt d  WITH seq = value(cnt))
  SET l.br_datam_report_layout_id = seq(bedrock_seq,nextval), l.br_datamart_report_id = br_existsinfo
   ->list_0[d.seq].id, l.layout_flag = br_existsinfo->list_0[d.seq].layout_flag,
   l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].id > 0)
    AND (br_existsinfo->list_0[d.seq].exists_ind=0))
   JOIN (l)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart report layout >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datam_report_layout l,
   (dummyt d  WITH seq = value(cnt))
  SET l.layout_flag = br_existsinfo->list_0[d.seq].layout_flag, l.updt_cnt = (l.updt_cnt+ 1), l
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].id > 0)
    AND (br_existsinfo->list_0[d.seq].exists_ind=1))
   JOIN (l
   WHERE (l.br_datamart_report_id=br_existsinfo->list_0[d.seq].id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart report layout >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_rpt_layout_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
END GO
