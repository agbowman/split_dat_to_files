CREATE PROGRAM bed_aud_ccn_setup:dba
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
 FREE RECORD ccndata
 RECORD ccndata(
   1 ccnlist[*]
     2 ccn_id = f8
     2 cms_cert_number = vc
     2 ccn_name = vc
     2 tin = vc
     2 locations[*]
       3 location_cd = f8
       3 location_full_title = vc
       3 ptsvc_code = vc
       3 encounter_type_display = vc
     2 address_line_1 = vc
     2 address_line_2 = vc
     2 address_line_3 = vc
     2 address_line_4 = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 county = vc
     2 country = vc
     2 phone_num = vc
     2 extension_type = vc
     2 extension = vc
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
 DECLARE column_cnt = i4 WITH protect, constant(18)
 DECLARE col_cms_certification_number = i4 WITH protect, constant(1)
 DECLARE col_ccn_name = i4 WITH protect, constant(2)
 DECLARE col_tin = i4 WITH protect, constant(3)
 DECLARE col_location_full_title = i4 WITH protect, constant(4)
 DECLARE col_pos_code_display = i4 WITH protect, constant(5)
 DECLARE col_encounter_type_display = i4 WITH protect, constant(6)
 DECLARE col_address1 = i4 WITH protect, constant(7)
 DECLARE col_address2 = i4 WITH protect, constant(8)
 DECLARE col_address3 = i4 WITH protect, constant(9)
 DECLARE col_address4 = i4 WITH protect, constant(10)
 DECLARE col_city = i4 WITH protect, constant(11)
 DECLARE col_state = i4 WITH protect, constant(12)
 DECLARE col_zip = i4 WITH protect, constant(13)
 DECLARE col_county = i4 WITH protect, constant(14)
 DECLARE col_country = i4 WITH protect, constant(15)
 DECLARE col_phone = i4 WITH protect, constant(16)
 DECLARE col_extension_type = i4 WITH protect, constant(17)
 DECLARE col_extension = i4 WITH protect, constant(18)
 DECLARE getccnsetupdemographicinfo(dummyvar=i2) = i2
 DECLARE getccnsetupprogramenrollment(dummyvar=i2) = i2
 DECLARE getccnlocationdetails(dummyvar=i2) = i2
 DECLARE createfulllocationdisplay(location_cd=f8) = vc
 DECLARE populatereportheaders(dummyvar=i2) = i2
 DECLARE populatereportdata(dummyvar=i2) = i2
 CALL getccnsetupdemographicinfo(0)
 CALL getccnsetupprogramenrollment(0)
 CALL getccnlocationdetails(0)
 IF ((request->skip_volume_check_ind=0))
  IF (size(ccndata->ccnlist,5) > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(ccndata->ccnlist,5) > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL populatereportheaders(0)
 CALL populatereportdata(0)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_ccn_setup.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
 SUBROUTINE getccnsetupdemographicinfo(dummyvar)
   SELECT INTO "nl:"
    ccn_name = cnvtupper(bcr.ccn_name)
    FROM br_ccn bcr,
     address a,
     phone p
    PLAN (bcr
     WHERE bcr.br_ccn_id != 0.0
      AND bcr.active_ind=1
      AND bcr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (a
     WHERE a.parent_entity_name=outerjoin("BR_CCN")
      AND a.parent_entity_id=outerjoin(bcr.br_ccn_id)
      AND a.active_ind=outerjoin(1))
     JOIN (p
     WHERE p.parent_entity_name=outerjoin("BR_CCN")
      AND p.parent_entity_id=outerjoin(bcr.br_ccn_id)
      AND p.active_ind=outerjoin(1))
    ORDER BY ccn_name, bcr.br_ccn_id
    HEAD REPORT
     cnt = 0, stat = alterlist(ccndata->ccnlist,100)
    HEAD bcr.br_ccn_id
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(ccndata->ccnlist,(cnt+ 99))
     ENDIF
    DETAIL
     ccndata->ccnlist[cnt].ccn_id = bcr.br_ccn_id, ccndata->ccnlist[cnt].cms_cert_number = bcr
     .ccn_nbr_txt, ccndata->ccnlist[cnt].ccn_name = bcr.ccn_name,
     ccndata->ccnlist[cnt].tin = bcr.tax_id_nbr_txt, ccndata->ccnlist[cnt].address_line_1 = a
     .street_addr, ccndata->ccnlist[cnt].address_line_2 = a.street_addr2,
     ccndata->ccnlist[cnt].address_line_3 = a.street_addr3, ccndata->ccnlist[cnt].address_line_4 = a
     .street_addr4, ccndata->ccnlist[cnt].city = a.city,
     ccndata->ccnlist[cnt].state = uar_get_code_display(a.state_cd), ccndata->ccnlist[cnt].zip = a
     .zipcode, ccndata->ccnlist[cnt].county = uar_get_code_display(a.county_cd),
     ccndata->ccnlist[cnt].country = uar_get_code_display(a.country_cd), ccndata->ccnlist[cnt].
     phone_num = p.phone_num
    FOOT REPORT
     stat = alterlist(ccndata->ccnlist,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getccnsetupprogramenrollment(dummyvar)
  DECLARE index = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM br_ccn_extension bce,
    code_value cv
   PLAN (bce
    WHERE expand(index,1,size(ccndata->ccnlist,5),bce.br_ccn_id,ccndata->ccnlist[index].ccn_id)
     AND bce.active_ind=1
     AND bce.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bce.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cv
    WHERE cv.code_value=outerjoin(bce.medicaid_stage_cd)
     AND cv.code_value != outerjoin(0.0))
   ORDER BY bce.br_ccn_id
   HEAD bce.br_ccn_id
    cnt = locateval(index,1,size(ccndata->ccnlist,5),bce.br_ccn_id,ccndata->ccnlist[index].ccn_id)
   DETAIL
    IF (cnt > 0)
     IF (trim(bce.program_type_txt,5)="MEDICARE")
      ccndata->ccnlist[cnt].extension_type = bce.program_type_txt, ccndata->ccnlist[cnt].extension =
      cnvtstring(bce.medicare_year,4)
     ELSEIF (bce.program_type_txt="MEDICAID")
      ccndata->ccnlist[cnt].extension_type = bce.program_type_txt, ccndata->ccnlist[cnt].extension =
      cv.description
     ELSEIF (bce.program_type_txt="MEDICAID/MEDICARE")
      IF (bce.medicare_year=0)
       ccndata->ccnlist[cnt].extension_type = bce.program_type_txt, ccndata->ccnlist[cnt].extension
        = cv.description
      ELSE
       ccndata->ccnlist[cnt].extension_type = bce.program_type_txt, ccndata->ccnlist[cnt].extension
        = cnvtstring(bce.medicare_year,4)
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 END ;Subroutine
 SUBROUTINE getccnlocationdetails(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_ccn_loc_reltn blr,
     br_ccn_loc_ptsvc_reltn bclpr,
     code_value cv
    PLAN (blr
     WHERE expand(index,1,size(ccndata->ccnlist,5),blr.br_ccn_id,ccndata->ccnlist[index].ccn_id)
      AND blr.active_ind=1
      AND blr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND blr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (cv
     WHERE cv.code_value=blr.location_cd)
     JOIN (bclpr
     WHERE bclpr.br_ccn_loc_reltn_id=outerjoin(blr.br_ccn_loc_reltn_id))
    ORDER BY blr.br_ccn_id
    HEAD blr.br_ccn_id
     cnt = locateval(index,1,size(ccndata->ccnlist,5),blr.br_ccn_id,ccndata->ccnlist[index].ccn_id),
     loc_cnt = 0
    DETAIL
     IF (cnt > 0)
      loc_cnt = (loc_cnt+ 1)
      IF (mod(loc_cnt,100)=1)
       stat = alterlist(ccndata->ccnlist[cnt].locations,(loc_cnt+ 99))
      ENDIF
      ccndata->ccnlist[cnt].locations[loc_cnt].location_cd = blr.location_cd, ccndata->ccnlist[cnt].
      locations[loc_cnt].encounter_type_display = uar_get_code_display(bclpr.encntr_type_cd), ccndata
      ->ccnlist[cnt].locations[loc_cnt].ptsvc_code = evaluate(bclpr.ptsvc_code_nbr,0,"",cnvtstring(
        bclpr.ptsvc_code_nbr))
     ENDIF
    FOOT  blr.br_ccn_id
     stat = alterlist(ccndata->ccnlist[cnt].locations,loc_cnt)
    WITH nocounter, expand = 1
   ;end select
   FOR (x = 1 TO size(ccndata->ccnlist,5))
     FOR (y = 1 TO size(ccndata->ccnlist[x].locations,5))
       SET ccndata->ccnlist[x].locations[y].location_full_title = createfulllocationdisplay(ccndata->
        ccnlist[x].locations[y].location_cd)
     ENDFOR
   ENDFOR
   CALL bederrorcheck("Error001: getCCNLocationDetails")
 END ;Subroutine
 SUBROUTINE createfulllocationdisplay(location_cd)
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
   RETURN(full_name)
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[col_cms_certification_number].header_text = "CMS Certification Number"
   SET reply->collist[col_cms_certification_number].data_type = 1
   SET reply->collist[col_cms_certification_number].hide_ind = 0
   SET reply->collist[col_ccn_name].header_text = "CCN Name"
   SET reply->collist[col_ccn_name].data_type = 1
   SET reply->collist[col_ccn_name].hide_ind = 0
   SET reply->collist[col_tin].header_text = "TIN"
   SET reply->collist[col_tin].data_type = 1
   SET reply->collist[col_tin].hide_ind = 0
   SET reply->collist[col_location_full_title].header_text = "CCN Location"
   SET reply->collist[col_location_full_title].data_type = 1
   SET reply->collist[col_location_full_title].hide_ind = 0
   SET reply->collist[col_pos_code_display].header_text = "Place of Service Code"
   SET reply->collist[col_pos_code_display].data_type = 1
   SET reply->collist[col_pos_code_display].hide_ind = 0
   SET reply->collist[col_encounter_type_display].header_text = "Encounter Type"
   SET reply->collist[col_encounter_type_display].data_type = 1
   SET reply->collist[col_encounter_type_display].hide_ind = 0
   SET reply->collist[col_address1].header_text = "Address Line 1"
   SET reply->collist[col_address1].data_type = 1
   SET reply->collist[col_address1].hide_ind = 0
   SET reply->collist[col_address2].header_text = "Address Line 2"
   SET reply->collist[col_address2].data_type = 1
   SET reply->collist[col_address2].hide_ind = 0
   SET reply->collist[col_address3].header_text = "Address Line 3"
   SET reply->collist[col_address3].data_type = 1
   SET reply->collist[col_address3].hide_ind = 0
   SET reply->collist[col_address4].header_text = "Address Line 4"
   SET reply->collist[col_address4].data_type = 1
   SET reply->collist[col_address4].hide_ind = 0
   SET reply->collist[col_city].header_text = "City"
   SET reply->collist[col_city].data_type = 1
   SET reply->collist[col_city].hide_ind = 0
   SET reply->collist[col_state].header_text = "State"
   SET reply->collist[col_state].data_type = 1
   SET reply->collist[col_state].hide_ind = 0
   SET reply->collist[col_zip].header_text = "Zip Code"
   SET reply->collist[col_zip].data_type = 1
   SET reply->collist[col_zip].hide_ind = 0
   SET reply->collist[col_county].header_text = "County"
   SET reply->collist[col_county].data_type = 1
   SET reply->collist[col_county].hide_ind = 0
   SET reply->collist[col_country].header_text = "Country"
   SET reply->collist[col_country].data_type = 1
   SET reply->collist[col_country].hide_ind = 0
   SET reply->collist[col_phone].header_text = "Phone number"
   SET reply->collist[col_phone].data_type = 1
   SET reply->collist[col_phone].hide_ind = 0
   SET reply->collist[col_extension_type].header_text = "Program Enrollment"
   SET reply->collist[col_extension_type].data_type = 1
   SET reply->collist[col_extension_type].hide_ind = 0
   SET reply->collist[col_extension].header_text = "Program Enrollment Date"
   SET reply->collist[col_extension].data_type = 1
   SET reply->collist[col_extension].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FOR (ccnt = 1 TO size(ccndata->ccnlist,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET cnt = size(ccndata->ccnlist[ccnt].locations,5)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(ccndata->ccnlist[ccnt].locations,5))
      PLAN (d)
      ORDER BY cnvtupper(ccndata->ccnlist[ccnt].ccn_name), cnvtupper(ccndata->ccnlist[ccnt].
        locations[d.seq].location_full_title)
      DETAIL
       reply->rowlist[rowcnt].celllist[col_cms_certification_number].string_value = ccndata->ccnlist[
       ccnt].cms_cert_number, reply->rowlist[rowcnt].celllist[col_ccn_name].string_value = ccndata->
       ccnlist[ccnt].ccn_name, reply->rowlist[rowcnt].celllist[col_tin].string_value = ccndata->
       ccnlist[ccnt].tin,
       reply->rowlist[rowcnt].celllist[col_location_full_title].string_value = ccndata->ccnlist[ccnt]
       .locations[d.seq].location_full_title, reply->rowlist[rowcnt].celllist[col_pos_code_display].
       string_value = ccndata->ccnlist[ccnt].locations[d.seq].ptsvc_code, reply->rowlist[rowcnt].
       celllist[col_encounter_type_display].string_value = ccndata->ccnlist[ccnt].locations[d.seq].
       encounter_type_display,
       reply->rowlist[rowcnt].celllist[col_address1].string_value = ccndata->ccnlist[ccnt].
       address_line_1, reply->rowlist[rowcnt].celllist[col_address2].string_value = ccndata->ccnlist[
       ccnt].address_line_2, reply->rowlist[rowcnt].celllist[col_address3].string_value = ccndata->
       ccnlist[ccnt].address_line_3,
       reply->rowlist[rowcnt].celllist[col_address4].string_value = ccndata->ccnlist[ccnt].
       address_line_4, reply->rowlist[rowcnt].celllist[col_city].string_value = ccndata->ccnlist[ccnt
       ].city, reply->rowlist[rowcnt].celllist[col_state].string_value = ccndata->ccnlist[ccnt].state,
       reply->rowlist[rowcnt].celllist[col_zip].string_value = ccndata->ccnlist[ccnt].zip, reply->
       rowlist[rowcnt].celllist[col_county].string_value = ccndata->ccnlist[ccnt].county, reply->
       rowlist[rowcnt].celllist[col_country].string_value = ccndata->ccnlist[ccnt].country,
       reply->rowlist[rowcnt].celllist[col_phone].string_value = ccndata->ccnlist[ccnt].phone_num,
       reply->rowlist[rowcnt].celllist[col_extension_type].string_value = ccndata->ccnlist[ccnt].
       extension_type, reply->rowlist[rowcnt].celllist[col_extension].string_value = ccndata->
       ccnlist[ccnt].extension,
       cnt = (cnt - 1)
       IF (cnt > 0)
        rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
         rowlist[rowcnt].celllist,column_cnt)
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   CALL bederrorcheck("Error005: populateReportData")
 END ;Subroutine
END GO
