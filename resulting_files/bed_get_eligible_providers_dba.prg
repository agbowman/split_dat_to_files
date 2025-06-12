CREATE PROGRAM bed_get_eligible_providers:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 id = f8
      2 person_id = f8
      2 national_provider_nbr = vc
      2 tax_id = vc
      2 specialty_id = f8
      2 health_plan = vc
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
      2 quality_measures[*]
        3 id = f8
        3 display = vc
        3 sequence = i2
        3 unique_code_value_display = vc
      2 omf_group_cd = f8
      2 omf_group_display = vc
      2 active_ind = i2
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 first_name = vc
      2 last_name = vc
      2 name_full_formatted = vc
      2 username = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 SET data_partition_ind = 0
 RANGE OF b IS br_eligible_provider
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
 "b.br_eligible_provider_id > 0 and b.active_ind = 1 and b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)"
 IF (data_partition_ind=1)
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 DECLARE prsnl_parse = vc
 SET prsnl_parse = "pr.person_id = b.provider_id"
 IF (validate(request->last_name))
  IF ((request->last_name > " "))
   SET prsnl_parse = concat(prsnl_parse," and pr.name_last_key = '",cnvtupper(request->last_name),
    "*'")
  ENDIF
 ENDIF
 IF (validate(request->first_name))
  IF ((request->first_name > " "))
   SET prsnl_parse = concat(prsnl_parse," and pr.name_first_key = '",cnvtupper(request->first_name),
    "*'")
  ENDIF
 ENDIF
 SET req_omf_group_cd = 0
 IF (validate(request->omf_group_cd))
  IF ((request->omf_group_cd > 0))
   SET req_omf_group_cd = request->omf_group_cd
  ENDIF
 ENDIF
 SET pca_group_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13003
   AND cv.cdf_meaning="PCA PCP"
   AND cv.active_ind=1
  DETAIL
   pca_group_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pcnt = 0
 SET mcnt = 0
 SET provider_included_ind = 0
 SELECT INTO "nl:"
  FROM br_eligible_provider b,
   prsnl pr,
   address a,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   phone p,
   code_value cv4,
   br_elig_prov_meas_reltn bm,
   pca_quality_measure pqm,
   code_value cv5,
   dummyt d,
   omf_groupings o,
   code_value cv6
  PLAN (b
   WHERE parser(bparse))
   JOIN (pr
   WHERE parser(prsnl_parse))
   JOIN (a
   WHERE a.parent_entity_name=outerjoin("BR_ELIGIBLE_PROVIDER")
    AND a.parent_entity_id=outerjoin(b.br_eligible_provider_id)
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
   WHERE p.parent_entity_name=outerjoin("BR_ELIGIBLE_PROVIDER")
    AND p.parent_entity_id=outerjoin(b.br_eligible_provider_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(p.phone_format_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (bm
   WHERE bm.br_eligible_provider_id=outerjoin(b.br_eligible_provider_id)
    AND bm.active_ind=outerjoin(1)
    AND bm.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pqm
   WHERE pqm.pca_quality_measure_id=outerjoin(bm.pca_quality_measure_id))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(pqm.measure_cd)
    AND cv5.active_ind=outerjoin(1))
   JOIN (d)
   JOIN (o
   WHERE cnvtreal(trim(o.key1))=pr.person_id
    AND o.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((o.valid_until_dt_tm=null) OR (o.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)))
    AND o.grouping_cd=pca_group_cd)
   JOIN (cv6
   WHERE cv6.code_value=cnvtreal(trim(o.key2))
    AND cv6.active_ind=1)
  ORDER BY b.br_eligible_provider_id, bm.measure_seq
  HEAD b.br_eligible_provider_id
   provider_included_ind = 0
   IF (((req_omf_group_cd=0) OR (req_omf_group_cd > 0
    AND (cnvtreal(trim(o.key2))=request->omf_group_cd))) )
    IF ((((request->no_quality_measures_ind=0)) OR ((request->no_quality_measures_ind=1)
     AND bm.br_elig_prov_meas_reltn_id=0)) )
     provider_included_ind = 1, pcnt = (pcnt+ 1), stat = alterlist(reply->providers,pcnt),
     reply->providers[pcnt].id = b.br_eligible_provider_id, reply->providers[pcnt].person_id = b
     .provider_id, reply->providers[pcnt].national_provider_nbr = b.national_provider_nbr_txt,
     reply->providers[pcnt].tax_id = b.tax_id_nbr_txt, reply->providers[pcnt].specialty_id = b
     .specialty_id, reply->providers[pcnt].health_plan = b.health_plan_txt,
     reply->providers[pcnt].address.address_id = a.address_id, reply->providers[pcnt].address.
     street_addr1 = a.street_addr, reply->providers[pcnt].address.street_addr2 = a.street_addr2,
     reply->providers[pcnt].address.street_addr3 = a.street_addr3, reply->providers[pcnt].address.
     street_addr4 = a.street_addr4, reply->providers[pcnt].address.city = a.city,
     reply->providers[pcnt].address.zipcode = a.zipcode, reply->providers[pcnt].address.contact_name
      = a.contact_name, reply->providers[pcnt].address.comment_txt = a.comment_txt,
     reply->providers[pcnt].address.state_code_value = a.state_cd, reply->providers[pcnt].address.
     state_display = cv1.display, reply->providers[pcnt].address.state_mean = cv1.cdf_meaning,
     reply->providers[pcnt].address.county_code_value = a.county_cd, reply->providers[pcnt].address.
     county_display = cv2.display, reply->providers[pcnt].address.county_mean = cv2.cdf_meaning,
     reply->providers[pcnt].address.country_code_value = a.country_cd, reply->providers[pcnt].address
     .country_display = cv3.display, reply->providers[pcnt].address.country_mean = cv3.cdf_meaning,
     reply->providers[pcnt].phone.phone_id = p.phone_id, reply->providers[pcnt].phone.
     phone_format_code_value = p.phone_format_cd, reply->providers[pcnt].phone.phone_format_display
      = cv4.display,
     reply->providers[pcnt].phone.phone_format_mean = cv4.cdf_meaning, reply->providers[pcnt].phone.
     phone_num = p.phone_num, reply->providers[pcnt].phone.contact = p.contact,
     reply->providers[pcnt].phone.call_instruction = p.call_instruction, reply->providers[pcnt].phone
     .extension = p.extension
     IF (cv6.code_set=4002173)
      reply->providers[pcnt].omf_group_cd = cnvtreal(trim(o.key2)), reply->providers[pcnt].
      omf_group_display = cv6.display
     ENDIF
     mcnt = 0, reply->providers[pcnt].active_ind = pr.active_ind, reply->providers[pcnt].
     beg_effective_dt_tm = pr.beg_effective_dt_tm,
     reply->providers[pcnt].end_effective_dt_tm = pr.end_effective_dt_tm, reply->providers[pcnt].
     first_name = pr.name_first, reply->providers[pcnt].last_name = pr.name_last,
     reply->providers[pcnt].name_full_formatted = pr.name_full_formatted, reply->providers[pcnt].
     username = pr.username
    ENDIF
   ENDIF
  DETAIL
   IF (provider_included_ind=1)
    IF (bm.br_elig_prov_meas_reltn_id > 0)
     mcnt = (mcnt+ 1), stat = alterlist(reply->providers[pcnt].quality_measures,mcnt), reply->
     providers[pcnt].quality_measures[mcnt].id = bm.pca_quality_measure_id,
     reply->providers[pcnt].quality_measures[mcnt].display = pqm.display_txt, reply->providers[pcnt].
     quality_measures[mcnt].sequence = bm.measure_seq, reply->providers[pcnt].quality_measures[mcnt].
     unique_code_value_display = cv5.display
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
