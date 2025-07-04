CREATE PROGRAM bed_ens_organization:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 qual[*]
      2 organization_id = f8
      2 facility_code_value = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET blgs
 RECORD blgs(
   01 blist[*]
     02 code_value = f8
 )
 FREE SET units
 RECORD units(
   01 ulist[*]
     02 code_value = f8
 )
 FREE SET rooms
 RECORD rooms(
   01 rlist[*]
     02 code_value = f8
 )
 FREE SET beds
 RECORD beds(
   01 dlist[*]
     02 code_value = f8
 )
 FREE SET child_phone
 RECORD child_phone(
   1 phones[*]
     2 org_index = i4
     2 phone_index = i4
     2 prsnl_reltn_id = f8
     2 child_reltn_id = f8
     2 person_id = f8
     2 phone_id = f8
     2 beg_dt = dq8
     2 end_dt = dq8
     2 phone_type = f8
     2 phone_format = f8
 )
 FREE SET child_add
 RECORD child_add(
   01 address[*]
     02 address_id = f8
     02 street_addr1 = vc
     02 street_addr2 = vc
     02 street_addr3 = vc
     02 street_addr4 = vc
     02 city = vc
     02 city_code = f8
     02 state_code_value = f8
     02 state_disp = vc
     02 county = vc
     02 county_code_value = f8
     02 zipcode = vc
     02 country = vc
     02 country_code_value = f8
     02 address_type_code_value = f8
     02 address_type_mean = vc
     02 contact_name = vc
     02 comment_txt = vc
     02 beg_effective_dt_tm = dq8
     02 end_effective_dt_tm = dq8
     02 action_flag = i2
     02 prsnl_reltn_id = f8
 )
 DECLARE error_flag = vc
 DECLARE serrmsg = vc
 DECLARE ierrcode = i4
 DECLARE ocnt = i4
 DECLARE otcnt = i4
 DECLARE acnt = i4
 DECLARE pcnt = i4
 DECLARE icnt = i4
 DECLARE org_id = f8
 DECLARE address_id = f8
 DECLARE phone_id = f8
 DECLARE institution_cd = f8
 DECLARE facility_code_value = f8
 DECLARE fac_loc_type_code_value = f8
 DECLARE fac_org_type_code_value = f8
 DECLARE client_org_type_code_value = f8
 DECLARE start_org_exists = i4
 DECLARE start_fac_exists = i4
 DECLARE active_cd = f8
 DECLARE inactive_code_value = f8
 DECLARE org_class_cd = f8
 DECLARE auth_cd = f8
 DECLARE bbmanuf_cd = f8
 DECLARE bbsuppl_cd = f8
 DECLARE intsecemail_cd = f8
 DECLARE extsecemail_cd = f8
 DECLARE prg_exists_ind = i4
 DECLARE contact_method_cd = f8
 DECLARE oacnt = i4
 DECLARE rscnt = i4
 DECLARE ptcnt = i4
 DECLARE phone_reltn_type = f8
 DECLARE pcnt = i4
 DECLARE icnt = i4
 DECLARE atcnt = i4
 DECLARE add_reltn_type = f8
 DECLARE add_client = i4
 DECLARE chg_phone(x,y) = f8
 DECLARE del_phone(x,y) = f8
 DECLARE chg_address(x,y) = f8
 DECLARE del_address(x,y) = f8
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE relpooloption = vc
 DECLARE state_display = vc
 DECLARE county_display = vc
 DECLARE country_display = vc
 DECLARE beg_dt_tm = dq8
 DECLARE end_dt_tm = dq8
 DECLARE save_sequence = i4
 DECLARE org_data_partition_ind = i4
 DECLARE ap_data_partition_ind = i4
 DECLARE field_found = i4
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ocnt = 0
 SET otcnt = 0
 SET acnt = 0
 SET pcnt = 0
 SET icnt = 0
 SET ocnt = size(request->org,5)
 SET org_id = 0.0
 SET address_id = 0.0
 SET phone_id = 0.0
 SET institution_cd = 0.0
 SET facility_code_value = 0.0
 SET fac_loc_type_code_value = 0.0
 SET fac_org_type_code_value = 0.0
 SET client_org_type_code_value = 0.0
 SET start_org_exists = 0
 SET start_fac_exists = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=278
   AND cv.active_ind=1
   AND ((cv.cdf_meaning="CLIENT") OR (cv.cdf_meaning="FACILITY"))
  DETAIL
   IF (cv.cdf_meaning="CLIENT")
    client_org_type_code_value = cv.code_value
   ELSE
    fac_org_type_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (((client_org_type_code_value=0.0) OR (fac_org_type_code_value=0.0)) )
  SET error_flag = "Y"
  SET error_msg = "Unable to find CLIENT and FACILITY on cs278."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.active_ind=1
   AND cv.cdf_meaning="FACILITY"
  DETAIL
   fac_loc_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = "Unable to find FACILITY on cs222."
  GO TO exit_script
 ENDIF
 IF (((ocnt=0) OR (ocnt=1
  AND trim(request->org[1].org_name)=" "
  AND (request->org[1].organization_id=0))) )
  SET error_flag = "Z"
  SET error_msg = "Zero entries in the request org list."
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->qual,ocnt)
 SET active_cd = 0.0
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND ((c.cdf_meaning="ACTIVE") OR (c.cdf_meaning="INACTIVE")) )
  DETAIL
   IF (c.cdf_meaning="INACTIVE")
    inactive_code_value = c.code_value
   ELSE
    active_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH")
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SET org_class_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=396
    AND c.cdf_meaning="ORG")
  DETAIL
   org_class_cd = c.code_value
  WITH nocounter
 ;end select
 IF (((org_class_cd=0) OR (((auth_cd=0) OR (active_cd=0)) )) )
  SET error_flag = "F"
  SET error_msg = concat("A Cerner defined code value could not be found. ",
   " ORG from 396, AUTH from 8 or ACTIVE from 48.")
  GO TO exit_script
 ENDIF
 SET bbmanuf_cd = 0.0
 SET bbsuppl_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning IN ("BBMANUF", "BBSUPPL"))
  DETAIL
   IF (cv.cdf_meaning="BBMANUF")
    bbmanuf_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BBSUPPL")
    bbsuppl_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET intsecemail_cd = 0.0
 SET extsecemail_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=43
    AND cv.cdf_meaning IN ("INTSECEMAIL", "EXTSECEMAIL")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="INTSECEMAIL")
    intsecemail_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="EXTSECEMAIL")
    extsecemail_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET org_data_partition_ind = 0
 SET ap_data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
   IF (field_found=1)
    SET org_data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = 3
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF a IS alias_pool
   SET field_found = validate(a.logical_domain_id)
   FREE RANGE a
   IF (field_found=1)
    SET ap_data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 5
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE ap_parse = vc
 SET ap_parse = "a.alias_pool_cd = c.code_value"
 IF (ap_data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET ap_parse = concat(ap_parse," and a.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE dea_pool = f8
 DECLARE dea_type = f8
 DECLARE prsnlprim_pool = f8
 DECLARE prsnlprim_type = f8
 DECLARE empcode_pool = f8
 DECLARE empcode_type = f8
 DECLARE encorg_pool = f8
 DECLARE encorg_type = f8
 DECLARE extid_pool = f8
 DECLARE extid_type = f8
 DECLARE healthplan_pool = f8
 DECLARE healthplan_type = f8
 DECLARE inscod_pool = f8
 DECLARE inscod_type = f8
 DECLARE ssn_pool = f8
 DECLARE ssn_type = f8
 DECLARE upin_pool = f8
 DECLARE upin_type = f8
 SET dea_pool = 0.0
 SET dea_type = 0.0
 SET prsnlprim_pool = 0.0
 SET prsnlprim_type = 0.0
 SET empcode_pool = 0.0
 SET empcode_type = 0.0
 SET encorg_pool = 0.0
 SET encorg_type = 0.0
 SET extid_pool = 0.0
 SET extid_type = 0.0
 SET healthplan_pool = 0.0
 SET healthplan_type = 0.0
 SET inscod_pool = 0.0
 SET inscod_type = 0.0
 SET ssn_pool = 0.0
 SET ssn_type = 0.0
 SET upin_pool = 0.0
 SET upin_type = 0.0
 SET relpooloption = "1"
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_name="ORGSTANDARDPOOL")
  DETAIL
   relpooloption = trim(bnv.br_value)
  WITH nocounter
 ;end select
 IF (relpooloption="1")
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=320
    AND c.cdf_meaning="DOCDEA"
   DETAIL
    dea_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="DEA")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    dea_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=320
    AND c.cdf_meaning="PRSNLPRIMID"
   DETAIL
    prsnlprim_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="PERSONNELPRIMARYIDENTIFIER")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    prsnlprim_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=334
    AND c.cdf_meaning="EMPLOYERCOD"
   DETAIL
    empcode_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="EMPLOYERCODE")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    empcode_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=334
    AND c.cdf_meaning="ESIORGALIAS"
   DETAIL
    encorg_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="ENCOUNTERORG")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    encorg_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=320
    AND c.cdf_meaning="EXTERNALID"
   DETAIL
    extid_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="EXTERNALID")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    extid_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=334
    AND c.cdf_meaning="HEALTHPLAN"
   DETAIL
    healthplan_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="HEALTHPLAN")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    healthplan_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=334
    AND c.cdf_meaning="INSURANCE CO"
   DETAIL
    inscod_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="INSURANCECODE")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    inscod_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=4
    AND c.cdf_meaning="SSN"
   DETAIL
    ssn_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="SSN")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    ssn_pool = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=320
    AND c.cdf_meaning="DOCUPIN"
   DETAIL
    upin_type = c.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    alias_pool a
   PLAN (c
    WHERE c.code_set=263
     AND c.display_key="UPIN")
    JOIN (a
    WHERE parser(ap_parse))
   DETAIL
    upin_pool = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 DECLARE externalorgind = i2 WITH protect, noconstant(0)
 FOR (x = 1 TO ocnt)
   SET start_org_exists = 0
   SET start_fac_exists = 0
   SET error_flag = "N"
   SET org_id = 0.0
   IF ((request->org[x].action_flag=1)
    AND (request->org[x].start_ind=1))
    SELECT INTO "nl:"
     FROM organization o
     WHERE ((o.org_name="START Organization") OR (o.org_name="STANDARD Organization"))
     DETAIL
      org_id = o.organization_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET start_org_exists = 0
    ELSEIF (curqual=1)
     SET stat = chg_org(x)
     SET start_org_exists = 1
     SET reply->qual[x].organization_id = org_id
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Multiple ORGANIZATION rows exist with an ORG_NAME ",
      "of either START Organization or STANDARD Organization")
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->org[x].action_flag=1)
    AND (((request->org[x].start_ind=0)) OR (start_org_exists=0)) )
    SET stat = add_org(x)
    SET reply->qual[x].organization_id = org_id
   ELSE
    IF ((request->org[x].organization_id=0)
     AND (request->org[x].action_flag IN (2, 3)))
     SET error_flag = "Y"
     SET error_msg = concat("Actions other than ADD require an org_id, no org_id sent with: ",trim(
       request->org[x].org_name),". This org is being skipped.")
     GO TO exit_script
    ELSE
     IF (start_org_exists=0)
      SET org_id = request->org[x].organization_id
      SET reply->qual[x].organization_id = org_id
      IF ((request->org[x].action_flag=2))
       SET stat = chg_org(x)
      ELSEIF ((request->org[x].action_flag=3))
       SET stat = del_org(x)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (org_id > 0
    AND start_org_exists=1)
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=220
      AND c.cdf_meaning="FACILITY"
      AND ((c.description="START Organization") OR (c.description="STANDARD Organization"))
     DETAIL
      facility_code_value = c.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET start_fac_exists = 0
    ELSEIF (curqual=1)
     SET request->org[x].facility.code_value = facility_code_value
     SET stat = chg_fac(x)
     SET start_fac_exists = 1
     SET reply->qual[x].facility_code_value = facility_code_value
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Multiple code values on code set 220 ",
      "exist with a CDF_MEANING of FACILITY and DESCRIPTION of either ",
      "START Organization or STANDARD Organization")
     GO TO exit_script
    ENDIF
    SET inst_code_value = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=221
      AND cv.cdf_meaning="INSTITUTION"
      AND ((cv.description="START Institution") OR (cv.description="STANDARD Institution"))
     DETAIL
      inst_code_value = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=1)
     SET request_cv->cd_value_list[1].action_flag = 2
     SET request_cv->cd_value_list[1].code_set = 221
     SET request_cv->cd_value_list[1].code_value = inst_code_value
     SET request_cv->cd_value_list[1].cdf_meaning = "INSTITUTION"
     SET request_cv->cd_value_list[1].display = request->org[x].facility.display
     SET request_cv->cd_value_list[1].description = request->org[x].facility.description
     SET request_cv->cd_value_list[1].active_ind = 1
     SET trace = recpersist
     EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    ELSEIF (curqual > 1)
     SET error_flag = "Y"
     SET error_msg = concat("Multiple code values on code set 221 ",
      "exist with a CDF_MEANING of INSTITUTION and DESCRIPTION of either ",
      "START Institution or STANDARD Institution")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (org_id > 0)
    IF ((request->org[x].facility.action_flag=1)
     AND start_fac_exists=0)
     SET stat = add_fac(x)
     IF (relpooloption="1"
      AND (request->org[x].action_flag=1))
      SET stat = add_alias_pools(x)
     ENDIF
    ELSEIF ((request->org[x].facility.action_flag=2))
     SET stat = chg_fac(x)
    ELSEIF ((request->org[x].facility.action_flag=3))
     SET stat = del_fac(x)
    ELSE
     IF (start_fac_exists=0)
      SET facility_code_value = request->org[x].facility.code_value
     ENDIF
    ENDIF
    SET otcnt = size(request->org[x].org_type,5)
    FOR (y = 1 TO otcnt)
      IF ((request->org[x].org_type[y].action_flag=1))
       SET stat = add_org_type(x,y)
      ELSEIF ((request->org[x].org_type[y].action_flag=3))
       SET stat = del_org_type(x,y)
      ENDIF
    ENDFOR
    SET acnt = size(request->org[x].address,5)
    IF (acnt > 0)
     FOR (y = 1 TO acnt)
       IF ((request->org[x].address[y].action_flag=1))
        SET stat = add_address(x,y)
       ELSEIF ((request->org[x].address[y].action_flag=2))
        SET stat = chg_address(x,y)
       ELSEIF ((request->org[x].address[y].action_flag=3))
        SET stat = del_address(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET pcnt = size(request->org[x].phone,5)
    IF (pcnt > 0)
     FOR (y = 1 TO pcnt)
       IF ((request->org[x].phone[y].action_flag=1))
        SET stat = add_phone(x,y)
       ELSEIF ((request->org[x].phone[y].action_flag=2))
        SET stat = chg_phone(x,y)
       ELSEIF ((request->org[x].phone[y].action_flag=3))
        SET stat = del_phone(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET icnt = size(request->org[x].instr,5)
    IF (icnt > 0)
     FOR (y = 1 TO icnt)
       IF ((request->org[x].instr[y].action_flag=1))
        SET stat = add_instr(x,y)
       ELSEIF ((request->org[x].instr[y].action_flag=2))
        SET stat = chg_instr(x,y)
       ELSEIF ((request->org[x].instr[y].action_flag=3))
        SET stat = del_instr(x,y)
       ENDIF
     ENDFOR
    ENDIF
    IF (validate(request->org[x].org_alias))
     SET oacnt = size(request->org[x].org_alias,5)
     FOR (y = 1 TO oacnt)
       IF ((request->org[x].org_alias[y].action_flag=1))
        SET stat = add_org_alias(x,y)
       ELSEIF ((request->org[x].org_alias[y].action_flag=2))
        SET stat = chg_org_alias(x,y)
       ELSEIF ((request->org[x].org_alias[y].action_flag=3))
        SET stat = del_org_alias(x,y)
       ENDIF
     ENDFOR
    ENDIF
    IF (validate(request->org[x].research_accounts))
     SET rscnt = size(request->org[x].research_accounts,5)
     FOR (y = 1 TO rscnt)
       IF ((request->org[x].research_accounts[y].action_flag=1))
        SET stat = add_research_account(x,y)
       ELSEIF ((request->org[x].research_accounts[y].action_flag=2))
        SET stat = chg_research_account(x,y)
       ELSEIF ((request->org[x].research_accounts[y].action_flag=3))
        SET stat = del_research_account(x,y)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET reply->qual[x].organization_id = org_id
 ENDFOR
 SET ptcnt = 0
 SET phone_reltn_type = uar_get_code_by("MEANING",30300,"PHONE")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ocnt)),
   (dummyt d2  WITH seq = 1),
   prsnl_reltn pr,
   prsnl p,
   prsnl_reltn_child prc,
   phone p2,
   prsnl_reltn_child prc2,
   phone p3
  PLAN (d
   WHERE maxrec(d2,size(request->org[d.seq].phone,5)) > 0)
   JOIN (d2
   WHERE (request->org[d.seq].phone[d2.seq].action_flag IN (2, 3)))
   JOIN (p2
   WHERE (p2.phone_id=request->org[d.seq].phone[d2.seq].phone_id)
    AND p2.parent_entity_name="ORGANIZATION")
   JOIN (prc
   WHERE prc.parent_entity_id=p2.phone_id
    AND prc.parent_entity_name="PHONE"
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prsnl_reltn_id=prc.prsnl_reltn_id
    AND pr.reltn_type_cd=phone_reltn_type
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc2
   WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc2.parent_entity_name="PHONE"
    AND prc2.prsnl_reltn_child_id != prc.prsnl_reltn_child_id
    AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p3
   WHERE p3.phone_id=prc2.parent_entity_id
    AND p3.active_ind=1
    AND p3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p3.parent_entity_id=p.person_id
    AND p3.parent_entity_name="PERSON")
  ORDER BY p3.phone_id
  HEAD REPORT
   pcnt = 0, ptcnt = 0, stat = alterlist(child_phone->phones,100)
  HEAD p3.phone_id
   pcnt = (pcnt+ 1), ptcnt = (ptcnt+ 1)
   IF (pcnt > 100)
    stat = alterlist(child_phone->phones,(ptcnt+ 100)), pcnt = 1
   ENDIF
   child_phone->phones[ptcnt].org_index = d.seq, child_phone->phones[ptcnt].phone_index = d2.seq,
   child_phone->phones[ptcnt].person_id = p3.parent_entity_id,
   child_phone->phones[ptcnt].prsnl_reltn_id = prc2.prsnl_reltn_id, child_phone->phones[ptcnt].
   child_reltn_id = prc2.prsnl_reltn_child_id, child_phone->phones[ptcnt].phone_id = p3.phone_id,
   child_phone->phones[ptcnt].phone_type = p2.phone_type_cd, child_phone->phones[ptcnt].phone_format
    = p2.phone_format_cd, child_phone->phones[ptcnt].beg_dt = p3.beg_effective_dt_tm,
   child_phone->phones[ptcnt].end_dt = p3.end_effective_dt_tm
   IF (validate(request->org[d.seq].phone[d2.seq].beg_effective_dt_tm))
    IF ((request->org[d.seq].phone[d2.seq].beg_effective_dt_tm > 0))
     child_phone->phones[ptcnt].end_dt = request->org[d.seq].phone[d2.seq].beg_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[d.seq].phone[d2.seq].end_effective_dt_tm))
    IF ((request->org[d.seq].phone[d2.seq].end_effective_dt_tm > 0))
     child_phone->phones[ptcnt].end_dt = request->org[d.seq].phone[d2.seq].end_effective_dt_tm
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(child_phone->phones,ptcnt)
  WITH nocounter
 ;end select
 IF (ptcnt > 0)
  SET ierrcode = 0
  UPDATE  FROM phone p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.phone_type_cd = child_phone->phones[d.seq].phone_type, p.phone_format_cd = child_phone->
    phones[d.seq].phone_format, p.phone_num = request->org[child_phone->phones[d.seq].org_index].
    phone[child_phone->phones[d.seq].phone_index].phone_num,
    p.phone_num_key = cnvtupper(cnvtalphanum(request->org[child_phone->phones[d.seq].org_index].
      phone[child_phone->phones[d.seq].phone_index].phone_num)), p.description = request->org[
    child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].phone_index].description,
    p.contact = request->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].
    phone_index].contact,
    p.call_instruction = request->org[child_phone->phones[d.seq].org_index].phone[child_phone->
    phones[d.seq].phone_index].call_instruction, p.paging_code = request->org[child_phone->phones[d
    .seq].org_index].phone[child_phone->phones[d.seq].phone_index].paging_code, p.extension = request
    ->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].phone_index].
    extension,
    p.beg_effective_dt_tm = cnvtdatetime(child_phone->phones[d.seq].beg_dt), p.end_effective_dt_tm =
    cnvtdatetime(child_phone->phones[d.seq].end_dt), p.updt_cnt = (p.updt_cnt+ 1),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].
    phone_index].action_flag=2))
    JOIN (p
    WHERE (p.phone_id=child_phone->phones[d.seq].phone_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error updating prsnl phones")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM phone p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.active_status_cd = inactive_code_value, p.end_effective_dt_tm =
    cnvtdatetime(curdate,curtime),
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].
    phone_index].action_flag=3))
    JOIN (p
    WHERE (p.phone_id=child_phone->phones[d.seq].phone_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error inactivating prsnl phones")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.display_seq = 0, p.updt_id = reqinfo->updt_id,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].
    phone_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_phone->phones[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update prsnl_reltn rows.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p
    .updt_cnt = (p.updt_cnt+ 1),
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (request->org[child_phone->phones[d.seq].org_index].phone[child_phone->phones[d.seq].
    phone_index].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_phone->phones[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate prsnl_reltn_child rows2.")
   GO TO exit_script
  ENDIF
 ENDIF
 SET atcnt = 0
 SET add_reltn_type = uar_get_code_by("MEANING",30300,"ADDRESS")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ocnt)),
   (dummyt d2  WITH seq = 1),
   prsnl_reltn pr,
   prsnl p,
   prsnl_reltn_child prc,
   address a,
   prsnl_reltn_child prc2,
   address a2
  PLAN (d
   WHERE maxrec(d2,size(request->org[d.seq].address,5)) > 0)
   JOIN (d2
   WHERE (request->org[d.seq].address[d2.seq].action_flag IN (2, 3)))
   JOIN (a
   WHERE (a.address_id=request->org[d.seq].address[d2.seq].address_id)
    AND a.parent_entity_name="ORGANIZATION")
   JOIN (prc
   WHERE prc.parent_entity_id=a.address_id
    AND prc.parent_entity_name="ADDRESS"
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.prsnl_reltn_id=prc.prsnl_reltn_id
    AND pr.reltn_type_cd=add_reltn_type
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pr.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc2
   WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc2.parent_entity_name="ADDRESS"
    AND prc2.prsnl_reltn_child_id != prc.prsnl_reltn_child_id
    AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a2
   WHERE a2.address_id=prc2.parent_entity_id
    AND a2.active_ind=1
    AND a2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND a2.parent_entity_id=p.person_id
    AND a2.parent_entity_name="PERSON")
  ORDER BY a2.address_id
  HEAD REPORT
   acnt = 0, atcnt = 0, stat = alterlist(child_add->address,100)
  HEAD a2.address_id
   acnt = (acnt+ 1), atcnt = (atcnt+ 1)
   IF (acnt > 100)
    stat = alterlist(child_add->address,(atcnt+ 100)), acnt = 1
   ENDIF
   child_add->address[atcnt].address_id = a2.address_id, child_add->address[atcnt].
   address_type_code_value = a.address_type_cd, child_add->address[atcnt].beg_effective_dt_tm = a
   .beg_effective_dt_tm,
   child_add->address[atcnt].end_effective_dt_tm = a.end_effective_dt_tm, child_add->address[atcnt].
   city = a.city, child_add->address[atcnt].city_code = a.city_cd,
   child_add->address[atcnt].comment_txt = a.comment_txt, child_add->address[atcnt].contact_name = a
   .contact_name, child_add->address[atcnt].country = a.country,
   child_add->address[atcnt].country_code_value = a.country_cd, child_add->address[atcnt].county = a
   .county, child_add->address[atcnt].county_code_value = a.county_cd,
   child_add->address[atcnt].state_code_value = a.state_cd, child_add->address[atcnt].state_disp = a
   .state, child_add->address[atcnt].street_addr1 = a.street_addr,
   child_add->address[atcnt].street_addr2 = a.street_addr2, child_add->address[atcnt].street_addr3 =
   a.street_addr3, child_add->address[atcnt].street_addr4 = a.street_addr4,
   child_add->address[atcnt].zipcode = a.zipcode, child_add->address[atcnt].action_flag = request->
   org[d.seq].address[d2.seq].action_flag, child_add->address[atcnt].prsnl_reltn_id = prc2
   .prsnl_reltn_id
  FOOT REPORT
   stat = alterlist(child_add->address,(atcnt+ 100))
  WITH nocounter
 ;end select
 IF (atcnt > 0)
  SET ierrcode = 0
  UPDATE  FROM address a,
    (dummyt d  WITH seq = value(atcnt))
   SET a.street_addr = child_add->address[d.seq].street_addr1, a.street_addr2 = child_add->address[d
    .seq].street_addr2, a.street_addr3 = child_add->address[d.seq].street_addr3,
    a.street_addr4 = child_add->address[d.seq].street_addr4, a.city = child_add->address[d.seq].city,
    a.state = child_add->address[d.seq].state_disp,
    a.state_cd = child_add->address[d.seq].state_code_value, a.zipcode = child_add->address[d.seq].
    zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(child_add->address[d.seq].zipcode)),
    a.county = child_add->address[d.seq].county, a.county_cd = child_add->address[d.seq].
    county_code_value, a.country = child_add->address[d.seq].country,
    a.country_cd = child_add->address[d.seq].country_code_value, a.address_type_cd = child_add->
    address[d.seq].address_type_code_value, a.contact_name = child_add->address[d.seq].contact_name,
    a.comment_txt = child_add->address[d.seq].comment_txt, a.beg_effective_dt_tm = cnvtdatetime(
     child_add->address[d.seq].beg_effective_dt_tm), a.end_effective_dt_tm = cnvtdatetime(child_add->
     address[d.seq].end_effective_dt_tm),
    a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task,
    a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (child_add->address[d.seq].action_flag=2))
    JOIN (a
    WHERE (a.address_id=child_add->address[d.seq].address_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update child addresses.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM address a,
    (dummyt d  WITH seq = value(atcnt))
   SET a.active_ind = 0, a.active_status_cd = inactive_code_value, a.updt_cnt = (a.updt_cnt+ 1),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (child_add->address[d.seq].action_flag=3))
    JOIN (a
    WHERE (a.address_id=child_add->address[d.seq].address_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate child addresses.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.active_ind = 0, p.display_seq = 0, p.updt_id = reqinfo->updt_id,
    p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
    updt_task,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (child_add->address[d.seq].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_add->address[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Update prsnl_reltn rows.")
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM prsnl_reltn_child p,
    (dummyt d  WITH seq = value(ptcnt))
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p
    .updt_cnt = (p.updt_cnt+ 1),
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (child_add->address[d.seq].action_flag=3))
    JOIN (p
    WHERE (p.prsnl_reltn_id=child_add->address[d.seq].prsnl_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Inactivate prsnl_reltn_child rows2.")
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE add_org(x)
   DECLARE start_dt = dq8
   DECLARE end_dt = dq8
   SET start_dt = cnvtdatetime(curdate,curtime3)
   SET end_dt = cnvtdatetime("31-DEC-2100")
   IF (validate(request->org[x].begin_effective_dt_tm))
    IF ((request->org[x].begin_effective_dt_tm > 0))
     SET start_dt = request->org[x].begin_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[x].end_effective_dt_tm))
    IF ((request->org[x].end_effective_dt_tm > 0))
     SET end_dt = request->org[x].end_effective_dt_tm
    ENDIF
   ENDIF
   IF (trim(request->org[x].org_name)=" ")
    SET error_flag = "Y"
    SET error_msg = concat("Org_Name missing, unable to add - entry nbr: ",cnvtstring(x))
    GO TO exit_script
   ENDIF
   DECLARE org_parse = vc
   SET org_parse = "o.data_status_cd = auth_cd"
   IF (org_data_partition_ind=1)
    IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
     SET org_parse = concat(org_parse," and o.logical_domain_id in (")
     FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
       IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
        SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
         logical_domain_id,")")
       ELSE
        SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
         logical_domain_id,",")
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM organization o
    WHERE o.org_name_key=cnvtupper(cnvtalphanum(request->org[x].org_name))
     AND parser(org_parse)
     AND o.active_ind=1
    DETAIL
     org_id = o.organization_id
    WITH nocounter
   ;end select
   IF (org_id > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing new organization row for org name: ",trim(request->org[x].
      org_name),". Org already exists.")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    j = seq(organization_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     org_id = cnvtreal(j)
    WITH format, counter
   ;end select
   IF (org_id=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to generate a new org_id for org name: ",trim(request->org[x].
      org_name),". Unable to add org.")
    GO TO exit_script
   ENDIF
   IF (validate(request->org[x].external_org_ind))
    SET externalorgind = request->org[x].external_org_ind
   ENDIF
   IF (org_data_partition_ind=1)
    INSERT  FROM organization o
     SET o.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, o.organization_id
       = org_id, o.contributor_system_cd = 0,
      o.org_name = trim(request->org[x].org_name), o.org_name_key = cnvtupper(cnvtalphanum(request->
        org[x].org_name)), o.federal_tax_id_nbr = request->org[x].federal_tax_id_nbr,
      o.org_status_cd = 0, o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd,
      o.data_status_dt_tm = cnvtdatetime(curdate,curtime3), o.data_status_prsnl_id = reqinfo->updt_id,
      o.beg_effective_dt_tm = cnvtdatetime(start_dt),
      o.end_effective_dt_tm = cnvtdatetime(end_dt), o.external_ind = externalorgind, o.active_ind = 1,
      o.active_status_cd = active_cd, o.active_status_prsnl_id = reqinfo->updt_id, o
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_applctx = reqinfo->updt_applctx, o
      .updt_cnt = 0,
      o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.ft_entity_id = 0
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM organization o
     SET o.organization_id = org_id, o.contributor_system_cd = 0, o.org_name = trim(request->org[x].
       org_name),
      o.org_name_key = cnvtupper(cnvtalphanum(request->org[x].org_name)), o.federal_tax_id_nbr =
      request->org[x].federal_tax_id_nbr, o.org_status_cd = 0,
      o.org_class_cd = org_class_cd, o.data_status_cd = auth_cd, o.data_status_dt_tm = cnvtdatetime(
       curdate,curtime3),
      o.data_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(start_dt), o
      .end_effective_dt_tm = cnvtdatetime(end_dt),
      o.external_ind = externalorgind, o.active_ind = 1, o.active_status_cd = active_cd,
      o.active_status_prsnl_id = reqinfo->updt_id, o.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = 0, o.updt_id = reqinfo->updt_id,
      o.updt_task = reqinfo->updt_task, o.ft_entity_id = 0
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing new organization row for org name: ",trim(request->org[x].
      org_name),".")
    GO TO exit_script
   ENDIF
   IF (((trim(request->org[x].org_prefix) > " ") OR ((((request->org[x].acute_care_ind > 0)) OR ((
   request->org[x].outreach_ind > 0))) )) )
    INSERT  FROM br_organization bo
     SET bo.organization_id = org_id, bo.br_prefix = trim(request->org[x].org_prefix), bo
      .acute_care_ind = request->org[x].acute_care_ind,
      bo.outreach_ind = request->org[x].outreach_ind
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing new br_organization row for org name: ",trim(request->org[
       x].org_name),".")
     GO TO exit_script
    ENDIF
   ENDIF
   SET add_client = 1
   SET otcnt = size(request->org[x].org_type,5)
   FOR (y = 1 TO otcnt)
     IF ((((request->org[x].org_type[y].org_type_code_value IN (bbmanuf_cd, bbsuppl_cd))) OR (trim(
      request->org[x].org_type[y].org_type_mean) IN ("BBMANUF", "BBSUPPL"))) )
      SET add_client = 0
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE chg_org(x)
   SET new_updt = 0
   DECLARE start_dt = dq8
   DECLARE end_dt = dq8
   SET start_dt = cnvtdatetime(curdate,curtime3)
   SET end_dt = cnvtdatetime("31-DEC-2100")
   SET temp_active_ind = 1
   SET temp_active_code = active_cd
   IF (validate(request->org[x].begin_effective_dt_tm))
    IF ((request->org[x].begin_effective_dt_tm > 0))
     SET start_dt = request->org[x].begin_effective_dt_tm
    ENDIF
    SET new_updt = 1
   ENDIF
   IF (validate(request->org[x].end_effective_dt_tm))
    IF ((request->org[x].end_effective_dt_tm > 0))
     SET end_dt = request->org[x].end_effective_dt_tm
    ENDIF
    SET new_updt = 1
   ENDIF
   IF (validate(request->org[x].active_ind))
    IF ((request->org[x].active_ind=1))
     SET temp_active_ind = 1
     SET temp_active_code = active_cd
    ELSE
     SET temp_active_ind = 0
     SET temp_active_code = inactive_code_value
    ENDIF
    SET new_updt = 1
   ENDIF
   IF (validate(request->org[x].external_org_ind))
    SET externalorgind = request->org[x].external_org_ind
   ENDIF
   IF (new_updt=1)
    UPDATE  FROM organization o
     SET o.org_name = trim(request->org[x].org_name), o.org_name_key = cnvtupper(cnvtalphanum(request
        ->org[x].org_name)), o.federal_tax_id_nbr = request->org[x].federal_tax_id_nbr,
      o.external_ind = externalorgind, o.active_ind = temp_active_ind, o.active_status_cd =
      temp_active_code,
      o.beg_effective_dt_tm = cnvtdatetime(start_dt), o.end_effective_dt_tm = cnvtdatetime(end_dt), o
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task,
      o.updt_applctx = reqinfo->updt_applctx
     WHERE o.organization_id=org_id
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM organization o
     SET o.org_name = trim(request->org[x].org_name), o.org_name_key = cnvtupper(cnvtalphanum(request
        ->org[x].org_name)), o.federal_tax_id_nbr = request->org[x].federal_tax_id_nbr,
      o.external_ind = externalorgind, o.active_ind = 1, o.active_status_cd = active_cd,
      o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), o.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), o.updt_cnt = (o.updt_cnt+ 1),
      o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
      updt_applctx
     WHERE o.organization_id=org_id
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM br_organization bo
     SET bo.br_prefix = trim(request->org[x].org_prefix), bo.acute_care_ind = request->org[x].
      acute_care_ind, bo.outreach_ind = request->org[x].outreach_ind,
      bo.updt_dt_tm = cnvtdatetime(curdate,curtime3), bo.updt_applctx = reqinfo->updt_applctx, bo
      .updt_cnt = 0,
      bo.updt_id = reqinfo->updt_id, bo.updt_task = reqinfo->updt_task
     WHERE bo.organization_id=org_id
     WITH nocounter
    ;end update
    IF (curqual=0
     AND trim(request->org[x].org_prefix) > " ")
     INSERT  FROM br_organization bo
      SET bo.organization_id = org_id, bo.br_prefix = trim(request->org[x].org_prefix), bo
       .acute_care_ind = request->org[x].acute_care_ind,
       bo.outreach_ind = request->org[x].outreach_ind
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing new br_organization row for org name: ",trim(request->
        org[x].org_name),".")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error updating organization row for org name: ",trim(request->org[x].
      org_name),".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_org(x)
   UPDATE  FROM organization o
    SET o.active_ind = 0, o.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     o.updt_cnt = (o.updt_cnt+ 1), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task,
     o.updt_applctx = reqinfo->updt_applctx
    WHERE o.organization_id=org_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating organization row for org name: ",trim(request->org[x].
      org_name),".")
    GO TO exit_script
   ENDIF
   SET facility_code_value = 0.0
   SELECT INTO "nl:"
    FROM location l,
     code_value cv
    PLAN (l
     WHERE l.organization_id=org_id
      AND l.active_ind=1)
     JOIN (cv
     WHERE cv.active_ind=1
      AND cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.code_value=l.location_cd)
    DETAIL
     facility_code_value = cv.code_value
    WITH nocounter
   ;end select
   CALL echo(facility_code_value)
   IF (facility_code_value > 0.0)
    SET request_cv->cd_value_list[1].action_flag = 3
    SET request_cv->cd_value_list[1].code_value = facility_code_value
    SET request_cv->cd_value_list[1].code_set = 220
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    SET bcnt = 0
    SET ucnt = 0
    SET rcnt = 0
    SET dcnt = 0
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE lg.parent_loc_cd=facility_code_value
      AND lg.active_ind=1
      AND lg.root_loc_cd=0
     HEAD REPORT
      bcnt = 0
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(blgs->blist,bcnt), blgs->blist[bcnt].code_value = lg
      .child_loc_cd
     WITH nocounter
    ;end select
    IF (bcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = bcnt),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=blgs->blist[d.seq].code_value)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
      HEAD REPORT
       ucnt = 0
      DETAIL
       ucnt = (ucnt+ 1), stat = alterlist(units->ulist,ucnt), units->ulist[ucnt].code_value = lg
       .child_loc_cd
      WITH nocounter
     ;end select
    ENDIF
    IF (ucnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = ucnt),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=units->ulist[d.seq].code_value)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
      HEAD REPORT
       rcnt = 0
      DETAIL
       rcnt = (rcnt+ 1), stat = alterlist(rooms->rlist,rcnt), rooms->rlist[rcnt].code_value = lg
       .child_loc_cd
      WITH nocounter
     ;end select
    ENDIF
    IF (rcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = rcnt),
       location_group lg
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=rooms->rlist[d.seq].code_value)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
      HEAD REPORT
       dcnt = 0
      DETAIL
       dcnt = (dcnt+ 1), stat = alterlist(beds->dlist,dcnt), beds->dlist[dcnt].code_value = lg
       .child_loc_cd
      WITH nocounter
     ;end select
    ENDIF
    FOR (i = 1 TO bcnt)
      SET request_cv->cd_value_list[1].action_flag = 3
      SET request_cv->cd_value_list[1].code_value = blgs->blist[i].code_value
      SET request_cv->cd_value_list[1].code_set = 220
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      UPDATE  FROM location_group lg
       SET lg.active_ind = 0, lg.active_status_cd = inactive_code_value, lg.updt_dt_tm = cnvtdatetime
        (curdate,curtime),
        lg.updt_id = reqinfo->updt_id, lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->
        updt_applctx,
        lg.updt_cnt = (lg.updt_cnt+ 1)
       WHERE (((lg.parent_loc_cd=blgs->blist[i].code_value)) OR ((lg.child_loc_cd=blgs->blist[i].
       code_value)))
       WITH nocounter
      ;end update
    ENDFOR
    FOR (i = 1 TO ucnt)
      SET request_cv->cd_value_list[1].action_flag = 3
      SET request_cv->cd_value_list[1].code_value = units->ulist[i].code_value
      SET request_cv->cd_value_list[1].code_set = 220
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      UPDATE  FROM nurse_unit nu
       SET nu.active_ind = 0, nu.active_status_cd = inactive_code_value, nu.updt_dt_tm = cnvtdatetime
        (curdate,curtime),
        nu.updt_id = reqinfo->updt_id, nu.updt_task = reqinfo->updt_task, nu.updt_applctx = reqinfo->
        updt_applctx,
        nu.updt_cnt = (nu.updt_cnt+ 1)
       WHERE (nu.location_cd=units->ulist[i].code_value)
       WITH nocounter
      ;end update
    ENDFOR
    FOR (i = 1 TO rcnt)
      SET request_cv->cd_value_list[1].action_flag = 3
      SET request_cv->cd_value_list[1].code_value = rooms->rlist[i].code_value
      SET request_cv->cd_value_list[1].code_set = 220
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      UPDATE  FROM location_group lg
       SET lg.active_ind = 0, lg.active_status_cd = inactive_code_value, lg.updt_dt_tm = cnvtdatetime
        (curdate,curtime),
        lg.updt_id = reqinfo->updt_id, lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->
        updt_applctx,
        lg.updt_cnt = (lg.updt_cnt+ 1)
       WHERE (((lg.parent_loc_cd=rooms->rlist[i].code_value)) OR ((lg.child_loc_cd=rooms->rlist[i].
       code_value)))
       WITH nocounter
      ;end update
      UPDATE  FROM room r
       SET r.active_ind = 0, r.active_status_cd = inactive_code_value, r.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
        updt_applctx,
        r.updt_cnt = (r.updt_cnt+ 1)
       WHERE (r.location_cd=rooms->rlist[i].code_value)
       WITH nocounter
      ;end update
    ENDFOR
    FOR (i = 1 TO dcnt)
      SET request_cv->cd_value_list[1].action_flag = 3
      SET request_cv->cd_value_list[1].code_value = beds->dlist[i].code_value
      SET request_cv->cd_value_list[1].code_set = 220
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      UPDATE  FROM bed b
       SET b.active_ind = 0, b.active_status_cd = inactive_code_value, b.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx,
        b.updt_cnt = (b.updt_cnt+ 1)
       WHERE (b.location_cd=beds->dlist[i].code_value)
       WITH nocounter
      ;end update
    ENDFOR
   ENDIF
   UPDATE  FROM location l
    SET l.active_ind = 0, l.active_status_cd = inactive_code_value, l.updt_dt_tm = cnvtdatetime(
      curdate,curtime),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx,
     l.updt_cnt = (l.updt_cnt+ 1)
    WHERE l.organization_id=org_id
     AND l.active_ind=1
    WITH nocounter
   ;end update
   CALL echo(build("b = ",cnvtstring(bcnt)))
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_fac(x)
   INSERT  FROM org_type_reltn otr
    SET otr.organization_id = org_id, otr.org_type_cd = fac_org_type_code_value, otr.updt_id =
     reqinfo->updt_id,
     otr.updt_cnt = 0, otr.updt_applctx = reqinfo->updt_applctx, otr.updt_task = reqinfo->updt_task,
     otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_ind = 1, otr.active_status_cd =
     active_cd,
     otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id = reqinfo->
     updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing org type relation for org name: ",request->org[x].org_name,
     " org type: FACILITY.")
    GO TO exit_script
   ENDIF
   SET facility_code_value = 0.0
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 220
   SET request_cv->cd_value_list[1].cdf_meaning = "FACILITY"
   SET request_cv->cd_value_list[1].display = request->org[x].facility.display
   SET request_cv->cd_value_list[1].description = request->org[x].facility.description
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET reply->qual[x].facility_code_value = reply_cv->qual[1].code_value
    SET facility_code_value = reply_cv->qual[1].code_value
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error writing FACILITY code value for org name: ",request->org[x].
     org_name," onto cs 220.")
    GO TO exit_script
   ENDIF
   INSERT  FROM location l
    SET l.location_cd = facility_code_value, l.location_type_cd = fac_loc_type_code_value, l
     .organization_id = org_id,
     l.resource_ind = 0, l.census_ind = 0, l.transmit_outbound_order_ind = 0,
     l.patcare_node_ind = 1, l.ref_lab_acct_nbr = " ", l.active_ind = 1,
     l.active_status_cd = active_cd, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
     .active_status_prsnl_id = reqinfo->updt_id,
     l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 23:59:59.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
     updt_applctx,
     l.updt_cnt = 0, l.data_status_cd = auth_cd, l.data_status_prsnl_id = 0,
     l.data_status_dt_tm = cnvtdatetime(curdate,curtime3), l.contributor_system_cd = 0, l
     .contributor_source_cd = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing FACILITY location for org name: ",request->org[x].org_name,
     " org type:  on location table.")
    GO TO exit_script
   ENDIF
   INSERT  FROM time_zone_r tz
    SET tz.parent_entity_id = facility_code_value, tz.parent_entity_name = "LOCATION", tz.time_zone
      = request->org[x].time_zone_display,
     tz.updt_dt_tm = cnvtdatetime(curdate,curtime3), tz.updt_applctx = reqinfo->updt_applctx, tz
     .updt_cnt = 0,
     tz.updt_id = reqinfo->updt_id, tz.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing new time_zone_r row for org name: ",trim(request->org[x].
      org_name),".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_fac(x)
   IF (start_fac_exists=0)
    SET facility_code_value = request->org[x].facility.code_value
   ENDIF
   IF (facility_code_value=0)
    SET error_flag = "Y"
    SET error_msg = "The facility_code_value must be defined for change action."
    GO TO exit_script
   ENDIF
   SET institution_cd = 0
   SET facility_name = fillstring(60," ")
   SELECT INTO "nl:"
    FROM code_value cv,
     code_value cv2
    PLAN (cv
     WHERE cv.code_value=facility_code_value)
     JOIN (cv2
     WHERE cv2.code_set=221
      AND cv2.cdf_meaning="INSTITUTION"
      AND ((cv2.display=cv.display) OR (cv2.description=cv.description)) )
    DETAIL
     institution_cd = cv2.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=facility_code_value
     DETAIL
      facility_name = cv.description
     WITH nocounter
    ;end select
    IF (((facility_name="START Organization") OR (facility_name="STANDARD Organization")) )
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=221
        AND ((cv.display="START Inst") OR (cv.display="STANDARD Inst")) )
      DETAIL
       institution_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual > 1)
      SET error_flag = "Y"
      SET error_msg = concat("Multiple code values on code set 221 ",
       "exist with a DISPLAY of either START Inst or STANDARD Inst")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (institution_cd > 0)
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = 221
    SET request_cv->cd_value_list[1].code_value = institution_cd
    SET request_cv->cd_value_list[1].cdf_meaning = "INSTITUTION"
    SET request_cv->cd_value_list[1].display = request->org[x].facility.display
    SET request_cv->cd_value_list[1].description = request->org[x].facility.description
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.description = request->org[x].facility.description, cv.display = request->org[x].facility.
     display, cv.display_key = trim(cnvtupper(cnvtalphanum(request->org[x].facility.display))),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo->updt_id, cv.updt_task =
     reqinfo->updt_task,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
    WHERE cv.active_ind=1
     AND cv.code_set=220
     AND cv.code_value=facility_code_value
    WITH nocounter
   ;end update
   UPDATE  FROM location l
    SET l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task =
     reqinfo->updt_task,
     l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt+ 1)
    WHERE l.location_cd=facility_code_value
    WITH nocounter
   ;end update
   SET reply->qual[x].facility_code_value = facility_code_value
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update facility ",request->org[x].facility.short_description,
     ".")
    GO TO exit_script
   ENDIF
   UPDATE  FROM time_zone_r tz
    SET tz.time_zone = request->org[x].time_zone_display, tz.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), tz.updt_applctx = reqinfo->updt_applctx,
     tz.updt_cnt = (tz.updt_cnt+ 1), tz.updt_id = reqinfo->updt_id, tz.updt_task = reqinfo->updt_task
    WHERE tz.parent_entity_id=facility_code_value
     AND tz.parent_entity_name="LOCATION"
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM time_zone_r tz
     SET tz.parent_entity_id = facility_code_value, tz.parent_entity_name = "LOCATION", tz.time_zone
       = request->org[x].time_zone_display,
      tz.updt_dt_tm = cnvtdatetime(curdate,curtime3), tz.updt_applctx = reqinfo->updt_applctx, tz
      .updt_cnt = 0,
      tz.updt_id = reqinfo->updt_id, tz.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing new time_zone_r row for org name: ",trim(request->org[x].
       org_name),".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_fac(x)
   SET facility_code_value = request->org[x].facility.code_value
   IF (facility_code_value=0)
    SET error_flag = "Y"
    SET error_msg = "The facility_code_value must be defined for change action."
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.active_ind = 0, cv.active_type_cd = inactive_code_value, cv.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo->updt_id, cv.updt_task =
     reqinfo->updt_task,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
    WHERE cv.active_ind=1
     AND cv.code_set=220
     AND cv.code_value=facility_code_value
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to inactivate facility ",request->org[x].facility.
     short_description,".")
    GO TO exit_script
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_org_type(x,y)
   SET org_type_cd = 0.0
   IF ((request->org[x].org_type[y].org_type_code_value=0))
    IF (trim(request->org[x].org_type[y].org_type_mean)=" ")
     SET error_flag = "Y"
     SET error_msg = concat("The org_type_code_value and org_type_mean not defined ",
      "org type relation for org name: ",request->org[x].org_name," not added.")
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=278
      AND (c.cdf_meaning=request->org[x].org_type[y].org_type_mean)
     DETAIL
      org_type_cd = c.code_value
     WITH nocounter
    ;end select
    IF (org_type_cd=0)
     SET error_flag = "Y"
     SET error_msg = concat("Code value not found for org type mean: ",request->org[x].org_type[y].
      org_type_mean,". Unable to add org type relation for org name: ",request->org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET org_type_cd = request->org[x].org_type[y].org_type_code_value
   ENDIF
   SET temp_active_ind = - (1)
   SELECT INTO "nl:"
    FROM org_type_reltn otr
    PLAN (otr
     WHERE otr.org_type_cd=org_type_cd
      AND otr.organization_id=org_id)
    DETAIL
     temp_active_ind = otr.active_ind
    WITH nocounter
   ;end select
   IF (curqual > 0
    AND temp_active_ind=1)
    IF (start_org_exists=0)
     SET error_flag = "Y"
     SET error_msg = concat("Org type relation already exists for org name: ",request->org[x].
      org_name," org type: ",request->org[x].org_type[y].org_type_mean,".")
     GO TO exit_script
    ENDIF
   ELSE
    IF (temp_active_ind=0)
     UPDATE  FROM org_type_reltn otr
      SET otr.active_ind = 1, otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo
       ->updt_id,
       otr.updt_task = reqinfo->updt_task, otr.updt_applctx = reqinfo->updt_applctx, otr.updt_cnt = (
       otr.updt_cnt+ 1)
      WHERE otr.organization_id=org_id
       AND otr.org_type_cd=org_type_cd
      WITH nocounter
     ;end update
    ELSE
     INSERT  FROM org_type_reltn otr
      SET otr.organization_id = org_id, otr.org_type_cd = org_type_cd, otr.updt_id = reqinfo->updt_id,
       otr.updt_cnt = 0, otr.updt_applctx = reqinfo->updt_applctx, otr.updt_task = reqinfo->updt_task,
       otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_ind = 1, otr.active_status_cd =
       active_cd,
       otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id = reqinfo
       ->updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing org type relation for org name: ",request->org[x].org_name,
      " org type: ",request->org[x].org_type[y].org_type_mean,".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_org_type(x,y)
   SET org_type_cd = 0.0
   IF ((request->org[x].org_type[y].org_type_code_value=0))
    IF (trim(request->org[x].org_type[y].org_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=278
        AND (c.cdf_meaning=request->org[x].org_type[y].org_type_mean))
      DETAIL
       org_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (org_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for org type mean: ",request->org[x].org_type[y].
       org_type_mean,". Unable to remove org type relation for org name: ",request->org[x].org_name,
       ".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Org type code value not available, unable to remove ",
      "org type relation for org name: ",request->org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET org_type_cd = request->org[x].org_type[y].org_type_code_value
   ENDIF
   IF (org_type_cd > 0)
    DELETE  FROM org_type_reltn otr
     WHERE otr.org_type_cd=org_type_cd
      AND otr.organization_id=org_id
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error deleting org type relation for org name: ",request->org[x].
      org_name," org type: ",request->org[x].org_type[y].org_type_mean,".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_address(x,y)
   SET address_type_cd = 0.0
   IF ((request->org[x].address[y].address_type_code_value=0))
    IF (trim(request->org[x].address[y].address_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=212
        AND (c.cdf_meaning=request->org[x].address[y].address_type_mean))
      DETAIL
       address_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (address_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for address type mean: ",request->org[x].address[y
       ].address_type_mean,". Unable to add address for org name: ",request->org[x].org_name,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Address type code value not available, unable to add ",
      "address for org name: ",request->org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET address_type_cd = request->org[x].address[y].address_type_code_value
   ENDIF
   IF (address_type_cd > 0)
    SET state_display = " "
    IF ((request->org[x].address[y].state_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->org[x].address[y].state_code_value)
       AND cv.active_ind=1
      DETAIL
       state_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET county_display = " "
    IF ((request->org[x].address[y].county_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->org[x].address[y].county_code_value)
       AND cv.active_ind=1
      DETAIL
       county_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET country_display = " "
    IF ((request->org[x].address[y].country_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->org[x].address[y].country_code_value)
       AND cv.active_ind=1
      DETAIL
       country_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET beg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET end_dt_tm = cnvtdatetime("31-DEC-2100")
    IF (validate(request->org[x].address[y].beg_effective_dt_tm))
     IF ((request->org[x].address[y].beg_effective_dt_tm > 0))
      SET beg_dt_tm = request->org[x].address[y].beg_effective_dt_tm
     ENDIF
    ENDIF
    IF (validate(request->org[x].address[y].end_effective_dt_tm))
     IF ((request->org[x].address[y].end_effective_dt_tm > 0))
      SET end_dt_tm = request->org[x].address[y].end_effective_dt_tm
     ENDIF
    ENDIF
    SET save_sequence = 0
    IF (validate(request->org[x].address[y].sequence))
     SET save_sequence = request->org[x].address[y].sequence
    ENDIF
    INSERT  FROM address a
     SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORGANIZATION", a
      .parent_entity_id = org_id,
      a.address_type_cd = address_type_cd, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
      a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3),
      a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm), a
      .end_effective_dt_tm = cnvtdatetime(end_dt_tm),
      a.street_addr = request->org[x].address[y].street_addr1, a.street_addr2 = request->org[x].
      address[y].street_addr2, a.street_addr3 = request->org[x].address[y].street_addr3,
      a.street_addr4 = request->org[x].address[y].street_addr4, a.city = request->org[x].address[y].
      city, a.state = state_display,
      a.state_cd = request->org[x].address[y].state_code_value, a.zipcode = request->org[x].address[y
      ].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->org[x].address[y].zipcode)),
      a.county = county_display, a.county_cd = request->org[x].address[y].county_code_value, a
      .country = country_display,
      a.country_cd = request->org[x].address[y].country_code_value, a.contact_name = request->org[x].
      address[y].contact_name, a.comment_txt = request->org[x].address[y].comment_txt,
      a.postal_barcode_info = " ", a.mail_stop = " ", a.operation_hours = " ",
      a.address_type_seq = save_sequence, a.data_status_cd = auth_cd, a.data_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      a.data_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing address for org name: ",request->org[x].org_name,
      " address type: ",request->org[x].address[y].address_type_mean,".")
     GO TO exit_script
    ENDIF
    IF (facility_code_value > 0)
     INSERT  FROM address a
      SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "LOCATION", a
       .parent_entity_id = facility_code_value,
       a.address_type_cd = address_type_cd, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       a.active_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm),
       a.end_effective_dt_tm = cnvtdatetime(end_dt_tm),
       a.street_addr = request->org[x].address[y].street_addr1, a.street_addr2 = request->org[x].
       address[y].street_addr2, a.street_addr3 = request->org[x].address[y].street_addr3,
       a.street_addr4 = request->org[x].address[y].street_addr4, a.city = request->org[x].address[y].
       city, a.state = state_display,
       a.state_cd = request->org[x].address[y].state_code_value, a.zipcode = request->org[x].address[
       y].zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->org[x].address[y].zipcode)),
       a.county = county_display, a.county_cd = request->org[x].address[y].county_code_value, a
       .country = country_display,
       a.country_cd = request->org[x].address[y].country_code_value, a.contact_name = request->org[x]
       .address[y].contact_name, a.comment_txt = request->org[x].address[y].comment_txt,
       a.postal_barcode_info = " ", a.mail_stop = " ", a.operation_hours = " ",
       a.address_type_seq = save_sequence, a.data_status_cd = auth_cd, a.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error writing facility address for org name: ",request->org[x].org_name,
       " address type: ",request->org[x].address[y].address_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_address(x,y)
  IF ((request->org[x].address[y].address_id > 0))
   SET state_display = " "
   IF ((request->org[x].address[y].state_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->org[x].address[y].state_code_value)
      AND cv.active_ind=1
     DETAIL
      state_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET county_display = " "
   IF ((request->org[x].address[y].county_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->org[x].address[y].county_code_value)
      AND cv.active_ind=1
     DETAIL
      county_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET country_display = " "
   IF ((request->org[x].address[y].country_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->org[x].address[y].country_code_value)
      AND cv.active_ind=1
     DETAIL
      country_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM address a
    WHERE (a.address_id=request->org[x].address[y].address_id)
    DETAIL
     beg_dt_tm = a.beg_effective_dt_tm, end_dt_tm = a.end_effective_dt_tm, save_sequence = a
     .address_type_seq
    WITH nocounter
   ;end select
   IF (validate(request->org[x].address[y].beg_effective_dt_tm))
    IF ((request->org[x].address[y].beg_effective_dt_tm > 0))
     SET beg_dt_tm = request->org[x].address[y].beg_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[x].address[y].end_effective_dt_tm))
    IF ((request->org[x].address[y].end_effective_dt_tm > 0))
     SET end_dt_tm = request->org[x].address[y].end_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[x].address[y].sequence))
    SET save_sequence = request->org[x].address[y].sequence
   ENDIF
   UPDATE  FROM address a
    SET a.street_addr = request->org[x].address[y].street_addr1, a.street_addr2 = request->org[x].
     address[y].street_addr2, a.street_addr3 = request->org[x].address[y].street_addr3,
     a.street_addr4 = request->org[x].address[y].street_addr4, a.city = request->org[x].address[y].
     city, a.state = state_display,
     a.state_cd = request->org[x].address[y].state_code_value, a.zipcode = request->org[x].address[y]
     .zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->org[x].address[y].zipcode)),
     a.county = county_display, a.county_cd = request->org[x].address[y].county_code_value, a.country
      = country_display,
     a.country_cd = request->org[x].address[y].country_code_value, a.address_type_cd = request->org[x
     ].address[y].address_type_code_value, a.contact_name = request->org[x].address[y].contact_name,
     a.comment_txt = request->org[x].address[y].comment_txt, a.beg_effective_dt_tm = cnvtdatetime(
      beg_dt_tm), a.end_effective_dt_tm = cnvtdatetime(end_dt_tm),
     a.address_type_seq = save_sequence, a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->org[x].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating address for org name: ",request->org[x].org_name,
     " address type: ",request->org[x].address[y].address_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error updating address for org name: ",request->org[x
    ].org_name," address type: ",request->org[x].address[y].address_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_address(x,y)
  IF ((request->org[x].address[y].address_id > 0))
   UPDATE  FROM address a
    SET a.active_ind = 0, a.active_status_cd = inactive_code_value, a.updt_cnt = (a.updt_cnt+ 1),
     a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
     updt_applctx,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->org[x].address[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating address for org name: ",request->org[x].org_name,
     " address type: ",request->org[x].address[y].address_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Address_ID required, error inactivating address for org name: ",request->
    org[x].org_name," address type: ",request->org[x].address[y].address_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_phone(x,y)
   SET contact_method_cd = 0.0
   IF (validate(request->org[x].phone[y].contact_method_code_value))
    SET contact_method_cd = request->org[x].phone[y].contact_method_code_value
   ENDIF
   SET contributor_system_cd = 0.0
   IF (validate(request->org[x].phone[y].contributor_system_code_value))
    SET contributor_system_cd = request->org[x].phone[y].contributor_system_code_value
   ENDIF
   SET phone_type_cd = 0.0
   IF ((request->org[x].phone[y].phone_type_code_value=0))
    IF (trim(request->org[x].phone[y].phone_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=43
        AND (c.cdf_meaning=request->org[x].phone[y].phone_type_mean))
      DETAIL
       phone_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (phone_type_cd=0)
      SET error_flag = "Y"
      SET error_msg = concat("Code value not found for phone type mean: ",request->org[x].phone[y].
       phone_type_mean,". Unable to add phone for org name: ",request->org[x].org_name,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Phone type code value not available, unable to add ",
      "phone for org name: ",request->org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ELSE
    SET phone_type_cd = request->org[x].phone[y].phone_type_code_value
   ENDIF
   SET phone_format_cd = 0.0
   IF ((request->org[x].phone[y].phone_format_code_value > 0))
    SET phone_format_cd = request->org[x].phone[y].phone_format_code_value
   ELSE
    IF (trim(request->org[x].phone[y].phone_format_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=281
        AND (c.cdf_meaning=request->org[x].phone[y].phone_format_mean))
      DETAIL
       phone_format_cd = c.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to find phone format on code set 281 for: ",request->org[x].
       phone[y].phone_format_mean,".")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Invalid phone format on org: ",request->org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   SET phone_id = 0.0
   SELECT INTO "nl:"
    FROM phone p
    PLAN (p
     WHERE p.phone_type_cd=phone_type_cd
      AND p.parent_entity_id=org_id
      AND p.active_ind=1
      AND p.parent_entity_name="ORGANIZATION")
    DETAIL
     IF (p.phone_num="     *")
      phone_id = p.phone_id, beg_dt_tm = p.beg_effective_dt_tm, end_dt_tm = p.end_effective_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF (start_org_exists=1
     AND phone_id > 0)
     IF (validate(request->org[x].phone[y].beg_effective_dt_tm))
      IF ((request->org[x].phone[y].beg_effective_dt_tm > 0))
       SET beg_dt_tm = request->org[x].phone[y].beg_effective_dt_tm
      ENDIF
     ENDIF
     IF (validate(request->org[x].phone[y].end_effective_dt_tm))
      IF ((request->org[x].phone[y].end_effective_dt_tm > 0))
       SET end_dt_tm = request->org[x].phone[y].end_effective_dt_tm
      ENDIF
     ENDIF
     UPDATE  FROM phone p
      SET p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = request
       ->org[x].phone[y].phone_num,
       p.phone_num_key = cnvtupper(cnvtalphanum(request->org[x].phone[y].phone_num)), p
       .phone_type_seq = request->org[x].phone[y].sequence, p.description = request->org[x].phone[y].
       description,
       p.contact = request->org[x].phone[y].contact, p.call_instruction = request->org[x].phone[y].
       call_instruction, p.paging_code = request->org[x].phone[y].paging_code,
       p.extension = request->org[x].phone[y].extension, p.phone_type_cd = request->org[x].phone[y].
       phone_type_code_value, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.beg_effective_dt_tm = cnvtdatetime(
        beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(end_dt_tm),
       p.contact_method_cd = contact_method_cd, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->
       updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE p.phone_id=phone_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error updating phone for org name: ",request->org[x].org_name,
       " phone type: ",request->org[x].phone[y].phone_type_mean,".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF ((request->org[x].phone[y].sequence IN (null, 0)))
    SET request->org[x].phone[y].sequence = 1
   ENDIF
   SET beg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET end_dt_tm = cnvtdatetime("31-DEC-2100")
   IF (validate(request->org[x].phone[y].beg_effective_dt_tm))
    IF ((request->org[x].phone[y].beg_effective_dt_tm > 0))
     SET beg_dt_tm = request->org[x].phone[y].beg_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[x].phone[y].end_effective_dt_tm))
    IF ((request->org[x].phone[y].end_effective_dt_tm > 0))
     SET end_dt_tm = request->org[x].phone[y].end_effective_dt_tm
    ENDIF
   ENDIF
   INSERT  FROM phone p
    SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION", p
     .parent_entity_id = org_id,
     p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = trim(request
      ->org[x].phone[y].phone_num),
     p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->org[x].phone[y].phone_num))), p
     .phone_type_seq = request->org[x].phone[y].sequence, p.description = trim(request->org[x].phone[
      y].description),
     p.contact = trim(request->org[x].phone[y].contact), p.call_instruction = trim(request->org[x].
      phone[y].call_instruction), p.extension = trim(request->org[x].phone[y].extension),
     p.paging_code = trim(request->org[x].phone[y].paging_code), p.contact_method_cd =
     contact_method_cd, p.contributor_system_cd = contributor_system_cd,
     p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
     p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind =
     1,
     p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
     .active_status_prsnl_id = reqinfo->updt_id,
     p.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(end_dt_tm),
     p.data_status_cd = auth_cd,
     p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error writing phone for org name: ",request->org[x].org_name,
     " phone type: ",request->org[x].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
   IF (facility_code_value > 0
    AND phone_type_cd != intsecemail_cd
    AND phone_type_cd != extsecemail_cd)
    INSERT  FROM phone p
     SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "LOCATION", p.parent_entity_id
       = facility_code_value,
      p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = trim(
       request->org[x].phone[y].phone_num),
      p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->org[x].phone[y].phone_num))), p
      .phone_type_seq = request->org[x].phone[y].sequence, p.description = trim(request->org[x].
       phone[y].description),
      p.contact = trim(request->org[x].phone[y].contact), p.call_instruction = trim(request->org[x].
       phone[y].call_instruction), p.extension = trim(request->org[x].phone[y].extension),
      p.paging_code = trim(request->org[x].phone[y].paging_code), p.contact_method_cd =
      contact_method_cd, p.contributor_system_cd = contributor_system_cd,
      p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
      p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind
       = 1,
      p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
      .active_status_prsnl_id = reqinfo->updt_id,
      p.beg_effective_dt_tm = cnvtdatetime(beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(end_dt_tm
       ), p.data_status_cd = auth_cd,
      p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing facility phone for org name: ",request->org[x].org_name,
      " phone type: ",request->org[x].phone[y].phone_type_mean,".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_phone(x,y)
  IF ((request->org[x].phone[y].phone_id > 0))
   SELECT INTO "nl:"
    FROM phone p
    WHERE (p.phone_id=request->org[x].phone[y].phone_id)
    DETAIL
     beg_dt_tm = p.beg_effective_dt_tm, end_dt_tm = p.end_effective_dt_tm
    WITH nocounter
   ;end select
   IF (validate(request->org[x].phone[y].beg_effective_dt_tm))
    IF ((request->org[x].phone[y].beg_effective_dt_tm > 0))
     SET beg_dt_tm = request->org[x].phone[y].beg_effective_dt_tm
    ENDIF
   ENDIF
   IF (validate(request->org[x].phone[y].end_effective_dt_tm))
    IF ((request->org[x].phone[y].end_effective_dt_tm > 0))
     SET end_dt_tm = request->org[x].phone[y].end_effective_dt_tm
    ENDIF
   ENDIF
   SET contact_method_cd = 0.0
   IF (validate(request->org[x].phone[y].contact_method_code_value))
    SET contact_method_cd = request->org[x].phone[y].contact_method_code_value
   ENDIF
   UPDATE  FROM phone p
    SET p.phone_format_cd = request->org[x].phone[y].phone_format_code_value, p.phone_num = request->
     org[x].phone[y].phone_num, p.phone_num_key = cnvtupper(cnvtalphanum(request->org[x].phone[y].
       phone_num)),
     p.phone_type_seq = request->org[x].phone[y].sequence, p.description = request->org[x].phone[y].
     description, p.contact = request->org[x].phone[y].contact,
     p.call_instruction = request->org[x].phone[y].call_instruction, p.paging_code = request->org[x].
     phone[y].paging_code, p.extension = request->org[x].phone[y].extension,
     p.phone_type_cd = request->org[x].phone[y].phone_type_code_value, p.beg_effective_dt_tm =
     cnvtdatetime(beg_dt_tm), p.end_effective_dt_tm = cnvtdatetime(end_dt_tm),
     p.contact_method_cd = contact_method_cd, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->
     updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->org[x].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating phone for org name: ",request->org[x].org_name,
     " phone type: ",request->org[x].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error updating phone for org name: ",request->org[x].
    org_name," phone type: ",request->org[x].phone[y].phone_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_phone(x,y)
  IF ((request->org[x].phone[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.active_ind = 0, p.active_status_cd = inactive_code_value, p.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime),
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->org[x].phone[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inactivating phone for org name: ",request->org[x].org_name,
     " phone type: ",request->org[x].phone[y].phone_type_mean,".")
    GO TO exit_script
   ENDIF
  ELSE
   SET error_flag = "Y"
   SET error_msg = concat("Phone_ID required, error inactivating phone for org name: ",request->org[x
    ].org_name," phone type: ",request->org[x].phone[y].phone_type_mean,".")
   GO TO exit_script
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_instr(x,y)
   SELECT INTO "nl:"
    FROM br_instr_org_reltn bior
    PLAN (bior
     WHERE bior.organization_id=org_id
      AND (bior.br_instr_id=request->org[x].instr[y].br_instr_id)
      AND bior.model_disp=trim(request->org[x].instr[y].model_disp))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET new_id = 0.0
    SELECT INTO "nl:"
     FROM br_instr_org_reltn bior
     PLAN (bior
      WHERE bior.br_instr_org_reltn_id > 0)
     ORDER BY bior.br_instr_org_reltn_id DESC
     HEAD REPORT
      new_id = bior.br_instr_org_reltn_id
     WITH nocounter
    ;end select
    SET new_id = (new_id+ 1)
    INSERT  FROM br_instr_org_reltn bior
     SET bior.organization_id = org_id, bior.br_instr_id = request->org[x].instr[y].br_instr_id, bior
      .br_instr_org_reltn_id = new_id,
      bior.model_disp = trim(request->org[x].instr[y].model_disp), bior.poc_ind = request->org[x].
      instr[y].point_of_care_ind, bior.robotics_ind = request->org[x].instr[y].robotics_ind,
      bior.multiplexor_ind = request->org[x].instr[y].multiplexor_ind, bior.uni_ind = request->org[x]
      .instr[y].uni_ind, bior.bi_ind = request->org[x].instr[y].bi_ind,
      bior.hq_ind = request->org[x].instr[y].hq_ind, bior.interface_ind = request->org[x].instr[y].
      interface_ind, bior.model = trim(request->org[x].instr[y].model),
      bior.manufacturer = trim(request->org[x].instr[y].manufacturer), bior.type = trim(request->org[
       x].instr[y].itype), bior.activity_type_mean = trim(request->org[x].instr[y].activity_type_mean
       )
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing instr for org name: ",request->org[x].org_name,
      " instr id: ",cnvtstring(request->org[x].instr[y].br_instr_id),".")
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_instr(x,y)
  UPDATE  FROM br_instr_org_reltn bior
   SET bior.model_disp = request->org[x].instr[y].model_disp, bior.poc_ind = request->org[x].instr[y]
    .point_of_care_ind, bior.robotics_ind = request->org[x].instr[y].robotics_ind,
    bior.multiplexor_ind = request->org[x].instr[y].multiplexor_ind, bior.uni_ind = request->org[x].
    instr[y].uni_ind, bior.bi_ind = request->org[x].instr[y].bi_ind,
    bior.hq_ind = request->org[x].instr[y].hq_ind, bior.interface_ind = request->org[x].instr[y].
    interface_ind, bior.model = request->org[x].instr[y].model,
    bior.manufacturer = request->org[x].instr[y].manufacturer, bior.type = request->org[x].instr[y].
    itype, bior.activity_type_mean = request->org[x].instr[y].activity_type_mean
   WHERE (bior.br_instr_org_reltn_id=request->org[x].instr[y].br_instr_org_reltn_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_msg = concat("Error updating instr for org name: ",request->org[x].org_name,
    " instr id: ",cnvtstring(request->org[x].instr[y].br_instr_id),".")
  ENDIF
 END ;Subroutine
 SUBROUTINE del_instr(x,y)
  DELETE  FROM br_instr_org_reltn bior
   PLAN (bior
    WHERE (bior.br_instr_org_reltn_id=request->org[x].instr[y].br_instr_org_reltn_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Error deleting instr for org name: ",request->org[x].org_name,
    " instr id: ",cnvtstring(request->org[x].instr[y].br_instr_id),".")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE add_alias_pools(x)
   IF (dea_type > 0.0
    AND dea_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "PRSNL_ALIAS", oapr
      .alias_entity_alias_type_cd = dea_type,
      oapr.alias_pool_cd = dea_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing DEA Alias Pool relationship for: ",request->org[x].
      org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (prsnlprim_type > 0.0
    AND prsnlprim_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "PRSNL_ALIAS", oapr
      .alias_entity_alias_type_cd = prsnlprim_type,
      oapr.alias_pool_cd = prsnlprim_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing Prsnl Primary ID Alias Pool relationship for: ",request->
      org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (empcode_type > 0.0
    AND empcode_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "ORGANIZATION_ALIAS", oapr
      .alias_entity_alias_type_cd = empcode_type,
      oapr.alias_pool_cd = empcode_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing Employer Code Alias Pool relationship for: ",request->org[
      x].org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (encorg_type > 0.0
    AND encorg_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "ORGANIZATION_ALIAS", oapr
      .alias_entity_alias_type_cd = encorg_type,
      oapr.alias_pool_cd = encorg_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing Encounter Org Alias Pool relationship for: ",request->org[
      x].org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (extid_type > 0.0
    AND extid_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "PRSNL_ALIAS", oapr
      .alias_entity_alias_type_cd = extid_type,
      oapr.alias_pool_cd = extid_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing External ID Alias Pool relationship for: ",request->org[x]
      .org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (healthplan_type > 0.0
    AND healthplan_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "ORGANIZATION_ALIAS", oapr
      .alias_entity_alias_type_cd = healthplan_type,
      oapr.alias_pool_cd = healthplan_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing Health Plan Alias Pool relationship for: ",request->org[x]
      .org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (inscod_type > 0.0
    AND inscod_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "ORGANIZATION_ALIAS", oapr
      .alias_entity_alias_type_cd = inscod_type,
      oapr.alias_pool_cd = inscod_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing Insurance Code Alias Pool relationship for: ",request->
      org[x].org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (ssn_type > 0.0
    AND ssn_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "PERSON_ALIAS", oapr
      .alias_entity_alias_type_cd = ssn_type,
      oapr.alias_pool_cd = ssn_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing SSN Alias Pool relationship for: ",request->org[x].
      org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (upin_type > 0.0
    AND upin_pool > 0.0)
    INSERT  FROM org_alias_pool_reltn oapr
     SET oapr.organization_id = org_id, oapr.alias_entity_name = "PRSNL_ALIAS", oapr
      .alias_entity_alias_type_cd = upin_type,
      oapr.alias_pool_cd = upin_pool, oapr.updt_id = reqinfo->updt_id, oapr.updt_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.updt_task = reqinfo->updt_task, oapr.updt_cnt = 0, oapr.updt_applctx = reqinfo->
      updt_applctx,
      oapr.active_ind = 1, oapr.active_status_cd = active_cd, oapr.active_status_dt_tm = cnvtdatetime
      (curdate,curtime3),
      oapr.active_status_prsnl_id = reqinfo->updt_id, oapr.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), oapr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      oapr.auto_assign_flag = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error writing UPIN Alias Pool relationship for: ",request->org[x].
      org_name,".")
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_org_alias(x,y)
   SET ierrcode = 0
   INSERT  FROM organization_alias o
    SET o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = org_id, o
     .alias_pool_cd = request->org[x].org_alias[y].alias_pool_code_value,
     o.alias = request->org[x].org_alias[y].alias, o.alias_key = cnvtupper(request->org[x].org_alias[
      y].alias), o.org_alias_type_cd = request->org[x].org_alias[y].org_alias_type_code_value,
     o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), o.updt_cnt = 0,
     o.active_ind = 1, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
     o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.active_status_cd =
     active_cd,
     o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o.active_status_prsnl_id = reqinfo->
     updt_id, o.org_alias_sub_type_cd = 0,
     o.check_digit_method_cd = 0, o.data_status_cd = auth_cd, o.data_status_prsnl_id = reqinfo->
     updt_id,
     o.contributor_system_cd = 0
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on org alias insert: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_org_alias(x,y)
   SET ierrcode = 0
   UPDATE  FROM organization_alias o
    SET o.organization_alias_id = request->org[x].org_alias[y].org_alias_id, o.organization_id =
     org_id, o.alias_pool_cd = request->org[x].org_alias[y].alias_pool_code_value,
     o.alias = request->org[x].org_alias[y].alias, o.alias_key = cnvtupper(request->org[x].org_alias[
      y].alias), o.org_alias_type_cd = request->org[x].org_alias[y].org_alias_type_code_value,
     o.active_status_cd = active_cd, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
     .updt_cnt = (o.updt_cnt+ 1),
     o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id, o.updt_task =
     reqinfo->updt_task,
     o.updt_applctx = reqinfo->updt_applctx
    WHERE (o.organization_alias_id=request->org[x].org_alias[y].org_alias_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on org alias update: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE del_org_alias(x,y)
   SET ierrcode = 0
   UPDATE  FROM organization_alias o
    SET o.active_ind = 0, o.active_status_cd = inactive_code_value, o.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     o.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_cnt = (o.updt_cnt+ 1), o
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
     updt_applctx
    WHERE (o.organization_alias_id=request->org[x].org_alias[y].org_alias_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on org alias delete: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_research_account(x,y)
   SET ierrcode = 0
   INSERT  FROM research_account r
    SET r.research_account_id = seq(organization_seq,nextval), r.organization_id = org_id, r.name =
     request->org[x].research_accounts[y].name,
     r.description = request->org[x].research_accounts[y].description, r.account_nbr = request->org[x
     ].research_accounts[y].account_nbr, r.encntr_type_cd = request->org[x].research_accounts[y].
     encounter_type_code_value,
     r.name_key = cnvtupper(cnvtalphanum(request->org[x].research_accounts[y].name)), r
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"),
     r.active_ind = 1, r.active_status_cd = active_cd, r.active_status_prsnl_id = reqinfo->updt_id,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = 0, r.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on research account insert: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_research_account(x,y)
   SET ierrcode = 0
   UPDATE  FROM research_account r
    SET r.organization_id = org_id, r.name = request->org[x].research_accounts[y].name, r.description
      = request->org[x].research_accounts[y].description,
     r.account_nbr = request->org[x].research_accounts[y].account_nbr, r.encntr_type_cd = request->
     org[x].research_accounts[y].encounter_type_code_value, r.name_key = cnvtupper(cnvtalphanum(
       request->org[x].research_accounts[y].name)),
     r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), r.active_ind = 1,
     r.active_status_cd = active_cd, r.active_status_prsnl_id = reqinfo->updt_id, r
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo
     ->updt_id,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task
    PLAN (r
     WHERE (r.research_account_id=request->org[x].research_accounts[y].research_account_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on research account update: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE del_research_account(x,y)
   SET ierrcode = 0
   UPDATE  FROM research_account r
    SET r.active_ind = 0, r.updt_cnt = (r.updt_cnt+ 1), r.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (r
     WHERE (r.research_account_id=request->org[x].research_accounts[y].research_account_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error on research account delete: ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (((error_flag="N") OR (error_flag="Z")) )
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ORG","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 IF ((request->audit_mode_ind=1))
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echo(build(error_msg))
 CALL echorecord(reply)
END GO
