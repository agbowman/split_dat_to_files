CREATE PROGRAM bed_get_fn_trk_tabs:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 description = vc
     2 action_type = i2
     2 option = i4
     2 action = i4
   1 slist[*]
     2 sequence = i2
     2 description = vc
     2 action_type = i2
     2 option = i4
     2 action = i4
     2 visible_ind = i2
     2 icon = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET acnt = 0
 SET tot_acnt = 0
 SET stat = alterlist(reply->slist,8)
 SET stat = alterlist(reply->alist,50)
 SET comp_type_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.active_ind=1
   AND cv.cdf_meaning="FORMASSOC"
  DETAIL
   comp_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET comp_name_unq = fillstring(50," ")
 SET comp_name_unq = concat(trim(cnvtstring(request->position_code_value)),";",trim(cnvtstring(
    request->trk_group_code_value)))
 SELECT INTO "NL:"
  FROM track_prefs tp,
   track_comp_prefs tcp
  PLAN (tp
   WHERE tp.comp_name=trim(request->trk_group_display)
    AND tp.comp_name_unq=trim(comp_name_unq)
    AND tp.comp_pref=concat(trim(cnvtstring(request->trk_group_code_value)),".000000")
    AND tp.comp_type_cd=comp_type_code_value
    AND tp.parent_pref_id=0.0)
   JOIN (tcp
   WHERE tcp.track_pref_id=tp.track_pref_id)
  ORDER BY tcp.sub_comp_name
  DETAIL
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (tot_count > 50)
    stat = alterlist(reply->slist,(tot_count+ 50)), count = 1
   ENDIF
   reply->slist[tot_count].sequence = tot_count, reply->slist[tot_count].action_type = cnvtint(
    substring(1,1,tcp.sub_comp_pref))
   IF ((reply->slist[tot_count].action_type=2))
    end_pos = findstring(";",tcp.sub_comp_pref,3,0), reply->slist[tot_count].option = cnvtint(
     substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
    beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (beg_pos+ 1), reply->slist[
    tot_count].visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)),
    end_pos = size(trim(tcp.sub_comp_pref),1)
    IF (end_pos > beg_pos)
     reply->slist[tot_count].icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp
       .sub_comp_pref))
    ENDIF
   ELSEIF ((reply->slist[tot_count].action_type=1))
    end_pos = findstring(";",tcp.sub_comp_pref,3,0), reply->slist[tot_count].option = cnvtint(
     substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), reply->slist[tot_count].action = cnvtint(
     substring(beg_pos,(end_pos - beg_pos),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
    beg_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), beg_pos = (beg_pos+ 1), reply->slist[
    tot_count].visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)),
    end_pos = size(trim(tcp.sub_comp_pref),1)
    IF (end_pos > beg_pos)
     reply->slist[tot_count].icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),tcp
       .sub_comp_pref))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,tot_count)
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = tot_count),
   pm_flx_conversation p,
   pm_flx_task_conv_reltn p2
  PLAN (d)
   JOIN (p
   WHERE (reply->slist[d.seq].action_type=1)
    AND p.active_ind=1
    AND ((p.task=117005) OR (((p.task=117006) OR (p.task=117007)) )) )
   JOIN (p2
   WHERE p2.conversation_id=p.conversation_id
    AND p2.active_ind=1
    AND (p2.task=reply->slist[d.seq].option))
  DETAIL
   reply->slist[d.seq].description = p.description
  WITH nocounter
 ;end select
 SELECT INTO "NL"
  FROM (dummyt d  WITH seq = tot_count),
   dcp_forms_ref dfr
  PLAN (d)
   JOIN (dfr
   WHERE (reply->slist[d.seq].action_type=2)
    AND (dfr.dcp_forms_ref_id=reply->slist[d.seq].option))
  ORDER BY dfr.description
  DETAIL
   reply->slist[d.seq].description = dfr.description
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  d.dcp_forms_ref_id, d.updt_dt_tm
  FROM dcp_forms_ref d,
   dummyt d1,
   (dummyt d2  WITH seq = tot_count)
  PLAN (d
   WHERE d.active_ind=1
    AND d.dcp_forms_ref_id > 0)
   JOIN (d1)
   JOIN (d2
   WHERE (reply->slist[d2.seq].option=d.dcp_forms_ref_id))
  ORDER BY d.description
  DETAIL
   acnt = (acnt+ 1), tot_acnt = (tot_acnt+ 1)
   IF (acnt > 50)
    stat = alterlist(reply->alist,(tot_acnt+ 50)), acnt = 1
   ENDIF
   reply->alist[tot_acnt].action_type = 2, reply->alist[tot_acnt].option = d.dcp_forms_ref_id, reply
   ->alist[tot_acnt].description = d.description
  WITH outerjoin = d1, dontexist, nocounter
 ;end select
 SELECT INTO "NL:"
  FROM pm_flx_conversation p,
   pm_flx_task_conv_reltn p2,
   dummyt d1,
   (dummyt d2  WITH seq = tot_count)
  PLAN (p
   WHERE p.active_ind=1
    AND ((p.task=117005) OR (((p.task=117006) OR (p.task=117007)) )) )
   JOIN (p2
   WHERE p2.conversation_id=p.conversation_id
    AND p2.action=p.action
    AND p2.active_ind=1
    AND ((p2.task=4250512) OR (((p2.task=4250510) OR (p2.task=4250511)) )) )
   JOIN (d1)
   JOIN (d2
   WHERE (reply->slist[d2.seq].option=p.task))
  DETAIL
   acnt = (acnt+ 1), tot_acnt = (tot_acnt+ 1)
   IF (acnt > 50)
    stat = alterlist(reply->alist,(tot_acnt+ 50)), acnt = 1
   ENDIF
   reply->alist[tot_acnt].action_type = 1, reply->alist[tot_acnt].option = p.task, reply->alist[
   tot_acnt].description = p.description,
   reply->alist[tot_acnt].action = p.action
  WITH outerjoin = d1, dontexist, nocounter
 ;end select
 SET stat = alterlist(reply->alist,tot_acnt)
#exit_script
 IF (((tot_count > 0) OR (tot_acnt > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
