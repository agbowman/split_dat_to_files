CREATE PROGRAM bed_get_pos_by_components:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 components[*]
      2 view_comp_prefs_id = f8
      2 detail_prefs_id = f8
      2 positions[*]
        3 position_code_value = f8
        3 position_display = vc
        3 match_components[*]
          4 view_comp_prefs_id = f8
          4 detail_prefs_id = f8
          4 comp_name = vc
          4 comp_seq = i4
          4 view_comp_app_level = i2
          4 detail_prefs_app_level = i2
          4 parent_view_id = f8
          4 parent_view_caption = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_req
 RECORD temp_req(
   1 components[*]
     2 frame_type = vc
     2 view_name = vc
     2 view_seq = i4
     2 sub_view_name = vc
     2 sub_view_seq = i4
     2 view_comp_ind = i2
     2 global_ind = i2
     2 sub_view_ind = i2
     2 comp_name = vc
     2 positions[*]
       3 position_code_value = f8
       3 position_display = vc
       3 match_components[*]
         4 final_view_comp_prefs_id = f8
         4 final_detail_prefs_id = f8
         4 comp_name = vc
         4 comp_seq = i4
         4 parent_view_id = f8
         4 parent_view_caption = vc
         4 parent_view_name = vc
         4 parent_view_seq = i4
         4 view_comp_id = f8
         4 detail_pref_id = f8
         4 view_comp_app_level = i2
         4 detail_prefs_app_level = i2
         4 detail_prefs_search = i2
         4 view_comp_prefs_search = i2
 )
 FREE SET global_pos
 RECORD global_pos(
   1 pos[*]
     2 code_value = f8
     2 display = vc
   1 pos_cnt = i4
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->components,5)
 IF (((req_cnt=0) OR ((request->application=0))) )
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->components,req_cnt)
 SET stat = alterlist(temp_req->components,req_cnt)
 FOR (x = 1 TO req_cnt)
   IF ((request->components[x].view_comp_prefs_id=0.0)
    AND (request->components[x].detail_prefs_id=0.0))
    GO TO exit_script
   ENDIF
   SET reply->components[x].view_comp_prefs_id = request->components[x].view_comp_prefs_id
   SET reply->components[x].detail_prefs_id = request->components[x].detail_prefs_id
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  c.code_value
  FROM code_value c,
   view_prefs v
  PLAN (c
   WHERE c.code_set=88
    AND c.active_ind=1)
   JOIN (v
   WHERE v.application_number=outerjoin(request->application)
    AND v.position_cd=outerjoin(c.code_value)
    AND v.prsnl_id=outerjoin(0.0)
    AND v.active_ind=outerjoin(1))
  ORDER BY c.code_value
  HEAD c.code_value
   IF (v.view_prefs_id=0.0)
    global_pos->pos_cnt = (global_pos->pos_cnt+ 1), stat = alterlist(global_pos->pos,global_pos->
     pos_cnt), global_pos->pos[global_pos->pos_cnt].code_value = c.code_value,
    global_pos->pos[global_pos->pos_cnt].display = c.display
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   view_comp_prefs p,
   view_prefs vp
  PLAN (d
   WHERE (request->components[d.seq].view_comp_prefs_id > 0.0))
   JOIN (p
   WHERE (p.view_comp_prefs_id=request->components[d.seq].view_comp_prefs_id)
    AND p.active_ind=1)
   JOIN (vp
   WHERE vp.view_name=p.view_name
    AND vp.view_seq=p.view_seq
    AND vp.application_number=p.application_number
    AND vp.position_cd IN (0, p.position_cd)
    AND vp.prsnl_id=p.prsnl_id
    AND vp.active_ind=1)
  ORDER BY d.seq, vp.position_cd, vp.view_prefs_id,
   p.view_comp_prefs_id
  DETAIL
   temp_req->components[d.seq].frame_type = vp.frame_type, temp_req->components[d.seq].view_name = vp
   .view_name, temp_req->components[d.seq].view_seq = vp.view_seq,
   temp_req->components[d.seq].view_comp_ind = 1, temp_req->components[d.seq].comp_name = p.comp_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   detail_prefs p,
   view_prefs vp
  PLAN (d
   WHERE (request->components[d.seq].view_comp_prefs_id=0.0))
   JOIN (p
   WHERE (p.detail_prefs_id=request->components[d.seq].detail_prefs_id)
    AND p.active_ind=1)
   JOIN (vp
   WHERE vp.view_name=p.view_name
    AND vp.view_seq=p.view_seq
    AND vp.application_number=p.application_number
    AND vp.position_cd IN (p.position_cd, 0)
    AND vp.prsnl_id=p.prsnl_id
    AND vp.active_ind=1)
  ORDER BY d.seq, vp.position_cd, vp.view_prefs_id,
   p.detail_prefs_id
  DETAIL
   temp_req->components[d.seq].frame_type = vp.frame_type, temp_req->components[d.seq].view_name = vp
   .view_name, temp_req->components[d.seq].view_seq = vp.view_seq,
   temp_req->components[d.seq].comp_name = p.comp_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   view_prefs vp,
   view_comp_prefs vcp,
   code_value c,
   name_value_prefs n,
   name_value_prefs n2
  PLAN (d)
   JOIN (vp
   WHERE (vp.application_number=request->application)
    AND vp.prsnl_id=0.0
    AND (vp.frame_type=temp_req->components[d.seq].frame_type)
    AND (vp.view_name=temp_req->components[d.seq].view_name)
    AND vp.active_ind=1)
   JOIN (vcp
   WHERE vcp.application_number=vp.application_number
    AND vcp.position_cd=vp.position_cd
    AND vcp.prsnl_id=vp.prsnl_id
    AND vcp.view_name=vp.view_name
    AND vcp.view_seq=vp.view_seq
    AND (vcp.comp_name=temp_req->components[d.seq].comp_name))
   JOIN (c
   WHERE c.code_value=outerjoin(vcp.position_cd)
    AND c.active_ind=outerjoin(1))
   JOIN (n
   WHERE n.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND n.parent_entity_name=outerjoin("VIEW_PREFS")
    AND trim(n.pvc_name)=outerjoin(trim(request->components[d.seq].parent_pvc_name))
    AND n.active_ind=outerjoin(1))
   JOIN (n2
   WHERE n2.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND n2.parent_entity_name=outerjoin("VIEW_PREFS")
    AND trim(n2.pvc_name)=outerjoin("VIEW_CAPTION")
    AND n2.active_ind=outerjoin(1))
  ORDER BY d.seq, vp.position_cd, vp.view_prefs_id,
   vcp.view_comp_prefs_id, n.name_value_prefs_id
  HEAD d.seq
   pcnt = 0, ptcnt = size(temp_req->components[d.seq].positions,5), stat = alterlist(temp_req->
    components[d.seq].positions,(ptcnt+ 100))
  HEAD vp.position_cd
   IF (vp.position_cd=c.code_value)
    pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
    IF (pcnt > 100)
     stat = alterlist(temp_req->components[d.seq].positions,(ptcnt+ 100)), pcnt = 1
    ENDIF
    temp_req->components[d.seq].positions[ptcnt].position_code_value = c.code_value, temp_req->
    components[d.seq].positions[ptcnt].position_display = c.display, stat = alterlist(temp_req->
     components[d.seq].positions[ptcnt].match_components,10)
   ENDIF
   pv_cnt = 0, pvt_cnt = 0
  HEAD vp.view_prefs_id
   load_view_ind = 0
  HEAD vcp.view_comp_prefs_id
   load_view_ind = 0
  HEAD n.name_value_prefs_id
   IF ((request->components[d.seq].parent_pvc_name > " "))
    IF (trim(request->components[d.seq].parent_pvc_name)=n.pvc_name)
     IF ((request->components[d.seq].parent_pvc_value > " "))
      IF ((request->components[d.seq].parent_pvc_value=n.pvc_value))
       load_view_ind = 1
      ENDIF
     ELSE
      load_view_ind = 1
     ENDIF
    ENDIF
   ELSE
    load_view_ind = 1
   ENDIF
  FOOT  vcp.view_comp_prefs_id
   IF (load_view_ind=1
    AND vp.position_cd=c.code_value)
    pv_cnt = (pv_cnt+ 1), pvt_cnt = (pvt_cnt+ 1)
    IF (pv_cnt > 10)
     stat = alterlist(temp_req->components[d.seq].positions[ptcnt].match_components,(pvt_cnt+ 10)),
     pv_cnt = 1
    ENDIF
    temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].comp_name = vcp.comp_name,
    temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].comp_seq = vcp.comp_seq,
    temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].view_comp_id = vcp
    .view_comp_prefs_id,
    temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].parent_view_caption = n2
    .pvc_value, temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].parent_view_id
     = vp.view_prefs_id, temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].
    parent_view_name = vcp.view_name,
    temp_req->components[d.seq].positions[ptcnt].match_components[pvt_cnt].parent_view_seq = vcp
    .view_seq
   ENDIF
  FOOT  vp.position_cd
   IF (vp.position_cd=c.code_value)
    stat = alterlist(temp_req->components[d.seq].positions[ptcnt].match_components,pvt_cnt)
    IF (pvt_cnt=0)
     ptcnt = (ptcnt - 1), pcnt = (pcnt - 1)
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(temp_req->components[d.seq].positions,ptcnt)
  WITH nocounter
 ;end select
 SET cnt = 0
 SET tcnt = 0
 FOR (c = 1 TO req_cnt)
   SET p_size = size(temp_req->components[c].positions,5)
   SET start = 0
   SET num = 0
   SET global_pos_index = locateval(num,start,p_size,0.0,temp_req->components[c].positions[num].
    position_code_value)
   IF (global_pos_index > 0)
    SET global_comp_size = size(temp_req->components[c].positions[global_pos_index].match_components,
     5)
    FOR (gp = 1 TO global_pos->pos_cnt)
      SET p_size = (p_size+ 1)
      SET stat = alterlist(temp_req->components[c].positions,p_size)
      SET temp_req->components[c].positions[p_size].position_code_value = global_pos->pos[gp].
      code_value
      SET temp_req->components[c].positions[p_size].position_display = global_pos->pos[gp].display
      SET stat = alterlist(temp_req->components[c].positions[p_size].match_components,
       global_comp_size)
      FOR (mc = 1 TO global_comp_size)
        SET temp_req->components[c].positions[p_size].match_components[mc].comp_name = temp_req->
        components[c].positions[global_pos_index].match_components[mc].comp_name
        SET temp_req->components[c].positions[p_size].match_components[mc].comp_seq = temp_req->
        components[c].positions[global_pos_index].match_components[mc].comp_seq
        SET temp_req->components[c].positions[p_size].match_components[mc].detail_pref_id = temp_req
        ->components[c].positions[global_pos_index].match_components[mc].detail_pref_id
        SET temp_req->components[c].positions[p_size].match_components[mc].parent_view_caption =
        temp_req->components[c].positions[global_pos_index].match_components[mc].parent_view_caption
        SET temp_req->components[c].positions[p_size].match_components[mc].parent_view_id = temp_req
        ->components[c].positions[global_pos_index].match_components[mc].parent_view_id
        SET temp_req->components[c].positions[p_size].match_components[mc].parent_view_name =
        temp_req->components[c].positions[global_pos_index].match_components[mc].parent_view_name
        SET temp_req->components[c].positions[p_size].match_components[mc].parent_view_seq = temp_req
        ->components[c].positions[global_pos_index].match_components[mc].parent_view_seq
        SET temp_req->components[c].positions[p_size].match_components[mc].view_comp_id = temp_req->
        components[c].positions[global_pos_index].match_components[mc].view_comp_id
        SET temp_req->components[c].positions[p_size].match_components[mc].view_comp_app_level = 1
      ENDFOR
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(p_size)),
     (dummyt d2  WITH seq = 1),
     detail_prefs p,
     name_value_prefs n
    PLAN (d
     WHERE maxrec(d2,size(temp_req->components[c].positions[d.seq].match_components,5)))
     JOIN (d2)
     JOIN (p
     WHERE (p.application_number=request->application)
      AND p.prsnl_id=0.0
      AND (p.position_cd=temp_req->components[c].positions[d.seq].position_code_value)
      AND (p.view_name=temp_req->components[c].positions[d.seq].match_components[d2.seq].
     parent_view_name)
      AND (p.view_seq=temp_req->components[c].positions[d.seq].match_components[d2.seq].
     parent_view_seq)
      AND (p.comp_name=temp_req->components[c].positions[d.seq].match_components[d2.seq].comp_name)
      AND (p.comp_seq=temp_req->components[c].positions[d.seq].match_components[d2.seq].comp_seq))
     JOIN (n
     WHERE n.parent_entity_id=outerjoin(p.detail_prefs_id)
      AND n.parent_entity_name=outerjoin("DETAIL_PREFS")
      AND trim(n.pvc_name)=outerjoin(trim(request->components[c].pvc_name))
      AND n.active_ind=outerjoin(1))
    ORDER BY d.seq, d2.seq, p.detail_prefs_id,
     n.name_value_prefs_id
    HEAD d.seq
     load_ind = 0
    HEAD d2.seq
     load_ind = 0
    HEAD p.detail_prefs_id
     temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_pref_id = p
     .detail_prefs_id
    HEAD n.name_value_prefs_id
     IF ((request->components[c].pvc_name > " "))
      IF (n.name_value_prefs_id > 0.0)
       temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_search = 1
       IF ((request->components[c].pvc_value > " "))
        IF ((request->components[c].pvc_value=n.pvc_value))
         temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_search = 2
        ENDIF
       ELSE
        temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_search = 2
       ENDIF
      ENDIF
     ENDIF
    FOOT  p.detail_prefs_id
     temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_app_level = 0,
     temp_req->components[c].positions[d.seq].match_components[d2.seq].final_detail_prefs_id = p
     .detail_prefs_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(p_size)),
     (dummyt d2  WITH seq = 1),
     detail_prefs p,
     name_value_prefs n
    PLAN (d
     WHERE maxrec(d2,size(temp_req->components[c].positions[d.seq].match_components,5)))
     JOIN (d2)
     JOIN (p
     WHERE (p.application_number=request->application)
      AND p.prsnl_id=0.0
      AND p.position_cd=0.0
      AND (p.view_name=temp_req->components[c].positions[d.seq].match_components[d2.seq].
     parent_view_name)
      AND (p.view_seq=temp_req->components[c].positions[d.seq].match_components[d2.seq].
     parent_view_seq)
      AND (p.comp_name=temp_req->components[c].positions[d.seq].match_components[d2.seq].comp_name)
      AND (p.comp_seq=temp_req->components[c].positions[d.seq].match_components[d2.seq].comp_seq))
     JOIN (n
     WHERE n.parent_entity_id=outerjoin(p.detail_prefs_id)
      AND n.parent_entity_name=outerjoin("DETAIL_PREFS")
      AND trim(n.pvc_name)=outerjoin(trim(request->components[c].pvc_name))
      AND n.active_ind=outerjoin(1))
    ORDER BY d.seq, d2.seq, p.detail_prefs_id,
     n.name_value_prefs_id
    HEAD d.seq
     load_ind = 0
    HEAD d2.seq
     load_ind = 0
    HEAD p.detail_prefs_id
     search_prefs = 0
    HEAD n.name_value_prefs_id
     IF ((request->components[c].pvc_name > " "))
      IF (n.name_value_prefs_id > 0.0)
       search_prefs = 1
       IF ((request->components[c].pvc_value > " "))
        IF ((request->components[c].pvc_value=n.pvc_value))
         search_prefs = 2
        ENDIF
       ELSE
        search_prefs = 2
       ENDIF
      ENDIF
     ENDIF
    FOOT  p.detail_prefs_id
     IF ((temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_search=0))
      temp_req->components[c].positions[d.seq].match_components[d2.seq].detail_prefs_search =
      search_prefs
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(p_size)),
     (dummyt d2  WITH seq = 1),
     view_comp_prefs p,
     name_value_prefs n
    PLAN (d
     WHERE maxrec(d2,size(temp_req->components[c].positions[d.seq].match_components,5)))
     JOIN (d2)
     JOIN (p
     WHERE (p.view_comp_prefs_id=temp_req->components[c].positions[d.seq].match_components[d2.seq].
     view_comp_id))
     JOIN (n
     WHERE n.parent_entity_id=outerjoin(p.view_comp_prefs_id)
      AND n.parent_entity_name=outerjoin("VIEW_COMP_PREFS")
      AND trim(n.pvc_name)=outerjoin(trim(request->components[c].pvc_name))
      AND n.active_ind=outerjoin(1))
    ORDER BY d.seq, d2.seq, p.view_comp_prefs_id,
     n.name_value_prefs_id
    HEAD d.seq
     pos_add_ind = 0
    HEAD d2.seq
     load_ind = 0
    HEAD p.view_comp_prefs_id
     load_ind = 0
    HEAD n.name_value_prefs_id
     IF ((request->components[c].pvc_name > " "))
      IF (n.name_value_prefs_id > 0.0)
       IF ((request->components[c].pvc_value > " "))
        IF ((request->components[c].pvc_value=n.pvc_value))
         temp_req->components[c].positions[d.seq].match_components[d2.seq].view_comp_prefs_search = 2
        ENDIF
       ELSE
        temp_req->components[c].positions[d.seq].match_components[d2.seq].view_comp_prefs_search = 2
       ENDIF
      ENDIF
     ENDIF
    FOOT  p.view_comp_prefs_id
     temp_req->components[c].positions[d.seq].match_components[d2.seq].final_view_comp_prefs_id = p
     .view_comp_prefs_id
    WITH nocounter
   ;end select
   SET tcnt = 0
   SET cnt = 0
   SET stat = alterlist(reply->components[c].positions,100)
   FOR (p = 1 TO p_size)
     SET pos_add_ind = 0
     SET mc_cnt = 0
     SET mc_tcnt = 0
     IF (p != global_pos_index)
      SET mc_size = size(temp_req->components[c].positions[p].match_components,5)
      FOR (mc = 1 TO mc_size)
        IF ((((request->components[c].pvc_name > " ")
         AND (((temp_req->components[c].positions[p].match_components[mc].detail_prefs_search=2)) OR
        ((temp_req->components[c].positions[p].match_components[mc].view_comp_prefs_search=2))) ) OR
        ((request->components[c].pvc_name IN ("", " ", null))))
         AND (((request->components[c].view_comp_prefs_id > 0.0)
         AND (temp_req->components[c].positions[p].match_components[mc].final_view_comp_prefs_id >
        0.0)) OR ((request->components[c].view_comp_prefs_id=0.0))) )
         IF (pos_add_ind=0)
          SET pos_add_ind = 1
          SET cnt = (cnt+ 1)
          SET tcnt = (tcnt+ 1)
          IF (cnt > 100)
           SET stat = alterlist(reply->components[c].positions,(tcnt+ 100))
           SET cnt = 1
          ENDIF
          SET reply->components[c].positions[tcnt].position_code_value = temp_req->components[c].
          positions[p].position_code_value
          SET reply->components[c].positions[tcnt].position_display = temp_req->components[c].
          positions[p].position_display
          SET mc_cnt = 0
          SET mc_tcnt = 0
          SET stat = alterlist(reply->components[c].positions[tcnt].match_components,10)
         ENDIF
         SET mc_cnt = (mc_cnt+ 1)
         SET mc_tcnt = (mc_tcnt+ 1)
         IF (mc_cnt > 10)
          SET stat = alterlist(reply->components[c].positions[tcnt].match_components,(mc_tcnt+ 10))
          SET mc_cnt = 1
         ENDIF
         IF ((request->components[c].detail_prefs_id > 0))
          SET reply->components[c].positions[tcnt].match_components[mc_tcnt].detail_prefs_app_level
           = temp_req->components[c].positions[p].match_components[mc].detail_prefs_app_level
          SET reply->components[c].positions[tcnt].match_components[mc_tcnt].detail_prefs_id =
          temp_req->components[c].positions[p].match_components[mc].final_detail_prefs_id
         ENDIF
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].view_comp_app_level =
         temp_req->components[c].positions[p].match_components[mc].view_comp_app_level
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].view_comp_prefs_id =
         temp_req->components[c].positions[p].match_components[mc].final_view_comp_prefs_id
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].comp_name = temp_req->
         components[c].positions[p].match_components[mc].comp_name
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].comp_seq = temp_req->
         components[c].positions[p].match_components[mc].comp_seq
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].parent_view_caption =
         temp_req->components[c].positions[p].match_components[mc].parent_view_caption
         SET reply->components[c].positions[tcnt].match_components[mc_tcnt].parent_view_id = temp_req
         ->components[c].positions[p].match_components[mc].parent_view_id
        ENDIF
      ENDFOR
     ENDIF
     IF (pos_add_ind=1)
      SET stat = alterlist(reply->components[c].positions[tcnt].match_components,mc_tcnt)
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->components[c].positions,tcnt)
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
