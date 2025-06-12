CREATE PROGRAM bed_aud_cpc_ep:dba
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
 FREE RECORD cpcdata
 RECORD cpcdata(
   1 cpcs[*]
     2 br_cpc_id = f8
     2 br_cpc_name = vc
     2 tax_id_nbr_txt = vc
     2 cpc_site_id_txt = vc
     2 providers[*]
       3 provider_id = f8
       3 provider_name = vc
       3 provider_tin = vc
       3 provider_npi = vc
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
 DECLARE cpc_name = i4 WITH protect, constant(1)
 DECLARE site_id = i4 WITH protect, constant(2)
 DECLARE tin = i4 WITH protect, constant(3)
 DECLARE ep_name = i4 WITH protect, constant(4)
 DECLARE ep_tin = i4 WITH protect, constant(5)
 DECLARE ep_npi = i4 WITH protect, constant(6)
 DECLARE column_cnt = i4 WITH protect, constant(6)
 DECLARE total_report_rows = i4 WITH protect
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE getcpcswitheligibleproviders(dummyvar=i2) = i2
 DECLARE populatereportheaders(dummyvar=i2) = i2
 DECLARE populatereportdata(dummyvar=i2) = i2
 SET total_report_rows = 0
 CALL getcpcswitheligibleproviders(0)
 IF ((request->skip_volume_check_ind=0))
  IF (total_report_rows > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (total_report_rows > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL populatereportheaders(0)
 CALL populatereportdata(0)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_cpc_ep.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
 SUBROUTINE getcpcswitheligibleproviders(dummyvar)
   CALL bedlogmessage("getCPCsWithEligibleProviders","Entering ...")
   SET cpc_cnt = 0
   SET ep_cnt = 0
   SELECT INTO "nl:"
    FROM br_cpc bc,
     br_cpc_elig_prov_reltn bcepr,
     br_eligible_provider bep,
     prsnl p
    PLAN (bc
     WHERE bc.br_cpc_id > 0.0
      AND bc.active_ind=1
      AND bc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bcepr
     WHERE bcepr.br_cpc_id=bc.br_cpc_id
      AND bcepr.active_ind=1
      AND bcepr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bcepr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bep
     WHERE bep.br_eligible_provider_id=bcepr.br_eligible_provider_id
      AND bep.logical_domain_id=logical_domain_id)
     JOIN (p
     WHERE bep.provider_id=p.person_id)
    ORDER BY bc.br_cpc_name
    HEAD bc.br_cpc_id
     cpc_cnt = (cpc_cnt+ 1), ep_cnt = 0, stat = alterlist(cpcdata->cpcs,cpc_cnt),
     cpcdata->cpcs[cpc_cnt].br_cpc_id = bc.br_cpc_id, cpcdata->cpcs[cpc_cnt].br_cpc_name = bc
     .br_cpc_name, cpcdata->cpcs[cpc_cnt].tax_id_nbr_txt = bc.tax_id_nbr_txt,
     cpcdata->cpcs[cpc_cnt].cpc_site_id_txt = bc.cpc_site_id_txt
    DETAIL
     ep_cnt = (ep_cnt+ 1), stat = alterlist(cpcdata->cpcs[cpc_cnt].providers,ep_cnt), cpcdata->cpcs[
     cpc_cnt].providers[ep_cnt].provider_id = bep.br_eligible_provider_id,
     cpcdata->cpcs[cpc_cnt].providers[ep_cnt].provider_name = p.name_full_formatted, cpcdata->cpcs[
     cpc_cnt].providers[ep_cnt].provider_tin = bep.tax_id_nbr_txt, cpcdata->cpcs[cpc_cnt].providers[
     ep_cnt].provider_npi = bep.national_provider_nbr_txt,
     total_report_rows = (total_report_rows+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error001:  getCPCsWithEligibleProviders")
   CALL bedlogmessage("getCPCsWithEligibleProviders","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   CALL bedlogmessage("populateReportHeaders","Entering ...")
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[cpc_name].header_text = "Practice Site Name"
   SET reply->collist[cpc_name].data_type = 1
   SET reply->collist[cpc_name].hide_ind = 0
   SET reply->collist[site_id].header_text = "Practice Site ID"
   SET reply->collist[site_id].data_type = 1
   SET reply->collist[site_id].hide_ind = 0
   SET reply->collist[tin].header_text = "Practice Site TIN"
   SET reply->collist[tin].data_type = 1
   SET reply->collist[tin].hide_ind = 0
   SET reply->collist[ep_name].header_text = "Eligible Clinician"
   SET reply->collist[ep_name].data_type = 1
   SET reply->collist[ep_name].hide_ind = 0
   SET reply->collist[ep_tin].header_text = "Eligible Clinician TIN"
   SET reply->collist[ep_tin].data_type = 1
   SET reply->collist[ep_tin].hide_ind = 0
   SET reply->collist[ep_npi].header_text = "Eligible Clinician NPI"
   SET reply->collist[ep_npi].data_type = 1
   SET reply->collist[ep_npi].hide_ind = 0
   CALL bederrorcheck("Error002: populateReportHeaders")
   CALL bedlogmessage("populateReportHeaders","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   CALL bedlogmessage("populateReportData","Entering ...")
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FOR (pcnt = 1 TO size(cpcdata->cpcs,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET cnt = size(cpcdata->cpcs[pcnt].providers,5)
     IF (cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(cpcdata->cpcs[pcnt].providers,5))
       PLAN (d)
       ORDER BY cnvtupper(cpcdata->cpcs[pcnt].br_cpc_name), cnvtupper(cpcdata->cpcs[pcnt].providers[d
         .seq].provider_name)
       DETAIL
        reply->rowlist[rowcnt].celllist[cpc_name].string_value = cpcdata->cpcs[pcnt].br_cpc_name,
        reply->rowlist[rowcnt].celllist[site_id].string_value = cpcdata->cpcs[pcnt].cpc_site_id_txt,
        reply->rowlist[rowcnt].celllist[tin].string_value = cpcdata->cpcs[pcnt].tax_id_nbr_txt,
        reply->rowlist[rowcnt].celllist[ep_name].string_value = cpcdata->cpcs[pcnt].providers[d.seq].
        provider_name, reply->rowlist[rowcnt].celllist[ep_tin].string_value = cpcdata->cpcs[pcnt].
        providers[d.seq].provider_tin, reply->rowlist[rowcnt].celllist[ep_npi].string_value = cpcdata
        ->cpcs[pcnt].providers[d.seq].provider_npi,
        cnt = (cnt - 1)
        IF (cnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error003: populateReportData")
   CALL bedlogmessage("populateReportData","Exiting ...")
 END ;Subroutine
END GO
