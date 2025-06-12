CREATE PROGRAM bed_ens_eligible_providers:dba
 FREE SET reply
 RECORD reply(
   1 providers[*]
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
 FREE SET eligible_provider_url_reltn_delete
 RECORD eligible_provider_url_reltn_delete(
   1 reltn[*]
     2 eligible_provider_id = f8
     2 br_portal_url_id = f8
     2 br_portal_url_svc_entity_r_id = f8
 )
 FREE RECORD copyextension
 RECORD copyextension(
   1 br_elig_prov_extension_id = f8
   1 orig_br_elig_prov_extension_id = f8
   1 br_eligible_provider_id = f8
   1 program_type_txt = vc
   1 medicaid_stage_cd = f8
   1 medicare_year = i4
   1 beg_effective_dt_tm = dq8
 ) WITH protect
 FREE SET delete_hist
 RECORD delete_hist(
   1 deleted_item[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
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
 DECLARE delete_hist_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
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
 CALL bederrorcheck("GETBUSINESS1")
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
 CALL bederrorcheck("GETBUSINESS")
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
 CALL bederrorcheck("GETACTIVE")
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
 CALL bederrorcheck("GETAUTH")
 SET pcnt = size(request->providers,5)
 SET stat = alterlist(reply->providers,pcnt)
 FOR (p = 1 TO pcnt)
   IF ((request->providers[p].action_flag=1))
    SET br_eligible_provider_id = 0.0
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_eligible_provider_id = cnvtreal(z)
     WITH nocounter
    ;end select
    CALL bederrorcheck("GETID")
    SET reply->providers[p].id = br_eligible_provider_id
    IF (data_partition_ind=1)
     INSERT  FROM br_eligible_provider b
      SET b.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, b
       .br_eligible_provider_id = br_eligible_provider_id, b.provider_id = request->providers[p].
       person_id,
       b.national_provider_nbr_txt = request->providers[p].national_provider_nbr, b.tax_id_nbr_txt =
       request->providers[p].tax_id, b.specialty_id = request->providers[p].specialty_id,
       b.health_plan_txt = request->providers[p].health_plan, b.health_plan_txt_dt_tm = cnvtdatetime(
        curdate,curtime3), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx,
       b.updt_cnt = 0, b.orig_br_eligible_provider_id = br_eligible_provider_id, b.active_ind = 1,
       b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), b.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00")
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTEP2")
    ELSE
     INSERT  FROM br_eligible_provider b
      SET b.br_eligible_provider_id = br_eligible_provider_id, b.provider_id = request->providers[p].
       person_id, b.national_provider_nbr_txt = request->providers[p].national_provider_nbr,
       b.tax_id_nbr_txt = request->providers[p].tax_id, b.specialty_id = request->providers[p].
       specialty_id, b.health_plan_txt = request->providers[p].health_plan,
       b.health_plan_txt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0,
       b.orig_br_eligible_provider_id = br_eligible_provider_id, b.active_ind = 1, b
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTEP1")
    ENDIF
    IF ((request->providers[p].address.action_flag=1))
     SET address_id = 0.0
     SELECT INTO "nl:"
      z = seq(address_seq,nextval)
      FROM dual
      DETAIL
       address_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("GEDID")
     SET reply->providers[p].address_id = address_id
     INSERT  FROM address a
      SET a.address_id = address_id, a.parent_entity_name = "BR_ELIGIBLE_PROVIDER", a
       .parent_entity_id = br_eligible_provider_id,
       a.address_type_cd = bus_addr_type_cd, a.street_addr = request->providers[p].address.
       street_addr1, a.street_addr2 = request->providers[p].address.street_addr2,
       a.street_addr3 = request->providers[p].address.street_addr3, a.street_addr4 = request->
       providers[p].address.street_addr4, a.city = request->providers[p].address.city,
       a.state_cd = request->providers[p].address.state_code_value, a.zipcode = request->providers[p]
       .address.zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->providers[p].address.zipcode
         )),
       a.county_cd = request->providers[p].address.county_code_value, a.country_cd = request->
       providers[p].address.country_code_value, a.contact_name = request->providers[p].address.
       contact_name,
       a.comment_txt = request->providers[p].address.comment_txt, a.active_ind = 1, a
       .active_status_cd = active_cd,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.data_status_cd = auth_cd, a
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTADDRESS1")
    ENDIF
    IF ((request->providers[p].phone.action_flag=1))
     SET phone_id = 0.0
     SELECT INTO "nl:"
      z = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       phone_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("GETID")
     SET reply->providers[p].phone_id = phone_id
     INSERT  FROM phone p
      SET p.phone_id = phone_id, p.parent_entity_name = "BR_ELIGIBLE_PROVIDER", p.parent_entity_id =
       br_eligible_provider_id,
       p.phone_type_cd = bus_phone_type_cd, p.phone_format_cd = request->providers[p].phone.
       phone_format_code_value, p.phone_num = trim(request->providers[p].phone.phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->providers[p].phone.phone_num))), p
       .contact = trim(request->providers[p].phone.contact), p.call_instruction = trim(request->
        providers[p].phone.call_instruction),
       p.extension = trim(request->providers[p].phone.extension), p.updt_id = reqinfo->updt_id, p
       .updt_cnt = 0,
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
     CALL bederrorcheck("INSERTPHONE1")
    ENDIF
    SET qcnt = size(request->providers[p].quality_measures,5)
    IF (qcnt > 0)
     SET br_elig_prov_meas_reltn_id = 0.0
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       br_elig_prov_meas_reltn_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("GETID2")
     INSERT  FROM br_elig_prov_meas_reltn b,
       (dummyt d  WITH seq = qcnt)
      SET b.br_elig_prov_meas_reltn_id = br_elig_prov_meas_reltn_id, b.br_eligible_provider_id =
       br_eligible_provider_id, b.pca_quality_measure_id = request->providers[p].quality_measures[d
       .seq].id,
       b.measure_seq = request->providers[p].quality_measures[d.seq].sequence, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0,
       b.orig_br_elig_prov_meas_r_id = br_elig_prov_meas_reltn_id, b.active_ind = 1, b
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      PLAN (d)
       JOIN (b)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTEP")
    ENDIF
   ELSEIF ((request->providers[p].action_flag=2))
    SET reply->providers[p].id = request->providers[p].id
    SET health_plan_changed_ind = 0
    SELECT INTO "nl:"
     FROM br_eligible_provider b
     WHERE (b.br_eligible_provider_id=request->providers[p].id)
      AND b.active_ind=1
      AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      IF (trim(b.health_plan_txt) != trim(request->providers[p].health_plan))
       health_plan_changed_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("EPSELECT")
    IF (health_plan_changed_ind=1)
     UPDATE  FROM br_eligible_provider b
      SET b.provider_id = request->providers[p].person_id, b.national_provider_nbr_txt = request->
       providers[p].national_provider_nbr, b.tax_id_nbr_txt = request->providers[p].tax_id,
       b.specialty_id = request->providers[p].specialty_id, b.health_plan_txt = request->providers[p]
       .health_plan, b.health_plan_txt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1)
      WHERE (b.br_eligible_provider_id=request->providers[p].id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("UPDATEEP1")
    ELSE
     UPDATE  FROM br_eligible_provider b
      SET b.provider_id = request->providers[p].person_id, b.national_provider_nbr_txt = request->
       providers[p].national_provider_nbr, b.tax_id_nbr_txt = request->providers[p].tax_id,
       b.specialty_id = request->providers[p].specialty_id, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
       .updt_cnt+ 1)
      WHERE (b.br_eligible_provider_id=request->providers[p].id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("UPDATEEP2")
    ENDIF
    IF ((request->providers[p].address.action_flag=2))
     SET reply->providers[p].address_id = request->providers[p].address.address_id
     UPDATE  FROM address a
      SET a.street_addr = request->providers[p].address.street_addr1, a.street_addr2 = request->
       providers[p].address.street_addr2, a.street_addr3 = request->providers[p].address.street_addr3,
       a.street_addr4 = request->providers[p].address.street_addr4, a.city = request->providers[p].
       address.city, a.state_cd = request->providers[p].address.state_code_value,
       a.zipcode = request->providers[p].address.zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(
         request->providers[p].address.zipcode)), a.county_cd = request->providers[p].address.
       county_code_value,
       a.country_cd = request->providers[p].address.country_code_value, a.contact_name = request->
       providers[p].address.contact_name, a.comment_txt = request->providers[p].address.comment_txt,
       a.updt_id = reqinfo->updt_id, a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = reqinfo->
       updt_applctx,
       a.updt_task = reqinfo->updt_task, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (a.address_id=request->providers[p].address.address_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("UPDATEADDRESS")
    ELSEIF ((request->providers[p].address.action_flag=1))
     SET address_id = 0.0
     SELECT INTO "nl:"
      z = seq(address_seq,nextval)
      FROM dual
      DETAIL
       address_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("GETID")
     SET reply->providers[p].address_id = address_id
     INSERT  FROM address a
      SET a.address_id = address_id, a.parent_entity_name = "BR_ELIGIBLE_PROVIDER", a
       .parent_entity_id = request->providers[p].id,
       a.address_type_cd = bus_addr_type_cd, a.street_addr = request->providers[p].address.
       street_addr1, a.street_addr2 = request->providers[p].address.street_addr2,
       a.street_addr3 = request->providers[p].address.street_addr3, a.street_addr4 = request->
       providers[p].address.street_addr4, a.city = request->providers[p].address.city,
       a.state_cd = request->providers[p].address.state_code_value, a.zipcode = request->providers[p]
       .address.zipcode, a.zipcode_key = cnvtupper(cnvtalphanum(request->providers[p].address.zipcode
         )),
       a.county_cd = request->providers[p].address.county_code_value, a.country_cd = request->
       providers[p].address.country_code_value, a.contact_name = request->providers[p].address.
       contact_name,
       a.comment_txt = request->providers[p].address.comment_txt, a.active_ind = 1, a
       .active_status_cd = active_cd,
       a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
       updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.data_status_cd = auth_cd, a
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       a.data_status_prsnl_id = reqinfo->updt_id, a.updt_id = reqinfo->updt_id, a.updt_cnt = 0,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTADDRESS")
    ENDIF
    IF ((request->providers[p].phone.action_flag=2))
     SET reply->providers[p].phone_id = request->providers[p].phone.phone_id
     UPDATE  FROM phone p
      SET p.phone_format_cd = request->providers[p].phone.phone_format_code_value, p.phone_num = trim
       (request->providers[p].phone.phone_num), p.phone_num_key = trim(cnvtupper(cnvtalphanum(request
          ->providers[p].phone.phone_num))),
       p.contact = trim(request->providers[p].phone.contact), p.call_instruction = trim(request->
        providers[p].phone.call_instruction), p.extension = trim(request->providers[p].phone.
        extension),
       p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1), p.updt_applctx = reqinfo->
       updt_applctx,
       p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (p.phone_id=request->providers[p].phone.phone_id)
      WITH nocounter
     ;end update
     CALL bederrorcheck("UPDATEPHONE")
    ELSEIF ((request->providers[p].phone.action_flag=1))
     SET phone_id = 0.0
     SELECT INTO "nl:"
      z = seq(phone_seq,nextval)
      FROM dual
      DETAIL
       phone_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("GETID")
     SET reply->providers[p].phone_id = phone_id
     INSERT  FROM phone p
      SET p.phone_id = phone_id, p.parent_entity_name = "BR_ELIGIBLE_PROVIDER", p.parent_entity_id =
       request->providers[p].id,
       p.phone_type_cd = bus_phone_type_cd, p.phone_format_cd = request->providers[p].phone.
       phone_format_code_value, p.phone_num = trim(request->providers[p].phone.phone_num),
       p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->providers[p].phone.phone_num))), p
       .contact = trim(request->providers[p].phone.contact), p.call_instruction = trim(request->
        providers[p].phone.call_instruction),
       p.extension = trim(request->providers[p].phone.extension), p.updt_id = reqinfo->updt_id, p
       .updt_cnt = 0,
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
     CALL bederrorcheck("INSERTPHONE")
    ENDIF
    SELECT INTO "nl:"
     FROM br_elig_prov_meas_reltn b
     PLAN (b
      WHERE (b.br_eligible_provider_id=request->providers[p].id))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_elig_prov_meas_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_ELIG_PROV_MEAS_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    DELETE  FROM br_elig_prov_meas_reltn b
     PLAN (b
      WHERE (b.br_eligible_provider_id=request->providers[p].id))
     WITH nocounter
    ;end delete
    SET qcnt = size(request->providers[p].quality_measures,5)
    IF (qcnt > 0)
     INSERT  FROM br_elig_prov_meas_reltn b,
       (dummyt d  WITH seq = qcnt)
      SET b.br_elig_prov_meas_reltn_id = seq(bedrock_seq,nextval), b.br_eligible_provider_id =
       request->providers[p].id, b.pca_quality_measure_id = request->providers[p].quality_measures[d
       .seq].id,
       b.measure_seq = request->providers[p].quality_measures[d.seq].sequence, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
      PLAN (d)
       JOIN (b)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("INSERTMEASERROR")
    ENDIF
   ELSEIF ((request->providers[p].action_flag=3))
    SET reply->providers[p].id = request->providers[p].id
    SELECT INTO "nl:"
     FROM br_eligible_provider b
     PLAN (b
      WHERE (b.br_eligible_provider_id=request->providers[p].id)
       AND b.active_ind=1
       AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = b.br_eligible_provider_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_ELIGIBLE_PROVIDER"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    DELETE  FROM address a
     WHERE (a.parent_entity_id=request->providers[p].id)
      AND a.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEADDRESS")
    DELETE  FROM phone p
     WHERE (p.parent_entity_id=request->providers[p].id)
      AND p.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEPHONE")
    DELETE  FROM br_elig_prov_extension e
     WHERE (e.br_eligible_provider_id=request->providers[p].id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEPROVIDEREXTENSION")
    SELECT INTO "nl:"
     FROM br_elig_prov_meas_reltn ep
     PLAN (ep
      WHERE (ep.br_eligible_provider_id=request->providers[p].id))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = ep.br_elig_prov_meas_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_ELIG_PROV_MEAS_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    DELETE  FROM br_elig_prov_meas_reltn ep
     PLAN (ep
      WHERE (ep.br_eligible_provider_id=request->providers[p].id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEMEASURESCQM1")
    SELECT INTO "nl:"
     FROM lh_cqm_meas_svc_entity_r cqm
     PLAN (cqm
      WHERE (cqm.parent_entity_id=request->providers[p].id)
       AND cqm.parent_entity_name="BR_ELIGIBLE_PROVIDER")
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
    DELETE  FROM lh_cqm_meas_svc_entity_r cqm
     PLAN (cqm
      WHERE (cqm.parent_entity_id=request->providers[p].id)
       AND cqm.parent_entity_name="BR_ELIGIBLE_PROVIDER")
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEMEASURESCQM2")
    SELECT INTO "nl:"
     FROM br_pqrs_meas_provider_reltn pqrs
     PLAN (pqrs
      WHERE (pqrs.br_eligible_provider_id=request->providers[p].id))
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = pqrs.br_pqrs_meas_provider_reltn_id, delete_hist->deleted_item[
      delete_hist_cnt].parent_entity_name = "BR_PQRS_MEAS_PROVIDER_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    DELETE  FROM br_pqrs_meas_provider_reltn pqrs
     PLAN (pqrs
      WHERE (pqrs.br_eligible_provider_id=request->providers[p].id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEMEASURESPQRS")
    UPDATE  FROM br_svc_entity_report_reltn svc
     SET svc.active_ind = 0, svc.updt_dt_tm = cnvtdatetime(curdate,curtime3), svc.updt_id = reqinfo->
      updt_id,
      svc.updt_task = reqinfo->updt_task, svc.updt_cnt = (svc.updt_cnt+ 1), svc.updt_applctx =
      reqinfo->updt_applctx
     WHERE (svc.parent_entity_id=request->providers[p].id)
      AND svc.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     WITH nocounter
    ;end update
    CALL bederrorcheck("DELETEFUNCTMEASURES")
    SET current_reltn_list_size = 0
    SELECT INTO "nl:"
     FROM br_portal_url_svc_entity_r bpuser
     WHERE bpuser.parent_entity_name="BR_ELIGIBLE_PROVIDER"
      AND (bpuser.parent_entity_id=request->providers[p].id)
      AND bpuser.active_ind=1
     DETAIL
      stat = alterlist(eligible_provider_url_reltn_delete->reltn,(size(
        eligible_provider_url_reltn_delete->reltn,5)+ 1)), current_reltn_list_size = size(
       eligible_provider_url_reltn_delete->reltn,5), eligible_provider_url_reltn_delete->reltn[
      current_reltn_list_size].eligible_provider_id = request->providers[p].id,
      eligible_provider_url_reltn_delete->reltn[current_reltn_list_size].br_portal_url_id = bpuser
      .br_portal_url_id, eligible_provider_url_reltn_delete->reltn[current_reltn_list_size].
      br_portal_url_svc_entity_r_id = bpuser.br_portal_url_svc_entity_r_id
     WITH nocounter
    ;end select
    FOR (x = 1 TO current_reltn_list_size)
      CALL createportalreltnattribute(eligible_provider_url_reltn_delete->reltn[x].
       br_portal_url_svc_entity_r_id,0.0,invitation_provided_code_type)
      CALL createportalreltnattribute(eligible_provider_url_reltn_delete->reltn[x].
       br_portal_url_svc_entity_r_id,0.0,patient_declined_code_type)
      UPDATE  FROM br_portal_url_svc_entity_r bpuser
       SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
        bpuser.updt_cnt+ 1),
        bpuser.updt_applctx = reqinfo->updt_applctx
       WHERE (bpuser.br_portal_url_svc_entity_r_id=eligible_provider_url_reltn_delete->reltn[x].
       br_portal_url_svc_entity_r_id)
      ;end update
      CALL bederrorcheck("UPDT_BR_PORTAL1")
      SET br_portal_relations_exist = 0
      SELECT INTO "nl:"
       FROM br_portal_url_svc_entity_r bpuser
       WHERE bpuser.active_ind=1
        AND (bpuser.br_portal_url_id=eligible_provider_url_reltn_delete->reltn[x].br_portal_url_id)
        AND bpuser.parent_entity_name != code_value_table_name
       DETAIL
        br_portal_relations_exist = 1
       WITH nocounter
      ;end select
      IF (br_portal_relations_exist=0)
       UPDATE  FROM br_portal_url_svc_entity_r bpuser
        SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         bpuser.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt =
         (bpuser.updt_cnt+ 1),
         bpuser.updt_applctx = reqinfo->updt_applctx
        WHERE (bpuser.br_portal_url_id=eligible_provider_url_reltn_delete->reltn[x].br_portal_url_id)
       ;end update
       CALL bederrorcheck("UPDT_BR_PORTAL2")
       UPDATE  FROM br_portal_url bpu
        SET bpu.active_ind = 0, bpu.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpu
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         bpu.updt_id = reqinfo->updt_id, bpu.updt_task = reqinfo->updt_task, bpu.updt_cnt = (bpu
         .updt_cnt+ 1),
         bpu.updt_applctx = reqinfo->updt_applctx
        WHERE (bpu.br_portal_url_id=eligible_provider_url_reltn_delete->reltn[x].br_portal_url_id)
       ;end update
       CALL bederrorcheck("UPDT_BR_PORTAL2")
      ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM br_group_reltn bgr
     PLAN (bgr
      WHERE (bgr.parent_entity_id=request->providers[p].id)
       AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER")
     HEAD REPORT
      stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10)), cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (cnt > 10)
       cnt = 1, stat = alterlist(delete_hist->deleted_item,(delete_hist_cnt+ 10))
      ENDIF
      delete_hist_cnt = (delete_hist_cnt+ 1), delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_id = bgr.br_group_reltn_id, delete_hist->deleted_item[delete_hist_cnt].
      parent_entity_name = "BR_GROUP_RELTN"
     FOOT REPORT
      stat = alterlist(delete_hist->deleted_item,delete_hist_cnt)
     WITH nocounter
    ;end select
    DELETE  FROM br_group_reltn bgr
     PLAN (bgr
      WHERE (bgr.parent_entity_id=request->providers[p].id)
       AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER")
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEEPGROUPS")
    IF ( NOT (validate(br_gpro_reltn_hist,0)))
     RECORD br_gpro_reltn_hist(
       1 br_gpro_reltn[*]
         2 br_gpro_reltn_id = f8
         2 orig_br_gpro_reltn_id = f8
         2 br_gpro_id = f8
         2 parent_entity_name = vc
         2 parent_entity_id = f8
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 updt_id = f8
         2 updt_task = i4
         2 updt_applctx = f8
         2 updt_dt_tm = dq8
         2 updt_cnt = i4
     ) WITH protect
    ENDIF
    DECLARE gpro_reltn_size = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM br_gpro_reltn bgr
     WHERE bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
      AND (bgr.parent_entity_id=request->providers[p].id)
      AND bgr.active_ind=1
      AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      gpro_reltn_size = (gpro_reltn_size+ 1), stat = alterlist(br_gpro_reltn_hist->br_gpro_reltn,
       gpro_reltn_size), br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].br_gpro_reltn_id = bgr
      .br_gpro_reltn_id,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].br_gpro_id = bgr.br_gpro_id,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].parent_entity_name = bgr.parent_entity_name,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].parent_entity_id = bgr.parent_entity_id,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].beg_effective_dt_tm = bgr
      .beg_effective_dt_tm, br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].end_effective_dt_tm =
      bgr.end_effective_dt_tm, br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].updt_id = bgr
      .updt_id,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].updt_task = bgr.updt_task,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].updt_applctx = bgr.updt_applctx,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].updt_dt_tm = bgr.updt_dt_tm,
      br_gpro_reltn_hist->br_gpro_reltn[gpro_reltn_size].updt_cnt = bgr.updt_cnt
     WITH nocounter
    ;end select
    CALL bederrorcheck("SELECTGPRORELTN")
    IF (gpro_reltn_size > 0)
     FOR (x = 1 TO gpro_reltn_size)
       SET br_new_gpro_reltn_id = 0.0
       SELECT INTO "nl:"
        z = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         br_new_gpro_reltn_id = cnvtreal(z)
        WITH nocounter
       ;end select
       CALL bederrorcheck("BEDROCKSEQERR")
       INSERT  FROM br_gpro_reltn bgr
        SET bgr.br_gpro_reltn_id = br_new_gpro_reltn_id, bgr.orig_br_gpro_reltn_id =
         br_gpro_reltn_hist->br_gpro_reltn[x].br_gpro_reltn_id, bgr.br_gpro_id = br_gpro_reltn_hist->
         br_gpro_reltn[x].br_gpro_id,
         bgr.parent_entity_name = br_gpro_reltn_hist->br_gpro_reltn[x].parent_entity_name, bgr
         .parent_entity_id = br_gpro_reltn_hist->br_gpro_reltn[x].parent_entity_id, bgr.active_ind =
         1,
         bgr.updt_dt_tm = cnvtdatetime(br_gpro_reltn_hist->br_gpro_reltn[x].updt_dt_tm), bgr.updt_id
          = br_gpro_reltn_hist->br_gpro_reltn[x].updt_id, bgr.updt_task = br_gpro_reltn_hist->
         br_gpro_reltn[x].updt_task,
         bgr.updt_applctx = br_gpro_reltn_hist->br_gpro_reltn[x].updt_applctx, bgr.updt_cnt =
         br_gpro_reltn_hist->br_gpro_reltn[x].updt_cnt, bgr.beg_effective_dt_tm = cnvtdatetime(
          br_gpro_reltn_hist->br_gpro_reltn[x].beg_effective_dt_tm),
         bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("BRGPRORELTNHIST")
       UPDATE  FROM br_gpro_reltn bgr
        SET bgr.active_ind = 0, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (bgr.br_gpro_reltn_id=br_gpro_reltn_hist->br_gpro_reltn[x].br_gpro_reltn_id)
         AND bgr.active_ind=1
         AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end update
       CALL bederrorcheck("BRGPROUPDATE")
     ENDFOR
    ENDIF
    IF ( NOT (validate(br_cpc_elig_prov_reltn_hist,0)))
     RECORD br_cpc_elig_prov_reltn_hist(
       1 br_cpc_elig_prov_reltn[*]
         2 br_cpc_elig_prov_reltn_id = f8
         2 br_cpc_id = f8
         2 br_eligible_provider_id = f8
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 updt_id = f8
         2 updt_task = i4
         2 updt_applctx = f8
         2 updt_dt_tm = dq8
         2 updt_cnt = i4
     ) WITH protect
    ENDIF
    DECLARE cpc_reltn_size = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM br_cpc_elig_prov_reltn bgr
     WHERE (bgr.br_eligible_provider_id=request->providers[p].id)
      AND bgr.active_ind=1
      AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      cpc_reltn_size = (cpc_reltn_size+ 1), stat = alterlist(br_cpc_elig_prov_reltn_hist->
       br_cpc_elig_prov_reltn,cpc_reltn_size), br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[
      cpc_reltn_size].br_cpc_elig_prov_reltn_id = bgr.br_cpc_elig_prov_reltn_id,
      br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].br_cpc_id = bgr.br_cpc_id,
      br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].br_eligible_provider_id =
      bgr.br_eligible_provider_id, br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size
      ].beg_effective_dt_tm = bgr.beg_effective_dt_tm,
      br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].end_effective_dt_tm = bgr
      .end_effective_dt_tm, br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].
      updt_id = bgr.updt_id, br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].
      updt_task = bgr.updt_task,
      br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].updt_applctx = bgr
      .updt_applctx, br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].updt_dt_tm
       = bgr.updt_dt_tm, br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[cpc_reltn_size].updt_cnt
       = bgr.updt_cnt
     WITH nocounter
    ;end select
    CALL bederrorcheck("SELECTCPCEPRELTN")
    IF (cpc_reltn_size > 0)
     FOR (x = 1 TO cpc_reltn_size)
       SET br_new_cpc_reltn_id = 0.0
       SELECT INTO "nl:"
        z = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         br_new_cpc_reltn_id = cnvtreal(z)
        WITH nocounter
       ;end select
       CALL bederrorcheck("BEDROCKSEQERR")
       INSERT  FROM br_cpc_elig_prov_reltn bgr
        SET bgr.br_cpc_elig_prov_reltn_id = br_new_cpc_reltn_id, bgr.orig_br_cpc_elig_prov_reltn_id
          = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].br_cpc_elig_prov_reltn_id, bgr
         .br_eligible_provider_id = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].
         br_eligible_provider_id,
         bgr.br_cpc_id = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].br_cpc_id, bgr
         .active_ind = 1, bgr.updt_dt_tm = cnvtdatetime(br_cpc_elig_prov_reltn_hist->
          br_cpc_elig_prov_reltn[x].updt_dt_tm),
         bgr.updt_id = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].updt_id, bgr.updt_task
          = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].updt_task, bgr.updt_applctx =
         br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].updt_applctx,
         bgr.updt_cnt = br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].updt_cnt, bgr
         .beg_effective_dt_tm = cnvtdatetime(br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].
          beg_effective_dt_tm), bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       CALL bederrorcheck("BRCPCRELTNHIST")
       UPDATE  FROM br_cpc_elig_prov_reltn bgr
        SET bgr.active_ind = 0, bgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (bgr.br_cpc_elig_prov_reltn_id=br_cpc_elig_prov_reltn_hist->br_cpc_elig_prov_reltn[x].
        br_cpc_elig_prov_reltn_id)
         AND bgr.active_ind=1
         AND bgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end update
       CALL bederrorcheck("BRCPCUPDATE")
     ENDFOR
    ENDIF
    SELECT INTO "nl:"
     FROM br_elig_prov_extension bepe
     WHERE (bepe.br_eligible_provider_id=request->providers[p].id)
      AND bepe.active_ind=1
      AND bepe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      copyextension->br_elig_prov_extension_id = bepe.br_elig_prov_extension_id, copyextension->
      orig_br_elig_prov_extension_id = bepe.orig_br_elig_prov_extension_id, copyextension->
      br_eligible_provider_id = bepe.br_eligible_provider_id,
      copyextension->program_type_txt = bepe.program_type_txt, copyextension->medicaid_stage_cd =
      bepe.medicaid_stage_cd, copyextension->medicare_year = bepe.medicare_year,
      copyextension->beg_effective_dt_tm = bepe.beg_effective_dt_tm
     WITH nocounter
    ;end select
    CALL bederrorcheck("EPExtHistErr1")
    IF (curqual > 0)
     DECLARE new_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      z = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       new_id = cnvtreal(z)
      WITH nocounter
     ;end select
     CALL bederrorcheck("EPExtHistErr2")
     INSERT  FROM br_elig_prov_extension bepe
      SET bepe.br_elig_prov_extension_id = new_id, bepe.orig_br_elig_prov_extension_id =
       copyextension->orig_br_elig_prov_extension_id, bepe.br_eligible_provider_id = copyextension->
       br_eligible_provider_id,
       bepe.program_type_txt = copyextension->program_type_txt, bepe.medicaid_stage_cd =
       copyextension->medicaid_stage_cd, bepe.medicare_year = copyextension->medicare_year,
       bepe.beg_effective_dt_tm = cnvtdatetime(copyextension->beg_effective_dt_tm), bepe
       .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bepe.active_ind = 1,
       bepe.updt_dt_tm = cnvtdatetime(curdate,curtime3), bepe.updt_id = reqinfo->updt_id, bepe
       .updt_task = reqinfo->updt_task,
       bepe.updt_applctx = reqinfo->updt_applctx, bepe.updt_cnt = 0
      WITH nocounter
     ;end insert
     CALL bederrorcheck("EPExtHistErr3")
     UPDATE  FROM br_elig_prov_extension bepe
      SET bepe.active_ind = 0, bepe.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bepe
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bepe.updt_id = reqinfo->updt_id, bepe.updt_task = reqinfo->updt_task, bepe.updt_applctx =
       reqinfo->updt_applctx,
       bepe.updt_cnt = (bepe.updt_cnt+ 1)
      WHERE (bepe.br_elig_prov_extension_id=copyextension->br_elig_prov_extension_id)
     ;end update
     CALL bederrorcheck("EPExtHistErr4")
    ENDIF
    DELETE  FROM br_eligible_provider b
     WHERE (b.br_eligible_provider_id=request->providers[p].id)
      AND b.active_ind=1
      AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("DELETEEP")
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
