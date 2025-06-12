CREATE PROGRAM bed_get_views_components:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 views[*]
      2 view_name = vc
      2 view_seq = i4
      2 child_views[*]
        3 view_prefs_id = f8
        3 view_name = vc
        3 view_seq = i4
        3 display_seq = vc
        3 view_caption = vc
        3 global_ind = i2
      2 components[*]
        3 source_id = f8
        3 source_table = vc
        3 comp_name = vc
        3 comp_seq = i4
        3 comp_global_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE req_global_ind = i2 WITH protect
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->views,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->views,req_cnt)
 FOR (x = 1 TO req_cnt)
  SET reply->views[x].view_name = request->views[x].view_name
  SET reply->views[x].view_seq = request->views[x].view_seq
 ENDFOR
 SET req_global_ind = 1
 SELECT INTO "nl:"
  FROM view_prefs v
  PLAN (v
   WHERE (v.application_number=request->application_number)
    AND (v.position_cd=request->position_code_value)
    AND v.active_ind=1)
  HEAD REPORT
   req_global_ind = 0
  WITH nocounter
 ;end select
 IF (req_global_ind=0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    view_prefs v,
    name_value_prefs n,
    name_value_prefs n2
   PLAN (d)
    JOIN (v
    WHERE (v.application_number=request->application_number)
     AND (v.position_cd=request->position_code_value)
     AND v.prsnl_id IN (0, null)
     AND (v.frame_type=request->views[d.seq].view_name)
     AND v.active_ind=1)
    JOIN (n
    WHERE n.parent_entity_id=outerjoin(v.view_prefs_id)
     AND n.parent_entity_name=outerjoin("VIEW_PREFS")
     AND trim(n.pvc_name)=outerjoin("DISPLAY_SEQ")
     AND n.active_ind=outerjoin(1))
    JOIN (n2
    WHERE n2.parent_entity_id=outerjoin(v.view_prefs_id)
     AND n2.parent_entity_name=outerjoin("VIEW_PREFS")
     AND trim(n2.pvc_name)=outerjoin("VIEW_CAPTION")
     AND n2.active_ind=outerjoin(1))
   ORDER BY d.seq, v.view_prefs_id
   HEAD d.seq
    cnt = 0, tcnt = 0, stat = alterlist(reply->views[d.seq].child_views,10)
   HEAD v.view_prefs_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->views[d.seq].child_views,(tcnt+ 10)), cnt = 1
    ENDIF
    reply->views[d.seq].child_views[tcnt].view_prefs_id = v.view_prefs_id, reply->views[d.seq].
    child_views[tcnt].view_name = v.view_name, reply->views[d.seq].child_views[tcnt].view_seq = v
    .view_seq
   DETAIL
    reply->views[d.seq].child_views[tcnt].view_caption = n2.pvc_value, reply->views[d.seq].
    child_views[tcnt].display_seq = n.pvc_value
   FOOT  d.seq
    stat = alterlist(reply->views[d.seq].child_views,tcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    view_comp_prefs p
   PLAN (d)
    JOIN (p
    WHERE (p.application_number=request->application_number)
     AND (p.position_cd=request->position_code_value)
     AND ((p.prsnl_id+ 0) IN (0, null))
     AND (p.view_name=request->views[d.seq].view_name)
     AND (p.view_seq=request->views[d.seq].view_seq)
     AND p.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    cnt = 0, tcnt = size(reply->views[d.seq].components,5), stat = alterlist(reply->views[d.seq].
     components,(tcnt+ 10))
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->views[d.seq].components,(tcnt+ 10)), cnt = 1
    ENDIF
    reply->views[d.seq].components[tcnt].comp_name = p.comp_name, reply->views[d.seq].components[tcnt
    ].comp_seq = p.comp_seq, reply->views[d.seq].components[tcnt].source_id = p.view_comp_prefs_id,
    reply->views[d.seq].components[tcnt].source_table = "VIEW_COMP_PREFS"
   FOOT  d.seq
    stat = alterlist(reply->views[d.seq].components,tcnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    view_prefs v,
    view_prefs v2,
    name_value_prefs n,
    name_value_prefs n2
   PLAN (d)
    JOIN (v
    WHERE (v.application_number=request->application_number)
     AND v.position_cd=0
     AND v.prsnl_id IN (0, null)
     AND (v.frame_type=request->views[d.seq].view_name)
     AND v.active_ind=1)
    JOIN (n
    WHERE n.parent_entity_id=outerjoin(v.view_prefs_id)
     AND n.parent_entity_name=outerjoin("VIEW_PREFS")
     AND trim(n.pvc_name)=outerjoin("DISPLAY_SEQ")
     AND n.active_ind=outerjoin(1))
    JOIN (n2
    WHERE n2.parent_entity_id=outerjoin(v.view_prefs_id)
     AND n2.parent_entity_name=outerjoin("VIEW_PREFS")
     AND trim(n2.pvc_name)=outerjoin("VIEW_CAPTION")
     AND n2.active_ind=outerjoin(1))
    JOIN (v2
    WHERE v2.application_number=outerjoin(v.application_number)
     AND v2.position_cd=outerjoin(request->position_code_value)
     AND v2.prsnl_id=outerjoin(0.0)
     AND v2.view_name=outerjoin(request->views[d.seq].view_name)
     AND v2.view_seq=outerjoin(request->views[d.seq].view_seq))
   ORDER BY d.seq, v.view_prefs_id
   HEAD d.seq
    cnt = 0, tcnt = 0, stat = alterlist(reply->views[d.seq].child_views,10)
   HEAD v.view_prefs_id
    IF (v2.view_prefs_id=0)
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->views[d.seq].child_views,(tcnt+ 10)), cnt = 1
     ENDIF
     reply->views[d.seq].child_views[tcnt].view_prefs_id = v.view_prefs_id, reply->views[d.seq].
     child_views[tcnt].view_name = v.view_name, reply->views[d.seq].child_views[tcnt].view_seq = v
     .view_seq,
     reply->views[d.seq].child_views[tcnt].global_ind = 1, reply->views[d.seq].child_views[tcnt].
     view_caption = n2.pvc_value, reply->views[d.seq].child_views[tcnt].display_seq = n.pvc_value
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->views[d.seq].child_views,tcnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    view_comp_prefs p
   PLAN (d)
    JOIN (p
    WHERE (p.application_number=request->application_number)
     AND p.position_cd=0.0
     AND ((p.prsnl_id+ 0) IN (0, null))
     AND (p.view_name=request->views[d.seq].view_name)
     AND (p.view_seq=request->views[d.seq].view_seq)
     AND p.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    cnt = 0, tcnt = size(reply->views[d.seq].components,5), stat = alterlist(reply->views[d.seq].
     components,(tcnt+ 10))
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->views[d.seq].components,(tcnt+ 10)), cnt = 1
    ENDIF
    reply->views[d.seq].components[tcnt].comp_name = p.comp_name, reply->views[d.seq].components[tcnt
    ].comp_seq = p.comp_seq, reply->views[d.seq].components[tcnt].source_id = p.view_comp_prefs_id,
    reply->views[d.seq].components[tcnt].source_table = "VIEW_COMP_PREFS", reply->views[d.seq].
    components[tcnt].comp_global_ind = 1
   FOOT  d.seq
    stat = alterlist(reply->views[d.seq].components,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   detail_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.application_number=request->application_number)
    AND (p.position_cd=request->position_code_value)
    AND ((p.prsnl_id+ 0) IN (0, null))
    AND (p.view_name=request->views[d.seq].view_name)
    AND (p.view_seq=request->views[d.seq].view_seq)
    AND p.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, tcnt = size(reply->views[d.seq].components,5), stat = alterlist(reply->views[d.seq].
    components,(tcnt+ 10))
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(reply->views[d.seq].components,(tcnt+ 10)), cnt = 1
   ENDIF
   reply->views[d.seq].components[tcnt].comp_name = p.comp_name, reply->views[d.seq].components[tcnt]
   .comp_seq = p.comp_seq, reply->views[d.seq].components[tcnt].source_id = p.detail_prefs_id,
   reply->views[d.seq].components[tcnt].source_table = "DETAIL_PREFS"
  FOOT  d.seq
   stat = alterlist(reply->views[d.seq].components,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
