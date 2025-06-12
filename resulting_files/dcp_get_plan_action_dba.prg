CREATE PROGRAM dcp_get_plan_action:dba
 RECORD reply(
   1 qual[*]
     2 pathway_id = f8
     2 owner_name = vc
     2 dc_reason_cd = f8
     2 dc_reason_disp = c40
     2 dc_reason_mean = c12
     2 action_qual[*]
       3 pw_action_seq = i2
       3 pw_action_cd = f8
       3 pw_action_disp = c40
       3 pw_action_mean = c12
       3 pw_status_cd = f8
       3 pw_status_disp = c40
       3 pw_status_mean = c12
       3 action_dt_tm = dq8
       3 action_prsnl_name = vc
       3 action_prsnl_id = f8
       3 action_prsnl_phys_ind = i2
       3 provider_id = f8
       3 provider_name = vc
       3 communication_type_cd = f8
       3 communication_type_disp = c40
       3 communication_type_mean = c12
       3 action_tz = i4
       3 action_comment = vc
       3 action_reason_cd = f8
       3 action_reason_disp = c40
       3 action_reason_mean = c12
       3 notification_list[*]
         4 to_prsnl_id = f8
         4 to_prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE pathwaycnt = i4 WITH protect, noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE act_cnt = i2 WITH noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE pathway_cnt = i4 WITH constant(value(size(request->qual,5)))
 DECLARE get_pathway_notifications(idx=i4) = null
 SELECT INTO "nl:"
  pa.pathway_id, pa.pw_action_seq, pr.person_id,
  actionprsnlname = trim(pr.name_full_formatted,3), providername = trim(pr2.name_full_formatted,3)
  FROM pathway_action pa,
   prsnl pr,
   prsnl pr2
  PLAN (pa
   WHERE expand(i,1,pathway_cnt,pa.pathway_id,request->qual[i].pathway_id))
   JOIN (pr
   WHERE pa.action_prsnl_id=pr.person_id)
   JOIN (pr2
   WHERE pa.provider_id=pr2.person_id)
  ORDER BY pa.pathway_id, pa.pw_action_seq
  HEAD REPORT
   pathwaycnt = 0
  HEAD pa.pathway_id
   pathwaycnt = (pathwaycnt+ 1)
   IF (pathwaycnt > value(size(reply->qual,5)))
    stat = alterlist(reply->qual,(pathwaycnt+ 10))
   ENDIF
   act_cnt = 0, reply->qual[pathwaycnt].pathway_id = pa.pathway_id
  DETAIL
   act_cnt = (act_cnt+ 1)
   IF (act_cnt > value(size(reply->qual[pathwaycnt].action_qual,5)))
    stat = alterlist(reply->qual[pathwaycnt].action_qual,(act_cnt+ 10))
   ENDIF
   reply->qual[pathwaycnt].action_qual[act_cnt].pw_action_seq = pa.pw_action_seq, reply->qual[
   pathwaycnt].action_qual[act_cnt].pw_action_cd = pa.action_type_cd, reply->qual[pathwaycnt].
   action_qual[act_cnt].pw_status_cd = pa.pw_status_cd,
   reply->qual[pathwaycnt].action_qual[act_cnt].action_dt_tm = cnvtdatetime(pa.action_dt_tm), reply->
   qual[pathwaycnt].action_qual[act_cnt].communication_type_cd = pa.communication_type_cd, reply->
   qual[pathwaycnt].action_qual[act_cnt].action_comment = pa.action_comment,
   reply->qual[pathwaycnt].action_qual[act_cnt].action_reason_cd = pa.action_reason_cd
   IF (pr.person_id=pa.action_prsnl_id)
    reply->qual[pathwaycnt].action_qual[act_cnt].action_prsnl_name = actionprsnlname, reply->qual[
    pathwaycnt].action_qual[act_cnt].action_prsnl_id = pa.action_prsnl_id, reply->qual[pathwaycnt].
    action_qual[act_cnt].action_prsnl_phys_ind = pr.physician_ind
   ENDIF
   reply->qual[pathwaycnt].action_qual[act_cnt].provider_id = pa.provider_id
   IF (pa.provider_id != pa.action_prsnl_id
    AND pr2.person_id=pa.provider_id)
    reply->qual[pathwaycnt].action_qual[act_cnt].provider_name = providername
   ENDIF
   reply->qual[pathwaycnt].action_qual[act_cnt].action_tz = pa.action_tz
  FOOT  pa.pathway_id
   stat = alterlist(reply->qual[pathwaycnt].action_qual,act_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,pathwaycnt)
  WITH nocounter
 ;end select
 IF (value(size(reply->qual,5)) > 0)
  SELECT INTO "nl:"
   FROM pathway pw,
    prsnl pr,
    (dummyt d  WITH seq = value(size(reply->qual,5)))
   PLAN (d)
    JOIN (pw
    WHERE (pw.pathway_id=reply->qual[d.seq].pathway_id))
    JOIN (pr
    WHERE pr.person_id=outerjoin(pw.ref_owner_person_id))
   HEAD REPORT
    dummy = 0
   DETAIL
    reply->qual[d.seq].owner_name = trim(pr.name_full_formatted,3)
    IF (pw.dc_reason_cd > 0)
     reply->qual[d.seq].dc_reason_cd = pw.dc_reason_cd
    ENDIF
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
 ;end select
 FOR (idx = 1 TO pathwaycnt)
   CALL get_pathway_notifications(idx)
 ENDFOR
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE get_pathway_notifications(idx)
   SELECT INTO "nl:"
    FROM pathway_notification pn,
     pathway_action pa,
     prsnl pr
    PLAN (pa
     WHERE (pa.pathway_id=reply->qual[idx].pathway_id))
     JOIN (pn
     WHERE pn.pathway_id=pa.pathway_id
      AND pn.pw_action_seq=pa.pw_action_seq)
     JOIN (pr
     WHERE pr.person_id=pn.to_prsnl_id)
    HEAD REPORT
     act_cnt = value(size(reply->qual[idx].action_qual,5))
    DETAIL
     idx2 = locateval(idx2,1,act_cnt,pn.pw_action_seq,reply->qual[idx].action_qual[idx2].
      pw_action_seq)
     IF (idx2 > 0)
      stat = alterlist(reply->qual[idx].action_qual[idx2].notification_list,1), reply->qual[idx].
      action_qual[idx2].notification_list.to_prsnl_id = pn.to_prsnl_id, reply->qual[idx].action_qual[
      idx2].notification_list.to_prsnl_name = trim(pr.name_full_formatted,3)
     ENDIF
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
END GO
