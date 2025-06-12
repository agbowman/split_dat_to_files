CREATE PROGRAM bed_aud_cpc:dba
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
     2 locations[*]
       3 location_cd = f8
       3 location_full_title = vc
     2 address
       3 street_line_1 = vc
       3 street_line_2 = vc
       3 street_line_3 = vc
       3 street_line_4 = vc
       3 city = vc
       3 state = vc
       3 zip = vc
       3 county = vc
       3 country = vc
       3 contact = vc
       3 comment = vc
     2 phone
       3 phone_format = vc
       3 phone_num = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
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
 EXECUTE lh_bedrock_refresh
 CALL bedbeginscript(0)
 DECLARE cpc_name = i4 WITH protect, constant(1)
 DECLARE site_id = i4 WITH protect, constant(2)
 DECLARE tin = i4 WITH protect, constant(3)
 DECLARE cpc_location = i4 WITH protect, constant(4)
 DECLARE address_street1 = i4 WITH protect, constant(5)
 DECLARE address_street2 = i4 WITH protect, constant(6)
 DECLARE address_street3 = i4 WITH protect, constant(7)
 DECLARE address_street4 = i4 WITH protect, constant(8)
 DECLARE address_city = i4 WITH protect, constant(9)
 DECLARE address_state = i4 WITH protect, constant(10)
 DECLARE address_zip = i4 WITH protect, constant(11)
 DECLARE address_county = i4 WITH protect, constant(12)
 DECLARE address_country = i4 WITH protect, constant(13)
 DECLARE address_contact = i4 WITH protect, constant(14)
 DECLARE address_comment = i4 WITH protect, constant(15)
 DECLARE phone_format = i4 WITH protect, constant(16)
 DECLARE phone_number = i4 WITH protect, constant(17)
 DECLARE phone_extension = i4 WITH protect, constant(18)
 DECLARE phone_contact = i4 WITH protect, constant(19)
 DECLARE phone_comment = i4 WITH protect, constant(20)
 DECLARE column_cnt = i4 WITH protect, constant(20)
 DECLARE total_report_rows = i4 WITH protect
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 DECLARE getcpcs(dummyvar=i2) = i2
 DECLARE getcpcaddress(dummyvar=i2) = null
 DECLARE getcpcphone(dummyvar=i2) = null
 DECLARE createfulllocationdisplay(location_cd=f8) = vc
 DECLARE populatereportheaders(dummyvar=i2) = i2
 DECLARE populatereportdata(dummyvar=i2) = i2
 SET total_report_rows = 0
 CALL getcpcs(0)
 CALL getcpcaddress(0)
 CALL getcpcphone(0)
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
  SET reply->output_filename = build("bed_aud_cpc.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
 SUBROUTINE getcpcs(dummyvar)
   CALL bedlogmessage("getCPCs","Entering ...")
   SET cpc_cnt = 0
   SET loc_cnt = 0
   SELECT INTO "nl:"
    FROM br_cpc bc,
     lh_br_cpc_loc_reltn bclr
    PLAN (bc
     WHERE bc.br_cpc_id > 0.0
      AND bc.active_ind=1
      AND bc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND bc.logical_domain_id=logical_domain_id)
     JOIN (bclr
     WHERE bclr.br_cpc_id=bc.br_cpc_id
      AND bclr.active_ind=1
      AND bclr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bclr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY bc.br_cpc_name
    HEAD bc.br_cpc_id
     cpc_cnt = (cpc_cnt+ 1), loc_cnt = 0, stat = alterlist(cpcdata->cpcs,cpc_cnt),
     cpcdata->cpcs[cpc_cnt].br_cpc_id = bc.br_cpc_id, cpcdata->cpcs[cpc_cnt].br_cpc_name = bc
     .br_cpc_name, cpcdata->cpcs[cpc_cnt].tax_id_nbr_txt = bc.tax_id_nbr_txt,
     cpcdata->cpcs[cpc_cnt].cpc_site_id_txt = bc.cpc_site_id_txt
    DETAIL
     loc_cnt = (loc_cnt+ 1), stat = alterlist(cpcdata->cpcs[cpc_cnt].locations,loc_cnt), cpcdata->
     cpcs[cpc_cnt].locations[loc_cnt].location_cd = bclr.location_cd,
     total_report_rows = (total_report_rows+ 1)
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(cpcdata->cpcs,5))
     FOR (y = 1 TO size(cpcdata->cpcs[x].locations,5))
       SET cpcdata->cpcs[x].locations[y].location_full_title = createfulllocationdisplay(cpcdata->
        cpcs[x].locations[y].location_cd)
     ENDFOR
   ENDFOR
   CALL bederrorcheck("Error001: getCPCs")
   CALL bedlogmessage("getCPCs","Exiting ...")
 END ;Subroutine
 SUBROUTINE getcpcaddress(dummyvar)
   CALL bedlogmessage("getCPCAddress","Entering ...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cpcdata->cpcs,5))),
     address a
    PLAN (d)
     JOIN (a
     WHERE a.parent_entity_name="BR_CPC"
      AND (a.parent_entity_id=cpcdata->cpcs[d.seq].br_cpc_id)
      AND a.active_ind=1)
    DETAIL
     cpcdata->cpcs[d.seq].address.street_line_1 = a.street_addr, cpcdata->cpcs[d.seq].address.
     street_line_2 = a.street_addr2, cpcdata->cpcs[d.seq].address.street_line_3 = a.street_addr3,
     cpcdata->cpcs[d.seq].address.street_line_4 = a.street_addr4, cpcdata->cpcs[d.seq].address.city
      = a.city, cpcdata->cpcs[d.seq].address.state = uar_get_code_display(a.state_cd),
     cpcdata->cpcs[d.seq].address.city = a.city, cpcdata->cpcs[d.seq].address.zip = a.zipcode,
     cpcdata->cpcs[d.seq].address.county = uar_get_code_display(a.county_cd),
     cpcdata->cpcs[d.seq].address.country = uar_get_code_display(a.country_cd), cpcdata->cpcs[d.seq].
     address.contact = a.contact_name, cpcdata->cpcs[d.seq].address.comment = a.comment_txt
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error002: getCPCAddress")
   CALL bedlogmessage("getCPCs","Exiting ...")
 END ;Subroutine
 SUBROUTINE getcpcphone(dummyvar)
   CALL bedlogmessage("getCPCPhone","Entering ...")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(cpcdata->cpcs,5))),
     phone p
    PLAN (d)
     JOIN (p
     WHERE p.parent_entity_name="BR_CPC"
      AND (p.parent_entity_id=cpcdata->cpcs[d.seq].br_cpc_id)
      AND p.active_ind=1)
    DETAIL
     cpcdata->cpcs[d.seq].phone.phone_format = uar_get_code_display(p.phone_format_cd), cpcdata->
     cpcs[d.seq].phone.phone_num = p.phone_num, cpcdata->cpcs[d.seq].phone.contact = p.contact,
     cpcdata->cpcs[d.seq].phone.call_instruction = p.call_instruction, cpcdata->cpcs[d.seq].phone.
     extension = p.extension
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error003: getCPCPhone")
   CALL bedlogmessage("getCPCPhone","Exiting ...")
 END ;Subroutine
 SUBROUTINE createfulllocationdisplay(location_cd)
   CALL bedlogmessage("createFullLocationDisplay","Entering ...")
   DECLARE full_name = vc
   SELECT INTO "nl:"
    FROM code_value cv1,
     location_group lg1,
     code_value cv2,
     location_group lg2,
     code_value cv3
    PLAN (cv1
     WHERE cv1.code_value=location_cd)
     JOIN (lg1
     WHERE lg1.child_loc_cd=cv1.code_value)
     JOIN (cv2
     WHERE cv2.code_value=lg1.parent_loc_cd)
     JOIN (lg2
     WHERE lg2.child_loc_cd=cv2.code_value)
     JOIN (cv3
     WHERE cv3.code_value=lg2.parent_loc_cd)
    DETAIL
     full_name = build2(trim(cv3.display),"/",trim(cv2.display),"/",trim(cv1.display))
     IF (cv1.active_ind=0)
      full_name = build2(full_name," <inactive>")
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error004: createFullLocationDisplay")
   CALL bedlogmessage("createFullLocationDisplay","Exiting ...")
   RETURN(full_name)
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
   SET reply->collist[cpc_location].header_text = "Practice Site Location"
   SET reply->collist[cpc_location].data_type = 1
   SET reply->collist[cpc_location].hide_ind = 0
   SET reply->collist[address_street1].header_text = "Practice Site Address"
   SET reply->collist[address_street1].data_type = 1
   SET reply->collist[address_street1].hide_ind = 0
   SET reply->collist[address_street2].header_text = "Practice Site Address Line 2"
   SET reply->collist[address_street2].data_type = 1
   SET reply->collist[address_street2].hide_ind = 0
   SET reply->collist[address_street3].header_text = "Practice Site Address Line 3"
   SET reply->collist[address_street3].data_type = 1
   SET reply->collist[address_street3].hide_ind = 0
   SET reply->collist[address_street4].header_text = "Practice Site Address Line 4"
   SET reply->collist[address_street4].data_type = 1
   SET reply->collist[address_street4].hide_ind = 0
   SET reply->collist[address_city].header_text = "Practice Site City"
   SET reply->collist[address_city].data_type = 1
   SET reply->collist[address_city].hide_ind = 0
   SET reply->collist[address_state].header_text = "Practice Site State"
   SET reply->collist[address_state].data_type = 1
   SET reply->collist[address_state].hide_ind = 0
   SET reply->collist[address_zip].header_text = "Practice Site Zip Code"
   SET reply->collist[address_zip].data_type = 1
   SET reply->collist[address_zip].hide_ind = 0
   SET reply->collist[address_county].header_text = "Practice Site County"
   SET reply->collist[address_county].data_type = 1
   SET reply->collist[address_county].hide_ind = 0
   SET reply->collist[address_country].header_text = "Practice Site Country"
   SET reply->collist[address_country].data_type = 1
   SET reply->collist[address_country].hide_ind = 0
   SET reply->collist[address_contact].header_text = "Contact Name"
   SET reply->collist[address_contact].data_type = 1
   SET reply->collist[address_contact].hide_ind = 0
   SET reply->collist[address_comment].header_text = "Additional Information"
   SET reply->collist[address_comment].data_type = 1
   SET reply->collist[address_comment].hide_ind = 0
   SET reply->collist[address_comment].header_text = "Additional Information"
   SET reply->collist[address_comment].data_type = 1
   SET reply->collist[address_comment].hide_ind = 0
   SET reply->collist[phone_format].header_text = "Practice Site Phone Number Format"
   SET reply->collist[phone_format].data_type = 1
   SET reply->collist[phone_format].hide_ind = 0
   SET reply->collist[phone_number].header_text = "Practice Site Phone Number"
   SET reply->collist[phone_number].data_type = 1
   SET reply->collist[phone_number].hide_ind = 0
   SET reply->collist[phone_extension].header_text = "Practice Site Phone Number Extension"
   SET reply->collist[phone_extension].data_type = 1
   SET reply->collist[phone_extension].hide_ind = 0
   SET reply->collist[phone_contact].header_text = "Contact Name"
   SET reply->collist[phone_contact].data_type = 1
   SET reply->collist[phone_contact].hide_ind = 0
   SET reply->collist[phone_comment].header_text = "Additional Information"
   SET reply->collist[phone_comment].data_type = 1
   SET reply->collist[phone_comment].hide_ind = 0
   CALL bederrorcheck("Error004: populateReportHeaders")
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
     SET cnt = size(cpcdata->cpcs[pcnt].locations,5)
     IF (cnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(cpcdata->cpcs[pcnt].locations,5))
       PLAN (d)
       ORDER BY cnvtupper(cpcdata->cpcs[pcnt].br_cpc_name), cnvtupper(cpcdata->cpcs[pcnt].locations[d
         .seq].location_full_title)
       DETAIL
        reply->rowlist[rowcnt].celllist[cpc_name].string_value = cpcdata->cpcs[pcnt].br_cpc_name,
        reply->rowlist[rowcnt].celllist[site_id].string_value = cpcdata->cpcs[pcnt].cpc_site_id_txt,
        reply->rowlist[rowcnt].celllist[tin].string_value = cpcdata->cpcs[pcnt].tax_id_nbr_txt,
        reply->rowlist[rowcnt].celllist[cpc_location].string_value = cpcdata->cpcs[pcnt].locations[d
        .seq].location_full_title, reply->rowlist[rowcnt].celllist[address_street1].string_value =
        cpcdata->cpcs[pcnt].address.street_line_1, reply->rowlist[rowcnt].celllist[address_street2].
        string_value = cpcdata->cpcs[pcnt].address.street_line_2,
        reply->rowlist[rowcnt].celllist[address_street3].string_value = cpcdata->cpcs[pcnt].address.
        street_line_3, reply->rowlist[rowcnt].celllist[address_street4].string_value = cpcdata->cpcs[
        pcnt].address.street_line_4, reply->rowlist[rowcnt].celllist[address_city].string_value =
        cpcdata->cpcs[pcnt].address.city,
        reply->rowlist[rowcnt].celllist[address_state].string_value = cpcdata->cpcs[pcnt].address.
        state, reply->rowlist[rowcnt].celllist[address_zip].string_value = cpcdata->cpcs[pcnt].
        address.zip, reply->rowlist[rowcnt].celllist[address_county].string_value = cpcdata->cpcs[
        pcnt].address.county,
        reply->rowlist[rowcnt].celllist[address_country].string_value = cpcdata->cpcs[pcnt].address.
        country, reply->rowlist[rowcnt].celllist[address_contact].string_value = cpcdata->cpcs[pcnt].
        address.contact, reply->rowlist[rowcnt].celllist[address_comment].string_value = cpcdata->
        cpcs[pcnt].address.comment,
        reply->rowlist[rowcnt].celllist[phone_format].string_value = cpcdata->cpcs[pcnt].phone.
        phone_format, reply->rowlist[rowcnt].celllist[phone_number].string_value = cpcdata->cpcs[pcnt
        ].phone.phone_num, reply->rowlist[rowcnt].celllist[phone_extension].string_value = cpcdata->
        cpcs[pcnt].phone.extension,
        reply->rowlist[rowcnt].celllist[phone_contact].string_value = cpcdata->cpcs[pcnt].phone.
        contact, reply->rowlist[rowcnt].celllist[phone_comment].string_value = cpcdata->cpcs[pcnt].
        phone.call_instruction, cnt = (cnt - 1)
        IF (cnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error005: populateReportData")
   CALL bedlogmessage("populateReportData","Exiting ...")
 END ;Subroutine
END GO
