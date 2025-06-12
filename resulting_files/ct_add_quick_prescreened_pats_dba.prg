CREATE PROGRAM ct_add_quick_prescreened_pats:dba
 RECORD personstosyscancel(
   1 persons[*]
     2 person_id = f8
 )
 RECORD personstoadd(
   1 prescreened_patients[*]
     2 person_id = f8
 )
 RECORD persontoprotocolmap(
   1 list[*]
     2 personid = f8
     2 protocolid = f8
 )
 DECLARE pat_cnt = i4 WITH protect, constant(size(request->prescreened_patients,5))
 DECLARE consq_cnt = i4
 DECLARE personid = f8
 DECLARE num = i4
 DECLARE pos = i4
 DECLARE protid = f8
 DECLARE listidx = i4 WITH noconstant(1)
 DECLARE count = i4
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE current_cnt = i4 WITH protect, noconstant(0)
 DECLARE added_via_flag = i4
 DECLARE screened_status_cd = f8
 DECLARE personexists = i4
 DECLARE syscancelidx = i4 WITH noconstant(1)
 DECLARE addpersonidx = i4 WITH noconstant(1)
 DECLARE manually_added = i2 WITH protect, constant(1)
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 SELECT INTO "nl:"
  FROM person p,
   pt_prot_reg ppr,
   pt_prot_prescreen pr,
   dummyt d1,
   dummyt d2,
   dummyt d3
  PLAN (p
   WHERE expand(idx,1,pat_cnt,p.person_id,request->prescreened_patients[idx].person_id))
   JOIN (d1)
   JOIN (ppr
   WHERE ppr.person_id=p.person_id
    AND (ppr.prot_master_id=request->protocol_id))
   JOIN (d2)
   JOIN (pr
   WHERE pr.person_id=p.person_id
    AND (pr.prot_master_id=request->protocol_id)
    AND pr.screening_status_cd != syscancel_cd)
   JOIN (d3)
  DETAIL
   pos = locateval(num,1,size(persontoprotocolmap->list,5),p.person_id,persontoprotocolmap->list[num]
    .personid,
    request->protocol_id,persontoprotocolmap->list[num].protocolid)
   IF (pos=0)
    stat = alterlist(persontoprotocolmap->list,(size(persontoprotocolmap->list,5)+ 1)),
    persontoprotocolmap->list[listidx].personid = p.person_id, persontoprotocolmap->list[listidx].
    protocolid = request->protocol_id,
    listidx += 1
    IF (pr.added_via_flag != manually_added)
     pat_pos = locateval(idx,1,pat_cnt,p.person_id,request->prescreened_patients[idx].person_id)
     IF (pat_pos > 0)
      consq_cnt = size(request->prescreened_patients[pat_pos].consequents,5), consq_pos = locateval(
       idx,1,consq_cnt,request->protocol_id,cnvtreal(request->prescreened_patients[pat_pos].
        consequents[idx].what_inferred))
      IF (consq_pos > 0)
       IF ((request->prescreened_patients[pat_pos].consequents[consq_pos].absent=1))
        IF (pr.screening_status_cd=pending_cd)
         stat = alterlist(personstosyscancel->persons,(size(personstosyscancel->persons,5)+ 1)),
         personstosyscancel->persons[syscancelidx].person_id = p.person_id, syscancelidx += 1
        ENDIF
       ELSE
        IF (pr.screening_status_cd=pending_cd)
         stat = alterlist(personstosyscancel->persons,(size(personstosyscancel->persons,5)+ 1)),
         personstosyscancel->persons[syscancelidx].person_id = p.person_id, syscancelidx += 1,
         stat = alterlist(personstoadd->prescreened_patients,(size(personstoadd->prescreened_patients,
           5)+ 1)), personstoadd->prescreened_patients[addpersonidx].person_id = p.person_id,
         addpersonidx += 1
        ELSEIF (pr.person_id=0)
         stat = alterlist(personstoadd->prescreened_patients,(size(personstoadd->prescreened_patients,
           5)+ 1)), personstoadd->prescreened_patients[addpersonidx].person_id = p.person_id,
         addpersonidx += 1
        ENDIF
       ENDIF
      ELSEIF (pr.screening_status_cd=pending_cd)
       stat = alterlist(personstosyscancel->persons,(size(personstosyscancel->persons,5)+ 1)),
       personstosyscancel->persons[syscancelidx].person_id = p.person_id, syscancelidx += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, dontcare = ppr, dontcare = pr
 ;end select
 CALL echorecord(persontoprotocolmap)
 CALL echorecord(personstosyscancel)
 CALL echorecord(personstoadd)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 UPDATE  FROM pt_prot_prescreen ppp
  SET ppp.screening_status_cd = syscancel_cd, ppp.updt_dt_tm = cnvtdatetime(sysdate), ppp.updt_cnt =
   (ppp.updt_cnt+ 1)
  WHERE expand(idx,1,(syscancelidx - 1),ppp.person_id,personstosyscancel->persons[idx].person_id)
   AND (ppp.prot_master_id=request->protocol_id)
   AND ppp.screening_status_cd=pending_cd
 ;end update
 IF (addpersonidx > 1)
  DECLARE added_via_he = i2 WITH protect, constant(2)
  INSERT  FROM pt_prot_prescreen ppp,
    (dummyt d  WITH seq = value((addpersonidx - 1)))
   SET ppp.pt_prot_prescreen_id = seq(protocol_def_seq,nextval), ppp.ct_prescreen_job_id = request->
    job_id, ppp.person_id = personstoadd->prescreened_patients[d.seq].person_id,
    ppp.prot_master_id = request->protocol_id, ppp.screener_person_id = request->screener_id, ppp
    .screened_dt_tm = cnvtdatetime(sysdate),
    ppp.screening_status_cd = pending_cd, ppp.added_via_flag = added_via_he, ppp.updt_dt_tm =
    cnvtdatetime(sysdate)
   PLAN (d)
    JOIN (ppp)
   WITH nocounter
  ;end insert
 ENDIF
 SET current_cnt = size(request->prescreened_patients,5)
 IF ((request->job_id > 0))
  SELECT INTO "nl:"
   FROM ct_prot_prescreen_job_info cji
   WHERE (cji.ct_prescreen_job_id=request->job_id)
   WITH nocounter, forupdatewait(cji)
  ;end select
  UPDATE  FROM ct_prot_prescreen_job_info cji
   SET cji.curr_eval_pat_cnt = (cji.curr_eval_pat_cnt+ current_cnt), cji.updt_dt_tm = cnvtdatetime(
     sysdate), cji.updt_cnt = (cji.updt_cnt+ 1)
   WHERE (cji.ct_prescreen_job_id=request->job_id)
  ;end update
  DECLARE failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"FAILED"))
  DECLARE job_end_ind = i2 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM ct_prot_prescreen_job_info cji
   WHERE (cji.ct_prescreen_job_id=request->job_id)
   DETAIL
    IF (cji.total_eval_pat_cnt=cji.curr_eval_pat_cnt)
     job_end_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (job_end_ind=1)
   DECLARE complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"COMPLETE"))
   UPDATE  FROM ct_prescreen_job cj
    SET cj.job_status_cd = complete_cd, cj.job_end_dt_tm = cnvtdatetime(sysdate)
    WHERE (cj.ct_prescreen_job_id=request->job_id)
     AND cj.job_status_cd != failed_cd
   ;end update
   UPDATE  FROM ct_prot_prescreen_job_info cji
    SET cji.completed_flag = 1
    WHERE (cji.ct_prescreen_job_id=request->job_id)
   ;end update
  ENDIF
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("Transaction error, changes rolled back")
 ELSE
  COMMIT
 ENDIF
END GO
