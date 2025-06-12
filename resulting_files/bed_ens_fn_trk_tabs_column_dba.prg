CREATE PROGRAM bed_ens_fn_trk_tabs_column:dba
 FREE SET reply
 RECORD reply(
   1 tabs[*]
     2 name_value_prefs_id = f8
   1 error_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE tab_detail = vc
 DECLARE new_pvc_value = vc
 DECLARE find_list_type = vc
 SET error_flag = "N"
 SET name_value_prefs_id = 0.0
 SET view_comp_prefs_id = 0.0
 SET view_prefs_id = 0.0
 SET detail_prefs_id = 0.0
 SET new_view_seq = 0
 SET list_type_code_value = 0.0
 SET tab_cnt = size(request->tabs,5)
 SET stat = alterlist(reply->tabs,tab_cnt)
 FOR (x = 1 TO tab_cnt)
  IF ((request->tabs[x].action_flag=1))
   SET detail_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     detail_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET new_view_seq = 0
   FOR (i = 1 TO 999)
     SET found = 0
     SELECT INTO "NL:"
      FROM detail_prefs dp
      WHERE (dp.position_cd=request->position_code_value)
       AND dp.view_name="TRKLISTVIEW"
       AND dp.comp_name="CUSTOM"
       AND dp.view_seq=i
      DETAIL
       found = 1
      WITH nocounter
     ;end select
     IF (found=0)
      SET not_found = 1
      SELECT INTO "NL:"
       FROM view_prefs vp
       WHERE (vp.position_cd=request->position_code_value)
        AND vp.frame_type="TRACKLIST"
        AND vp.view_name="TRKLISTVIEW"
        AND vp.view_seq=i
       DETAIL
        not_found = 0
       WITH nocounter
      ;end select
      IF (not_found=1)
       SELECT INTO "NL:"
        FROM view_comp_prefs vcp
        WHERE (vcp.position_cd=request->position_code_value)
         AND vcp.view_name="TRKLISTVIEW"
         AND vcp.comp_name="CUSTOM"
         AND vcp.view_seq=i
        DETAIL
         not_found = 0
        WITH nocounter
       ;end select
      ENDIF
      IF (not_found=1)
       SET new_view_seq = i
       SET i = 1000
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM detail_prefs dp
    SET dp.detail_prefs_id = detail_prefs_id, dp.application_number = 4250111, dp.position_cd =
     request->position_code_value,
     dp.prsnl_id = 0.0, dp.person_id = 0.0, dp.view_name = "TRKLISTVIEW",
     dp.view_seq = new_view_seq, dp.comp_name = "CUSTOM", dp.comp_seq = 1,
     dp.active_ind = 1, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dp.updt_id = reqinfo->updt_id,
     dp.updt_task = reqinfo->updt_task, dp.updt_cnt = 1, dp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert position = ",cnvtstring(request->position_code_value),
     " with view_seq = ",cnvtstring(new_view_seq)," into view_comp_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET reply->tabs[x].name_value_prefs_id = name_value_prefs_id
   SET list_type_code_value = 0.0
   CASE (request->tabs[x].list_type)
    OF "TRKBEDLIST":
     SET find_list_type = "TRKBEDLIST"
    OF "LOCATION":
     SET find_list_type = "TRKPATLIST"
    OF "TRKPRVLIST":
     SET find_list_type = "TRKPRVLIST"
    OF "TRKGROUP":
     SET find_list_type = "TRKPATLIST"
   ENDCASE
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=16629
     AND cv.active_ind=1
     AND cv.cdf_meaning=find_list_type
    DETAIL
     IF (find_list_type != "TRKPATLIST")
      list_type_code_value = cv.code_value
     ELSEIF (find_list_type="TRKPATLIST")
      IF ((((request->tabs[x].list_type="TRKGROUP")
       AND cv.display="*Group*") OR ((request->tabs[x].list_type="LOCATION")
       AND cv.display="*Location*")) )
       list_type_code_value = cv.code_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (list_type_code_value=0)
    SET error_flag = "Y"
    SET error_msg = concat("Invalid list_type ",trim(request->tabs[x].list_type)," for CS16629.")
    GO TO exit_script
   ENDIF
   SET tab_detail = fillstring(256," ")
   IF ((request->tabs[x].list_type="TRKBEDLIST"))
    SET tab_detail = concat(trim(request->tabs[x].list_type),";0,0,0,0,0;")
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].
       location_view_code_value)),";","0;0;0;0;",trim(cnvtstring(list_type_code_value)),
     ";",trim(cnvtstring(request->tabs[x].column_view_id)),";",trim(cnvtstring(request->
       trk_group_code_value)),";")
    IF ((request->tabs[x].refresh_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
      trim(cnvtstring(request->tabs[x].refresh_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].custom_filter_id)),";",
     trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
    IF ((request->tabs[x].scroll_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].scroll_unit)),",",trim
      (cnvtstring(request->tabs[x].scroll_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),"0;0;2003")
   ELSEIF ((request->tabs[x].list_type="LOCATION"))
    SET tab_detail = concat(trim(request->tabs[x].list_type),";0,0,0,0,0")
    SET unit_cd = 0.0
    SET building_cd = 0.0
    SET facility_cd = 0.0
    SELECT INTO "NL:"
     FROM track_group tg,
      location_group l1,
      location_group l2
     PLAN (tg
      WHERE (tg.tracking_group_cd=request->trk_group_code_value)
       AND tg.child_table="TRACK_ASSOC")
      JOIN (l1
      WHERE l1.child_loc_cd=tg.parent_value
       AND l1.active_ind=1
       AND l1.root_loc_cd=0)
      JOIN (l2
      WHERE l2.child_loc_cd=l1.parent_loc_cd
       AND l1.active_ind=1
       AND l1.root_loc_cd=0)
     DETAIL
      unit_cd = tg.parent_value, building_cd = l1.parent_loc_cd, facility_cd = l2.parent_loc_cd
     WITH nocounter
    ;end select
    SET tab_detail = concat(trim(tab_detail),";",trim(cnvtstring(facility_cd)),";",trim(cnvtstring(
       building_cd)),
     ";",trim(cnvtstring(unit_cd)),";0;0;",trim(cnvtstring(list_type_code_value)),";",
     trim(cnvtstring(request->tabs[x].column_view_id)),";",trim(cnvtstring(request->
       trk_group_code_value)),";")
    IF ((request->tabs[x].refresh_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
      trim(cnvtstring(request->tabs[x].refresh_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].custom_filter_id)),";",
     trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
    IF ((request->tabs[x].scroll_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].scroll_unit)),",",trim
      (cnvtstring(request->tabs[x].scroll_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),"0;0;1004")
   ELSEIF ((request->tabs[x].list_type="TRKPRVLIST"))
    SET tab_detail = concat(trim(request->tabs[x].list_type),";","0,0,0,0,0;0;")
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(list_type_code_value)),";",trim(
      cnvtstring(request->tabs[x].column_view_id)),";",
     trim(cnvtstring(request->trk_group_code_value)),";")
    IF ((request->tabs[x].refresh_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
      trim(cnvtstring(request->tabs[x].refresh_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].custom_filter_id)),";",
     trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
    IF ((request->tabs[x].scroll_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].scroll_unit)),",",trim
      (cnvtstring(request->tabs[x].scroll_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),"0;0;8001")
   ELSEIF ((request->tabs[x].list_type="TRKGROUP"))
    SET tab_detail = concat(trim(request->tabs[x].list_type),";0,0,0,0,")
    SET tab_detail = concat(trim(tab_detail),"0,0,0,0;;")
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(list_type_code_value)),";",trim(
      cnvtstring(request->tabs[x].column_view_id)),";",
     trim(cnvtstring(request->trk_group_code_value)),";")
    IF ((request->tabs[x].refresh_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
      trim(cnvtstring(request->tabs[x].refresh_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].custom_filter_id)),";",
     trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
    IF ((request->tabs[x].scroll_time > 0))
     SET tab_detail = concat(trim(tab_detail),trim(cnvtstring(request->tabs[x].scroll_unit)),",",trim
      (cnvtstring(request->tabs[x].scroll_time)),";")
    ELSE
     SET tab_detail = concat(trim(tab_detail),"0;")
    ENDIF
    SET tab_detail = concat(trim(tab_detail),"0;0;3004")
   ENDIF
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "DETAIL_PREFS", nvp
     .parent_entity_id = detail_prefs_id,
     nvp.pvc_name = "TABINFO", nvp.pvc_value = tab_detail, nvp.active_ind = 1,
     nvp.merge_name = " ", nvp.merge_id = 0.0, nvp.sequence = 0.0,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_comp_prefs_id),
     " with pvc_name = COMP_DLLNAME into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     view_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM view_prefs vp
    SET vp.view_prefs_id = view_prefs_id, vp.application_number = 4250111, vp.position_cd = request->
     position_code_value,
     vp.prsnl_id = 0.0, vp.frame_type = "TRACKLIST", vp.view_name = "TRKLISTVIEW",
     vp.view_seq = new_view_seq, vp.active_ind = 1, vp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     vp.updt_id = reqinfo->updt_id, vp.updt_task = reqinfo->updt_task, vp.updt_cnt = 1,
     vp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert position = ",cnvtstring(request->position_code_value),
     " with view_seq = ",cnvtstring(new_view_seq)," into view_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
     .parent_entity_id = view_prefs_id,
     nvp.pvc_name = "VIEW_IND", nvp.pvc_value = "0", nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_prefs_id),
     " with pvc_name = VIEW_IND into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
     .parent_entity_id = view_prefs_id,
     nvp.pvc_name = "VIEW_CAPTION", nvp.pvc_value = request->tabs[x].name, nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_prefs_id),
     " with pvc_name = VIEW_CAPTION into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET pvc_value = cnvtstring(request->tabs[x].tab_sequence,3,0,r)
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
     .parent_entity_id = view_prefs_id,
     nvp.pvc_name = "DISPLAY_SEQ", nvp.pvc_value = pvc_value, nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_prefs_id),
     " with pvc_name = DISPLAY_SEQ into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
     .parent_entity_id = view_prefs_id,
     nvp.pvc_name = "DLL_NAME", nvp.pvc_value = "PVTRACKLIST", nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_prefs_id),
     " with pvc_name = DLL_NAME into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_PREFS", nvp
     .parent_entity_id = view_prefs_id,
     nvp.pvc_name = "WWWFLAG", nvp.pvc_value = "1", nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_prefs_id),
     " with pvc_name = WWWFLAG into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET view_comp_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     view_comp_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM view_comp_prefs vcp
    SET vcp.view_comp_prefs_id = view_comp_prefs_id, vcp.application_number = 4250111, vcp
     .position_cd = request->position_code_value,
     vcp.prsnl_id = 0.0, vcp.view_name = "TRKLISTVIEW", vcp.view_seq = new_view_seq,
     vcp.comp_name = "CUSTOM", vcp.comp_seq = 1, vcp.active_ind = 1,
     vcp.updt_dt_tm = cnvtdatetime(curdate,curtime3), vcp.updt_id = reqinfo->updt_id, vcp.updt_task
      = reqinfo->updt_task,
     vcp.updt_cnt = 1, vcp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert position = ",cnvtstring(request->position_code_value),
     " with view_seq = ",cnvtstring(new_view_seq)," into view_comp_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_COMP_PREFS",
     nvp.parent_entity_id = view_comp_prefs_id,
     nvp.pvc_name = "COMP_POS", nvp.pvc_value = "0,0,3,4", nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_comp_prefs_id),
     " with pvc_name = COMP_POS into name_value_prefs table.")
    GO TO exit_script
   ENDIF
   SET name_value_prefs_id = 0.0
   SELECT INTO "NL:"
    j = seq(carenet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     name_value_prefs_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = name_value_prefs_id, nvp.parent_entity_name = "VIEW_COMP_PREFS",
     nvp.parent_entity_id = view_comp_prefs_id,
     nvp.pvc_name = "COMP_DLLNAME", nvp.pvc_value = "PVTRACKLIST", nvp.active_ind = 1,
     nvp.merge_name = null, nvp.merge_id = 0.0, nvp.sequence = null,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_cnt = 1, nvp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_entity_id ",cnvtstring(view_comp_prefs_id),
     " with pvc_name = COMP_DLLNAME into name_value_prefs table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->tabs[x].action_flag=2))
   SET reply->tabs[x].name_value_prefs_id = request->tabs[x].name_value_prefs_id
   SET new_pvc_value = fillstring(256," ")
   SELECT INTO "NL:"
    FROM name_value_prefs nvp
    WHERE (nvp.name_value_prefs_id=request->tabs[x].name_value_prefs_id)
    DETAIL
     IF (nvp.pvc_value="TRKBEDLIST*")
      beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(end_pos - 1),
       nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_view_cd = cnvtreal(substring(beg_pos,(
        end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos), new_pvc_value = concat(trim(new_pvc_value),";",
       trim(cnvtstring(bed_view_cd)),";0;0;0;0;"), beg_pos = (beg_pos+ 8),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd = cnvtreal(substring(beg_pos,(
        end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id = cnvtreal(substring(beg_pos,
        (end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd = cnvtreal(substring(beg_pos,
        (end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate = substring(beg_pos,(end_pos -
       beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(substring(beg_pos,(
        end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd = cnvtreal(substring(
        beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate = substring(beg_pos,(end_pos -
       beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd = cnvtreal(substring(beg_pos,
        (end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd = cnvtreal(substring(
        beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(" ",nvp.pvc_value,beg_pos,0), dnbr = cnvtint(substring(beg_pos,(end_pos -
        beg_pos),nvp.pvc_value)), new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(
         list_type_cd)),";",trim(cnvtstring(request->tabs[x].column_view_id)),";",
       trim(cnvtstring(request->trk_group_code_value)),";")
      IF ((request->tabs[x].refresh_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
        trim(cnvtstring(request->tabs[x].refresh_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].custom_filter_id)),
       ";",trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
      IF ((request->tabs[x].scroll_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].scroll_unit)),",",
        trim(cnvtstring(request->tabs[x].scroll_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(loc_security_cd)),";",trim(
        cnvtstring(edit_security_cd)),";",
       trim(cnvtstring(dnbr)))
     ELSEIF (nvp.pvc_value="LOCATION*")
      beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(end_pos - 1),
       nvp.pvc_value), facility_cd = 0.0,
      building_cd = 0.0, unit_cd = 0.0, room_cd = 0.0,
      bed_cd = 0.0, beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos),
      facility_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos),
      building_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos),
      unit_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1
      ), end_pos = findstring(";",nvp.pvc_value,beg_pos),
      room_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1
      ), end_pos = findstring(";",nvp.pvc_value,beg_pos),
      bed_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      list_type_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      column_view_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      track_group_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      refresh_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      filter_id = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos
      + 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      location_view_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      scroll_rate = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      loc_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0),
      edit_security_cd = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
      end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0),
      dnbr = cnvtint(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), new_pvc_value = concat(
       trim(new_pvc_value),";",trim(cnvtstring(facility_cd)),";",trim(cnvtstring(building_cd)),
       ";",trim(cnvtstring(unit_cd)),";",trim(cnvtstring(room_cd)),";",
       trim(cnvtstring(bed_cd)),";"), new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(
         list_type_cd)),";",trim(cnvtstring(request->tabs[x].column_view_id)),";",
       trim(cnvtstring(request->trk_group_code_value)),";")
      IF ((request->tabs[x].refresh_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
        trim(cnvtstring(request->tabs[x].refresh_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].custom_filter_id)),
       ";",trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
      IF ((request->tabs[x].scroll_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].scroll_unit)),",",
        trim(cnvtstring(request->tabs[x].scroll_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(loc_security_cd)),";",trim(
        cnvtstring(edit_security_cd)),";",
       trim(cnvtstring(dnbr)))
     ELSEIF (nvp.pvc_value="TRKPRVLIST*")
      beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(end_pos - 1),
       nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(beg_pos,(end_pos - beg_pos),
       nvp.pvc_value), new_pvc_value = concat(trim(new_pvc_value),";",trim(temp)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
      substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal
      (substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
      substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0), dnbr = cnvtint(
       substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      new_pvc_value = concat(trim(new_pvc_value),";",trim(cnvtstring(list_type_cd)),";",trim(
        cnvtstring(request->tabs[x].column_view_id)),
       ";",trim(cnvtstring(request->trk_group_code_value)),";")
      IF ((request->tabs[x].refresh_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
        trim(cnvtstring(request->tabs[x].refresh_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].custom_filter_id)),
       ";",trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
      IF ((request->tabs[x].scroll_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].scroll_unit)),",",
        trim(cnvtstring(request->tabs[x].scroll_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(loc_security_cd)),";",trim(
        cnvtstring(edit_security_cd)),";",
       trim(cnvtstring(dnbr)))
     ELSEIF (nvp.pvc_value="TRKGROUP*")
      beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), new_pvc_value = substring(1,(end_pos - 1),
       nvp.pvc_value), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(beg_pos,(end_pos - beg_pos),
       nvp.pvc_value), new_pvc_value = concat(trim(new_pvc_value),";",trim(temp)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
      substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal
      (substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
      substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
      cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      beg_pos = (end_pos+ 1), end_pos = findstring(" ",nvp.pvc_value,beg_pos,0), dnbr = cnvtint(
       substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
      new_pvc_value = concat(trim(new_pvc_value),";",trim(cnvtstring(list_type_cd)),";",trim(
        cnvtstring(request->tabs[x].column_view_id)),
       ";",trim(cnvtstring(request->trk_group_code_value)),";")
      IF ((request->tabs[x].refresh_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].refresh_unit)),",",
        trim(cnvtstring(request->tabs[x].refresh_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].custom_filter_id)),
       ";",trim(cnvtstring(request->tabs[x].location_view_code_value)),";")
      IF ((request->tabs[x].scroll_time > 0))
       new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(request->tabs[x].scroll_unit)),",",
        trim(cnvtstring(request->tabs[x].scroll_time)),";")
      ELSE
       new_pvc_value = concat(trim(new_pvc_value),"0;")
      ENDIF
      new_pvc_value = concat(trim(new_pvc_value),trim(cnvtstring(loc_security_cd)),";",trim(
        cnvtstring(edit_security_cd)),";",
       trim(cnvtstring(dnbr)))
     ENDIF
    WITH nocounter
   ;end select
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = new_pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id
      = reqinfo->updt_id,
     nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (nvp.name_value_prefs_id=request->tabs[x].name_value_prefs_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update name_value_prefs for ",cnvtstring(request->tabs[x].
      name_value_prefs_id))
    GO TO exit_script
   ENDIF
  ELSEIF ((request->tabs[x].action_flag=3))
   SET reply->tabs[x].name_value_prefs_id = request->tabs[x].name_value_prefs_id
   SET detail_prefs_id = 0.0
   SET dp_view_seq = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE (nvp.name_value_prefs_id=request->tabs[x].name_value_prefs_id))
     JOIN (dp
     WHERE dp.detail_prefs_id=nvp.parent_entity_id)
    DETAIL
     detail_prefs_id = nvp.parent_entity_id, dp_view_seq = dp.view_seq
    WITH nocounter
   ;end select
   DELETE  FROM detail_prefs dp
    WHERE dp.detail_prefs_id=detail_prefs_id
    WITH nocounter
   ;end delete
   DELETE  FROM name_value_prefs nvp
    WHERE (nvp.name_value_prefs_id=request->tabs[x].name_value_prefs_id)
    WITH nocounter
   ;end delete
   SET view_prefs_id = 0.0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE vp.application_number=4250111
     AND (vp.position_cd=request->position_code_value)
     AND vp.frame_type="TRACKLIST"
     AND vp.view_name="TRKLISTVIEW"
     AND vp.view_seq=dp_view_seq
    DETAIL
     view_prefs_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   DELETE  FROM view_prefs vp
    WHERE vp.view_prefs_id=view_prefs_id
    WITH nocounter
   ;end delete
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.parent_entity_id=view_prefs_id
    WITH nocounter
   ;end delete
   SET view_comp_prefs_id = 0.0
   SELECT INTO "NL:"
    FROM view_comp_prefs vcp
    WHERE vcp.application_number=4250111
     AND (vcp.position_cd=request->position_code_value)
     AND vcp.comp_name="CUSTOM"
     AND vcp.view_name="TRKLISTVIEW"
     AND vcp.view_seq=dp_view_seq
    DETAIL
     view_comp_prefs_id = vcp.view_comp_prefs_id
    WITH nocounter
   ;end select
   DELETE  FROM view_comp_prefs vcp
    WHERE vcp.view_comp_prefs_id=view_comp_prefs_id
    WITH nocounter
   ;end delete
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
     AND nvp.parent_entity_id=view_comp_prefs_id
    WITH nocounter
   ;end delete
  ELSEIF ((request->tabs[x].action_flag=0))
   SET reply->tabs[x].name_value_prefs_id = request->tabs[x].name_value_prefs_id
  ENDIF
  IF ((request->tabs[x].tab_info.action_flag=2)
   AND (((request->tabs[x].action_flag=0)) OR ((request->tabs[x].action_flag=2))) )
   SET detail_prefs_id = 0.0
   SET dp_view_seq = 0
   SELECT INTO "NL:"
    FROM name_value_prefs nvp,
     detail_prefs dp
    PLAN (nvp
     WHERE (nvp.name_value_prefs_id=request->tabs[x].name_value_prefs_id))
     JOIN (dp
     WHERE dp.detail_prefs_id=nvp.parent_entity_id)
    DETAIL
     detail_prefs_id = nvp.parent_entity_id, dp_view_seq = dp.view_seq
    WITH nocounter
   ;end select
   SET view_prefs_id = 0.0
   SELECT INTO "NL:"
    FROM view_prefs vp
    WHERE vp.application_number=4250111
     AND (vp.position_cd=request->position_code_value)
     AND vp.frame_type="TRACKLIST"
     AND vp.view_name="TRKLISTVIEW"
     AND vp.view_seq=dp_view_seq
    DETAIL
     view_prefs_id = vp.view_prefs_id
    WITH nocounter
   ;end select
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = request->tabs[x].name, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp
     .updt_id = reqinfo->updt_id,
     nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx = reqinfo
     ->updt_applctx
    WHERE nvp.parent_entity_id=view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.pvc_name="VIEW_CAPTION"
     AND (nvp.pvc_value != request->tabs[x].name)
    WITH nocounter
   ;end update
   SET pvc_value = cnvtstring(request->tabs[x].tab_sequence,3,0,r)
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id =
     reqinfo->updt_id,
     nvp.updt_task = reqinfo->updt_task, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_applctx = reqinfo
     ->updt_applctx
    WHERE nvp.parent_entity_id=view_prefs_id
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.pvc_name="DISPLAY_SEQ"
     AND nvp.pvc_value != pvc_value
    WITH nocounter
   ;end update
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
