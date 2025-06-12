CREATE PROGRAM ct_get_pt_batch_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 plist[*]
      2 person_id = f8
      2 name_last = vc
      2 name_first = vc
      2 mrns[*]
        3 mrn = vc
        3 alias_pool_cd = f8
        3 alias_pool_disp = vc
        3 alias_pool_desc = vc
        3 alias_pool_mean = c12
      2 added_by_person = vc
      2 added_dt_tm = dq8
    1 pts_removed_ind = i2
    1 tw_accrual = i4
    1 site_accrual = i4
    1 tw_targeted_accrual = i4
    1 site_targeted_accrual = i4
    1 accrual_estimate_only_ind = i2
    1 track_tw_accrual = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD enrolls(
   1 plist[*]
     2 person_id = f8
 )
 RECORD accrual_request(
   1 prot_amendment_id = f8
   1 prot_master_id = f8
   1 requiredaccrualcd = f8
   1 person_id = f8
   1 person_list[*]
     2 person_id = f8
   1 participation_type_cd = f8
   1 application_nbr = i4
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
 )
 RECORD accrual_reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 accrual_estimate_only_ind = i2
   1 track_tw_accrual = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cnte = i4 WITH protect, noconstant(0)
 DECLARE cntm = i4 WITH protect, noconstant(0)
 DECLARE badd = i2 WITH protect, noconstant(0)
 DECLARE mrn = f8 WITH protect, noconstant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE yes_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17438,"YES"))
 DECLARE enroll_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17349,"ENROLLING"))
 SELECT INTO "nl:"
  consent_id = decode(pc.seq,pc.consent_id,0.0)
  FROM ct_pt_prot_batch_list bl,
   person pt,
   person p,
   person_alias p_a,
   pt_prot_reg ppr,
   prot_amendment pa,
   pt_consent pc,
   dummyt d1
  PLAN (bl
   WHERE (bl.prot_master_id=request->prot_master_id))
   JOIN (pt
   WHERE pt.person_id=bl.person_id)
   JOIN (p
   WHERE p.person_id=bl.updt_id)
   JOIN (p_a
   WHERE p_a.person_id=outerjoin(pt.person_id)
    AND p_a.person_alias_type_cd=outerjoin(mrn)
    AND ((p_a.active_ind+ 0)=outerjoin(1))
    AND p_a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND p_a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ppr
   WHERE ppr.prot_master_id=outerjoin(request->prot_master_id)
    AND ppr.person_id=outerjoin(bl.person_id)
    AND ppr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pa
   WHERE (pa.prot_master_id=request->prot_master_id))
   JOIN (d1)
   JOIN (pc
   WHERE pc.person_id=bl.person_id
    AND pc.prot_amendment_id=pa.prot_amendment_id
    AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pc.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pc.not_returned_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pc.reason_for_consent_cd=enroll_cd)
  ORDER BY bl.person_id
  HEAD REPORT
   cnt = 0, cnte = 0
  HEAD bl.person_id
   cntm = 0, badd = 0
   IF (ppr.reg_id=0
    AND consent_id=0)
    badd = 1, cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->plist,(cnt+ 9))
    ENDIF
    reply->plist[cnt].person_id = bl.person_id, reply->plist[cnt].name_last = pt.name_last, reply->
    plist[cnt].name_first = pt.name_first,
    reply->plist[cnt].added_dt_tm = bl.updt_dt_tm
   ELSE
    cnte = (cnte+ 1)
    IF (mod(cnte,10)=1)
     stat = alterlist(enrolls->plist,(cnte+ 9))
    ENDIF
    enrolls->plist[cnte].person_id = bl.person_id
   ENDIF
  HEAD p.person_id
   IF (badd=1)
    reply->plist[cnt].added_by_person = p.name_full_formatted
   ENDIF
  DETAIL
   IF (badd=1)
    IF (size(trim(p_a.alias),1) > 0)
     cntm = (cntm+ 1)
     IF (mod(cntm,10)=1)
      stat = alterlist(reply->plist[cnt].mrns,(cntm+ 10))
     ENDIF
     reply->plist[cnt].mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->plist[
     cnt].mrns[cntm].alias_pool_cd = p_a.alias_pool_cd
    ENDIF
   ENDIF
  FOOT  bl.person_id
   IF (badd=1)
    stat = alterlist(reply->plist[cnt].mrns,cntm)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->plist,cnt), stat = alterlist(enrolls->plist,cnte)
  WITH nocounter, outerjoin = d1, dontcare = pc
 ;end select
 SET stat = initrec(accrual_request)
 SET accrual_request->prot_master_id = request->prot_master_id
 SET accrual_request->requiredaccrualcd = yes_cd
 EXECUTE ct_get_validate_target_accrual  WITH replace("REPLY","ACCRUAL_REPLY"), replace("REQUEST",
  "ACCRUAL_REQUEST")
 CALL echorecord(accrual_reply)
 SET reply->tw_accrual = accrual_reply->grouptargetaccrued
 SET reply->site_accrual = accrual_reply->totalaccrued
 SET reply->tw_targeted_accrual = accrual_reply->grouptargetaccrual
 SET reply->site_targeted_accrual = accrual_reply->targetaccrual
 SET reply->accrual_estimate_only_ind = accrual_reply->accrual_estimate_only_ind
 SET reply->track_tw_accrual = accrual_reply->track_tw_accrual
 IF (cnte > 0
  AND 1=0)
  DELETE  FROM ct_pt_prot_batch_list bl,
    (dummyt d  WITH seq = value(size(enrolls->plist,5)))
   SET bl.seq = 1
   PLAN (d)
    JOIN (bl
    WHERE (bl.person_id=enrolls->plist[d.seq].person_id)
     AND (bl.prot_master_id=request->prot_master_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL echo("Error deleting")
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SET last_mod = "002"
 SET mod_date = "Feb 22, 2018"
END GO
