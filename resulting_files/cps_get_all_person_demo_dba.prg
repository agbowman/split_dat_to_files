CREATE PROGRAM cps_get_all_person_demo:dba
 RECORD reply(
   1 name_type_cd = f8
   1 name_full_formatted = vc
   1 name_first = vc
   1 name_middle = vc
   1 name_last = vc
   1 name_degree = vc
   1 name_title = vc
   1 name_prefix = vc
   1 name_suffix = vc
   1 name_initials = vc
   1 phone_qual = i4
   1 phone[*]
     2 phone_num = vc
     2 phone_extension = vc
     2 phone_type = f8
   1 address_qual = i4
   1 address[*]
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 zipcode = vc
     2 county = vc
     2 country = vc
     2 mail_stop = vc
     2 address_type = f8
   1 sex_cd = f8
   1 birth_dt_cd = f8
   1 birth_dt_tm = dq8
   1 ssn = vc
   1 mrn = vc
   1 pcp_person_id = f8
   1 pcp_name_full_formatted = vc
   1 pcp_name_first = vc
   1 pcp_name_middle = vc
   1 pcp_name_last = vc
   1 pcp_name_degree = vc
   1 pcp_name_title = vc
   1 pcp_name_prefix = vc
   1 pcp_name_suffix = vc
   1 pcp_name_initials = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_cvtext(p1) = c25
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET ssn_cd = 0.0
 SET mrn_cd = 0.0
 SET pcp_cd = 0.0
 SELECT INTO "NL:"
  p.person_id, pn.name_full
  FROM person p,
   person_name pn
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (pn
   WHERE p.person_id=pn.person_id)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->name_first = pn.name_first, reply->
   name_middle = pn.name_middle,
   reply->name_last = pn.name_last, reply->name_degree = pn.name_degree, reply->name_title = pn
   .name_title,
   reply->name_prefix = pn.name_prefix, reply->name_suffix = pn.name_suffix, reply->name_initials =
   pn.name_initials,
   reply->birth_dt_cd = p.birth_dt_cd, reply->birth_dt_tm = p.birth_dt_tm, reply->sex_cd = p.sex_cd
  WITH check, nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "NL:"
  a.residence_type_cd
  FROM address a
  PLAN (a
   WHERE (a.parent_entity_id=request->person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY a.residence_type_cd
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->address,10)
  HEAD a.residence_type_cd
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->address,(count1+ 9))
   ENDIF
   reply->address[count1].street_addr = a.street_addr, reply->address[count1].street_addr2 = a
   .street_addr2, reply->address[count1].street_addr3 = a.street_addr3,
   reply->address[count1].street_addr4 = a.street_addr4, reply->address[count1].city = a.city, reply
   ->address[count1].state = a.state,
   reply->address[count1].state_cd = a.state_cd, reply->address[count1].zipcode = a.zipcode, reply->
   address[count1].county = a.county,
   reply->address[count1].country = a.country, reply->address[count1].mail_stop = a.mail_stop, reply
   ->address[count1].address_type = a.address_type_cd
  DETAIL
   x = 0
  FOOT REPORT
   stat = alterlist(reply->address,count1), reply->address_qual = count1
  WITH check, nocounter
 ;end select
 SELECT INTO "NL:"
  ph.phone_num
  FROM phone ph
  PLAN (ph
   WHERE (ph.parent_entity_id=request->person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY ph.phone_num
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->phone,10)
  HEAD ph.phone_num
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->phone,(count1+ 9))
   ENDIF
   reply->phone[count1].phone_num = ph.phone_num, reply->phone[count1].phone_extension = ph.extension,
   reply->phone[count1].phone_type = ph.phone_type_cd
  DETAIL
   x = 0
  FOOT REPORT
   stat = alterlist(reply->phone,count1), reply->phone_qual = count1
  WITH check, nocounter
 ;end select
 SET cdf_meaning = "SSN"
 SET code_set = 4
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_cd = code_value
 SELECT INTO "NL:"
  pa.alias
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=ssn_cd)
  DETAIL
   reply->ssn = pa.alias
  WITH check, nocounter, maxqual(pm,1)
 ;end select
 SET cdf_meaning = "MRN"
 SET code_set = 4
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SELECT INTO "NL:"
  pa.alias
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=mrn_cd)
  DETAIL
   reply->mrn = pa.alias
  WITH check, nocounter, maxqual(pm,1)
 ;end select
 SET cdf_meaning = "PCP"
 SET code_set = 331
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET pcp_cd = code_value
 SELECT INTO "NL:"
  ppr.person_id
  FROM person_prsnl_reltn ppr
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd)
  DETAIL
   reply->pcp_person_id = ppr.prsnl_person_id
  WITH check, nocounter, maxqual(ppr,1)
 ;end select
 SELECT INTO "NL:"
  p.person_id, pn.name_full
  FROM person p,
   person_name pn
  PLAN (p
   WHERE (p.person_id=reply->pcp_person_id))
   JOIN (pn
   WHERE p.person_id=pn.person_id)
  DETAIL
   reply->pcp_name_full_formatted = p.name_full_formatted, reply->pcp_name_first = pn.name_first,
   reply->pcp_name_middle = pn.name_middle,
   reply->pcp_name_last = pn.name_last, reply->pcp_name_degree = pn.name_degree, reply->
   pcp_name_title = pn.name_title,
   reply->pcp_name_prefix = pn.name_prefix, reply->pcp_name_suffix = pn.name_suffix, reply->
   pcp_name_initials = pn.name_initials
  WITH check, nocounter
 ;end select
END GO
