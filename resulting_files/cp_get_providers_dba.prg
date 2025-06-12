CREATE PROGRAM cp_get_providers:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 r_cd = f8
     2 r_disp = c40
     2 r_desc = c60
     2 r_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET count4 = 0
 SET found_prov = "F"
 SET prov_already_in_list = 0
 SET prov_cnt = 0
 SET i = 0
 DECLARE activate_cd = f8
 DECLARE modify_cd = f8
 DECLARE order_cd = f8
 DECLARE renew_cd = f8
 DECLARE resume_cd = f8
 DECLARE stud_activate_cd = f8
 DECLARE consult_doc_cd = f8
 DECLARE order_doc_cd = f8
 SET stat = uar_get_meaning_by_codeset(6003,"ACTIVATE",1,activate_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"MODIFY",1,modify_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,order_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RENEW",1,renew_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RESUME",1,resume_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"STUDACTIVATE",1,stud_activate_cd)
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,consult_doc_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,order_doc_cd)
 SELECT DISTINCT INTO "nl:"
  ppr.prsnl_person_id, ppr.person_prsnl_r_cd
  FROM person_prsnl_reltn ppr,
   prsnl p,
   dummyt d
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (p
   WHERE ppr.prsnl_person_id=p.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ppr.prsnl_person_id, ppr.person_prsnl_r_cd
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].person_id = p.person_id, reply->qual[count1].name_full_formatted = p
   .name_full_formatted, reply->qual[count1].r_cd = ppr.person_prsnl_r_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET found_prov = "T"
 ENDIF
 CALL echo(build("count1= ",count1))
 SET count2 = count1
 IF ((request->encntr_id > 0))
  SELECT DISTINCT INTO "nl:"
   epr.prsnl_person_id, epr.encntr_prsnl_r_cd
   FROM encntr_prsnl_reltn epr,
    prsnl p,
    dummyt d
   PLAN (epr
    WHERE (epr.encntr_id=request->encntr_id)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d)
    JOIN (p
    WHERE epr.prsnl_person_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY epr.prsnl_person_id, epr.encntr_prsnl_r_cd
   DETAIL
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->qual,(count2+ 9))
    ENDIF
    reply->qual[count2].person_id = p.person_id, reply->qual[count2].name_full_formatted = p
    .name_full_formatted, reply->qual[count2].r_cd = epr.encntr_prsnl_r_cd
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET found_prov = "T"
  ENDIF
 ELSE
  SELECT DISTINCT INTO "nl:"
   epr.prsnl_person_id, epr.encntr_prsnl_r_cd
   FROM encounter e,
    encntr_prsnl_reltn epr,
    prsnl p,
    dummyt d
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.active_ind=1
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d)
    JOIN (p
    WHERE epr.prsnl_person_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY epr.prsnl_person_id, epr.encntr_prsnl_r_cd
   DETAIL
    count2 = (count2+ 1)
    IF (mod(count2,10)=1)
     stat = alterlist(reply->qual,(count2+ 9))
    ENDIF
    reply->qual[count2].person_id = p.person_id, reply->qual[count2].name_full_formatted = p
    .name_full_formatted, reply->qual[count2].r_cd = epr.encntr_prsnl_r_cd
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET found_prov = "T"
  ENDIF
 ENDIF
 CALL echo(build("count2= ",count2))
 SET count3 = count2
 IF ((request->order_id > 0))
  SELECT INTO "nl:"
   oa.order_provider_id
   FROM order_action oa,
    prsnl p
   PLAN (oa
    WHERE (oa.order_id=request->order_id)
     AND oa.action_type_cd IN (activate_cd, modify_cd, order_cd, renew_cd, resume_cd,
    stud_activate_cd)
     AND oa.action_rejected_ind=0)
    JOIN (p
    WHERE oa.order_provider_id=p.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    prov_already_in_list = 0, prov_cnt = size(reply->qual,5)
    FOR (i = 1 TO prov_cnt)
      IF ((reply->qual[i].person_id=p.person_id)
       AND (reply->qual[i].r_cd=order_doc_cd))
       i = (prov_cnt+ 1), prov_already_in_list = 1
      ENDIF
    ENDFOR
    IF (prov_already_in_list=0)
     count3 = (count3+ 1)
     IF (mod(count3,10)=1)
      stat = alterlist(reply->qual,(count3+ 9))
     ENDIF
     reply->qual[count3].person_id = p.person_id, reply->qual[count3].name_full_formatted = p
     .name_full_formatted, reply->qual[count3].r_cd = order_doc_cd
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET found_prov = "T"
  ENDIF
 ENDIF
 CALL echo(build("count3= ",count3))
 SET count4 = count3
 IF ((request->order_id > 0))
  SELECT INTO "nl:"
   od.order_id, p.name_full_formatted
   FROM order_detail od,
    prsnl p
   PLAN (od
    WHERE (od.order_id=request->order_id)
     AND od.oe_field_meaning="CONSULTDOC"
     AND od.oe_field_meaning_id=2)
    JOIN (p
    WHERE p.person_id=od.oe_field_value
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY od.action_sequence DESC, od.detail_sequence
   HEAD REPORT
    lastestseq = 1
   HEAD od.action_sequence
    do_nothing = 0
   DETAIL
    IF (lastestseq=1
     AND od.oe_field_display_value > " ")
     prov_already_in_list = 0, prov_cnt = size(reply->qual,5)
     FOR (i = 1 TO prov_cnt)
       IF ((reply->qual[i].person_id=od.oe_field_value)
        AND (reply->qual[i].r_cd=consult_doc_cd))
        i = (prov_cnt+ 1), prov_already_in_list = 1
       ENDIF
     ENDFOR
     IF (prov_already_in_list=0)
      count4 = (count4+ 1)
      IF (mod(count4,10)=1)
       stat = alterlist(reply->qual,(count4+ 9))
      ENDIF
      reply->qual[count4].person_id = od.oe_field_value, reply->qual[count4].name_full_formatted = p
      .name_full_formatted, reply->qual[count4].r_cd = consult_doc_cd
     ENDIF
    ENDIF
   FOOT  od.action_sequence
    IF (lastestseq=1)
     lastestseq = 0, stat = alterlist(reply->qual,count4)
    ENDIF
   FOOT REPORT
    do_nothing = 0
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET found_prov = "T"
  ENDIF
 ENDIF
 SET stat = alterlist(reply->qual,count4)
 CALL echo(build("count4= ",count4))
 IF (found_prov="F")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
