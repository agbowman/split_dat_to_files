CREATE PROGRAM dcp_get_custom_patient_list:dba
 RECORD reply(
   1 custom_pt_list_id = f8
   1 qual[*]
     2 cust_ptl_entry_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 name_full_formatted = vc
     2 priority_flag = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 org_cnt = i2
   1 orglist[*]
     2 org_id = f8
     2 confid_level = i4
 )
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12,"")
 SET in_cd = 0.0
 SET ob_cd = 0.0
 SET code_set = 69
 SET cdf_meaning = "INPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET in_cd = code_value
 SET code_set = 69
 SET cdf_meaning = "OBSERVATION"
 EXECUTE cpm_get_cd_for_cdf
 SET ob_cd = code_value
 IF (validate(ccldminfo->mode,0))
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
  SET temp->org_cnt = 0
  SELECT INTO "nl:"
   c.collation_seq
   FROM prsnl_org_reltn por,
    (dummyt d  WITH seq = 1),
    code_value c
   PLAN (por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d)
    JOIN (c
    WHERE c.code_value=por.confid_level_cd)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(temp->orglist,count), temp->orglist[count].org_id = por
    .organization_id
    IF (confid_ind=1)
     IF (c.collation_seq > 0)
      temp->orglist[count].confid_level = c.collation_seq
     ELSE
      temp->orglist[count].confid_level = 0
     ENDIF
    ELSE
     temp->orglist[count].confid_level = 9999
    ENDIF
   FOOT REPORT
    temp->org_cnt = count
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF ((temp->org_cnt=0))
  SET temp->org_cnt = 1
 ENDIF
 SELECT INTO "nl:"
  FROM custom_pt_list_entry cple,
   person p,
   encounter e,
   code_value c1,
   (dummyt d  WITH seq = value(temp->org_cnt))
  PLAN (cple
   WHERE (cple.custom_pt_list_id=request->custom_pt_list_id))
   JOIN (e
   WHERE e.person_id=cple.person_id
    AND ((e.encntr_id=cple.encntr_id) OR (cple.encntr_id=0))
    AND e.encntr_type_class_cd IN (in_cd, ob_cd))
   JOIN (c1
   WHERE c1.code_value=e.confid_level_cd)
   JOIN (d
   WHERE ((encntr_org_sec_ind=0
    AND confid_ind=0) OR ((e.organization_id=temp->orglist[d.seq].org_id)
    AND (temp->orglist[d.seq].confid_level >= c1.collation_seq))) )
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   count1 = 0, reply->custom_pt_list_id = cple.custom_pt_list_id
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].cust_ptl_entry_id = cple.cust_ptl_entry_id, reply->qual[count1].person_id = p
   .person_id, reply->qual[count1].name_full_formatted = p.name_full_formatted,
   reply->qual[count1].encntr_id = e.encntr_id, reply->qual[count1].priority_flag = 0, reply->qual[
   count1].active_ind = 1
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
