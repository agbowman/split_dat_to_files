CREATE PROGRAM dm_atr_app_import:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
     2 application_access_exist = i2
 )
 SET stat = alterlist(status->qual,request->atr_count)
 CALL echo("Importing Applications into clinical tables...")
 SELECT INTO "nl:"
  a.application_number
  FROM application a,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=request->atr_list[d.seq].application_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Applications into clinical tables...")
 UPDATE  FROM application a,
   (dummyt d  WITH seq = value(request->atr_count))
  SET a.seq = 1, a.owner = request->atr_list[d.seq].owner, a.description = request->atr_list[d.seq].
   description,
   a.active_ind = request->atr_list[d.seq].active_ind, a.log_access_ind = request->atr_list[d.seq].
   log_access_ind, a.direct_access_ind = request->atr_list[d.seq].direct_access_ind,
   a.application_ini_ind = request->atr_list[d.seq].application_ini_ind, a.log_level = 0, a
   .request_log_level = 0,
   a.min_version_required = request->atr_list[d.seq].min_version_required, a.object_name = request->
   atr_list[d.seq].object_name, a.active_dt_tm =
   IF ((request->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     active_dt_tm)
   ELSE null
   ENDIF
   ,
   a.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   , a.last_localized_dt_tm =
   IF ((request->atr_list[d.seq].last_localized_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     last_localized_dt_tm)
   ELSE null
   ENDIF
   , a.text = request->atr_list[d.seq].text,
   a.disable_cache_ind = request->atr_list[d.seq].disable_cache_ind, a.common_application_ind =
   request->atr_list[d.seq].common_application_ind, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   a.updt_task = 0, a.updt_id = 0.0, a.updt_cnt = 0,
   a.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (a
   WHERE (a.application_number=request->atr_list[d.seq].application_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Applications into clinical tables...")
 INSERT  FROM application a,
   (dummyt d  WITH seq = value(request->atr_count))
  SET a.seq = 1, a.application_number = request->atr_list[d.seq].application_number, a.owner =
   request->atr_list[d.seq].owner,
   a.description = request->atr_list[d.seq].description, a.active_ind = request->atr_list[d.seq].
   active_ind, a.log_access_ind = request->atr_list[d.seq].log_access_ind,
   a.direct_access_ind = request->atr_list[d.seq].direct_access_ind, a.application_ini_ind = request
   ->atr_list[d.seq].application_ini_ind, a.log_level = 0,
   a.request_log_level = 0, a.min_version_required = request->atr_list[d.seq].min_version_required, a
   .object_name = request->atr_list[d.seq].object_name,
   a.active_dt_tm =
   IF ((request->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     active_dt_tm)
   ELSE null
   ENDIF
   , a.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   , a.last_localized_dt_tm =
   IF ((request->atr_list[d.seq].last_localized_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     last_localized_dt_tm)
   ELSE null
   ENDIF
   ,
   a.text = request->atr_list[d.seq].text, a.disable_cache_ind = request->atr_list[d.seq].
   disable_cache_ind, a.common_application_ind = request->atr_list[d.seq].common_application_ind,
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_task = 0, a.updt_id = 0.0,
   a.updt_cnt = 0, a.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (a)
  WITH nocounter
 ;end insert
 CALL echo("  Deleting unwanted Applications from clinical tables...")
 DELETE  FROM application a,
   (dummyt d  WITH seq = value(request->atr_count))
  SET a.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (status->qual[d.seq].exist=1))
   JOIN (a
   WHERE (a.application_number=request->atr_list[d.seq].application_number))
  WITH nocounter
 ;end delete
 COMMIT
 CALL echo("Preparing to insert DBA position for the applications")
 SET acdef_appgrp_cd = 0.0
 SET acposition_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=500
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   acdef_appgrp_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=88
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   acposition_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.position_cd
  FROM application_group a
  WHERE a.position_cd=acposition_cd
   AND a.app_group_cd=acdef_appgrp_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM application_group a
   SET a.application_group_id = cnvtint(seq(cpm_seq,nextval)), a.position_cd = acposition_cd, a
    .app_group_cd = acdef_appgrp_cd,
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "01-JAN-2099"), a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_application = 0, a.updt_applctx = 0,
    a.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  ta.application_number
  FROM application_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (ta
   WHERE (ta.application_number=request->atr_list[d.seq].application_number)
    AND ta.app_group_cd=acdef_appgrp_cd)
  DETAIL
   status->qual[d.seq].application_access_exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Inserting new applications_Access rows...")
 INSERT  FROM application_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  SET ta.seq = 1, ta.application_number = request->atr_list[d.seq].application_number, ta
   .application_access_id = cnvtint(seq(application_access_id_seq,nextval)),
   ta.app_group_cd = acdef_appgrp_cd, ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta.active_dt_tm
    = cnvtdatetime(curdate,curtime3),
   ta.active_prsnl_id = 0, ta.updt_id = 0, ta.updt_task = 0,
   ta.updt_applctx = 0, ta.updt_cnt = 0, ta.active_ind = 1
  PLAN (d
   WHERE (status->qual[d.seq].application_access_exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (ta)
  WITH nocounter
 ;end insert
 CALL echo("  Deleting un-wanted application_Access rows...")
 DELETE  FROM application_access ta,
   (dummyt d  WITH seq = value(request->atr_count))
  SET ta.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (status->qual[d.seq].application_access_exist=1))
   JOIN (ta
   WHERE (ta.application_number=request->atr_list[d.seq].application_number))
  WITH nocounter
 ;end delete
 COMMIT
END GO
