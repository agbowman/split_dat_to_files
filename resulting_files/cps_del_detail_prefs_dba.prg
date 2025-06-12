CREATE PROGRAM cps_del_detail_prefs:dba
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
 SET reply->status_data.status = "F"
 FREE SET hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 prefs_id = f8
 )
 DECLARE max_del = i4 WITH public, constant(50)
 DECLARE more_ind = i2 WITH public, noconstant(0)
 IF ((request->app_number > 0)
  AND (request->position_ind=1))
  CALL echo("***")
  CALL echo("***   Delete All Position Level Prefs")
  CALL echo("***")
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = dp.detail_prefs_id
      FROM detail_prefs dp
      WHERE dp.prsnl_id=0
       AND dp.position_cd > 0
       AND (dp.application_number=request->app_number)))
      AND nvp.parent_entity_name="DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM detail_prefs dp
     WHERE dp.prsnl_id=0
      AND dp.position_cd > 0
      AND (dp.application_number=request->app_number)
     WITH nocounter, maxqual(dp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
 ENDIF
 IF ((request->app_number > 0)
  AND (request->prsnl_ind=1))
  CALL echo("***")
  CALL echo("***   Delete All PRSNL Level Prefs")
  CALL echo("***")
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = dp.detail_prefs_id
      FROM detail_prefs dp
      WHERE dp.prsnl_id > 0
       AND dp.position_cd=0
       AND (dp.application_number=request->app_number)))
      AND nvp.parent_entity_name="DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM detail_prefs dp
     WHERE dp.prsnl_id > 0
      AND dp.position_cd=0
      AND (dp.application_number=request->app_number)
     WITH nocounter, maxqual(dp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
 ENDIF
 IF ((request->app_number > 0)
  AND (request->app_ind=1))
  CALL echo("***")
  CALL echo("***   Delete All App Level Prefs")
  CALL echo("***")
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM name_value_prefs nvp
     WHERE nvp.parent_entity_id IN (
     (SELECT
      parent_entity_id = dp.detail_prefs_id
      FROM detail_prefs dp
      WHERE dp.prsnl_id=0
       AND dp.position_cd=0
       AND (dp.application_number=request->app_number)))
      AND nvp.parent_entity_name="DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
  SET more_ind = 1
  SET while_knt = 1
  WHILE (more_ind > 0)
    DELETE  FROM detail_prefs dp
     WHERE dp.prsnl_id=0
      AND dp.position_cd=0
      AND (dp.application_number=request->app_number)
     WITH nocounter, maxqual(dp,value(max_del))
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
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
    SET while_knt = (while_knt+ 1)
  ENDWHILE
 ENDIF
 IF ((request->map_qual < 1))
  GO TO exit_script
 ENDIF
 IF ((request->group_qual < 1))
  CALL echo("***")
  CALL echo("***   Delete Specified Preferences")
  CALL echo("***")
  SELECT INTO "nl:"
   FROM detail_prefs dp,
    (dummyt d  WITH seq = value(request->map_qual))
   PLAN (d
    WHERE d.seq > 0)
    JOIN (dp
    WHERE (dp.prsnl_id=request->map[d.seq].prsnl_id)
     AND (dp.position_cd=request->map[d.seq].position_cd)
     AND (dp.application_number=request->map[d.seq].app_number))
   HEAD REPORT
    knt = 0, stat = alterlist(hold->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(hold->qual,(knt+ 9))
    ENDIF
    hold->qual[knt].prefs_id = dp.detail_prefs_id
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
   SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
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
      WHERE (nvp.parent_entity_id=hold->qual[d.seq].prefs_id)
       AND nvp.parent_entity_name="DETAIL_PREFS")
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
    DELETE  FROM detail_prefs dp,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET dp.seq = 1
     PLAN (d
      WHERE d.seq > 0)
      JOIN (dp
      WHERE (dp.detail_prefs_id=hold->qual[d.seq].prefs_id))
     WITH nocounter, maxrec = value(max_del)
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
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
  CALL echo("***   Delete Specified Preferences for VIEW_NAME")
  CALL echo("***")
  FOR (i = 1 TO request->group_qual)
    FREE SET hold
    RECORD hold(
      1 qual_knt = i4
      1 qual[*]
        2 prefs_id = f8
    )
    SELECT INTO "nl:"
     FROM detail_prefs dp,
      (dummyt d  WITH seq = value(request->map_qual))
     PLAN (d
      WHERE d.seq > 0)
      JOIN (dp
      WHERE (dp.prsnl_id=request->map[d.seq].prsnl_id)
       AND (dp.position_cd=request->map[d.seq].position_cd)
       AND (dp.application_number=request->map[d.seq].app_number)
       AND (dp.view_name=request->group[i].view_name)
       AND (dp.view_seq=request->group[i].view_seq)
       AND (dp.comp_name=request->group[i].comp_name)
       AND (dp.comp_seq=request->group[i].comp_seq))
     HEAD REPORT
      knt = 0, stat = alterlist(hold->qual,10)
     DETAIL
      knt = (knt+ 1)
      IF (mod(knt,10)=1
       AND knt != 1)
       stat = alterlist(hold->qual,(knt+ 9))
      ENDIF
      hold->qual[knt].prefs_id = dp.detail_prefs_id
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
     SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    CALL echorecord(hold)
    IF ((hold->qual_knt > 0))
     IF ((request->group[i].pref_qual < 1))
      DELETE  FROM name_value_prefs nvp,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET nvp.seq = 1
       PLAN (d
        WHERE d.seq > 0)
        JOIN (nvp
        WHERE (nvp.parent_entity_id=hold->qual[d.seq].prefs_id)
         AND nvp.parent_entity_name="DETAIL_PREFS")
       WITH nocounter
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
      COMMIT
      DELETE  FROM detail_prefs dp,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET dp.seq = 1
       PLAN (d
        WHERE d.seq > 0)
        JOIN (dp
        WHERE (dp.detail_prefs_id=hold->qual[d.seq].prefs_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = delete_error
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "DELETE"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "DETAIL_PREFS"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       ROLLBACK
       GO TO exit_script
      ENDIF
      COMMIT
     ELSE
      DELETE  FROM name_value_prefs nvp,
        (dummyt d1  WITH seq = value(hold->qual_knt)),
        (dummyt d2  WITH seq = value(request->group[i].pref_qual))
       SET nvp.seq = 1
       PLAN (d1
        WHERE d1.seq > 0)
        JOIN (d2
        WHERE d2.seq > 0)
        JOIN (nvp
        WHERE (nvp.parent_entity_id=hold->qual[d1.seq].prefs_id)
         AND nvp.parent_entity_name="DETAIL_PREFS"
         AND (nvp.pvc_name=request->group[i].pref[d2.seq].pref_name))
       WITH nocounter
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
      COMMIT
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(reply)
 SET cps_script_version = "002 12/08/03 SF3151"
END GO
