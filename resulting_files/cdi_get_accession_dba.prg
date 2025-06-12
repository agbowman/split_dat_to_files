CREATE PROGRAM cdi_get_accession:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 accession_qual[*]
      2 accession = vc
      2 accession_fmt = vc
      2 accession_id = f8
      2 collect_dt_tm = dq8
      2 collect_tz = i4
      2 order_name = vc
      2 receive_dt_tm = dq8
      2 receive_tz = i4
      2 birth_date = dq8
      2 birth_tz = i4
      2 gender = vc
      2 ordering_phys = vc
      2 org_id = f8
      2 facility = vc
      2 patient_name = vc
      2 person_id = f8
      2 mrn = vc
      2 encntr_nbr = vc
      2 encntr_id = f8
      2 order_id = f8
      2 exam_reason = vc
      2 request_dt_tm = dq8
      2 order_type = i4
      2 exam_status_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE accrtl
 SET reply->status_data.status = "F"
 DECLARE accession_rows = i4 WITH noconstant(value(size(request->accession_qual,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE acc_count = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE tempaccession = vc WITH noconstant("")
 SET ord_action_type_codeset = 6003
 SET ord_action_type_order_cdf = "ORDER"
 DECLARE ord_action_type_order_cd = f8
 SET ord_action_type_order_cd = uar_get_code_by("MEANING",ord_action_type_codeset,nullterm(
   ord_action_type_order_cdf))
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE fin_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 DECLARE null_vc = vc WITH constant("")
 DECLARE sec_org_reltn = i4 WITH noconstant(0)
 DECLARE isconfidsecurityon = i4 WITH noconstant(0)
 DECLARE duserid = f8 WITH noconstant(0.0)
 DECLARE bstatus = i2 WITH noconstant(0)
 DECLARE getuserorgs(duserid_in=f8) = i2
 DECLARE checkencntrorgsecurity(dorgid=f8,dordconflevelcd=f8) = i2
 DECLARE confidentiality_codeset = f8 WITH public, noconstant(87.0)
 DECLARE conf_count = i4 WITH noconstant(0), protect
 FREE RECORD user_orgs
 RECORD user_orgs(
   1 list[*]
     2 organization_id = f8
     2 confid_level_cd = f8
     2 collation_seq = i4
 )
 FREE RECORD conf_codeset
 RECORD conf_codeset(
   1 list[*]
     2 confid_level_cd = f8
     2 collation_seq = i4
 )
 SET duserid = reqinfo->updt_id
 SELECT INTO "nl:"
  d.seq
  FROM dm_info d
  WHERE d.info_name="SEC_ORG_RELTN"
   AND d.info_domain="SECURITY"
  DETAIL
   IF (d.info_number > 0)
    sec_org_reltn = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (sec_org_reltn=1)
  SET bstatus = getuserorgs(duserid)
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM dm_info d
  WHERE d.info_name="SEC_CONFID"
   AND d.info_domain="SECURITY"
  DETAIL
   IF (d.info_number > 0)
    isconfidsecurityon = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (isconfidsecurityon=1)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=confidentiality_codeset
    AND cv.active_ind=1
   DETAIL
    conf_count = (conf_count+ 1)
    IF (mod(conf_count,10)=1)
     stat = alterlist(conf_codeset->list,(conf_count+ 9))
    ENDIF
    conf_codeset->list[conf_count].confid_level_cd = cv.code_value, conf_codeset->list[conf_count].
    collation_seq = cv.seq
   FOOT REPORT
    stat = alterlist(conf_codeset->list,conf_count)
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  aor.accession, aor.accession_id, o.order_id,
  o.person_id, o.encntr_id, orr.order_id,
  orr.reason_for_exam, orr.request_dt_tm, p.birth_dt_tm,
  gender = uar_get_code_display(p.sex_cd), o.orig_order_dt_tm, o.current_start_dt_tm,
  o.order_mnemonic, mrn = pa2.alias, oa.action_personnel_id,
  facility = uar_get_code_display(e.loc_facility_cd)
  FROM (dummyt d  WITH seq = value(size(request->accession_qual,5))),
   accession_order_r aor,
   orders o,
   order_action oa,
   prsnl oa_pl,
   person p,
   encounter e,
   person_alias pa2,
   encntr_alias ea2,
   order_radiology orr
  PLAN (d)
   JOIN (aor
   WHERE (((aor.accession=request->accession_qual[d.seq].accession)
    AND textlen(request->accession_qual[d.seq].accession) > 1
    AND (0.0=request->accession_qual[d.seq].accession_id)) OR ((((aor.accession_id=request->
   accession_qual[d.seq].accession_id)
    AND textlen(request->accession_qual[d.seq].accession) <= 1
    AND (request->accession_qual[d.seq].accession_id > 0.0)) OR ((aor.accession_id=request->
   accession_qual[d.seq].accession_id)
    AND (aor.accession=request->accession_qual[d.seq].accession))) )) )
   JOIN (o
   WHERE o.order_id=aor.order_id)
   JOIN (orr
   WHERE outerjoin(o.order_id)=orr.order_id)
   JOIN (oa
   WHERE outerjoin(o.order_id)=oa.order_id)
   JOIN (oa_pl
   WHERE outerjoin(oa.action_personnel_id)=oa_pl.person_id
    AND outerjoin(0.0) < oa_pl.person_id)
   JOIN (p
   WHERE outerjoin(o.person_id)=p.person_id)
   JOIN (e
   WHERE outerjoin(o.encntr_id)=e.encntr_id)
   JOIN (pa2
   WHERE outerjoin(o.person_id)=pa2.person_id
    AND outerjoin(mrn_cd)=pa2.person_alias_type_cd)
   JOIN (ea2
   WHERE outerjoin(o.encntr_id)=ea2.encntr_id
    AND outerjoin(fin_cd)=ea2.encntr_alias_type_cd)
  HEAD aor.accession
   acc_count = (acc_count+ 1)
   IF (checkencntrorgsecurity(e.organization_id,e.confid_level_cd)=1)
    IF (mod(acc_count,10)=1)
     stat = alterlist(reply->accession_qual,(acc_count+ 9))
    ENDIF
    reply->accession_qual[acc_count].accession = aor.accession, reply->accession_qual[acc_count].
    accession_fmt = uar_accformatunformatted(aor.accession,0), reply->accession_qual[acc_count].
    accession_id = aor.accession_id,
    reply->accession_qual[acc_count].collect_dt_tm = o.current_start_dt_tm, reply->accession_qual[
    acc_count].collect_tz = o.current_start_tz, reply->accession_qual[acc_count].order_name = o
    .order_mnemonic,
    reply->accession_qual[acc_count].receive_dt_tm = o.orig_order_dt_tm, reply->accession_qual[
    acc_count].receive_tz = o.orig_order_tz, reply->accession_qual[acc_count].birth_date = p
    .birth_dt_tm,
    reply->accession_qual[acc_count].birth_tz = p.birth_tz, reply->accession_qual[acc_count].gender
     = gender, reply->accession_qual[acc_count].ordering_phys = oa_pl.name_full_formatted,
    reply->accession_qual[acc_count].org_id = e.organization_id, reply->accession_qual[acc_count].
    patient_name = trim(p.name_full_formatted,3), reply->accession_qual[acc_count].person_id = p
    .person_id,
    reply->accession_qual[acc_count].mrn = pa2.alias, reply->accession_qual[acc_count].encntr_nbr =
    ea2.alias, reply->accession_qual[acc_count].facility = facility,
    reply->accession_qual[acc_count].encntr_id = e.encntr_id, reply->accession_qual[acc_count].
    order_id = o.order_id, reply->accession_qual[acc_count].exam_reason = orr.reason_for_exam,
    reply->accession_qual[acc_count].request_dt_tm = orr.request_dt_tm
    IF (orr.order_id > 0)
     reply->accession_qual[acc_count].order_type = 1
    ELSE
     reply->accession_qual[acc_count].order_type = 0
    ENDIF
    reply->accession_qual[acc_count].exam_status_cd = orr.exam_status_cd
   ELSE
    acc_count = (acc_count - 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->accession_qual,acc_count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SUBROUTINE getuserorgs(duserid_in)
   DECLARE lorgcount = i4 WITH noconstant(0)
   DECLARE lindex = i4 WITH noconstant(0)
   FREE RECORD get_orgs_request
   RECORD get_orgs_request(
     1 action_flag = i2
     1 user_id = f8
   )
   FREE RECORD get_orgs_reply
   RECORD get_orgs_reply(
     1 valid_orgs[*]
       2 org_id = f8
       2 org_name = vc
       2 confid_level_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET get_orgs_request->action_flag = 1
   SET get_orgs_request->user_id = duserid_in
   EXECUTE pm_get_orgs_for_user  WITH replace("REQUEST","GET_ORGS_REQUEST"), replace("REPLY",
    "GET_ORGS_REPLY")
   IF ((get_orgs_reply->status_data.status="F"))
    SET dummyvar = setstatusblock("S","GET","F","GetUserOrgs","pm_get_orgs_for_user failed")
    RETURN(0)
   ENDIF
   SET lorgcount = size(get_orgs_reply->valid_orgs,5)
   IF (lorgcount > 0)
    SET stat = alterlist(user_orgs->list,lorgcount)
    FOR (lindex = 1 TO lorgcount)
      SET user_orgs->list[lindex].organization_id = get_orgs_reply->valid_orgs[lindex].org_id
      SET user_orgs->list[lindex].confid_level_cd = get_orgs_reply->valid_orgs[lindex].
      confid_level_cd
      SET user_orgs->list[lindex].collation_seq = 0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=confidentiality_codeset
        AND cv.active_ind=1
        AND (cv.code_value=user_orgs->list[lindex].confid_level_cd)
       DETAIL
        user_orgs->list[lindex].collation_seq = cv.collation_seq
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE checkencntrorgsecurity(dorgid,dordconflevelcd)
   DECLARE lindex = i4 WITH noconstant(0)
   DECLARE lconfindex = i4 WITH noconstant(0)
   DECLARE lconfcount = i4 WITH noconstant(0)
   IF (sec_org_reltn=0)
    RETURN(1)
   ENDIF
   SET lorgcount = size(user_orgs->list,5)
   SET lconfcount = size(conf_codeset->list,5)
   IF (lorgcount > 0)
    IF (dordconflevelcd > 0
     AND lconfcount > 0)
     FOR (lindex = 1 TO lorgcount)
       IF ((user_orgs->list[lindex].organization_id=dorgid))
        FOR (lconfindex = 1 TO lconfcount)
          IF ((conf_codeset->list[lconfindex].confid_level_cd=dordconflevelcd))
           IF ((user_orgs->list[lindex].collation_seq >= conf_codeset->list[lconfindex].collation_seq
           ))
            RETURN(1)
           ELSE
            RETURN(0)
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ELSE
     FOR (lindex = 1 TO lorgcount)
       IF ((user_orgs->list[lindex].organization_id=dorgid))
        RETURN(1)
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
