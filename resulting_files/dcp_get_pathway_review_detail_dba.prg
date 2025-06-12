CREATE PROGRAM dcp_get_pathway_review_detail:dba
 SET modify = predeclare
 DECLARE prsnl_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE sql_get_name_display(personid=f8,nametypecd=f8,date=q8) = c100
 DECLARE s_script_name = vc WITH protect, constant("dcp_get_pathway_review_detail")
 DECLARE l_review_count = i4 WITH protect, constant(value(size(request->reviews,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lselectindex = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(0)
 DECLARE lreviewindex = i4 WITH protect, noconstant(0)
 DECLARE lreviewcount = i4 WITH protect, noconstant(0)
 DECLARE lreviewsize = i4 WITH protect, noconstant(0)
 DECLARE lpersonnelgroupcount = i4 WITH protect, noconstant(0)
 DECLARE lpersonnelgroupsize = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE lsubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 FREE RECORD pathway_review_details
 RECORD pathway_review_details(
   1 reviews[*]
     2 pathway_review_id = f8
     2 review_status_reason_cd = f8
     2 review_status_comment = vc
     2 notification_dt_tm = dq8
     2 notification_tz = i4
     2 from_prsnl_id = f8
     2 from_prsnl_name = vc
     2 to_prsnl_id = f8
     2 to_prsnl_name = vc
     2 to_prsnl_group_id = f8
     2 to_prsnl_group_idx = i4
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
     2 pathway_id = f8
     2 pw_action_seq = i4
 )
 FREE RECORD query_personnel_group
 RECORD query_personnel_group(
   1 personnel_groups[*]
     2 personnel_group_id = f8
     2 name = vc
 )
 IF (l_review_count < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pr.pathway_review_id, pr.pathway_id, pr.pw_action_seq
  FROM pathway_review pr
  PLAN (pr
   WHERE expand(lselectindex,1,l_review_count,pr.pathway_review_id,request->reviews[lselectindex].
    pathway_review_id))
  ORDER BY pr.pathway_review_id, pr.pathway_id, pr.pw_action_seq
  HEAD REPORT
   idx = 0
  DETAIL
   IF (pr.active_ind=1)
    lreviewcount = (lreviewcount+ 1)
    IF (lreviewsize < lreviewcount)
     lreviewsize = (lreviewsize+ 20), stat = alterlist(pathway_review_details->reviews,lreviewsize)
    ENDIF
    pathway_review_details->reviews[lreviewcount].pathway_review_id = pr.pathway_review_id,
    pathway_review_details->reviews[lreviewcount].pathway_id = pr.pathway_id, pathway_review_details
    ->reviews[lreviewcount].pw_action_seq = pr.pw_action_seq
   ENDIF
  FOOT REPORT
   IF (lreviewcount > 0)
    IF (lreviewcount < lreviewsize)
     stat = alterlist(reply->reviews,lreviewcount)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (lreviewcount <= 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"No reviews found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pa.pathway_id, pa.pw_action_seq, action_prsnl_name = sql_get_name_display(pa.action_prsnl_id,
   prsnl_type_cd,pa.action_dt_tm)
  FROM pathway_action pa
  PLAN (pa
   WHERE expand(lselectindex,1,lreviewcount,pa.pathway_id,pathway_review_details->reviews[
    lselectindex].pathway_id))
  ORDER BY pa.pathway_id, pa.pw_action_seq
  HEAD REPORT
   idx = 0, lreviewindex = 0
  DETAIL
   lreviewindex = locateval(lreviewindex,1,lreviewcount,pa.pathway_id,pathway_review_details->
    reviews[lreviewindex].pathway_id,
    pa.pw_action_seq,pathway_review_details->reviews[lreviewindex].pw_action_seq)
   IF (lreviewindex > 0)
    pathway_review_details->reviews[lreviewindex].review_status_reason_cd = pa.action_reason_cd,
    pathway_review_details->reviews[lreviewindex].review_status_comment = trim(pa.action_comment),
    pathway_review_details->reviews[lreviewindex].action_prsnl_id = pa.action_prsnl_id,
    pathway_review_details->reviews[lreviewindex].action_prsnl_name = trim(action_prsnl_name)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (curqual <= 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"No actions found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pn.pathway_id, pn.pw_action_seq, from_prsnl_name = sql_get_name_display(pn.from_prsnl_id,
   prsnl_type_cd,pn.notification_created_dt_tm),
  to_prsnl_name = sql_get_name_display(pn.to_prsnl_id,prsnl_type_cd,pn.notification_created_dt_tm)
  FROM pathway_notification pn
  PLAN (pn
   WHERE expand(lselectindex,1,lreviewcount,pn.pathway_id,pathway_review_details->reviews[
    lselectindex].pathway_id))
  ORDER BY pn.pathway_id, pn.pw_action_seq
  HEAD REPORT
   idx = 0, lreviewindex = 0
  DETAIL
   lreviewindex = locateval(lreviewindex,1,lreviewcount,pn.pathway_id,pathway_review_details->
    reviews[lreviewindex].pathway_id,
    pn.pw_action_seq,pathway_review_details->reviews[lreviewindex].pw_action_seq)
   IF (lreviewindex > 0)
    pathway_review_details->reviews[lreviewindex].notification_dt_tm = cnvtdatetime(pn
     .notification_created_dt_tm), pathway_review_details->reviews[lreviewindex].notification_tz = pn
    .notification_created_tz, pathway_review_details->reviews[lreviewindex].from_prsnl_id = pn
    .from_prsnl_id,
    pathway_review_details->reviews[lreviewindex].from_prsnl_name = trim(from_prsnl_name),
    pathway_review_details->reviews[lreviewindex].to_prsnl_id = pn.to_prsnl_id,
    pathway_review_details->reviews[lreviewindex].to_prsnl_name = trim(to_prsnl_name),
    pathway_review_details->reviews[lreviewindex].to_prsnl_group_id = pn.to_prsnl_group_id
    IF (pn.to_prsnl_group_id > 0.0)
     idx = locateval(idx,1,lpersonnelgroupcount,pn.to_prsnl_group_id,query_personnel_group->
      personnel_groups[idx].personnel_group_id)
     IF (idx=0)
      lpersonnelgroupcount = (lpersonnelgroupcount+ 1), idx = lpersonnelgroupcount
      IF (lpersonnelgroupsize < lpersonnelgroupcount)
       lpersonnelgroupsize = (lpersonnelgroupsize+ 5), stat = alterlist(query_personnel_group->
        personnel_groups,lpersonnelgroupsize)
      ENDIF
      query_personnel_group->personnel_groups[lpersonnelgroupcount].personnel_group_id = pn
      .to_prsnl_group_id
     ENDIF
     pathway_review_details->reviews[lreviewindex].to_prsnl_group_idx = idx
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (curqual <= 0)
  CALL set_script_status("F","SELECT","F",s_script_name,"No notifications found.")
  GO TO exit_script
 ENDIF
 IF (lpersonnelgroupcount > 0)
  IF (lpersonnelgroupcount < lpersonnelgroupsize)
   SET stat = alterlist(query_personnel_group->personnel_groups,lpersonnelgroupcount)
  ENDIF
 ENDIF
 IF (lpersonnelgroupcount > 0)
  SELECT INTO "nl:"
   pg.prsnl_group_id
   FROM prsnl_group pg
   PLAN (pg
    WHERE expand(lselectindex,1,lpersonnelgroupcount,pg.prsnl_group_id,query_personnel_group->
     personnel_groups[lselectindex].personnel_group_id))
   ORDER BY pg.prsnl_group_id
   DETAIL
    idx = locateval(idx,1,lpersonnelgroupcount,pg.prsnl_group_id,query_personnel_group->
     personnel_groups[idx].personnel_group_id)
    IF (idx != 0)
     query_personnel_group->personnel_groups[idx].name = trim(pg.prsnl_group_name)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  IF (curqual <= 0)
   CALL set_script_status("F","SELECT","F",s_script_name,"No personnel groups found.")
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->reviews,lreviewcount)
 FOR (idx = 1 TO lreviewcount)
   SET reply->reviews[idx].pathway_review_id = pathway_review_details->reviews[idx].pathway_review_id
   SET reply->reviews[idx].review_status_reason_cd = pathway_review_details->reviews[idx].
   review_status_reason_cd
   SET reply->reviews[idx].review_status_comment = trim(pathway_review_details->reviews[idx].
    review_status_comment)
   SET reply->reviews[idx].notification_dt_tm = cnvtdatetime(pathway_review_details->reviews[idx].
    notification_dt_tm)
   SET reply->reviews[idx].notification_tz = pathway_review_details->reviews[idx].notification_tz
   SET reply->reviews[idx].from_prsnl_id = pathway_review_details->reviews[idx].from_prsnl_id
   SET reply->reviews[idx].from_prsnl_name = trim(pathway_review_details->reviews[idx].
    from_prsnl_name)
   SET reply->reviews[idx].to_prsnl_id = pathway_review_details->reviews[idx].to_prsnl_id
   SET reply->reviews[idx].to_prsnl_name = trim(pathway_review_details->reviews[idx].to_prsnl_name)
   SET reply->reviews[idx].action_prsnl_id = pathway_review_details->reviews[idx].action_prsnl_id
   SET reply->reviews[idx].action_prsnl_name = trim(pathway_review_details->reviews[idx].
    action_prsnl_name)
   SET reply->reviews[idx].to_prsnl_group_id = pathway_review_details->reviews[idx].to_prsnl_group_id
   IF ((pathway_review_details->reviews[idx].to_prsnl_group_idx > 0))
    SET reply->reviews[idx].to_prsnl_group_name = trim(query_personnel_group->personnel_groups[
     pathway_review_details->reviews[idx].to_prsnl_group_idx].name)
   ENDIF
 ENDFOR
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET lsubeventstatuscount = (lsubeventstatuscount+ 1)
   IF (lsubeventstatuscount > lsubeventstatussize)
    SET lsubeventstatussize = (lsubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,lsubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[lsubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[lsubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[lsubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[lsubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 FREE RECORD pathway_review_details
 FREE RECORD query_personnel
 FREE RECORD query_personnel_group
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrcnt <= 100)
   SET lerrcnt = (lerrcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 IF ((reply->status_data.status="F"))
  SET stat = alterlist(reply->reviews,0)
 ENDIF
 DECLARE last_mod = c3 WITH protect, constant(fillstring(3,"001"))
 DECLARE mod_date = c30 WITH protect, constant(fillstring(30,"May 7, 2013"))
END GO
