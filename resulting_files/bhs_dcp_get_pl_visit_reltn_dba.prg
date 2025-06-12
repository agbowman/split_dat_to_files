CREATE PROGRAM bhs_dcp_get_pl_visit_reltn:dba
 RECORD orgs(
   1 qual[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 DECLARE dminfo_ok = i2 WITH noconstant(0)
 SET dminfo_ok = validate(ccldminfo->mode,0)
 CALL echo(concat("Ccldminfo exists= ",build(dminfo_ok)))
 IF (dminfo_ok=1)
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  DECLARE org_cnt = i2 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM prsnl_org_reltn por
   WHERE (por.person_id=reqinfo->updt_id)
    AND por.active_ind=1
    AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   HEAD REPORT
    org_cnt = 0
   DETAIL
    org_cnt = (org_cnt+ 1)
    IF (mod(org_cnt,10)=1)
     stat = alterlist(orgs->qual,(org_cnt+ 9))
    ENDIF
    orgs->qual[org_cnt].org_id = por.organization_id
    IF (por.confid_level_cd > 0)
     orgs->qual[org_cnt].confid_level = uar_get_collation_seq(por.confid_level_cd)
    ELSE
     orgs->qual[org_cnt].confid_level = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(orgs->qual,org_cnt)
   WITH nocounter
  ;end select
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE encntr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE nbr_to_get = i4 WITH noconstant(cnvtint(size(request->encntr_type_filters,5)))
 DECLARE arg_nbr = i4 WITH noconstant(cnvtint(size(request->arguments,5)))
 DECLARE counter = i4 WITH noconstant(1)
 DECLARE visit_cd = vc WITH noconstant(fillstring(1000," "))
 DECLARE prsnl_id = f8 WITH noconstant(reqinfo->updt_id)
 DECLARE patient_status_flag = i4 WITH noconstant(0)
 DECLARE patient_status_minutes = i4 WITH noconstant(0)
 DECLARE encntr_filter_ind = i4 WITH noconstant(0)
 DECLARE encntr_type_ind = i4 WITH noconstant(0)
 DECLARE encntr_cds = vc WITH noconstant(fillstring(1000," "))
 DECLARE epr_where = vc WITH noconstant(fillstring(1000," "))
 DECLARE visit_ind = i2 WITH noconstant(0)
 DECLARE fac_filter = vc WITH noconstant(fillstring(1000," "))
 DECLARE fac_ind = i2 WITH noconstant(0)
 DECLARE filterind = i2 WITH noconstant(0)
 SET temp_dt_tm = cnvtdatetime(curdate,curtime3)
 SET visit_ind = 0
 FOR (counter = 1 TO arg_nbr)
   CASE (request->arguments[counter].argument_name)
    OF "visit_reltn_cd":
     IF ((request->arguments[counter].parent_entity_id > 0))
      SET visit_cd = concat(visit_cd,cnvtstring(request->arguments[counter].parent_entity_id),",")
      SET visit_ind = 1
     ENDIF
    OF "prsnl_id":
     SET prsnl_id = cnvtint(request->arguments[counter].parent_entity_id)
    OF "patient_status_flag":
     SET patient_status_flag = cnvtint(request->arguments[counter].argument_value)
    OF "patient_status_minutes":
     SET patient_status_minutes = cnvtint(request->arguments[counter].argument_value)
    OF "facility_filter":
     SET fac_filter = concat(fac_filter,cnvtstring(request->arguments[counter].parent_entity_id),",")
     SET fac_ind = 1
   ENDCASE
 ENDFOR
 IF (visit_ind=1)
  SET visit_cd = substring(1,(size(visit_cd,1) - 1),visit_cd)
  SET epr_where = concat("epr.prsnl_person_id = prsnl_id and epr.expiration_ind = 0",
   " and epr.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)",
   " and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)"," and epr.encntr_prsnl_r_cd in (",
   visit_cd,
   ") and epr.active_ind = 1")
 ELSE
  SET epr_where = concat("epr.prsnl_person_id = prsnl_id and epr.expiration_ind = 0",
   " and epr.active_ind = 1"," and epr.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)",
   " and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
 ENDIF
 IF (nbr_to_get > 0)
  IF ((request->encntr_type_filters[1].encntr_type_cd=0))
   SET encntr_cds =
   " and expand(counter, 1, nbr_to_get, e.encntr_class_cd, request->encntr_type_filters[counter].encntr_class_cd)"
  ELSE
   SET encntr_cds =
   " and expand(counter, 1, nbr_to_get, e.encntr_type_cd, request->encntr_type_filters[counter].encntr_type_cd)"
  ENDIF
 ENDIF
 SET temp_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- ((patient_status_minutes/ 1440.0)))
 IF (patient_status_flag=0)
  SET encntr_where = "e.encntr_id = epr.encntr_id and e.active_ind = 1"
 ELSEIF (patient_status_flag=1)
  SET encntr_where = concat("e.encntr_id = epr.encntr_id and e.active_ind = 1",
   " and e.reg_dt_tm between cnvtdatetime(temp_dt_tm) "," and cnvtdatetime(curdate,curtime)")
 ELSEIF (patient_status_flag=2)
  SET encntr_where = concat("e.encntr_id = epr.encntr_id and e.active_ind = 1",
   " and e.disch_dt_tm between cnvtdatetime(temp_dt_tm) "," and cnvtdatetime(curdate,curtime)")
 ELSEIF (patient_status_flag=3)
  SET encntr_where = concat("e.encntr_id = epr.encntr_id and e.active_ind = 1",
   " and nullind(e.disch_dt_tm) = 1")
 ELSE
  SET encntr_where = "e.encntr_id = epr.encntr_id and e.active_ind = 1"
 ENDIF
 IF (nbr_to_get > 0)
  SET encntr_where = concat(encntr_where,encntr_cds)
 ENDIF
 IF (fac_ind=1)
  SET fac_filter = substring(1,(size(fac_filter,1) - 1),fac_filter)
  SET encntr_where = concat(encntr_where," and e.loc_facility_cd + 0 in (",fac_filter,")")
 ENDIF
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1)) )
  SET filterind = 1
 ELSE
  SET filterind = 0
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   encounter e,
   person p,
   dcp_pl_prioritization pr
  PLAN (epr
   WHERE parser(trim(epr_where)))
   JOIN (e
   WHERE parser(trim(encntr_where)))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE outerjoin(p.person_id)=pr.person_id
    AND pr.patient_list_id=outerjoin(request->patient_list_id))
  ORDER BY p.person_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->patients,(cnt+ 9))
   ENDIF
   reply->patients[cnt].person_id = p.person_id, reply->patients[cnt].person_name = p
   .name_full_formatted, reply->patients[cnt].encntr_id = e.encntr_id,
   reply->patients[cnt].priority = pr.priority, reply->patients[cnt].organization_id = e
   .organization_id, reply->patients[cnt].confid_level_cd = e.confid_level_cd,
   reply->patients[cnt].confid_level = uar_get_collation_seq(e.confid_level_cd)
   IF ((reply->patients[cnt].confid_level < 0))
    reply->patients[cnt].confid_level = 0
   ENDIF
   reply->patients[cnt].filter_ind = filterind
   IF (epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    reply->patients[cnt].active_ind = 1
   ELSE
    reply->patients[cnt].active_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->patients,cnt)
  WITH nocounter
 ;end select
 IF (((confid_ind=1) OR (encntr_org_sec_ind=1))
  AND cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    person_prsnl_reltn ppr,
    code_value_extension cve
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (ppr
    WHERE (ppr.person_id=reply->patients[d.seq].person_id)
     AND (ppr.prsnl_person_id=reqinfo->updt_id)
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cve
    WHERE cve.code_value=ppr.person_prsnl_r_cd
     AND cve.field_name="Override"
     AND cve.code_set=331)
   DETAIL
    IF (((cve.field_value="2") OR (cve.field_value="1"
     AND ((confid_ind=0) OR ((reply->patients[d.seq].confid_level=0))) )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    (dummyt d2  WITH seq = value(org_cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (d2
    WHERE (orgs->qual[d2.seq].org_id=reply->patients[d.seq].organization_id))
   DETAIL
    IF (((confid_ind=0) OR ((orgs->qual[d2.seq].confid_level >= reply->patients[d.seq].confid_level)
    )) )
     reply->patients[d.seq].filter_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    encntr_prsnl_reltn epr
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=1))
    JOIN (epr
    WHERE (epr.encntr_id=reply->patients[d.seq].encntr_id)
     AND (epr.prsnl_person_id=reqinfo->updt_id)
     AND epr.expiration_ind=0
     AND epr.active_ind=1
     AND epr.encntr_prsnl_r_cd > 0
     AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->patients[d.seq].filter_ind = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt))
   PLAN (d
    WHERE (reply->patients[d.seq].filter_ind=0))
   HEAD REPORT
    actual_cnt = 0
   DETAIL
    actual_cnt = (actual_cnt+ 1), reply->patients[actual_cnt].person_id = reply->patients[d.seq].
    person_id, reply->patients[actual_cnt].person_name = reply->patients[d.seq].person_name,
    reply->patients[actual_cnt].encntr_id = reply->patients[d.seq].encntr_id, reply->patients[
    actual_cnt].priority = reply->patients[d.seq].priority, reply->patients[actual_cnt].active_ind =
    reply->patients[d.seq].active_ind,
    reply->patients[actual_cnt].organization_id = reply->patients[d.seq].organization_id, reply->
    patients[actual_cnt].confid_level_cd = reply->patients[d.seq].confid_level_cd, reply->patients[
    actual_cnt].confid_level = reply->patients[d.seq].confid_level,
    reply->patients[actual_cnt].filter_ind = reply->patients[d.seq].filter_ind
   FOOT REPORT
    cnt = actual_cnt, stat = alterlist(reply->patients,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cnt = 0
   SET stat = alterlist(reply->patients,cnt)
  ENDIF
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
