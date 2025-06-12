CREATE PROGRAM bbt_get_exception:dba
 RECORD reply(
   1 qual[*]
     2 updt_cnt = i4
     2 exception_id = f8
     2 product_nbr = c20
     2 product_type = vc
     2 cur_expire_dt_tm = dq8
     2 accession = c20
     2 physician_name_full_formatted = c100
     2 patient_name_full_formatted = c100
     2 usr_name_full_formatted = c100
     2 alias = c200
     2 reason = c20
     2 active_status_dt_tm = dq8
     2 review_dt_tm = dq8
     2 review_status_cd = f8
     2 review_by_prsnl_id = f8
     2 review_doc_id = f8
     2 long_text = vc
     2 patient_abo_rh = c20
     2 product_abo_rh = c20
     2 current_abo_rh = c20
     2 resulted_abo_rh = c20
     2 previous_abo_rh = c20
     2 product_antigens = c20
     2 patient_antibodies = c20
     2 transfusion_req = c20
     2 product_att = c20
     2 product_sub_nbr = c20
     2 procedure = c20
     2 result = c20
     2 donor_name_full_formatted = c100
     2 donor_nbr = c20
     2 donor_abo_rh = c20
     2 eligibility_status = c20
     2 donation_procedure = c20
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
 RECORD trnreq(
   1 req_list[*]
     2 trn_code = f8
     2 trn_display = c20
 )
 SET stat = alterlist(reply->qual,10)
 SET qual_index = 0
 SET mrn_code = 0.0
 SET encntr_mrn_code = 0.0
 SET admitdoc = 0.0
 SET donorid_code = 0.0
 SET inprocess_code = 0.0
 IF (((trim(request->cdf_meaning)="EXPUNITXM") OR (((trim(request->cdf_meaning)="EXPUNITDIS") OR (((
 trim(request->cdf_meaning)="UNCONFDIS") OR (((trim(request->cdf_meaning)="UNMATXM") OR (((trim(
  request->cdf_meaning)="NOTREQDIS") OR (((trim(request->cdf_meaning)="EXPSPECIMEN") OR (((trim(
  request->cdf_meaning)="EXPXMDIS") OR (((trim(request->cdf_meaning)="NOAGDIS") OR (((trim(request->
  cdf_meaning)="UNCORSSIDS") OR (trim(request->cdf_meaning)="UNMATDIS")) )) )) )) )) )) )) )) )) )
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=319
    AND c.cdf_meaning="MRN"
    AND c.active_ind=1
   DETAIL
    encntr_mrn_code = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="EXPUNITXM") OR (((trim(request->cdf_meaning)="EXPUNITDIS") OR (((
 trim(request->cdf_meaning)="EXPSPECIMEN") OR (((trim(request->cdf_meaning)="EXPXMDIS") OR (((trim(
  request->cdf_meaning)="NOTREQDIS") OR (((trim(request->cdf_meaning)="NOAGDIS") OR (((trim(request->
  cdf_meaning)="UNCORSSIDS") OR (((trim(request->cdf_meaning)="UNMATDIS") OR (((trim(request->
  cdf_meaning)="UNCONFDIS") OR (trim(request->cdf_meaning)="UNMATXM")) )) )) )) )) )) )) )) )) )
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=4
    AND c.cdf_meaning="MRN"
    AND c.active_ind=1
   DETAIL
    mrn_code = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=16229
   AND c.cdf_meaning="INPROCESS"
   AND c.active_ind=1
  DETAIL
   inprocess_code = c.code_value
  WITH nocounter
 ;end select
 IF (((trim(request->cdf_meaning)="EXPUNITXM") OR (((trim(request->cdf_meaning)="EXPUNITDIS") OR (((
 trim(request->cdf_meaning)="EXPSPECIMEN") OR (((trim(request->cdf_meaning)="EXPXMDIS") OR (((trim(
  request->cdf_meaning)="NOAGDIS") OR (((trim(request->cdf_meaning)="NOTREQDIS") OR (((trim(request->
  cdf_meaning)="PTGTCHG") OR (((trim(request->cdf_meaning)="PTGTNOCHG") OR (((trim(request->
  cdf_meaning)="UNCORSSIDS") OR (((trim(request->cdf_meaning)="UNMATDIS") OR (((trim(request->
  cdf_meaning)="UNCONFDIS") OR (((trim(request->cdf_meaning)="UNMATXM") OR (((trim(request->
  cdf_meaning)="UNGTCHG") OR (trim(request->cdf_meaning)="UNGTNOCHG")) )) )) )) )) )) )) )) )) )) ))
 )) )) )
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=333
    AND c.cdf_meaning="ADMITDOC"
    AND c.active_ind=1
   DETAIL
    admitdoc = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="DONINELIG") OR (((trim(request->cdf_meaning)="DONPERM") OR (((trim
 (request->cdf_meaning)="DONPERMOVER") OR (((trim(request->cdf_meaning)="REGPERM") OR (((trim(request
  ->cdf_meaning)="REGPERMOVER") OR (((trim(request->cdf_meaning)="REGINELIG") OR (((trim(request->
  cdf_meaning)="DONVOLEXCD") OR (((trim(request->cdf_meaning)="REGVOLEXCD") OR (((trim(request->
  cdf_meaning)="DONDIRNOMATC") OR (trim(request->cdf_meaning)="REGDIRNOMATC")) )) )) )) )) )) )) ))
 )) )
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=4
    AND c.cdf_meaning="DONORID"
    AND c.active_ind=1
   DETAIL
    donorid_code = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="DONDIRNOMATC") OR (((trim(request->cdf_meaning)="REGDIRNOMATC")
  OR (((trim(request->cdf_meaning)="UNCONFDIS") OR (((trim(request->cdf_meaning)="UNMATXM") OR (((
 trim(request->cdf_meaning)="UNGTCHG") OR (((trim(request->cdf_meaning)="UNGTNOCHG") OR (((trim(
  request->cdf_meaning)="EXPSPECIMEN") OR (((trim(request->cdf_meaning)="EXPXMDIS") OR (((trim(
  request->cdf_meaning)="NOAGDIS") OR (((trim(request->cdf_meaning)="NOTREQDIS") OR (((trim(request->
  cdf_meaning)="PTGTCHG") OR (((trim(request->cdf_meaning)="PTGTNOCHG") OR (((trim(request->
  cdf_meaning)="UNCORSSIDS") OR (trim(request->cdf_meaning)="UNMATDIS")) )) )) )) )) )) )) )) )) ))
 )) )) )) )
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
 ENDIF
 IF (((trim(request->cdf_meaning)="NOAGDIS") OR (trim(request->cdf_meaning)="NOTREQDIS")) )
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
 ENDIF
 IF (trim(request->cdf_meaning)="NOAGDIS")
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
 ENDIF
 IF (trim(request->cdf_meaning)="NOTREQDIS")
  SET stat = alterlist(trnreq->req_list,10)
  SET req_idx = 0
  SELECT INTO "nl:"
   FROM code_value c1
   WHERE c1.code_set=1611
    AND c1.code_value > 0
   DETAIL
    req_idx = (req_idx+ 1)
    IF (mod(req_idx,10)=1
     AND req_idx != 1)
     stat = alterlist(trnreq->req_list,(req_idx+ 9))
    ENDIF
    trnreq->req_list[req_idx].trn_code = c1.code_value, trnreq->req_list[req_idx].trn_display = c1
    .display
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET stat = alterlist(trnreq->req_list,req_idx)
  ENDIF
 ENDIF
 IF (((trim(request->cdf_meaning)="NOAGDIS") OR (trim(request->cdf_meaning)="NOTREQDIS")) )
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
 ENDIF
 IF (((trim(request->cdf_meaning)="EXPUNITXM") OR (trim(request->cdf_meaning)="EXPUNITDIS")) )
  SELECT INTO "nl:"
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   pr.cur_expire_dt_tm, bb.exception_id, bb.active_status_dt_tm,
   bb.person_id, bb.review_dt_tm, bb.review_status_cd,
   bb.review_by_prsnl_id, bb.review_doc_id, per.name_full_formatted,
   ea.alias, prs.name_full_formatted, usr.name_full_formatted,
   ac.accession
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person per,
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].product_type = uar_get_code_display(pr.product_cd), reply->qual[
     qual_index].cur_expire_dt_tm = pr.cur_expire_dt_tm, reply->qual[qual_index].accession = ac
     .accession,
     reply->qual[qual_index].patient_name_full_formatted = per.name_full_formatted, reply->qual[
     qual_index].physician_name_full_formatted = prs.name_full_formatted, reply->qual[qual_index].
     alias = ea.alias,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].review_dt_tm = bb.review_dt_tm, reply->qual[qual_index].review_status_cd
      = bb.review_status_cd, reply->qual[qual_index].review_by_prsnl_id = bb.review_by_prsnl_id,
     reply->qual[qual_index].review_doc_id = bb.review_doc_id
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(ea), dontcare(re), dontcare(epr)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="EXPSPECIMEN") OR (trim(request->cdf_meaning)="EXPXMDIS")) )
  SELECT INTO "nl:"
   xm.crossmatch_exp_dt_tm, pa.abo_cd, pa.rh_cd,
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   pr.cur_expire_dt_tm, bb.exception_id, bb.active_status_dt_tm,
   bb.person_id, bb.review_dt_tm, bb.review_status_cd,
   bb.review_by_prsnl_id, bb.review_doc_id, per.name_full_formatted,
   ea.alias, prs.name_full_formatted, usr.name_full_formatted,
   ac.accession
   FROM bb_exception bb,
    product_event pe,
    crossmatch xm,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 4),
    (dummyt d5  WITH seq = 5),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (xm
    WHERE pe.product_event_id=xm.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].product_type = uar_get_code_display(pr.product_cd), reply->qual[
     qual_index].cur_expire_dt_tm = xm.crossmatch_exp_dt_tm, reply->qual[qual_index].accession = ac
     .accession,
     reply->qual[qual_index].patient_name_full_formatted = per.name_full_formatted, reply->qual[
     qual_index].physician_name_full_formatted = prs.name_full_formatted, reply->qual[qual_index].
     alias = ea.alias,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].review_dt_tm = bb.review_dt_tm, reply->qual[qual_index].review_status_cd
      = bb.review_status_cd, reply->qual[qual_index].review_by_prsnl_id = bb.review_by_prsnl_id,
     reply->qual[qual_index].review_doc_id = bb.review_doc_id, idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].product_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].patient_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    outerjoin(d5), dontcare(ea), dontcare(re),
    dontcare(epr), dontcare(pa)
  ;end select
 ENDIF
 IF (trim(request->cdf_meaning)="NOAGDIS")
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_cnt, bb.active_status_dt_tm,
   bb.person_id, bb.review_dt_tm, bb.review_status_cd,
   bb.review_by_prsnl_id, bb.review_doc_id, bb1.exception_id,
   bb1.requirement_cd, bb1.special_testing_cd, pa.abo_cd,
   pa.rh_cd, pr.cur_expire_dt_tm, pe.event_dt_tm,
   pe.person_id, pe.product_event_id, pr.product_nbr,
   pr.product_sub_nbr, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.name_full_formatted, ac.accession
   FROM bb_exception bb,
    bb_reqs_exception bb1,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    (dummyt d6  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (((d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
    ) ORJOIN ((d5
    WHERE d5.seq=1)
    JOIN (bb1
    WHERE bb.exception_id=bb1.exception_id)
    ))
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].accession = ac.accession, reply->qual[qual_index].
     patient_name_full_formatted = per.name_full_formatted, reply->qual[qual_index].
     physician_name_full_formatted = prs.name_full_formatted,
     reply->qual[qual_index].alias = ea.alias, reply->qual[qual_index].reason = uar_get_code_display(
      bb.override_reason_cd), reply->qual[qual_index].usr_name_full_formatted = usr
     .name_full_formatted,
     reply->qual[qual_index].active_status_dt_tm = bb.active_status_dt_tm, reply->qual[qual_index].
     review_dt_tm = bb.review_dt_tm, reply->qual[qual_index].review_status_cd = bb.review_status_cd,
     reply->qual[qual_index].review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].
     review_doc_id = bb.review_doc_id, idx_a = 1,
     finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].product_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].patient_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= an_idx
      AND finish_flag="N")
       IF ((bb1.requirement_cd=anreq->an_list[idx_a].an_code))
        reply->qual[qual_index].patient_antibodies = anreq->an_list[idx_a].an_display, finish_flag =
        "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= st_idx
      AND finish_flag="N")
       IF ((bb1.special_testing_cd=streq->st_list[idx_a].st_code))
        reply->qual[qual_index].product_antigens = streq->st_list[idx_a].st_display, finish_flag =
        "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    outerjoin(d6), dontcare(ea), dontcare(re),
    dontcare(epr), dontcare(pa)
  ;end select
 ENDIF
 IF (trim(request->cdf_meaning)="NOTREQDIS")
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_cnt, bb.active_status_dt_tm,
   bb.person_id, bb.review_dt_tm, bb.review_status_cd,
   bb.review_by_prsnl_id, bb.review_doc_id, bb1.exception_id,
   bb1.requirement_cd, bb1.special_testing_cd, pa.abo_cd,
   pa.rh_cd, pr.cur_expire_dt_tm, pe.event_dt_tm,
   pe.person_id, pe.product_event_id, pr.product_nbr,
   pr.product_sub_nbr, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession
   FROM bb_exception bb,
    bb_reqs_exception bb1,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    (dummyt d6  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (((d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
    ) ORJOIN ((d5
    WHERE d5.seq=1)
    JOIN (bb1
    WHERE bb.exception_id=bb1.exception_id)
    ))
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].product_type = uar_get_code_display(pr.product_cd), reply->qual[
     qual_index].accession = ac.accession, reply->qual[qual_index].patient_name_full_formatted = per
     .name_full_formatted,
     reply->qual[qual_index].physician_name_full_formatted = prs.name_full_formatted, reply->qual[
     qual_index].alias = ea.alias, reply->qual[qual_index].reason = uar_get_code_display(bb
      .override_reason_cd),
     reply->qual[qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[
     qual_index].active_status_dt_tm = bb.active_status_dt_tm, reply->qual[qual_index].review_dt_tm
      = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].product_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].patient_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= req_idx
      AND finish_flag="N")
       IF ((bb1.requirement_cd=trnreq->req_list[idx_a].trn_code))
        reply->qual[qual_index].transfusion_req = trnreq->req_list[idx_a].trn_display, finish_flag =
        "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= st_idx
      AND finish_flag="N")
       IF ((bb1.special_testing_cd=streq->st_list[idx_a].st_code))
        reply->qual[qual_index].product_att = streq->st_list[idx_a].st_display, finish_flag = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    outerjoin(d6), dontcare(re), dontcare(epr),
    dontcare(pa)
  ;end select
 ENDIF
 IF (trim(request->cdf_meaning)="OVERINTERP")
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, dta.mnemonic, perr.result_value_alpha,
   perr.result_value_numeric, perr.result_value_dt_tm, per.name_full_formatted,
   pra.alias, ac.accession, pr.product_nbr,
   pr.product_sub_nbr
   FROM (dummyt d2  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    discrete_task_assay dta,
    perform_result perr,
    result re,
    orders o,
    (dummyt d4  WITH seq = 1),
    person per,
    person_alias pra,
    (dummyt d5  WITH seq = 1),
    accession_order_r ac,
    (dummyt d6  WITH seq = 1),
    product pr
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (perr
    WHERE bb.perform_result_id=perr.perform_result_id
     AND bb.result_id=perr.result_id)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (dta
    WHERE re.task_assay_cd=dta.task_assay_cd)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pr
    WHERE o.product_id=pr.product_id
     AND pr.product_id > 0)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (per
    WHERE o.person_id=per.person_id)
    JOIN (pra
    WHERE pra.person_alias_type_cd=mrn_code
     AND o.person_id=pra.person_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].patient_name_full_formatted = per.name_full_formatted, reply->qual[
     qual_index].alias = pra.alias, reply->qual[qual_index].reason = uar_get_code_display(bb
      .override_reason_cd),
     reply->qual[qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[
     qual_index].active_status_dt_tm = bb.active_status_dt_tm, reply->qual[qual_index].review_dt_tm
      = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].procedure = dta.mnemonic, reply->qual[qual_index].result = perr
     .result_value_alpha, reply->qual[qual_index].product_sub_nbr = pr.product_sub_nbr
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d4), outerjoin(d5),
    outerjoin(d6), dontcare(ac), dontcare(pr),
    dontcare(c3)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="PTGTCHG") OR (trim(request->cdf_meaning)="PTGTNOCHG")) )
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   pa.abo_cd, pa.rh_cd, per.name_full_formatted,
   pra.alias, prs.name_full_formatted, usr.username,
   ac.accession
   FROM bb_exception bb,
    person_aborh pa,
    person per,
    person_alias pra,
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac,
    orders o
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (per
    WHERE o.person_id=per.person_id)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=mrn_code
     AND o.person_id=pra.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE o.person_id=pa.person_id
     AND pa.active_ind=1)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].accession = ac.accession,
     reply->qual[qual_index].patient_name_full_formatted = per.name_full_formatted, reply->qual[
     qual_index].physician_name_full_formatted = prs.name_full_formatted, reply->qual[qual_index].
     alias = pra.alias,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].review_dt_tm = bb.review_dt_tm, reply->qual[qual_index].review_status_cd
      = bb.review_status_cd, reply->qual[qual_index].review_by_prsnl_id = bb.review_by_prsnl_id,
     reply->qual[qual_index].review_doc_id = bb.review_doc_id, idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bb.from_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bb.from_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].previous_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bb.to_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bb.to_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].resulted_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].current_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d3), outerjoin(d4), outerjoin(d5)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="UNCROSSDIS") OR (((trim(request->cdf_meaning)="UNMATDIS") OR (((
 trim(request->cdf_meaning)="UNMATXM") OR (trim(request->cdf_meaning)="UNCONFDIS")) )) )) )
  SELECT INTO "nl:"
   pa.abo_cd, pa.rh_cd, pr.cur_expire_dt_tm,
   pe.event_dt_tm, pe.person_id, pe.product_event_id,
   pr.product_nbr, pr.product_sub_nbr, bb.exception_id,
   bb.updt_cnt, bb.active_status_dt_tm, bb.person_id,
   bb.review_dt_tm, bb.review_status_cd, bb.review_by_prsnl_id,
   bb.review_doc_id, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    encntr_alias ea,
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_nbr = pr.product_nbr,
     reply->qual[qual_index].product_type = uar_get_code_display(pr.product_cd), reply->qual[
     qual_index].cur_expire_dt_tm = pr.cur_expire_dt_tm, reply->qual[qual_index].accession = ac
     .accession,
     reply->qual[qual_index].patient_name_full_formatted = per.name_full_formatted, reply->qual[
     qual_index].physician_name_full_formatted = prs.name_full_formatted, reply->qual[qual_index].
     alias = ea.alias,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].review_dt_tm = bb.review_dt_tm, reply->qual[qual_index].review_status_cd
      = bb.review_status_cd, reply->qual[qual_index].review_by_prsnl_id = bb.review_by_prsnl_id,
     reply->qual[qual_index].review_doc_id = bb.review_doc_id, idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].product_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].patient_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    outerjoin(d5), dontcare(ea), dontcare(re),
    dontcare(epr), dontcare(pa)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="UNGTCHG") OR (trim(request->cdf_meaning)="UNGTNOCHG")) )
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, pr.product_nbr, pr.product_sub_nbr,
   ac.accession
   FROM code_value c1,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    product pr,
    blood_product bp,
    prsnl prs,
    encntr_prsnl_reltn epr,
    result re,
    orders o,
    accession_order_r ac
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (pr
    WHERE o.product_id=pr.product_id)
    JOIN (bp
    WHERE pr.product_id=bp.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].product_type = uar_get_code_display(pr.proudct_cd),
     reply->qual[qual_index].product_nbr = pr.product_nbr, reply->qual[qual_index].
     physician_name_full_formatted = prs.name_full_formatted, reply->qual[qual_index].reason =
     uar_get_code_display(bb.override_reason_cd),
     reply->qual[qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[
     qual_index].active_status_dt_tm = bb.active_status_dt_tm, reply->qual[qual_index].review_dt_tm
      = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].accession = ac.accession, idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bb.from_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bb.from_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].previous_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bb.to_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bb.to_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].resulted_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].current_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d2), outerjoin(d3)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="DONINELIG") OR (((trim(request->cdf_meaning)="DONPERM") OR (((trim
 (request->cdf_meaning)="DONPERMOVER") OR (((trim(request->cdf_meaning)="REGPERM") OR (trim(request->
  cdf_meaning)="REGPERMOVER")) )) )) )) )
  SELECT INTO "nl:"
   bb.active_status_dt_tm, bb.exception_id, bb.updt_dt_tm,
   bb.updt_cnt, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, do.person_id, pra.alias
   FROM bb_exception bb,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    prsnl usr,
    result re,
    bbd_donor_contact do,
    person dnr,
    person_alias pra,
    person_donor pd,
    bbd_donation_results dr
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (do
    WHERE bb.donor_contact_id=do.contact_id)
    JOIN (dnr
    WHERE do.person_id=dnr.person_id)
    JOIN (pd
    WHERE do.person_id=pd.person_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (dr
    WHERE dr.person_id=do.person_id
     AND dr.encntr_id=do.encntr_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=donorid_code
     AND do.person_id=pra.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].review_dt_tm = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].donor_name_full_formatted = dnr.name_full_formatted, reply->qual[
     qual_index].donor_nbr = pra.alias, reply->qual[qual_index].eligibility_status =
     uar_get_code_display(pd.eligibility_type_cd),
     reply->qual[qual_index].donation_procedure = uar_get_code_display(dr.procedure_cd)
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d1), outerjoin(d2), outerjoin(d3),
    outerjoin(d4), dontcare(re), dontcare(pra),
    dontcare(dr)
  ;end select
 ENDIF
 IF (trim(request->cdf_meaning)="REGINELIG")
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, do.person_id, pra.alias
   FROM (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    result re,
    bbd_donor_contact do,
    person dnr,
    person_alias pra,
    person_donor pd
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (do
    WHERE bb.donor_contact_id=do.contact_id)
    JOIN (dnr
    WHERE do.person_id=dnr.person_id)
    JOIN (pd
    WHERE do.person_id=pd.person_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=donorid_code
     AND do.person_id=pra.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].review_dt_tm = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].donor_name_full_formatted = dnr.name_full_formatted, reply->qual[
     qual_index].donor_nbr = pra.alias, reply->qual[qual_index].eligibility_status =
     uar_get_code_display(pd.eligibility_type_cd)
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d1), outerjoin(d2), outerjoin(d3),
    dontcare(re), dontcare(pra), dontcare(dr)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="DONVOLEXCD") OR (trim(request->cdf_meaning)="REGVOLEXCD")) )
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, do.person_id, pra.alias
   FROM (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    result re,
    bbd_donor_contact do,
    person dnr,
    person_alias pra
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (do
    WHERE bb.donor_contact_id=do.contact_id)
    JOIN (dnr
    WHERE do.person_id=dnr.person_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=donorid_code
     AND do.person_id=pra.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].review_dt_tm = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].donor_name_full_formatted = dnr.name_full_formatted, reply->qual[
     qual_index].donor_nbr = pra.alias
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d1), outerjoin(d2), outerjoin(d3),
    dontcare(re), dontcare(pra), dontcare(dr)
  ;end select
 ENDIF
 IF (((trim(request->cdf_meaning)="DONDIRNOMATC") OR (trim(request->cdf_meaning)="REGDIRNOMATC")) )
  SELECT INTO "nl:"
   bb.exception_id, bb.updt_dt_tm, bb.updt_cnt,
   bb.active_status_dt_tm, bb.person_id, bb.review_dt_tm,
   bb.review_status_cd, bb.review_by_prsnl_id, bb.review_doc_id,
   usr.username, do.person_id, pra.alias,
   pra1.alias, pa.abo_cd, pa.rh_cd,
   pa1.abo_cd, pa1.rh_cd, per.name_full_formatted
   FROM (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    (dummyt d6  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    result re,
    bbd_donor_contact do,
    person dnr,
    person_alias pra,
    person_alias pra1,
    person per,
    person_aborh pa,
    person_aborh pa1
   PLAN (bb
    WHERE bb.active_status_dt_tm >= cnvtdatetime(request->beg_dt_tm)
     AND bb.active_status_dt_tm <= cnvtdatetime(request->end_dt_tm)
     AND (bb.exception_id > request->last_exception_id)
     AND bb.exception_type_cd=cnvtint(request->exception_type_cd)
     AND ((bb.review_status_cd=0) OR (bb.review_status_cd=inprocess_code)) )
    JOIN (per
    WHERE bb.person_id=per.person_id)
    JOIN (do
    WHERE bb.donor_contact_id=do.contact_id)
    JOIN (dnr
    WHERE do.person_id=dnr.person_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=donorid_code
     AND do.person_id=pra.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pra1
    WHERE pra1.person_alias_type_cd=mrn_code
     AND bb.person_id=pra1.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (usr
    WHERE bb.active_status_prsnl_id=usr.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (pa
    WHERE bb.person_id=pa.person_id
     AND pa.active_ind=1)
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pa1
    WHERE dnr.person_id=pa1.person_id
     AND pa1.active_ind=1)
   DETAIL
    IF (bb.exception_id > 0)
     qual_index = (qual_index+ 1)
     IF (mod(qual_index,10)=1
      AND qual_index != 1)
      stat = alterlist(reply->qual,(qual_index+ 9))
     ENDIF
     reply->qual[qual_index].exception_id = bb.exception_id, reply->qual[qual_index].updt_cnt = bb
     .updt_cnt, reply->qual[qual_index].review_dt_tm = bb.review_dt_tm,
     reply->qual[qual_index].review_status_cd = bb.review_status_cd, reply->qual[qual_index].
     review_by_prsnl_id = bb.review_by_prsnl_id, reply->qual[qual_index].review_doc_id = bb
     .review_doc_id,
     reply->qual[qual_index].reason = uar_get_code_display(bb.override_reason_cd), reply->qual[
     qual_index].usr_name_full_formatted = usr.name_full_formatted, reply->qual[qual_index].
     active_status_dt_tm = bb.active_status_dt_tm,
     reply->qual[qual_index].donor_name_full_formatted = dnr.name_full_formatted, reply->qual[
     qual_index].donor_nbr = pra.alias, reply->qual[qual_index].patient_name_full_formatted = per
     .name_full_formatted,
     reply->qual[qual_index].alias = pra1.alias, idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa1.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa1.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].donor_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag =
        "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((pa.abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (pa.rh_cd=aborh->aborh_list[idx_a].rh_code))
        reply->qual[qual_index].patient_abo_rh = aborh->aborh_list[idx_a].aborh_display, finish_flag
         = "Y"
       ELSE
        idx_a = (idx_a+ 1)
       ENDIF
     ENDWHILE
    ENDIF
   WITH nocounter, orahint("index (bb xie7bb_exception)"), maxqual(bb,100),
    outerjoin(d1), outerjoin(d2), outerjoin(d3),
    outerjoin(d4), outerjoin(d5), outerjoin(d6),
    dontcare(re), dontcare(pra), dontcare(pra1),
    dontcare(dr), dontcare(pa), dontcare(pa1)
  ;end select
 ENDIF
 SET stat = alterlist(reply->qual,qual_index)
 IF (value(qual_index) > 0)
  SELECT INTO "nl:"
   FROM long_text l,
    (dummyt d  WITH seq = value(qual_index))
   PLAN (d)
    JOIN (l
    WHERE (l.long_text_id=reply->qual[d.seq].review_doc_id)
     AND l.long_text_id != 0)
   DETAIL
    reply->qual[d.seq].long_text = l.long_text
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
