CREATE PROGRAM cpm_app_access_init_fill:dba
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
 DECLARE row_exist_indicator = c1
 DECLARE app_group_cd = f8 WITH protect, noconstant(0.0)
 SET row_exist_indicator = "N"
 SELECT INTO "nl"
  c.code_value
  FROM code_value c
  WHERE c.code_set=500
   AND c.cki="CKI.CODEVALUE!2987"
  DETAIL
   app_group_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM application_access aa
  WHERE aa.app_group_cd != app_group_cd
   AND aa.application_access_id != 0
  DETAIL
   row_exist_indicator = "Y"
  WITH maxqual(aa,1)
 ;end select
 IF (row_exist_indicator="Y")
  GO TO db_inserts
 ENDIF
 FREE RECORD app_access_rec
 RECORD app_access_rec(
   1 app_access_list[*]
     2 application_number = i4
     2 app_group_cd = f8
     2 row_exists = c1
 )
 DECLARE error_code = f8
 DECLARE error_msg = c132
 DECLARE init_ind = f8
 SET app_access_cnt = 0
 SELECT DISTINCT INTO "nl:"
  FROM application app,
   application_task_r atr,
   task_access ta
  WHERE atr.task_number=ta.task_number
   AND app.application_number=atr.application_number
  ORDER BY atr.application_number, ta.app_group_cd
  DETAIL
   app_access_cnt = (app_access_cnt+ 1), stat = alterlist(app_access_rec->app_access_list,
    app_access_cnt), app_access_rec->app_access_list[app_access_cnt].application_number = atr
   .application_number,
   app_access_rec->app_access_list[app_access_cnt].app_group_cd = ta.app_group_cd
  WITH nocounter
 ;end select
 SET sys_prsnl_id = 0
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username="SYSTEM"
  DETAIL
   sys_prsnl_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM application_access aa1,
   (dummyt d  WITH seq = value(app_access_cnt))
  PLAN (d)
   JOIN (aa1
   WHERE (aa1.application_number=app_access_rec->app_access_list[d.seq].application_number)
    AND (aa1.app_group_cd=app_access_rec->app_access_list[d.seq].app_group_cd)
    AND aa1.active_prsnl_id=sys_prsnl_id)
  DETAIL
   app_access_rec->app_access_list[d.seq].row_exists = "Y"
  WITH nocounter
 ;end select
 INSERT  FROM application_access aa,
   (dummyt d  WITH seq = value(app_access_cnt))
  SET aa.application_access_id = cnvtint(seq(application_access_id_seq,nextval)), aa
   .application_number = app_access_rec->app_access_list[d.seq].application_number, aa.app_group_cd
    = app_access_rec->app_access_list[d.seq].app_group_cd,
   aa.active_ind = 1, aa.active_prsnl_id = sys_prsnl_id, aa.active_dt_tm = cnvtdatetime(curdate,
    curtime3),
   aa.updt_dt_tm = cnvtdatetime(curdate,curtime3), aa.updt_id = sys_prsnl_id, aa.updt_task = 0,
   aa.updt_cnt = 0, aa.updt_applctx = 0
  PLAN (d
   WHERE (app_access_rec->app_access_list[d.seq].row_exists != "Y"))
   JOIN (aa)
  WITH nocounter
 ;end insert
#db_inserts
 RECORD app(
   1 qual[*]
     2 application_number = f8
 )
 SELECT INTO "nl:"
  a.application_number
  FROM application a
  WHERE  NOT ( EXISTS (
  (SELECT
   aa.application_number
   FROM application_access aa
   WHERE aa.application_number=a.application_number)))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(app->qual,(cnt+ 9))
   ENDIF
   app->qual[cnt].application_number = a.application_number
  FOOT REPORT
   stat = alterlist(app->qual,cnt)
  WITH nocounter
 ;end select
 IF (size(app->qual,5) > 0)
  INSERT  FROM application_access a,
    (dummyt d  WITH seq = value(size(app->qual,5)))
   SET a.application_access_id = seq(application_access_id_seq,nextval), a.application_number = app->
    qual[d.seq].application_number, a.app_group_cd = app_group_cd,
    a.active_ind = 1, a.active_prsnl_id = 0, a.active_dt_tm = cnvtdatetime(curdate,curtime3),
    a.inactive_prsnl_id = 0, a.inactive_dt_tm = null, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_task = 0, a.updt_cnt = 0,
    a.updt_applctx = 0
   PLAN (d)
    JOIN (a)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
 SET error_code = 0
 SET error_msg = fillstring(132," ")
 SET error_code = error(error_msg,0)
 IF (error_code > 0)
  SET readme_data->status = "F"
  SET readme_data->message = error_msg
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Application access initial fill completed successfully"
 ENDIF
 FREE RECORD app_access_reg
 CALL echo("end of script")
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
