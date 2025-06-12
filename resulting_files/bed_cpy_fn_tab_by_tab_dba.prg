CREATE PROGRAM bed_cpy_fn_tab_by_tab:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET view_list
 RECORD view_list(
   1 vlist[*]
     2 view_seq = i4
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET to_cnt = size(request->to_positions,5)
 SET tab_cnt = size(request->from_tabs,5)
 SET stat = alterlist(view_list->vlist,20)
 SET vcount = 0
 SET tot_vcount = 0
 IF (tab_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM view_prefs vp,
   name_value_prefs nvp,
   (dummyt d  WITH seq = tab_cnt)
  PLAN (d)
   JOIN (vp
   WHERE (vp.position_cd=request->from_position_code_value)
    AND vp.prsnl_id=0
    AND vp.view_name="TRKLISTVIEW"
    AND vp.frame_type="TRACKLIST"
    AND vp.application_number=4250111)
   JOIN (nvp
   WHERE nvp.parent_entity_id=vp.view_prefs_id
    AND trim(nvp.pvc_name)="VIEW_CAPTION")
  DETAIL
   IF (findstring(request->from_tabs[d.seq].tab_name,nvp.pvc_value))
    vcount = (vcount+ 1), tot_vcount = (tot_vcount+ 1)
    IF (vcount > 20)
     stat = alterlist(view_list->vlist,(tot_vcount+ 20)), vcount = 1
    ENDIF
    view_list->vlist[tot_vcount].view_seq = vp.view_seq
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(view_list->vlist,tot_vcount)
 CALL echorecord(view_list)
 IF (tot_vcount > 0)
  FOR (x = 1 TO to_cnt)
    DELETE  FROM name_value_prefs nvp
     WHERE (nvp.parent_entity_id=
     (SELECT
      vp.view_prefs_id
      FROM view_prefs vp
      WHERE (vp.position_cd=request->to_positions[x].code_value)
       AND vp.prsnl_id=0
       AND vp.frame_type="TRACKLIST"
       AND vp.view_name="TRKLISTVIEW"
       AND vp.application_number=4250111))
     WITH nocounter
    ;end delete
    DELETE  FROM view_prefs vp
     WHERE (vp.position_cd=request->to_positions[x].code_value)
      AND vp.prsnl_id=0
      AND vp.frame_type="TRACKLIST"
      AND vp.view_name="TRKLISTVIEW"
      AND vp.application_number=4250111
     WITH nocounter
    ;end delete
    DELETE  FROM name_value_prefs nvp
     WHERE (nvp.parent_entity_id=
     (SELECT
      vcp.view_comp_prefs_id
      FROM view_comp_prefs vcp
      WHERE (vcp.position_cd=request->to_positions[x].code_value)
       AND vcp.prsnl_id=0
       AND vcp.view_name="TRKLISTVIEW"
       AND vcp.application_number=4250111))
     WITH nocounter
    ;end delete
    DELETE  FROM view_comp_prefs vcp
     WHERE (vcp.position_cd=request->to_positions[x].code_value)
      AND vcp.prsnl_id=0
      AND vcp.view_name="TRKLISTVIEW"
      AND vcp.application_number=4250111
     WITH nocounter
    ;end delete
    DELETE  FROM name_value_prefs nvp
     WHERE (nvp.parent_entity_id=
     (SELECT
      dp.detail_prefs_id
      FROM detail_prefs dp
      WHERE (dp.position_cd=request->to_positions[x].code_value)
       AND dp.prsnl_id=0
       AND dp.person_id=0
       AND dp.view_name="TRKLISTVIEW"
       AND dp.application_number=4250111))
     WITH nocounter
    ;end delete
    DELETE  FROM detail_prefs dp
     WHERE (dp.position_cd=request->to_positions[x].code_value)
      AND dp.prsnl_id=0
      AND dp.person_id=0
      AND dp.view_name="TRKLISTVIEW"
      AND dp.application_number=4250111
     WITH nocounter
    ;end delete
    FOR (i = 1 TO tot_vcount)
      INSERT  FROM detail_prefs
       (detail_prefs_id, application_number, position_cd,
       prsnl_id, person_id, view_name,
       view_seq, comp_name, comp_seq,
       active_ind, updt_cnt, updt_id,
       updt_dt_tm, updt_task, updt_applctx)(SELECT
        seq(carenet_seq,nextval), dp.application_number, request->to_positions[x].code_value,
        dp.prsnl_id, dp.person_id, dp.view_name,
        dp.view_seq, dp.comp_name, dp.comp_seq,
        dp.active_ind, 0, reqinfo->updt_id,
        cnvtdatetime(curdate,curtime3), reqinfo->updt_task, reqinfo->updt_applctx
        FROM detail_prefs dp
        WHERE (dp.position_cd=request->from_position_code_value)
         AND dp.prsnl_id=0
         AND dp.person_id=0
         AND dp.view_name="TRKLISTVIEW"
         AND dp.application_number=4250111
         AND (dp.view_seq=view_list->vlist[i].view_seq))
       WITH nocounter
      ;end insert
      INSERT  FROM name_value_prefs
       (name_value_prefs_id, parent_entity_name, parent_entity_id,
       pvc_name, pvc_value, active_ind,
       updt_applctx, updt_cnt, updt_dt_tm,
       updt_id, updt_task, merge_name,
       merge_id, sequence)(SELECT
        seq(carenet_seq,nextval), nvp.parent_entity_name, dp2.detail_prefs_id,
        nvp.pvc_name, nvp.pvc_value, 1,
        reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
        nvp.merge_id, nvp.sequence
        FROM name_value_prefs nvp,
         detail_prefs dp,
         detail_prefs dp2
        WHERE (dp.position_cd=request->from_position_code_value)
         AND dp.prsnl_id=0
         AND dp.person_id=0
         AND dp.view_name="TRKLISTVIEW"
         AND dp.application_number=4250111
         AND (dp.view_seq=view_list->vlist[i].view_seq)
         AND nvp.active_ind=1
         AND nvp.parent_entity_id=dp.detail_prefs_id
         AND (dp2.position_cd=request->to_positions[x].code_value)
         AND dp2.prsnl_id=0
         AND dp2.person_id=0
         AND dp2.view_name="TRKLISTVIEW"
         AND dp2.application_number=4250111
         AND dp2.view_seq=dp.view_seq)
       WITH nocounter
      ;end insert
      INSERT  FROM view_prefs
       (view_prefs_id, application_number, position_cd,
       prsnl_id, frame_type, view_name,
       view_seq, active_ind, updt_cnt,
       updt_id, updt_dt_tm, updt_task,
       updt_applctx)(SELECT
        seq(carenet_seq,nextval), vp.application_number, request->to_positions[x].code_value,
        vp.prsnl_id, vp.frame_type, vp.view_name,
        vp.view_seq, vp.active_ind, 0,
        reqinfo->updt_id, cnvtdatetime(curdate,curtime3), reqinfo->updt_task,
        reqinfo->updt_applctx
        FROM view_prefs vp
        WHERE (vp.position_cd=request->from_position_code_value)
         AND vp.prsnl_id=0
         AND vp.frame_type="TRACKLIST"
         AND vp.view_name="TRKLISTVIEW"
         AND vp.application_number=4250111
         AND (vp.view_seq=view_list->vlist[i].view_seq))
       WITH nocounter
      ;end insert
      INSERT  FROM name_value_prefs
       (name_value_prefs_id, parent_entity_name, parent_entity_id,
       pvc_name, pvc_value, active_ind,
       updt_applctx, updt_cnt, updt_dt_tm,
       updt_id, updt_task, merge_name,
       merge_id, sequence)(SELECT
        seq(carenet_seq,nextval), nvp.parent_entity_name, vp2.view_prefs_id,
        nvp.pvc_name, nvp.pvc_value, 1,
        reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
        nvp.merge_id, nvp.sequence
        FROM name_value_prefs nvp,
         view_prefs vp,
         view_prefs vp2
        WHERE (vp.position_cd=request->from_position_code_value)
         AND vp.prsnl_id=0
         AND vp.frame_type="TRACKLIST"
         AND vp.view_name="TRKLISTVIEW"
         AND vp.application_number=4250111
         AND (vp.view_seq=view_list->vlist[i].view_seq)
         AND nvp.active_ind=1
         AND nvp.parent_entity_id=vp.view_prefs_id
         AND (vp2.position_cd=request->to_positions[x].code_value)
         AND vp2.prsnl_id=0
         AND vp2.frame_type="TRACKLIST"
         AND vp2.view_name="TRKLISTVIEW"
         AND vp2.application_number=4250111
         AND vp2.view_seq=vp.view_seq)
       WITH nocounter
      ;end insert
      INSERT  FROM view_comp_prefs
       (view_comp_prefs_id, application_number, position_cd,
       prsnl_id, view_name, view_seq,
       comp_name, comp_seq, active_ind,
       updt_cnt, updt_id, updt_dt_tm,
       updt_task, updt_applctx)(SELECT
        seq(carenet_seq,nextval), vcp.application_number, request->to_positions[x].code_value,
        vcp.prsnl_id, vcp.view_name, vcp.view_seq,
        vcp.comp_name, vcp.comp_seq, vcp.active_ind,
        0, reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
        reqinfo->updt_task, reqinfo->updt_applctx
        FROM view_comp_prefs vcp
        WHERE (vcp.position_cd=request->from_position_code_value)
         AND vcp.prsnl_id=0
         AND vcp.view_name="TRKLISTVIEW"
         AND vcp.application_number=4250111
         AND (vcp.view_seq=view_list->vlist[i].view_seq))
       WITH nocounter
      ;end insert
      INSERT  FROM name_value_prefs
       (name_value_prefs_id, parent_entity_name, parent_entity_id,
       pvc_name, pvc_value, active_ind,
       updt_applctx, updt_cnt, updt_dt_tm,
       updt_id, updt_task, merge_name,
       merge_id, sequence)(SELECT
        seq(carenet_seq,nextval), nvp.parent_entity_name, vcp2.view_comp_prefs_id,
        nvp.pvc_name, nvp.pvc_value, 1,
        reqinfo->updt_applctx, 0, cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id, reqinfo->updt_task, nvp.merge_name,
        nvp.merge_id, nvp.sequence
        FROM name_value_prefs nvp,
         view_comp_prefs vcp,
         view_comp_prefs vcp2
        WHERE (vcp.position_cd=request->from_position_code_value)
         AND vcp.prsnl_id=0
         AND vcp.view_name="TRKLISTVIEW"
         AND vcp.application_number=4250111
         AND (vcp.view_seq=view_list->vlist[i].view_seq)
         AND nvp.active_ind=1
         AND nvp.parent_entity_id=vcp.view_comp_prefs_id
         AND (vcp2.position_cd=request->to_positions[x].code_value)
         AND vcp2.prsnl_id=0
         AND vcp2.view_name="TRKLISTVIEW"
         AND vcp2.application_number=4250111
         AND vcp2.view_seq=vcp.view_seq)
       WITH nocounter
      ;end insert
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_CPY_TRK_GROUP","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
