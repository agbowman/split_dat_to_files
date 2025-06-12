CREATE PROGRAM bed_get_ccn:dba
 FREE SET reply
 RECORD reply(
   1 ccn[*]
     2 id = f8
     2 number = f8
     2 name = vc
     2 tax_id = vc
     2 address
       3 address_id = f8
       3 street_addr1 = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state_code_value = f8
       3 state_display = vc
       3 state_mean = vc
       3 zipcode = vc
       3 county_code_value = f8
       3 county_display = vc
       3 county_mean = vc
       3 country_code_value = f8
       3 country_display = vc
       3 country_mean = vc
       3 contact_name = vc
       3 comment_txt = vc
     2 phone
       3 phone_id = f8
       3 phone_format_code_value = f8
       3 phone_format_display = vc
       3 phone_format_mean = vc
       3 phone_num = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
     2 number_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET data_partition_ind = 0
 RANGE OF b IS br_ccn
 SET data_partition_ind = validate(b.logical_domain_id)
 FREE RANGE b
 IF (data_partition_ind=1)
  IF (validate(ld_concept_person)=0)
   DECLARE ld_concept_person = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_prsnl)=0)
   DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
  ENDIF
  IF (validate(ld_concept_organization)=0)
   DECLARE ld_concept_organization = i2 WITH public, constant(3)
  ENDIF
  IF (validate(ld_concept_healthplan)=0)
   DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
  ENDIF
  IF (validate(ld_concept_alias_pool)=0)
   DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
  ENDIF
  IF (validate(ld_concept_minvalue)=0)
   DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_maxvalue)=0)
   DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
  ENDIF
  RECORD acm_get_curr_logical_domain_req(
    1 concept = i4
  )
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
  SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
  EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
  replace("REPLY",acm_get_curr_logical_domain_rep)
 ENDIF
 DECLARE bparse = vc
 SET bparse =
 "b.br_ccn_id > 0 and b.active_ind = 1 and b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)"
 IF (data_partition_ind=1)
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM br_ccn b,
   address a,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   phone p,
   code_value cv4
  PLAN (b
   WHERE parser(bparse))
   JOIN (a
   WHERE a.parent_entity_name=outerjoin("BR_CCN")
    AND a.parent_entity_id=outerjoin(b.br_ccn_id)
    AND a.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(a.state_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(a.county_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(a.country_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.parent_entity_name=outerjoin("BR_CCN")
    AND p.parent_entity_id=outerjoin(b.br_ccn_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(p.phone_format_cd)
    AND cv4.active_ind=outerjoin(1))
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->ccn,ccnt), reply->ccn[ccnt].id = b.br_ccn_id,
   reply->ccn[ccnt].number = b.ccn_nbr, reply->ccn[ccnt].number_string = b.ccn_nbr_txt, reply->ccn[
   ccnt].name = b.ccn_name,
   reply->ccn[ccnt].tax_id = b.tax_id_nbr_txt, reply->ccn[ccnt].address.address_id = a.address_id,
   reply->ccn[ccnt].address.street_addr1 = a.street_addr,
   reply->ccn[ccnt].address.street_addr2 = a.street_addr2, reply->ccn[ccnt].address.street_addr3 = a
   .street_addr3, reply->ccn[ccnt].address.street_addr4 = a.street_addr4,
   reply->ccn[ccnt].address.city = a.city, reply->ccn[ccnt].address.zipcode = a.zipcode, reply->ccn[
   ccnt].address.contact_name = a.contact_name,
   reply->ccn[ccnt].address.comment_txt = a.comment_txt, reply->ccn[ccnt].address.state_code_value =
   a.state_cd, reply->ccn[ccnt].address.state_display = cv1.display,
   reply->ccn[ccnt].address.state_mean = cv1.cdf_meaning, reply->ccn[ccnt].address.county_code_value
    = a.county_cd, reply->ccn[ccnt].address.county_display = cv2.display,
   reply->ccn[ccnt].address.county_mean = cv2.cdf_meaning, reply->ccn[ccnt].address.
   country_code_value = a.country_cd, reply->ccn[ccnt].address.country_display = cv3.display,
   reply->ccn[ccnt].address.country_mean = cv3.cdf_meaning, reply->ccn[ccnt].phone.phone_id = p
   .phone_id, reply->ccn[ccnt].phone.phone_format_code_value = p.phone_format_cd,
   reply->ccn[ccnt].phone.phone_format_display = cv4.display, reply->ccn[ccnt].phone.
   phone_format_mean = cv4.cdf_meaning, reply->ccn[ccnt].phone.phone_num = p.phone_num,
   reply->ccn[ccnt].phone.contact = p.contact, reply->ccn[ccnt].phone.call_instruction = p
   .call_instruction, reply->ccn[ccnt].phone.extension = p.extension
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
