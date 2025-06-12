CREATE PROGRAM bed_ens_ccn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ccn[*]
      2 id = f8
      2 address_id = f8
      2 phone_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE SET ccn_url_reltn_delete
 RECORD ccn_url_reltn_delete(
   1 reltn[*]
     2 ccn_id = f8
     2 br_portal_url_id = f8
     2 br_portal_url_svc_entity_r_id = f8
 )
 FREE RECORD copyextension
 RECORD copyextension(
   1 br_ccn_extension_id = f8
   1 orig_br_ccn_extension_id = f8
   1 br_ccn_id = f8
   1 program_type_txt = vc
   1 medicaid_stage_cd = f8
   1 medicare_year = i4
   1 beg_effective_dt_tm = dq8
 ) WITH protect
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE code_value_table_name = vc WITH protect, constant("CODE_VALUE")
 DECLARE invitation_provided_code_type = i4 WITH protect, constant(1)
 DECLARE patient_declined_code_type = i4 WITH protect, constant(2)
 DECLARE updatingeffectiverow = i2 WITH protect, noconstant(0)
 DECLARE createportalreltnattribute(reltnid=f8,eventcd=f8,type=i2) = f8
 SUBROUTINE createportalreltnattribute(reltnid,eventcd,type)
   SET updatingeffectiverow = 0
   FREE RECORD url_reltn_attr
   RECORD url_reltn_attr(
     1 br_prtl_url_se_r_cd_r_id = f8
     1 br_portal_url_svc_entity_r_id = f8
     1 portal_attr_cd_value = f8
     1 code_type_flag = i4
     1 beg_effective_dt_tm = f8
     1 active_ind = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_prtl_url_se_r_cd_r prtl_r
    PLAN (prtl_r
     WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
      AND prtl_r.code_type_flag=type
      AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (prtl_r.active_ind=0)
      IF (eventcd > 0.0)
       updatingeffectiverow = 1
      ENDIF
     ELSE
      IF (prtl_r.portal_attr_cd_value != eventcd)
       updatingeffectiverow = 1
      ENDIF
     ENDIF
     IF (updatingeffectiverow=1)
      url_reltn_attr->br_prtl_url_se_r_cd_r_id = prtl_r.br_prtl_url_se_r_cd_r_id, url_reltn_attr->
      br_portal_url_svc_entity_r_id = prtl_r.br_portal_url_svc_entity_r_id, url_reltn_attr->
      portal_attr_cd_value = prtl_r.portal_attr_cd_value,
      url_reltn_attr->code_type_flag = prtl_r.code_type_flag, url_reltn_attr->beg_effective_dt_tm =
      prtl_r.beg_effective_dt_tm, url_reltn_attr->active_ind = prtl_r.active_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get existing effective row")
   IF (updatingeffectiverow=1)
    SET newid = 0.0
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      newid = cnvtreal(j)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to get new relation attribute id")
    INSERT  FROM br_prtl_url_se_r_cd_r prtl_r
     SET prtl_r.br_prtl_url_se_r_cd_r_id = newid, prtl_r.orig_prtl_url_se_r_cd_r_id = url_reltn_attr
      ->br_prtl_url_se_r_cd_r_id, prtl_r.br_portal_url_svc_entity_r_id = url_reltn_attr->
      br_portal_url_svc_entity_r_id,
      prtl_r.portal_attr_cd_value = url_reltn_attr->portal_attr_cd_value, prtl_r.code_type_flag =
      url_reltn_attr->code_type_flag, prtl_r.active_ind = url_reltn_attr->active_ind,
      prtl_r.beg_effective_dt_tm = cnvtdatetime(url_reltn_attr->beg_effective_dt_tm), prtl_r
      .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r.updt_id = reqinfo->updt_id,
      prtl_r.updt_cnt = 0, prtl_r.updt_applctx = reqinfo->updt_applctx, prtl_r.updt_task = reqinfo->
      updt_task,
      prtl_r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert history of prtl attribute.")
    IF (eventcd > 0)
     UPDATE  FROM br_prtl_url_se_r_cd_r prtl_r
      SET prtl_r.active_ind = 1, prtl_r.portal_attr_cd_value = eventcd, prtl_r.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       prtl_r.updt_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r.updt_id = reqinfo->updt_id, prtl_r
       .updt_task = reqinfo->updt_task,
       prtl_r.updt_cnt = (prtl_r.updt_cnt+ 1), prtl_r.updt_applctx = reqinfo->updt_applctx
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to update existing row.")
    ELSE
     UPDATE  FROM br_prtl_url_se_r_cd_r prtl_r
      SET prtl_r.active_ind = 0, prtl_r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       prtl_r.updt_id = reqinfo->updt_id, prtl_r.updt_task = reqinfo->updt_task, prtl_r.updt_cnt = (
       prtl_r.updt_cnt+ 1),
       prtl_r.updt_applctx = reqinfo->updt_applctx
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate row.")
    ENDIF
   ELSEIF (eventcd > 0.0)
    SELECT INTO "nl:"
     FROM br_prtl_url_se_r_cd_r prtl_r
     PLAN (prtl_r
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.portal_attr_cd_value=eventcd
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to find end-effective row.")
    IF (curqual=0)
     SET newid = 0.0
     SELECT INTO "nl:"
      j = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       newid = cnvtreal(j)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Failed to get new relation attribute id")
     INSERT  FROM br_prtl_url_se_r_cd_r prtl_attr
      SET prtl_attr.br_prtl_url_se_r_cd_r_id = newid, prtl_attr.orig_prtl_url_se_r_cd_r_id = newid,
       prtl_attr.br_portal_url_svc_entity_r_id = reltnid,
       prtl_attr.portal_attr_cd_value = eventcd, prtl_attr.code_type_flag = type, prtl_attr
       .active_ind = 1,
       prtl_attr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_attr.end_effective_dt_tm
        = cnvtdatetime("31-DEC-2100"), prtl_attr.updt_id = reqinfo->updt_id,
       prtl_attr.updt_cnt = 0, prtl_attr.updt_applctx = reqinfo->updt_applctx, prtl_attr.updt_task =
       reqinfo->updt_task,
       prtl_attr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Failed to insert url reltn attribute")
     RETURN(newid)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
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
 SET bus_addr_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=212
   AND cv.cdf_meaning="BUSINESS"
   AND cv.active_ind=1
  DETAIL
   bus_addr_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("BUSINESSSEL1")
 SET bus_phone_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=43
   AND cv.cdf_meaning="BUSINESS"
   AND cv.active_ind=1
  DETAIL
   bus_phone_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("BUSINESSSEL2")
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("ACTIVESEL1")
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("AUTHSEL1")
 DECLARE ccn_number_string = vc
 SET ccnt = size(request->ccn,5)
 SET stat = alterlist(reply->ccn,ccnt)
 FOR (c = 1 TO ccnt)
   SET ccn_number_string = ""
   IF (validate(request->ccn[c].number_string))
    SET ccn_number_string = request->ccn[c].number_string
   ENDIF
   IF ((request->ccn[c].action_flag=1))
    SET br_ccn_id = 0.0
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_ccn_id = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck("IDSEL1")
    SET reply->ccn[c].id = br_ccn_id
    IF (data_partition_ind=1)
     INSERT  FROM br_ccn b
      SET b.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, b.br_ccn_id =
       br_ccn_id, b.ccn_nbr = request->ccn[c].number,
       b.ccn_nbr_txt = ccn_number_string, b.ccn_name = request->ccn[c].name, b.tax_id_nbr_txt =
       request->ccn[c].tax_id,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.active_ind = 1,
       b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00"), b.orig_br_ccn_id = br_ccn_id
      WITH nocounter
     ;end insert
     CALL bederrorcheck("CCNINSERT1")
    ELSE
     INSERT  FROM br_ccn b
      SET b.br_ccn_id = br_ccn_id, b.ccn_nbr = request->ccn[c].number, b.ccn_nbr_txt =
       ccn_number_string,
       b.ccn_name = request->ccn[c].name, b.tax_id_nbr_txt = request->ccn[c].tax_id, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx,
       b.updt_cnt = 0, b.active_ind = 1, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), b.orig_br_ccn_id = br_ccn_id
      WITH nocounter
     ;end insert
     CALL bederrorcheck("CCNINSERT2")
    ENDIF
    IF ((request->ccn[c].address.action_flag=1))
     SET address_id = 0.0
     SELECT INTO "nl:"
      z = seq(address_seq,nextval)
      FROM dual
      DETAIL
       address_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("IDSEL2")
     SET reply->ccn[c].address_id = address_id
     INSERT  FROM address a
      SET a.address_id = address_id, a.parent_entity_name = "BR_CCN", a.parent_entity_id = br_ccn_id,
       a.address_type_cd = bus_addr_type_cd, a.street_addr = request->ccn[c].address.street_addr1, a
       .street_addr2 = request->ccn[c].address.street_addr2,
       a.street_addr3 = request->ccn[c].address.street_addr3, a.street_addr4 = request->ccn[c].
       address.street_addr4, a.city = request->ccn[c].address.city,
       a.state_cd = request->ccn[c].address.state_code_value, a.zipcode = request->ccn[c].address.
       zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->ccn[c].address.zipcode)),
       a.county_cd = request->ccn[c].address.county_code_value, a.country_cd = request->ccn[c].
       address.country_code_value, a.contact_name = request->ccn[c].address.contact_name,
       a.comment_txt = request->ccn[c].address.comment_txt, a.active_ind = 1, a.active_status_cd =
       active_cd,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.data_status_cd = auth_cd, a
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ADDRESSINSERT1")
    ENDIF
    IF ((request->ccn[c].phone.action_flag=1))
     SET phone_id = 0.0
     SELECT INTO "nl:"
      z = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       phone_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("IDSEL3")
     SET reply->ccn[c].phone_id = phone_id
     INSERT  FROM phone p
      SET p.phone_id = phone_id, p.parent_entity_name = "BR_CCN", p.parent_entity_id = br_ccn_id,
       p.phone_type_cd = bus_phone_type_cd, p.phone_format_cd = request->ccn[c].phone.
       phone_format_code_value, p.phone_num = trim(request->ccn[c].phone.phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->ccn[c].phone.phone_num))), p.contact =
       trim(request->ccn[c].phone.contact), p.call_instruction = trim(request->ccn[c].phone.
        call_instruction),
       p.extension = trim(request->ccn[c].phone.extension), p.updt_id = reqinfo->updt_id, p.updt_cnt
        = 0,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     CALL bederrorcheck("PHONEINSERT1")
    ENDIF
   ELSEIF ((request->ccn[c].action_flag=2))
    SET reply->ccn[c].id = request->ccn[c].id
    UPDATE  FROM br_ccn b
     SET b.ccn_nbr = request->ccn[c].number, b.ccn_nbr_txt = ccn_number_string, b.ccn_name = request
      ->ccn[c].name,
      b.tax_id_nbr_txt = request->ccn[c].tax_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
      .updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
      .updt_cnt+ 1)
     WHERE (b.br_ccn_id=request->ccn[c].id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("CCNUPDATE1")
    IF ((request->ccn[c].address.action_flag=2))
     SET reply->ccn[c].address_id = request->ccn[c].address.address_id
     UPDATE  FROM address a
      SET a.street_addr = request->ccn[c].address.street_addr1, a.street_addr2 = request->ccn[c].
       address.street_addr2, a.street_addr3 = request->ccn[c].address.street_addr3,
       a.street_addr4 = request->ccn[c].address.street_addr4, a.city = request->ccn[c].address.city,
       a.state_cd = request->ccn[c].address.state_code_value,
       a.zipcode = request->ccn[c].address.zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->
         ccn[c].address.zipcode)), a.county_cd = request->ccn[c].address.county_code_value,
       a.country_cd = request->ccn[c].address.country_code_value, a.contact_name = request->ccn[c].
       address.contact_name, a.comment_txt = request->ccn[c].address.comment_txt,
       a.updt_id = reqinfo->updt_id, a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = reqinfo->
       updt_applctx,
       a.updt_task = reqinfo->updt_task, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (a.address_id=request->ccn[c].address.address_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("ADDRESSUPDATE1")
    ELSEIF ((request->ccn[c].address.action_flag=1))
     SET address_id = 0.0
     SELECT INTO "nl:"
      z = seq(address_seq,nextval)
      FROM dual
      DETAIL
       address_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("IDSEL4")
     SET reply->ccn[c].address_id = address_id
     INSERT  FROM address a
      SET a.address_id = address_id, a.parent_entity_name = "BR_CCN", a.parent_entity_id = request->
       ccn[c].id,
       a.address_type_cd = bus_addr_type_cd, a.street_addr = request->ccn[c].address.street_addr1, a
       .street_addr2 = request->ccn[c].address.street_addr2,
       a.street_addr3 = request->ccn[c].address.street_addr3, a.street_addr4 = request->ccn[c].
       address.street_addr4, a.city = request->ccn[c].address.city,
       a.state_cd = request->ccn[c].address.state_code_value, a.zipcode = request->ccn[c].address.
       zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->ccn[c].address.zipcode)),
       a.county_cd = request->ccn[c].address.county_code_value, a.country_cd = request->ccn[c].
       address.country_code_value, a.contact_name = request->ccn[c].address.contact_name,
       a.comment_txt = request->ccn[c].address.comment_txt, a.active_ind = 1, a.active_status_cd =
       active_cd,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.data_status_cd = auth_cd, a
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("ADDRESSINSERT2")
    ENDIF
    IF ((request->ccn[c].phone.action_flag=2))
     SET reply->ccn[c].phone_id = request->ccn[c].phone.phone_id
     UPDATE  FROM phone p
      SET p.phone_format_cd = request->ccn[c].phone.phone_format_code_value, p.phone_num = trim(
        request->ccn[c].phone.phone_num), p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->ccn[
          c].phone.phone_num))),
       p.contact = trim(request->ccn[c].phone.contact), p.call_instruction = trim(request->ccn[c].
        phone.call_instruction), p.extension = trim(request->ccn[c].phone.extension),
       p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
       updt_applctx,
       p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (p.phone_id=request->ccn[c].phone.phone_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("PHONEUPDATE1")
    ELSEIF ((request->ccn[c].phone.action_flag=1))
     SET phone_id = 0.0
     SELECT INTO "nl:"
      z = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       phone_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("IDSEL5")
     SET reply->ccn[c].phone_id = phone_id
     INSERT  FROM phone p
      SET p.phone_id = phone_id, p.parent_entity_name = "BR_CCN", p.parent_entity_id = request->ccn[c
       ].id,
       p.phone_type_cd = bus_phone_type_cd, p.phone_format_cd = request->ccn[c].phone.
       phone_format_code_value, p.phone_num = trim(request->ccn[c].phone.phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->ccn[c].phone.phone_num))), p.contact =
       trim(request->ccn[c].phone.contact), p.call_instruction = trim(request->ccn[c].phone.
        call_instruction),
       p.extension = trim(request->ccn[c].phone.extension), p.updt_id = reqinfo->updt_id, p.updt_cnt
        = 0,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     CALL bederrorcheck("PHONEINSERT2")
    ENDIF
   ELSEIF ((request->ccn[c].action_flag=3))
    SET reply->ccn[c].id = request->ccn[c].id
    DELETE  FROM address a
     WHERE (a.parent_entity_id=request->ccn[c].id)
      AND a.parent_entity_name="BR_CCN"
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL2")
    DELETE  FROM phone p
     WHERE (p.parent_entity_id=request->ccn[c].id)
      AND p.parent_entity_name="BR_CCN"
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL3")
    SELECT INTO "nl:"
     FROM br_ccn_loc_ptsvc_reltn b
     WHERE (b.br_ccn_loc_reltn_id=
     (SELECT
      b1.br_ccn_loc_reltn_id
      FROM br_ccn_loc_reltn b1
      WHERE (b1.br_ccn_id=request->ccn[c].id)))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_ccn_loc_ptsvc_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_CCN_LOC_PTSVC_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELHISTERROR1")
    DELETE  FROM br_ccn_loc_ptsvc_reltn b
     WHERE (b.br_ccn_loc_reltn_id=
     (SELECT
      b1.br_ccn_loc_reltn_id
      FROM br_ccn_loc_reltn b1
      WHERE (b1.br_ccn_id=request->ccn[c].id)))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL4")
    SELECT INTO "nl:"
     FROM br_ccn_loc_reltn b
     WHERE (b.br_ccn_id=request->ccn[c].id)
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_ccn_loc_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_CCN_LOC_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELHISTERROR2")
    DELETE  FROM br_ccn_loc_reltn b
     WHERE (b.br_ccn_id=request->ccn[c].id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL5")
    SELECT INTO "nl:"
     FROM lh_cqm_meas_svc_entity_r cqm
     WHERE (cqm.parent_entity_id=request->ccn[c].id)
      AND cqm.parent_entity_name="BR_CCN"
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = cqm.lh_cqm_meas_svc_entity_r_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "LH_CQM_MEAS_SVC_ENTITY_R"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELHISTERROR3")
    DELETE  FROM lh_cqm_meas_svc_entity_r cqm
     WHERE (cqm.parent_entity_id=request->ccn[c].id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL6")
    UPDATE  FROM br_svc_entity_report_reltn svc
     SET svc.active_ind = 0, svc.updt_dt_tm = cnvtdatetime(curdate,curtime3), svc.updt_id = reqinfo->
      updt_id,
      svc.updt_task = reqinfo->updt_task, svc.updt_cnt = (svc.updt_cnt+ 1), svc.updt_applctx =
      reqinfo->updt_applctx
     WHERE (svc.parent_entity_id=request->ccn[c].id)
      AND svc.parent_entity_name="BR_CCN"
     WITH nocounter
    ;end update
    CALL bederrorcheck("DELETEFUNCTMEASURES")
    SET current_reltn_list_size = 0
    SELECT INTO "nl:"
     FROM br_portal_url_svc_entity_r bpuser
     WHERE bpuser.parent_entity_name="BR_CCN"
      AND (bpuser.parent_entity_id=request->ccn[c].id)
      AND bpuser.active_ind=1
     DETAIL
      current_reltn_list_size = (current_reltn_list_size+ 1), stat = alterlist(ccn_url_reltn_delete->
       reltn,current_reltn_list_size), ccn_url_reltn_delete->reltn[current_reltn_list_size].ccn_id =
      request->ccn[c].id,
      ccn_url_reltn_delete->reltn[current_reltn_list_size].br_portal_url_id = bpuser.br_portal_url_id,
      ccn_url_reltn_delete->reltn[current_reltn_list_size].br_portal_url_svc_entity_r_id = bpuser
      .br_portal_url_svc_entity_r_id
     WITH nocounter
    ;end select
    FOR (x = 1 TO current_reltn_list_size)
      CALL createportalreltnattribute(ccn_url_reltn_delete->reltn[x].br_portal_url_svc_entity_r_id,
       0.0,invitation_provided_code_type)
      CALL createportalreltnattribute(ccn_url_reltn_delete->reltn[x].br_portal_url_svc_entity_r_id,
       0.0,patient_declined_code_type)
      UPDATE  FROM br_portal_url_svc_entity_r bpuser
       SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
        bpuser.updt_cnt+ 1),
        bpuser.updt_applctx = reqinfo->updt_applctx
       WHERE (bpuser.br_portal_url_svc_entity_r_id=ccn_url_reltn_delete->reltn[x].
       br_portal_url_svc_entity_r_id)
      ;end update
      CALL bederrorcheck("UPDT_BR_PORTAL1")
      SET br_portal_relations_exist = 0
      SELECT INTO "nl:"
       FROM br_portal_url_svc_entity_r bpuser
       WHERE bpuser.active_ind=1
        AND (bpuser.br_portal_url_id=ccn_url_reltn_delete->reltn[x].br_portal_url_id)
        AND bpuser.parent_entity_name != code_value_table_name
       DETAIL
        br_portal_relations_exist = 1
       WITH nocounter
      ;end select
      IF (br_portal_relations_exist=0)
       UPDATE  FROM br_portal_url bpu
        SET bpu.active_ind = 0, bpu.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpu
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         bpu.updt_id = reqinfo->updt_id, bpu.updt_task = reqinfo->updt_task, bpu.updt_cnt = (bpu
         .updt_cnt+ 1),
         bpu.updt_applctx = reqinfo->updt_applctx
        WHERE (bpu.br_portal_url_id=ccn_url_reltn_delete->reltn[x].br_portal_url_id)
       ;end update
       CALL bederrorcheck("UPDT_BR_PORTAL2")
      ENDIF
    ENDFOR
    UPDATE  FROM br_prsnl_ccn_reltn bpcr
     SET bpcr.active_ind = 0, bpcr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpcr
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bpcr.updt_id = reqinfo->updt_id, bpcr.updt_task = reqinfo->updt_task, bpcr.updt_cnt = (bpcr
      .updt_cnt+ 1),
      bpcr.updt_applctx = reqinfo->updt_applctx
     WHERE (bpcr.br_ccn_id=request->ccn[c].id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("UPDT_PRSNL_CCN_RELTN1")
    SELECT INTO "nl:"
     FROM br_ccn_extension bce
     WHERE (bce.br_ccn_id=request->ccn[c].id)
      AND bce.active_ind=1
      AND bce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      copyextension->br_ccn_extension_id = bce.br_ccn_extension_id, copyextension->
      orig_br_ccn_extension_id = bce.orig_br_ccn_extension_id, copyextension->br_ccn_id = bce
      .br_ccn_id,
      copyextension->program_type_txt = bce.program_type_txt, copyextension->medicaid_stage_cd = bce
      .medicaid_stage_cd, copyextension->medicare_year = bce.medicare_year,
      copyextension->beg_effective_dt_tm = bce.beg_effective_dt_tm
     WITH nocounter
    ;end select
    CALL bederrorcheck("CCNExtHistErr1")
    IF (curqual > 0)
     DECLARE new_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       new_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("CCNExtHistErr2")
     INSERT  FROM br_ccn_extension bce
      SET bce.br_ccn_extension_id = new_id, bce.orig_br_ccn_extension_id = copyextension->
       orig_br_ccn_extension_id, bce.br_ccn_id = copyextension->br_ccn_id,
       bce.program_type_txt = copyextension->program_type_txt, bce.medicaid_stage_cd = copyextension
       ->medicaid_stage_cd, bce.medicare_year = copyextension->medicare_year,
       bce.beg_effective_dt_tm = cnvtdatetime(copyextension->beg_effective_dt_tm), bce
       .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bce.active_ind = 1,
       bce.updt_dt_tm = cnvtdatetime(curdate,curtime3), bce.updt_id = reqinfo->updt_id, bce.updt_task
        = reqinfo->updt_task,
       bce.updt_applctx = reqinfo->updt_applctx, bce.updt_cnt = 0
      WITH nocounter
     ;end insert
     CALL bederrorcheck("CCNExtHistErr3")
     UPDATE  FROM br_ccn_extension bce
      SET bce.active_ind = 0, bce.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bce
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bce.updt_id = reqinfo->updt_id, bce.updt_task = reqinfo->updt_task, bce.updt_applctx = reqinfo
       ->updt_applctx,
       bce.updt_cnt = (bce.updt_cnt+ 1)
      WHERE (bce.br_ccn_extension_id=copyextension->br_ccn_extension_id)
     ;end update
     CALL bederrorcheck("CCNExtHistErr4")
    ENDIF
    SELECT INTO "nl:"
     FROM br_ccn b
     WHERE (b.br_ccn_id=request->ccn[c].id)
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_ccn_id, delete_hist->deleted_item[delete_hist_cnt].parent_entity_name
       = "BR_CCN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("DELHISTERROR4")
    DELETE  FROM br_ccn b
     WHERE (b.br_ccn_id=request->ccn[c].id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DEL1")
   ENDIF
 ENDFOR
 IF (delete_hist_cnt > 0)
  INSERT  FROM br_delete_hist his,
    (dummyt d  WITH seq = delete_hist_cnt)
   SET his.br_delete_hist_id = seq(bedrock_seq,nextval), his.parent_entity_name = delete_hist->
    deleted_item[d.seq].parent_entity_name, his.parent_entity_id = delete_hist->deleted_item[d.seq].
    parent_entity_id,
    his.updt_dt_tm = cnvtdatetime(curdate,curtime3), his.updt_id = reqinfo->updt_id, his.updt_task =
    reqinfo->updt_task,
    his.updt_cnt = 0, his.updt_applctx = reqinfo->updt_applctx, his.create_dt_tm = cnvtdatetime(
     curdate,curtime3)
   PLAN (d)
    JOIN (his)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("DELHISTINSERTFAILED1")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
