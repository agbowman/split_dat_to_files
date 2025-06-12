CREATE PROGRAM dcp_get_ppr_log:dba
 RECORD reply(
   1 prsn_cnt = i4
   1 ppa_total_count = i4
   1 prsn[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
     2 ppa_last_dt_tm = dq8
     2 view_caption = vc
     2 computer_name = vc
     2 position_cd = f8
     2 position_disp = vc
     2 ppa_comment = vc
     2 ppa_id = f8
     2 ppr_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE count3 = i4 WITH noconstant(0)
 DECLARE count4 = i4 WITH noconstant(0)
 DECLARE prsn_cnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE last_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE totalreccnt = i4 WITH noconstant(0)
 DECLARE reclimit = i4 WITH noconstant(0)
 DECLARE ppa_cd = f8 WITH constant(uar_get_code_by("MEANING",104,"CHARTACCESS"))
 IF ((request->ppa_total_count <= 0))
  SELECT INTO "nl:"
   reccnt = count(*)
   FROM person_prsnl_activity ppa
   WHERE (ppa.person_id=request->person_id)
    AND ppa.ppa_type_cd=ppa_cd
   DETAIL
    reply->ppa_total_count = reccnt
   WITH nocounter
  ;end select
  SET totalreccnt = reply->ppa_total_count
 ELSE
  SET totalreccnt = request->ppa_total_count
  SET reply->ppa_total_count = totalreccnt
 ENDIF
 SET reclimit = 1000
 IF ((request->all_ind=1))
  IF (totalreccnt > reclimit
   AND (request->ppa_last_dt_tm > 0))
   SELECT INTO "nl:"
    ppa.ppa_id, ppa.ppa_last_dt_tm, p.person_id,
    nullind_ppa_ppa_last_dt_tm = nullind(ppa.ppa_last_dt_tm)
    FROM person_prsnl_activity ppa,
     prsnl p
    PLAN (ppa
     WHERE ppa.active_ind=1
      AND ppa.ppa_type_cd=ppa_cd
      AND (ppa.person_id=request->person_id)
      AND ppa.ppa_last_dt_tm < cnvtdatetime(request->ppa_last_dt_tm))
     JOIN (p
     WHERE ppa.prsnl_id=p.person_id)
    ORDER BY ppa.ppa_last_dt_tm DESC
    HEAD REPORT
     count1 = 0
    DETAIL
     IF (p.name_full_formatted > " ")
      count1 += 1
      IF (count1 > size(reply->prsn,5))
       stat = alterlist(reply->prsn,(count1+ 10))
      ENDIF
      IF (nullind_ppa_ppa_last_dt_tm=0)
       reply->prsn[count1].ppa_last_dt_tm = cnvtdatetime(ppa.ppa_last_dt_tm)
      ENDIF
      reply->prsn[count1].prsnl_name = p.name_full_formatted, reply->prsn[count1].prsnl_id = p
      .person_id, reply->prsn[count1].view_caption = ppa.view_caption,
      reply->prsn[count1].computer_name = ppa.computer_name, reply->prsn[count1].position_cd = p
      .position_cd, reply->prsn[count1].ppa_comment = ppa.ppa_comment,
      reply->prsn[count1].ppa_id = ppa.ppa_id
     ENDIF
    FOOT REPORT
     reply->prsn_cnt = count1
    WITH nocounter, maxrec = 1000
   ;end select
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    ppa.ppa_id, ppa.ppa_last_dt_tm, p.person_id,
    nullind_ppa_ppa_last_dt_tm = nullind(ppa.ppa_last_dt_tm)
    FROM person_prsnl_activity ppa,
     prsnl p
    PLAN (ppa
     WHERE ppa.active_ind=1
      AND ppa.ppa_type_cd=ppa_cd
      AND (ppa.person_id=request->person_id))
     JOIN (p
     WHERE ppa.prsnl_id=p.person_id)
    ORDER BY ppa.ppa_last_dt_tm DESC
    HEAD REPORT
     count1 = 0
    DETAIL
     IF (p.name_full_formatted > " ")
      count1 += 1
      IF (count1 > size(reply->prsn,5))
       stat = alterlist(reply->prsn,(count1+ 10))
      ENDIF
      IF (nullind_ppa_ppa_last_dt_tm=0)
       reply->prsn[count1].ppa_last_dt_tm = cnvtdatetime(ppa.ppa_last_dt_tm)
      ENDIF
      reply->prsn[count1].prsnl_name = p.name_full_formatted, reply->prsn[count1].prsnl_id = p
      .person_id, reply->prsn[count1].view_caption = ppa.view_caption,
      reply->prsn[count1].computer_name = ppa.computer_name, reply->prsn[count1].position_cd = p
      .position_cd, reply->prsn[count1].ppa_comment = ppa.ppa_comment,
      reply->prsn[count1].ppa_id = ppa.ppa_id, reply->prsn[count1].ppr_cd = ppa.ppr_cd
     ENDIF
    FOOT REPORT
     reply->prsn_cnt = count1
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ppa.ppa_id, ppa.ppa_last_dt_tm, p.person_id,
  nullind_ppa_ppa_last_dt_tm = nullind(ppa.ppa_last_dt_tm)
  FROM person_prsnl_activity ppa,
   prsnl p
  PLAN (ppa
   WHERE ppa.active_ind=1
    AND ppa.ppa_type_cd=ppa_cd
    AND (ppa.person_id=request->person_id))
   JOIN (p
   WHERE ppa.prsnl_id=p.person_id)
  ORDER BY p.person_id, ppa.ppa_last_dt_tm DESC
  HEAD REPORT
   count1 = 0
  HEAD p.person_id
   IF (p.name_full_formatted > " ")
    count1 += 1
    IF (count1 > size(reply->prsn,5))
     stat = alterlist(reply->prsn,(count1+ 10))
    ENDIF
    IF (nullind_ppa_ppa_last_dt_tm=0)
     reply->prsn[count1].ppa_last_dt_tm = cnvtdatetime(ppa.ppa_last_dt_tm)
    ENDIF
    reply->prsn[count1].prsnl_name = p.name_full_formatted, reply->prsn[count1].prsnl_id = p
    .person_id, reply->prsn[count1].view_caption = ppa.view_caption,
    reply->prsn[count1].computer_name = ppa.computer_name, reply->prsn[count1].position_cd = p
    .position_cd, reply->prsn[count1].ppa_comment = ppa.ppa_comment,
    reply->prsn[count1].ppa_id = ppa.ppa_id, reply->prsn[count1].ppr_cd = ppa.ppr_cd
   ENDIF
  FOOT  p.person_id
   reply->prsn_cnt = count1
  FOOT REPORT
   count1 = count1
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->prsn_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
