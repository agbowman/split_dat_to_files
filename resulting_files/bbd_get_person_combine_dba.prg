CREATE PROGRAM bbd_get_person_combine:dba
 RECORD reply(
   1 qual[*]
     2 exceptions[*]
       3 bb_review_queue_id = f8
       3 from_e = c20
       3 to_e = c20
       3 review_status = c20
       3 review_dt_tm = dq8
       3 review_by = c100
       3 review_by_prsnl_id = f8
       3 review_doc_id = f8
       3 review_doc = vc
       3 updt_cnt = i4
     2 bb_comments = vc
     2 person_combine_id = f8
     2 from_patient_id = f8
     2 encntr_combine_id = f8
     2 active_status_dt_tm = dq8
     2 from_patient_name = c100
     2 to_patient_name = c100
     2 to_mrn = c100
     2 from_mrn = c100
     2 donor_yes_no = c1
     2 long_text_id = f8
     2 to_patient_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c6
     2 abo_code = f8
     2 rh_code = f8
 )
 RECORD parent_relation(
   1 qual[*]
     2 parent_entity_name = c20
     2 bb_review_queue_id = f8
 )
 RECORD exception(
   1 qual[*]
     2 from_id = f8
     2 to_id = f8
 )
 RECORD streq(
   1 st_list[*]
     2 st_code = f8
     2 st_display = c20
 )
 RECORD anreq(
   1 an_list[*]
     2 an_code = f8
     2 an_display = c20
 )
 SET stat = alterlist(exception->qual,10)
 SET stat = 0
 SET qual_index = 0
 SET qual_index2 = 0
 SET stat = alterlist(reply->qual,10)
 SET inprocess_code = 0.0
 SET encntr_mrn_code = 0.0
 SET index1 = 0
 SET excep_index = 0
 SET index2 = 0
 SET stat = alterlist(streq->st_list,10)
 SET st_idx = 0
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=1612
   AND c1.code_value > 0
  DETAIL
   st_idx = (st_idx+ 1)
   IF (mod(st_idx,10)=1
    AND st_idx != 1)
    stat = alterlist(streq->st_list,(st_idx+ 9))
   ENDIF
   streq->st_list[st_idx].st_code = c1.code_value, streq->st_list[st_idx].st_display = c1.display
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(streq->st_list,st_idx)
 ENDIF
 SET stat = alterlist(anreq->an_list,10)
 SET an_idx = 0
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=1613
   AND c1.code_value > 0
  DETAIL
   an_idx = (an_idx+ 1)
   IF (mod(an_idx,10)=1
    AND an_idx != 1)
    stat = alterlist(anreq->an_list,(an_idx+ 9))
   ENDIF
   anreq->an_list[an_idx].an_code = c1.code_value, anreq->an_list[an_idx].an_display = c1.display
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(anreq->an_list,an_idx)
 ENDIF
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2,
   (dummyt d1  WITH seq = 1),
   code_value cv2,
   (dummyt d2  WITH seq = 1),
   code_value cv3
  PLAN (cv1
   WHERE cv1.code_set=1640
    AND cv1.active_ind=1)
   JOIN (cve1
   WHERE cve1.code_set=1640
    AND cv1.code_value=cve1.code_value
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_set=1640
    AND cv1.code_value=cve2.code_value
    AND cve2.field_name="RhOnly_cd")
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cv2
   WHERE cv2.code_set=1641
    AND cnvtint(cve1.field_value)=cv2.code_value)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (cv3
   WHERE cv3.code_set=1642
    AND cnvtint(cve2.field_value)=cv3.code_value)
  ORDER BY cve1.field_value, cve2.field_value
  DETAIL
   aborh_index = (aborh_index+ 1)
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cv2.code_value, aborh->aborh_list[aborh_index].rh_code = cv3.code_value
  WITH outerjoin(d1), outerjoin(d2), check,
   nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(aborh->aborh_list,aborh_index)
 ENDIF
 SET encntr_mrn_code = uar_get_code_by("MEANING",319,"MRN")
 SET inprocess_code = uar_get_code_by("MEANING",16229,"INPROCESS")
 IF ((request->r_type=1))
  SELECT DISTINCT INTO "nl:"
   pc.person_combine_id, pc.encntr_id, pc.from_person_id,
   pc.to_person_id, pc.active_status_dt_tm, pc.to_mrn,
   pd_person_id = maxval(pdt.person_id,pdf.person_id), pet.name_full_formatted, pef
   .name_full_formatted
   FROM person_combine pc,
    bb_review_queue rq,
    person_donor pdf,
    person_donor pdt,
    person pef,
    person pet
   PLAN (pc
    WHERE pc.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND pc.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND pc.encntr_id=0
     AND (pc.person_combine_id > request->last_combine_id))
    JOIN (rq
    WHERE rq.from_person_id=pc.from_person_id
     AND rq.to_person_id=pc.to_person_id
     AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code)) )
    JOIN (pet
    WHERE pet.person_id=pc.to_person_id
     AND pet.active_ind=1)
    JOIN (pef
    WHERE pef.person_id=pc.from_person_id)
    JOIN (pdt
    WHERE pdt.person_id=outerjoin(pc.to_person_id))
    JOIN (pdf
    WHERE pdf.person_id=outerjoin(pc.from_person_id))
   ORDER BY pc.active_status_dt_tm, pc.person_combine_id, 0
   DETAIL
    qual_index = (qual_index+ 1)
    IF (mod(qual_index,10)=1
     AND qual_index != 1)
     stat = alterlist(reply->qual,(qual_index+ 9)), stat = alterlist(exception->qual,(qual_index+ 9))
    ENDIF
    reply->qual[qual_index].active_status_dt_tm = pc.active_status_dt_tm, reply->qual[qual_index].
    from_patient_name = pef.name_full_formatted, reply->qual[qual_index].to_patient_name = pet
    .name_full_formatted,
    reply->qual[qual_index].to_mrn = pc.to_mrn, reply->qual[qual_index].from_mrn = pc.from_mrn, reply
    ->qual[qual_index].person_combine_id = pc.person_combine_id,
    reply->qual[qual_index].from_patient_id = pc.from_person_id, reply->qual[qual_index].
    to_patient_id = pc.to_person_id, exception->qual[qual_index].from_id = pc.from_person_id,
    exception->qual[qual_index].to_id = pc.to_person_id
    IF (pd_person_id > 0)
     reply->qual[qual_index].donor_yes_no = "Y"
    ELSE
     reply->qual[qual_index].donor_yes_no = "N"
    ENDIF
   WITH nocounter, maxread(pc,100)
  ;end select
  IF (qual_index != 0)
   FOR (index1 = 1 TO qual_index)
     SET stat = alterlist(reply->qual[index1].exceptions,10)
     SET stat = alterlist(parent_relation->qual,10)
     SET excep_index = 0
     SELECT DISTINCT INTO "nl:"
      rq.bb_review_queue_id, rq.parent_entity_name
      FROM bb_review_queue rq
      WHERE (rq.from_person_id=exception->qual[index1].from_id)
       AND (rq.to_person_id=exception->qual[index1].to_id)
       AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code))
      ORDER BY rq.bb_review_queue_id, 0
      DETAIL
       excep_index = (excep_index+ 1)
       IF (mod(excep_index,10)=1
        AND excep_index != 1)
        stat = alterlist(parent_relation->qual,(excep_index+ 9)), stat = alterlist(reply->qual[index1
         ].exceptions,(excep_index+ 9))
       ENDIF
       parent_relation->qual[excep_index].parent_entity_name = rq.parent_entity_name, parent_relation
       ->qual[excep_index].bb_review_queue_id = rq.bb_review_queue_id, reply->qual[index1].
       exceptions[excep_index].bb_review_queue_id = rq.bb_review_queue_id
      WITH nocounter
     ;end select
     SET stat = alterlist(parent_relation->qual,excep_index)
     SET stat = alterlist(reply->qual[index1].exceptions,excep_index)
     FOR (index2 = 1 TO excep_index)
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ABORH"))
        SELECT DISTINCT INTO "nl:"
         rq.bb_review_queue_id, rq.from_parent_entity_id, rq.to_parent_entity_id,
         rq.review_dt_tm, rq.review_prsnl_id, rq.updt_cnt,
         prs.name_full_formatted, c1.display, pat.abo_cd,
         pat.rh_cd, paf.abo_cd, paf.rh_cd
         FROM bb_review_queue rq,
          person_aborh pat,
          person_aborh paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_aborh_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_aborh_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((paf.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (paf.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].from_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((pat.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (pat.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].to_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIBODY"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.review_prsnl_id, rq.bb_review_queue_id, prs.name_full_formatted,
         c1.display, pat.antibody_cd, paf.antibody_cd
         FROM bb_review_queue rq,
          person_antibody pat,
          person_antibody paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antibody_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antibody_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by_prsnl_id = rq.review_prsnl_id, reply->qual[index1].exceptions[
          index2].review_by = prs.name_full_formatted,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((paf.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].from_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((pat.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].to_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIGEN"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.review_prsnl_id, rq.bb_review_queue_id, prs.name_full_formatted,
         c1.display, pat.antigen_cd, paf.antigen_cd
         FROM bb_review_queue rq,
          person_antigen pat,
          person_antigen paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antigen_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antigen_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((paf.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].from_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((pat.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].to_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
     ENDFOR
     IF (value(excep_index) > 0)
      SELECT INTO "nl:"
       FROM long_text l,
        (dummyt d  WITH seq = value(excep_index))
       PLAN (d)
        JOIN (l
        WHERE (l.long_text_id=reply->qual[index1].exceptions[d.seq].review_doc_id)
         AND l.long_text_id != 0)
       DETAIL
        reply->qual[index1].exceptions[d.seq].review_doc = l.long_text
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->r_type=2))
  SELECT DISTINCT INTO "nl:"
   pc.person_combine_id, pc.encntr_id, pc.from_person_id,
   pc.to_person_id, pc.active_status_dt_tm, pc.to_mrn,
   dr.encntr_id, dr.donation_result_id, pet.name_full_formatted,
   pef.name_full_formatted, rq.bb_review_queue_id, rq.parent_entity_name,
   rq.from_parent_entity_id, rq.review_prsnl_id, rq.review_outcome_cd,
   rq.to_parent_entity_id, rq.review_doc_id, ea.alias
   FROM person_combine pc,
    bb_review_queue rq,
    bbd_donation_results dr,
    person pef,
    person pet,
    encntr_alias ea
   PLAN (pc
    WHERE pc.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND pc.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND pc.encntr_id > 0
     AND (pc.person_combine_id > request->last_combine_id))
    JOIN (rq
    WHERE rq.from_person_id=pc.from_person_id
     AND rq.to_person_id=pc.to_person_id
     AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code)) )
    JOIN (pet
    WHERE pet.person_id=pc.to_person_id
     AND pet.active_ind=1)
    JOIN (pef
    WHERE pef.person_id=pc.from_person_id)
    JOIN (dr
    WHERE dr.encntr_id=outerjoin(pc.encntr_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(pc.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(encntr_mrn_code))
   ORDER BY pc.active_status_dt_tm, pc.person_combine_id, 0
   DETAIL
    qual_index = (qual_index+ 1)
    IF (mod(qual_index,10)=1
     AND qual_index != 1)
     stat = alterlist(reply->qual,(qual_index+ 9)), stat = alterlist(exception->qual,(qual_index+ 9))
    ENDIF
    reply->qual[qual_index].active_status_dt_tm = pc.active_status_dt_tm, reply->qual[qual_index].
    from_patient_name = pef.name_full_formatted, reply->qual[qual_index].to_patient_name = pet
    .name_full_formatted,
    reply->qual[qual_index].to_mrn = pc.to_mrn, reply->qual[qual_index].from_mrn = ea.alias, reply->
    qual[qual_index].person_combine_id = pc.person_combine_id,
    reply->qual[qual_index].from_patient_id = pc.from_person_id, reply->qual[qual_index].
    to_patient_id = pc.to_person_id, exception->qual[qual_index].from_id = pc.from_person_id,
    exception->qual[qual_index].to_id = pc.to_person_id
    IF (dr.donation_result_id > 0)
     reply->qual[qual_index].donor_yes_no = "Y"
    ELSE
     reply->qual[qual_index].donor_yes_no = "N"
    ENDIF
   WITH nocounter, maxread(pc,100)
  ;end select
  IF (qual_index != 0)
   FOR (index1 = 1 TO qual_index)
     SET stat = alterlist(reply->qual[index1].exceptions,10)
     SET stat = alterlist(parent_relation->qual,10)
     SET excep_index = 0
     SELECT DISTINCT INTO "nl:"
      rq.bb_review_queue_id, rq.parent_entity_name
      FROM bb_review_queue rq
      WHERE (rq.from_person_id=exception->qual[index1].from_id)
       AND (rq.to_person_id=exception->qual[index1].to_id)
       AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code))
      ORDER BY rq.bb_review_queue_id, 0
      DETAIL
       excep_index = (excep_index+ 1)
       IF (mod(excep_index,10)=1
        AND excep_index != 1)
        stat = alterlist(parent_relation->qual,(excep_index+ 9)), stat = alterlist(reply->qual[index1
         ].exceptions,(excep_index+ 9))
       ENDIF
       parent_relation->qual[excep_index].parent_entity_name = rq.parent_entity_name, parent_relation
       ->qual[excep_index].bb_review_queue_id = rq.bb_review_queue_id, reply->qual[index1].
       exceptions[excep_index].bb_review_queue_id = rq.bb_review_queue_id
      WITH nocounter
     ;end select
     SET stat = alterlist(parent_relation->qual,excep_index)
     SET stat = alterlist(reply->qual[index1].exceptions,excep_index)
     FOR (index2 = 1 TO excep_index)
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ABORH"))
        SELECT DISTINCT INTO "nl:"
         rq.bb_review_queue_id, rq.from_parent_entity_id, rq.to_parent_entity_id,
         rq.review_dt_tm, rq.updt_cnt, rq.review_prsnl_id,
         prs.name_full_formatted, c1.display, pat.abo_cd,
         pat.rh_cd, paf.abo_cd, paf.rh_cd
         FROM bb_review_queue rq,
          person_aborh pat,
          person_aborh paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_aborh_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_aborh_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((paf.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (paf.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].from_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((pat.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (pat.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].to_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIBODY"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.bb_review_queue_id, rq.review_prsnl_id, prs.name_full_formatted,
         c1.display, pat.antibody_cd, paf.antibody_cd
         FROM bb_review_queue rq,
          person_antibody pat,
          person_antibody paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antibody_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antibody_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((paf.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].from_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((pat.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].to_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIGEN"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.bb_review_queue_id, rq.review_prsnl_id, prs.name_full_formatted,
         c1.display, pat.antigen_cd, paf.antigen_cd
         FROM bb_review_queue rq,
          person_antigen pat,
          person_antigen paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antigen_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antigen_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((paf.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].from_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((pat.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].to_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
     ENDFOR
     IF (value(excep_index) > 0)
      SELECT INTO "nl:"
       FROM long_text l,
        (dummyt d  WITH seq = value(excep_index))
       PLAN (d)
        JOIN (l
        WHERE (l.long_text_id=reply->qual[index1].exceptions[d.seq].review_doc_id)
         AND l.long_text_id != 0)
       DETAIL
        reply->qual[index1].exceptions[d.seq].review_doc = l.long_text
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->r_type=3))
  SELECT DISTINCT INTO "nl:"
   ec.encntr_combine_id, ec.from_encntr_id, ec.to_encntr_id,
   ec.active_status_dt_tm, dr_donation_result_id = maxval(drt.donation_result_id,drf
    .donation_result_id), pef.name_full_formatted,
   rq.bb_review_queue_id, rq.parent_entity_name, rq.from_parent_entity_id,
   rq.to_parent_entity_id, rq.review_prsnl_id, rq.review_outcome_cd,
   rq.review_doc_id, ea.alias
   FROM encntr_combine ec,
    bb_review_queue rq,
    bbd_donation_results drt,
    bbd_donation_results drf,
    person pef,
    encntr_alias ea
   PLAN (ec
    WHERE ec.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND ec.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (ec.encntr_combine_id > request->last_combine_id))
    JOIN (rq
    WHERE rq.from_encntr_id=ec.from_encntr_id
     AND rq.to_encntr_id=ec.to_encntr_id
     AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code)) )
    JOIN (drt
    WHERE drt.encntr_id=outerjoin(ec.to_encntr_id))
    JOIN (drf
    WHERE drf.encntr_id=outerjoin(ec.from_encntr_id))
    JOIN (pef
    WHERE pef.person_id=outerjoin(drt.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(ec.to_encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(encntr_mrn_code))
   ORDER BY ec.active_status_dt_tm, ec.encntr_combine_id, 0
   DETAIL
    qual_index = (qual_index+ 1)
    IF (mod(qual_index,10)=1
     AND qual_index != 1)
     stat = alterlist(reply->qual,(qual_index+ 9)), stat = alterlist(parent_relation->qual,(
      qual_index+ 9))
    ENDIF
    reply->qual[qual_index].active_status_dt_tm = ec.active_status_dt_tm, reply->qual[qual_index].
    to_patient_name = pef.name_full_formatted, reply->qual[qual_index].to_mrn = ea.alias,
    reply->qual[qual_index].encntr_combine_id = ec.encntr_combine_id, reply->qual[qual_index].
    from_patient_id = pef.person_id, reply->qual[qual_index].to_patient_id = pef.person_id,
    exception->qual[qual_index].from_id = ec.from_encntr_id, exception->qual[qual_index].to_id = ec
    .to_encntr_id
    IF (dr_donation_result_id > 0)
     reply->qual[qual_index].donor_yes_no = "Y"
    ELSE
     reply->qual[qual_index].donor_yes_no = "N"
    ENDIF
   WITH nocounter, maxread(ec,100)
  ;end select
  IF (qual_index != 0)
   FOR (index1 = 1 TO qual_index)
     SET stat = alterlist(reply->qual[index1].exceptions,10)
     SET stat = alterlist(parent_relation->qual,10)
     SET excep_index = 0
     SELECT DISTINCT INTO "nl:"
      rq.bb_review_queue_id, rq.parent_entity_name
      FROM bb_review_queue rq
      WHERE (rq.from_encntr_id=exception->qual[index1].from_id)
       AND (rq.to_encntr_id=exception->qual[index1].to_id)
       AND ((rq.review_outcome_cd=0) OR (rq.review_outcome_cd=inprocess_code))
      ORDER BY rq.bb_review_queue_id, 0
      DETAIL
       excep_index = (excep_index+ 1)
       IF (mod(excep_index,10)=1
        AND excep_index != 1)
        stat = alterlist(parent_relation->qual,(excep_index+ 9)), stat = alterlist(reply->qual[index1
         ].exceptions,(excep_index+ 9))
       ENDIF
       parent_relation->qual[excep_index].parent_entity_name = rq.parent_entity_name, parent_relation
       ->qual[excep_index].bb_review_queue_id = rq.bb_review_queue_id, reply->qual[index1].
       exceptions[excep_index].bb_review_queue_id = rq.bb_review_queue_id
      WITH nocounter
     ;end select
     SET stat = alterlist(parent_relation->qual,excep_index)
     SET stat = alterlist(reply->qual[index1].exceptions,excep_index)
     FOR (index2 = 1 TO excep_index)
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ABORH"))
        SELECT DISTINCT INTO "nl:"
         rq.bb_review_queue_id, rq.from_parent_entity_id, rq.to_parent_entity_id,
         rq.review_dt_tm, rq.bb_review_queue_id, rq.updt_cnt,
         rq.review_prsnl_id, prs.name_full_formatted, c1.display,
         pat.abo_cd, pat.rh_cd, paf.abo_cd,
         paf.rh_cd
         FROM bb_review_queue rq,
          person_aborh pat,
          person_aborh paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_aborh_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_aborh_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((paf.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (paf.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].from_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= aborh_index
           AND finish_flag="N")
            IF ((pat.abo_cd=aborh->aborh_list[idx_a].abo_code)
             AND (pat.rh_cd=aborh->aborh_list[idx_a].rh_code))
             reply->qual[index1].exceptions[index2].to_e = aborh->aborh_list[idx_a].aborh_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIBODY"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.bb_review_queue_id, rq.review_prsnl_id, prs.name_full_formatted,
         c1.display, pat.antibody_cd, paf.antibody_cd
         FROM bb_review_queue rq,
          person_antibody pat,
          person_antibody paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antibody_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antibody_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((paf.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].from_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= an_idx
           AND finish_flag="N")
            IF ((pat.antibody_cd=anreq->an_list[idx_a].an_code))
             reply->qual[index1].exceptions[index2].to_e = anreq->an_list[idx_a].an_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
       IF ((parent_relation->qual[index2].parent_entity_name="PERSON_ANTIGEN"))
        SELECT DISTINCT INTO "nl:"
         rq.from_parent_entity_id, rq.to_parent_entity_id, rq.review_dt_tm,
         rq.bb_review_queue_id, rq.review_prsnl_id, prs.name_full_formatted,
         c1.display, pat.antigen_cd, paf.antigen_cd
         FROM bb_review_queue rq,
          person_antigen pat,
          person_antigen paf,
          code_value c1,
          (dummyt d1  WITH seq = 1),
          (dummyt d2  WITH seq = 1),
          (dummyt d3  WITH seq = 1),
          (dummyt d4  WITH seq = 1),
          prsnl prs
         PLAN (rq
          WHERE (rq.bb_review_queue_id=parent_relation->qual[index2].bb_review_queue_id))
          JOIN (d1
          WHERE d1.seq=1)
          JOIN (paf
          WHERE rq.from_parent_entity_id=paf.person_antigen_id
           AND paf.active_ind=1)
          JOIN (d2
          WHERE d2.seq=1)
          JOIN (pat
          WHERE rq.to_parent_entity_id=pat.person_antigen_id
           AND pat.active_ind=1)
          JOIN (d3
          WHERE d3.seq=1)
          JOIN (prs
          WHERE prs.person_id=rq.review_prsnl_id)
          JOIN (d4
          WHERE d4.seq=1)
          JOIN (c1
          WHERE c1.code_value=rq.review_outcome_cd
           AND rq.review_outcome_cd != 0)
         ORDER BY rq.bb_review_queue_id, 0
         DETAIL
          reply->qual[index1].exceptions[index2].review_status = c1.display, reply->qual[index1].
          exceptions[index2].review_by = prs.name_full_formatted, reply->qual[index1].exceptions[
          index2].review_by_prsnl_id = rq.review_prsnl_id,
          reply->qual[index1].exceptions[index2].review_dt_tm = rq.review_dt_tm, reply->qual[index1].
          exceptions[index2].review_doc_id = rq.review_doc_id, reply->qual[index1].exceptions[index2]
          .updt_cnt = rq.updt_cnt,
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((paf.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].from_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
          idx_a = 1, finish_flag = "N"
          WHILE (idx_a <= st_idx
           AND finish_flag="N")
            IF ((pat.antigen_cd=streq->st_list[idx_a].st_code))
             reply->qual[index1].exceptions[index2].to_e = streq->st_list[idx_a].st_display,
             finish_flag = "Y"
            ELSE
             idx_a = (idx_a+ 1)
            ENDIF
          ENDWHILE
         WITH nocounter, outerjoin(d1), outerjoin(d2),
          outerjoin(d3), outerjoin(d4), dontcare(paf),
          dontcare(pat), dontcare(c1)
        ;end select
       ENDIF
     ENDFOR
     IF (value(excep_index) > 0)
      SELECT INTO "nl:"
       FROM long_text l,
        (dummyt d  WITH seq = value(excep_index))
       PLAN (d)
        JOIN (l
        WHERE (l.long_text_id=reply->qual[index1].exceptions[d.seq].review_doc_id)
         AND l.long_text_id != 0)
       DETAIL
        reply->qual[index1].exceptions[d.seq].review_doc = l.long_text
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET stat = alterlist(reply->qual,qual_index)
 SET reply->status_data.status = "S"
END GO
