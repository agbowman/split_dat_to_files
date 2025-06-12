CREATE PROGRAM bed_get_pref_frames_multi:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 frames[*]
      2 frame_name = vc
      2 positions[*]
        3 code_value = f8
        3 is_global = i2
        3 views[*]
          4 view_prefs_id = f8
          4 view_name = vc
          4 view_caption = vc
          4 view_seq = i4
          4 display_seq
            5 pvc_value = vc
            5 nvp_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_reply
 RECORD temp_reply(
   1 frames[*]
     2 frame_name = vc
     2 positions[*]
       3 code_value = f8
       3 is_global = i2
       3 views[*]
         4 view_prefs_id = f8
         4 view_name = vc
         4 view_caption = vc
         4 view_seq = i4
         4 display_seq
           5 pvc_value = vc
           5 nvp_id = f8
 )
 FREE SET temp_positions
 RECORD temp_positions(
   1 positions[*]
     2 code_value = f8
     2 is_global = f8
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 IF ( NOT (validate(request,0)))
  CALL error("No Request")
 ENDIF
 IF ((request->application_number=0))
  CALL error("No application number")
 ENDIF
 SET frame_count = size(request->frames,5)
 IF (frame_count < 1)
  CALL error("No frames requested")
 ENDIF
 SET position_count = size(request->positions,5)
 IF (position_count < 1)
  CALL error("No positions requested")
 ENDIF
 SET stat = alterlist(temp_positions->positions,position_count)
 FOR (x = 1 TO position_count)
  SET temp_positions->positions[x].code_value = request->positions[x].code_value
  SET temp_positions->positions[x].is_global = 1
 ENDFOR
 SET non_global_position_count = 0
 SELECT INTO "nl:"
  FROM view_prefs v,
   (dummyt d  WITH seq = value(position_count))
  PLAN (d)
   JOIN (v
   WHERE (v.application_number=request->application_number)
    AND (v.position_cd=temp_positions->positions[d.seq].code_value)
    AND v.prsnl_id=0.0
    AND v.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   non_global_position_count = (non_global_position_count+ 1), temp_positions->positions[d.seq].
   is_global = 0
  WITH nocounter
 ;end select
 IF (non_global_position_count != position_count)
  SET position_count = (position_count+ 1)
  SET stat = alterlist(temp_positions->positions,position_count)
 ENDIF
 SET stat = alterlist(temp_reply->frames,frame_count)
 FOR (f = 1 TO frame_count)
   SET temp_reply->frames[f].frame_name = request->frames[f].frame_name
   SET stat = alterlist(temp_reply->frames[f].positions,position_count)
   FOR (p = 1 TO position_count)
    SET temp_reply->frames[f].positions[p].code_value = temp_positions->positions[p].code_value
    SET temp_reply->frames[f].positions[p].is_global = temp_positions->positions[p].is_global
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM view_prefs vp,
   name_value_prefs nvp,
   name_value_prefs nvp2,
   (dummyt d_frame  WITH seq = value(frame_count)),
   (dummyt d_pos  WITH seq = 1)
  PLAN (d_frame
   WHERE maxrec(d_pos,size(temp_reply->frames[d_frame.seq].positions,5)))
   JOIN (d_pos
   WHERE (temp_reply->frames[d_frame.seq].positions[d_pos.seq].is_global=0))
   JOIN (vp
   WHERE (vp.application_number=request->application_number)
    AND (vp.position_cd=temp_reply->frames[d_frame.seq].positions[d_pos.seq].code_value)
    AND vp.active_ind=1
    AND (vp.frame_type=temp_reply->frames[d_frame.seq].frame_name)
    AND vp.prsnl_id=0.0)
   JOIN (nvp
   WHERE nvp.parent_entity_name=outerjoin("VIEW_PREFS")
    AND nvp.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND trim(nvp.pvc_name)=outerjoin("VIEW_CAPTION"))
   JOIN (nvp2
   WHERE nvp2.parent_entity_name=outerjoin("VIEW_PREFS")
    AND nvp2.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND trim(nvp2.pvc_name)=outerjoin("DISPLAY_SEQ"))
  ORDER BY d_frame.seq, d_pos.seq
  HEAD d_frame.seq
   view_count = 0
  HEAD d_pos.seq
   view_count = 0, stat = alterlist(temp_reply->frames[d_frame.seq].positions[d_pos.seq].views,10)
  DETAIL
   view_count = (view_count+ 1)
   IF (mod(view_count,10)=0)
    stat = alterlist(temp_reply->frames[d_frame.seq].positions[d_pos.seq].views,(view_count+ 10))
   ENDIF
   temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[view_count].view_prefs_id = vp
   .view_prefs_id, temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[view_count].view_name
    = vp.view_name, temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[view_count].
   display_seq.pvc_value = nvp2.pvc_value,
   temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[view_count].display_seq.nvp_id = nvp2
   .name_value_prefs_id, temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[view_count].
   view_caption = nvp.pvc_value, temp_reply->frames[d_frame.seq].positions[d_pos.seq].views[
   view_count].view_seq = vp.view_seq
  FOOT  d_pos.seq
   stat = alterlist(temp_reply->frames[d_frame.seq].positions[d_pos.seq].views,view_count)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->frames,frame_count)
 FOR (f = 1 TO frame_count)
   SET reply->frames[f].frame_name = temp_reply->frames[f].frame_name
   SET pos_count = 0
   FOR (p = 1 TO position_count)
    SET view_size = size(temp_reply->frames[f].positions[p].views,5)
    IF ((temp_reply->frames[f].positions[p].code_value > 0))
     IF ((temp_reply->frames[f].positions[p].is_global=0))
      CALL copy_from_temp(f,p,p)
     ELSE
      CALL copy_from_temp(f,p,position_count)
     ENDIF
    ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE copy_from_temp(f,copy_to,copy_from)
  SET num_views = size(temp_reply->frames[f].positions[copy_from].views,5)
  IF (num_views > 0)
   SET pos_count = (pos_count+ 1)
   SET stat = alterlist(reply->frames[f].positions,pos_count)
   SET reply->frames[f].positions[pos_count].code_value = temp_reply->frames[f].positions[copy_to].
   code_value
   SET reply->frames[f].positions[pos_count].is_global = temp_reply->frames[f].positions[copy_to].
   is_global
   SET stat = alterlist(reply->frames[f].positions[pos_count].views,num_views)
   FOR (v = 1 TO num_views)
     SET reply->frames[f].positions[pos_count].views[v].view_prefs_id = temp_reply->frames[f].
     positions[copy_from].views[v].view_prefs_id
     SET reply->frames[f].positions[pos_count].views[v].view_name = temp_reply->frames[f].positions[
     copy_from].views[v].view_name
     SET reply->frames[f].positions[pos_count].views[v].display_seq.pvc_value = temp_reply->frames[f]
     .positions[copy_from].views[v].display_seq.pvc_value
     SET reply->frames[f].positions[pos_count].views[v].display_seq.nvp_id = temp_reply->frames[f].
     positions[copy_from].views[v].display_seq.nvp_id
     SET reply->frames[f].positions[pos_count].views[v].view_caption = temp_reply->frames[f].
     positions[copy_from].views[v].view_caption
     SET reply->frames[f].positions[pos_count].views[v].view_seq = temp_reply->frames[f].positions[
     copy_from].views[v].view_seq
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE error(string)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(string)
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
