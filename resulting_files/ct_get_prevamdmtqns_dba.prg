CREATE PROGRAM ct_get_prevamdmtqns:dba
 RECORD reply(
   1 questionnaires[*]
     2 prot_questionnaire_id = f8
     2 questionnaire_name = vc
     2 questionnaire_type_cd = f8
     2 questionnaire_type_disp = vc
     2 questionnaire_type_desc = vc
     2 questionnaire_type_mean = vc
     2 edit_ind = i2
     2 desc_text = vc
     2 desc_long_text_id = f8
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
 SET reply->status_data.status = "F"
 DECLARE quest_cnt = i2 WITH protect, noconstant(0)
 DECLARE prot_amendment_id = f8 WITH public, noconstant(0.0)
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 IF (validate(request->prev_amendment_id) > 0)
  SET prot_amendment_id = request->prev_amendment_id
 ELSE
  SELECT INTO "nl:"
   pa.prot_amendment_id
   FROM prot_amendment pa
   PLAN (pa
    WHERE (pa.prot_master_id=request->prot_master_id)
     AND (pa.amendment_nbr=request->amendment_nbr))
   ORDER BY pa.revision_seq DESC
   DETAIL
    IF ((request->revision_seq > 0))
     IF ((pa.revision_seq=request->revision_seq))
      prot_amendment_id = pa.prot_amendment_id, bfound = 1
     ENDIF
    ELSEIF ((request->revision_seq=0)
     AND (request->amendment_nbr=request->cur_amd_nbr))
     prot_amendment_id = pa.parent_amendment_id, bfound = 1
    ENDIF
    IF (bfound=0)
     prot_amendment_id = pa.prot_amendment_id, bfound = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(prot_amendment_id)
 IF (prot_amendment_id > 0)
  SELECT INTO "nl:"
   pq.prot_questionnaire_id
   FROM prot_questionnaire pq,
    long_text_reference ltr
   PLAN (pq
    WHERE pq.prot_amendment_id=prot_amendment_id
     AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ltr
    WHERE ltr.long_text_id=outerjoin(pq.desc_long_text_id))
   HEAD REPORT
    quest_cnt = 0
   DETAIL
    quest_cnt = (quest_cnt+ 1)
    IF (mod(quest_cnt,10)=1)
     stat = alterlist(reply->questionnaires,(quest_cnt+ 9))
    ENDIF
    reply->questionnaires[quest_cnt].prot_questionnaire_id = pq.prot_questionnaire_id, reply->
    questionnaires[quest_cnt].questionnaire_type_cd = pq.questionnaire_type_cd, reply->
    questionnaires[quest_cnt].questionnaire_name = pq.questionnaire_name,
    reply->questionnaires[quest_cnt].edit_ind = 1
    IF (pq.desc_long_text_id > 0)
     reply->questionnaires[quest_cnt].desc_text = ltr.long_text, reply->questionnaires[quest_cnt].
     desc_long_text_id = ltr.long_text_id
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->questionnaires,quest_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSEIF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF (quest_cnt > 0)
   SELECT INTO "nl:"
    FROM prot_questionnaire pq,
     (dummyt d  WITH seq = value(quest_cnt))
    PLAN (d)
     JOIN (pq
     WHERE (pq.prot_amendment_id=request->cur_amendment_id)
      AND (pq.questionnaire_type_cd=reply->questionnaires[d.seq].questionnaire_type_cd)
      AND (pq.questionnaire_name=reply->questionnaires[d.seq].questionnaire_name)
      AND pq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     reply->questionnaires[d.seq].edit_ind = 0
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET last_mod = "006"
 SET mod_date = "Jan 21, 2008"
 CALL echo(build("Status:",reply->status_data.status))
END GO
