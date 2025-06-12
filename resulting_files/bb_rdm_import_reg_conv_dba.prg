CREATE PROGRAM bb_rdm_import_reg_conv:dba
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
 RECORD app_group(
   1 qual[*]
     2 app_group_cd = f8
     2 corereg_access_ind = i2
     2 grant_access_ind = i2
 )
 DECLARE conv_id = f8 WITH protect, noconstant(0.0)
 DECLARE activecd = f8 WITH protect, noconstant(0.0)
 DECLARE seq_id = f8 WITH protect, noconstant(0.0)
 DECLARE flexreg_task = i4 WITH protect, constant(100000)
 DECLARE corereg_task = i4 WITH protect, constant(100005)
 DECLARE bb_common_task = i4 WITH protect, constant(225800)
 DECLARE bb_reg_conv_task = i4 WITH protect, constant(225597)
 DECLARE lgroupcnt = i4 WITH protect, noconstant(0)
 DECLARE lgrantaccesscnt = i4 WITH protect, noconstant(0)
 EXECUTE dm_dbimport "cer_install:bb_flex_reg_conv.csv", "pm_imp_flx_conversation", 1000
 SELECT INTO "nl:"
  pfc.conversation_id
  FROM pm_flx_conversation pfc
  PLAN (pfc
   WHERE pfc.conversation_id > 0.0
    AND cnvtupper(pfc.description)="BLOOD BANK REGISTRATION"
    AND pfc.active_ind=1)
  DETAIL
   conv_id = pfc.conversation_id
  WITH nocounter
 ;end select
 IF (conv_id > 0.0)
  SELECT INTO "nl:"
   p.task
   FROM pm_flx_task_conv_reltn p
   PLAN (p
    WHERE p.task=bb_common_task
     AND p.active_ind=1)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=48
      AND cv.cdf_meaning="ACTIVE"
      AND cv.active_ind=1)
    DETAIL
     activecd = cv.code_value
    WITH nocounter
   ;end select
   SET seq_id = 0.0
   SELECT INTO "nl:"
    y = seq(pm_task_conv_reltn_id_seq,nextval)
    FROM dual
    DETAIL
     seq_id = y
    WITH format, counter
   ;end select
   IF (curqual > 0)
    INSERT  FROM pm_flx_task_conv_reltn p
     SET p.task_conv_reltn_id = seq_id, p.task = bb_common_task, p.organization_id = 0.0,
      p.conversation_id = conv_id, p.action = 900, p.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3),
      p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p.active_ind = 1, p
      .active_status_cd = activecd,
      p.active_status_prsnl_id = 0.0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_cnt = 0,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 0.0, p.updt_applctx = 0,
      p.updt_task = 0
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SELECT DISTINCT INTO "nl:"
      t.app_group_cd
      FROM task_access t
      PLAN (t
       WHERE t.task_number=bb_common_task)
      ORDER BY t.app_group_cd, 0
      DETAIL
       lgroupcnt = (lgroupcnt+ 1)
       IF (mod(lgroupcnt,10)=1)
        stat = alterlist(app_group->qual,(lgroupcnt+ 9))
       ENDIF
       app_group->qual[lgroupcnt].app_group_cd = t.app_group_cd
      FOOT REPORT
       stat = alterlist(app_group->qual,lgroupcnt)
      WITH nocounter
     ;end select
     IF (lgroupcnt > 0)
      SELECT INTO "nl:"
       t.app_group_cd
       FROM task_access t,
        (dummyt d  WITH seq = value(lgroupcnt))
       PLAN (d)
        JOIN (t
        WHERE t.task_number=corereg_task
         AND (t.app_group_cd=app_group->qual[d.seq].app_group_cd))
       DETAIL
        app_group->qual[d.seq].corereg_access_ind = 1
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       t.app_group_cd
       FROM task_access t,
        (dummyt d  WITH seq = value(lgroupcnt))
       PLAN (d
        WHERE (app_group->qual[d.seq].corereg_access_ind=1))
        JOIN (t
        WHERE t.task_number=flexreg_task
         AND (t.app_group_cd=app_group->qual[d.seq].app_group_cd))
       DETAIL
        app_group->qual[d.seq].grant_access_ind = 1, lgrantaccesscnt = (lgrantaccesscnt+ 1)
       WITH nocounter, outerjoin(d), dontexist
      ;end select
      IF (lgrantaccesscnt > 0)
       INSERT  FROM task_access t,
         (dummyt d  WITH seq = value(lgroupcnt))
        SET t.task_number = flexreg_task, t.app_group_cd = app_group->qual[d.seq].app_group_cd, t
         .updt_id = 0.0,
         t.updt_task = 0, t.updt_applctx = 0, t.updt_cnt = 0,
         t.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        PLAN (d
         WHERE (app_group->qual[d.seq].grant_access_ind=1))
         JOIN (t)
        WITH nocounter
       ;end insert
       INSERT  FROM task_access t,
         (dummyt d  WITH seq = value(lgroupcnt))
        SET t.task_number = bb_reg_conv_task, t.app_group_cd = app_group->qual[d.seq].app_group_cd, t
         .updt_id = 0.0,
         t.updt_task = 0, t.updt_applctx = 0, t.updt_cnt = 0,
         t.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        PLAN (d
         WHERE (app_group->qual[d.seq].grant_access_ind=1))
         JOIN (t)
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message = "Unable to insert row into pm_flx_task_conv_reltn"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
