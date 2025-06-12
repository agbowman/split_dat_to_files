CREATE PROGRAM cps_get_detail_prefs:dba
 FREE SET reply
 RECORD reply(
   1 app_qual = i4
   1 app[*]
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 position_qual = i4
   1 position[*]
     2 position_cd = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 prsnl_qual = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
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
 SET dvar = 0
 DECLARE idx = i4 WITH noconstant(0), public
 IF ((request->app_qual > 0))
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
 IF ((request->position_qual > 0))
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
 IF ((request->prsnl_qual > 0))
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
 GO TO exit_script
 SUBROUTINE get_app_prefs(lvar)
  SET app_knt = 0
  FOR (i = 1 TO request->app_qual)
    SET app_knt += 1
    SET reply->app_qual = app_knt
    SET stat = alterlist(reply->app,app_knt)
    SET reply->app[app_knt].app_number = request->app[i].app_number
    SELECT INTO "nl:"
     nvp.pvc_name
     FROM detail_prefs dp,
      name_value_prefs nvp
     PLAN (dp
      WHERE dp.prsnl_id=0
       AND dp.position_cd=0
       AND (dp.application_number=request->app[i].app_number)
       AND expand(idx,1,request->app[i].group_qual,dp.view_name,request->app[i].group[idx].view_name,
       dp.view_seq,request->app[i].group[idx].view_seq,dp.comp_name,request->app[i].group[idx].
       comp_name,dp.comp_seq,
       request->app[i].group[idx].comp_seq)
       AND dp.active_ind > 0)
      JOIN (nvp
      WHERE nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.active_ind > 0)
     ORDER BY dp.detail_prefs_id, nvp.pvc_name
     HEAD REPORT
      grp_knt = 0, stat = alterlist(reply->app[app_knt].group,10)
     HEAD dp.detail_prefs_id
      grp_knt += 1
      IF (mod(grp_knt,10)=1
       AND grp_knt != 1)
       stat = alterlist(reply->app[app_knt].group,(grp_knt+ 9))
      ENDIF
      reply->app[app_knt].group[grp_knt].group_id = dp.detail_prefs_id, reply->app[app_knt].group[
      grp_knt].view_name = dp.view_name, reply->app[app_knt].group[grp_knt].view_seq = dp.view_seq,
      reply->app[app_knt].group[grp_knt].comp_name = dp.comp_name, reply->app[app_knt].group[grp_knt]
      .comp_seq = dp.comp_seq, pref_knt = 0,
      stat = alterlist(reply->app[app_knt].group[grp_knt].pref,10)
     DETAIL
      pref_knt += 1
      IF (mod(pref_knt,10)=1
       AND pref_knt != 1)
       stat = alterlist(reply->app[app_knt].group[grp_knt].pref,(pref_knt+ 9))
      ENDIF
      reply->app[app_knt].group[grp_knt].pref[pref_knt].pref_id = nvp.name_value_prefs_id, reply->
      app[app_knt].group[grp_knt].pref[pref_knt].pref_name = nvp.pvc_name, reply->app[app_knt].group[
      grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
      reply->app[app_knt].group[grp_knt].pref[pref_knt].sequence = nvp.sequence, reply->app[app_knt].
      group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->app[app_knt].group[grp_knt].pref[
      pref_knt].merge_name = nvp.merge_name,
      reply->app[app_knt].group[grp_knt].pref[pref_knt].active_ind = nvp.active_ind
     FOOT  dp.detail_prefs_id
      reply->app[app_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->app[app_knt].
       group[grp_knt].pref,pref_knt)
     FOOT REPORT
      reply->app[app_knt].group_qual = grp_knt, stat = alterlist(reply->app[app_knt].group,grp_knt)
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_pos_prefs(lvar)
  SET pos_knt = 0
  FOR (i = 1 TO request->position_qual)
    SET pos_knt += 1
    SET reply->position_qual = pos_knt
    SET stat = alterlist(reply->position,pos_knt)
    SET reply->position[pos_knt].app_number = request->position[i].app_number
    SET reply->position[pos_knt].position_cd = request->position[i].position_cd
    SELECT INTO "nl:"
     nvp.pvc_name
     FROM detail_prefs dp,
      name_value_prefs nvp
     PLAN (dp
      WHERE dp.prsnl_id=0
       AND (dp.position_cd=request->position[pos_knt].position_cd)
       AND (dp.application_number=request->position[pos_knt].app_number)
       AND expand(idx,1,request->position[pos_knt].group_qual,dp.view_name,request->position[pos_knt]
       .group[idx].view_name,
       dp.view_seq,request->position[pos_knt].group[idx].view_seq,dp.comp_name,request->position[
       pos_knt].group[idx].comp_name,dp.comp_seq,
       request->position[pos_knt].group[idx].comp_seq)
       AND dp.active_ind > 0)
      JOIN (nvp
      WHERE nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.active_ind > 0)
     ORDER BY dp.detail_prefs_id, nvp.pvc_name
     HEAD REPORT
      grp_knt = 0, stat = alterlist(reply->position[pos_knt].group,10)
     HEAD dp.detail_prefs_id
      grp_knt += 1
      IF (mod(grp_knt,10)=1
       AND grp_knt != 1)
       stat = alterlist(reply->position[pos_knt].group,(grp_knt+ 9))
      ENDIF
      reply->position[pos_knt].group[grp_knt].group_id = dp.detail_prefs_id, reply->position[pos_knt]
      .group[grp_knt].view_name = dp.view_name, reply->position[pos_knt].group[grp_knt].view_seq = dp
      .view_seq,
      reply->position[pos_knt].group[grp_knt].comp_name = dp.comp_name, reply->position[pos_knt].
      group[grp_knt].comp_seq = dp.comp_seq, pref_knt = 0,
      stat = alterlist(reply->position[pos_knt].group[grp_knt].pref,10)
     DETAIL
      pref_knt += 1
      IF (mod(pref_knt,10)=1
       AND pref_knt != 1)
       stat = alterlist(reply->position[pos_knt].group[grp_knt].pref,(pref_knt+ 9))
      ENDIF
      reply->position[pos_knt].group[grp_knt].pref[pref_knt].pref_id = nvp.name_value_prefs_id, reply
      ->position[pos_knt].group[grp_knt].pref[pref_knt].pref_name = nvp.pvc_name, reply->position[
      pos_knt].group[grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
      reply->position[pos_knt].group[grp_knt].pref[pref_knt].sequence = nvp.sequence, reply->
      position[pos_knt].group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->position[
      pos_knt].group[grp_knt].pref[pref_knt].merge_name = nvp.merge_name,
      reply->position[pos_knt].group[grp_knt].pref[pref_knt].active_ind = nvp.active_ind
     FOOT  dp.detail_prefs_id
      reply->position[pos_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->position[
       pos_knt].group[grp_knt].pref,pref_knt)
     FOOT REPORT
      reply->position[pos_knt].group_qual = grp_knt, stat = alterlist(reply->position[pos_knt].group,
       grp_knt)
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_prsnl_prefs(lvar)
  SET prsnl_knt = 0
  FOR (i = 1 TO request->prsnl_qual)
    SET prsnl_knt += 1
    SET reply->prsnl_qual = prsnl_knt
    SET stat = alterlist(reply->prsnl,prsnl_knt)
    SET reply->prsnl[prsnl_knt].app_number = request->prsnl[i].app_number
    SET reply->prsnl[prsnl_knt].prsnl_id = request->prsnl[i].prsnl_id
    SELECT INTO "nl:"
     nvp.pvc_name
     FROM detail_prefs dp,
      name_value_prefs nvp
     PLAN (dp
      WHERE (dp.prsnl_id=request->prsnl[prsnl_knt].prsnl_id)
       AND dp.position_cd=0
       AND (dp.application_number=request->prsnl[prsnl_knt].app_number)
       AND expand(idx,1,request->prsnl[prsnl_knt].group_qual,dp.view_name,request->prsnl[prsnl_knt].
       group[idx].view_name,
       dp.view_seq,request->prsnl[prsnl_knt].group[idx].view_seq,dp.comp_name,request->prsnl[
       prsnl_knt].group[idx].comp_name,dp.comp_seq,
       request->prsnl[prsnl_knt].group[idx].comp_seq)
       AND dp.active_ind > 0)
      JOIN (nvp
      WHERE nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.active_ind > 0)
     ORDER BY dp.detail_prefs_id, nvp.pvc_name
     HEAD REPORT
      grp_knt = 0, stat = alterlist(reply->prsnl[prsnl_knt].group,10)
     HEAD dp.detail_prefs_id
      grp_knt += 1
      IF (mod(grp_knt,10)=1
       AND grp_knt != 1)
       stat = alterlist(reply->prsnl[prsnl_knt].group,(grp_knt+ 9))
      ENDIF
      reply->prsnl[prsnl_knt].group[grp_knt].group_id = dp.detail_prefs_id, reply->prsnl[prsnl_knt].
      group[grp_knt].view_name = dp.view_name, reply->prsnl[prsnl_knt].group[grp_knt].view_seq = dp
      .view_seq,
      reply->prsnl[prsnl_knt].group[grp_knt].comp_name = dp.comp_name, reply->prsnl[prsnl_knt].group[
      grp_knt].comp_seq = dp.comp_seq, pref_knt = 0,
      stat = alterlist(reply->prsnl[prsnl_knt].group[grp_knt].pref,10)
     DETAIL
      pref_knt += 1
      IF (mod(pref_knt,10)=1
       AND pref_knt != 1)
       stat = alterlist(reply->prsnl[prsnl_knt].group[grp_knt].pref,(pref_knt+ 9))
      ENDIF
      reply->prsnl[prsnl_knt].group[grp_knt].pref[pref_knt].pref_id = nvp.name_value_prefs_id, reply
      ->prsnl[prsnl_knt].group[grp_knt].pref[pref_knt].pref_name = nvp.pvc_name, reply->prsnl[
      prsnl_knt].group[grp_knt].pref[pref_knt].pref_value = nvp.pvc_value,
      reply->prsnl[prsnl_knt].group[grp_knt].pref[pref_knt].sequence = nvp.sequence, reply->prsnl[
      prsnl_knt].group[grp_knt].pref[pref_knt].merge_id = nvp.merge_id, reply->prsnl[prsnl_knt].
      group[grp_knt].pref[pref_knt].merge_name = nvp.merge_name,
      reply->prsnl[prsnl_knt].group[grp_knt].pref[pref_knt].active_ind = nvp.active_ind
     FOOT  dp.detail_prefs_id
      reply->prsnl[prsnl_knt].group[grp_knt].pref_qual = pref_knt, stat = alterlist(reply->prsnl[
       prsnl_knt].group[grp_knt].pref,pref_knt)
     FOOT REPORT
      reply->prsnl[prsnl_knt].group_qual = grp_knt, stat = alterlist(reply->prsnl[prsnl_knt].group,
       grp_knt)
     WITH nocounter
    ;end select
  ENDFOR
 END ;Subroutine
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "003 02/03/05 AW9942"
END GO
