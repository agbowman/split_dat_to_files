CREATE PROGRAM bed_aud_reg_auto_discharge:dba
 CALL echo("*****bed_aud_reg_auto_discharge.prg - 0000002 / REVCYCREG-23239 *****")
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
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
 DECLARE l_tot_col = i4 WITH constant(10), protect
 DECLARE l_col_ps = i4 WITH constant(1), protect
 DECLARE l_col_org = i4 WITH constant(2), protect
 DECLARE l_col_enctype = i4 WITH constant(3), protect
 DECLARE l_col_startfld = i4 WITH constant(4), protect
 DECLARE l_col_days = i4 WITH constant(5), protect
 DECLARE l_col_endfld = i4 WITH constant(6), protect
 DECLARE l_col_enddisp = i4 WITH constant(7), protect
 DECLARE l_col_endval = i4 WITH constant(8), protect
 DECLARE l_col_outboundind = i4 WITH constant(9), protect
 DECLARE l_col_futureappt = i4 WITH constant(10), protect
 DECLARE s_auto_disch_param_name = vc WITH constant("AUTO_DISCH*"), protect
 DECLARE lrowcnt = i4 WITH noconstant(0), protect
 DECLARE lhighvolumecnt = i4 WITH noconstant(0), protect
 DECLARE bneworgflag = i2 WITH noconstant(false), protect
 DECLARE lautodischoutboundind = i4 WITH noconstant(0), protect
 DECLARE lautodischa03ind = i4 WITH noconstant(0), protect
 DECLARE bautodischoutboundind = i2 WITH noconstant(false), protect
 DECLARE bautodischa03ind = i2 WITH noconstant(false), protect
 DECLARE soutboundmsgtype = vc WITH noconstant(""), protect
 DECLARE soutboundmsg = vc WITH noconstant(""), protect
 DECLARE loldautodischoutboundind = i4 WITH noconstant(0), protect
 SET lhighvolumecnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM encntr_type_params etp
   PLAN (etp
    WHERE etp.encntr_type_cd > 0.0)
   DETAIL
    lhighvolumecnt = hv_cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   hv_rc_param_count = count(*)
   FROM pm_auto_disch_parm_set_r rc_params
   PLAN (rc_params
    WHERE rc_params.encntr_type_cd > 0.0)
   DETAIL
    lhighvolumecnt = (lhighvolumecnt+ hv_rc_param_count)
   WITH nocounter
  ;end select
  IF (lhighvolumecnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (lhighvolumecnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,l_tot_col)
 SET reply->collist[l_col_ps].header_text = "Parameter Set Name"
 SET reply->collist[l_col_ps].data_type = 1
 SET reply->collist[l_col_ps].hide_ind = 0
 SET reply->collist[l_col_org].header_text = "Organization/Facility"
 SET reply->collist[l_col_org].data_type = 1
 SET reply->collist[l_col_org].hide_ind = 0
 SET reply->collist[l_col_enctype].header_text = "Encounter Type (Patient Type)"
 SET reply->collist[l_col_enctype].data_type = 1
 SET reply->collist[l_col_enctype].hide_ind = 0
 SET reply->collist[l_col_startfld].header_text = "Start Field"
 SET reply->collist[l_col_startfld].data_type = 1
 SET reply->collist[l_col_startfld].hide_ind = 0
 SET reply->collist[l_col_days].header_text = "Number of Days"
 SET reply->collist[l_col_days].data_type = 1
 SET reply->collist[l_col_days].hide_ind = 0
 SET reply->collist[l_col_endfld].header_text = "End Field"
 SET reply->collist[l_col_endfld].data_type = 1
 SET reply->collist[l_col_endfld].hide_ind = 0
 SET reply->collist[l_col_enddisp].header_text = "Discharge Disposition"
 SET reply->collist[l_col_enddisp].data_type = 1
 SET reply->collist[l_col_enddisp].hide_ind = 0
 SET reply->collist[l_col_endval].header_text = "Date and Time Format"
 SET reply->collist[l_col_endval].data_type = 1
 SET reply->collist[l_col_endval].hide_ind = 0
 SET reply->collist[l_col_outboundind].header_text = "Outbound Indicator"
 SET reply->collist[l_col_outboundind].data_type = 1
 SET reply->collist[l_col_outboundind].hide_ind = 0
 SET reply->collist[l_col_futureappt].header_text = "Future Appointment Check"
 SET reply->collist[l_col_futureappt].data_type = 1
 SET reply->collist[l_col_futureappt].hide_ind = 0
 SET stat = alterlist(reply->rowlist,50)
 SET bneworgflag = false
 SELECT INTO "nl:"
  FROM encntr_type_params e
  PLAN (e
   WHERE e.param_name="AUTO_DISCH_OUTBOUND_IND"
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   loldautodischoutboundind = e.value_nbr
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.org_name, cv.display, etp.param_name,
  etp.value_string, etp.value_nbr
  FROM encntr_type_params etp,
   code_value cv,
   organization o,
   code_value cv1
  PLAN (etp
   WHERE etp.encntr_type_cd > 0.0
    AND etp.param_name=patstring(s_auto_disch_param_name))
   JOIN (cv
   WHERE cv.code_value=etp.encntr_type_cd
    AND cv.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(etp.value_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (o
   WHERE o.organization_id=outerjoin(etp.organization_id)
    AND o.active_ind=outerjoin(1))
  ORDER BY o.org_name_key, cv.display
  HEAD o.org_name
   lrowcnt += 1, bneworgflag = true
   IF (mod(lrowcnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ lrowcnt))
   ENDIF
   stat = alterlist(reply->rowlist[lrowcnt].celllist,l_tot_col), reply->rowlist[lrowcnt].celllist[
   l_col_ps].string_value = "PM_UPT_AUTO_DISCHARGE", reply->rowlist[lrowcnt].celllist[
   l_col_futureappt].string_value = "N/A"
   IF (loldautodischoutboundind=1)
    reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "Yes (Global Flag)"
   ELSE
    reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "No"
   ENDIF
   IF (o.org_name > " ")
    reply->rowlist[lrowcnt].celllist[l_col_org].string_value = o.org_name
   ELSE
    reply->rowlist[lrowcnt].celllist[l_col_org].string_value = "All Organizations"
   ENDIF
   reply->rowlist[lrowcnt].celllist[l_col_enctype].string_value = cv.display
  HEAD cv.display
   IF (bneworgflag=false)
    lrowcnt += 1
    IF (mod(lrowcnt,50)=0)
     stat = alterlist(reply->rowlist,(50+ lrowcnt))
    ENDIF
    stat = alterlist(reply->rowlist[lrowcnt].celllist,l_tot_col), reply->rowlist[lrowcnt].celllist[
    l_col_ps].string_value = "PM_UPT_AUTO_DISCHARGE", reply->rowlist[lrowcnt].celllist[
    l_col_futureappt].string_value = "N/A"
    IF (loldautodischoutboundind=1)
     reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "Yes (Global Flag)"
    ELSE
     reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "No"
    ENDIF
    IF (o.org_name > " ")
     reply->rowlist[lrowcnt].celllist[l_col_org].string_value = o.org_name
    ELSE
     reply->rowlist[lrowcnt].celllist[l_col_org].string_value = "All Organizations"
    ENDIF
    reply->rowlist[lrowcnt].celllist[l_col_enctype].string_value = cv.display
   ENDIF
   bneworgflag = false
  DETAIL
   CASE (etp.param_name)
    OF "AUTO_DISCH_START_FIELD":
     reply->rowlist[lrowcnt].celllist[l_col_startfld].string_value = etp.value_string
    OF "AUTO_DISCH_DAYS":
     reply->rowlist[lrowcnt].celllist[l_col_days].string_value = cnvtstring(etp.value_nbr)
    OF "AUTO_DISCH_END_FIELD":
     reply->rowlist[lrowcnt].celllist[l_col_endfld].string_value = etp.value_string
    OF "AUTO_DISCH_DISP_VALUE":
     reply->rowlist[lrowcnt].celllist[l_col_enddisp].string_value = cv1.display
    OF "AUTO_DISCH_ETYPE_OUTBOUND_IND":
     IF (etp.value_nbr=1
      AND loldautodischoutboundind=2)
      reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "Yes (Encounter Level Flag)"
     ENDIF
     ,reply->rowlist[lrowcnt].celllist[l_col_days].string_value = cnvtstring(etp.value_nbr)
    OF "AUTO_DISCH_END_VALUE":
     CASE (etp.value_nbr)
      OF 0:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Start date + # of days with time of 23:59"
      OF 1:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Discharge Date = Start Date with time of 23:59"
      OF 2:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Date and Time Auto Discharge Script Ran"
     ENDCASE
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM rc_parameter_set rps,
   rc_parameter rp
  PLAN (rps
   WHERE rps.parm_set_name="AUTO_DISCH_GLOBAL"
    AND rps.active_ind=1
    AND rps.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND rps.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (rp
   WHERE rp.rc_parameter_set_id=rps.rc_parameter_set_id
    AND rp.parm_name IN ("AUTO_DISCH_OUTBOUND_IND", "AUTO_DISCH_A03_IND")
    AND rp.active_ind=1
    AND rp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND rp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY rp.parm_name, rp.beg_effective_dt_tm
  HEAD rp.parm_name
   CASE (rp.parm_name)
    OF "AUTO_DISCH_A03_IND":
     bautodischa03ind = true,lautodischa03ind = rp.parm_value_nbr
    OF "AUTO_DISCH_OUTBOUND_IND":
     bautodischoutboundind = true,lautodischoutboundind = rp.parm_value_nbr
   ENDCASE
  WITH nocounter
 ;end select
 IF (lautodischa03ind=0)
  SET soutboundmsgtype = "Simplified A03"
 ELSEIF (lautodischa03ind=1)
  SET soutboundmsgtype = "Complete A03 with insurance"
 ENDIF
 SET bneworgflag = false
 SELECT INTO "nl:"
  rc_params.seq
  FROM pm_auto_disch_parm_set_r rc_params,
   rc_parameter rcp,
   rc_parameter_set rps,
   code_value cv,
   code_value cve
  PLAN (rc_params
   WHERE rc_params.active_ind=1)
   JOIN (rcp
   WHERE rcp.rc_parameter_set_id=rc_params.rc_parameter_set_id
    AND rcp.active_ind=1)
   JOIN (rps
   WHERE rps.rc_parameter_set_id=rcp.rc_parameter_set_id
    AND rps.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rc_params.loc_facility_cd)
   JOIN (cve
   WHERE cve.code_value=rc_params.encntr_type_cd)
  ORDER BY rps.parm_set_name, cv.display, cve.display
  HEAD cv.display
   bneworgflag = true, lrowcnt += 1
   IF (mod(lrowcnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ lrowcnt))
   ENDIF
   stat = alterlist(reply->rowlist[lrowcnt].celllist,l_tot_col), reply->rowlist[lrowcnt].celllist[
   l_col_ps].string_value = trim(rps.parm_set_name,3), reply->rowlist[lrowcnt].celllist[l_col_endval]
   .string_value = "Start date + # of days with time of 23:59",
   reply->rowlist[lrowcnt].celllist[l_col_futureappt].string_value = "No"
   IF (lautodischoutboundind=1)
    reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = concat("Yes (Global Flag) ",
     soutboundmsgtype)
   ELSE
    reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "No"
   ENDIF
   IF (rc_params.loc_facility_cd=0)
    reply->rowlist[lrowcnt].celllist[l_col_org].string_value = "All Facilities"
   ELSE
    reply->rowlist[lrowcnt].celllist[l_col_org].string_value = cv.display
   ENDIF
   reply->rowlist[lrowcnt].celllist[l_col_enctype].string_value = cve.display
  HEAD cve.display
   IF (bneworgflag=false)
    lrowcnt += 1
    IF (mod(lrowcnt,50)=0)
     stat = alterlist(reply->rowlist,(50+ lrowcnt))
    ENDIF
    stat = alterlist(reply->rowlist[lrowcnt].celllist,l_tot_col), reply->rowlist[lrowcnt].celllist[
    l_col_ps].string_value = trim(rps.parm_set_name,3), reply->rowlist[lrowcnt].celllist[l_col_endval
    ].string_value = "Start date + # of days with time of 23:59",
    reply->rowlist[lrowcnt].celllist[l_col_futureappt].string_value = "No"
    IF (lautodischoutboundind=1)
     reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = concat("Yes (Global Flag) ",
      soutboundmsgtype)
    ELSE
     reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = "No"
    ENDIF
    IF (rc_params.loc_facility_cd=0)
     reply->rowlist[lrowcnt].celllist[l_col_org].string_value = "All Facilities"
    ELSE
     reply->rowlist[lrowcnt].celllist[l_col_org].string_value = cv.display
    ENDIF
    reply->rowlist[lrowcnt].celllist[l_col_enctype].string_value = cve.display
   ENDIF
   bneworgflag = false
  DETAIL
   CASE (rcp.parm_name)
    OF "AUTO_DISCH_START_FIELD":
     reply->rowlist[lrowcnt].celllist[l_col_startfld].string_value = rcp.parm_value_txt
    OF "AUTO_DISCH_DAYS":
     reply->rowlist[lrowcnt].celllist[l_col_days].string_value = cnvtstring(rcp.parm_value_nbr)
    OF "AUTO_DISCH_CHARGE_DAYS":
     reply->rowlist[lrowcnt].celllist[l_col_days].string_value = cnvtstring(rcp.parm_value_nbr)
    OF "AUTO_DISCH_MONTH_END_IND":
     IF (rcp.parm_value_nbr=1)
      reply->rowlist[lrowcnt].celllist[l_col_days].string_value = "End of the Month", reply->rowlist[
      lrowcnt].celllist[l_col_endval].string_value =
      "Start date's last day of the month with time of 23:59"
     ENDIF
    OF "AUTO_DISCH_ETYPE_OUTBOUND_IND":
     IF (rcp.parm_value_nbr=1
      AND lautodischoutboundind=2)
      reply->rowlist[lrowcnt].celllist[l_col_outboundind].string_value = concat(
       "Yes (Encounter Level Flag) ",soutboundmsgtype)
     ENDIF
    OF "AUTO_DISCH_FUTURE_APPT":
     IF (rcp.parm_value_nbr=1)
      reply->rowlist[lrowcnt].celllist[l_col_futureappt].string_value = "Yes (Postpone Discharge)"
     ENDIF
    OF "AUTO_DISCH_END_FIELD":
     reply->rowlist[lrowcnt].celllist[l_col_endfld].string_value = rcp.parm_value_txt
    OF "AUTO_DISCH_DISP_VALUE":
     reply->rowlist[lrowcnt].celllist[l_col_enddisp].string_value = uar_get_code_display(rcp
      .parm_value)
    OF "AUTO_DISCH_END_VALUE":
     CASE (rcp.parm_value_nbr)
      OF 0:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Start date + # of days with time of 23:59"
      OF 1:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Start Date = Start Date with time of 23:59"
      OF 2:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Date and Time Auto Discharge Script Ran"
      OF 3:
       reply->rowlist[lrowcnt].celllist[l_col_endval].string_value =
       "Start date + (# of days minus 1) with time of 23:59"
     ENDCASE
   ENDCASE
  WITH nocounter
 ;end select
 CALL bederrorcheck(
  "Error002: Error Getting RC parameter facility from pm_auto_disch_parm_set_r table")
 SET stat = alterlist(reply->rowlist,lrowcnt)
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("erm_auto_discharge.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
