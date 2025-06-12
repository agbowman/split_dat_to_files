CREATE PROGRAM dcp_del_view_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = vc WITH noconstant("F")
 DECLARE app_nbr = i4 WITH noconstant(0)
 DECLARE psn_cd = f8 WITH noconstant(0.0)
 DECLARE prsnlid = f8 WITH noconstant(0.0)
 DECLARE viewname = vc WITH noconstant(fillstring(12," "))
 DECLARE frametype = vc WITH noconstant(fillstring(12," "))
 DECLARE viewseq = i4 WITH noconstant(0)
 DECLARE parententityname = vc WITH noconstant(fillstring(12," "))
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE count2 = i2 WITH noconstant(0)
 DECLARE viewprefsid = f8 WITH noconstant(request->view_prefs_id)
 SET parententityid[500] = 0.0
 SET reply->status_data.status = "F"
 IF ((request->prsnl_id > 0))
  SET request->position_cd = 0
 ENDIF
 IF (viewprefsid=0)
  SELECT INTO "nl:"
   vp.view_prefs_id
   FROM view_prefs vp
   WHERE (vp.prsnl_id=request->prsnl_id)
    AND (vp.position_cd=request->position_cd)
    AND (vp.application_number=request->application_number)
    AND (vp.frame_type=request->frame_type)
    AND (vp.view_name=request->view_name)
    AND (vp.view_seq=request->view_seq)
   DETAIL
    viewprefsid = vp.view_prefs_id
   WITH nocounter, maxqual(vp,1)
  ;end select
 ENDIF
 IF (viewprefsid=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM view_prefs vp
  WHERE vp.view_prefs_id=viewprefsid
  DETAIL
   app_nbr = vp.application_number, psn_cd = vp.position_cd, prsnlid = vp.prsnl_id,
   frametype = vp.frame_type, viewname = vp.view_name, viewseq = vp.view_seq
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  dp.detail_prefs_id
  FROM detail_prefs dp
  WHERE ((dp.prsnl_id+ 0)=prsnlid)
   AND dp.position_cd=psn_cd
   AND ((dp.application_number+ 0)=app_nbr)
   AND dp.view_name=viewname
   AND dp.view_seq=viewseq
  HEAD REPORT
   parententityname = "DETAIL_PREFS", count1 = 0
  DETAIL
   count1 = (count1+ 1), parententityid[count1] = dp.detail_prefs_id
  WITH nocounter
 ;end select
 IF (count1 > 0)
  DELETE  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(count1))
   SET nvp.seq = 1
   PLAN (d)
    JOIN (nvp
    WHERE cnvtupper(nvp.parent_entity_name)=parententityname
     AND (nvp.parent_entity_id=parententityid[d.seq]))
   WITH nocounter
  ;end delete
  DELETE  FROM detail_prefs dp,
    (dummyt d  WITH seq = value(count1))
   SET dp.seq = 1
   PLAN (d)
    JOIN (dp
    WHERE (dp.detail_prefs_id=parententityid[d.seq]))
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  vcp.view_comp_prefs_id
  FROM view_comp_prefs vcp
  WHERE vcp.prsnl_id=prsnlid
   AND ((vcp.position_cd+ 0)=psn_cd)
   AND ((vcp.application_number+ 0)=app_nbr)
   AND vcp.view_name=viewname
   AND vcp.view_seq=viewseq
  HEAD REPORT
   parententityname = "VIEW_COMP_PREFS", count2 = 0
  DETAIL
   count2 = (count2+ 1), parententityid[count2] = vcp.view_comp_prefs_id
  WITH nocounter
 ;end select
 IF (count2 > 0)
  DELETE  FROM name_value_prefs nvp,
    (dummyt d  WITH seq = value(count2))
   SET nvp.seq = 1
   PLAN (d)
    JOIN (nvp
    WHERE nvp.parent_entity_name=parententityname
     AND (nvp.parent_entity_id=parententityid[d.seq]))
   WITH nocounter
  ;end delete
  DELETE  FROM view_comp_prefs vcp,
    (dummyt d  WITH seq = value(count2))
   SET vcp.seq = 1
   PLAN (d)
    JOIN (vcp
    WHERE (vcp.view_comp_prefs_id=parententityid[d.seq]))
   WITH nocounter
  ;end delete
 ENDIF
 DELETE  FROM name_value_prefs nvp
  WHERE nvp.parent_entity_name="VIEW_PREFS"
   AND nvp.parent_entity_id=viewprefsid
  WITH nocounter
 ;end delete
 DELETE  FROM view_prefs sn
  WHERE sn.view_prefs_id=viewprefsid
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "view_prefs table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET failed = "T"
 ENDIF
#exit_program
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
