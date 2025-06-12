CREATE PROGRAM bed_get_drc_group:dba
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
 FREE SET rows
 RECORD rows(
   1 qual[*]
     2 parent_premise_id = f8
     2 routes_concat_disp = vc
     2 routes_concat_physical_sort_key = i4
     2 clinical_conditions = vc
     2 clinical_cond_physical_sort_key = i4
     2 pma_operator_sort_key = i4
     2 pma_physical_sort_key = i4
     2 pma_field1 = f8
     2 pma_field2 = f8
     2 hepatic_physical_sort_key = i2
     2 crcl_operator_sort_key = i4
     2 crcl_unit_of_measure_sort_key = i1
     2 crcl_physical_sort_key = i4
     2 crcl_field1 = f8
     2 crcl_field2 = f8
     2 age_operator_sort_key = i4
     2 age_physical_sort_key = i4
     2 age_field1 = f8
     2 age_field2 = f8
     2 weight_operator_sort_key = i4
     2 weight_physical_sort_key = i4
     2 weight_field1 = f8
     2 weight_field2 = f8
     2 overlap_sort_key = i4
     2 gap_sort_key = i4
     2 mark_age_overlap = i2
     2 mark_weight_overlap = i2
     2 mark_crcl_overlap = i2
     2 mark_pma_overlap = i2
     2 mark_age_gap = i2
     2 mark_weight_gap = i2
     2 sorted_routes[*]
       3 drc_premise_list_id = f8
       3 parent_entity_id = f8
       3 route_disp = vc
       3 active_ind = i2
 )
 RECORD sorted_rows(
   1 qual[*]
     2 parent_premise_id = f8
 )
 FREE SET prev_row
 RECORD prev_row(
   1 parent_premise_id = f8
   1 routes_concat_physical_sort_key = i4
   1 clinical_cond_physical_sort_key = i4
   1 pma_operator_sort_key = i4
   1 pma_field1 = f8
   1 pma_field2 = f8
   1 hepatic_physical_sort_key = i2
   1 crcl_unit_of_measure_sort_key = i1
   1 crcl_operator_sort_key = i4
   1 crcl_field1 = f8
   1 crcl_field2 = f8
   1 age_operator_sort_key = i4
   1 age_field1 = f8
   1 age_field2 = f8
   1 weight_operator_sort_key = i4
   1 weight_field1 = f8
   1 weight_field2 = f8
   1 overlap_sort_key = i4
   1 gap_sort_key = i4
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
 DECLARE age = i2 WITH protect, constant(1)
 DECLARE routes = i2 WITH protect, constant(2)
 DECLARE weight = i2 WITH protect, constant(3)
 DECLARE crcl = i2 WITH protect, constant(4)
 DECLARE pma = i2 WITH protect, constant(5)
 DECLARE hepatic = i2 WITH protect, constant(6)
 DECLARE clinical_condition = i2 WITH protect, constant(7)
 DECLARE none = i2 WITH protect, constant(0)
 DECLARE no_overlap = i2 WITH protect, constant(0)
 DECLARE has_overlap = i2 WITH protect, constant(1)
 DECLARE same = i2 WITH protect, constant(2)
 DECLARE no_gap = i2 WITH protect, constant(0)
 DECLARE has_gap = i2 WITH protect, constant(1)
 DECLARE less_than_key = i2 WITH protect, constant(- (3))
 DECLARE between_key = i2 WITH protect, constant(- (2))
 DECLARE greater_equal_key = i2 WITH protect, constant(- (1))
 DECLARE no_operator_key = i2 WITH protect, constant(0)
 DECLARE no_hepatic_key = i2 WITH protect, constant(0)
 DECLARE yes_hepatic_key = i2 WITH protect, constant(- (1))
 DECLARE no_condition_key = i2 WITH protect, constant(0)
 DECLARE unit_ml_min_1_73m2_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!2570188158"))
 DECLARE unit_ml_min_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2738"))
 DECLARE unit_ml_min_1_73m2_key = i1 WITH protect, constant(1)
 DECLARE unit_ml_min_key = i1 WITH protect, constant(10)
 DECLARE convert_to_days(number=f8,units_code=f8,from_or_to=i2) = null
 DECLARE convert_to_kgs(number=f8,units_code=f8,operator=i2) = null
 DECLARE calculateoperatorsortkey(operator_type=i2) = i2
 DECLARE calculatecrclunitofmeasuresortkey(unit_type=f8) = i1
 DECLARE calculateyesnosortkey(operator_type=f8) = i2
 DECLARE calculateoperatorandfieldbasedsortkey(field_type=i2) = null
 DECLARE ranktherowsforphysicalsorting(dummyvar=i2) = null
 DECLARE compareiftworowsareinsamebucketforoverlap(curr_seq=i4) = null
 DECLARE compareiftworowsareinsamebucketforagegap(curr_seq=i4) = null
 DECLARE compareiftworowsareinsamebucketforweightgap(curr_seq=i4) = null
 DECLARE compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq=i4,type=i2) = null
 DECLARE markoverlap(type=i2) = i2
 DECLARE markrowsforoverlap(dummyvar=i2) = null
 DECLARE markrowsforagegap(dummyvar=i2) = null
 DECLARE markrowsforweightgap(dummyvar=i2) = null
 DECLARE number_of_days = f8 WITH public, noconstant(0.0)
 DECLARE number_of_hrs = f8 WITH public, noconstant(0.0)
 DECLARE number_of_kgs = f8 WITH public, noconstant(0.0)
 DECLARE age_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE pma_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE crcl_overlap_flag = i2 WITH public, noconstant(0)
 DECLARE weight_overlap_flag = i2 WITH public, noconstant(0)
 SUBROUTINE convert_to_days(number,units_code,from_or_to)
   SET number_of_days = 0.0
   SET number_of_hrs = 0.0
   IF (units_code=years
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 360.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number=2.0)
    SET number_of_days = 720.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number >= 3.0)
    SET number_of_days = round((365.0 * number),1)
    SET number_of_hrs = round(((365.0 * number) * 24.0),2)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 359.9
    SET number_of_hrs = ((360.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=2.0)
    SET number_of_days = 719.9
    SET number_of_hrs = ((720.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number >= 3.0)
    SET number_of_days = round(((365.0 * number) - 0.1),1)
    SET number_of_hrs = round((((365.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 28.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number >= 2.0)
    SET number_of_days = round((30.0 * number),1)
    SET number_of_hrs = round(((30.0 * number) * 24.0),2)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 27.9
    SET number_of_hrs = ((28.0 * 24.0) - 0.01)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number >= 2.0)
    SET number_of_days = round(((30.0 * number) - 0.1),1)
    SET number_of_hrs = round((((30.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=weeks
    AND from_or_to=1)
    SET number_of_days = round((7.0 * number),1)
    SET number_of_hrs = round(((7.0 * number) * 24.0),2)
   ELSEIF (units_code=weeks
    AND from_or_to=0)
    SET number_of_days = round(((7.0 * number) - 0.1),1)
    SET number_of_hrs = round((((7.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=days
    AND from_or_to=1)
    SET number_of_days = round(number,1)
    SET number_of_hrs = round((number * 24.0),2)
   ELSEIF (units_code=days
    AND from_or_to=0)
    SET number_of_days = round((number - 0.1),1)
    SET number_of_hrs = round(((number * 24.0) - 0.01),2)
   ELSEIF (units_code=hours
    AND from_or_to=1)
    SET number_of_days = round((number/ 24.0),1)
    SET number_of_hrs = round(number,2)
   ELSEIF (units_code=hours
    AND from_or_to=0)
    SET number_of_days = round(((number/ 24.0) - 0.1),1)
    SET number_of_hrs = round((number - 0.01),2)
   ELSE
    SET number_of_days = 0.0
   ENDIF
   CALL bederrorcheck("Error 013: Failed to convert to days")
 END ;Subroutine
 SUBROUTINE convert_to_kgs(number,units_code,operator)
   SET number_of_kgs = 0.0
   IF (units_code=kg
    AND operator=1)
    SET number_of_kgs = round((number - 0.00001),5)
   ELSEIF (units_code=kg
    AND ((operator=3) OR (operator=4)) )
    SET number_of_kgs = round(number,5)
   ELSEIF (units_code=kg
    AND operator=2)
    SET number_of_kgs = round((number+ 0.00001),5)
   ELSEIF (units_code=gram
    AND operator=1)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 1000.0) - 0.00001),5)
    ENDIF
   ELSEIF (units_code=gram
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((number/ 1000.0),5)
    ENDIF
   ELSEIF (units_code=gram
    AND operator=2)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 1000.0)+ 0.00001),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND operator=1)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((((number/ 16.0) * 0.4545) - 0.00001),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round(((number/ 16.0) * 0.4545),5)
    ENDIF
   ELSEIF (units_code=ounce
    AND operator=2)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((((number/ 16.0) * 0.4545)+ 0.00001),5)
    ENDIF
   ELSEIF (units_code=lbs
    AND operator=1)
    SET number_of_kgs = round(((number * 0.4545) - 0.00001),5)
   ELSEIF (units_code=lbs
    AND ((operator=3) OR (operator=4)) )
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = round((number * 0.4545),5)
    ENDIF
   ELSEIF (units_code=lbs
    AND operator=2)
    SET number_of_kgs = round(((number * 0.4545)+ 0.00001),5)
   ELSE
    SET number_of_kgs = 0.0
   ENDIF
   CALL bederrorcheck("Error 014: Failed to convert to kgs")
 END ;Subroutine
 SUBROUTINE calculateoperatorsortkey(operator_type)
  CASE (operator_type)
   OF 1:
    RETURN(less_than_key)
   OF 6:
    RETURN(between_key)
   OF 4:
    RETURN(greater_equal_key)
  ENDCASE
  CALL bederrorcheck("Error 015: Wrong operator_type")
 END ;Subroutine
 SUBROUTINE calculateyesnosortkey(operator_type)
  CASE (operator_type)
   OF 0.0:
    RETURN(no_hepatic_key)
   OF 1.0:
    RETURN(yes_hepatic_key)
  ENDCASE
  CALL bederrorcheck("Error 016: Invalid Yes/No operator.")
 END ;Subroutine
 SUBROUTINE ranktherowsforphysicalsorting(dummyvar)
   CALL calculateoperatorandfieldbasedsortkey(routes)
   CALL calculateoperatorandfieldbasedsortkey(age)
   CALL calculateoperatorandfieldbasedsortkey(pma)
   CALL calculateoperatorandfieldbasedsortkey(crcl)
   CALL calculateoperatorandfieldbasedsortkey(weight)
   CALL calculateoperatorandfieldbasedsortkey(clinical_condition)
   SET stat = alterlist(sorted_rows->qual,size(rows->qual,5))
   IF (size(sorted_rows->qual,5) > 0)
    SET i = 0
    SELECT INTO "NL:"
     rows->qual[d1.seq].parent_premise_id
     FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
     PLAN (d1)
     ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].gap_sort_key
       DESC, rows->qual[d1.seq].age_physical_sort_key,
      rows->qual[d1.seq].weight_physical_sort_key, rows->qual[d1.seq].pma_physical_sort_key, rows->
      qual[d1.seq].clinical_cond_physical_sort_key,
      rows->qual[d1.seq].hepatic_physical_sort_key, rows->qual[d1.seq].crcl_physical_sort_key
     DETAIL
      i = (i+ 1), sorted_rows->qual[i].parent_premise_id = rows->qual[d1.seq].parent_premise_id
     WITH nocounter
    ;end select
    CALL bederrorcheck(
     "Error 017: Error while ranking the rows physically based on the physical_sort_keys")
   ENDIF
 END ;Subroutine
 SUBROUTINE calculateoperatorandfieldbasedsortkey(field_type)
  DECLARE previous_concat_route_disp = vc
  IF (size(rows->qual,5) > 0)
   CASE (field_type)
    OF routes:
     SET concat_route_disp_key = 0
     SET previous_concat_route_disp = ""
     SET route_concat_disp = ""
     SELECT INTO "NL:"
      route_concat_disp = substring(1,1000,trim(rows->qual[d1.seq].routes_concat_disp,7))
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY route_concat_disp
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].routes_concat_disp=previous_concat_route_disp)))
        concat_route_disp_key = (concat_route_disp_key+ 1), previous_concat_route_disp = rows->qual[
        d1.seq].routes_concat_disp
       ENDIF
       rows->qual[d1.seq].routes_concat_physical_sort_key = concat_route_disp_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to clinical conditions")
    OF clinical_condition:
     SET clinical_cond_key = no_condition_key
     SET previous_clic_cond = ""
     SET clinical_condition_temp = ""
     SELECT INTO "NL:"
      clinical_condition_temp = substring(1,1000,trim(rows->qual[d1.seq].clinical_conditions,7))
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1
       WHERE  NOT (trim(rows->qual[d1.seq].clinical_conditions,7) IN ("", null)))
      ORDER BY clinical_condition_temp DESC
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].clinical_conditions=previous_clic_cond)))
        clinical_cond_key = (clinical_cond_key - 1), previous_clic_cond = rows->qual[d1.seq].
        clinical_conditions
       ENDIF
       rows->qual[d1.seq].clinical_cond_physical_sort_key = clinical_cond_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to clinical conditions")
    OF pma:
     SET pma_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].pma_operator_sort_key, rows->qual[d1.seq].pma_field1, rows->qual[d1.seq].
      pma_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].pma_operator_sort_key, rows->qual[d1.seq].pma_field1, rows->qual[d1
       .seq].pma_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].pma_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].pma_field1=previous_row_field1)
        AND (rows->qual[d1.seq].pma_field2=previous_row_field2)))
        pma_key = (pma_key+ 1), previous_operator_value = rows->qual[d1.seq].pma_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].pma_field1,
        previous_row_field2 = rows->qual[d1.seq].pma_field2
       ENDIF
       rows->qual[d1.seq].pma_physical_sort_key = pma_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to PMA")
    OF crcl:
     SET crcl_key = 0
     SET previous_unit_of_measure_value = - (128)
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].crcl_unit_of_measure_sort_key, rows->qual[d1.seq].crcl_operator_sort_key,
      rows->qual[d1.seq].crcl_field1,
      rows->qual[d1.seq].crcl_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].crcl_unit_of_measure_sort_key, rows->qual[d1.seq].
       crcl_operator_sort_key, rows->qual[d1.seq].crcl_field1,
       rows->qual[d1.seq].crcl_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].crcl_unit_of_measure_sort_key=previous_unit_of_measure_value)
        AND (rows->qual[d1.seq].crcl_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].crcl_field1=previous_row_field1)
        AND (rows->qual[d1.seq].crcl_field2=previous_row_field2)))
        crcl_key = (crcl_key+ 1), previous_unit_of_measure_value = rows->qual[d1.seq].
        crcl_unit_of_measure_sort_key, previous_operator_value = rows->qual[d1.seq].
        crcl_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].crcl_field1, previous_row_field2 = rows->qual[d1.seq
        ].crcl_field2
       ENDIF
       rows->qual[d1.seq].crcl_physical_sort_key = crcl_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to CrCl")
    OF age:
     SET age_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].age_operator_sort_key, rows->qual[d1.seq].age_field1, rows->qual[d1.seq].
      age_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].age_operator_sort_key, rows->qual[d1.seq].age_field1, rows->qual[d1
       .seq].age_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].age_field1=previous_row_field1)
        AND (rows->qual[d1.seq].age_field2=previous_row_field2)))
        age_key = (age_key+ 1), previous_operator_value = rows->qual[d1.seq].age_operator_sort_key,
        previous_row_field1 = rows->qual[d1.seq].age_field1,
        previous_row_field2 = rows->qual[d1.seq].age_field2
       ENDIF
       rows->qual[d1.seq].age_physical_sort_key = age_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to Age")
    OF weight:
     SET weight_key = 0
     SET previous_operator_value = - (5)
     SET previous_row_field1 = - (5.0)
     SET previous_row_field2 = - (5.0)
     SELECT INTO "NL:"
      rows->qual[d1.seq].weight_operator_sort_key, rows->qual[d1.seq].weight_field1, rows->qual[d1
      .seq].weight_field2
      FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
      PLAN (d1)
      ORDER BY rows->qual[d1.seq].weight_operator_sort_key, rows->qual[d1.seq].weight_field1, rows->
       qual[d1.seq].weight_field2
      DETAIL
       IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=previous_operator_value)
        AND (rows->qual[d1.seq].weight_field1=previous_row_field1)
        AND (rows->qual[d1.seq].weight_field2=previous_row_field2)))
        weight_key = (weight_key+ 1), previous_operator_value = rows->qual[d1.seq].
        weight_operator_sort_key, previous_row_field1 = rows->qual[d1.seq].weight_field1,
        previous_row_field2 = rows->qual[d1.seq].weight_field2
       ENDIF
       rows->qual[d1.seq].weight_physical_sort_key = weight_key
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error 018: Error while assigning physical sort key to Weight")
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforoverlap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   IF ((rows->qual[curr_seq].overlap_sort_key=prev_row->overlap_sort_key)
    AND (rows->qual[curr_seq].routes_concat_physical_sort_key=prev_row->
   routes_concat_physical_sort_key)
    AND (rows->qual[curr_seq].clinical_cond_physical_sort_key=prev_row->
   clinical_cond_physical_sort_key)
    AND (rows->qual[curr_seq].hepatic_physical_sort_key=prev_row->hepatic_physical_sort_key)
    AND (rows->qual[curr_seq].crcl_unit_of_measure_sort_key=prev_row->crcl_unit_of_measure_sort_key))
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,age)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,pma)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,weight)
    CALL compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,crcl)
    SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[
     index].parent_premise_id)
    SET rows->qual[prev_index].mark_age_overlap = markoverlap(age)
    SET rows->qual[prev_index].mark_pma_overlap = markoverlap(pma)
    SET rows->qual[prev_index].mark_weight_overlap = markoverlap(weight)
    SET rows->qual[prev_index].mark_crcl_overlap = markoverlap(crcl)
   ENDIF
   CALL bederrorcheck("Error 020: Error while compare adjacent rows for Overlap.")
 END ;Subroutine
 SUBROUTINE compareprevrowwithcurrrowanddetermineifsameorpartialornooverlap(curr_seq,type)
  CASE (type)
   OF age:
    IF ((prev_row->age_operator_sort_key=rows->qual[curr_seq].age_operator_sort_key))
     CASE (prev_row->age_operator_sort_key)
      OF between_key:
       IF ((prev_row->age_field1=rows->qual[curr_seq].age_field1)
        AND (prev_row->age_field2=rows->qual[curr_seq].age_field2))
        SET age_overlap_flag = same
       ELSEIF ((( NOT ((prev_row->age_field1 < rows->qual[curr_seq].age_field2))) OR ( NOT ((prev_row
       ->age_field2 > rows->qual[curr_seq].age_field1)))) )
        SET age_overlap_flag = no_overlap
       ELSE
        SET age_overlap_flag = has_overlap
       ENDIF
      ELSE
       IF ((prev_row->age_field1=rows->qual[curr_seq].age_field1))
        SET age_overlap_flag = same
       ELSE
        SET age_overlap_flag = has_overlap
       ENDIF
     ENDCASE
    ELSE
     CASE (prev_row->age_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->age_field1 > rows->qual[curr_seq].age_field1))
        SET age_overlap_flag = has_overlap
       ELSE
        SET age_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].age_operator_sort_key=greater_equal_key))
        IF ((prev_row->age_field2 > rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].age_operator_sort_key=less_than_key))
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field2))
         SET age_overlap_flag = has_overlap
        ELSE
         SET age_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   OF pma:
    IF ((prev_row->pma_operator_sort_key=rows->qual[curr_seq].pma_operator_sort_key))
     IF ( NOT ((prev_row->pma_operator_sort_key=no_operator_key)))
      CASE (prev_row->pma_operator_sort_key)
       OF between_key:
        IF ((prev_row->pma_field1=rows->qual[curr_seq].pma_field1)
         AND (prev_row->pma_field2=rows->qual[curr_seq].pma_field2))
         SET pma_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field2))) OR ( NOT ((
        prev_row->pma_field2 > rows->qual[curr_seq].pma_field1)))) )
         SET pma_overlap_flag = no_overlap
        ELSE
         SET pma_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1=rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = same
        ELSE
         SET pma_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET pma_overlap_flag = same
     ENDIF
    ELSE
     CASE (prev_row->pma_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->pma_field1 > rows->qual[curr_seq].pma_field1))
        SET pma_overlap_flag = has_overlap
       ELSE
        SET pma_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].pma_operator_sort_key=greater_equal_key))
        IF ((prev_row->pma_field2 > rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].pma_operator_sort_key=less_than_key))
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field1))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->pma_field1 < rows->qual[curr_seq].pma_field2))
         SET pma_overlap_flag = has_overlap
        ELSE
         SET pma_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   OF weight:
    IF ((prev_row->weight_operator_sort_key=rows->qual[curr_seq].weight_operator_sort_key))
     IF ( NOT ((prev_row->weight_operator_sort_key=no_operator_key)))
      CASE (prev_row->weight_operator_sort_key)
       OF between_key:
        IF ((prev_row->weight_field1=rows->qual[curr_seq].weight_field1)
         AND (prev_row->weight_field2=rows->qual[curr_seq].weight_field2))
         SET weight_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field2))) OR ( NOT ((
        prev_row->weight_field2 > rows->qual[curr_seq].weight_field1)))) )
         SET weight_overlap_flag = no_overlap
        ELSE
         SET weight_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->weight_field1=rows->qual[curr_seq].weight_field1))
         SET weight_overlap_flag = same
        ELSE
         SET weight_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET weight_overlap_flag = same
     ENDIF
    ELSE
     IF ((((prev_row->weight_operator_sort_key=no_operator_key)) OR ((rows->qual[curr_seq].
     weight_operator_sort_key=no_operator_key))) )
      SET weight_overlap_flag = has_overlap
     ELSE
      CASE (prev_row->weight_operator_sort_key)
       OF less_than_key:
        IF ((prev_row->weight_field1 > rows->qual[curr_seq].weight_field1))
         SET weight_overlap_flag = has_overlap
        ELSE
         SET weight_overlap_flag = no_overlap
        ENDIF
       OF between_key:
        IF ((rows->qual[curr_seq].weight_operator_sort_key=greater_equal_key))
         IF ((prev_row->weight_field2 > rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ELSE
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ENDIF
       ELSE
        IF ((rows->qual[curr_seq].weight_operator_sort_key=less_than_key))
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ELSE
         IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field2))
          SET weight_overlap_flag = has_overlap
         ELSE
          SET weight_overlap_flag = no_overlap
         ENDIF
        ENDIF
      ENDCASE
     ENDIF
    ENDIF
   OF crcl:
    IF ((prev_row->crcl_operator_sort_key=rows->qual[curr_seq].crcl_operator_sort_key))
     IF ( NOT ((prev_row->crcl_operator_sort_key=no_operator_key)))
      CASE (prev_row->crcl_operator_sort_key)
       OF between_key:
        IF ((prev_row->crcl_field1=rows->qual[curr_seq].crcl_field1)
         AND (prev_row->crcl_field2=rows->qual[curr_seq].crcl_field2))
         SET crcl_overlap_flag = same
        ELSEIF ((( NOT ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field2))) OR ( NOT ((
        prev_row->crcl_field2 > rows->qual[curr_seq].crcl_field1)))) )
         SET crcl_overlap_flag = no_overlap
        ELSE
         SET crcl_overlap_flag = has_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1=rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = same
        ELSE
         SET crcl_overlap_flag = has_overlap
        ENDIF
      ENDCASE
     ELSE
      SET crcl_overlap_flag = same
     ENDIF
    ELSE
     CASE (prev_row->crcl_operator_sort_key)
      OF less_than_key:
       IF ((prev_row->crcl_field1 > rows->qual[curr_seq].crcl_field1))
        SET crcl_overlap_flag = has_overlap
       ELSE
        SET crcl_overlap_flag = no_overlap
       ENDIF
      OF between_key:
       IF ((rows->qual[curr_seq].crcl_operator_sort_key=greater_equal_key))
        IF ((prev_row->crcl_field2 > rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ENDIF
      ELSE
       IF ((rows->qual[curr_seq].crcl_operator_sort_key=less_than_key))
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field1))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ELSE
        IF ((prev_row->crcl_field1 < rows->qual[curr_seq].crcl_field2))
         SET crcl_overlap_flag = has_overlap
        ELSE
         SET crcl_overlap_flag = no_overlap
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   ELSE
    CALL bederrorcheck("Error 021: Unrecongnizeable premise type flag.")
  ENDCASE
  CALL bederrorcheck("Error 022: Error while compare premises of adjacent rows.")
 END ;Subroutine
 SUBROUTINE markoverlap(type)
   DECLARE result = i2 WITH public, noconstant(0)
   CASE (type)
    OF age:
     IF (((pma_overlap_flag=same) OR (pma_overlap_flag=has_overlap))
      AND ((age_overlap_flag=same) OR (age_overlap_flag=has_overlap))
      AND ((crcl_overlap_flag=same) OR (crcl_overlap_flag=has_overlap))
      AND ((weight_overlap_flag=same) OR (weight_overlap_flag=has_overlap)) )
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF pma:
     IF (((pma_overlap_flag=has_overlap) OR (pma_overlap_flag=same))
      AND age_overlap_flag=same
      AND crcl_overlap_flag=same
      AND weight_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF weight:
     IF (((weight_overlap_flag=has_overlap) OR (weight_overlap_flag=same))
      AND age_overlap_flag=same
      AND crcl_overlap_flag=same
      AND pma_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    OF crcl:
     IF (((crcl_overlap_flag=has_overlap) OR (crcl_overlap_flag=same))
      AND age_overlap_flag=same
      AND pma_overlap_flag=same
      AND weight_overlap_flag=same)
      SET result = has_overlap
     ELSE
      SET result = no_overlap
     ENDIF
    ELSE
     CALL bederrorcheck("Error 021: Unrecongnizeable premise type flag.")
   ENDCASE
   CALL bederrorcheck("Error 024: Error while determine if a row has overlap ranges.")
   RETURN(result)
 END ;Subroutine
 SUBROUTINE markrowsforoverlap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SET sorted_index = 1
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1)
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].overlap_sort_key
      DESC, rows->qual[d1.seq].clinical_cond_physical_sort_key,
     rows->qual[d1.seq].pma_physical_sort_key, rows->qual[d1.seq].hepatic_physical_sort_key, rows->
     qual[d1.seq].crcl_physical_sort_key,
     rows->qual[d1.seq].age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforoverlap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->routes_concat_physical_sort_key = rows->qual[d1.seq].
     routes_concat_physical_sort_key,
     prev_row->clinical_cond_physical_sort_key = rows->qual[d1.seq].clinical_cond_physical_sort_key,
     prev_row->hepatic_physical_sort_key = rows->qual[d1.seq].hepatic_physical_sort_key, prev_row->
     pma_operator_sort_key = rows->qual[d1.seq].pma_operator_sort_key,
     prev_row->pma_field1 = rows->qual[d1.seq].pma_field1, prev_row->pma_field2 = rows->qual[d1.seq].
     pma_field2, prev_row->crcl_unit_of_measure_sort_key = rows->qual[d1.seq].
     crcl_unit_of_measure_sort_key,
     prev_row->crcl_operator_sort_key = rows->qual[d1.seq].crcl_operator_sort_key, prev_row->
     crcl_field1 = rows->qual[d1.seq].crcl_field1, prev_row->crcl_field2 = rows->qual[d1.seq].
     crcl_field2,
     prev_row->age_operator_sort_key = rows->qual[d1.seq].age_operator_sort_key, prev_row->age_field1
      = rows->qual[d1.seq].age_field1, prev_row->age_field2 = rows->qual[d1.seq].age_field2,
     prev_row->weight_operator_sort_key = rows->qual[d1.seq].weight_operator_sort_key, prev_row->
     weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->qual[d1.seq].
     weight_field2,
     prev_row->overlap_sort_key = rows->qual[d1.seq].overlap_sort_key
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 025: Error while Marking rows for overlap.")
 END ;Subroutine
 SUBROUTINE markrowsforagegap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SELECT INTO "NL:"
    route = rows->qual[d1.seq].routes_concat_physical_sort_key
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1
     WHERE (rows->qual[d1.seq].gap_sort_key=0001))
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].
     age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    HEAD route
     sorted_index = 1
     IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=less_than_key)))
      rows->qual[d1.seq].mark_age_gap = has_gap
     ENDIF
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforagegap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->age_operator_sort_key = rows->qual[d1.seq].age_operator_sort_key,
     prev_row->age_field1 = rows->qual[d1.seq].age_field1, prev_row->age_field2 = rows->qual[d1.seq].
     age_field2, prev_row->weight_operator_sort_key = rows->qual[d1.seq].weight_operator_sort_key,
     prev_row->weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->
     qual[d1.seq].weight_field2, prev_row->gap_sort_key = rows->qual[d1.seq].gap_sort_key
    FOOT  route
     IF ( NOT ((rows->qual[d1.seq].age_operator_sort_key=greater_equal_key)))
      rows->qual[d1.seq].mark_age_gap = has_gap
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 026: Error while Marking rows for gap.")
 END ;Subroutine
 SUBROUTINE markrowsforweightgap(dummyvar)
   DECLARE sorted_index = i2 WITH protect, noconstant(1)
   SELECT INTO "NL:"
    route = rows->qual[d1.seq].routes_concat_physical_sort_key, age = rows->qual[d1.seq].
    age_physical_sort_key
    FROM (dummyt d1  WITH seq = value(size(rows->qual,5)))
    PLAN (d1
     WHERE (rows->qual[d1.seq].overlap_sort_key=0011))
    ORDER BY rows->qual[d1.seq].routes_concat_physical_sort_key, rows->qual[d1.seq].
     age_physical_sort_key, rows->qual[d1.seq].weight_physical_sort_key
    HEAD route
     sorted_index = 1
    HEAD age
     sorted_index = 1
     IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=less_than_key)))
      rows->qual[d1.seq].mark_weight_gap = has_gap
     ENDIF
    DETAIL
     IF ( NOT (sorted_index=1))
      CALL compareiftworowsareinsamebucketforweightgap(d1.seq)
     ENDIF
     sorted_index = (sorted_index+ 1), prev_row->parent_premise_id = rows->qual[d1.seq].
     parent_premise_id, prev_row->weight_operator_sort_key = rows->qual[d1.seq].
     weight_operator_sort_key,
     prev_row->weight_field1 = rows->qual[d1.seq].weight_field1, prev_row->weight_field2 = rows->
     qual[d1.seq].weight_field2
    FOOT  age
     IF ( NOT ((rows->qual[d1.seq].weight_operator_sort_key=greater_equal_key)))
      rows->qual[d1.seq].mark_weight_gap = has_gap
     ENDIF
    FOOT  route
     sorted_index = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 026: Error while Marking rows for gap.")
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforagegap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[index
    ].parent_premise_id)
   IF ((rows->qual[prev_index].mark_age_gap=no_gap))
    CASE (prev_row->age_operator_sort_key)
     OF less_than_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF less_than_key:
        SET rows->qual[prev_index].mark_age_gap = no_gap
       OF between_key:
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->age_field1 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
      ENDCASE
     OF between_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF between_key:
        IF ((prev_row->age_field2 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->age_field2 < rows->qual[curr_seq].age_field1))
         SET rows->qual[prev_index].mark_age_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_age_gap = no_gap
        ENDIF
      ENDCASE
     OF greater_equal_key:
      CASE (rows->qual[curr_seq].age_operator_sort_key)
       OF greater_equal_key:
        SET rows->qual[prev_index].mark_age_gap = no_gap
      ENDCASE
    ENDCASE
   ENDIF
   CALL bederrorcheck("Error 027: Error while compare adjacent rows for Age Gap.")
 END ;Subroutine
 SUBROUTINE compareiftworowsareinsamebucketforweightgap(curr_seq)
   DECLARE index = i2 WITH protect, noconstant(1)
   DECLARE prev_index = i2 WITH protect, noconstant(0)
   SET prev_index = locateval(index,1,size(rows->qual,5),prev_row->parent_premise_id,rows->qual[index
    ].parent_premise_id)
   IF ((rows->qual[prev_index].mark_weight_gap=no_gap))
    CASE (prev_row->weight_operator_sort_key)
     OF less_than_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF less_than_key:
        SET rows->qual[prev_index].mark_weight_gap = no_gap
       OF between_key:
        IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->weight_field1 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
      ENDCASE
     OF between_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF between_key:
        IF ((((prev_row->weight_field2 < rows->qual[curr_seq].weight_field1)) OR ((prev_row->
        weight_field1 > rows->qual[curr_seq].weight_field2))) )
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
       OF greater_equal_key:
        IF ((prev_row->weight_field2 < rows->qual[curr_seq].weight_field1))
         SET rows->qual[prev_index].mark_weight_gap = has_gap
        ELSE
         SET rows->qual[prev_index].mark_weight_gap = no_gap
        ENDIF
      ENDCASE
     OF greater_equal_key:
      CASE (rows->qual[curr_seq].weight_operator_sort_key)
       OF greater_equal_key:
        SET rows->qual[prev_index].mark_weight_gap = no_gap
      ENDCASE
    ENDCASE
   ENDIF
   CALL bederrorcheck("Error 028: Error while compare adjacent rows for Weight Gap.")
 END ;Subroutine
 SUBROUTINE calculatecrclunitofmeasuresortkey(unit_type)
  CASE (unit_type)
   OF unit_ml_min_1_73m2_cd:
    RETURN(unit_ml_min_1_73m2_key)
   OF unit_ml_min_cd:
    RETURN(unit_ml_min_key)
  ENDCASE
  CALL bederrorcheck("Error 029: Wrong unit_type for CrCl")
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 dose_range_check_id = f8
      2 drc_form_reltn_id = f8
      2 reltn_build_flag = i2
      2 reltn_active_ind = i2
      2 drc_name = vc
      2 drc_content_rule_identifier = f8
      2 drc_build_flag = i2
      2 drc_active_ind = i2
      2 parent_premise[*]
        3 parent_premise_id = f8
        3 active_ind = i2
        3 routes_location_flag = i2
        3 premise[*]
          4 drc_premise_id = f8
          4 premise_type_flag = i2
          4 concept_cki = vc
          4 source_string = vc
          4 relational_operator_flag = i2
          4 value_unit_cd = f8
          4 value_unit_display = c40
          4 value1 = f8
          4 value2 = f8
          4 age1_to_days = f8
          4 age2_to_days = f8
          4 weight1_to_kgs = f8
          4 weight2_to_kgs = f8
          4 active_ind = i2
          4 has_overlap = i2
          4 has_gap = i2
          4 routes[*]
            5 drc_premise_list_id = f8
            5 parent_entity_id = f8
            5 route_disp = vc
            5 active_ind = i2
        3 dose_range[*]
          4 drc_dose_range_id = f8
          4 min_value = f8
          4 max_value = f8
          4 min_value_variance = f8
          4 max_value_variance = f8
          4 value_unit_cd = f8
          4 value_unit_display = c40
          4 max_dose = f8
          4 max_dose_unit_cd = f8
          4 max_dose_unit_display = c40
          4 dose_days = i4
          4 type_flag = i2
          4 long_text_id = f8
          4 long_text = vc
          4 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(unsortedreply,0)))
  RECORD unsortedreply(
    1 qual[*]
      2 dose_range_check_id = f8
      2 drc_form_reltn_id = f8
      2 reltn_build_flag = i2
      2 reltn_active_ind = i2
      2 drc_name = vc
      2 drc_content_rule_identifier = f8
      2 drc_build_flag = i2
      2 drc_active_ind = i2
      2 parent_premise[*]
        3 parent_premise_id = f8
        3 active_ind = i2
        3 routes_location_flag = i2
        3 premise[*]
          4 drc_premise_id = f8
          4 premise_type_flag = i2
          4 concept_cki = vc
          4 source_string = vc
          4 relational_operator_flag = i2
          4 value_unit_cd = f8
          4 value1 = f8
          4 value2 = f8
          4 age1_to_days = f8
          4 age2_to_days = f8
          4 weight1_to_kgs = f8
          4 weight2_to_kgs = f8
          4 active_ind = i2
          4 routes[*]
            5 drc_premise_list_id = f8
            5 parent_entity_id = f8
            5 route_disp = vc
            5 active_ind = i2
        3 dose_range[*]
          4 drc_dose_range_id = f8
          4 min_value = f8
          4 max_value = f8
          4 min_value_variance = f8
          4 max_value_variance = f8
          4 value_unit_cd = f8
          4 max_dose = f8
          4 max_dose_unit_cd = f8
          4 dose_days = i4
          4 type_flag = i2
          4 long_text_id = f8
          4 long_text = vc
          4 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE populategrouperreply(dummyvar=i2) = null
 DECLARE populaterowsstructwithinfofromunsortedreply(dummyvar=i2) = null
 DECLARE populatereplyinsortedorder(dummyvar=i2) = null
 DECLARE get_clinical_conditions_source_string(qualcnt=i4) = null
 DECLARE populatedoseranges(dummyvar=i2) = null
 DECLARE direct_to_days(number=f8,units_code=f8) = null
 DECLARE direct_to_kgs(number=f8,units_code=f8) = null
 DECLARE less_than = i2 WITH protect, constant(1)
 DECLARE greater_than_equal = i2 WITH protect, constant(4)
 DECLARE betwn = i2 WITH protect, constant(6)
 DECLARE relational_routes = i2 WITH protect, constant(8)
 DECLARE single = i2 WITH protect, constant(1)
 DECLARE daily = i2 WITH protect, constant(2)
 DECLARE therapy = i2 WITH protect, constant(3)
 DECLARE ndays = i2 WITH protect, constant(4)
 DECLARE na = i2 WITH protect, constant(5)
 DECLARE continuous = i2 WITH protect, constant(6)
 DECLARE lifetime = i2 WITH protect, constant(7)
 DECLARE ppcnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE plcnt = i4 WITH protect, noconstant(0)
 DECLARE qualcnt = i4 WITH protect, noconstant(0)
 DECLARE pploop = i4 WITH protect, noconstant(0)
 DECLARE ploop = i4 WITH protect, noconstant(0)
 DECLARE hours = f8 WITH protect, noconstant(0.0)
 DECLARE days = f8 WITH protect, noconstant(0.0)
 DECLARE weeks = f8 WITH protect, noconstant(0.0)
 DECLARE months = f8 WITH protect, noconstant(0.0)
 DECLARE years = f8 WITH protect, noconstant(0.0)
 DECLARE kg = f8 WITH protect, noconstant(0.0)
 DECLARE gram = f8 WITH protect, noconstant(0.0)
 DECLARE ounce = f8 WITH protect, noconstant(0.0)
 DECLARE lbs = f8 WITH protect, noconstant(0.0)
 SET days = uar_get_code_by_cki("CKI.CODEVALUE!8423")
 SET weeks = uar_get_code_by_cki("CKI.CODEVALUE!7994")
 SET months = uar_get_code_by_cki("CKI.CODEVALUE!7993")
 SET years = uar_get_code_by_cki("CKI.CODEVALUE!3712")
 SET hours = uar_get_code_by_cki("CKI.CODEVALUE!2743")
 SET kg = uar_get_code_by_cki("CKI.CODEVALUE!2751")
 SET gram = uar_get_code_by_cki("CKI.CODEVALUE!6123")
 SET ounce = uar_get_code_by_cki("CKI.CODEVALUE!2745")
 SET lbs = uar_get_code_by_cki("CKI.CODEVALUE!2746")
 CALL bedbeginscript(0)
 CALL populategrouperunsortedreply(0)
 CALL get_clinical_conditions_source_string(qualcnt)
 CALL populatedoseranges(0)
 CALL populaterowsstructwithinfofromunsortedreply(0)
 CALL ranktherowsforphysicalsorting(0)
 CALL markrowsforoverlap(0)
 CALL markrowsforagegap(0)
 CALL markrowsforweightgap(0)
 CALL populatereplyinsortedorder(0)
 SUBROUTINE populategrouperunsortedreply(dummyvar)
  SELECT INTO "nl:"
   dfr.drc_group_id, dfr.dose_range_check_id, dfr.drc_form_reltn_id,
   dfr.build_flag, dfr.active_ind, drc.dose_range_check_name,
   drc.content_rule_identifier, drc.build_flag, drc.active_ind,
   dp.drc_premise_id, dp.active_ind, dp2.drc_premise_id,
   dp2.premise_type_flag, dp2.relational_operator_flag, dp2.value_unit_cd,
   dp2.value1, dp2.value2, dp2.concept_cki,
   dp2.active_ind, dpl.drc_premise_list_id, dpl.parent_entity_id
   FROM drc_form_reltn dfr,
    dose_range_check drc,
    dummyt d,
    drc_premise dp,
    drc_premise dp2,
    drc_premise_list dpl
   PLAN (dfr
    WHERE (dfr.dose_range_check_id=request->dose_range_check_id))
    JOIN (drc
    WHERE drc.dose_range_check_id=dfr.dose_range_check_id)
    JOIN (d)
    JOIN (dp
    WHERE dp.dose_range_check_id=drc.dose_range_check_id
     AND dp.parent_premise_id=0
     AND dp.active_ind=1)
    JOIN (dp2
    WHERE dp2.parent_premise_id=dp.drc_premise_id
     AND dp2.active_ind=1)
    JOIN (dpl
    WHERE outerjoin(dp2.drc_premise_id)=dpl.drc_premise_id
     AND dpl.active_ind=outerjoin(1))
   ORDER BY dfr.drc_group_id, dfr.dose_range_check_id, dp.drc_premise_id,
    dp2.premise_type_flag, dpl.parent_entity_id
   HEAD REPORT
    ppcnt = 0, pcnt = 0, qualcnt = 0
   HEAD dfr.dose_range_check_id
    ppcnt = 0, qualcnt = (qualcnt+ 1), stat = alterlist(unsortedreply->qual,qualcnt),
    unsortedreply->qual[qualcnt].dose_range_check_id = dfr.dose_range_check_id, unsortedreply->qual[
    qualcnt].drc_form_reltn_id = dfr.drc_form_reltn_id, unsortedreply->qual[qualcnt].reltn_build_flag
     = dfr.build_flag,
    unsortedreply->qual[qualcnt].reltn_active_ind = dfr.active_ind, unsortedreply->qual[qualcnt].
    drc_name = drc.dose_range_check_name, unsortedreply->qual[qualcnt].drc_content_rule_identifier =
    drc.content_rule_identifier,
    unsortedreply->qual[qualcnt].drc_build_flag = drc.build_flag, unsortedreply->qual[qualcnt].
    drc_active_ind = drc.active_ind
   HEAD dp.drc_premise_id
    IF (dp.drc_premise_id > 0.0)
     ppcnt = (ppcnt+ 1), stat = alterlist(unsortedreply->qual[qualcnt].parent_premise,ppcnt), stat =
     alterlist(rows->qual,ppcnt),
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].parent_premise_id = dp.drc_premise_id,
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].active_ind = dp.active_ind, unsortedreply->
     qual[qualcnt].parent_premise[ppcnt].routes_location_flag = 0,
     rows->qual[ppcnt].parent_premise_id = dp.drc_premise_id, pcnt = 0
    ENDIF
    CALL bederrorcheck("Error 001: Error within the head of dp.drc_premise_id")
   HEAD dp2.premise_type_flag
    IF (ppcnt > 0)
     pcnt = (pcnt+ 1), stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise,
      pcnt)
     IF (dp2.premise_type_flag > 0)
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].drc_premise_id = dp2
      .drc_premise_id, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
      premise_type_flag = dp2.premise_type_flag, unsortedreply->qual[qualcnt].parent_premise[ppcnt].
      premise[pcnt].relational_operator_flag = dp2.relational_operator_flag,
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value_unit_cd = dp2
      .value_unit_cd, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = dp2
      .value1, unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value2 = dp2.value2,
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].active_ind = dp2.active_ind
     ELSE
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_type_flag = none
     ENDIF
     IF (dp2.premise_type_flag=age)
      CASE (dp2.relational_operator_flag)
       OF less_than:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
       OF greater_than_equal:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
       OF betwn:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,
        CALL direct_to_days(dp2.value2,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age2_to_days = number_of_days
       ELSE
        CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
        CALL bederrorcheck(build("Error 002: Age operator issue for dp2.drc_premise_id of: ",dp2
         .drc_premise_id))
      ENDCASE
     ELSEIF (dp2.premise_type_flag=weight)
      CASE (dp2.relational_operator_flag)
       OF less_than:
        CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].weight1_to_kgs = number_of_kgs,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0
       OF greater_than_equal:
        CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].weight1_to_kgs = number_of_kgs,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0
       OF betwn:
        CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].weight1_to_kgs = number_of_kgs,
        CALL direct_to_kgs(dp2.value2,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].weight2_to_kgs = number_of_kgs
       ELSE
        CALL echo(build("Can't recognize weight relational operator:",dp2.relational_operator_flag))
        CALL bederrorcheck(build("Error 003: Weight operator issue for dp2.drc_premise_id of: ",dp2
         .drc_premise_id))
      ENDCASE
     ELSEIF (dp2.premise_type_flag=crcl)
      CASE (dp2.relational_operator_flag)
       OF greater_than_equal:
        CALL echo(build("Can't recognize renal relational operator:",dp2.relational_operator_flag))
        CALL bederrorcheck(build("Error 004: CrCl operator issue for dp2.drc_premise_id of: ",dp2
         .drc_premise_id))
      ENDCASE
     ELSEIF (dp2.premise_type_flag=pma)
      CASE (dp2.relational_operator_flag)
       OF less_than:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
       OF greater_than_equal:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,unsortedreply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
       OF betwn:
        CALL direct_to_days(dp2.value1,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age1_to_days = number_of_days,
        CALL direct_to_days(dp2.value2,dp2.value_unit_cd)unsortedreply->qual[qualcnt].parent_premise[
        ppcnt].premise[pcnt].age2_to_days = number_of_days
       ELSE
        CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
        CALL bederrorcheck(build("Error 005: CrCl operator issue for dp2.drc_premise_id of: ",dp2
         .drc_premise_id))
      ENDCASE
     ELSEIF (dp2.premise_type_flag=hepatic)
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = dp2.value1
     ELSEIF (dp2.premise_type_flag=clinical_condition)
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].concept_cki = dp2.concept_cki
     ENDIF
     plcnt = 0
    ENDIF
   DETAIL
    IF (dp2.premise_type_flag=routes
     AND dpl.drc_premise_id > 0.0
     AND dpl.parent_entity_id > 0.0)
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].routes_location_flag = 1, plcnt = (plcnt+ 1),
     stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes,plcnt),
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].
     drc_premise_list_id = dpl.drc_premise_list_id, unsortedreply->qual[qualcnt].parent_premise[ppcnt
     ].premise[pcnt].routes[plcnt].parent_entity_id = dpl.parent_entity_id, unsortedreply->qual[
     qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].route_disp = uar_get_code_display(dpl
      .parent_entity_id),
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].active_ind = dpl
     .active_ind
    ENDIF
   FOOT  dp2.premise_type_flag
    IF (plcnt=0
     AND dp2.premise_type_flag=routes)
     plcnt = 1, stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
      routes,plcnt), unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].
     drc_premise_list_id = unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
     drc_premise_id,
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].parent_entity_id
      = unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1, unsortedreply->qual[
     qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].route_disp = uar_get_code_display(
      unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1), unsortedreply->qual[
     qualcnt].parent_premise[ppcnt].premise[pcnt].routes[plcnt].active_ind = 1,
     unsortedreply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = 0
    ENDIF
   FOOT  dfr.dose_range_check_id
    stat = alterlist(unsortedreply->qual[qualcnt].parent_premise,ppcnt)
   WITH nocounter, outerjoin = d
  ;end select
  CALL bederrorcheck("Error 006: Error for the main select querry for parent_premise id of: ")
 END ;Subroutine
 SUBROUTINE get_clinical_conditions_source_string(qualcnt)
   FOR (cnt = 1 TO qualcnt)
     FOR (pploop = 1 TO size(unsortedreply->qual[cnt].parent_premise,5))
       FOR (ploop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].premise,5))
         IF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=
         clinical_condition)
          AND  NOT (trim(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].concept_cki,
          clinical_condition) IN ("", null)))
          SELECT INTO "nl:"
           FROM nomenclature n
           WHERE (n.concept_cki=unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
           concept_cki)
            AND n.primary_cterm_ind=1
            AND n.active_ind=1
           DETAIL
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].source_string = n
            .source_string
           WITH nocounter
          ;end select
          CALL bederrorcheck(build("Error 007: Failed to get Clinical Condition for: ",unsortedreply
            ->qual[cnt].parent_premise[pploop].premise[ploop].concept_cki))
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatedoseranges(dummyvar)
  SELECT INTO "nl:"
   ddr.drc_premise_id
   FROM (dummyt d  WITH seq = value(ppcnt)),
    drc_dose_range ddr,
    long_text lt
   PLAN (d
    WHERE (unsortedreply->qual[qualcnt].parent_premise[d.seq].parent_premise_id > 0))
    JOIN (ddr
    WHERE (ddr.drc_premise_id=unsortedreply->qual[qualcnt].parent_premise[d.seq].parent_premise_id)
     AND ddr.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(ddr.long_text_id)
     AND lt.active_ind=outerjoin(1))
   ORDER BY ddr.drc_premise_id, ddr.type_flag, ddr.dose_days,
    build(trim(cnvtupper(uar_get_code_display(ddr.value_unit_cd)),7),"          ")
   HEAD ddr.drc_premise_id
    dcnt = 0, hassingle = 0, hasdaily = 0,
    needinsertsingle = 0, needinsertdaily = 0
   HEAD ddr.type_flag
    IF (ddr.type_flag=single)
     hassingle = 1
    ELSE
     IF (ddr.type_flag=daily)
      hasdaily = 1
      IF (hassingle=0)
       needinsertsingle = 1
      ENDIF
     ELSE
      IF (hasdaily=0
       AND hassingle=1)
       needinsertdaily = 1
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    IF (needinsertsingle=1)
     needinsertsingle = 0, hassingle = 1, dcnt = (dcnt+ 1),
     stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range,dcnt),
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].drc_dose_range_id = ddr
     .drc_dose_range_id, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].
     type_flag = single,
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].active_ind = 0
    ENDIF
    IF (needinsertdaily=1)
     needinsertdaily = 0, hasdaily = 1, dcnt = (dcnt+ 1),
     stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range,dcnt),
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].drc_dose_range_id = ddr
     .drc_dose_range_id, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].
     type_flag = daily,
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].active_ind = 0
    ENDIF
    dcnt = (dcnt+ 1), stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range,
     dcnt), unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].drc_dose_range_id =
    ddr.drc_dose_range_id,
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].min_value = ddr.min_value,
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].max_value = ddr.max_value,
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].min_value_variance = (ddr
    .min_variance_pct * 100),
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].max_value_variance = (ddr
    .max_variance_pct * 100), unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].
    value_unit_cd = ddr.value_unit_cd, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[
    dcnt].max_dose = ddr.max_dose,
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].max_dose_unit_cd = ddr
    .max_dose_unit_cd, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].dose_days
     = ddr.dose_days, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].type_flag
     = ddr.type_flag,
    unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].long_text_id = lt
    .long_text_id, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].long_text = lt
    .long_text, unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].active_ind = ddr
    .active_ind
   FOOT  ddr.drc_premise_id
    IF (hassingle=1
     AND hasdaily=0)
     dcnt = (dcnt+ 1), stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range,
      dcnt), unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].drc_dose_range_id =
     ddr.drc_dose_range_id,
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].type_flag = daily,
     unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range[dcnt].active_ind = 0
    ENDIF
    stat = alterlist(unsortedreply->qual[qualcnt].parent_premise[d.seq].dose_range,dcnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 008: Failed to get dose ranges")
 END ;Subroutine
 SUBROUTINE direct_to_days(number,units_code)
   SET number_of_days = 0.0
   IF (units_code=years
    AND number=1.0)
    SET number_of_days = 360.0
   ELSEIF (units_code=years
    AND number=2.0)
    SET number_of_days = 720.0
   ELSEIF (units_code=years
    AND number >= 3.0)
    SET number_of_days = (365.0 * number)
   ELSEIF (units_code=months
    AND number=1.0)
    SET number_of_days = 28.0
   ELSEIF (units_code=months
    AND number >= 2.0)
    SET number_of_days = (30.0 * number)
   ELSEIF (units_code=weeks)
    SET number_of_days = (7.0 * number)
   ELSEIF (units_code=days)
    SET number_of_days = number
   ELSEIF (units_code=hours)
    SET number_of_days = (number/ 24.0)
   ELSE
    SET number_of_days = 0.0
   ENDIF
   CALL bederrorcheck("Error 009: Failed to direct to days")
 END ;Subroutine
 SUBROUTINE direct_to_kgs(number,units_code)
   SET number_of_kgs = 0.0
   IF (units_code=kg)
    SET number_of_kgs = number
   ELSEIF (units_code=gram)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = (number/ 1000.0)
    ENDIF
   ELSEIF (units_code=ounce)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = ((number/ 16.0) * 0.4545)
    ENDIF
   ELSEIF (units_code=lbs)
    IF (number=0.0)
     SET number_of_kgs = 0.0
    ELSE
     SET number_of_kgs = (number * 0.4545)
    ENDIF
   ELSE
    SET number_of_kgs = 0.0
   ENDIF
   CALL bederrorcheck("Error 010: Failed to direct to kgs")
 END ;Subroutine
 SUBROUTINE populaterowsstructwithinfofromunsortedreply(dummyvar)
   SET cnt = 1
   SET pploop = 1
   SET ploop = 1
   FOR (cnt = 1 TO size(unsortedreply->qual,5))
     FOR (pploop = 1 TO size(unsortedreply->qual[cnt].parent_premise,5))
       SET rows->qual[pploop].overlap_sort_key = 0000
       SET rows->qual[pploop].gap_sort_key = 0000
       FOR (ploop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].premise,5))
         CASE (unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag)
          OF age:
           SET rows->qual[pploop].age_operator_sort_key = calculateoperatorsortkey(unsortedreply->
            qual[cnt].parent_premise[pploop].premise[ploop].relational_operator_flag)
           SET rows->qual[pploop].age_field1 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].age1_to_days
           SET rows->qual[pploop].age_field2 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].age2_to_days
           SET rows->qual[pploop].overlap_sort_key = (rows->qual[pploop].overlap_sort_key+ 0001)
           SET rows->qual[pploop].gap_sort_key = (rows->qual[pploop].gap_sort_key+ 0001)
          OF routes:
           SELECT INTO "NL:"
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes[d1.seq].route_disp
            FROM (dummyt d1  WITH seq = value(size(unsortedreply->qual[cnt].parent_premise[pploop].
               premise[ploop].routes,5)))
            PLAN (d1)
            ORDER BY cnvtupper(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes[
              d1.seq].route_disp)
            HEAD REPORT
             index = 1, stat = alterlist(rows->qual[pploop].sorted_routes,size(unsortedreply->qual[
               cnt].parent_premise[pploop].premise[ploop].routes,5))
            DETAIL
             rows->qual[pploop].routes_concat_disp = concat(rows->qual[pploop].routes_concat_disp,
              cnvtupper(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes[d1.seq]
               .route_disp)), rows->qual[pploop].sorted_routes[index].drc_premise_list_id =
             unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes[d1.seq].
             drc_premise_list_id, rows->qual[pploop].sorted_routes[index].parent_entity_id =
             unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes[d1.seq].
             parent_entity_id,
             rows->qual[pploop].sorted_routes[index].route_disp = unsortedreply->qual[cnt].
             parent_premise[pploop].premise[ploop].routes[d1.seq].route_disp, rows->qual[pploop].
             sorted_routes[index].active_ind = unsortedreply->qual[cnt].parent_premise[pploop].
             premise[ploop].routes[d1.seq].active_ind, index = (index+ 1)
            WITH nocounter
           ;end select
          OF weight:
           SET rows->qual[pploop].weight_operator_sort_key = calculateoperatorsortkey(unsortedreply->
            qual[cnt].parent_premise[pploop].premise[ploop].relational_operator_flag)
           SET rows->qual[pploop].weight_field1 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].weight1_to_kgs
           SET rows->qual[pploop].weight_field2 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].weight2_to_kgs
           SET rows->qual[pploop].overlap_sort_key = (rows->qual[pploop].overlap_sort_key+ 0010)
          OF crcl:
           SET rows->qual[pploop].crcl_operator_sort_key = calculateoperatorsortkey(unsortedreply->
            qual[cnt].parent_premise[pploop].premise[ploop].relational_operator_flag)
           SET rows->qual[pploop].crcl_unit_of_measure_sort_key = calculatecrclunitofmeasuresortkey(
            unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd)
           SET rows->qual[pploop].crcl_field1 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].value1
           SET rows->qual[pploop].crcl_field2 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].value2
           SET rows->qual[pploop].overlap_sort_key = (rows->qual[pploop].overlap_sort_key+ 0100)
           SET rows->qual[pploop].gap_sort_key = (rows->qual[pploop].gap_sort_key+ 0100)
          OF pma:
           SET rows->qual[pploop].pma_operator_sort_key = calculateoperatorsortkey(unsortedreply->
            qual[cnt].parent_premise[pploop].premise[ploop].relational_operator_flag)
           SET rows->qual[pploop].pma_field1 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].age1_to_days
           SET rows->qual[pploop].pma_field2 = unsortedreply->qual[cnt].parent_premise[pploop].
           premise[ploop].age2_to_days
           SET rows->qual[pploop].overlap_sort_key = (rows->qual[pploop].overlap_sort_key+ 1000)
           SET rows->qual[pploop].gap_sort_key = (rows->qual[pploop].gap_sort_key+ 10000)
          OF hepatic:
           SET rows->qual[pploop].hepatic_physical_sort_key = calculateyesnosortkey(unsortedreply->
            qual[cnt].parent_premise[pploop].premise[ploop].value1)
           SET rows->qual[pploop].gap_sort_key = (rows->qual[pploop].gap_sort_key+ 1000)
          OF clinical_condition:
           SET rows->qual[pploop].clinical_conditions = cnvtupper(unsortedreply->qual[cnt].
            parent_premise[pploop].premise[ploop].source_string)
           SET rows->qual[pploop].gap_sort_key = (rows->qual[pploop].gap_sort_key+ 100000)
          OF 0:
           SET aaa = 1
          ELSE
           CALL bederrorcheck("Error 011: Unknown Premise Type. Failed to populate rows struct")
         ENDCASE
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE populatereplyinsortedorder(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(1)
   DECLARE sorted_pp_index = i4 WITH protect, noconstant(1)
   DECLARE p_list_loop = i4 WITH protect, noconstant(1)
   DECLARE dloop = i4 WITH protect, noconstant(1)
   SET stat = alterlist(reply->qual,size(unsortedreply->qual,5))
   FOR (cnt = 1 TO size(unsortedreply->qual,5))
     SET reply->qual[cnt].dose_range_check_id = unsortedreply->qual[cnt].dose_range_check_id
     SET reply->qual[cnt].drc_form_reltn_id = unsortedreply->qual[cnt].drc_form_reltn_id
     SET reply->qual[cnt].reltn_build_flag = unsortedreply->qual[cnt].reltn_build_flag
     SET reply->qual[cnt].reltn_active_ind = unsortedreply->qual[cnt].reltn_active_ind
     SET reply->qual[cnt].drc_name = unsortedreply->qual[cnt].drc_name
     SET reply->qual[cnt].drc_content_rule_identifier = unsortedreply->qual[cnt].
     drc_content_rule_identifier
     SET reply->qual[cnt].drc_build_flag = unsortedreply->qual[cnt].drc_build_flag
     SET reply->qual[cnt].drc_active_ind = unsortedreply->qual[cnt].drc_active_ind
     SET stat = alterlist(reply->qual[cnt].parent_premise,size(unsortedreply->qual[cnt].
       parent_premise,5))
     FOR (pploop = 1 TO size(unsortedreply->qual[cnt].parent_premise,5))
       SET index = 1
       SET sorted_pp_index = locateval(index,1,size(sorted_rows->qual,5),unsortedreply->qual[cnt].
        parent_premise[pploop].parent_premise_id,sorted_rows->qual[index].parent_premise_id)
       SET reply->qual[cnt].parent_premise[sorted_pp_index].parent_premise_id = unsortedreply->qual[
       cnt].parent_premise[pploop].parent_premise_id
       SET reply->qual[cnt].parent_premise[sorted_pp_index].active_ind = unsortedreply->qual[cnt].
       parent_premise[pploop].active_ind
       SET reply->qual[cnt].parent_premise[sorted_pp_index].routes_location_flag = unsortedreply->
       qual[cnt].parent_premise[pploop].routes_location_flag
       SET stat = alterlist(reply->qual[cnt].parent_premise[sorted_pp_index].premise,size(
         unsortedreply->qual[cnt].parent_premise[pploop].premise,5))
       FOR (ploop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].premise,5))
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].drc_premise_id =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].drc_premise_id
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].premise_type_flag =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].concept_cki =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].concept_cki
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].source_string =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].source_string
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].relational_operator_flag
          = unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].relational_operator_flag
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].value_unit_cd =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].value_unit_cd
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].value_unit_display =
         uar_get_code_display(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].
          value_unit_cd)
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].value1 = unsortedreply->
         qual[cnt].parent_premise[pploop].premise[ploop].value1
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].value2 = unsortedreply->
         qual[cnt].parent_premise[pploop].premise[ploop].value2
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].age1_to_days =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].age1_to_days
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].age2_to_days =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].age2_to_days
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].weight1_to_kgs =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].weight1_to_kgs
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].weight2_to_kgs =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].weight2_to_kgs
         SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].active_ind =
         unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].active_ind
         IF ((reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].premise_type_flag=age))
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_overlap = rows->
          qual[pploop].mark_age_overlap
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_gap = rows->qual[
          pploop].mark_age_gap
         ELSEIF ((reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].premise_type_flag=
         pma))
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_overlap = rows->
          qual[pploop].mark_pma_overlap
         ELSEIF ((reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].premise_type_flag=
         weight))
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_overlap = rows->
          qual[pploop].mark_weight_overlap
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_gap = rows->qual[
          pploop].mark_weight_gap
         ELSEIF ((reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].premise_type_flag=
         crcl))
          SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].has_overlap = rows->
          qual[pploop].mark_crcl_overlap
         ENDIF
         IF ((unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=routes
         ))
          SET stat = alterlist(reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].routes,
           size(unsortedreply->qual[cnt].parent_premise[pploop].premise[ploop].routes,5))
          FOR (p_list_loop = 1 TO size(rows->qual[pploop].sorted_routes,5))
            SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].routes[p_list_loop].
            drc_premise_list_id = rows->qual[pploop].sorted_routes[p_list_loop].drc_premise_list_id
            SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].routes[p_list_loop].
            parent_entity_id = rows->qual[pploop].sorted_routes[p_list_loop].parent_entity_id
            SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].routes[p_list_loop].
            route_disp = rows->qual[pploop].sorted_routes[p_list_loop].route_disp
            SET reply->qual[cnt].parent_premise[sorted_pp_index].premise[ploop].routes[p_list_loop].
            active_ind = rows->qual[pploop].sorted_routes[p_list_loop].active_ind
          ENDFOR
          CALL bederrorcheck("Error 012: Error while populating reoutes in routes of the reply")
         ENDIF
       ENDFOR
       SET stat = alterlist(reply->qual[cnt].parent_premise[sorted_pp_index].dose_range,size(
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range,5))
       FOR (dloop = 1 TO size(unsortedreply->qual[cnt].parent_premise[pploop].dose_range,5))
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].drc_dose_range_id =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].drc_dose_range_id
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].min_value =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].min_value
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].max_value =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].max_value
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].min_value_variance =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].min_value_variance
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].max_value_variance =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].max_value_variance
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].value_unit_cd =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].value_unit_cd
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].value_unit_display =
         uar_get_code_display(unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].
          value_unit_cd)
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].max_dose =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].max_dose
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].max_dose_unit_cd =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].max_dose_unit_cd
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].max_dose_unit_display
          = uar_get_code_display(unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].
          max_dose_unit_cd)
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].dose_days =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].dose_days
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].type_flag =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].type_flag
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].long_text_id =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].long_text_id
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].long_text =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].long_text
         SET reply->qual[cnt].parent_premise[sorted_pp_index].dose_range[dloop].active_ind =
         unsortedreply->qual[cnt].parent_premise[pploop].dose_range[dloop].active_ind
       ENDFOR
       CALL bederrorcheck("Error 013: Error while populating the premises in the reply")
     ENDFOR
     CALL bederrorcheck("Error 014: Error while populating the grouper related stuff in the reply")
   ENDFOR
 END ;Subroutine
 CALL echorecord(rows)
 CALL bedexitscript(0)
END GO
