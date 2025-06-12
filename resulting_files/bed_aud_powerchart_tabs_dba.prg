CREATE PROGRAM bed_aud_powerchart_tabs:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET tcnt = 0
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 position_cnt = i2
   1 positions[*]
     2 position_cd = f8
     2 position_txt = vc
     2 view_cnt = i2
     2 priv_cnt = i2
     2 pref_cnt = i2
     2 views[*]
       3 level = vc
       3 view_name = vc
       3 view_level = vc
       3 view_caption = vc
       3 view_seq = i4
       3 table_view_seq = i4
       3 pref_name = vc
       3 pref_value = vc
       3 pref_level = vc
       3 sub_view_cnt = i2
       3 sub_views[*]
         4 sub_level = vc
         4 sub_view_name = vc
         4 sub_view_level = vc
         4 sub_view_caption = vc
         4 sub_view_seq = i4
         4 pref_name = vc
         4 pref_value = vc
         4 pref_level = vc
         4 table_view_seq = i4
 )
 SET high_volume_cnt = 0
 SET positioncnt = 0
 SELECT INTO "nl:"
  FROM application a
  PLAN (a
   WHERE a.application_number=600005
    AND a.active_ind=1)
  HEAD REPORT
   positioncnt = 0
  DETAIL
   positioncnt = (temp_reply->position_cnt+ 1), temp_reply->position_cnt = positioncnt, stat =
   alterlist(temp_reply->positions,positioncnt),
   temp_reply->positions[positioncnt].position_cd = 0, temp_reply->positions[positioncnt].
   position_txt = a.description
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
  ORDER BY cv.display_key
  HEAD REPORT
   positioncnt = 1
  DETAIL
   positioncnt = (temp_reply->position_cnt+ 1), temp_reply->position_cnt = positioncnt, stat =
   alterlist(temp_reply->positions,positioncnt),
   temp_reply->positions[positioncnt].position_cd = cv.code_value, temp_reply->positions[positioncnt]
   .position_txt = cv.display
  WITH nocounter
 ;end select
 IF (positioncnt > 0)
  SELECT INTO "nl"
   s = cnvtint(trim(nvp2.pvc_value))
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    view_prefs vp,
    name_value_prefs nvp,
    name_value_prefs nvp2
   PLAN (d1)
    JOIN (vp
    WHERE vp.prsnl_id=0
     AND (vp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND vp.application_number=600005
     AND vp.frame_type="ORG")
    JOIN (nvp
    WHERE nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND trim(nvp.pvc_name)="VIEW_CAPTION")
    JOIN (nvp2
    WHERE nvp2.parent_entity_id=vp.view_prefs_id
     AND nvp2.parent_entity_name="VIEW_PREFS"
     AND trim(nvp2.pvc_name)="DISPLAY_SEQ")
   ORDER BY d1.seq, vp.frame_type, s,
    vp.view_prefs_id
   HEAD REPORT
    viewcnt = 0
   HEAD d1.seq
    viewcnt = viewcnt
   HEAD nvp2.pvc_value
    viewcnt = viewcnt
   HEAD vp.view_prefs_id
    high_volume_cnt = (high_volume_cnt+ 1), viewcnt = (temp_reply->positions[d1.seq].view_cnt+ 1),
    temp_reply->positions[d1.seq].view_cnt = viewcnt,
    stat = alterlist(temp_reply->positions[d1.seq].views,viewcnt), temp_reply->positions[d1.seq].
    views[viewcnt].level = vp.frame_type, temp_reply->positions[d1.seq].views[viewcnt].view_name = vp
    .view_name,
    temp_reply->positions[d1.seq].views[viewcnt].table_view_seq = vp.view_seq, temp_reply->positions[
    d1.seq].views[viewcnt].view_caption = nvp.pvc_value, temp_reply->positions[d1.seq].views[viewcnt]
    .view_seq = cnvtint(trim(nvp2.pvc_value))
    IF ((temp_reply->positions[d1.seq].position_cd=0))
     temp_reply->positions[d1.seq].views[viewcnt].view_level = "application"
    ELSE
     temp_reply->positions[d1.seq].views[viewcnt].view_level = "position"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   s = cnvtint(trim(nvp2.pvc_value))
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    view_prefs vp,
    name_value_prefs nvp,
    name_value_prefs nvp2
   PLAN (d1)
    JOIN (vp
    WHERE vp.prsnl_id=0
     AND (vp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND vp.application_number=600005
     AND vp.frame_type="CHART")
    JOIN (nvp
    WHERE nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND trim(nvp.pvc_name)="VIEW_CAPTION")
    JOIN (nvp2
    WHERE nvp2.parent_entity_id=vp.view_prefs_id
     AND nvp2.parent_entity_name="VIEW_PREFS"
     AND trim(nvp2.pvc_name)="DISPLAY_SEQ")
   ORDER BY d1.seq, vp.frame_type, s,
    vp.view_prefs_id
   HEAD REPORT
    viewcnt = 0
   HEAD d1.seq
    viewcnt = viewcnt
   HEAD nvp2.pvc_value
    viewcnt = viewcnt
   HEAD vp.view_prefs_id
    high_volume_cnt = (high_volume_cnt+ 1), viewcnt = (temp_reply->positions[d1.seq].view_cnt+ 1),
    temp_reply->positions[d1.seq].view_cnt = viewcnt,
    stat = alterlist(temp_reply->positions[d1.seq].views,viewcnt), temp_reply->positions[d1.seq].
    views[viewcnt].level = vp.frame_type, temp_reply->positions[d1.seq].views[viewcnt].view_name = vp
    .view_name,
    temp_reply->positions[d1.seq].views[viewcnt].table_view_seq = vp.view_seq, temp_reply->positions[
    d1.seq].views[viewcnt].view_caption = nvp.pvc_value, temp_reply->positions[d1.seq].views[viewcnt]
    .view_seq = cnvtint(trim(nvp2.pvc_value))
    IF ((temp_reply->positions[d1.seq].position_cd=0))
     temp_reply->positions[d1.seq].views[viewcnt].view_level = "application"
    ELSE
     temp_reply->positions[d1.seq].views[viewcnt].view_level = "position"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    (dummyt d2  WITH seq = value(1)),
    view_prefs vp,
    name_value_prefs nvp,
    name_value_prefs nvp2
   PLAN (d1
    WHERE maxrec(d2,size(temp_reply->positions[d1.seq].views,5)))
    JOIN (d2)
    JOIN (vp
    WHERE vp.prsnl_id=0
     AND (vp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND vp.application_number=600005
     AND (vp.frame_type=temp_reply->positions[d1.seq].views[d2.seq].view_name))
    JOIN (nvp
    WHERE nvp.parent_entity_id=vp.view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND trim(nvp.pvc_name)="VIEW_CAPTION")
    JOIN (nvp2
    WHERE nvp2.parent_entity_id=vp.view_prefs_id
     AND nvp2.parent_entity_name="VIEW_PREFS"
     AND trim(nvp2.pvc_name)="DISPLAY_SEQ")
   ORDER BY d1.seq, d2.seq, vp.view_prefs_id
   HEAD REPORT
    subviewcnt = 0
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1), subviewcnt = (temp_reply->positions[d1.seq].views[d2.seq]
    .sub_view_cnt+ 1), temp_reply->positions[d1.seq].views[d2.seq].sub_view_cnt = subviewcnt,
    stat = alterlist(temp_reply->positions[d1.seq].views[d2.seq].sub_views,subviewcnt), temp_reply->
    positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_level = vp.frame_type, temp_reply->
    positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_name = vp.view_name,
    temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_caption = nvp
    .pvc_value, temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_seq =
    cnvtint(trim(nvp2.pvc_value)), temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].
    table_view_seq = vp.view_seq
    IF ((temp_reply->positions[d1.seq].position_cd=0))
     temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_level = "application"
    ELSE
     temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_level = "position"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    (dummyt d2  WITH seq = value(1)),
    view_comp_prefs vcp
   PLAN (d1
    WHERE maxrec(d2,size(temp_reply->positions[d1.seq].views,5)))
    JOIN (d2)
    JOIN (vcp
    WHERE vcp.prsnl_id=0
     AND (vcp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND vcp.application_number=600005
     AND (vcp.view_name=temp_reply->positions[d1.seq].views[d2.seq].view_name)
     AND vcp.view_name IN ("CHARTSUMM", "HOMEVIEW")
     AND (vcp.view_seq=temp_reply->positions[d1.seq].views[d2.seq].table_view_seq))
   ORDER BY d1.seq, d2.seq, vcp.comp_seq
   HEAD REPORT
    subviewcnt = 0
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1), subviewcnt = (temp_reply->positions[d1.seq].views[d2.seq]
    .sub_view_cnt+ 1), temp_reply->positions[d1.seq].views[d2.seq].sub_view_cnt = subviewcnt,
    stat = alterlist(temp_reply->positions[d1.seq].views[d2.seq].sub_views,subviewcnt), temp_reply->
    positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_level = vcp.comp_name, temp_reply->
    positions[d1.seq].views[d2.seq].sub_views[subviewcnt].sub_view_seq = vcp.comp_seq,
    temp_reply->positions[d1.seq].views[d2.seq].sub_views[subviewcnt].table_view_seq = vcp.comp_seq
   WITH nocounter
  ;end select
  IF ((temp_reply->positions[1].position_cd=0))
   SET appvcnt = temp_reply->positions[1].view_cnt
   FOR (p = 2 TO positioncnt)
     IF ((temp_reply->positions[p].view_cnt=0))
      SET temp_reply->positions[p].view_cnt = appvcnt
      SET stat = alterlist(temp_reply->positions[p].views,appvcnt)
      FOR (v = 1 TO appvcnt)
        SET temp_reply->positions[p].views[v].level = temp_reply->positions[1].views[v].level
        SET temp_reply->positions[p].views[v].view_name = temp_reply->positions[1].views[v].view_name
        SET temp_reply->positions[p].views[v].view_level = "application"
        SET temp_reply->positions[p].views[v].view_caption = temp_reply->positions[1].views[v].
        view_caption
        SET temp_reply->positions[p].views[v].view_seq = temp_reply->positions[1].views[v].view_seq
        SET temp_reply->positions[p].views[v].table_view_seq = temp_reply->positions[1].views[v].
        table_view_seq
        SET temp_reply->positions[p].views[v].pref_name = temp_reply->positions[1].views[v].pref_name
        SET temp_reply->positions[p].views[v].pref_value = temp_reply->positions[1].views[v].
        pref_value
        SET temp_reply->positions[p].views[v].pref_level = temp_reply->positions[1].views[v].
        pref_level
        SET appsvcnt = temp_reply->positions[1].views[v].sub_view_cnt
        SET temp_reply->positions[p].views[v].sub_view_cnt = appsvcnt
        SET stat = alterlist(temp_reply->positions[p].views[v].sub_views,appsvcnt)
        FOR (s = 1 TO appsvcnt)
          SET temp_reply->positions[p].views[v].sub_views[s].sub_level = temp_reply->positions[1].
          views[v].sub_views[s].sub_level
          SET temp_reply->positions[p].views[v].sub_views[s].sub_view_name = temp_reply->positions[1]
          .views[v].sub_views[s].sub_view_name
          SET temp_reply->positions[p].views[v].sub_views[s].sub_view_level = temp_reply->positions[1
          ].views[v].sub_views[s].sub_view_level
          SET temp_reply->positions[p].views[v].sub_views[s].sub_view_caption = temp_reply->
          positions[1].views[v].sub_views[s].sub_view_caption
          SET temp_reply->positions[p].views[v].sub_views[s].sub_view_seq = temp_reply->positions[1].
          views[v].sub_views[s].sub_view_seq
          SET temp_reply->positions[p].views[v].sub_views[s].pref_name = temp_reply->positions[1].
          views[v].sub_views[s].pref_name
          SET temp_reply->positions[p].views[v].sub_views[s].pref_value = temp_reply->positions[1].
          views[v].sub_views[s].pref_value
          SET temp_reply->positions[p].views[v].sub_views[s].pref_level = temp_reply->positions[1].
          views[v].sub_views[s].pref_level
          SET temp_reply->positions[p].views[v].sub_views[s].table_view_seq = temp_reply->positions[1
          ].views[v].sub_views[s].table_view_seq
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  FOR (p = 1 TO positioncnt)
    FOR (v = 1 TO temp_reply->positions[p].view_cnt)
      IF ((temp_reply->positions[p].views[v].view_name IN ("CHARTSUMM", "SPTASKLIST", "HOMEVIEW")))
       SELECT INTO "nl"
        FROM (dummyt d  WITH seq = value(temp_reply->positions[p].views[v].sub_view_cnt)),
         detail_prefs dp,
         name_value_prefs nvp
        PLAN (d)
         JOIN (dp
         WHERE dp.prsnl_id=0
          AND (dp.position_cd=temp_reply->positions[p].position_cd)
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[p].views[v].view_name)
          AND (dp.view_seq=temp_reply->positions[p].views[v].table_view_seq)
          AND (dp.comp_name=temp_reply->positions[p].views[v].sub_views[d.seq].sub_level)
          AND (dp.comp_seq=temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name) IN ("GENSPREADINFO", "GENVIEWINFO", "R_EVENT_SET_NAME"))
        DETAIL
         temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_name = nvp.pvc_name, temp_reply
         ->positions[p].views[v].sub_views[d.seq].sub_view_caption = nvp.pvc_value
         IF ((temp_reply->positions[p].position_cd=0))
          temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_level = "application"
         ELSE
          temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_level = "position"
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
  ENDFOR
  FOR (p = 1 TO positioncnt)
    FOR (v = 1 TO temp_reply->positions[p].view_cnt)
      IF ((temp_reply->positions[p].views[v].view_name IN ("CHARTSUMM", "SPTASKLIST", "HOMEVIEW")))
       SELECT INTO "nl"
        FROM (dummyt d  WITH seq = value(temp_reply->positions[p].views[v].sub_view_cnt)),
         detail_prefs dp,
         name_value_prefs nvp
        PLAN (d
         WHERE (temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_name=" "))
         JOIN (dp
         WHERE dp.prsnl_id=0
          AND dp.position_cd=0
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[p].views[v].view_name)
          AND (dp.view_seq=temp_reply->positions[p].views[v].table_view_seq)
          AND (dp.comp_name=temp_reply->positions[p].views[v].sub_views[d.seq].sub_level)
          AND (dp.comp_seq=temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name) IN ("GENSPREADINFO", "GENVIEWINFO", "R_EVENT_SET_NAME"))
        DETAIL
         temp_reply->positions[p].views[v].sub_views[d.seq].sub_view_name = nvp.pvc_name, temp_reply
         ->positions[p].views[v].sub_views[d.seq].sub_view_caption = nvp.pvc_value, temp_reply->
         positions[p].views[v].sub_views[d.seq].sub_view_level = "application"
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
  ENDFOR
  SELECT INTO "nl"
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    (dummyt d2  WITH seq = value(1)),
    detail_prefs dp,
    name_value_prefs nvp
   PLAN (d1
    WHERE maxrec(d2,size(temp_reply->positions[d1.seq].views,5)))
    JOIN (d2)
    JOIN (dp
    WHERE dp.prsnl_id=0
     AND (dp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND dp.application_number=600005
     AND (dp.view_name=temp_reply->positions[d1.seq].views[d2.seq].view_name)
     AND dp.view_name="FLOWSHEET"
     AND (dp.view_seq=temp_reply->positions[d1.seq].views[d2.seq].table_view_seq))
    JOIN (nvp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
   ORDER BY d1.seq, d2.seq
   DETAIL
    temp_reply->positions[d1.seq].views[d2.seq].pref_name = nvp.pvc_name, temp_reply->positions[d1
    .seq].views[d2.seq].pref_value = nvp.pvc_value
    IF ((temp_reply->positions[d1.seq].position_cd=0))
     temp_reply->positions[d1.seq].views[d2.seq].pref_level = "application"
    ELSE
     temp_reply->positions[d1.seq].views[d2.seq].pref_level = "position"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    (dummyt d2  WITH seq = value(1)),
    detail_prefs dp,
    name_value_prefs nvp
   PLAN (d1
    WHERE maxrec(d2,size(temp_reply->positions[d1.seq].views,5))
     AND (temp_reply->positions[d1.seq].position_cd > 0))
    JOIN (d2
    WHERE (temp_reply->positions[d1.seq].views[d2.seq].pref_name=" "))
    JOIN (dp
    WHERE dp.prsnl_id=0
     AND dp.position_cd=0
     AND dp.application_number=600005
     AND (dp.view_name=temp_reply->positions[d1.seq].views[d2.seq].view_name)
     AND dp.view_name="FLOWSHEET"
     AND (dp.view_seq=temp_reply->positions[d1.seq].views[d2.seq].table_view_seq))
    JOIN (nvp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
   ORDER BY d1.seq, d2.seq
   DETAIL
    temp_reply->positions[d1.seq].views[d2.seq].pref_name = nvp.pvc_name, temp_reply->positions[d1
    .seq].views[d2.seq].pref_value = nvp.pvc_value, temp_reply->positions[d1.seq].views[d2.seq].
    pref_level = "application"
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   FROM (dummyt d1  WITH seq = value(positioncnt)),
    (dummyt d2  WITH seq = value(1)),
    detail_prefs dp,
    name_value_prefs nvp
   PLAN (d1
    WHERE maxrec(d2,size(temp_reply->positions[d1.seq].views,5))
     AND (temp_reply->positions[d1.seq].position_cd > 0))
    JOIN (d2
    WHERE (temp_reply->positions[d1.seq].views[d2.seq].view_level="application"))
    JOIN (dp
    WHERE dp.prsnl_id=0
     AND (dp.position_cd=temp_reply->positions[d1.seq].position_cd)
     AND dp.application_number=600005
     AND (dp.view_name=temp_reply->positions[d1.seq].views[d2.seq].view_name)
     AND dp.view_name="FLOWSHEET"
     AND (dp.view_seq=temp_reply->positions[d1.seq].views[d2.seq].table_view_seq))
    JOIN (nvp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
   ORDER BY d1.seq, d2.seq
   DETAIL
    temp_reply->positions[d1.seq].views[d2.seq].pref_name = nvp.pvc_name, temp_reply->positions[d1
    .seq].views[d2.seq].pref_value = nvp.pvc_value, temp_reply->positions[d1.seq].views[d2.seq].
    pref_level = "position"
   WITH nocounter
  ;end select
  FOR (x = 1 TO positioncnt)
   SET view_cnt = size(temp_reply->positions[x].views,5)
   FOR (y = 1 TO view_cnt)
    SET sview_cnt = size(temp_reply->positions[x].views[y].sub_views,5)
    FOR (z = 1 TO sview_cnt)
      IF ((temp_reply->positions[x].views[y].sub_views[z].sub_level="RESULTSREVIE")
       AND (temp_reply->positions[x].views[y].sub_views[z].sub_view_name="FLOWSHEET"))
       SELECT INTO "nl"
        FROM detail_prefs dp,
         name_value_prefs nvp
        PLAN (dp
         WHERE dp.prsnl_id=0
          AND (dp.position_cd=temp_reply->positions[x].position_cd)
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[x].views[y].sub_views[z].sub_view_name)
          AND (dp.view_seq=temp_reply->positions[x].views[y].sub_views[z].table_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
        ORDER BY dp.comp_seq, dp.detail_prefs_id
        DETAIL
         temp_reply->positions[x].views[y].sub_views[z].pref_name = nvp.pvc_name, temp_reply->
         positions[x].views[y].sub_views[z].pref_value = nvp.pvc_value
         IF ((temp_reply->positions[x].position_cd=0))
          temp_reply->positions[x].views[y].sub_views[z].pref_level = "application"
         ELSE
          temp_reply->positions[x].views[y].sub_views[z].pref_level = "position"
         ENDIF
        WITH nocounter
       ;end select
      ELSEIF ((temp_reply->positions[x].views[y].sub_views[z].sub_view_name="FLOWSHEET"))
       SELECT INTO "nl"
        FROM detail_prefs dp,
         name_value_prefs nvp
        PLAN (dp
         WHERE dp.prsnl_id=0
          AND (dp.position_cd=temp_reply->positions[x].position_cd)
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[x].views[y].sub_views[z].sub_view_name)
          AND (dp.view_seq=temp_reply->positions[x].views[y].sub_views[z].table_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
        ORDER BY dp.comp_seq, dp.detail_prefs_id
        DETAIL
         temp_reply->positions[x].views[y].sub_views[z].pref_name = nvp.pvc_name, temp_reply->
         positions[x].views[y].sub_views[z].pref_value = nvp.pvc_value
         IF ((temp_reply->positions[x].position_cd=0))
          temp_reply->positions[x].views[y].sub_views[z].pref_level = "application"
         ELSE
          temp_reply->positions[x].views[y].sub_views[z].pref_level = "position"
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDFOR
  ENDFOR
  FOR (x = 1 TO positioncnt)
   SET view_cnt = size(temp_reply->positions[x].views,5)
   FOR (y = 1 TO view_cnt)
    SET sview_cnt = size(temp_reply->positions[x].views[y].sub_views,5)
    FOR (z = 1 TO sview_cnt)
      IF ((temp_reply->positions[x].views[y].sub_views[z].sub_level="RESULTSREVIE")
       AND (temp_reply->positions[x].views[y].sub_views[z].sub_view_name="FLOWSHEET")
       AND (temp_reply->positions[x].views[y].sub_views[z].pref_name=" "))
       SELECT INTO "nl"
        FROM detail_prefs dp,
         name_value_prefs nvp
        PLAN (dp
         WHERE dp.prsnl_id=0
          AND dp.position_cd=0
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[x].views[y].sub_views[z].sub_view_name)
          AND (dp.view_seq=temp_reply->positions[x].views[y].sub_views[z].table_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
        ORDER BY dp.comp_seq, dp.detail_prefs_id
        DETAIL
         temp_reply->positions[x].views[y].sub_views[z].pref_name = nvp.pvc_name, temp_reply->
         positions[x].views[y].sub_views[z].pref_value = nvp.pvc_value, temp_reply->positions[x].
         views[y].sub_views[z].pref_level = "application"
        WITH nocounter
       ;end select
      ELSEIF ((temp_reply->positions[x].views[y].sub_views[z].sub_view_name="FLOWSHEET")
       AND (temp_reply->positions[x].views[y].sub_views[z].pref_name=" "))
       SELECT INTO "nl"
        FROM detail_prefs dp,
         name_value_prefs nvp
        PLAN (dp
         WHERE dp.prsnl_id=0
          AND dp.position_cd=0
          AND dp.application_number=600005
          AND (dp.view_name=temp_reply->positions[x].views[y].sub_views[z].sub_view_name)
          AND (dp.view_seq=temp_reply->positions[x].views[y].sub_views[z].table_view_seq))
         JOIN (nvp
         WHERE nvp.parent_entity_id=dp.detail_prefs_id
          AND nvp.parent_entity_name="DETAIL_PREFS"
          AND trim(nvp.pvc_name)="R_EVENT_SET_NAME")
        ORDER BY dp.comp_seq, dp.detail_prefs_id
        DETAIL
         temp_reply->positions[x].views[y].sub_views[z].pref_name = nvp.pvc_name, temp_reply->
         positions[x].views[y].sub_views[z].pref_value = nvp.pvc_value, temp_reply->positions[x].
         views[y].sub_views[z].pref_level = "application"
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDFOR
  ENDFOR
 ENDIF
 SET col_cnt = 9
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Application, Positions"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Parent Display Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Child Display Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Sequence"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Child Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Child Level"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Preference Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Preference Value"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Preference Level"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF ((request->skip_volume_check_ind=0))
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF (positioncnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO positioncnt)
   IF (size(temp_reply->positions[x].views,5) > 0)
    FOR (y = 1 TO size(temp_reply->positions[x].views,5))
     SET stat = add_rep(temp_reply->positions[x].position_txt,temp_reply->positions[x].views[y].level,
      temp_reply->positions[x].views[y].view_caption,cnvtstring(temp_reply->positions[x].views[y].
       view_seq),temp_reply->positions[x].views[y].view_name,
      temp_reply->positions[x].views[y].view_level,temp_reply->positions[x].views[y].pref_name,
      temp_reply->positions[x].views[y].pref_value,temp_reply->positions[x].views[y].pref_level)
     IF (size(temp_reply->positions[x].views[y].sub_views,5) > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = value(size(temp_reply->positions[x].views[y].sub_views,5)))
       PLAN (d)
       ORDER BY temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_seq
       DETAIL
        IF ((temp_reply->positions[x].views[y].view_name IN ("CHARTSUMM", "SPTASKLIST", "HOMEVIEW")))
         stat = add_rep(temp_reply->positions[x].position_txt,temp_reply->positions[x].views[y].
          view_caption,temp_reply->positions[x].views[y].sub_views[d.seq].sub_level,concat(trim(
            cnvtstring(temp_reply->positions[x].views[y].view_seq)),"--",trim(cnvtstring(temp_reply->
             positions[x].views[y].sub_views[d.seq].sub_view_seq))),"Component",
          "",temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_name,temp_reply->positions[x
          ].views[y].sub_views[d.seq].sub_view_caption,temp_reply->positions[x].views[y].sub_views[d
          .seq].sub_view_level)
        ELSEIF ((temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_name="FLOWSHEET"))
         stat = add_rep(temp_reply->positions[x].position_txt,temp_reply->positions[x].views[y].
          view_caption,temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_caption,concat(
           trim(cnvtstring(temp_reply->positions[x].views[y].view_seq)),"--",trim(cnvtstring(
             temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_seq))),temp_reply->
          positions[x].views[y].sub_views[d.seq].sub_view_name,
          temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_level,temp_reply->positions[x].
          views[y].sub_views[d.seq].pref_name,temp_reply->positions[x].views[y].sub_views[d.seq].
          pref_value,temp_reply->positions[x].views[y].sub_views[d.seq].pref_level)
        ELSE
         stat = add_rep(temp_reply->positions[x].position_txt,temp_reply->positions[x].views[y].
          view_caption,temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_caption,concat(
           trim(cnvtstring(temp_reply->positions[x].views[y].view_seq)),"--",trim(cnvtstring(
             temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_seq))),temp_reply->
          positions[x].views[y].sub_views[d.seq].sub_view_name,
          temp_reply->positions[x].views[y].sub_views[d.seq].sub_view_level,"","","")
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8,p9)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   SET reply->rowlist[row_tot_cnt].celllist[9].string_value = p9
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("br_powerchart_tab.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
