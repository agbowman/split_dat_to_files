CREATE PROGRAM bed_aud_gpro_cqm_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD gprodata
 RECORD gprodata(
   1 gprolist[*]
     2 gpro_id = f8
     2 gpro_name = vc
     2 tin = vc
     2 measures[*]
       3 measure_id = f8
       3 measure_iden = vc
       3 adult_pediatric_type = vc
       3 measure_description = vc
       3 domain = vc
       3 mu_year = vc
       3 high_priority_ind = i2
       3 outcome_ind = i2
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
 DECLARE column_cnt = i4 WITH protect, constant(8)
 DECLARE getgproinfo(dummyvar=i2) = i2
 DECLARE getgprocqmmeasures(dummyvar=i2) = i2
 DECLARE populatereportheaders(dummyvar=i2) = i2
 DECLARE populatereportdata(dummyvar=i2) = i2
 CALL getgproinfo(0)
 IF (size(gprodata->gprolist,5) > 0)
  CALL getgprocqmmeasures(0)
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (size(gprodata->gprolist,5) > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(gprodata->gprolist,5) > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL populatereportheaders(0)
 CALL populatereportdata(0)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_gpro_cqm_measures.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(1)
 SUBROUTINE getgproinfo(dummyvar)
   CALL bedlogmessage("getGPROInfo ","Entering ...")
   DECLARE k = i4 WITH protect, noconstant(1)
   IF ( NOT (validate(getgprorequest,0)))
    RECORD getgprorequest(
      1 groups[*]
        2 br_gpro_id = f8
      1 only_gpro_flag = i2
    ) WITH protect
   ENDIF
   IF ( NOT (validate(getgproreply,0)))
    RECORD getgproreply(
      1 gpros[*]
        2 gpro_id = f8
        2 gpro_name = vc
        2 tin = vc
        2 providers[*]
          3 provider_id = f8
          3 provider_name = vc
          3 tin = vc
          3 npi = vc
          3 active_ind = i2
          3 effective_ind = i2
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
        2 submit_type_flag = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
   ENDIF
   SET getgprorequest->only_gpro_flag = 1
   EXECUTE bed_get_gpros  WITH replace("REQUEST",getgprorequest), replace("REPLY",getgproreply)
   IF ((getgproreply->status_data.status != "S"))
    CALL bedlogmessage("getGPROInfo ","bed_get_gpros did not return success.")
    IF (validate(debug,0)=1)
     CALL echorecord(getgprorequest)
     CALL echorecord(getgproreply)
     CALL bederror("Failure calling bed_get_gpros")
    ENDIF
   ENDIF
   IF (size(getgproreply->gpros,5) > 0)
    SET stat = alterlist(gprodata->gprolist,size(getgproreply->gpros,5))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(getgproreply->gpros,5))
     PLAN (d)
     ORDER BY cnvtupper(getgproreply->gpros[d.seq].gpro_name)
     DETAIL
      gprodata->gprolist[k].gpro_id = getgproreply->gpros[d.seq].gpro_id, gprodata->gprolist[k].
      gpro_name = getgproreply->gpros[d.seq].gpro_name, gprodata->gprolist[k].tin = getgproreply->
      gpros[d.seq].tin,
      k = (k+ 1)
     WITH nocounter
    ;end select
   ENDIF
   CALL bedlogmessage("getGPROInfo ","Exiting ...")
 END ;Subroutine
 SUBROUTINE getgprocqmmeasures(dummyvar)
   CALL bedlogmessage("getGPROCQMMeasures","Entering ...")
   DECLARE measure_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(gprodata->gprolist,5)),
     lh_cqm_meas_svc_entity_r r,
     lh_cqm_meas bcm,
     lh_cqm_domain bcd
    PLAN (d)
     JOIN (r
     WHERE r.parent_entity_name="BR_GPRO"
      AND (r.parent_entity_id=gprodata->gprolist[d.seq].gpro_id)
      AND r.active_ind=1
      AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bcm
     WHERE bcm.lh_cqm_meas_id=r.lh_cqm_meas_id
      AND bcm.svc_entity_type_flag=1)
     JOIN (bcd
     WHERE bcd.lh_cqm_domain_id=bcm.lh_cqm_domain_id)
    ORDER BY r.parent_entity_id
    HEAD r.parent_entity_id
     measure_cnt = 0
    DETAIL
     measure_cnt = (measure_cnt+ 1), stat = alterlist(gprodata->gprolist[d.seq].measures,measure_cnt),
     gprodata->gprolist[d.seq].measures[measure_cnt].measure_id = bcm.lh_cqm_meas_id,
     gprodata->gprolist[d.seq].measures[measure_cnt].measure_iden = bcm.measure_short_desc, gprodata
     ->gprolist[d.seq].measures[measure_cnt].domain = bcd.lh_cqm_domain_name, gprodata->gprolist[d
     .seq].measures[measure_cnt].mu_year = substring((textlen(trim(bcm.meas_ident,7)) - 3),textlen(
       trim(bcm.meas_ident,7)),trim(bcm.meas_ident,7))
     IF ((((gprodata->gprolist[d.seq].measures[measure_cnt].mu_year="2014")) OR ((gprodata->gprolist[
     d.seq].measures[measure_cnt].mu_year="2015"))) )
      gprodata->gprolist[d.seq].measures[measure_cnt].mu_year = "2014/2015"
     ENDIF
     gprodata->gprolist[d.seq].measures[measure_cnt].high_priority_ind = bcm.high_priority_ind,
     gprodata->gprolist[d.seq].measures[measure_cnt].outcome_ind = bcm.outcome_ind, gprodata->
     gprolist[d.seq].measures[measure_cnt].measure_description = bcm.meas_desc
    WITH nocounter
   ;end select
   CALL bedlogmessage("getGPROCQMMeasures","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   CALL bedlogmessage("populateReportHeaders","Entering ...")
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[1].header_text = "TIN Name"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Tax ID Number"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Measure Year"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Measure ID"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Description"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Domain"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "High Priority"
   SET reply->collist[7].data_type = 1
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = "Outcome"
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
   CALL bedlogmessage("populateReportHeaders","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   CALL bedlogmessage("populateReportData","Entering ...")
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FOR (pcnt = 1 TO size(gprodata->gprolist,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET reply->rowlist[rowcnt].celllist[1].string_value = gprodata->gprolist[pcnt].gpro_name
     SET reply->rowlist[rowcnt].celllist[2].string_value = gprodata->gprolist[pcnt].tin
     SET cnt = size(gprodata->gprolist[pcnt].measures,5)
     IF (cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(gprodata->gprolist[pcnt].measures,5))
       PLAN (d)
       ORDER BY gprodata->gprolist[pcnt].measures[d.seq].mu_year, gprodata->gprolist[pcnt].measures[d
        .seq].measure_iden, gprodata->gprolist[pcnt].measures[d.seq].measure_description
       DETAIL
        reply->rowlist[rowcnt].celllist[1].string_value = gprodata->gprolist[pcnt].gpro_name, reply->
        rowlist[rowcnt].celllist[2].string_value = gprodata->gprolist[pcnt].tin, reply->rowlist[
        rowcnt].celllist[3].string_value = gprodata->gprolist[pcnt].measures[d.seq].mu_year,
        reply->rowlist[rowcnt].celllist[4].string_value = gprodata->gprolist[pcnt].measures[d.seq].
        measure_iden, reply->rowlist[rowcnt].celllist[5].string_value = gprodata->gprolist[pcnt].
        measures[d.seq].measure_description, reply->rowlist[rowcnt].celllist[6].string_value =
        gprodata->gprolist[pcnt].measures[d.seq].domain
        IF ((gprodata->gprolist[pcnt].measures[d.seq].high_priority_ind=1))
         reply->rowlist[rowcnt].celllist[7].string_value = "High Priority"
        ELSE
         reply->rowlist[rowcnt].celllist[7].string_value = ""
        ENDIF
        IF ((gprodata->gprolist[pcnt].measures[d.seq].outcome_ind=1))
         reply->rowlist[rowcnt].celllist[8].string_value = "Outcome"
        ELSE
         reply->rowlist[rowcnt].celllist[8].string_value = ""
        ENDIF
        cnt = (cnt - 1)
        IF (cnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateReportData","Exiting ...")
 END ;Subroutine
END GO
