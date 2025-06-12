CREATE PROGRAM bed_ens_info_buttons:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 buttons[*]
      2 service_id = f8
      2 service_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET temp_category
 RECORD temp_category(
   1 categories[*]
     2 service_id = f8
     2 action_flag = i2
     2 category_code = f8
     2 service_vocab_id = f8
 )
 FREE SET temp_cat_reltn
 RECORD temp_cat_reltn(
   1 facs[*]
     2 service_id = f8
     2 service_type_code = f8
     2 service_uri = vc
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 reltn_id = f8
     2 category_code = f8
 )
 FREE SET temp_nomen
 RECORD temp_nomen(
   1 nomens[*]
     2 service_id = f8
     2 action_flag = i2
     2 category_code = f8
     2 nomen_code = f8
     2 service_vocab_id = f8
 )
 FREE SET temp_staging_fac
 RECORD temp_staging_fac(
   1 facilities[*]
     2 action_flag = i2
     2 fac_code = f8
     2 entity_name = vc
     2 reltn_id = f8
     2 service_id = f8
     2 service_type_cd = f8
     2 service_uri = vc
 )
 FREE SET temp_fac
 RECORD temp_fac(
   1 facs[*]
     2 action_flag = i2
     2 fac_code = f8
     2 entity_name = vc
     2 reltn_id = f8
     2 service_id = f8
     2 service_type_cd = f8
     2 service_uri = vc
     2 category_code = f8
 )
 FREE SET temp_service_cd
 RECORD temp_service_cd(
   1 service_cds[*]
     2 service_cd = f8
 )
 FREE SET temp_authorization_cd
 RECORD temp_authorization_cd(
   1 authrorization_cd[*]
     2 authorization_type_cd = f8
 )
 FREE SET temp_action_flag
 RECORD temp_action_flag(
   1 action_flags[*]
     2 inserted_flag = i2
 )
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
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
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 DECLARE log_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE entity_name = vc WITH constant("LOCATION")
 DECLARE req_size = i4 WITH noconstant(0)
 DECLARE category_size = i4 WITH noconstant(0)
 DECLARE nomen_size = i4 WITH noconstant(0)
 DECLARE fac_size = i4 WITH noconstant(0)
 DECLARE category_cnt = i4 WITH noconstant(0)
 DECLARE nomen_cnt = i4 WITH noconstant(0)
 DECLARE fac_cnt = i4 WITH noconstant(0)
 DECLARE service_type_cd = f8 WITH noconstant(0.0)
 DECLARE patient_ed_cd = f8 WITH noconstant(0.0)
 DECLARE cds_cd = f8 WITH noconstant(0.0)
 DECLARE pe_cds_cd = f8 WITH noconstant(0.0)
 DECLARE authorization_type_cd = f8 WITH noconstant(0.0)
 DECLARE meaning = vc
 SET req_size = size(request->info_buttons,5)
 SET stat = alterlist(reply->buttons,req_size)
 SET stat = alterlist(temp_service_cd->service_cds,req_size)
 SET stat = alterlist(temp_action_flag->action_flags,req_size)
 SET stat = alterlist(temp_authorization_cd->authrorization_cd,req_size)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002691
   AND cv.cdf_meaning="INFOPAT"
   AND cv.active_ind=1
  DETAIL
   patient_ed_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002691
   AND cv.cdf_meaning="INFOCDS"
   AND cv.active_ind=1
  DETAIL
   cds_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002691
   AND cv.cdf_meaning="INFOPATCDS"
   AND cv.active_ind=1
  DETAIL
   pe_cds_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_size)
   IF ((request->info_buttons[x].patient_education=1)
    AND (request->info_buttons[x].clinical_research=1))
    SET temp_service_cd->service_cds[x].service_cd = pe_cds_cd
   ELSEIF ((request->info_buttons[x].patient_education=1))
    SET temp_service_cd->service_cds[x].service_cd = patient_ed_cd
   ELSEIF ((request->info_buttons[x].clinical_research=1))
    SET temp_service_cd->service_cds[x].service_cd = cds_cd
   ENDIF
   IF ( NOT ((request->info_buttons[x].user_name IN (""))))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=4002607
      AND cv.cdf_meaning="INFOBUTTON"
      AND cv.active_ind=1
     DETAIL
      temp_authorization_cd->authrorization_cd[x].authorization_type_cd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->info_buttons[x].action_flag=1))
    SET temp_btn_id = 0.0
    SELECT INTO "NL:"
     j = seq(si_registry_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      temp_btn_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL bederrorcheck("SeqError")
    SET request->info_buttons[x].service_id = temp_btn_id
    SET reply->buttons[x].service_id = request->info_buttons[x].service_id
    SET reply->buttons[x].service_name = request->info_buttons[x].service_name
   ENDIF
   SET category_size = size(request->info_buttons[x].content_categories,5)
   FOR (r = 1 TO category_size)
     SET category_cnt = (category_cnt+ 1)
     SET stat = alterlist(temp_category->categories,category_cnt)
     SET temp_category->categories[category_cnt].action_flag = request->info_buttons[x].
     content_categories[r].action_flag
     SET temp_category->categories[category_cnt].service_id = request->info_buttons[x].service_id
     SET temp_category->categories[category_cnt].category_code = request->info_buttons[x].
     content_categories[r].category_code
     IF ((request->info_buttons[x].content_categories[r].action_flag=1))
      SET vocabid = 0.0
      SELECT INTO "NL:"
       j = seq(si_registry_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        vocabid = cnvtreal(j)
       WITH format, counter
      ;end select
      CALL bederrorcheck("Seq2Error")
      SET temp_category->categories[category_cnt].service_vocab_id = vocabid
     ENDIF
     SET nomen_size = size(request->info_buttons[x].content_categories[r].nomens,5)
     FOR (s = 1 TO nomen_size)
       SET nomen_cnt = (nomen_cnt+ 1)
       SET stat = alterlist(temp_nomen->nomens,nomen_cnt)
       SET temp_nomen->nomens[nomen_cnt].action_flag = request->info_buttons[x].content_categories[r]
       .nomens[s].action_flag
       SET temp_nomen->nomens[nomen_cnt].nomen_code = request->info_buttons[x].content_categories[r].
       nomens[s].nomen_code
       SET temp_nomen->nomens[nomen_cnt].category_code = temp_category->categories[category_cnt].
       category_code
       SET temp_nomen->nomens[nomen_cnt].service_id = temp_category->categories[category_cnt].
       service_id
       IF ((temp_nomen->nomens[nomen_cnt].action_flag=1))
        SET vocabid = 0.0
        SELECT INTO "NL:"
         j = seq(si_registry_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          vocabid = cnvtreal(j)
         WITH format, counter
        ;end select
        CALL bederrorcheck("Seq3Error")
        SET temp_nomen->nomens[nomen_cnt].service_vocab_id = vocabid
       ENDIF
     ENDFOR
   ENDFOR
   SET fac_size = size(request->info_buttons[x].facilities,5)
   FOR (a = 1 TO fac_size)
     SET fac_cnt = (fac_cnt+ 1)
     SET stat = alterlist(temp_staging_fac->facilities,fac_cnt)
     SET temp_staging_fac->facilities[fac_cnt].fac_code = request->info_buttons[x].facilities[a].
     fac_code
     SET temp_staging_fac->facilities[fac_cnt].entity_name = entity_name
     SET temp_staging_fac->facilities[fac_cnt].action_flag = request->info_buttons[x].facilities[a].
     action_flag
     SET temp_staging_fac->facilities[fac_cnt].service_id = request->info_buttons[x].service_id
     IF ((request->info_buttons[x].service_type_code=0.0))
      SET temp_staging_fac->facilities[fac_cnt].service_type_cd = temp_service_cd->service_cds[x].
      service_cd
     ELSE
      SET temp_staging_fac->facilities[fac_cnt].service_type_cd = request->info_buttons[x].
      service_type_code
     ENDIF
     SET temp_staging_fac->facilities[fac_cnt].service_uri = request->info_buttons[x].service_uri
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp_staging_fac->facilities,5)),
   (dummyt d1  WITH seq = size(temp_category->categories,5))
  PLAN (d
   WHERE (temp_staging_fac->facilities[d.seq].action_flag=1))
   JOIN (d1
   WHERE (outerjoin(temp_category->categories[d1.seq].service_id)=temp_staging_fac->facilities[d.seq]
   .service_id))
  ORDER BY d.seq, d1.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp_fac->facs,cnt), temp_fac->facs[cnt].action_flag =
   temp_staging_fac->facilities[d.seq].action_flag,
   temp_fac->facs[cnt].fac_code = temp_staging_fac->facilities[d.seq].fac_code, temp_fac->facs[cnt].
   entity_name = temp_staging_fac->facilities[d.seq].entity_name, temp_fac->facs[cnt].service_id =
   temp_staging_fac->facilities[d.seq].service_id,
   temp_fac->facs[cnt].service_type_cd = temp_staging_fac->facilities[d.seq].service_type_cd,
   temp_fac->facs[cnt].service_uri = temp_staging_fac->facilities[d.seq].service_uri, temp_fac->facs[
   cnt].category_code = temp_category->categories[d1.seq].category_code
   IF ((temp_staging_fac->facilities[d.seq].action_flag=1)
    AND (temp_staging_fac->facilities[d.seq].service_type_cd=pe_cds_cd))
    temp_fac->facs[cnt].service_type_cd = patient_ed_cd, cnt = (cnt+ 1), stat = alterlist(temp_fac->
     facs,cnt),
    temp_fac->facs[cnt].action_flag = temp_staging_fac->facilities[d.seq].action_flag, temp_fac->
    facs[cnt].fac_code = temp_staging_fac->facilities[d.seq].fac_code, temp_fac->facs[cnt].
    entity_name = temp_staging_fac->facilities[d.seq].entity_name,
    temp_fac->facs[cnt].service_id = temp_staging_fac->facilities[d.seq].service_id, temp_fac->facs[
    cnt].service_type_cd = cds_cd, temp_fac->facs[cnt].service_uri = temp_staging_fac->facilities[d
    .seq].service_uri,
    temp_fac->facs[cnt].category_code = temp_category->categories[d1.seq].category_code
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_fac->facs,cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("FacReltnPopErr1")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp_staging_fac->facilities,5))
  PLAN (d
   WHERE (temp_staging_fac->facilities[d.seq].action_flag=3))
  HEAD REPORT
   cnt = size(temp_fac->facs,5), tcnt = (cnt+ 100), stat = alterlist(temp_fac->facs,tcnt)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > tcnt)
    stat = alterlist(temp_fac->facs,(tcnt+ 100)), tcnt = (tcnt+ 100)
   ENDIF
   temp_fac->facs[cnt].action_flag = temp_staging_fac->facilities[d.seq].action_flag, temp_fac->facs[
   cnt].fac_code = temp_staging_fac->facilities[d.seq].fac_code, temp_fac->facs[cnt].entity_name =
   temp_staging_fac->facilities[d.seq].entity_name,
   temp_fac->facs[cnt].service_id = temp_staging_fac->facilities[d.seq].service_id, temp_fac->facs[
   cnt].service_type_cd = temp_staging_fac->facilities[d.seq].service_type_cd, temp_fac->facs[cnt].
   service_uri = temp_staging_fac->facilities[d.seq].service_uri
  FOOT REPORT
   stat = alterlist(temp_fac->facs,cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("FacReltnPopErr2")
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 SET category_size = size(temp_category->categories,5)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(category_size)),
   si_service_reltn ssr
  PLAN (d
   WHERE (temp_category->categories[d.seq].action_flag=1))
   JOIN (ssr
   WHERE (ssr.si_external_service_id=temp_category->categories[d.seq].service_id))
  ORDER BY d.seq, ssr.parent_entity_id
  HEAD REPORT
   cnt = 0, stat = alterlist(temp_cat_reltn->facs,100)
  HEAD d.seq
   dummy_var = 0
  HEAD ssr.parent_entity_id
   cnt = (cnt+ 1), rcnt = (rcnt+ 1)
   IF (rcnt > 100)
    stat = alterlist(temp_cat_reltn->facs,(cnt+ 100)), rcnt = 0
   ENDIF
   temp_cat_reltn->facs[cnt].service_id = ssr.si_external_service_id, temp_cat_reltn->facs[cnt].
   service_type_code = ssr.external_service_type_cd, temp_cat_reltn->facs[cnt].service_uri = ssr
   .service_uri,
   temp_cat_reltn->facs[cnt].parent_entity_id = ssr.parent_entity_id, temp_cat_reltn->facs[cnt].
   parent_entity_name = ssr.parent_entity_name, temp_cat_reltn->facs[cnt].category_code =
   temp_category->categories[d.seq].category_code
  FOOT REPORT
   stat = alterlist(temp_cat_reltn->facs,cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("CatReltnPopErr")
 DELETE  FROM si_external_service_vocab sesv,
   (dummyt d  WITH seq = value(req_size))
  SET sesv.seq = 1
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=3))
   JOIN (sesv
   WHERE (sesv.si_external_service_id=request->info_buttons[d.seq].service_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("BtnNomenDeleteError")
 DELETE  FROM si_service_reltn ssr,
   (dummyt d  WITH seq = value(req_size))
  SET ssr.seq = 1
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=3))
   JOIN (ssr
   WHERE (ssr.si_external_service_id=request->info_buttons[d.seq].service_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("BtnFacReltnDelErr")
 DELETE  FROM si_external_service ses,
   (dummyt d  WITH seq = value(req_size))
  SET ses.seq = 1
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=3))
   JOIN (ses
   WHERE (ses.si_external_service_id=request->info_buttons[d.seq].service_id)
    AND ses.logical_domain_id=log_domain_id)
  WITH nocounter
 ;end delete
 CALL bederrorcheck("BtnDeleteError")
 UPDATE  FROM si_external_service ses,
   (dummyt d  WITH seq = value(req_size))
  SET ses.service_name = request->info_buttons[d.seq].service_name, ses.service_uri = request->
   info_buttons[d.seq].service_uri, ses.username_txt = request->info_buttons[d.seq].user_name,
   ses.authorization_type_cd = temp_authorization_cd->authrorization_cd[d.seq].authorization_type_cd,
   ses.external_service_type_cd = temp_service_cd->service_cds[d.seq].service_cd, ses.certificate_txt
    = request->info_buttons[d.seq].password,
   ses.updt_dt_tm = cnvtdatetime(curdate,curtime3), ses.updt_id = reqinfo->updt_id, ses.updt_task =
   reqinfo->updt_task,
   ses.updt_cnt = (ses.updt_cnt+ 1), ses.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=2))
   JOIN (ses
   WHERE (ses.si_external_service_id=request->info_buttons[d.seq].service_id)
    AND ses.logical_domain_id=log_domain_id)
  WITH nocounter
 ;end update
 CALL bederrorcheck("BtnUpdateError")
 UPDATE  FROM si_service_property ssp,
   (dummyt d  WITH seq = value(req_size))
  SET ssp.prop_value =
   IF ((request->info_buttons[d.seq].send_personel_id=1)) "ENABLED"
   ELSE "DISABLED"
   ENDIF
   , ssp.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssp.updt_id = reqinfo->updt_id,
   ssp.updt_task = reqinfo->updt_task, ssp.updt_cnt = (ssp.updt_cnt+ 1), ssp.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=2))
   JOIN (ssp
   WHERE (ssp.parent_entity_id=request->info_buttons[d.seq].service_id)
    AND ssp.parent_entity_name="SI_EXTERNAL_SERVICE"
    AND ssp.prop_name="SEND_USERNAME_AS_AUTHORIZED")
  WITH nocounter
 ;end update
 CALL bederrorcheck("BtnUpdatePropError")
 UPDATE  FROM si_service_reltn ssr,
   (dummyt d  WITH seq = value(req_size))
  SET ssr.default_ind = 0
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=2)
    AND (request->info_buttons[d.seq].patient_education=0))
   JOIN (ssr
   WHERE (ssr.si_external_service_id=request->info_buttons[d.seq].service_id)
    AND ssr.parent_entity_name="LOCATION"
    AND ssr.external_service_type_cd=patient_ed_cd)
  WITH nocounter
 ;end update
 CALL bederrorcheck("RemoveDefaultsFromFacReln")
 UPDATE  FROM si_service_reltn ssr,
   (dummyt d  WITH seq = value(req_size))
  SET ssr.default_ind = 0
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=2)
    AND (request->info_buttons[d.seq].clinical_research=0))
   JOIN (ssr
   WHERE (ssr.si_external_service_id=request->info_buttons[d.seq].service_id)
    AND ssr.parent_entity_name="LOCATION"
    AND ssr.external_service_type_cd=cds_cd)
  WITH nocounter
 ;end update
 CALL bederrorcheck("RemoveDefaultsFromFacReln")
 SELECT INTO "nl:"
  FROM si_service_property ssp,
   (dummyt d  WITH seq = value(req_size))
  PLAN (d)
   JOIN (ssp
   WHERE (ssp.parent_entity_id=request->info_buttons[d.seq].service_id)
    AND ssp.parent_entity_name="SI_EXTERNAL_SERVICE"
    AND ssp.prop_name="SEND_USERNAME_AS_AUTHORIZED")
  ORDER BY d.seq
  HEAD d.seq
   temp_action_flag->action_flags[d.seq].inserted_flag = 2
  WITH nocounter
 ;end select
 CALL bederrorcheck("BtnSelUpInsertError")
 INSERT  FROM si_service_property ssp,
   (dummyt d  WITH seq = value(req_size))
  SET ssp.parent_entity_name = "SI_EXTERNAL_SERVICE", ssp.parent_entity_id = request->info_buttons[d
   .seq].service_id, ssp.si_service_property_id = seq(si_registry_seq,nextval),
   ssp.prop_name = "SEND_USERNAME_AS_AUTHORIZED", ssp.prop_value =
   IF ((request->info_buttons[d.seq].send_personel_id=1)) "ENABLED"
   ELSE "DISABLED"
   ENDIF
   , ssp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ssp.updt_id = reqinfo->updt_id, ssp.updt_task = reqinfo->updt_task, ssp.updt_cnt = 0,
   ssp.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=2)
    AND (temp_action_flag->action_flags[d.seq].inserted_flag=0))
   JOIN (ssp)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("BtnUpInsertError")
 INSERT  FROM si_external_service ses,
   (dummyt d  WITH seq = value(req_size))
  SET ses.si_external_service_id = request->info_buttons[d.seq].service_id, ses.service_name =
   request->info_buttons[d.seq].service_name, ses.service_uri = request->info_buttons[d.seq].
   service_uri,
   ses.external_service_type_cd = temp_service_cd->service_cds[d.seq].service_cd, ses.username_txt =
   request->info_buttons[d.seq].user_name, ses.authorization_type_cd = temp_authorization_cd->
   authrorization_cd[d.seq].authorization_type_cd,
   ses.certificate_txt = request->info_buttons[d.seq].password, ses.logical_domain_id = log_domain_id,
   ses.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ses.updt_id = reqinfo->updt_id, ses.updt_task = reqinfo->updt_task, ses.updt_cnt = 0,
   ses.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=1))
   JOIN (ses)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("BtnInsertError")
 INSERT  FROM si_service_property ssp,
   (dummyt d  WITH seq = value(req_size))
  SET ssp.parent_entity_name = "SI_EXTERNAL_SERVICE", ssp.parent_entity_id = request->info_buttons[d
   .seq].service_id, ssp.si_service_property_id = seq(si_registry_seq,nextval),
   ssp.prop_name = "SEND_USERNAME_AS_AUTHORIZED", ssp.prop_value =
   IF ((request->info_buttons[d.seq].send_personel_id=1)) "ENABLED"
   ELSE "DISABLED"
   ENDIF
   , ssp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ssp.updt_id = reqinfo->updt_id, ssp.updt_task = reqinfo->updt_task, ssp.updt_cnt = 0,
   ssp.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->info_buttons[d.seq].action_flag=1))
   JOIN (ssp)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("BtnInsertPropError")
 SET category_size = size(temp_category->categories,5)
 IF (category_size > 0)
  DELETE  FROM si_external_service_vocab sesv,
    (dummyt d  WITH seq = value(category_size))
   SET sesv.seq = 1
   PLAN (d
    WHERE (temp_category->categories[d.seq].action_flag=3))
    JOIN (sesv
    WHERE (sesv.si_external_service_id=temp_category->categories[d.seq].service_id)
     AND (sesv.content_category_cd=temp_category->categories[d.seq].category_code))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("CatDeleteError")
  DELETE  FROM si_service_reltn ssr,
    (dummyt d  WITH seq = value(category_size))
   SET ssr.seq = 1
   PLAN (d
    WHERE (temp_category->categories[d.seq].action_flag=3))
    JOIN (ssr
    WHERE (ssr.si_external_service_id=temp_category->categories[d.seq].service_id)
     AND (ssr.content_cat_filter_cd=temp_category->categories[d.seq].category_code))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("CatReltnDelErr")
  INSERT  FROM si_external_service_vocab sesv,
    (dummyt d  WITH seq = value(category_size))
   SET sesv.si_external_service_vocab_id = temp_category->categories[d.seq].service_vocab_id, sesv
    .si_external_service_id = temp_category->categories[d.seq].service_id, sesv.content_category_cd
     = temp_category->categories[d.seq].category_code,
    sesv.updt_dt_tm = cnvtdatetime(curdate,curtime3), sesv.updt_id = reqinfo->updt_id, sesv.updt_task
     = reqinfo->updt_task,
    sesv.updt_cnt = 0, sesv.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_category->categories[d.seq].action_flag=1))
    JOIN (sesv)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("InsertContentError")
 ENDIF
 SET cat_reltn_size = size(temp_cat_reltn->facs,5)
 IF (cat_reltn_size > 0)
  INSERT  FROM si_service_reltn ssr,
    (dummyt d  WITH seq = value(cat_reltn_size))
   SET ssr.si_service_reltn_id = seq(si_registry_seq,nextval), ssr.si_external_service_id =
    temp_cat_reltn->facs[d.seq].service_id, ssr.external_service_type_cd = temp_cat_reltn->facs[d.seq
    ].service_type_code,
    ssr.parent_entity_id = temp_cat_reltn->facs[d.seq].parent_entity_id, ssr.parent_entity_name =
    temp_cat_reltn->facs[d.seq].parent_entity_name, ssr.service_uri = temp_cat_reltn->facs[d.seq].
    service_uri,
    ssr.listener_alias = "", ssr.authorization_type_cd = 0.0, ssr.auth_location_uri = "",
    ssr.certificate_location_uri = "", ssr.certificate_type_cd = 0.0, ssr.content_cat_filter_cd =
    temp_cat_reltn->facs[d.seq].category_code,
    ssr.default_ind = 0, ssr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssr.updt_id = reqinfo->
    updt_id,
    ssr.updt_task = reqinfo->updt_task, ssr.updt_cnt = 0, ssr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ssr)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("CatReltnInsertErr")
 ENDIF
 SET nomen_size = size(temp_nomen->nomens,5)
 IF (nomen_size > 0)
  DELETE  FROM si_external_service_vocab sesv,
    (dummyt d  WITH seq = value(nomen_size))
   SET sesv.seq = 1
   PLAN (d
    WHERE (temp_nomen->nomens[d.seq].action_flag=3))
    JOIN (sesv
    WHERE (sesv.si_external_service_id=temp_nomen->nomens[d.seq].service_id)
     AND (sesv.content_category_cd=temp_nomen->nomens[d.seq].category_code)
     AND (sesv.vocabulary_cd=temp_nomen->nomens[d.seq].nomen_code))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("DeleteNomenError")
  INSERT  FROM si_external_service_vocab sesv,
    (dummyt d  WITH seq = value(nomen_size))
   SET sesv.si_external_service_vocab_id = temp_nomen->nomens[d.seq].service_vocab_id, sesv
    .si_external_service_id = temp_nomen->nomens[d.seq].service_id, sesv.content_category_cd =
    temp_nomen->nomens[d.seq].category_code,
    sesv.vocabulary_cd = temp_nomen->nomens[d.seq].nomen_code, sesv.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), sesv.updt_id = reqinfo->updt_id,
    sesv.updt_task = reqinfo->updt_task, sesv.updt_cnt = 0, sesv.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_nomen->nomens[d.seq].action_flag=1))
    JOIN (sesv)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("InsertNomenError")
 ENDIF
 SET fac_size = size(temp_fac->facs,5)
 IF (fac_size > 0)
  DELETE  FROM si_service_reltn ssr,
    (dummyt d  WITH seq = value(fac_size))
   SET ssr.seq = 1
   PLAN (d
    WHERE (temp_fac->facs[d.seq].action_flag=3))
    JOIN (ssr
    WHERE (ssr.si_external_service_id=temp_fac->facs[d.seq].service_id)
     AND (ssr.parent_entity_id=temp_fac->facs[d.seq].fac_code))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("DeleteReltnError")
  INSERT  FROM si_service_reltn ssr,
    (dummyt d  WITH seq = value(fac_size))
   SET ssr.si_service_reltn_id = seq(si_registry_seq,nextval), ssr.si_external_service_id = temp_fac
    ->facs[d.seq].service_id, ssr.external_service_type_cd = temp_fac->facs[d.seq].service_type_cd,
    ssr.parent_entity_id = temp_fac->facs[d.seq].fac_code, ssr.parent_entity_name = temp_fac->facs[d
    .seq].entity_name, ssr.service_uri = temp_fac->facs[d.seq].service_uri,
    ssr.listener_alias = "", ssr.authorization_type_cd = 0.0, ssr.auth_location_uri = "",
    ssr.certificate_location_uri = "", ssr.certificate_type_cd = 0.0, ssr.content_cat_filter_cd =
    temp_fac->facs[d.seq].category_code,
    ssr.default_ind = 0, ssr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssr.updt_id = reqinfo->
    updt_id,
    ssr.updt_task = reqinfo->updt_task, ssr.updt_cnt = 0, ssr.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp_fac->facs[d.seq].action_flag=1))
    JOIN (ssr)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("InsertFacilityError")
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
