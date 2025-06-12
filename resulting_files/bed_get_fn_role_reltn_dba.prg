CREATE PROGRAM bed_get_fn_role_reltn:dba
 FREE SET reply
 RECORD reply(
   1 rlist[*]
     2 description = vc
     2 display = vc
     2 slist[*]
       3 code_value = f8
       3 description = vc
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET track_ref
 RECORD track_ref(
   1 cnu_list[*]
     2 unique_comp = vc
 )
 SET reply->status_data.status = "F"
 SET stot_count = 0
 SET scount = 0
 SET rtot_count = 0
 SET rcount = 0
 SET stat = alterlist(reply->rlist,50)
 SET trtot_count = 0
 SET trcount = 0
 SET stat = alterlist(track_ref->cnu_list,50)
 SET comp_type_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="DEFRELNROLE"
  DETAIL
   comp_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET prv_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prv_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET track_ref_id = 0.0
 SELECT INTO "NL:"
  FROM track_reference tr
  WHERE tr.active_ind=1
   AND (tr.tracking_group_cd=request->trk_group_code_value)
   AND tr.tracking_ref_type_cd=prv_code_value
  DETAIL
   trcount = (trcount+ 1), trtot_count = (trtot_count+ 1)
   IF (trcount > 50)
    stat = alterlist(track_ref->cnu_list,(trtot_count+ 50)), trcount = 1
   ENDIF
   track_ref->cnu_list[trtot_count].unique_comp = build(trim(cnvtstring(request->trk_group_code_value,
      20,0)),";",trim(cnvtstring(tr.tracking_ref_id,20,0))), rcount = (rcount+ 1), rtot_count = (
   rtot_count+ 1)
   IF (rcount > 50)
    stat = alterlist(reply->rlist,(rtot_count+ 50)), rcount = 1
   ENDIF
   reply->rlist[rtot_count].description = tr.description, reply->rlist[rtot_count].display = tr
   .display
  WITH nocounter
 ;end select
 SET stat = alterlist(track_ref->cnu_list,trtot_count)
 SET stat = alterlist(reply->rlist,rtot_count)
 IF (trtot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = trtot_count),
    track_prefs tp,
    track_comp_prefs tcp,
    code_value cv
   PLAN (d)
    JOIN (tp
    WHERE tp.comp_name="Default Relation"
     AND tp.comp_type_cd=comp_type_code_value
     AND tp.comp_pref="Role Cd"
     AND (tp.comp_name_unq=track_ref->cnu_list[d.seq].unique_comp))
    JOIN (tcp
    WHERE tcp.sub_comp_name="Default Relation"
     AND tcp.sub_comp_type_cd=comp_type_code_value
     AND tcp.track_pref_id=tp.track_pref_id)
    JOIN (cv
    WHERE cv.active_ind=1
     AND cv.code_set=333
     AND cv.code_value=cnvtreal(tcp.sub_comp_pref))
   ORDER BY d.seq
   HEAD d.seq
    stat = alterlist(reply->rlist[d.seq].slist,50), scount = 0, stot_count = 0
   DETAIL
    scount = (scount+ 1), stot_count = (stot_count+ 1)
    IF (scount > 50)
     stat = alterlist(reply->rlist[d.seq].slist,(stot_count+ 50)), scount = 1
    ENDIF
    reply->rlist[d.seq].slist[stot_count].code_value = cv.code_value, reply->rlist[d.seq].slist[
    stot_count].description = cv.description, reply->rlist[d.seq].slist[stot_count].display = cv
    .display
   FOOT  d.seq
    stat = alterlist(reply->rlist[d.seq].slist,stot_count)
   WITH nocounter
  ;end select
 ENDIF
 IF (rtot_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
END GO
