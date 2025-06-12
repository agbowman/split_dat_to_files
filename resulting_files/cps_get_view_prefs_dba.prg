CREATE PROGRAM cps_get_view_prefs:dba
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
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 view_knt = i4
     2 views[*]
       3 view_prefs_id = f8
       3 frame_type = c12
       3 view_name = c12
       3 view_seq = i4
       3 view_pref_qual = i4
       3 view_pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 merge_name = vc
         4 merge_id = f8
         4 sequence = i4
       3 view_comp_knt = i4
       3 view_comp[*]
         4 view_comp_prefs_id = f8
         4 comp_name = c12
         4 comp_seq = i4
         4 comp_pref_qual = i4
         4 comp_pref[*]
           5 pref_id = f8
           5 pref_name = c32
           5 pref_value = vc
           5 merge_name = vc
           5 merge_id = f8
           5 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE idx1 = i4 WITH noconstant(0), public
 SET max_vknt = 0
 IF ((request->qual_knt < 1))
  SET failed = input_error
  SET table_name = "REQUEST_VALIDATION"
  SET serrmsg = "No items in request"
 ENDIF
 IF ((request->frame_knt > 0))
  CALL echo("**********************")
  CALL echo("request->frame_knt > 0")
  CALL echo("**********************")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   svar = build(vp.prsnl_id,vp.position_cd,vp.application_number), vp.frame_type, vp.view_prefs_id
   FROM view_prefs vp,
    name_value_prefs nvp
   PLAN (vp
    WHERE expand(idx,1,request->qual_knt,vp.prsnl_id,request->qual[idx].prsnl_id,
     vp.position_cd,request->qual[idx].position_cd,vp.application_number,request->qual[idx].
     application_number)
     AND expand(idx1,1,request->frame_knt,vp.frame_type,request->frames[idx1].frame_type)
     AND ((vp.active_ind+ 0)=true))
    JOIN (nvp
    WHERE nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.active_ind=true)
   ORDER BY svar, vp.prsnl_id, vp.frame_type,
    vp.view_prefs_id
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   HEAD svar
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].application_number = vp.application_number, reply->qual[knt].position_cd = vp
    .position_cd, reply->qual[knt].prsnl_id = vp.prsnl_id,
    vknt = 0, stat = alterlist(reply->qual[knt].views,10)
   HEAD vp.view_prefs_id
    vknt += 1
    IF (mod(vknt,10)=1
     AND vknt != 1)
     stat = alterlist(reply->qual[knt].views,(vknt+ 9))
    ENDIF
    reply->qual[knt].views[vknt].view_prefs_id = vp.view_prefs_id, reply->qual[knt].views[vknt].
    frame_type = vp.frame_type, reply->qual[knt].views[vknt].view_name = vp.view_name,
    reply->qual[knt].views[vknt].view_seq = vp.view_seq, pknt = 0, stat = alterlist(reply->qual[knt].
     views[vknt].view_pref,10)
   DETAIL
    pknt += 1
    IF (mod(pknt,10)=1
     AND pknt != 1)
     stat = alterlist(reply->qual[knt].views[vknt].view_pref,(pknt+ 9))
    ENDIF
    reply->qual[knt].views[vknt].view_pref[pknt].pref_id = nvp.name_value_prefs_id, reply->qual[knt].
    views[vknt].view_pref[pknt].pref_name = nvp.pvc_name, reply->qual[knt].views[vknt].view_pref[pknt
    ].pref_value = nvp.pvc_value,
    reply->qual[knt].views[vknt].view_pref[pknt].merge_name = nvp.merge_name, reply->qual[knt].views[
    vknt].view_pref[pknt].merge_id = nvp.merge_id, reply->qual[knt].views[vknt].view_pref[pknt].
    sequence = nvp.sequence
   FOOT  vp.view_prefs_id
    reply->qual[knt].views[vknt].view_pref_qual = pknt, stat = alterlist(reply->qual[knt].views[vknt]
     .view_pref,pknt)
   FOOT  svar
    reply->qual[knt].view_knt = vknt, stat = alterlist(reply->qual[knt].views,vknt)
    IF (vknt > max_vknt)
     max_vknt = vknt
    ENDIF
   FOOT REPORT
    reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter, orahintcbo(
     "LEADING(VP NVP) USE_NL(NVP) INDEX(VP XIE3VIEW_PREFS) INDEX(NVP XIE1NAME_VALUE_PREFS)")
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "VIEW_PREFS"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("**********************")
  CALL echo("request->frame_knt < 0")
  CALL echo("**********************")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   svar = build(vp.prsnl_id,vp.position_cd,vp.application_number), vp.frame_type, vp.view_prefs_id
   FROM view_prefs vp,
    name_value_prefs nvp
   PLAN (vp
    WHERE expand(idx,1,request->qual_knt,vp.prsnl_id,request->qual[idx].prsnl_id,
     vp.position_cd,request->qual[idx].position_cd,vp.application_number,request->qual[idx].
     application_number)
     AND ((vp.active_ind+ 0)=true))
    JOIN (nvp
    WHERE nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.active_ind=true)
   ORDER BY svar, vp.prsnl_id, vp.frame_type,
    vp.view_prefs_id
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   HEAD svar
    knt += 1
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].application_number = vp.application_number, reply->qual[knt].position_cd = vp
    .position_cd, reply->qual[knt].prsnl_id = vp.prsnl_id,
    vknt = 0, stat = alterlist(reply->qual[knt].views,10)
   HEAD vp.view_prefs_id
    vknt += 1
    IF (mod(vknt,10)=1
     AND vknt != 1)
     stat = alterlist(reply->qual[knt].views,(vknt+ 9))
    ENDIF
    reply->qual[knt].views[vknt].view_prefs_id = vp.view_prefs_id, reply->qual[knt].views[vknt].
    frame_type = vp.frame_type, reply->qual[knt].views[vknt].view_name = vp.view_name,
    reply->qual[knt].views[vknt].view_seq = vp.view_seq, pknt = 0, stat = alterlist(reply->qual[knt].
     views[vknt].view_pref,10)
   DETAIL
    pknt += 1
    IF (mod(pknt,10)=1
     AND pknt != 1)
     stat = alterlist(reply->qual[knt].views[vknt].view_pref,(pknt+ 9))
    ENDIF
    reply->qual[knt].views[vknt].view_pref[pknt].pref_id = nvp.name_value_prefs_id, reply->qual[knt].
    views[vknt].view_pref[pknt].pref_name = nvp.pvc_name, reply->qual[knt].views[vknt].view_pref[pknt
    ].pref_value = nvp.pvc_value,
    reply->qual[knt].views[vknt].view_pref[pknt].merge_name = nvp.merge_name, reply->qual[knt].views[
    vknt].view_pref[pknt].merge_id = nvp.merge_id, reply->qual[knt].views[vknt].view_pref[pknt].
    sequence = nvp.sequence
   FOOT  vp.view_prefs_id
    reply->qual[knt].views[vknt].view_pref_qual = pknt, stat = alterlist(reply->qual[knt].views[vknt]
     .view_pref,pknt)
   FOOT  svar
    reply->qual[knt].view_knt = vknt, stat = alterlist(reply->qual[knt].views,vknt)
    IF (vknt > max_vknt)
     max_vknt = vknt
    ENDIF
   FOOT REPORT
    reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter, orahintcbo(
     "LEADING(VP NVP) USE_NL(NVP) INDEX(VP XIE3VIEW_PREFS) INDEX(NVP XIE1NAME_VALUE_PREFS)")
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "VIEW_PREFS"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->qual_knt < 1))
  GO TO exit_script
 ENDIF
 CALL echo("*******************")
 CALL echo("Get view_comp_prefs")
 CALL echo("*******************")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(reply->qual_knt)),
   (dummyt d2  WITH seq = value(max_vknt)),
   view_comp_prefs vcp,
   name_value_prefs nvp
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE d2.seq > 0
    AND (d2.seq <= reply->qual[d1.seq].view_knt))
   JOIN (vcp
   WHERE (vcp.prsnl_id=reply->qual[d1.seq].prsnl_id)
    AND (vcp.position_cd=reply->qual[d1.seq].position_cd)
    AND (vcp.application_number=reply->qual[d1.seq].application_number)
    AND (concat(vcp.view_name,"")=reply->qual[d1.seq].views[d2.seq].view_name)
    AND (vcp.view_seq=reply->qual[d1.seq].views[d2.seq].view_seq)
    AND vcp.active_ind=true)
   JOIN (nvp
   WHERE nvp.parent_entity_id=vcp.view_comp_prefs_id
    AND nvp.parent_entity_name="VIEW_COMP_PREFS"
    AND nvp.active_ind=true)
  ORDER BY d1.seq, d2.seq, vcp.view_comp_prefs_id
  HEAD d1.seq
   dvar = 0
  HEAD d2.seq
   vcknt = 0, stat = alterlist(reply->qual[d1.seq].views[d2.seq].view_comp,10)
  HEAD vcp.view_comp_prefs_id
   vcknt += 1
   IF (mod(vcknt,10)=1
    AND vcknt != 1)
    stat = alterlist(reply->qual[d1.seq].views[d2.seq].view_comp,(vcknt+ 9))
   ENDIF
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].view_comp_prefs_id = vcp.view_comp_prefs_id,
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_name = vcp.comp_name, reply->qual[d1.seq].
   views[d2.seq].view_comp[vcknt].comp_seq = vcp.comp_seq,
   pknt = 0, stat = alterlist(reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref,10)
  DETAIL
   pknt += 1
   IF (mod(pknt,10)=1
    AND pknt != 1)
    stat = alterlist(reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref,(pknt+ 9))
   ENDIF
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].pref_id = nvp
   .name_value_prefs_id, reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].pref_name
    = nvp.pvc_name, reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].pref_value =
   nvp.pvc_value,
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].merge_name = nvp.merge_name,
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].merge_id = nvp.merge_id, reply
   ->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref[pknt].sequence = nvp.sequence
  FOOT  vcp.view_comp_prefs_id
   reply->qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref_qual = pknt, stat = alterlist(reply->
    qual[d1.seq].views[d2.seq].view_comp[vcknt].comp_pref,pknt)
  FOOT  d2.seq
   reply->qual[d1.seq].views[d2.seq].view_comp_knt = vcknt, stat = alterlist(reply->qual[d1.seq].
    views[d2.seq].view_comp,vcknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "VIEW_COMP_PREFS"
  GO TO exit_script
 ENDIF
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
 ELSEIF ((reply->qual_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "004 01/31/05 AW9942"
END GO
