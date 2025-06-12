CREATE PROGRAM dm_backfill_app_access_80:dba
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
 RECORD app(
   1 qual[*]
     2 application_number = f8
 )
 DECLARE app_group_cd = f8 WITH protect, noconstant(0.0)
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
  IF (curqual=0)
   SET readme_data->status = "F"
   SET readme_data->message = "Unable to insert into application_access table"
   ROLLBACK
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Successfully inserted applications into application_access table"
   COMMIT
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "No applications to insert into application_access table"
 ENDIF
 EXECUTE dm_readme_status
END GO
