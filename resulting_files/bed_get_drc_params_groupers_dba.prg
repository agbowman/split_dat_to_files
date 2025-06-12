CREATE PROGRAM bed_get_drc_params_groupers:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 drc_qual[*]
      2 dose_range_check_name = vc
      2 drc_group_id = f8
      2 has_facilities_assoc = i2
      2 dose_range_id_for_default = f8
      2 has_content_defined_for_default = i2
    1 products[*]
      2 formulation_id = f8
      2 item_id = f8
      2 generic_name = vc
      2 cki = vc
      2 groups[*]
        3 drc_group_reltn_id = f8
        3 dose_range_check_name = vc
        3 drc_group_id = f8
        3 has_facilities_assoc = i2
        3 dose_range_id_for_default = f8
        3 has_content_defined_for_default = i2
    1 synonyms[*]
      2 drug_synonym_id = f8
      2 synonym_id = f8
      2 mnemonic = vc
      2 cki = vc
      2 groups[*]
        3 drc_group_reltn_id = f8
        3 dose_range_check_name = vc
        3 drc_group_id = f8
        3 has_facilities_assoc = i2
        3 dose_range_id_for_default = f8
        3 has_content_defined_for_default = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
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
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
 ENDIF
 CALL bedbeginscript(0)
 DECLARE new_model_check = i2 WITH public, noconstant(0)
 DECLARE getgroupersbygroupername(dummyvar=i2) = i2
 DECLARE getgroupersbyproductname(dummyvar=i2) = i2
 DECLARE getgroupersbysynonymname(dummyvar=i2) = i2
 CASE (request->search_type_flag)
  OF 0:
   CALL getgroupersbygroupername(0)
  OF 1:
   CALL getgroupersbyproductname(0)
  OF 2:
   CALL getgroupersbysynonymname(0)
 ENDCASE
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getgroupersbygroupername(dummyvar)
   DECLARE drc_cnt = i4 WITH protect, noconstant(0)
   IF ((request->starts_with_contains_flag=0))
    SELECT DISTINCT INTO "nl:"
     drc.dose_range_check_name, dgr.drc_group_id
     FROM dose_range_check drc,
      drc_form_reltn dfr,
      drc_group_reltn dgr
     PLAN (drc
      WHERE cnvtupper(drc.dose_range_check_name) IN (patstring(concat(cnvtupper(trim(request->
          drug_name)),"*"))))
      JOIN (dfr
      WHERE dfr.dose_range_check_id=drc.dose_range_check_id
       AND dfr.drc_group_id > 0)
      JOIN (dgr
      WHERE dgr.drc_group_id=dfr.drc_group_id)
     ORDER BY dgr.drc_group_id
     HEAD REPORT
      drc_cnt = 0
     HEAD dgr.drc_group_id
      drc_cnt = (drc_cnt+ 1)
      IF (mod(drc_cnt,10)=1)
       stat = alterlist(reply->drc_qual,(drc_cnt+ 9))
      ENDIF
      reply->drc_qual[drc_cnt].dose_range_check_name = drc.dose_range_check_name, reply->drc_qual[
      drc_cnt].drc_group_id = dgr.drc_group_id, reply->drc_qual[drc_cnt].has_facilities_assoc = 0
     FOOT REPORT
      stat = alterlist(reply->drc_qual,drc_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error001 : grouper by grouper name starts with")
   ELSE
    SELECT DISTINCT INTO "nl:"
     drc.dose_range_check_name, dgr.drc_group_id
     FROM dose_range_check drc,
      drc_form_reltn dfr,
      drc_group_reltn dgr
     PLAN (drc
      WHERE cnvtupper(drc.dose_range_check_name) IN (patstring(concat("*",cnvtupper(trim(request->
          drug_name)),"*"))))
      JOIN (dfr
      WHERE dfr.dose_range_check_id=drc.dose_range_check_id
       AND dfr.drc_group_id > 0)
      JOIN (dgr
      WHERE dgr.drc_group_id=dfr.drc_group_id)
     ORDER BY dgr.drc_group_id
     HEAD REPORT
      drc_cnt = 0
     HEAD dgr.drc_group_id
      drc_cnt = (drc_cnt+ 1)
      IF (mod(drc_cnt,10)=1)
       stat = alterlist(reply->drc_qual,(drc_cnt+ 9))
      ENDIF
      reply->drc_qual[drc_cnt].dose_range_check_name = drc.dose_range_check_name, reply->drc_qual[
      drc_cnt].drc_group_id = dgr.drc_group_id, reply->drc_qual[drc_cnt].has_facilities_assoc = 0
     FOOT REPORT
      stat = alterlist(reply->drc_qual,drc_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error002 : grouper by grouper name contains")
   ENDIF
   FOR (curr_group_cnt = 1 TO size(reply->drc_qual,5))
     SELECT INTO "nl:"
      FROM drc_facility_r dfreltn
      WHERE (dfreltn.drc_group_id=reply->drc_qual[curr_group_cnt].drc_group_id)
       AND dfreltn.active_ind=1
      DETAIL
       IF (dfreltn.facility_cd=0.0)
        reply->drc_qual[curr_group_cnt].dose_range_id_for_default = dfreltn.dose_range_check_id
       ENDIF
       IF (dfreltn.facility_cd > 0.0)
        IF ((reply->drc_qual[curr_group_cnt].has_facilities_assoc=0.0))
         reply->drc_qual[curr_group_cnt].has_facilities_assoc = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM drc_premise dp
      WHERE (dp.dose_range_check_id=reply->drc_qual[curr_group_cnt].dose_range_id_for_default)
       AND dp.parent_ind=1
       AND dp.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET reply->drc_qual[curr_group_cnt].has_content_defined_for_default = 1
     ELSE
      SET reply->drc_qual[curr_group_cnt].has_content_defined_for_default = 0
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error003 : grouper's facilities")
 END ;Subroutine
 SUBROUTINE getgroupersbyproductname(dummyvar)
   SET med_def_cd = uar_get_code_by("MEANING",11001,"MED_DEF")
   SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
   SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
   SET sys_pkg_type_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
   SELECT INTO "nl:"
    dmp.pref_nbr
    FROM dm_prefs dmp
    WHERE dmp.application_nbr=300000
     AND dmp.pref_domain="PHARMNET-INPATIENT"
     AND dmp.pref_name="NEW MODEL"
     AND dmp.person_id=0
     AND dmp.pref_section="FRMLRYMGMT"
    DETAIL
     IF (dmp.pref_nbr=1)
      new_model_check = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (new_model_check=0)
    IF ((request->starts_with_contains_flag=0))
     SELECT INTO "nl:"
      FROM object_identifier_index oii,
       medication_definition md,
       drc_group_reltn dgr,
       drc_form_reltn dfr,
       dose_range_check drc,
       drc_facility_r dfreltn
      PLAN (oii
       WHERE oii.object_type_cd=med_def_cd
        AND oii.identifier_type_cd=desc_cd
        AND oii.active_ind=1
        AND oii.generic_object=0
        AND oii.primary_ind=1
        AND cnvtupper(oii.value_key) IN (patstring(concat(trim(cnvtupper(trim(cnvtalphanum(request->
             drug_name),8)),5),"*"))))
       JOIN (md
       WHERE md.item_id=oii.object_id)
       JOIN (dgr
       WHERE md.cki > outerjoin(" ")
        AND md.cki=outerjoin("MUL.FRMLTN!*")
        AND dgr.formulation_id=outerjoin(cnvtint(substring(12,10,md.cki))))
       JOIN (dfr
       WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id)
        AND dfr.drc_group_id > outerjoin(0))
       JOIN (drc
       WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id))
       JOIN (dfreltn
       WHERE dfreltn.facility_cd > outerjoin(0))
      ORDER BY oii.value, dfr.drc_group_id
      HEAD REPORT
       prod_cnt = 0, group_cnt = 0, stat = alterlist(reply->products,10),
       save_drc_id = 0.0
      HEAD oii.value
       IF (md.cki="MUL.FRMLTN!*")
        prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->products,prod_cnt), reply->products[
        prod_cnt].item_id = oii.object_id,
        reply->products[prod_cnt].generic_name = oii.value, reply->products[prod_cnt].cki = md.cki
        IF (dgr.drc_group_reltn_id > 0)
         reply->products[prod_cnt].formulation_id = dgr.formulation_id
        ENDIF
        group_cnt = 0, save_drc_id = 0.0, group_cnt = (group_cnt+ 1),
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt), reply->products[prod_cnt].
        groups[group_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
        groups[group_cnt].dose_range_check_name = drc.dose_range_check_name,
        reply->products[prod_cnt].groups[group_cnt].drc_group_id = dfr.drc_group_id, save_drc_id =
        drc.dose_range_check_id, reply->products[prod_cnt].groups[group_cnt].has_facilities_assoc = 0
       ENDIF
      FOOT  oii.value
       IF (group_cnt > 0)
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt)
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->products,prod_cnt)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = "T"
     ENDIF
     CALL bederrorcheck("Error004 : grouper by product name starts with (old formulary)")
    ELSEIF ((request->starts_with_contains_flag=1))
     SELECT INTO "nl:"
      FROM object_identifier_index oii,
       medication_definition md,
       drc_group_reltn dgr,
       drc_form_reltn dfr,
       dose_range_check drc
      PLAN (oii
       WHERE oii.object_type_cd=med_def_cd
        AND oii.identifier_type_cd=desc_cd
        AND oii.active_ind=1
        AND oii.generic_object=0
        AND oii.primary_ind=1
        AND cnvtupper(oii.value_key) IN (patstring(concat("*",trim(cnvtupper(trim(cnvtalphanum(
             request->drug_name),8)),5),"*"))))
       JOIN (md
       WHERE md.item_id=oii.object_id)
       JOIN (dgr
       WHERE md.cki > outerjoin(" ")
        AND md.cki=outerjoin("MUL.FRMLTN!*")
        AND dgr.formulation_id=outerjoin(cnvtint(substring(12,10,md.cki))))
       JOIN (dfr
       WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id)
        AND dfr.drc_group_id > outerjoin(0))
       JOIN (drc
       WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id))
      ORDER BY oii.value, dfr.drc_group_id
      HEAD REPORT
       prod_cnt = 0, group_cnt = 0, stat = alterlist(reply->products,10),
       save_drc_id = 0.0
      HEAD oii.value
       IF (md.cki="MUL.FRMLTN!*")
        prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->products,prod_cnt), reply->products[
        prod_cnt].item_id = oii.object_id,
        reply->products[prod_cnt].generic_name = oii.value, reply->products[prod_cnt].cki = md.cki
        IF (dgr.drc_group_reltn_id > 0)
         reply->products[prod_cnt].formulation_id = dgr.formulation_id
        ENDIF
        group_cnt = 0, save_drc_id = 0.0, group_cnt = (group_cnt+ 1),
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt), reply->products[prod_cnt].
        groups[group_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
        groups[group_cnt].dose_range_check_name = drc.dose_range_check_name,
        reply->products[prod_cnt].groups[group_cnt].drc_group_id = dfr.drc_group_id, save_drc_id =
        drc.dose_range_check_id, reply->products[prod_cnt].groups[group_cnt].has_facilities_assoc = 0
       ENDIF
      FOOT  oii.value
       IF (group_cnt > 0)
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt)
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->products,prod_cnt)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = "T"
     ENDIF
    ENDIF
    CALL bederrorcheck("Error005 : grouper by product name contains (old formulary)")
   ELSE
    IF ((request->starts_with_contains_flag=0))
     SELECT INTO "nl:"
      FROM med_identifier mi,
       medication_definition md,
       drc_group_reltn dgr,
       drc_form_reltn dfr,
       dose_range_check drc
      PLAN (mi
       WHERE cnvtupper(mi.value_key) IN (patstring(concat(trim(cnvtupper(trim(cnvtalphanum(request->
             drug_name),8)),5),"*")))
        AND mi.flex_type_cd IN (system_cd, sys_pkg_type_cd)
        AND mi.med_product_id=0.0
        AND mi.med_identifier_type_cd=desc_cd
        AND mi.active_ind=1)
       JOIN (md
       WHERE md.item_id=mi.item_id)
       JOIN (dgr
       WHERE md.cki > outerjoin(" ")
        AND md.cki=outerjoin("MUL.FRMLTN!*")
        AND dgr.formulation_id=outerjoin(cnvtint(substring(12,10,md.cki))))
       JOIN (dfr
       WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id)
        AND dfr.drc_group_id > outerjoin(0))
       JOIN (drc
       WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id))
      ORDER BY mi.value, dfr.drc_group_id
      HEAD REPORT
       prod_cnt = 0, group_cnt = 0, stat = alterlist(reply->products,10),
       save_drc_id = 0.0
      HEAD mi.value
       IF (md.cki="MUL.FRMLTN!*")
        prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->products,prod_cnt), reply->products[
        prod_cnt].item_id = mi.item_id,
        reply->products[prod_cnt].generic_name = mi.value, reply->products[prod_cnt].cki = md.cki
        IF (dgr.drc_group_reltn_id > 0)
         reply->products[prod_cnt].formulation_id = dgr.formulation_id
        ENDIF
        group_cnt = 0, save_drc_id = 0.0, group_cnt = (group_cnt+ 1),
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt), reply->products[prod_cnt].
        groups[group_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
        groups[group_cnt].dose_range_check_name = drc.dose_range_check_name,
        reply->products[prod_cnt].groups[group_cnt].drc_group_id = dfr.drc_group_id, save_drc_id =
        drc.dose_range_check_id, reply->products[prod_cnt].groups[group_cnt].has_facilities_assoc = 0
       ENDIF
      FOOT  mi.value
       IF (group_cnt > 0)
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt)
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->products,prod_cnt)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = "T"
     ENDIF
     CALL bederrorcheck("Error006 : grouper by product name starts with (new formulary)")
    ELSEIF ((request->starts_with_contains_flag=1))
     SELECT INTO "nl:"
      FROM med_identifier mi,
       medication_definition md,
       drc_group_reltn dgr,
       drc_form_reltn dfr,
       dose_range_check drc
      PLAN (mi
       WHERE cnvtupper(mi.value_key) IN (patstring(concat("*",trim(cnvtupper(trim(cnvtalphanum(
             request->drug_name),8)),5),"*")))
        AND mi.flex_type_cd IN (system_cd, sys_pkg_type_cd)
        AND mi.med_product_id=0.0
        AND mi.med_identifier_type_cd=desc_cd
        AND mi.active_ind=1)
       JOIN (md
       WHERE md.item_id=mi.item_id)
       JOIN (dgr
       WHERE md.cki > outerjoin(" ")
        AND md.cki=outerjoin("MUL.FRMLTN!*")
        AND dgr.formulation_id=outerjoin(cnvtint(substring(12,10,md.cki))))
       JOIN (dfr
       WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id)
        AND dfr.drc_group_id > outerjoin(0))
       JOIN (drc
       WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id))
      ORDER BY mi.value, dfr.drc_group_id
      HEAD REPORT
       prod_cnt = 0, group_cnt = 0, stat = alterlist(reply->products,10),
       save_drc_id = 0.0
      HEAD mi.value
       IF (md.cki="MUL.FRMLTN!*")
        prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->products,(prod_cnt+ 9)), reply->products[
        prod_cnt].item_id = mi.item_id,
        reply->products[prod_cnt].generic_name = mi.value, reply->products[prod_cnt].cki = md.cki
        IF (dgr.drc_group_reltn_id > 0)
         reply->products[prod_cnt].formulation_id = dgr.formulation_id
        ENDIF
        group_cnt = 0, save_drc_id = 0.0, group_cnt = (group_cnt+ 1),
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt), reply->products[prod_cnt].
        groups[group_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
        groups[group_cnt].dose_range_check_name = drc.dose_range_check_name,
        reply->products[prod_cnt].groups[group_cnt].drc_group_id = dfr.drc_group_id, save_drc_id =
        drc.dose_range_check_id, reply->products[prod_cnt].groups[group_cnt].has_facilities_assoc = 0
       ENDIF
      FOOT  mi.value
       IF (group_cnt > 0)
        stat = alterlist(reply->products[prod_cnt].groups,group_cnt)
       ENDIF
      FOOT REPORT
       stat = alterlist(reply->products,prod_cnt)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = "T"
     ENDIF
     CALL bederrorcheck("Error007 : grouper by product name contains (new formulary)")
    ENDIF
   ENDIF
   FOR (curr_product_cnt = 1 TO size(reply->products,5))
     SELECT INTO "nl:"
      FROM drc_facility_r dfreltn
      WHERE (dfreltn.drc_group_id=reply->products[curr_product_cnt].groups[1].drc_group_id)
       AND dfreltn.active_ind=1
      DETAIL
       IF (dfreltn.facility_cd=0.0)
        reply->products[curr_product_cnt].groups[1].dose_range_id_for_default = dfreltn
        .dose_range_check_id
       ENDIF
       IF (dfreltn.facility_cd > 0.0)
        IF ((reply->products[curr_product_cnt].groups[1].has_facilities_assoc=0.0))
         reply->products[curr_product_cnt].groups[1].has_facilities_assoc = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM drc_premise dp
      WHERE (dp.dose_range_check_id=reply->products[curr_product_cnt].groups[1].
      dose_range_id_for_default)
       AND dp.parent_ind=1
       AND dp.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET reply->products[curr_product_cnt].groups[1].has_content_defined_for_default = 1
     ELSE
      SET reply->products[curr_product_cnt].groups[1].has_content_defined_for_default = 0
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error008 : grouper by product name facility association")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getgroupersbysynonymname(dummyvar)
   DECLARE syn_cnt = i4 WITH protect, noconstant(0)
   DECLARE grp_cnt = i4 WITH protect, noconstant(0)
   DECLARE pharm_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=6000
     AND c.cdf_meaning="PHARMACY"
    DETAIL
     pharm_cd = c.code_value
    WITH nocounter
   ;end select
   IF ((request->starts_with_contains_flag=0))
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs,
      drc_group_reltn dgr,
      drc_form_reltn dfr,
      dose_range_check drc,
      drc_facility_r dfreltn
     PLAN (ocs
      WHERE cnvtupper(ocs.mnemonic) IN (patstring(concat(cnvtupper(trim(request->drug_name)),"*")))
       AND ocs.cki="MUL.ORD-SYN!*"
       AND ocs.catalog_type_cd=pharm_cd
       AND ocs.active_ind=1
       AND ocs.hide_flag=0)
      JOIN (dgr
      WHERE dgr.drug_synonym_id=outerjoin(cnvtint(substring(13,10,ocs.cki)))
       AND dgr.drc_group_reltn_id > outerjoin(0))
      JOIN (dfr
      WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id))
      JOIN (drc
      WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id)
       AND drc.dose_range_check_id > outerjoin(0.0))
      JOIN (dfreltn
      WHERE dfreltn.facility_cd=outerjoin(0.0)
       AND dfreltn.drc_group_id=outerjoin(dgr.drc_group_id))
     ORDER BY ocs.synonym_id, dgr.drc_group_reltn_id, dgr.drc_group_id
     HEAD ocs.synonym_id
      grp_cnt = 1, syn_cnt = (syn_cnt+ 1), stat = alterlist(reply->synonyms,syn_cnt),
      reply->synonyms[syn_cnt].drug_synonym_id = dgr.drug_synonym_id, reply->synonyms[syn_cnt].
      synonym_id = ocs.synonym_id, reply->synonyms[syn_cnt].mnemonic = ocs.mnemonic,
      reply->synonyms[syn_cnt].cki = ocs.cki, stat = alterlist(reply->synonyms[syn_cnt].groups,
       grp_cnt), reply->synonyms[syn_cnt].groups[grp_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id,
      reply->synonyms[syn_cnt].groups[grp_cnt].dose_range_check_name = drc.dose_range_check_name,
      reply->synonyms[syn_cnt].groups[grp_cnt].drc_group_id = dfr.drc_group_id, reply->synonyms[
      syn_cnt].groups[grp_cnt].has_facilities_assoc = 0
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error009 : grouper by synonym name starts with")
   ELSEIF ((request->starts_with_contains_flag=1))
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs,
      drc_group_reltn dgr,
      drc_form_reltn dfr,
      dose_range_check drc
     PLAN (ocs
      WHERE cnvtupper(ocs.mnemonic) IN (patstring(concat("*",cnvtupper(trim(request->drug_name)),"*")
       ))
       AND ocs.cki="MUL.ORD-SYN!*"
       AND ocs.catalog_type_cd=pharm_cd
       AND ocs.active_ind=1
       AND ocs.hide_flag=0)
      JOIN (dgr
      WHERE dgr.drug_synonym_id=outerjoin(cnvtint(substring(13,10,ocs.cki)))
       AND dgr.drc_group_reltn_id > outerjoin(0))
      JOIN (dfr
      WHERE dfr.drc_group_id=outerjoin(dgr.drc_group_id))
      JOIN (drc
      WHERE drc.dose_range_check_id=outerjoin(dfr.dose_range_check_id)
       AND drc.dose_range_check_id > outerjoin(0.0))
     ORDER BY ocs.synonym_id, dgr.drc_group_reltn_id, dgr.drc_group_id
     HEAD ocs.synonym_id
      grp_cnt = 1, syn_cnt = (syn_cnt+ 1), stat = alterlist(reply->synonyms,syn_cnt),
      reply->synonyms[syn_cnt].drug_synonym_id = dgr.drug_synonym_id, reply->synonyms[syn_cnt].
      synonym_id = ocs.synonym_id, reply->synonyms[syn_cnt].mnemonic = ocs.mnemonic,
      reply->synonyms[syn_cnt].cki = ocs.cki, stat = alterlist(reply->synonyms[syn_cnt].groups,
       grp_cnt), reply->synonyms[syn_cnt].groups[grp_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id,
      reply->synonyms[syn_cnt].groups[grp_cnt].dose_range_check_name = drc.dose_range_check_name,
      reply->synonyms[syn_cnt].groups[grp_cnt].drc_group_id = dfr.drc_group_id, reply->synonyms[
      syn_cnt].groups[grp_cnt].has_facilities_assoc = 0
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck("Error009 : grouper by synonym name contains")
   FOR (curr_synonym_cnt = 1 TO size(reply->synonyms,5))
     SELECT INTO "nl:"
      FROM drc_facility_r dfreltn
      WHERE (dfreltn.drc_group_id=reply->synonyms[curr_synonym_cnt].groups[1].drc_group_id)
       AND dfreltn.active_ind=1
      DETAIL
       IF (dfreltn.facility_cd=0.0)
        reply->synonyms[curr_synonym_cnt].groups[1].dose_range_id_for_default = dfreltn
        .dose_range_check_id
       ENDIF
       IF (dfreltn.facility_cd > 0.0)
        IF ((reply->synonyms[curr_synonym_cnt].groups[1].has_facilities_assoc=0.0))
         reply->synonyms[curr_synonym_cnt].groups[1].has_facilities_assoc = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM drc_premise dp
      WHERE (dp.dose_range_check_id=reply->synonyms[curr_synonym_cnt].groups[1].
      dose_range_id_for_default)
       AND dp.parent_ind=1
       AND dp.active_ind=1
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET reply->synonyms[curr_synonym_cnt].groups[1].has_content_defined_for_default = 1
     ELSE
      SET reply->synonyms[curr_synonym_cnt].groups[1].has_content_defined_for_default = 0
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error010 : grouper by synonym name facility association")
   RETURN(0)
 END ;Subroutine
END GO
