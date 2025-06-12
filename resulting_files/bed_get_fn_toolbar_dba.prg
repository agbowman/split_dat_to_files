CREATE PROGRAM bed_get_fn_toolbar:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 description = vc
     2 action_type = i2
     2 option = i4
     2 action = i4
   1 plist[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 slist[*]
       3 sequence = i2
       3 description = vc
       3 action_type = i2
       3 option = i4
       3 action = i4
       3 visible_ind = i2
       3 icon = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET track_pref
 RECORD track_pref(
   1 cnu_list[*]
     2 unique_comp = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET acnt = 0
 SET tot_acnt = 0
 SET stat = alterlist(reply->alist,50)
 SET pcount = 0
 SET ptot_count = 0
 SET stat = alterlist(reply->plist,50)
 SET tptot_count = 0
 SET tpcount = 0
 SET stat = alterlist(track_pref->cnu_list,50)
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
 SELECT DISTINCT INTO "NL:"
  FROM dcp_forms_ref d
  PLAN (d
   WHERE d.active_ind=1
    AND d.dcp_forms_ref_id > 0)
  ORDER BY d.description
  DETAIL
   acnt = (acnt+ 1), tot_acnt = (tot_acnt+ 1)
   IF (acnt > 50)
    stat = alterlist(reply->alist,(tot_acnt+ 50)), acnt = 1
   ENDIF
   reply->alist[tot_acnt].action_type = 2, reply->alist[tot_acnt].option = d.dcp_forms_ref_id, reply
   ->alist[tot_acnt].description = d.description
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM pm_flx_conversation p,
   pm_flx_task_conv_reltn p2
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (p2
   WHERE p2.conversation_id=p.conversation_id
    AND p2.action=p.action
    AND p2.active_ind=1
    AND p2.task >= 4250510
    AND p2.task <= 4250517)
  ORDER BY p.description, p2.task
  DETAIL
   acnt = (acnt+ 1), tot_acnt = (tot_acnt+ 1)
   IF (acnt > 50)
    stat = alterlist(reply->alist,(tot_acnt+ 50)), acnt = 1
   ENDIF
   reply->alist[tot_acnt].action_type = 1, reply->alist[tot_acnt].option = p2.task, reply->alist[
   tot_acnt].description = p.description,
   reply->alist[tot_acnt].action = p.action
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->alist,tot_acnt)
 SET tot_acnt = (tot_acnt+ 1)
 SET stat = alterlist(reply->alist,tot_acnt)
 SET reply->alist[tot_acnt].action_type = 3
 SET reply->alist[tot_acnt].option = 0.0
 SET reply->alist[tot_acnt].description = "Pre-Arrival Form"
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=88
   AND cv.active_ind=1
  DETAIL
   tpcount = (tpcount+ 1), tptot_count = (tptot_count+ 1)
   IF (tpcount > 50)
    stat = alterlist(track_pref->cnu_list,(tptot_count+ 50)), trcount = 1
   ENDIF
   track_pref->cnu_list[tptot_count].unique_comp = build(trim(cnvtstring(cv.code_value,20,0)),";",
    trim(cnvtstring(request->trk_group_code_value,20,0))), pcount = (pcount+ 1), ptot_count = (
   ptot_count+ 1)
   IF (pcount > 50)
    stat = alterlist(reply->plist,(ptot_count+ 50)), pcount = 1
   ENDIF
   reply->plist[ptot_count].description = cv.description, reply->plist[ptot_count].display = cv
   .display, reply->plist[ptot_count].code_value = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->plist,ptot_count)
 DECLARE tp_parse = vc
 SET tp_parse = build('tp.comp_pref = "',trim(cnvtstring(request->trk_group_code_value,20,0)),
  '*" and '," tp.comp_type_cd= ",comp_type_code_value,
  " and tp.parent_pref_id = 0.0")
 IF (tptot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tptot_count),
    track_prefs tp,
    track_comp_prefs tcp
   PLAN (d)
    JOIN (tp
    WHERE parser(tp_parse)
     AND (tp.comp_name_unq=track_pref->cnu_list[d.seq].unique_comp))
    JOIN (tcp
    WHERE tcp.track_pref_id=tp.track_pref_id)
   ORDER BY d.seq, tcp.track_pref_id
   HEAD d.seq
    stat = alterlist(reply->plist[d.seq].slist,50), tot_count = 0
   DETAIL
    action_type = cnvtint(substring(1,1,tcp.sub_comp_pref))
    IF (((action_type=1) OR (((action_type=2) OR (action_type=3)) )) )
     tot_count = (tot_count+ 1), reply->plist[d.seq].slist[tot_count].sequence = tot_count, reply->
     plist[d.seq].slist[tot_count].action_type = cnvtint(substring(1,1,tcp.sub_comp_pref))
     IF ((reply->plist[d.seq].slist[tot_count].action_type=2))
      end_pos = findstring(";",tcp.sub_comp_pref,3,0), reply->plist[d.seq].slist[tot_count].option =
      cnvtint(substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
      reply->plist[d.seq].slist[tot_count].visible_ind = cnvtint(substring(beg_pos,1,tcp
        .sub_comp_pref)), end_pos = size(trim(tcp.sub_comp_pref),1), beg_pos = (beg_pos+ 2)
      IF (end_pos > beg_pos)
       reply->plist[d.seq].slist[tot_count].icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),
         tcp.sub_comp_pref))
      ENDIF
     ELSEIF ((reply->plist[d.seq].slist[tot_count].action_type=1))
      end_pos = findstring(";",tcp.sub_comp_pref,3,0), reply->plist[d.seq].slist[tot_count].option =
      cnvtint(substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
      end_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), reply->plist[d.seq].slist[tot_count].
      action = cnvtint(substring(beg_pos,(end_pos - beg_pos),tcp.sub_comp_pref)), beg_pos = (end_pos
      + 1),
      reply->plist[d.seq].slist[tot_count].visible_ind = cnvtint(substring(beg_pos,1,tcp
        .sub_comp_pref)), end_pos = size(trim(tcp.sub_comp_pref),1), beg_pos = (beg_pos+ 2)
      IF (end_pos > beg_pos)
       reply->plist[d.seq].slist[tot_count].icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),
         tcp.sub_comp_pref))
      ENDIF
     ELSEIF ((reply->plist[d.seq].slist[tot_count].action_type=3))
      end_pos = findstring(";",tcp.sub_comp_pref,3,0), reply->plist[d.seq].slist[tot_count].
      visible_ind = cnvtint(substring(3,1,tcp.sub_comp_pref)), end_pos = size(trim(tcp.sub_comp_pref),
       1),
      beg_pos = 5
      IF (end_pos > beg_pos)
       reply->plist[d.seq].slist[tot_count].icon = cnvtint(substring(beg_pos,((end_pos - beg_pos)+ 1),
         tcp.sub_comp_pref))
      ENDIF
      reply->plist[d.seq].slist[tot_count].description = "Pre-Arrival Form"
     ENDIF
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->plist[d.seq].slist,tot_count)
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO ptot_count)
  SET scnt = size(reply->plist[x].slist,5)
  IF (scnt > 0)
   SELECT INTO "NL"
    FROM (dummyt d  WITH seq = scnt),
     pm_flx_conversation p,
     pm_flx_task_conv_reltn p2
    PLAN (d)
     JOIN (p
     WHERE (reply->plist[x].slist[d.seq].action_type=1)
      AND p.active_ind=1)
     JOIN (p2
     WHERE p2.conversation_id=p.conversation_id
      AND p2.active_ind=1
      AND (p2.task=reply->plist[x].slist[d.seq].option))
    DETAIL
     reply->plist[x].slist[d.seq].description = p.description
    WITH nocounter
   ;end select
   SELECT INTO "NL"
    FROM (dummyt d  WITH seq = scnt),
     dcp_forms_ref dfr
    PLAN (d)
     JOIN (dfr
     WHERE (reply->plist[x].slist[d.seq].action_type=2)
      AND (dfr.dcp_forms_ref_id=reply->plist[x].slist[d.seq].option))
    ORDER BY dfr.description
    DETAIL
     reply->plist[x].slist[d.seq].description = dfr.description
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 IF (((ptot_count > 0) OR (tot_acnt > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
