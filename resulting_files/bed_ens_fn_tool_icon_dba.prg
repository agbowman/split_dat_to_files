CREATE PROGRAM bed_ens_fn_tool_icon:dba
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
 FREE SET temp_tp
 RECORD temp_tp(
   1 tlist[*]
     2 track_pref_id = f8
 )
 FREE SET temp_tcp
 RECORD temp_tcp(
   1 tlist[*]
     2 track_comp_pref_id = f8
     2 action_type = i2
     2 option = i4
     2 action = i4
     2 visible_ind = i2
     2 icon = i4
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET tp_cnt = 0
 SET tot_tpcnt = 0
 SET tcp_cnt = 0
 SET tot_tcpcnt = 0
 SET beg_pos = 0
 SET end_pos = 0
 SET form_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="FORMASSOC"
  DETAIL
   form_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET group_cnt = size(request->trlist,5)
 SET icon_cnt = size(request->ilist,5)
 IF (group_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM track_prefs tp,
   (dummyt d  WITH seq = group_cnt)
  PLAN (d)
   JOIN (tp
   WHERE tp.comp_type_cd=form_code_value
    AND tp.parent_pref_id=0.0)
  HEAD REPORT
   stat = alterlist(temp_tp->tlist,50)
  DETAIL
   beg_pos = findstring(";",tp.comp_name_unq,1,0), beg_pos = (beg_pos+ 1), end_pos = findstring(" ",
    tp.comp_name_unq,beg_pos,0)
   IF (end_pos > beg_pos)
    trk_code = cnvtreal(substring(beg_pos,((end_pos - beg_pos)+ 1),tp.comp_name_unq))
   ENDIF
   IF ((trk_code=request->trlist[d.seq].code_value))
    tot_tpcnt = (tot_tpcnt+ 1), tp_cnt = (tp_cnt+ 1)
    IF (tp_cnt > 50)
     stat = alterlist(temp_tp->tlist,(tot_tpcnt+ 50)), tp_cnt = 1
    ENDIF
    temp_tp->tlist[tot_tpcnt].track_pref_id = tp.track_pref_id
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_tp->tlist,tot_tpcnt)
  WITH nocounter
 ;end select
 IF (((tot_tpcnt=0) OR (icon_cnt=0)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM track_comp_prefs tcp,
   (dummyt d  WITH seq = tot_tpcnt),
   (dummyt d2  WITH seq = icon_cnt)
  PLAN (d)
   JOIN (d2)
   JOIN (tcp
   WHERE (tcp.track_pref_id=temp_tp->tlist[d.seq].track_pref_id)
    AND tcp.sub_comp_type_cd=form_code_value
    AND tcp.sub_comp_name="Action Id*")
  HEAD REPORT
   stat = alterlist(temp_tcp->tlist,50)
  DETAIL
   action_type = 0, option = 0, icon = 0,
   visible_ind = 0, action_type = cnvtint(substring(1,1,tcp.sub_comp_pref)), end_pos = findstring(";",
    tcp.sub_comp_pref,3,0),
   option = cnvtint(substring(3,(end_pos - 3),tcp.sub_comp_pref))
   IF ((action_type=request->ilist[d2.seq].action_type)
    AND (option=request->ilist[d2.seq].option))
    IF (action_type=2)
     beg_pos = (end_pos+ 1), beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (
     beg_pos+ 1),
     visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)), end_pos = size(trim(tcp
       .sub_comp_pref),1)
     IF (end_pos > beg_pos)
      icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref))
     ENDIF
    ELSEIF (action_type=1)
     beg_pos = (end_pos+ 1), end_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), action = cnvtint(
      substring(beg_pos,(end_pos - beg_pos),tcp.sub_comp_pref)),
     beg_pos = (end_pos+ 1), beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (
     beg_pos+ 1),
     visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)), end_pos = size(trim(tcp
       .sub_comp_pref),1)
     IF (end_pos > beg_pos)
      icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref))
     ENDIF
    ENDIF
    IF ((icon != request->ilist[d2.seq].icon))
     tot_tcpcnt = (tot_tcpcnt+ 1), tcp_cnt = (tcp_cnt+ 1)
     IF (tcp_cnt > 50)
      stat = alterlist(temp_tcp->tlist,(tot_tcpcnt+ 50)), tcp_cnt = 1
     ENDIF
     temp_tcp->tlist[tot_tcpcnt].track_comp_pref_id = tcp.track_pref_comp_id, temp_tcp->tlist[
     tot_tcpcnt].action_type = action_type, temp_tcp->tlist[tot_tcpcnt].option = option,
     temp_tcp->tlist[tot_tcpcnt].action = action, temp_tcp->tlist[tot_tcpcnt].visible_ind =
     visible_ind, temp_tcp->tlist[tot_tcpcnt].icon = request->ilist[d2.seq].icon
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_tcp->tlist,tot_tcpcnt)
  WITH nocounter
 ;end select
 IF (tot_tcpcnt > 0)
  UPDATE  FROM track_comp_prefs tcp,
    (dummyt d  WITH seq = tot_tcpcnt)
   SET tcp.sub_comp_pref =
    IF ((temp_tcp->tlist[d.seq].action_type=1)) concat(trim(cnvtstring(temp_tcp->tlist[d.seq].
        action_type)),";",trim(cnvtstring(temp_tcp->tlist[d.seq].option)),";",trim(cnvtstring(
        temp_tcp->tlist[d.seq].action)),
      ";",trim(cnvtstring(temp_tcp->tlist[d.seq].visible_ind)),";",trim(cnvtstring(temp_tcp->tlist[d
        .seq].icon)))
    ELSEIF ((temp_tcp->tlist[d.seq].action_type=2)) concat(trim(cnvtstring(temp_tcp->tlist[d.seq].
        action_type)),";",trim(cnvtstring(temp_tcp->tlist[d.seq].option)),";",trim(cnvtstring(
        temp_tcp->tlist[d.seq].visible_ind)),
      ";",trim(cnvtstring(temp_tcp->tlist[d.seq].icon)))
    ENDIF
    , tcp.updt_dt_tm = cnvtdatetime(curdate,curtime3), tcp.updt_id = reqinfo->updt_id,
    tcp.updt_applctx = reqinfo->updt_applctx, tcp.updt_cnt = (tcp.updt_cnt+ 1)
   PLAN (d)
    JOIN (tcp
    WHERE (tcp.track_pref_comp_id=temp_tcp->tlist[d.seq].track_comp_pref_id))
   WITH nocounter
  ;end update
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_TOOL_ICON","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
