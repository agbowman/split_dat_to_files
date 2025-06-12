CREATE PROGRAM dm_ocd_install_atr:dba
 FREE RECORD atr
 RECORD atr(
   1 atr_count = i4
   1 atr_list[*]
     2 application_number = i4
     2 owner = c20
     2 description = vc
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 last_localized_dt_tm = dq8
     2 active_ind = i2
     2 log_level = i2
     2 request_log_level = i2
     2 min_version_required = vc
     2 log_access_ind = i2
     2 direct_access_ind = i2
     2 application_ini_ind = i2
     2 object_name = vc
     2 disable_cache_ind = i2
     2 module = vc
     2 text = vc
     2 common_application_ind = i2
     2 feature_number = i4
     2 schema_date = dq8
     2 deleted_ind = i2
 )
 SET atr->atr_count = 0
 SET stat = alterlist(atr->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_ocd_application d
  WHERE d.alpha_feature_nbr=ocd_number
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), atr->atr_count = cnt, stat = alterlist(atr->atr_list,cnt),
   atr->atr_list[cnt].application_number = d.application_number, atr->atr_list[cnt].owner = d.owner,
   atr->atr_list[cnt].description = d.description,
   atr->atr_list[cnt].active_dt_tm = d.active_dt_tm, atr->atr_list[cnt].inactive_dt_tm = d
   .inactive_dt_tm, atr->atr_list[cnt].last_localized_dt_tm = d.last_localized_dt_tm,
   atr->atr_list[cnt].active_ind = d.active_ind, atr->atr_list[cnt].log_level = d.log_level, atr->
   atr_list[cnt].request_log_level = d.request_log_level,
   atr->atr_list[cnt].min_version_required = d.min_version_required, atr->atr_list[cnt].
   log_access_ind = d.log_access_ind, atr->atr_list[cnt].direct_access_ind = d.direct_access_ind,
   atr->atr_list[cnt].application_ini_ind = d.application_ini_ind, atr->atr_list[cnt].object_name = d
   .object_name, atr->atr_list[cnt].disable_cache_ind = d.disable_cache_ind,
   atr->atr_list[cnt].text = d.text, atr->atr_list[cnt].common_application_ind = d
   .common_application_ind, atr->atr_list[cnt].feature_number = d.feature_number,
   atr->atr_list[cnt].schema_date = d.schema_date, atr->atr_list[cnt].deleted_ind = d.deleted_ind
  WITH nocounter
 ;end select
 IF ((atr->atr_count > 0))
  EXECUTE dm_ocd_import_app
 ENDIF
 EXECUTE dm_ocd_import_app_access
 FREE RECORD atr
 RECORD atr(
   1 atr_count = i4
   1 atr_list[*]
     2 task_number = i4
     2 description = vc
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 optional_required_flag = i2
     2 subordinate_task_ind = i2
     2 text = vc
     2 old_task_number = i4
     2 feature_number = i4
     2 schema_date = dq8
     2 deleted_ind = i2
 )
 SET atr->atr_count = 0
 SET stat = alterlist(atr->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_ocd_task d
  WHERE d.alpha_feature_nbr=ocd_number
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), atr->atr_count = cnt, stat = alterlist(atr->atr_list,cnt),
   atr->atr_list[cnt].task_number = d.task_number, atr->atr_list[cnt].description = d.description,
   atr->atr_list[cnt].active_ind = d.active_ind,
   atr->atr_list[cnt].active_dt_tm = d.active_dt_tm, atr->atr_list[cnt].inactive_dt_tm = d
   .inactive_dt_tm, atr->atr_list[cnt].optional_required_flag = d.optional_required_flag,
   atr->atr_list[cnt].subordinate_task_ind = d.subordinate_task_ind, atr->atr_list[cnt].text = d.text,
   atr->atr_list[cnt].old_task_number = d.old_task_number,
   atr->atr_list[cnt].feature_number = d.feature_number, atr->atr_list[cnt].schema_date = d
   .schema_date, atr->atr_list[cnt].deleted_ind = d.deleted_ind
  WITH nocounter
 ;end select
 IF ((atr->atr_count > 0))
  EXECUTE dm_ocd_import_task
 ENDIF
 EXECUTE dm_ocd_import_task_access
 FREE RECORD atr
 RECORD atr(
   1 atr_count = i4
   1 atr_list[*]
     2 request_number = i4
     2 description = vc
     2 request_name = c20
     2 cachetime = i4
     2 epilog_script = c30
     2 prolog_script = c30
     2 write_to_que_ind = i2
     2 text = vc
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 feature_number = i4
     2 schema_date = dq8
     2 deleted_ind = i2
     2 cachegrace = i4
     2 cachestale = i4
     2 cachetrim = c20
 )
 SET atr->atr_count = 0
 SET stat = alterlist(atr->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_ocd_request d
  WHERE d.alpha_feature_nbr=ocd_number
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), atr->atr_count = cnt, stat = alterlist(atr->atr_list,cnt),
   atr->atr_list[cnt].request_number = d.request_number, atr->atr_list[cnt].description = d
   .description, atr->atr_list[cnt].request_name = d.request_name,
   atr->atr_list[cnt].cachetime = d.cachetime, atr->atr_list[cnt].cachegrace = d.cachegrace, atr->
   atr_list[cnt].cachestale = d.cachestale,
   atr->atr_list[cnt].cachetrim = d.cachetrim, atr->atr_list[cnt].epilog_script = d.epilog_script,
   atr->atr_list[cnt].prolog_script = d.prolog_script,
   atr->atr_list[cnt].write_to_que_ind = d.write_to_que_ind, atr->atr_list[cnt].text = d.text, atr->
   atr_list[cnt].active_ind = d.active_ind,
   atr->atr_list[cnt].active_dt_tm = d.active_dt_tm, atr->atr_list[cnt].inactive_dt_tm = d
   .inactive_dt_tm, atr->atr_list[cnt].feature_number = d.feature_number,
   atr->atr_list[cnt].schema_date = d.schema_date, atr->atr_list[cnt].deleted_ind = d.deleted_ind
  WITH nocounter
 ;end select
 IF ((atr->atr_count > 0))
  EXECUTE dm_ocd_import_req
 ENDIF
 FREE RECORD atr
 RECORD atr(
   1 atr_count = i4
   1 atr_list[*]
     2 application_number = i4
     2 task_number = i4
     2 deleted_ind = i2
   1 feature_number = i4
   1 schema_date = dq8
 )
 SET atr->atr_count = 0
 SET stat = alterlist(atr->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_ocd_app_task_r d
  WHERE d.alpha_feature_nbr=ocd_number
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), atr->atr_count = cnt, stat = alterlist(atr->atr_list,cnt),
   atr->atr_list[cnt].application_number = d.application_number, atr->atr_list[cnt].task_number = d
   .task_number, atr->atr_list[cnt].deleted_ind = d.deleted_ind
  WITH nocounter
 ;end select
 IF ((atr->atr_count > 0))
  EXECUTE dm_ocd_import_app_task
 ENDIF
 FREE RECORD atr
 RECORD atr(
   1 atr_count = i4
   1 atr_list[*]
     2 task_number = i4
     2 request_number = i4
     2 deleted_ind = i2
   1 feature_number = i4
   1 schema_date = dq8
 )
 SET atr->atr_count = 0
 SET stat = alterlist(atr->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_ocd_task_req_r d
  WHERE d.alpha_feature_nbr=ocd_number
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), atr->atr_count = cnt, stat = alterlist(atr->atr_list,cnt),
   atr->atr_list[cnt].task_number = d.task_number, atr->atr_list[cnt].request_number = d
   .request_number, atr->atr_list[cnt].deleted_ind = d.deleted_ind
  WITH nocounter
 ;end select
 IF ((atr->atr_count > 0))
  EXECUTE dm_ocd_import_task_req
 ENDIF
 SET app_count = 0
 SET task_count = 0
 SET req_count = 0
 SET at_count = 0
 SET tr_count = 0
 SET success_ind = 1
 SELECT INTO "nl:"
  FROM dm_ocd_application d
  WHERE d.alpha_feature_nbr=ocd_number
   AND d.deleted_ind=0
  WITH nocounter
 ;end select
 SET app_count = curqual
 IF (app_count > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_application d,
    application a
   WHERE d.alpha_feature_nbr=ocd_number
    AND d.application_number=a.application_number
    AND d.deleted_ind=0
   WITH nocounter
  ;end select
  IF (curqual < app_count)
   SET success_ind = 0
   GO TO check_success
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_task d
  WHERE d.alpha_feature_nbr=ocd_number
   AND d.deleted_ind=0
  WITH nocounter
 ;end select
 SET task_count = curqual
 IF (task_count > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_task d,
    application_task a
   WHERE d.alpha_feature_nbr=ocd_number
    AND d.task_number=a.task_number
    AND d.deleted_ind=0
   WITH nocounter
  ;end select
  IF (curqual < task_count)
   SET success_ind = 0
   GO TO check_success
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_request d
  WHERE d.alpha_feature_nbr=ocd_number
   AND d.deleted_ind=0
  WITH nocounter
 ;end select
 SET req_count = curqual
 IF (req_count > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_request d,
    request a
   WHERE d.alpha_feature_nbr=ocd_number
    AND d.request_number=a.request_number
    AND d.deleted_ind=0
   WITH nocounter
  ;end select
  IF (curqual < req_count)
   SET success_ind = 0
   GO TO check_success
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_app_task_r d
  WHERE d.alpha_feature_nbr=ocd_number
   AND d.deleted_ind=0
  WITH nocounter
 ;end select
 SET at_count = curqual
 IF (at_count > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_app_task_r d,
    application_task_r a
   WHERE d.alpha_feature_nbr=ocd_number
    AND d.application_number=a.application_number
    AND d.task_number=a.task_number
    AND d.deleted_ind=0
   WITH nocounter
  ;end select
  IF (curqual < at_count)
   SET success_ind = 0
   GO TO check_success
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_task_req_r d
  WHERE d.alpha_feature_nbr=ocd_number
   AND d.deleted_ind=0
  WITH nocounter
 ;end select
 SET tr_count = curqual
 IF (tr_count > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_task_req_r d,
    task_request_r a
   WHERE d.alpha_feature_nbr=ocd_number
    AND d.task_number=a.task_number
    AND d.request_number=a.request_number
    AND d.deleted_ind=0
   WITH nocounter
  ;end select
  IF (curqual < tr_count)
   SET success_ind = 0
   GO TO check_success
  ENDIF
 ENDIF
#check_success
 IF (success_ind=0)
  SET docd_reply->status = "F"
 ELSE
  SET docd_reply->status = "S"
 ENDIF
#end_script
END GO
