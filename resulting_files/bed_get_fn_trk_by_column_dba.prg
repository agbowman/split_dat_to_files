CREATE PROGRAM bed_get_fn_trk_by_column:dba
 FREE SET reply
 RECORD reply(
   1 column_views[*]
     2 id = f8
     2 name = vc
     2 tabs[*]
       3 tab_name = vc
       3 name_value_prefs_id = f8
       3 positions[*]
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_view
 RECORD temp_view(
   1 vlist[*]
     2 id = f8
     2 name = vc
     2 active_ind = i2
     2 tabs[*]
       3 name_value_prefs_id = f8
       3 view_prefs_id = f8
       3 position_cd = f8
 )
 SET reply->status_data.status = "F"
 SET col_count = 0
 SET tot_col_count = 0
 SET tot_tcount = 0
 SET tot_count = 0
 SET dcount = 0
 SET rcount = 0
 SET tot_rcount = 0
 SET ccount = 0
 SET pos_cnt = 0
 SET tab_cnt = 0
 DECLARE search_string = vc
 SET search_string = build('"*',trim(cnvtstring(request->column_id,20,0)),'*"')
 DECLARE nvp_parse = vc
 SET nvp_parse = concat("nvp.active_ind = 1 and nvp.parent_entity_name = 'PREDEFINED_PREFS' and ",
  "nvp.pvc_name = 'Colinfo*' and nvp.pvc_value = ",search_string)
 SELECT INTO "NL:"
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE parser(nvp_parse))
  ORDER BY nvp.parent_entity_id
  HEAD REPORT
   stat = alterlist(temp_view->vlist,10)
  HEAD nvp.parent_entity_id
   col_count = (col_count+ 1), tot_col_count = (tot_col_count+ 1)
   IF (col_count > 10)
    stat = alterlist(temp_view->vlist,(tot_col_count+ 10)), col_count = 1
   ENDIF
   temp_view->vlist[tot_col_count].id = nvp.parent_entity_id
  FOOT REPORT
   stat = alterlist(temp_view->vlist,tot_col_count)
  WITH nocounter
 ;end select
 IF (tot_col_count=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tot_col_count),
   predefined_prefs p
  PLAN (d)
   JOIN (p
   WHERE (p.predefined_prefs_id=temp_view->vlist[d.seq].id))
  DETAIL
   temp_view->vlist[d.seq].name = p.name, temp_view->vlist[d.seq].active_ind = p.active_ind
  WITH nocounter
 ;end select
 FOR (i = 1 TO tot_col_count)
  IF ((temp_view->vlist[i].active_ind=1))
   DECLARE tabinfo = vc
   SET tabinfo = build('"*',trim(cnvtstring(temp_view->vlist[i].id,20,0)),"*",trim(cnvtstring(request
      ->trk_group_code_value,20,0)),'*"')
   DECLARE nvp_parse = vc
   SET nvp_parse = concat("nvp.active_ind = 1 and nvp.parent_entity_name = 'DETAIL_PREFS' and ",
    "nvp.pvc_name = 'TABINFO' and nvp.pvc_value = ",tabinfo)
   SELECT INTO "NL:"
    FROM name_value_prefs nvp,
     detail_prefs dp,
     view_prefs vp
    PLAN (nvp
     WHERE parser(nvp_parse))
     JOIN (dp
     WHERE dp.detail_prefs_id=nvp.parent_entity_id
      AND dp.prsnl_id=0)
     JOIN (vp
     WHERE vp.application_number=4250111
      AND vp.position_cd=dp.position_cd
      AND vp.view_seq=dp.view_seq
      AND vp.active_ind=1
      AND vp.frame_type="TRACKLIST"
      AND vp.view_name="TRKLISTVIEW"
      AND vp.view_seq=dp.view_seq
      AND vp.position_cd=dp.position_cd
      AND vp.prsnl_id=0)
    ORDER BY nvp.parent_entity_id, dp.position_cd, vp.position_cd
    HEAD REPORT
     tcount = 0, tot_tcount = 0, stat = alterlist(temp_view->vlist[i].tabs,10)
    HEAD nvp.parent_entity_id
     tcount = (tcount+ 1), tot_tcount = (tot_tcount+ 1)
     IF (tcount > 10)
      stat = alterlist(temp_view->vlist[i].tabs,(tot_tcount+ 10)), tcount = 1
     ENDIF
     temp_view->vlist[i].tabs[tot_tcount].name_value_prefs_id = nvp.name_value_prefs_id
    HEAD dp.position_cd
     temp_view->vlist[i].tabs[tot_tcount].position_cd = dp.position_cd
    HEAD vp.position_cd
     temp_view->vlist[i].tabs[tot_tcount].view_prefs_id = vp.view_prefs_id
    FOOT REPORT
     stat = alterlist(temp_view->vlist[i].tabs,tot_tcount)
    WITH nocounter
   ;end select
  ENDIF
  IF (tot_tcount > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = tot_tcount),
     name_value_prefs nvp
    PLAN (d)
     JOIN (nvp
     WHERE nvp.active_ind=1
      AND nvp.pvc_name="VIEW_CAPTION"
      AND (nvp.parent_entity_id=temp_view->vlist[i].tabs[d.seq].view_prefs_id))
    ORDER BY d.seq
    HEAD REPORT
     ccount = (ccount+ 1), stat = alterlist(reply->column_views,ccount), reply->column_views[ccount].
     id = temp_view->vlist[i].id,
     reply->column_views[ccount].name = temp_view->vlist[i].name, stat = alterlist(reply->
      column_views[ccount].tabs,20), rcount = 0,
     tot_rcount = 0, pos_cnt = 0
    HEAD d.seq
     found = 0, tab_cnt = 0
     FOR (z = 1 TO tot_rcount)
       IF ((reply->column_views[ccount].tabs[z].tab_name=nvp.pvc_value))
        found = 1, tab_cnt = z, z = tot_rcount
       ENDIF
     ENDFOR
     IF (found=0)
      rcount = (rcount+ 1), tot_rcount = (tot_rcount+ 1)
      IF (rcount > 20)
       stat = alterlist(reply->column_views[ccount].tabs,(tot_rcount+ 20)), rcount = 1
      ENDIF
      tab_cnt = tot_rcount, reply->column_views[ccount].tabs[tab_cnt].tab_name = nvp.pvc_value, reply
      ->column_views[ccount].tabs[tab_cnt].name_value_prefs_id = temp_view->vlist[i].tabs[d.seq].
      name_value_prefs_id
     ENDIF
    DETAIL
     found = 0, pos_cnt = size(reply->column_views[ccount].tabs[tab_cnt].positions,5)
     FOR (p = 1 TO pos_cnt)
       IF ((reply->column_views[ccount].tabs[tab_cnt].positions[p].code_value=temp_view->vlist[i].
       tabs[d.seq].position_cd))
        found = 1, p = pos_cnt
       ENDIF
     ENDFOR
     IF (found=0)
      pos_cnt = size(reply->column_views[ccount].tabs[tab_cnt].positions,5), pos_cnt = (pos_cnt+ 1),
      stat = alterlist(reply->column_views[ccount].tabs[tab_cnt].positions,pos_cnt),
      reply->column_views[ccount].tabs[tab_cnt].positions[pos_cnt].code_value = temp_view->vlist[i].
      tabs[d.seq].position_cd
      IF ((reply->column_views[ccount].tabs[tab_cnt].positions[pos_cnt].code_value=0))
       reply->column_views[ccount].tabs[tab_cnt].positions[pos_cnt].display = "ALL"
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->column_views[ccount].tabs,tab_cnt)
    WITH nocounter
   ;end select
   FOR (x = 1 TO tab_cnt)
    SET pos_cnt = size(reply->column_views[ccount].tabs[x].positions,5)
    IF (pos_cnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = pos_cnt),
       code_value cv
      PLAN (d
       WHERE (reply->column_views[ccount].tabs[x].positions[d.seq].code_value > 0))
       JOIN (cv
       WHERE cv.code_set=88
        AND (cv.code_value=reply->column_views[ccount].tabs[x].positions[d.seq].code_value))
      DETAIL
       reply->column_views[ccount].tabs[x].positions[d.seq].display = cv.display
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (tot_col_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
