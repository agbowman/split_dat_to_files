CREATE PROGRAM bed_get_fn_tool_icon:dba
 FREE SET reply
 RECORD reply(
   1 ilist[*]
     2 description = vc
     2 action_type = i2
     2 option = i4
     2 icon = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_tcp
 RECORD temp_tcp(
   1 tlist[*]
     2 description = vc
     2 action_type = i2
     2 action = i4
     2 option = i4
     2 icon = i4
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(temp_tcp->tlist,50)
 DECLARE comp_type_code_value = f8 WITH noconstant(0.0), protect
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="FORMASSOC"
  DETAIL
   comp_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE tp_parse = vc
 SET tp_parse = build("cnvtreal(tp.comp_pref) = ",request->trk_group_code_value," and ",
  " tp.comp_type_cd= ",comp_type_code_value,
  " and tp.parent_pref_id = 0.0")
 SELECT INTO "NL:"
  FROM track_prefs tp,
   track_comp_prefs tcp
  PLAN (tp
   WHERE parser(tp_parse))
   JOIN (tcp
   WHERE tcp.track_pref_id=tp.track_pref_id
    AND ((tcp.sub_comp_pref="1*") OR (tcp.sub_comp_pref="2*")) )
  ORDER BY tcp.sub_comp_name
  DETAIL
   action_type = 0, option = 0, icon = 0,
   action_type = cnvtint(substring(1,1,tcp.sub_comp_pref))
   IF (action_type=2)
    end_pos = findstring(";",tcp.sub_comp_pref,3,0), option = cnvtint(substring(3,(end_pos - 3),tcp
      .sub_comp_pref)), beg_pos = (end_pos+ 1),
    beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (beg_pos+ 1), end_pos = size(
     trim(tcp.sub_comp_pref),1)
    IF (end_pos > beg_pos)
     icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref))
    ENDIF
   ELSEIF (action_type=1)
    end_pos = findstring(";",tcp.sub_comp_pref,3,0), option = cnvtint(substring(3,(end_pos - 3),tcp
      .sub_comp_pref)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), action = cnvtint(substring(beg_pos,(
      end_pos - beg_pos),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
    beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (beg_pos+ 1), end_pos = size(
     trim(tcp.sub_comp_pref),1)
    IF (end_pos > beg_pos)
     icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref))
    ENDIF
   ENDIF
   found = 0
   FOR (i = 1 TO tot_count)
     IF ((temp_tcp->tlist[i].option=option)
      AND (temp_tcp->tlist[i].icon=icon))
      found = 1, i = tot_count
     ENDIF
   ENDFOR
   IF (found=0)
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (tot_count > 50)
     stat = alterlist(temp_tcp->tlist,(tot_count+ 50)), count = 1
    ENDIF
    temp_tcp->tlist[tot_count].action_type = action_type, temp_tcp->tlist[tot_count].action = action,
    temp_tcp->tlist[tot_count].option = option,
    temp_tcp->tlist[tot_count].icon = icon
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_tcp->tlist,tot_count)
 IF (tot_count=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = tot_count),
   pm_flx_conversation p,
   pm_flx_task_conv_reltn p2
  PLAN (d)
   JOIN (p
   WHERE (temp_tcp->tlist[d.seq].action_type=1)
    AND p.active_ind=1
    AND (p.action=temp_tcp->tlist[d.seq].action))
   JOIN (p2
   WHERE p2.conversation_id=p.conversation_id
    AND p2.action=p.action
    AND p2.active_ind=1
    AND (p2.task=temp_tcp->tlist[d.seq].option))
  DETAIL
   temp_tcp->tlist[d.seq].description = p.description
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = tot_count),
   dcp_forms_ref dfr
  PLAN (d)
   JOIN (dfr
   WHERE (temp_tcp->tlist[d.seq].action_type=2)
    AND (dfr.dcp_forms_ref_id=temp_tcp->tlist[d.seq].option))
  ORDER BY dfr.description
  DETAIL
   temp_tcp->tlist[d.seq].description = dfr.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->ilist,tot_count)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tot_count)
  DETAIL
   reply->ilist[d.seq].description = temp_tcp->tlist[d.seq].description, reply->ilist[d.seq].
   action_type = temp_tcp->tlist[d.seq].action_type, reply->ilist[d.seq].option = temp_tcp->tlist[d
   .seq].option,
   reply->ilist[d.seq].icon = temp_tcp->tlist[d.seq].icon
  WITH nocounter
 ;end select
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
