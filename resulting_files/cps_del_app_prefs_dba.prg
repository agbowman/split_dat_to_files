CREATE PROGRAM cps_del_app_prefs:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE max_del = i4 WITH public, constant(500)
 DECLARE more_ind = i2 WITH public, noconstant(0)
 IF ((request->app_number > 0)
  AND (request->position_ind=1))
  CALL echo("***")
  CALL echo("***   Handle Position Level Deletes")
  CALL echo("***")
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = ap.app_prefs_id
      FROM app_prefs ap
      WHERE ap.prsnl_id=0
       AND ap.position_cd > 0
       AND (ap.application_number=request->app_number)))
      AND nvp.parent_entity_name="APP_PREFS"
     WITH nocounter, maxqual(nvp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM app_prefs ap
     WHERE ap.prsnl_id=0
      AND ap.position_cd > 0
      AND (ap.application_number=request->app_number)
     WITH nocounter, maxqual(ap,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
 ENDIF
 IF ((request->prsnl_ind=1))
  CALL echo("***")
  CALL echo("***   Handle PRSNL Level Deletes")
  CALL echo("***")
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = ap.app_prefs_id
      FROM app_prefs ap
      WHERE ap.prsnl_id > 0
       AND ap.position_cd=0
       AND (ap.application_number=request->app_number)))
      AND nvp.parent_entity_name="APP_PREFS"
     WITH nocounter, maxqual(nvp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM app_prefs ap
     WHERE ap.prsnl_id > 0
      AND ap.position_cd=0
      AND (ap.application_number=request->app_number)
     WITH nocounter, maxqual(ap,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
 ENDIF
 IF ((request->app_ind=1))
  CALL echo("***")
  CALL echo("***   Handle App Level Deletes")
  CALL echo("***")
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = ap.app_prefs_id
      FROM app_prefs ap
      WHERE ap.prsnl_id=0
       AND ap.position_cd=0
       AND (ap.application_number=request->app_number)))
      AND nvp.parent_entity_name="APP_PREFS"
     WITH nocounter, maxqual(nvp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM app_prefs ap
     WHERE ap.prsnl_id=0
      AND ap.position_cd=0
      AND (ap.application_number=request->app_number)
     WITH nocounter, maxqual(ap,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
 ENDIF
 IF ((request->map_qual < 1))
  GO TO exit_script
 ENDIF
 FREE SET hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 pref_id = f8
 )
 IF ((request->pref_qual < 1))
  CALL echo("***")
  CALL echo("***   Delete Specific Preference Values")
  CALL echo("***")
  SELECT INTO "nl:"
   FROM app_prefs ap,
    (dummyt d  WITH seq = value(request->map_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (ap
    WHERE (ap.prsnl_id=request->map[d.seq].prsnl_id)
     AND (ap.position_cd=request->map[d.seq].position_cd)
     AND (ap.application_number=request->map[d.seq].app_number))
   HEAD REPORT
    knt = 0, stat = alterlist(hold->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(hold->qual,(knt+ 9))
    ENDIF
    hold->qual[knt].pref_id = ap.app_prefs_id
   FOOT REPORT
    hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSEIF ((hold->qual_knt < 1))
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET nvp.seq = 1
     PLAN (d
      WHERE d.seq > 0)
      JOIN (nvp
      WHERE (nvp.parent_entity_id=hold->qual[d.seq].pref_id)
       AND nvp.parent_entity_name="APP_PREFS")
     WITH nocounter, maxrec = value(max_del)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM app_prefs ap,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET ap.seq = 1
     PLAN (d
      WHERE d.seq > 0)
      JOIN (ap
      WHERE (ap.app_prefs_id=hold->qual[d.seq].pref_id))
     WITH nocounter, maxrec = value(max_del)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
 ELSE
  CALL echo("***")
  CALL echo("***   Delete Specific PVC_NAME Values")
  CALL echo("***")
  SELECT INTO "nl:"
   FROM app_prefs ap,
    name_value_prefs nvp,
    (dummyt d  WITH seq = value(request->map_qual)),
    (dummyt d2  WITH seq = value(request->pref_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (ap
    WHERE (ap.prsnl_id=request->map[d.seq].prsnl_id)
     AND (ap.position_cd=request->map[d.seq].position_cd)
     AND (ap.application_number=request->map[d.seq].app_number))
    JOIN (nvp
    WHERE nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name=request->pref[d2.seq].pref_name))
   HEAD REPORT
    knt = 0, stat = alterlist(hold->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(hold->qual,(knt+ 9))
    ENDIF
    hold->qual[knt].pref_id = nvp.name_value_prefs_id
   FOOT REPORT
    hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSEIF ((hold->qual_knt < 1))
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
  SET more_ind = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET nvp.seq = 1
     PLAN (d
      WHERE d.seq > 0)
      JOIN (nvp
      WHERE (nvp.name_value_prefs_id=hold->qual[d.seq].pref_id))
     WITH nocounter, maxrec = value(max_del)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     ROLLBACK
     GO TO exit_script
    ENDIF
    IF (curqual=max_del)
     SET more_ind = curqual
    ELSE
     SET more_ind = 0
    ENDIF
    COMMIT
  ENDWHILE
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed=false)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(reply)
 SET cps_script_version = "001 12/08/03 SF3151"
END GO
