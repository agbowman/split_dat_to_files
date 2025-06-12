CREATE PROGRAM bed_ens_org_org_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD allfacilities
 RECORD allfacilities(
   1 facilities[*]
     2 org_org_reltn_id = f8
 )
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
 IF ( NOT (validate(cs48_active_cd)))
  DECLARE cs48_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 ENDIF
 IF ( NOT (validate(cs48_inactive_cd)))
  DECLARE cs48_inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 ENDIF
 DECLARE createorupdatemaxbedallocation(dummyvar=i2) = i2
 DECLARE markfacilitiesashistorical(dummyvar=i2) = i2
 DECLARE markfacilitiesotherthanhistoricalasactive(dummyvar=i2) = i2
 DECLARE createorupdateprimaryfacility(dummyvar=i2) = i2
 DECLARE addorremovesubregioncatchmentareareltn(dummyvar=i2) = i2
 IF ( NOT (createorupdatemaxbedallocation(0)))
  CALL bederror("Could not create/update maximum bed allocation.")
 ENDIF
 IF ( NOT (markfacilitiesashistorical(0)))
  CALL bederror("Could not update facilities as historical.")
 ENDIF
 IF ( NOT (markfacilitiesotherthanhistoricalasactive(0)))
  CALL bederror("Could not update facilities as active.")
 ENDIF
 IF ( NOT (createorupdateprimaryfacility(0)))
  CALL bederror("Could not create/update primary facility relationship.")
 ENDIF
 CALL addorremovesubregioncatchmentareareltn(0)
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE createorupdatemaxbedallocation(dummyvar)
   CALL bedlogmessage("createOrUpdateMaxBedAllocation","Entering")
   DECLARE info_type_code = f8 WITH noconstant(0.0), protect
   DECLARE org_info_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=355
      AND c.cdf_meaning="BEDALLOCATN"
      AND c.active_ind=1)
    DETAIL
     info_type_code = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_info i
    PLAN (i
     WHERE (i.organization_id=request->organization_id)
      AND i.info_type_cd=info_type_code)
    ORDER BY i.org_info_id
    HEAD i.org_info_id
     org_info_id = i.org_info_id
    WITH nocounter
   ;end select
   IF (org_info_id > 0)
    UPDATE  FROM org_info i
     SET i.value_numeric = request->max_bed_allocation, i.updt_dt_tm = cnvtdatetime(curdate,curtime),
      i.updt_applctx = reqinfo->updt_applctx,
      i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt+ 1), i.updt_task = reqinfo->updt_task
     WHERE (i.organization_id=request->organization_id)
      AND i.info_type_cd=info_type_code
     WITH nocounter
    ;end update
   ELSE
    SELECT INTO "nl:"
     y = seq(organization_seq,nextval)
     FROM dual
     DETAIL
      org_info_id = cnvtreal(y)
     WITH format, counter
    ;end select
    INSERT  FROM org_info i
     SET i.org_info_id = org_info_id, i.value_numeric = request->max_bed_allocation, i
      .organization_id = request->organization_id,
      i.info_type_cd = info_type_code, i.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), i
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      i.active_ind = 1, i.active_status_cd = cs48_active_cd, i.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      i.active_status_prsnl_id = reqinfo->updt_id, i.updt_dt_tm = cnvtdatetime(curdate,curtime), i
      .updt_applctx = reqinfo->updt_applctx,
      i.updt_id = reqinfo->updt_id, i.updt_cnt = 0, i.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("createOrUpdateMaxBedAllocation","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE markfacilitiesashistorical(dummyvar)
   CALL bedlogmessage("markFacilitiesAsHistorical","Entering")
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE primary_facility_code = f8 WITH protect, noconstant(0.0)
   UPDATE  FROM org_org_reltn i
    SET i.active_ind = 0, i.active_status_cd = cs48_inactive_cd, i.active_status_dt_tm = cnvtdatetime
     (curdate,curtime),
     i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
     i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt+
     1),
     i.updt_task = reqinfo->updt_task
    WHERE expand(num,1,size(request->historical_facilities,5),i.org_org_reltn_id,request->
     historical_facilities[num].org_org_reltn_id)
    WITH nocounter
   ;end update
   SET num = 0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=4038010
      AND c.cdf_meaning="CATCHPRIMFAC"
      AND c.active_ind=1)
    DETAIL
     primary_facility_code = c.code_value
    WITH nocounter
   ;end select
   UPDATE  FROM org_org_reltn_info i
    SET i.active_ind = 0, i.active_status_cd = cs48_inactive_cd, i.active_status_dt_tm = cnvtdatetime
     (curdate,curtime),
     i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
     i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt+
     1),
     i.updt_task = reqinfo->updt_task
    WHERE i.org_org_reltn_info_type_cd=primary_facility_code
     AND expand(num,1,size(request->historical_facilities,5),i.org_org_reltn_id,request->
     historical_facilities[num].org_org_reltn_id)
    WITH nocounter
   ;end update
   CALL bedlogmessage("markFacilitiesAsHistorical","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE markfacilitiesotherthanhistoricalasactive(dummyvar)
   CALL bedlogmessage("markFacilitiesOtherThanHistoricalAsActive","Entering")
   SET stat = initrec(allfacilities)
   DECLARE faccnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE org_org_reltn_cd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=369
      AND c.cdf_meaning="CA_FAC")
    DETAIL
     org_org_reltn_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_org_reltn i
    PLAN (i
     WHERE (i.organization_id=request->organization_id)
      AND i.org_org_reltn_cd=org_org_reltn_cd
      AND i.active_ind=0
      AND i.active_status_cd=cs48_inactive_cd)
    ORDER BY i.org_org_reltn_id
    DETAIL
     faccnt = (faccnt+ 1), stat = alterlist(allfacilities->facilities,faccnt), allfacilities->
     facilities[faccnt].org_org_reltn_id = i.org_org_reltn_id
    WITH nocounter
   ;end select
   FOR (histcnt = 1 TO size(allfacilities->facilities,5))
    SET pos = locateval(num,1,size(request->historical_facilities,5),allfacilities->facilities[
     histcnt].org_org_reltn_id,request->historical_facilities[num].org_org_reltn_id)
    IF (pos=0)
     UPDATE  FROM org_org_reltn i
      SET i.active_ind = 1, i.active_status_cd = cs48_active_cd, i.active_status_dt_tm = cnvtdatetime
       (curdate,curtime),
       i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
       i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt
       + 1),
       i.updt_task = reqinfo->updt_task
      WHERE (i.org_org_reltn_id=allfacilities->facilities[histcnt].org_org_reltn_id)
      WITH nocounter
     ;end update
    ENDIF
   ENDFOR
   CALL bedlogmessage("markFacilitiesOtherThanHistoricalAsActive","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE createorupdateprimaryfacility(dummyvar)
   CALL bedlogmessage("createOrUpdatePrimaryFacility","Entering")
   DECLARE primary_facility_code = f8 WITH noconstant(0.0), protect
   DECLARE org_org_reltn_info_id = f8 WITH noconstant(0.0), protect
   DECLARE active_ind = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=4038010
      AND c.cdf_meaning="CATCHPRIMFAC"
      AND c.active_ind=1)
    DETAIL
     primary_facility_code = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_org_reltn_info i
    PLAN (i
     WHERE (i.org_org_reltn_id=request->primary_facility.org_org_reltn_id)
      AND i.org_org_reltn_info_type_cd=primary_facility_code)
    ORDER BY i.org_org_reltn_info_id
    HEAD i.org_org_reltn_info_id
     org_org_reltn_info_id = i.org_org_reltn_info_id, active_ind = i.active_ind
    WITH nocounter
   ;end select
   IF (org_org_reltn_info_id > 0
    AND active_ind=0)
    CALL markallfacilitiesasnonprimary(0)
    UPDATE  FROM org_org_reltn_info i
     SET i.active_ind = 1, i.active_status_cd = cs48_active_cd, i.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
      i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt
      + 1),
      i.updt_task = reqinfo->updt_task
     WHERE i.org_org_reltn_info_id=org_org_reltn_info_id
     WITH nocounter
    ;end update
   ELSEIF (org_org_reltn_info_id=0)
    CALL markallfacilitiesasnonprimary(0)
    SELECT INTO "nl:"
     y = seq(organization_seq,nextval)
     FROM dual
     DETAIL
      org_org_reltn_info_id = cnvtreal(y)
     WITH format, counter
    ;end select
    INSERT  FROM org_org_reltn_info i
     SET i.org_org_reltn_info_id = org_org_reltn_info_id, i.org_org_reltn_id = request->
      primary_facility.org_org_reltn_id, i.org_org_reltn_info_type_cd = primary_facility_code,
      i.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), i.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), i.active_ind = 1,
      i.active_status_cd = cs48_active_cd, i.active_status_dt_tm = cnvtdatetime(curdate,curtime), i
      .active_status_prsnl_id = reqinfo->updt_id,
      i.updt_dt_tm = cnvtdatetime(curdate,curtime), i.updt_applctx = reqinfo->updt_applctx, i.updt_id
       = reqinfo->updt_id,
      i.updt_cnt = 0, i.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("createOrUpdatePrimaryFacility","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE addorremovesubregioncatchmentareareltn(dummyvar)
   CALL bedlogmessage("addOrRemoveSubRegionCatchmentAreaReltn","Entering")
   DECLARE org_org_reltn_id = f8 WITH protect, noconstant(0.0)
   DECLARE org_org_reltn_cd = f8 WITH protect, noconstant(0.0)
   DECLARE subcnt = i4 WITH protect, noconstant(0)
   DECLARE active_ind = i2 WITH protect, noconstant(0)
   DECLARE active_cd = f8 WITH protect, noconstant(0.0)
   DECLARE end_effective_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00.00")
    )
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=369
      AND c.cdf_meaning="CA_SUB-REG")
    DETAIL
     org_org_reltn_cd = c.code_value
    WITH nocounter
   ;end select
   FOR (subcnt = 1 TO size(request->sub_regions,5))
     SET org_org_reltn_id = 0
     SELECT INTO "nl:"
      FROM org_org_reltn oor
      PLAN (oor
       WHERE (oor.related_org_id=request->sub_regions[subcnt].related_org_id)
        AND (oor.organization_id=request->organization_id)
        AND oor.org_org_reltn_cd=org_org_reltn_cd)
      DETAIL
       org_org_reltn_id = oor.org_org_reltn_id, active_ind = oor.active_ind
      WITH nocounter
     ;end select
     IF (org_org_reltn_id > 0
      AND (request->sub_regions[subcnt].active_ind != active_ind))
      IF ((request->sub_regions[subcnt].active_ind=1))
       SET active_cd = cs48_active_cd
       SET end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      ELSE
       SET active_cd = cs48_inactive_cd
       SET end_effective_dt_tm = cnvtdatetime(curdate,curtime)
      ENDIF
      UPDATE  FROM org_org_reltn i
       SET i.active_ind = request->sub_regions[subcnt].active_ind, i.active_status_cd = active_cd, i
        .active_status_dt_tm = cnvtdatetime(curdate,curtime),
        i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(
         end_effective_dt_tm), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
        i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i
        .updt_cnt+ 1),
        i.updt_task = reqinfo->updt_task
       WHERE i.org_org_reltn_id=org_org_reltn_id
       WITH nocounter
      ;end update
     ELSEIF (org_org_reltn_id=0)
      SELECT INTO "nl:"
       y = seq(organization_seq,nextval)
       FROM dual
       DETAIL
        org_org_reltn_id = cnvtreal(y)
       WITH format, counter
      ;end select
      INSERT  FROM org_org_reltn oor
       SET oor.org_org_reltn_id = org_org_reltn_id, oor.organization_id = request->organization_id,
        oor.org_org_reltn_cd = org_org_reltn_cd,
        oor.related_org_id = request->sub_regions[subcnt].related_org_id, oor.active_ind = 1, oor
        .active_status_cd = cs48_active_cd,
        oor.active_status_dt_tm = cnvtdatetime(curdate,curtime), oor.active_status_prsnl_id = reqinfo
        ->updt_id, oor.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
        oor.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), oor.updt_dt_tm =
        cnvtdatetime(curdate,curtime), oor.updt_applctx = reqinfo->updt_applctx,
        oor.updt_id = reqinfo->updt_id, oor.updt_cnt = 0, oor.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
   CALL bedlogmessage("addOrRemoveSubRegionCatchmentAreaReltn","Exiting")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE markallfacilitiesasnonprimary(dummyvar)
   CALL bedlogmessage("markAllFacilitiesAsNonPrimary","Entering")
   SET stat = initrec(allfacilities)
   DECLARE primary_facility_code = f8 WITH noconstant(0.0), protect
   DECLARE org_org_reltn_cd = f8 WITH protect, noconstant(0.0)
   DECLARE faccnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=4038010
      AND c.cdf_meaning="CATCHPRIMFAC"
      AND c.active_ind=1)
    DETAIL
     primary_facility_code = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=369
      AND c.cdf_meaning="CA_FAC")
    DETAIL
     org_org_reltn_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_org_reltn i
    PLAN (i
     WHERE (i.organization_id=request->organization_id)
      AND i.org_org_reltn_cd=org_org_reltn_cd
      AND i.active_ind=1)
    ORDER BY i.org_org_reltn_id
    DETAIL
     faccnt = (faccnt+ 1), stat = alterlist(allfacilities->facilities,faccnt), allfacilities->
     facilities[faccnt].org_org_reltn_id = i.org_org_reltn_id
    WITH nocounter
   ;end select
   UPDATE  FROM org_org_reltn_info i
    SET i.active_ind = 0, i.active_status_cd = cs48_inactive_cd, i.active_status_dt_tm = cnvtdatetime
     (curdate,curtime),
     i.active_status_prsnl_id = reqinfo->updt_id, i.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime), i.updt_dt_tm = cnvtdatetime(curdate,curtime),
     i.updt_applctx = reqinfo->updt_applctx, i.updt_id = reqinfo->updt_id, i.updt_cnt = (i.updt_cnt+
     1),
     i.updt_task = reqinfo->updt_task
    WHERE i.org_org_reltn_info_type_cd=primary_facility_code
     AND expand(num,1,size(allfacilities->facilities,5),i.org_org_reltn_id,allfacilities->facilities[
     num].org_org_reltn_id)
    WITH nocounter
   ;end update
   CALL bedlogmessage("markAllFacilitiesAsNonPrimary","Exiting")
   RETURN(true)
 END ;Subroutine
END GO
