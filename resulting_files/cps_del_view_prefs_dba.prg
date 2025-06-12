CREATE PROGRAM cps_del_view_prefs:dba
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
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD comp_list
 RECORD comp_list(
   1 qual_knt = i4
   1 qual[*]
     2 view_comp_prefs_id = f8
 )
 SET found_id = false
 FOR (i = 1 TO request->qual_knt)
   FOR (j = 1 TO request->qual[i].view_knt)
     CALL echo("***")
     CALL echo("***   Find VIEW_COMP_PREFS items")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM view_comp_prefs vcp
      PLAN (vcp
       WHERE (vcp.prsnl_id=request->qual[i].prsnl_id)
        AND (vcp.position_cd=request->qual[i].position_cd)
        AND (vcp.application_number=request->qual[i].application_number)
        AND (vcp.view_name=request->qual[i].views[j].view_name)
        AND (vcp.view_seq=request->qual[i].views[j].view_seq))
      HEAD REPORT
       knt = 0, stat = alterlist(comp_list->qual,10)
      DETAIL
       knt = (knt+ 1)
       IF (mod(knt,10)=1
        AND knt != 1)
        stat = alterlist(comp_list->qual,(knt+ 9))
       ENDIF
       comp_list->qual[knt].view_comp_prefs_id = vcp.view_comp_prefs_id
      FOOT REPORT
       comp_list->qual_knt = knt, stat = alterlist(comp_list->qual,knt)
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "VIEW_COMP_PREFS"
      GO TO exit_script
     ENDIF
     IF ((comp_list->qual_knt > 0))
      CALL echo("***")
      CALL echo("***   DELETE NAME_VALUE_PREFS VIEW_COMP_PREFS items")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM name_value_prefs nvp,
        (dummyt d  WITH seq = value(comp_list->qual_knt))
       SET nvp.seq = 1
       PLAN (d
        WHERE d.seq > 0)
        JOIN (nvp
        WHERE (nvp.parent_entity_id=comp_list->qual[d.seq].view_comp_prefs_id)
         AND nvp.parent_entity_name="VIEW_COMP_PREFS")
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = delete_error
       SET table_name = "NAME_VALUE_PREFS"
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   DELETE VIEW_COMP_PREFS items")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM view_comp_prefs vcp,
        (dummyt d  WITH seq = value(comp_list->qual_knt))
       SET vcp.seq = 1
       PLAN (d
        WHERE d.seq > 0)
        JOIN (vcp
        WHERE (vcp.view_comp_prefs_id=comp_list->qual[d.seq].view_comp_prefs_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = delete_error
       SET table_name = "VIEW_COMP_PREFS"
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echo("***")
     CALL echo("***   DELETE NAME_VALUE_PREFS VIEW_PREFS items")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM name_value_prefs
      WHERE parent_entity_id IN (
      (SELECT
       parent_entity_id = view_prefs_id
       FROM view_prefs
       WHERE (prsnl_id=request->qual[i].prsnl_id)
        AND (position_cd=request->qual[i].position_cd)
        AND (application_number=request->qual[i].application_number)
        AND (frame_type=request->qual[i].views[j].frame_type)
        AND (view_name=request->qual[i].views[j].view_name)
        AND (view_seq=request->qual[i].views[j].view_seq)))
       AND parent_entity_name="VIEW_PREFS"
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      SET table_name = "NAME_VALUE_PREFS"
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   DELETE VIEW_PREFS items")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     DELETE  FROM view_prefs
      WHERE (prsnl_id=request->qual[i].prsnl_id)
       AND (position_cd=request->qual[i].position_cd)
       AND (application_number=request->qual[i].application_number)
       AND (frame_type=request->qual[i].views[j].frame_type)
       AND (view_name=request->qual[i].views[j].view_name)
       AND (view_seq=request->qual[i].views[j].view_seq)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = delete_error
      SET table_name = "VIEW_PREFS"
      GO TO exit_script
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 SET script_version = "003 09/12/03 SF3151"
END GO
