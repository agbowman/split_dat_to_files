CREATE PROGRAM cps_get_all_detail_prefs:dba
 FREE SET reply
 RECORD reply(
   1 level_qual = i4
   1 level[*]
     2 level_flag = i2
     2 group_qual = i4
     2 group[*]
       3 detail_prefs_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 name_value_prefs_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 merge_id = f8
         4 merge_name = vc
         4 sequence = i4
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
 SET level_knt = 0
 SET reply->level_qual = level_knt
 SET dvar = 0
 IF ((request->app_ind=1))
  SET level_knt += 1
  SET stat = alterlist(reply->level,level_knt)
  SET reply->level[level_knt].level_flag = 0
  CALL get_app_prefs(dvar)
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
 ENDIF
 IF ((request->position_cd > 0))
  SET level_knt += 1
  SET stat = alterlist(reply->level,level_knt)
  SET reply->level[level_knt].level_flag = 1
  CALL get_pos_prefs(dvar)
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
 ENDIF
 IF ((request->prsnl_id > 0))
  SET level_knt += 1
  SET stat = alterlist(reply->level,level_knt)
  SET reply->level[level_knt].level_flag = 2
  CALL get_prsnl_prefs(dvar)
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
 ENDIF
 SET reply->level_qual = level_knt
 GO TO exit_script
 SUBROUTINE get_app_prefs(lvar)
   SELECT INTO "nl:"
    dp.view_name, nvp.pvc_name
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE dp.prsnl_id=0
      AND dp.position_cd=0
      AND (dp.application_number=request->app_number)
      AND dp.active_ind > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.active_ind > 0)
    ORDER BY dp.view_name, nvp.pvc_name
    HEAD REPORT
     grp_knt = 0, stat = alterlist(reply->level[level_knt].group,10)
    HEAD dp.view_name
     grp_knt += 1
     IF (mod(grp_knt,10)=1
      AND grp_knt != 1)
      stat = alterlist(reply->level[level_knt].group,(grp_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].detail_prefs_id = dp.detail_prefs_id, reply->level[
     level_knt].group[grp_knt].view_name = dp.view_name, reply->level[level_knt].group[grp_knt].
     view_seq = dp.view_seq,
     reply->level[level_knt].group[grp_knt].comp_name = dp.comp_name, reply->level[level_knt].group[
     grp_knt].comp_seq = dp.comp_seq, pref_knt = 0,
     stat = alterlist(reply->level[level_knt].group[grp_knt].pref,10)
    DETAIL
     pref_knt += 1
     IF (mod(pref_knt,10)=1
      AND pref_knt != 1)
      stat = alterlist(reply->level[level_knt].group[grp_knt].pref,(pref_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].pref[pref_knt].name_value_prefs_id = nvp
     .name_value_prefs_id, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_name = nvp
     .pvc_name, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
     reply->level[level_knt].group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->level[
     level_knt].group[grp_knt].pref[pref_knt].merge_name = nvp.merge_name, reply->level[level_knt].
     group[grp_knt].pref[pref_knt].sequence = nvp.sequence
    FOOT  dp.view_name
     reply->level[level_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->level[
      level_knt].group[grp_knt].pref,pref_knt)
    FOOT REPORT
     reply->level[level_knt].group_qual = grp_knt, stat = alterlist(reply->level[level_knt].group,
      grp_knt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_pos_prefs(lvar)
   SELECT INTO "nl:"
    dp.view_name, nvp.pvc_name
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE dp.prsnl_id=0
      AND (dp.position_cd=request->position_cd)
      AND (dp.application_number=request->app_number)
      AND dp.active_ind > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.active_ind > 0)
    ORDER BY dp.view_name, nvp.pvc_name
    HEAD REPORT
     grp_knt = 0, stat = alterlist(reply->level[level_knt].group,10)
    HEAD dp.view_name
     grp_knt += 1
     IF (mod(grp_knt,10)=1
      AND grp_knt != 1)
      stat = alterlist(reply->level[level_knt].group,(grp_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].detail_prefs_id = dp.detail_prefs_id, reply->level[
     level_knt].group[grp_knt].view_name = dp.view_name, reply->level[level_knt].group[grp_knt].
     view_seq = dp.view_seq,
     reply->level[level_knt].group[grp_knt].comp_name = dp.comp_name, reply->level[level_knt].group[
     grp_knt].comp_seq = dp.comp_seq, pref_knt = 0,
     stat = alterlist(reply->level[level_knt].group[grp_knt].pref,10)
    DETAIL
     pref_knt += 1
     IF (mod(pref_knt,10)=1
      AND pref_knt != 1)
      stat = alterlist(reply->level[level_knt].group[grp_knt].pref,(pref_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].pref[pref_knt].name_value_prefs_id = nvp
     .name_value_prefs_id, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_name = nvp
     .pvc_name, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
     reply->level[level_knt].group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->level[
     level_knt].group[grp_knt].pref[pref_knt].merge_name = nvp.merge_name, reply->level[level_knt].
     group[grp_knt].pref[pref_knt].sequence = nvp.sequence
    FOOT  dp.view_name
     reply->level[level_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->level[
      level_knt].group[grp_knt].pref,pref_knt)
    FOOT REPORT
     reply->level[level_knt].group_qual = grp_knt, stat = alterlist(reply->level[level_knt].group,
      grp_knt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_prsnl_prefs(lvar)
   SELECT INTO "nl:"
    dp.view_name, nvp.pvc_name
    FROM detail_prefs dp,
     name_value_prefs nvp
    PLAN (dp
     WHERE (dp.prsnl_id=request->prsnl_id)
      AND dp.position_cd=0
      AND (dp.application_number=request->app_number)
      AND dp.active_ind > 0)
     JOIN (nvp
     WHERE nvp.parent_entity_id=dp.detail_prefs_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.active_ind > 0)
    ORDER BY dp.view_name, nvp.pvc_name
    HEAD REPORT
     grp_knt = 0, stat = alterlist(reply->level[level_knt].group,10)
    HEAD dp.view_name
     grp_knt += 1
     IF (mod(grp_knt,10)=1
      AND grp_knt != 1)
      stat = alterlist(reply->level[level_knt].group,(grp_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].detail_prefs_id = dp.detail_prefs_id, reply->level[
     level_knt].group[grp_knt].view_name = dp.view_name, reply->level[level_knt].group[grp_knt].
     view_seq = dp.view_seq,
     reply->level[level_knt].group[grp_knt].comp_name = dp.comp_name, reply->level[level_knt].group[
     grp_knt].comp_seq = dp.comp_seq, pref_knt = 0,
     stat = alterlist(reply->level[level_knt].group[grp_knt].pref,10)
    DETAIL
     pref_knt += 1
     IF (mod(pref_knt,10)=1
      AND pref_knt != 1)
      stat = alterlist(reply->level[level_knt].group[grp_knt].pref,(pref_knt+ 9))
     ENDIF
     reply->level[level_knt].group[grp_knt].pref[pref_knt].name_value_prefs_id = nvp
     .name_value_prefs_id, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_name = nvp
     .pvc_name, reply->level[level_knt].group[grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
     reply->level[level_knt].group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->level[
     level_knt].group[grp_knt].pref[pref_knt].merge_name = nvp.merge_name, reply->level[level_knt].
     group[grp_knt].pref[pref_knt].sequence = nvp.sequence
    FOOT  dp.view_name
     reply->level[level_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->level[
      level_knt].group[grp_knt].pref,pref_knt)
    FOOT REPORT
     reply->level[level_knt].group_qual = grp_knt, stat = alterlist(reply->level[level_knt].group,
      grp_knt)
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ENDIF
END GO
