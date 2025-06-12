CREATE PROGRAM ct_get_elig_quests:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 qual[*]
      2 bgotdata = i2
      2 prot_amendment_id = f8
      2 primary_mnemonic = vc
      2 pi = vc
      2 cra = vc
      2 quest[*]
        3 prot_elig_quest_id = f8
        3 question = vc
        3 question_nbr = i4
        3 desired_value = vc
        3 valid_ans = vc
        3 req_value = i2
        3 req_date = i2
        3 quest_type_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET pi_cd = 0.0
 SET cra_cd = 0.0
 SET qual_cnt = size(request->qual,5)
 SET bstat = alterlist(reply->qual,qual_cnt)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET bstat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET bstat = uar_get_meaning_by_codeset(17441,"CRA",1,cra_cd)
 IF (qual_cnt > 0)
  SELECT INTO "nl:"
   FROM prot_amendment pa,
    prot_master pm,
    (dummyt d  WITH seq = value(qual_cnt))
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_amendment_id=request->qual[d.seq].prot_amendment_id))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
   HEAD d.seq
    cnt = 0, reply->qual[d.seq].bgotdata = 1
   DETAIL
    reply->qual[d.seq].prot_amendment_id = pa.prot_amendment_id, reply->qual[d.seq].primary_mnemonic
     = pm.primary_mnemonic
   WITH nocounter, dontcare = p
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_program
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET qual_cnt = size(request->qual,5)
 FOR (i = 1 TO qual_cnt)
   SELECT INTO "nl:"
    FROM prot_elig_quest peq,
     answer_format af,
     category_item ci,
     valid_answer_cat vac,
     long_text_reference ltr
    PLAN (peq
     WHERE (peq.prot_amendment_id=request->qual[i].prot_amendment_id)
      AND peq.quest_type_ind=1
      AND peq.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (af
     WHERE peq.answer_format_id=af.answer_format_id)
     JOIN (vac
     WHERE vac.answer_format_id=peq.answer_format_id)
     JOIN (ci
     WHERE ci.category_item_id=vac.category_item_id)
     JOIN (ltr
     WHERE ltr.long_text_id=peq.long_text_id)
    ORDER BY peq.elig_quest_nbr
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(reply->qual[i].quest,5))
      stat = alterlist(reply->qual[i].quest,(cnt+ 10))
     ENDIF
     reply->qual[i].quest[cnt].prot_elig_quest_id = peq.prot_elig_quest_id, reply->qual[i].quest[cnt]
     .question = ltr.long_text, reply->qual[i].quest[cnt].question_nbr = peq.elig_quest_nbr,
     reply->qual[i].quest[cnt].desired_value = peq.desired_value, reply->qual[i].quest[cnt].req_value
      = peq.value_required_flag, reply->qual[i].quest[cnt].req_date = peq.date_required_flag,
     reply->qual[i].quest[cnt].quest_type_ind = peq.quest_type_ind, reply->qual[i].quest[cnt].
     valid_ans = ci.category_item_text
    FOOT REPORT
     stat = alterlist(reply->qual[i].quest,cnt)
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (qual_cnt > 0)
  SELECT INTO "nl:"
   FROM prot_role pr,
    person p,
    (dummyt d  WITH seq = value(qual_cnt))
   PLAN (d)
    JOIN (pr
    WHERE (pr.prot_amendment_id=reply->qual[d.seq].prot_amendment_id))
    JOIN (p
    WHERE p.person_id=pr.person_id)
   HEAD d.seq
    cnt = 0
   DETAIL
    IF (pr.prot_role_cd=pi_cd)
     reply->qual[d.seq].pi = p.name_full_formatted
    ENDIF
    IF (pr.prot_role_cd=cra_cd)
     reply->qual[d.seq].cra = p.name_full_formatted
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_program
 SET last_mod = "002"
 SET mod_date = "August 20, 2007"
END GO
