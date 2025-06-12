CREATE PROGRAM bed_get_cnt_wv:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 working_views[*]
      2 cnt_wv_key_id = f8
      2 working_view_uid = vc
      2 dcp_wv_ref_id = f8
      2 display_name = vc
      2 position_cd = f8
      2 position_cduid = vc
      2 position_display = vc
      2 position_meaning = vc
      2 location_cd = f8
      2 location_cduid = vc
      2 location_display = vc
      2 location_meaning = vc
      2 version_num = i4
      2 future_ind = i2
    1 dcp_view_names[*]
      2 dcp_view_display_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET vcnt = 0
 SET wvcnt = 0
 SELECT INTO "nl:"
  FROM cnt_wv_key v,
   cnt_code_value_key vpc,
   cnt_code_value_key vlc
  PLAN (v
   WHERE v.active_ind=1)
   JOIN (vpc
   WHERE vpc.code_value_uid=outerjoin(v.position_cduid))
   JOIN (vlc
   WHERE vlc.code_value_uid=outerjoin(v.location_cduid))
  HEAD v.cnt_wv_key_id
   vcnt = (vcnt+ 1), stat = alterlist(reply->working_views,vcnt), reply->working_views[vcnt].
   cnt_wv_key_id = v.cnt_wv_key_id,
   reply->working_views[vcnt].working_view_uid = v.working_view_uid, reply->working_views[vcnt].
   dcp_wv_ref_id = v.dcp_wv_ref_id, reply->working_views[vcnt].display_name = v.display_name
   IF (vpc.code_value_uid != "")
    reply->working_views[vcnt].position_cd = vpc.code_value, reply->working_views[vcnt].
    position_cduid = vpc.code_value_uid, reply->working_views[vcnt].position_display = vpc.display,
    reply->working_views[vcnt].position_meaning = vpc.cdf_meaning
   ENDIF
   IF (vlc.code_value_uid != "")
    reply->working_views[vcnt].location_cd = vlc.code_value, reply->working_views[vcnt].
    location_cduid = vlc.code_value_uid, reply->working_views[vcnt].location_display = vlc.display,
    reply->working_views[vcnt].location_meaning = vlc.cdf_meaning
   ENDIF
   reply->working_views[vcnt].version_num = v.version_num
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on retrieving working view hierarchy")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(reply->working_views,5)),
   working_view wv
  PLAN (d
   WHERE (reply->working_views[d.seq].dcp_wv_ref_id=0.0))
   JOIN (wv
   WHERE cnvtupper(wv.display_name)=cnvtupper(reply->working_views[d.seq].display_name)
    AND wv.current_working_view=0)
  ORDER BY d.seq
  HEAD d.seq
   reply->working_views[d.seq].dcp_wv_ref_id = wv.working_view_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on retrieving working view id")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM working_view wv
  PLAN (wv
   WHERE wv.current_working_view=0)
  ORDER BY wv.display_name
  HEAD wv.display_name
   wvcnt = (wvcnt+ 1), stat = alterlist(reply->dcp_view_names,wvcnt), reply->dcp_view_names[wvcnt].
   dcp_view_display_name = wv.display_name
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on retrieving working view names")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 DECLARE num_wv = i4 WITH protect, noconstant(0)
 FOR (num_wv = 1 TO size(reply->working_views,5))
  SET reply->working_views[num_wv].future_ind = 0
  IF ((reply->working_views[num_wv].dcp_wv_ref_id > 0))
   SELECT INTO "nl:"
    FROM working_view w
    WHERE (w.current_working_view=reply->working_views[num_wv].dcp_wv_ref_id)
     AND w.active_ind=0
     AND w.version_num=0
    DETAIL
     reply->working_views[num_wv].future_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
