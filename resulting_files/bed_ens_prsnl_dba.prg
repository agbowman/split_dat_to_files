CREATE PROGRAM bed_ens_prsnl:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 person_list[*]
      2 person_id = f8
      2 status_msg = vc
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET position
 RECORD position(
   1 position_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET sex
 RECORD sex(
   1 sex_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET alias_type
 RECORD alias_type(
   1 alias_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET alias_pool
 RECORD alias_pool(
   1 alias_pool_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET address_type
 RECORD address_type(
   1 address_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET state
 RECORD state(
   1 state_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET country
 RECORD country(
   1 country_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET county
 RECORD county(
   1 county_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET phone_type
 RECORD phone_type(
   1 phone_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET phone_format
 RECORD phone_format(
   1 phone_format_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET confid_level
 RECORD confid_level(
   1 confid_level_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET org_set_type
 RECORD org_set_type(
   1 org_set_type_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET task_activity
 RECORD task_activity(
   1 task_activity_list[*]
     2 code = f8
     2 disp = vc
     2 mean = vc
 )
 FREE SET org
 RECORD org(
   1 org_list[*]
     2 id = f8
     2 name = vc
 )
 FREE SET org_set
 RECORD org_set(
   1 org_set_list[*]
     2 id = f8
     2 name = vc
 )
 FREE SET new_comments
 RECORD new_comments(
   1 comment_list[*]
     2 comment = vc
     2 type_code_value = f8
     2 prsnl_comment_id = f8
     2 long_text_id = f8
     2 action_flag = i4
 )
 IF ( NOT (validate(reqprsnltorccloudsync,0)))
  FREE SET reqprsnltorccloudsync
  RECORD reqprsnltorccloudsync(
    1 prsnl_list[*]
      2 action_flag = i2
      2 prsnl_id = f8
      2 revelate_required_fields = gvc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(repprsnltorccloudsync,0)))
  FREE SET repprsnltorccloudsync
  RECORD repprsnltorccloudsync(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE rccloudindex = i4 WITH protect, noconstant(0)
 DECLARE ishealthproffeatureenabled = i2 WITH protect, noconstant(false)
 DECLARE act_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE curr_dt_tm = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE system_identifier_feature_toggle_key = vc WITH protect, constant("urn:cerner:revelate")
 DECLARE revelate_enable_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":enable"))
 DECLARE health_prof_mf_feature_toggle_key = vc WITH protect, constant(build2(
   system_identifier_feature_toggle_key,":health-professional-master-file"))
 IF ((validate(pm_flex_hist_def,- (9))=- (9)))
  DECLARE pm_flex_hist_def = i2 WITH constant(0)
  IF ((validate(fh_hist_rec->encntr_id,- (99))=- (99)))
   RECORD fh_hist_rec(
     1 pm_hist_tracking_id = f8
     1 category_cd = f8
     1 encntr_id = f8
     1 person_id = f8
     1 transaction_dt_tm = dq8
     1 contributor_system_cd = f8
     1 addnewrow = i2
     1 str_list[*]
       2 attr_name = c32
       2 n_value = vc
       2 o_value = vc
     1 long_list[*]
       2 attr_name = c32
       2 n_value = i4
       2 o_value = i4
     1 dbl_list[*]
       2 attr_name = c32
       2 n_value = f8
       2 o_value = f8
     1 date_list[*]
       2 attr_name = c32
       2 n_value = dq8
       2 o_value = dq8
   )
  ENDIF
  DECLARE fh_lstrcnt = i4 WITH noconstant(0)
  DECLARE fh_llongcnt = i4 WITH noconstant(0)
  DECLARE fh_ldblcnt = i4 WITH noconstant(0)
  DECLARE fh_ldatecnt = i4 WITH noconstant(0)
  DECLARE fh_lcnt = i4 WITH noconstant(0)
  DECLARE fh_bfound = i2 WITH noconstant(false)
  DECLARE fh_dhist = f8 WITH noconstant(0.0)
  IF ((validate(dtstartdate,- (99.0))=- (99.0)))
   DECLARE dtstartdate = f8 WITH noconstant(0.0)
  ENDIF
  IF ((validate(dtenddate,- (99.0))=- (99.0)))
   DECLARE dtenddate = f8 WITH noconstant(0.0)
  ENDIF
  SET dtstartdate = cnvtdatetime("01-JAN-1800 00:00:00.00")
  SET dtenddate = cnvtdatetime("31-DEC-2100 00:00:00.00")
  DECLARE fh_setstring(fh_new=i2,fh_field=vc,fh_svalue=vc) = null
  DECLARE fh_setlong(fh_new=i2,fh_field=vc,fh_ivalue=i4) = null
  DECLARE fh_setdouble(fh_new=i2,fh_field=vc,fh_fvalue=f8) = null
  DECLARE fh_setdate(fh_new=i2,fh_field=vc,fh_dvalue=f8) = null
  DECLARE fh_setids(fh_tracking=f8,fh_encntr=f8,fh_person=f8) = null
  DECLARE fh_setdata(fh_trans_dt_tm=f8,fh_con_sys_cd=f8,fh_addnew=i2) = null
  DECLARE fh_setcategory(fh_dcategory=f8) = null
  DECLARE fh_clearrecord(fh_dummy) = null
  DECLARE fh_processhistory(fh_dummy) = null
  SUBROUTINE fh_setstring(fh_new,fh_field,fh_svalue)
    SET fh_field = trim(cnvtlower(fh_field),3)
    SET fh_bfound = false
    IF (textlen(trim(fh_svalue,3)) > 0)
     SET fh_svalue = trim(fh_svalue,3)
    ELSE
     SET fh_svalue = " "
    ENDIF
    SET fh_lstrcnt = size(fh_hist_rec->str_list,5)
    FOR (fh_lcnt = 1 TO fh_lstrcnt)
      IF ((fh_hist_rec->str_list[fh_lcnt].attr_name=fh_field))
       IF (fh_new)
        SET fh_hist_rec->str_list[fh_lcnt].n_value = fh_svalue
       ELSE
        SET fh_hist_rec->str_list[fh_lcnt].o_value = fh_svalue
       ENDIF
       SET fh_bfound = true
       SET fh_lcnt = fh_lstrcnt
      ENDIF
    ENDFOR
    IF (fh_bfound != true)
     SET fh_lstrcnt = (fh_lstrcnt+ 1)
     SET stat = alterlist(fh_hist_rec->str_list,fh_lstrcnt)
     SET fh_hist_rec->str_list[fh_lstrcnt].attr_name = fh_field
     IF (fh_new)
      SET fh_hist_rec->str_list[fh_lstrcnt].n_value = fh_svalue
     ELSE
      SET fh_hist_rec->str_list[fh_lstrcnt].o_value = fh_svalue
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE fh_setlong(fh_new,fh_field,fh_ivalue)
    SET fh_field = trim(cnvtlower(fh_field),3)
    SET fh_llongcnt = size(fh_hist_rec->long_list,5)
    SET fh_bfound = false
    FOR (fh_lcnt = 1 TO fh_llongcnt)
      IF ((fh_hist_rec->long_list[fh_lcnt].attr_name=fh_field))
       IF (fh_new)
        SET fh_hist_rec->long_list[fh_lcnt].n_value = fh_ivalue
       ELSE
        SET fh_hist_rec->long_list[fh_lcnt].o_value = fh_ivalue
       ENDIF
       SET fh_bfound = true
       SET fh_lcnt = fh_llongcnt
      ENDIF
    ENDFOR
    IF (fh_bfound != true)
     SET fh_llongcnt = (fh_llongcnt+ 1)
     SET stat = alterlist(fh_hist_rec->long_list,fh_llongcnt)
     SET fh_hist_rec->long_list[fh_llongcnt].attr_name = fh_field
     IF (fh_new)
      SET fh_hist_rec->long_list[fh_llongcnt].n_value = fh_ivalue
     ELSE
      SET fh_hist_rec->long_list[fh_llongcnt].o_value = fh_ivalue
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE fh_setdouble(fh_new,fh_field,fh_fvalue)
    SET fh_field = trim(cnvtlower(fh_field),3)
    SET fh_ldblcnt = size(fh_hist_rec->dbl_list,5)
    SET fh_bfound = false
    FOR (fh_lcnt = 1 TO fh_ldblcnt)
      IF ((fh_hist_rec->dbl_list[fh_lcnt].attr_name=fh_field))
       IF (fh_new)
        SET fh_hist_rec->dbl_list[fh_lcnt].n_value = fh_fvalue
       ELSE
        SET fh_hist_rec->dbl_list[fh_lcnt].o_value = fh_fvalue
       ENDIF
       SET fh_bfound = true
       SET fh_lcnt = fh_ldblcnt
      ENDIF
    ENDFOR
    IF (fh_bfound != true)
     SET fh_ldblcnt = (fh_ldblcnt+ 1)
     SET stat = alterlist(fh_hist_rec->dbl_list,fh_ldblcnt)
     SET fh_hist_rec->dbl_list[fh_ldblcnt].attr_name = fh_field
     IF (fh_new)
      SET fh_hist_rec->dbl_list[fh_ldblcnt].n_value = fh_fvalue
     ELSE
      SET fh_hist_rec->dbl_list[fh_ldblcnt].o_value = fh_fvalue
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE fh_setdate(fh_new,fh_field,fh_dvalue)
    SET fh_field = trim(cnvtlower(fh_field),3)
    SET fh_ldatecnt = size(fh_hist_rec->date_list,5)
    SET fh_bfound = false
    FOR (fh_lcnt = 1 TO fh_ldatecnt)
      IF ((fh_hist_rec->date_list[fh_lcnt].attr_name=fh_field))
       IF (fh_new)
        SET fh_hist_rec->date_list[fh_lcnt].n_value = cnvtdatetime(fh_dvalue)
       ELSE
        SET fh_hist_rec->date_list[fh_lcnt].o_value = cnvtdatetime(fh_dvalue)
       ENDIF
       SET fh_bfound = true
       SET fh_lcnt = fh_ldatecnt
      ENDIF
    ENDFOR
    IF (fh_bfound != true)
     SET fh_ldatecnt = (fh_ldatecnt+ 1)
     SET stat = alterlist(fh_hist_rec->date_list,fh_ldatecnt)
     SET fh_hist_rec->date_list[fh_ldatecnt].attr_name = fh_field
     IF (fh_new)
      SET fh_hist_rec->date_list[fh_ldatecnt].n_value = cnvtdatetime(fh_dvalue)
     ELSE
      SET fh_hist_rec->date_list[fh_ldatecnt].o_value = cnvtdatetime(fh_dvalue)
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE fh_setids(fh_tracking,fh_encntr,fh_person)
    SET fh_hist_rec->pm_hist_tracking_id = fh_tracking
    SET fh_hist_rec->encntr_id = fh_encntr
    SET fh_hist_rec->person_id = fh_person
  END ;Subroutine
  SUBROUTINE fh_setdata(transdate,consyscd,baddnew)
    IF (((transdate <= dtstartdate) OR (transdate >= dtenddate)) )
     SET fh_hist_rec->transaction_dt_tm = cnvtdatetime(curdate,curtime3)
    ELSE
     SET fh_hist_rec->transaction_dt_tm = cnvtdatetime(transdate)
    ENDIF
    SET fh_hist_rec->contributor_system_cd = consyscd
    SET fh_hist_rec->addnewrow = baddnew
  END ;Subroutine
  SUBROUTINE fh_setcategory(fh_fvalue)
    SET fh_hist_rec->category_cd = fh_fvalue
  END ;Subroutine
  SUBROUTINE fh_clearrecord(dummy)
    SET fh_hist_rec->category_cd = 0.0
    SET fh_hist_rec->encntr_id = 0.0
    SET fh_hist_rec->person_id = 0.0
    SET fh_hist_rec->transaction_dt_tm = 0.0
    SET fh_hist_rec->contributor_system_cd = 0.0
    SET fh_hist_rec->addnewrow = 0
    IF (size(fh_hist_rec->str_list,5) > 0)
     SET stat = alterlist(fh_hist_rec->str_list,0)
    ENDIF
    IF (size(fh_hist_rec->long_list,5) > 0)
     SET stat = alterlist(fh_hist_rec->long_list,0)
    ENDIF
    IF (size(fh_hist_rec->dbl_list,5) > 0)
     SET stat = alterlist(fh_hist_rec->dbl_list,0)
    ENDIF
    IF (size(fh_hist_rec->date_list,5) > 0)
     SET stat = alterlist(fh_hist_rec->date_list,0)
    ENDIF
  END ;Subroutine
  SUBROUTINE fh_processhistory(dummy)
    FREE RECORD hist_eval_reply
    RECORD hist_eval_reply(
      1 pm_hist_tracking_id = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    EXECUTE pm_hist_eval  WITH replace("REPLY","HIST_EVAL_REPLY")
    CALL fh_clearrecord(0)
  END ;Subroutine
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
 SET ishealthproffeatureenabled = isfeaturetoggleenabled(revelate_enable_feature_toggle_key,
  health_prof_mf_feature_toggle_key,system_identifier_feature_toggle_key)
 IF ( NOT (ishealthproffeatureenabled))
  CALL logdebugmessage("main",build2("Feature Toggle disabled for one or both Keys: ",
    revelate_enable_feature_toggle_key," and ",health_prof_mf_feature_toggle_key))
 ENDIF
 SET bhistoryoption = 0
 SET history_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=20790
   AND cv.cdf_meaning="HISTORY"
   AND cv.active_ind=1
  DETAIL
   history_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (history_cd > 0)
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=history_cd
    AND cve.field_name="OPTION"
    AND cve.code_set=20790
   DETAIL
    IF (((trim(cve.field_value,3)="1") OR (trim(cve.field_value,3)="0")) )
     bhistoryoption = cnvtint(trim(cve.field_value,3))
    ELSE
     bhistoryoption = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET dnamecatcd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=30060
   AND cv.cdf_meaning="PERSON_NAME"
   AND cv.active_ind=1
  DETAIL
   dnamecatcd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET prsnlcnt = 0
 SET alcnt = 0
 SET addcnt = 0
 SET phocnt = 0
 SET orgcnt = 0
 SET ogcnt = 0
 SET prsnlcnt = size(request->person_list,5)
 SET phtypecnt = 0
 DECLARE osprid = f8
 SET osprid = 0.0
 DECLARE tusername = vc
 DECLARE state_display = vc
 DECLARE county_display = vc
 DECLARE country_display = vc
 SET person_id = 0.0
 SET address_id = 0.0
 SET phone_id = 0.0
 SET name_ff = fillstring(100," ")
 SET prsnl_name_ff = fillstring(100," ")
 IF (((prsnlcnt=0) OR (prsnlcnt=1
  AND trim(request->person_list[1].name_first)=" "
  AND trim(request->person_list[1].name_last)=" "
  AND (request->person_list[1].action_flag=1))) )
  SET error_flag = "T"
  SET error_msg = "Zero entries in the request person list."
  GO TO exit_script
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS person
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET person_logical_domain_id = 0.0
    SET acm_get_curr_logical_domain_req->concept = 1
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET person_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
   ENDIF
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET prsnl_logical_domain_id = 0.0
    SET acm_get_curr_logical_domain_req->concept = 2
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET prsnl_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
   ENDIF
  ENDIF
 ENDIF
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning="AUTH")
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SET person_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=302
    AND c.cdf_meaning="PERSON")
  DETAIL
   person_type_cd = c.code_value
  WITH nocounter
 ;end select
 SET current_name_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=213
    AND c.cdf_meaning="CURRENT")
  DETAIL
   current_name_type_cd = c.code_value
  WITH nocounter
 ;end select
 SET prsnl_name_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=213
    AND c.cdf_meaning="PRSNL")
  DETAIL
   prsnl_name_type_cd = c.code_value
  WITH nocounter
 ;end select
 SET prsnl_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=309
    AND c.cdf_meaning="USER")
  DETAIL
   prsnl_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (((auth_cd=0) OR (((person_type_cd=0) OR (active_cd=0)) )) )
  SET error_flag = "T"
  SET error_msg = concat("A Cerner defined code value could not be found. ",
   " AUTH from 8, PERSON from 302, or ACTIVE from 48.")
  GO TO exit_script
 ENDIF
 SET posncnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   posncnt = (posncnt+ 1), stat = alterlist(position->position_list,posncnt), position->
   position_list[posncnt].code = cv.code_value,
   position->position_list[posncnt].disp = cv.display, position->position_list[posncnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET sexcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=57
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   sexcnt = (sexcnt+ 1), stat = alterlist(sex->sex_list,sexcnt), sex->sex_list[sexcnt].code = cv
   .code_value,
   sex->sex_list[sexcnt].disp = cv.display, sex->sex_list[sexcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET altypecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE ((cv.code_set=4) OR (cv.code_set=320))
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   altypecnt = (altypecnt+ 1), stat = alterlist(alias_type->alias_type_list,altypecnt), alias_type->
   alias_type_list[altypecnt].code = cv.code_value,
   alias_type->alias_type_list[altypecnt].disp = cv.display, alias_type->alias_type_list[altypecnt].
   mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET alpocnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=263
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   alpocnt = (alpocnt+ 1), stat = alterlist(alias_pool->alias_pool_list,alpocnt), alias_pool->
   alias_pool_list[alpocnt].code = cv.code_value,
   alias_pool->alias_pool_list[alpocnt].disp = cv.display, alias_pool->alias_pool_list[alpocnt].mean
    = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET adtypecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=212
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   adtypecnt = (adtypecnt+ 1), stat = alterlist(address_type->address_type_list,adtypecnt),
   address_type->address_type_list[adtypecnt].code = cv.code_value,
   address_type->address_type_list[adtypecnt].disp = cv.display, address_type->address_type_list[
   adtypecnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET statecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=62
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   statecnt = (statecnt+ 1), stat = alterlist(state->state_list,statecnt), state->state_list[statecnt
   ].code = cv.code_value,
   state->state_list[statecnt].disp = cv.display, state->state_list[statecnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET countrycnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=15
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   countrycnt = (countrycnt+ 1), stat = alterlist(country->country_list,countrycnt), country->
   country_list[countrycnt].code = cv.code_value,
   country->country_list[countrycnt].disp = cv.display, country->country_list[countrycnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET countycnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=74
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   countycnt = (countycnt+ 1), stat = alterlist(county->county_list,countycnt), county->county_list[
   countycnt].code = cv.code_value,
   county->county_list[countycnt].disp = cv.display, county->county_list[countycnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET phtypecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=43
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   phtypecnt = (phtypecnt+ 1), stat = alterlist(phone_type->phone_type_list,phtypecnt), phone_type->
   phone_type_list[phtypecnt].code = cv.code_value,
   phone_type->phone_type_list[phtypecnt].disp = cv.display, phone_type->phone_type_list[phtypecnt].
   mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET phformatcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=281
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   phformatcnt = (phformatcnt+ 1), stat = alterlist(phone_format->phone_format_list,phformatcnt),
   phone_format->phone_format_list[phformatcnt].code = cv.code_value,
   phone_format->phone_format_list[phformatcnt].disp = cv.display, phone_format->phone_format_list[
   phformatcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET confidcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=87
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   confidcnt = (confidcnt+ 1), stat = alterlist(confid_level->confid_level_list,confidcnt),
   confid_level->confid_level_list[confidcnt].code = cv.code_value,
   confid_level->confid_level_list[confidcnt].disp = cv.display, confid_level->confid_level_list[
   confidcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET ostypecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=28881
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   ostypecnt = (ostypecnt+ 1), stat = alterlist(org_set_type->org_set_type_list,ostypecnt),
   org_set_type->org_set_type_list[ostypecnt].code = cv.code_value,
   org_set_type->org_set_type_list[ostypecnt].disp = cv.display, org_set_type->org_set_type_list[
   ostypecnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET taskactcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6027
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   taskactcnt = (taskactcnt+ 1), stat = alterlist(task_activity->task_activity_list,taskactcnt),
   task_activity->task_activity_list[taskactcnt].code = cv.code_value,
   task_activity->task_activity_list[taskactcnt].disp = cv.display, task_activity->
   task_activity_list[taskactcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET s_orgcnt = 0
 SELECT INTO "nl:"
  FROM organization o
  PLAN (o
   WHERE o.active_ind=1)
  ORDER BY o.organization_id
  HEAD o.organization_id
   s_orgcnt = (s_orgcnt+ 1), stat = alterlist(org->org_list,s_orgcnt), org->org_list[s_orgcnt].id = o
   .organization_id,
   org->org_list[s_orgcnt].name = o.org_name
  WITH nocounter
 ;end select
 SET s_oscnt = 0
 SELECT INTO "nl:"
  FROM org_set os
  PLAN (os
   WHERE os.active_ind=1)
  ORDER BY os.org_set_id
  HEAD os.org_set_id
   s_oscnt = (s_oscnt+ 1), stat = alterlist(org_set->org_set_list,s_oscnt), org_set->org_set_list[
   s_oscnt].id = os.org_set_id,
   org_set->org_set_list[s_oscnt].name = os.name
  WITH nocounter
 ;end select
 SET s_position_code = 0.0
 SET s_sex_code = 0.0
 SET s_alias_type_code = 0.0
 SET s_alias_pool_code = 0.0
 SET s_address_type_code = 0.0
 SET s_state_code = 0.0
 SET s_country_code = 0.0
 SET s_county_code = 0.0
 SET s_phone_type_code = 0.0
 SET s_phone_format_code = 0.0
 SET s_confid_level_code = 0.0
 SET s_org_set_type_code = 0.0
 SET s_task_activity_code = 0.0
 SET s_org_id = 0.0
 SET s_org_set_id = 0.0
 SET s_position_mean = fillstring(12," ")
 SET s_sex_mean = fillstring(12," ")
 SET s_alias_type_mean = fillstring(12," ")
 SET s_alias_pool_mean = fillstring(12," ")
 SET s_address_type_mean = fillstring(12," ")
 SET s_state_mean = fillstring(12," ")
 SET s_country_mean = fillstring(12," ")
 SET s_county_mean = fillstring(12," ")
 SET s_phone_type_mean = fillstring(12," ")
 SET s_phone_format_mean = fillstring(12," ")
 SET s_confid_level_mean = fillstring(12," ")
 SET s_org_set_type_mean = fillstring(12," ")
 SET s_task_activity_mean = fillstring(12," ")
 SET s_position_disp = fillstring(40," ")
 SET s_sex_disp = fillstring(40," ")
 SET s_alias_type_disp = fillstring(40," ")
 SET s_alias_pool_disp = fillstring(40," ")
 SET s_address_type_disp = fillstring(40," ")
 SET s_state_disp = fillstring(40," ")
 SET s_country_disp = fillstring(40," ")
 SET s_county_disp = fillstring(40," ")
 SET s_phone_type_disp = fillstring(40," ")
 SET s_phone_format_disp = fillstring(40," ")
 SET s_confid_level_disp = fillstring(40," ")
 SET s_org_set_type_disp = fillstring(40," ")
 SET s_task_activity_disp = fillstring(40," ")
 SET s_org_name = fillstring(100," ")
 SET s_org_set_name = fillstring(50," ")
 SET x1 = size(request->person_list,5)
 FOR (aa = 1 TO x1)
   IF ((request->person_list[aa].position_code_value=0)
    AND (request->person_list[aa].position_disp > " "))
    SET s_position_disp = request->person_list[aa].position_disp
    CALL get_position(aa)
    SET request->person_list[aa].position_code_value = s_position_code
   ENDIF
   IF ((request->person_list[aa].sex_code_value=0)
    AND (request->person_list[aa].sex_mean > " "))
    SET s_sex_mean = request->person_list[aa].sex_mean
    CALL get_sex_code(aa)
    SET request->person_list[aa].sex_code_value = s_sex_code
   ENDIF
   SET x2 = size(request->person_list[aa].alias_list,5)
   FOR (bb = 1 TO x2)
    IF ((request->person_list[aa].alias_list[bb].alias_type_code_value=0)
     AND (request->person_list[aa].alias_list[bb].alias_type_mean > " "))
     SET s_alias_type_mean = request->person_list[aa].alias_list[bb].alias_type_mean
     CALL get_alias_type(aa)
     SET request->person_list[aa].alias_list[bb].alias_type_code_value = s_alias_type_code
    ENDIF
    IF ((request->person_list[aa].alias_list[bb].alias_pool_code_value=0)
     AND (request->person_list[aa].alias_list[bb].alias_pool_disp > " "))
     SET s_alias_pool_disp = request->person_list[aa].alias_list[bb].alias_pool_disp
     CALL get_alias_pool(aa)
     SET request->person_list[aa].alias_list[bb].alias_pool_code_value = s_alias_pool_code
    ENDIF
   ENDFOR
   SET x3 = size(request->person_list[aa].address_list,5)
   FOR (cc = 1 TO x3)
     IF ((request->person_list[aa].address_list[cc].address_type_code_value=0)
      AND (request->person_list[aa].address_list[cc].address_type_mean > " "))
      SET s_address_type_mean = request->person_list[aa].address_list[cc].address_type_mean
      CALL get_address_type(aa)
      SET request->person_list[aa].address_list[cc].address_type_code_value = s_address_type_code
     ENDIF
     IF ((request->person_list[aa].address_list[cc].state_code_value=0)
      AND (request->person_list[aa].address_list[cc].state_disp > " "))
      SET s_state_disp = request->person_list[aa].address_list[cc].state_disp
      CALL get_state(aa)
      SET request->person_list[aa].address_list[cc].state_code_value = s_state_code
     ENDIF
     IF ((request->person_list[aa].address_list[cc].country_code_value=0)
      AND (request->person_list[aa].address_list[cc].country_disp > " "))
      SET s_country_disp = request->person_list[aa].address_list[cc].country_disp
      CALL get_country(aa)
      SET request->person_list[aa].address_list[cc].country_code_value = s_country_code
     ENDIF
     IF ((request->person_list[aa].address_list[cc].county_code_value=0)
      AND (request->person_list[aa].address_list[cc].county_disp > " "))
      SET s_county_disp = request->person_list[aa].address_list[cc].county_disp
      CALL get_county(aa)
      SET request->person_list[aa].address_list[cc].county_code_value = s_county_code
     ENDIF
   ENDFOR
   SET x4 = size(request->person_list[aa].phone_list,5)
   FOR (dd = 1 TO x4)
    IF ((request->person_list[aa].phone_list[dd].phone_type_code_value=0)
     AND (request->person_list[aa].phone_list[dd].phone_type_mean > " "))
     SET s_phone_type_mean = request->person_list[aa].phone_list[dd].phone_type_mean
     CALL get_phone_type(aa)
     SET request->person_list[aa].phone_list[dd].phone_type_code_value = s_phone_type_code
    ENDIF
    IF ((request->person_list[aa].phone_list[dd].phone_format_code_value=0)
     AND (request->person_list[aa].phone_list[dd].phone_format_mean > " "))
     SET s_phone_format_mean = request->person_list[aa].phone_list[dd].phone_format_mean
     CALL get_phone_format(aa)
     SET request->person_list[aa].phone_list[dd].phone_format_code_value = s_phone_format_code
    ENDIF
   ENDFOR
   SET x5 = size(request->person_list[aa].org_list,5)
   FOR (ee = 1 TO x5)
    IF ((request->person_list[aa].org_list[ee].confid_level_code_value=0)
     AND (request->person_list[aa].org_list[ee].confid_level_mean > " "))
     SET s_confid_level_mean = request->person_list[aa].org_list[ee].confid_level_mean
     CALL get_confid_level(aa)
     SET request->person_list[aa].org_list[ee].confid_level_code_value = s_confid_level_code
    ENDIF
    IF ((request->person_list[aa].org_list[ee].organization_id=0)
     AND (request->person_list[aa].org_list[ee].organization_name > " "))
     SET s_org_name = request->person_list[aa].org_list[ee].organization_name
     CALL get_org(aa)
     SET request->person_list[aa].org_list[ee].organization_id = s_org_id
    ENDIF
   ENDFOR
   SET x6 = size(request->person_list[aa].org_group_list,5)
   FOR (ff = 1 TO x6)
    IF ((request->person_list[aa].org_group_list[ff].org_set_type_code_value=0)
     AND (request->person_list[aa].org_group_list[ff].org_set_type_mean > " ")
     AND (request->person_list[aa].org_group_list[ff].org_set_type_disp > " "))
     SET s_org_set_type_mean = request->person_list[aa].org_group_list[ff].org_set_type_mean
     SET s_org_set_type_disp = request->person_list[aa].org_group_list[ff].org_set_type_disp
     CALL get_org_set_type(aa)
     SET request->person_list[aa].org_group_list[ff].org_set_type_code_value = s_org_set_type_code
    ENDIF
    IF ((request->person_list[aa].org_group_list[ff].org_set_id=0)
     AND (request->person_list[aa].org_group_list[ff].org_set_name > " "))
     SET s_org_set_name = request->person_list[aa].org_group_list[ff].org_set_name
     CALL get_org_set(aa)
     SET request->person_list[aa].org_group_list[ff].org_set_id = s_org_set_id
    ENDIF
   ENDFOR
   SET x7 = size(request->person_list[aa].notify_list,5)
   FOR (gg = 1 TO x7)
     IF ((request->person_list[aa].notify_list[gg].task_activity_code_value=0)
      AND (request->person_list[aa].notify_list[gg].task_activity_mean > " "))
      SET s_task_activity_mean = request->person_list[aa].notify_list[gg].task_activity_mean
      CALL get_task_activity(aa)
      SET request->person_list[aa].notify_list[gg].task_actiity_code_value = s_task_activity_code
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(reply->person_list,prsnlcnt)
 FOR (x = 1 TO prsnlcnt)
   SET person_id = 0.0
   IF ((request->person_list[x].action_flag=1))
    SET stat = add_prsnl(x)
   ELSE
    IF ((request->person_list[x].person_id=0))
     SET error_flag = "T"
     SET error_msg = concat("Actions other than ADD require an person_id, no person_id sent with: ",
      trim(request->person_list[x].name_full_formatted))
     GO TO exit_script
    ELSE
     SET person_id = request->person_list[x].person_id
     IF ((request->person_list[x].action_flag=0))
      SET stat = noaction_prsnl(x)
     ELSEIF ((request->person_list[x].action_flag=2))
      SET stat = chg_prsnl(x)
     ELSEIF ((request->person_list[x].action_flag=3))
      SET stat = del_prsnl(x)
     ENDIF
    ENDIF
   ENDIF
   IF (person_id > 0
    AND (request->person_list[x].action_flag != 1))
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE p.person_id=person_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET person_id = 0.0
     SET error_flag = "T"
     SET error_msg = concat("Invalid person_id: ",cnvtstring(person_id))
     GO TO exit_script
    ENDIF
   ENDIF
   IF (person_id > 0)
    SET alcnt = size(request->person_list[x].alias_list,5)
    IF (alcnt > 0)
     FOR (y = 1 TO alcnt)
       IF ((request->person_list[x].alias_list[y].action_flag=1))
        SET stat = add_alias(x,y)
       ELSEIF ((request->person_list[x].alias_list[y].action_flag=2))
        SET stat = chg_alias(x,y)
       ELSEIF ((request->person_list[x].alias_list[y].action_flag=3))
        SET stat = del_alias(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET addcnt = size(request->person_list[x].address_list,5)
    IF (addcnt > 0)
     FOR (y = 1 TO addcnt)
       IF ((request->person_list[x].address_list[y].action_flag=1))
        SET stat = add_address(x,y)
       ELSEIF ((request->person_list[x].address_list[y].action_flag=2))
        SET stat = chg_address(x,y)
       ELSEIF ((request->person_list[x].address_list[y].action_flag=3))
        SET stat = del_address(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET phocnt = size(request->person_list[x].phone_list,5)
    IF (phocnt > 0)
     FOR (y = 1 TO phocnt)
       IF ((request->person_list[x].phone_list[y].action_flag=1))
        SET stat = add_phone(x,y)
       ELSEIF ((request->person_list[x].phone_list[y].action_flag=2))
        SET stat = chg_phone(x,y)
       ELSEIF ((request->person_list[x].phone_list[y].action_flag=3))
        SET stat = del_phone(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET orgcnt = size(request->person_list[x].org_list,5)
    IF (orgcnt > 0)
     FOR (y = 1 TO orgcnt)
       IF ((request->person_list[x].org_list[y].action_flag=1))
        SET stat = add_org(x,y)
       ELSEIF ((request->person_list[x].org_list[y].action_flag=2))
        SET stat = chg_org(x,y)
       ELSEIF ((request->person_list[x].org_list[y].action_flag=3))
        SET stat = del_org(x,y)
       ENDIF
     ENDFOR
    ENDIF
    SET ogcnt = size(request->person_list[x].org_group_list,5)
    IF (ogcnt > 0)
     FOR (y = 1 TO ogcnt)
       IF ((request->person_list[x].org_group_list[y].action_flag=1))
        SET stat = add_org_group(x,y)
       ELSEIF ((request->person_list[x].org_group_list[y].action_flag=2))
        SET stat = chg_org_group(x,y)
       ELSEIF ((request->person_list[x].org_group_list[y].action_flag=3))
        SET stat = del_org_group(x,y)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (validate(request->person_list[x].comment_list))
    IF (size(request->person_list[x].comment_list,5) > 0)
     CALL ens_prsnl_comments(x)
     DECLARE prsnl_comment_index = i4 WITH protect, noconstant(0)
     FOR (prsnl_comment_index = 1 TO size(new_comments->comment_list,5))
       IF ((new_comments->comment_list[prsnl_comment_index].action_flag=1))
        CALL add_comment(x,prsnl_comment_index)
       ELSEIF ((new_comments->comment_list[prsnl_comment_index].action_flag=2))
        CALL chg_comment(x,prsnl_comment_index)
       ELSEIF ((new_comments->comment_list[prsnl_comment_index].action_flag=3))
        CALL del_comment(x,prsnl_comment_index)
       ELSE
        CALL echo("No change")
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (validate(request->person_list[x].result_delivery_method_list))
    DECLARE result_delivery_method_cnt = i4 WITH protect, noconstant(size(request->person_list[x].
      result_delivery_method_list,5))
    IF (result_delivery_method_cnt > 0)
     DECLARE result_delivery_method_index = i4 WITH protect, noconstant(0)
     FOR (result_delivery_method_index = 1 TO result_delivery_method_cnt)
       IF ((request->person_list[x].result_delivery_method_list[result_delivery_method_index].
       action_flag=1))
        CALL add_result_delivery_method(x,result_delivery_method_index)
       ELSEIF ((request->person_list[x].result_delivery_method_list[result_delivery_method_index].
       action_flag=3))
        CALL del_result_delivery_method(x,result_delivery_method_index)
       ELSE
        CALL echo("No Change")
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET reply->person_list[x].person_id = person_id
   IF (ishealthproffeatureenabled
    AND error_flag != "T"
    AND validate(request->person_list[x].revelate_required_fields))
    IF ((((request->person_list[x].action_flag=1)
     AND size(trim(request->person_list[x].revelate_required_fields)) > 0) OR ((request->person_list[
    x].action_flag=2))) )
     SET rccloudindex = (rccloudindex+ 1)
     SET stat = alterlist(reqprsnltorccloudsync->prsnl_list,rccloudindex)
     SET reqprsnltorccloudsync->prsnl_list[rccloudindex].action_flag = request->person_list[x].
     action_flag
     SET reqprsnltorccloudsync->prsnl_list[rccloudindex].prsnl_id = person_id
     SET reqprsnltorccloudsync->prsnl_list[rccloudindex].revelate_required_fields = request->
     person_list[x].revelate_required_fields
    ENDIF
   ENDIF
 ENDFOR
 IF (ishealthproffeatureenabled
  AND error_flag != "T"
  AND rccloudindex > 0)
  EXECUTE pft_bed_ens_health_prof  WITH replace("REQUEST",reqprsnltorccloudsync), replace("REPLY",
   repprsnltorccloudsync)
  IF ((repprsnltorccloudsync->status_data.status != "S"))
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Error saving health professional data, contact Patient Accounting team for more assistance")
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE noaction_prsnl(x)
   SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
    "Action flag zero for prsnl: ",trim(request->person_list[x].name_first)," ",
    trim(request->person_list[x].name_last),". No action taken at the person level.")
 END ;Subroutine
 SUBROUTINE add_prsnl(x)
  IF (trim(request->person_list[x].name_first) > " "
   AND trim(request->person_list[x].name_last) > " ")
   SELECT INTO "nl:"
    j = seq(person_only_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     person_id = cnvtreal(j)
    WITH format, counter
   ;end select
   IF (person_id > 0)
    IF ((request->person_list[x].name_full_formatted > " "))
     SET name_ff = request->person_list[x].name_full_formatted
    ELSE
     SET name_ff = uar_i18nbuildfullformatname(nullterm(trim(request->person_list[x].name_first,3)),
      nullterm(trim(request->person_list[x].name_last,3)),nullterm(trim(request->person_list[x].
        name_middle,3)),"",nullterm(trim(request->person_list[x].name_title,3)),
      "",nullterm(trim(request->person_list[x].name_suffix,3)),"","")
    ENDIF
    SET active_ind = 0
    IF ((request->person_list[x].active_ind_ind=1))
     SET active_ind = request->person_list[x].active_ind
    ELSE
     SET active_ind = 1
    ENDIF
    IF (data_partition_ind=1)
     INSERT  FROM person p
      SET p.logical_domain_id = person_logical_domain_id, p.person_id = person_id, p
       .contributor_system_cd = 0,
       p.person_type_cd = person_type_cd, p.name_first = trim(request->person_list[x].name_first), p
       .name_last = trim(request->person_list[x].name_last),
       p.name_middle = trim(request->person_list[x].name_middle), p.name_first_key = cnvtupper(
        cnvtalphanum(request->person_list[x].name_first)), p.name_last_key = cnvtupper(cnvtalphanum(
         request->person_list[x].name_last)),
       p.name_middle_key = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)), p
       .name_full_formatted = name_ff, p.name_phonetic = soundex(cnvtupper(request->person_list[x].
         name_last)),
       p.name_last_phonetic = soundex(cnvtupper(request->person_list[x].name_last)), p
       .name_first_phonetic = soundex(cnvtupper(request->person_list[x].name_first)), p.birth_dt_cd
        = 0,
       p.birth_dt_tm = cnvtdatetime(request->person_list[x].birth_dt_tm), p.sex_cd = request->
       person_list[x].sex_code_value, p.cause_of_death = " ",
       p.mother_maiden_name = " ", p.ft_entity_name = " ", p.military_base_location = " ",
       p.birth_prec_flag = 0, p.birth_tz = curtimezoneapp, p.abs_birth_dt_tm = datetimezone(
        cnvtdatetime(request->person_list[x].birth_dt_tm),curtimezoneapp),
       p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = reqinfo->updt_id,
       p.create_dt_tm = cnvtdatetime(curdate,curtime3), p.create_prsnl_id = reqinfo->updt_id, p
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.active_ind = active_ind, p
       .active_status_cd = active_cd,
       p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0, p.updt_id = reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM person p
      SET p.person_id = person_id, p.contributor_system_cd = 0, p.person_type_cd = person_type_cd,
       p.name_first = trim(request->person_list[x].name_first), p.name_last = trim(request->
        person_list[x].name_last), p.name_middle = trim(request->person_list[x].name_middle),
       p.name_first_key = cnvtupper(cnvtalphanum(request->person_list[x].name_first)), p
       .name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].name_last)), p.name_middle_key
        = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)),
       p.name_full_formatted = name_ff, p.name_phonetic = soundex(cnvtupper(request->person_list[x].
         name_last)), p.name_last_phonetic = soundex(cnvtupper(request->person_list[x].name_last)),
       p.name_first_phonetic = soundex(cnvtupper(request->person_list[x].name_first)), p.birth_dt_cd
        = 0, p.birth_dt_tm = cnvtdatetime(request->person_list[x].birth_dt_tm),
       p.sex_cd = request->person_list[x].sex_code_value, p.cause_of_death = " ", p
       .mother_maiden_name = " ",
       p.ft_entity_name = " ", p.military_base_location = " ", p.birth_prec_flag = 0,
       p.birth_tz = curtimezoneapp, p.abs_birth_dt_tm = datetimezone(cnvtdatetime(request->
         person_list[x].birth_dt_tm),curtimezoneapp), p.data_status_cd = auth_cd,
       p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->
       updt_id, p.create_dt_tm = cnvtdatetime(curdate,curtime3),
       p.create_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       p.active_ind = active_ind, p.active_status_cd = active_cd, p.active_status_prsnl_id = reqinfo
       ->updt_id,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), p.updt_applctx = reqinfo->updt_applctx,
       p.updt_cnt = 0, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "New person row written for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new person row for: ",trim(request->
       person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
    IF ((request->person_list[x].prsnl_name_full_formatted > " "))
     SET prsnl_name_ff = request->person_list[x].prsnl_name_full_formatted
    ELSE
     SET prsnl_name_ff = uar_i18nbuildfullformatname(nullterm(trim(request->person_list[x].
        prsnl_name_first,3)),nullterm(trim(request->person_list[x].prsnl_name_last,3)),nullterm(trim(
        request->person_list[x].name_middle,3)),"",nullterm(trim(request->person_list[x].name_title,3
        )),
      "",nullterm(trim(request->person_list[x].name_suffix,3)),"","")
    ENDIF
    IF ((request->person_list[x].username > " "))
     SET tusername = trim(request->person_list[x].username)
    ELSE
     SET tusername = " "
    ENDIF
    IF (data_partition_ind=1)
     INSERT  FROM prsnl pr
      SET pr.logical_domain_id = prsnl_logical_domain_id, pr.person_id = person_id, pr.name_first =
       request->person_list[x].prsnl_name_first,
       pr.name_last = request->person_list[x].prsnl_name_last, pr.name_first_key = cnvtupper(
        cnvtalphanum(request->person_list[x].prsnl_name_first)), pr.name_last_key = cnvtupper(
        cnvtalphanum(request->person_list[x].prsnl_name_last)),
       pr.name_full_formatted = name_ff, pr.prsnl_type_cd = prsnl_type_cd, pr.email = request->
       person_list[x].email,
       pr.physician_ind = request->person_list[x].physician_ind, pr.position_cd = request->
       person_list[x].position_code_value, pr.free_text_ind = null,
       pr.username =
       IF (tusername > " ") tusername
       ELSE null
       ENDIF
       , pr.prim_assign_loc_cd = request->person_list[x].primary_work_loc_code_value, pr
       .contributor_system_cd = 0,
       pr.data_status_cd = auth_cd, pr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pr
       .data_status_prsnl_id = reqinfo->updt_id,
       pr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), pr.create_dt_tm = cnvtdatetime(curdate,curtime3),
       pr.create_prsnl_id = reqinfo->updt_id, pr.active_ind = active_ind, pr.active_status_cd =
       active_cd,
       pr.active_status_prsnl_id = reqinfo->updt_id, pr.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), pr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0, pr.updt_id = reqinfo->updt_id,
       pr.updt_task = reqinfo->updt_task, pr.external_ind = request->person_list[x].external_ind
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM prsnl pr
      SET pr.person_id = person_id, pr.name_first = request->person_list[x].prsnl_name_first, pr
       .name_last = request->person_list[x].prsnl_name_last,
       pr.name_first_key = cnvtupper(cnvtalphanum(request->person_list[x].prsnl_name_first)), pr
       .name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].prsnl_name_last)), pr
       .name_full_formatted = name_ff,
       pr.prsnl_type_cd = prsnl_type_cd, pr.email = request->person_list[x].email, pr.physician_ind
        = request->person_list[x].physician_ind,
       pr.position_cd = request->person_list[x].position_code_value, pr.free_text_ind = null, pr
       .username =
       IF (tusername > " ") tusername
       ELSE null
       ENDIF
       ,
       pr.prim_assign_loc_cd = request->person_list[x].primary_work_loc_code_value, pr
       .contributor_system_cd = 0, pr.data_status_cd = auth_cd,
       pr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pr.data_status_prsnl_id = reqinfo->
       updt_id, pr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       pr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pr.create_dt_tm = cnvtdatetime(curdate,
        curtime3), pr.create_prsnl_id = reqinfo->updt_id,
       pr.active_ind = active_ind, pr.active_status_cd = active_cd, pr.active_status_prsnl_id =
       reqinfo->updt_id,
       pr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), pr.updt_applctx = reqinfo->updt_applctx,
       pr.updt_cnt = 0, pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->updt_task,
       pr.external_ind = request->person_list[x].external_ind
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "New PRSNL row written for: ",trim(request->person_list[x].prsnl_name_first)," ",
      trim(request->person_list[x].prsnl_name_last))
     IF ((request->person_list[x].submit_by > "  "))
      INSERT  FROM br_prsnl_submit b
       SET b.prsnl_id = person_id, b.submit_by = request->person_list[x].submit_by, b.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,">>","Error writing new PRSNL row for: ",trim(prsnl_name_ff),
        " into br_prsnl_submit table.")
      ENDIF
     ENDIF
     IF ((request->person_list[x].sch_ind=1))
      SET request_cv->cd_value_list[1].action_flag = 1
      SET request_cv->cd_value_list[1].code_set = 14231
      SET request_cv->cd_value_list[1].display = substring(1,40,prsnl_name_ff)
      SET request_cv->cd_value_list[1].description = substring(1,60,prsnl_name_ff)
      SET request_cv->cd_value_list[1].definition = prsnl_name_ff
      SET request_cv->cd_value_list[1].active_ind = 1
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      IF ((reply_cv->status_data.status="S")
       AND (reply_cv->qual[1].code_value > 0))
       SET next_cand_id = 0.0
       SELECT INTO "nl:"
        j = seq(sch_candidate_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         next_cand_id = cnvtreal(j)
        WITH format, counter
       ;end select
       INSERT  FROM sch_resource s
        SET s.resource_cd = reply_cv->qual[1].code_value, s.version_dt_tm = cnvtdatetime(
          "31-DEC-2100"), s.res_type_flag = 2,
         s.mnemonic = prsnl_name_ff, s.mnemonic_key = cnvtupper(prsnl_name_ff), s.description =
         prsnl_name_ff,
         s.person_id = person_id, s.candidate_id = next_cand_id, s.beg_effective_dt_tm = cnvtdatetime
         (curdate,curtime3),
         s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
         active_cd,
         s.null_dt_tm = cnvtdatetime("31-DEC-2100")
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "T"
        SET error_msg = concat(error_msg,">>","Error writing new PRSNL row for: ",trim(prsnl_name_ff),
         " into sch_resource table.")
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new PRSNL row for: ",trim(request->
       person_list[x].prsnl_name_first)," ",
      trim(request->person_list[x].prsnl_name_last))
    ENDIF
    SET person_name_id = 0.0
    SELECT INTO "nl:"
     j = seq(person_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      person_name_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM person_name pn
     SET pn.person_name_id = person_name_id, pn.person_id = person_id, pn.contributor_system_cd = 0,
      pn.name_type_cd = current_name_type_cd, pn.name_full = name_ff, pn.name_first = request->
      person_list[x].name_first,
      pn.name_middle = request->person_list[x].name_middle, pn.name_last = request->person_list[x].
      name_last, pn.name_title = request->person_list[x].name_title,
      pn.name_suffix = request->person_list[x].name_suffix, pn.name_prefix = " ", pn.name_first_key
       = cnvtupper(cnvtalphanum(request->person_list[x].name_first)),
      pn.name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].name_last)), pn
      .name_middle_key = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)), pn
      .name_type_seq = 1,
      pn.data_status_cd = auth_cd, pn.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
      .data_status_prsnl_id = reqinfo->updt_id,
      pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), pn.active_ind = active_ind,
      pn.active_status_cd = active_cd, pn.active_status_prsnl_id = reqinfo->updt_id, pn
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_applctx = reqinfo->updt_applctx, pn
      .updt_cnt = 0,
      pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "New CURRENT person_name row written for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
     IF (bhistoryoption=1)
      SET save_person_id = person_id
      SET pm_hist_tracking_id = 0.0
      SELECT INTO "nl:"
       j = seq(person_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        pm_hist_tracking_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM pm_hist_tracking pht
       SET pht.pm_hist_tracking_id = pm_hist_tracking_id, pht.transaction_dt_tm = cnvtdatetime(
         curdate,curtime3), pht.transaction_type_txt = "ADD",
        pht.transaction_reason_txt = "BED_ENS_PRSNL", pht.transaction_reason_cd = 0.0, pht
        .conv_task_number = 0,
        pht.person_id = 0.0, pht.encntr_id = 0.0, pht.create_dt_tm = cnvtdatetime(curdate,curtime3),
        pht.create_prsnl_id = reqinfo->updt_id, pht.create_task = reqinfo->updt_task, pht
        .contributor_system_cd = 0,
        pht.updt_dt_tm = cnvtdatetime(curdate,curtime3), pht.updt_applctx = reqinfo->updt_applctx,
        pht.updt_cnt = 0,
        pht.updt_id = reqinfo->updt_id, pht.updt_task = reqinfo->updt_task, pht.hl7_event = null
       WITH nocounter
      ;end insert
      SET dhistid = 0.0
      SET dttrans = 0.0
      SET dhistid = pm_hist_tracking_id
      SET dttrans = cnvtdatetime(curdate,curtime3)
      SELECT INTO "nl:"
       FROM person_name p
       WHERE p.person_name_id=person_name_id
       DETAIL
        CALL fh_setids(dhistid,0.0,p.person_id),
        CALL fh_setdata(dttrans,p.contributor_system_cd,0),
        CALL fh_setcategory(dnamecatcd),
        CALL fh_setdouble(1,"person_name_id",p.person_name_id),
        CALL fh_setdouble(1,"name_type_cd",p.name_type_cd),
        CALL fh_setstring(1,"name_first",p.name_first),
        CALL fh_setstring(1,"name_middle",p.name_middle),
        CALL fh_setstring(1,"name_last",p.name_last),
        CALL fh_setstring(1,"name_degree",p.name_degree),
        CALL fh_setstring(1,"name_prefix",p.name_prefix),
        CALL fh_setstring(1,"name_suffix",p.name_suffix),
        CALL fh_setstring(1,"name_title",p.name_title),
        CALL fh_setstring(1,"name_full",p.name_full),
        CALL fh_setstring(1,"name_initials",p.name_initials)
       WITH nocounter
      ;end select
      CALL fh_processhistory(0)
      CALL fh_clearrecord(0)
      SET person_id = save_person_id
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new CURRENT person_name row for: ",trim(
       request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
    SELECT INTO "nl:"
     j = seq(person_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      person_name_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM person_name pn
     SET pn.person_name_id = person_name_id, pn.person_id = person_id, pn.contributor_system_cd = 0,
      pn.name_type_cd = prsnl_name_type_cd, pn.name_full = name_ff, pn.name_first = request->
      person_list[x].name_first,
      pn.name_middle = request->person_list[x].name_middle, pn.name_last = request->person_list[x].
      name_last, pn.name_title = request->person_list[x].name_title,
      pn.name_suffix = request->person_list[x].name_suffix, pn.name_prefix = " ", pn.name_first_key
       = cnvtupper(cnvtalphanum(request->person_list[x].name_first)),
      pn.name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].name_last)), pn
      .name_middle_key = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)), pn
      .name_type_seq = 1,
      pn.data_status_cd = auth_cd, pn.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
      .data_status_prsnl_id = reqinfo->updt_id,
      pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), pn.active_ind = active_ind,
      pn.active_status_cd = active_cd, pn.active_status_prsnl_id = reqinfo->updt_id, pn
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_applctx = reqinfo->updt_applctx, pn
      .updt_cnt = 0,
      pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "New PRSNL person_name row written for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
     IF (bhistoryoption=1)
      SET save_person_id = person_id
      SET pm_hist_tracking_id = 0.0
      SELECT INTO "nl:"
       j = seq(person_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        pm_hist_tracking_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM pm_hist_tracking pht
       SET pht.pm_hist_tracking_id = pm_hist_tracking_id, pht.transaction_dt_tm = cnvtdatetime(
         curdate,curtime3), pht.transaction_type_txt = "ADD",
        pht.transaction_reason_txt = "BED_ENS_PRSNL", pht.transaction_reason_cd = 0.0, pht
        .conv_task_number = 0,
        pht.person_id = 0.0, pht.encntr_id = 0.0, pht.create_dt_tm = cnvtdatetime(curdate,curtime3),
        pht.create_prsnl_id = reqinfo->updt_id, pht.create_task = reqinfo->updt_task, pht
        .contributor_system_cd = 0,
        pht.updt_dt_tm = cnvtdatetime(curdate,curtime3), pht.updt_applctx = reqinfo->updt_applctx,
        pht.updt_cnt = 0,
        pht.updt_id = reqinfo->updt_id, pht.updt_task = reqinfo->updt_task, pht.hl7_event = null
       WITH nocounter
      ;end insert
      SET dhistid = 0.0
      SET dttrans = 0.0
      SET dhistid = pm_hist_tracking_id
      SET dttrans = cnvtdatetime(curdate,curtime3)
      SELECT INTO "nl:"
       FROM person_name p
       WHERE p.person_name_id=person_name_id
       DETAIL
        CALL fh_setids(dhistid,0.0,p.person_id),
        CALL fh_setdata(dttrans,p.contributor_system_cd,0),
        CALL fh_setcategory(dnamecatcd),
        CALL fh_setdouble(1,"person_name_id",p.person_name_id),
        CALL fh_setdouble(1,"name_type_cd",p.name_type_cd),
        CALL fh_setstring(1,"name_first",p.name_first),
        CALL fh_setstring(1,"name_middle",p.name_middle),
        CALL fh_setstring(1,"name_last",p.name_last),
        CALL fh_setstring(1,"name_degree",p.name_degree),
        CALL fh_setstring(1,"name_prefix",p.name_prefix),
        CALL fh_setstring(1,"name_suffix",p.name_suffix),
        CALL fh_setstring(1,"name_title",p.name_title),
        CALL fh_setstring(1,"name_full",p.name_full),
        CALL fh_setstring(1,"name_initials",p.name_initials)
       WITH nocounter
      ;end select
      CALL fh_processhistory(0)
      CALL fh_clearrecord(0)
      SET person_id = save_person_id
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new PRSNL person_name row for: ",trim(
       request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Unable to generate a new person_id for: ",trim(request->
      person_list[x].name_first),trim(request->person_list[x].name_last),
     ". Unable to add personnel.")
   ENDIF
   IF ((request->person_list[x].username > " "))
    SET shared_domain_ind = 0
    RANGE OF c IS code_value_set
    SET fnd = validate(c.br_client_id)
    FREE RANGE c
    IF (fnd=1)
     SET shared_domain_ind = 1
    ELSE
     SET shared_domain_ind = 0
    ENDIF
    IF (shared_domain_ind=0)
     IF ((request->person_list[x].name_full_formatted > " "))
      SET name_ff = request->person_list[x].name_full_formatted
     ELSE
      SET name_ff = uar_i18nbuildfullformatname(nullterm(trim(request->person_list[x].name_first,3)),
       nullterm(trim(request->person_list[x].name_last,3)),nullterm(trim(request->person_list[x].
         name_middle,3)),"",nullterm(trim(request->person_list[x].name_title,3)),
       "",nullterm(trim(request->person_list[x].name_suffix,3)),"","")
     ENDIF
     SET add_user = uar_sec_user(nullterm(request->person_list[x].username),nullterm(request->
       person_list[x].username),name_ff)
    ENDIF
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Name_First or Name_Last missing for new personnel, unable to add - entry nbr: ",cnvtstring(x))
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_prsnl(x)
  IF ((request->person_list[x].person_id > 0))
   IF ((request->person_list[x].name_full_formatted > " "))
    SET name_ff = request->person_list[x].name_full_formatted
   ELSE
    SET name_ff = uar_i18nbuildfullformatname(nullterm(trim(request->person_list[x].name_first,3)),
     nullterm(trim(request->person_list[x].name_last,3)),nullterm(trim(request->person_list[x].
       name_middle,3)),"",nullterm(trim(request->person_list[x].name_title,3)),
     "",nullterm(trim(request->person_list[x].name_suffix,3)),"","")
   ENDIF
   SET shared_domain_ind = 0
   SET username_upd = 0
   IF ((request->person_list[x].username > " "))
    RANGE OF c IS code_value_set
    SET fnd = validate(c.br_client_id)
    FREE RANGE c
    IF (fnd=1)
     SET shared_domain_ind = 1
    ELSE
     SET shared_domain_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM prsnl pr
     WHERE (pr.person_id=request->person_list[x].person_id)
     DETAIL
      IF ((request->person_list[x].username != pr.username))
       username_upd = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET active_ind = 0
   IF ((request->person_list[x].active_ind_ind=1))
    SET active_ind = request->person_list[x].active_ind
   ELSE
    SET active_ind = 1
   ENDIF
   UPDATE  FROM person p
    SET p.contributor_system_cd = 0, p.person_type_cd = person_type_cd, p.name_first = trim(request->
      person_list[x].name_first),
     p.name_last = trim(request->person_list[x].name_last), p.name_middle = trim(request->
      person_list[x].name_middle), p.name_first_key = cnvtupper(cnvtalphanum(request->person_list[x].
       name_first)),
     p.name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].name_last)), p.name_middle_key
      = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)), p.name_full_formatted = name_ff,
     p.name_phonetic = soundex(cnvtupper(request->person_list[x].name_last)), p.name_last_phonetic =
     soundex(cnvtupper(request->person_list[x].name_last)), p.name_first_phonetic = soundex(cnvtupper
      (request->person_list[x].name_first)),
     p.birth_dt_cd = 0, p.birth_dt_tm = cnvtdatetime(request->person_list[x].birth_dt_tm), p.sex_cd
      = request->person_list[x].sex_code_value,
     p.data_status_cd = auth_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
     .data_status_prsnl_id = 0,
     p.create_dt_tm = cnvtdatetime(curdate,curtime3), p.create_prsnl_id = reqinfo->updt_id, p
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->
     updt_id,
     p.updt_task = reqinfo->updt_task
    WHERE (p.person_id=request->person_list[x].person_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error writing new person for for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last)
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Person row successfully added for: ",request->person_list[x].name_first," ",
     request->person_list[x].name_last)
    SET current_person_name_id = 0.0
    SELECT INTO "nl:"
     FROM person_name pn
     WHERE (pn.person_id=request->person_list[x].person_id)
      AND pn.name_type_cd=prsnl_name_type_cd
      AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pn.active_ind=1
     ORDER BY pn.updt_dt_tm DESC, pn.person_id
     HEAD pn.person_id
      current_person_name_id = pn.person_name_id
     WITH nocounter
    ;end select
    IF (current_person_name_id > 0.0)
     UPDATE  FROM person_name pn
      SET pn.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), pn.updt_applctx = reqinfo->updt_applctx,
       pn.updt_cnt = (pn.updt_cnt+ 1), pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->
       updt_task
      WHERE pn.person_name_id=current_person_name_id
      WITH nocounter
     ;end update
    ENDIF
    SET person_name_id = 0.0
    SELECT INTO "nl:"
     j = seq(person_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      person_name_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM person_name pn
     SET pn.person_name_id = person_name_id, pn.person_id = request->person_list[x].person_id, pn
      .contributor_system_cd = 0,
      pn.name_type_cd = prsnl_name_type_cd, pn.name_full = name_ff, pn.name_first = request->
      person_list[x].name_first,
      pn.name_middle = request->person_list[x].name_middle, pn.name_last = request->person_list[x].
      name_last, pn.name_title = request->person_list[x].name_title,
      pn.name_suffix = request->person_list[x].name_suffix, pn.name_prefix = " ", pn.name_first_key
       = cnvtupper(cnvtalphanum(request->person_list[x].name_first)),
      pn.name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].name_last)), pn
      .name_middle_key = cnvtupper(cnvtalphanum(request->person_list[x].name_middle)), pn
      .name_type_seq = 1,
      pn.data_status_cd = auth_cd, pn.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pn
      .data_status_prsnl_id = reqinfo->updt_id,
      pn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pn.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), pn.active_ind = 1,
      pn.active_status_cd = active_cd, pn.active_status_prsnl_id = reqinfo->updt_id, pn
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      pn.updt_dt_tm = cnvtdatetime(curdate,curtime3), pn.updt_applctx = reqinfo->updt_applctx, pn
      .updt_cnt = 0,
      pn.updt_id = reqinfo->updt_id, pn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new person_name row for prsnl: ",request->
      person_list[x].name_first," ",
      request->person_list[x].name_last)
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Person_name row successfully added for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last)
     IF (bhistoryoption=1)
      SET save_person_id = person_id
      SET pm_hist_tracking_id = 0.0
      SELECT INTO "nl:"
       j = seq(person_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        pm_hist_tracking_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM pm_hist_tracking pht
       SET pht.pm_hist_tracking_id = pm_hist_tracking_id, pht.transaction_dt_tm = cnvtdatetime(
         curdate,curtime3), pht.transaction_type_txt = "ATDS",
        pht.transaction_reason_txt = "BED_ENS_PRSNL", pht.transaction_reason_cd = 0.0, pht
        .conv_task_number = 0,
        pht.person_id = 0.0, pht.encntr_id = 0.0, pht.create_dt_tm = cnvtdatetime(curdate,curtime3),
        pht.create_prsnl_id = reqinfo->updt_id, pht.create_task = reqinfo->updt_task, pht
        .contributor_system_cd = 0,
        pht.updt_dt_tm = cnvtdatetime(curdate,curtime3), pht.updt_applctx = reqinfo->updt_applctx,
        pht.updt_cnt = 0,
        pht.updt_id = reqinfo->updt_id, pht.updt_task = reqinfo->updt_task, pht.hl7_event = null
       WITH nocounter
      ;end insert
      SET dhistid = 0.0
      SET dttrans = 0.0
      SET dhistid = pm_hist_tracking_id
      SET dttrans = cnvtdatetime(curdate,curtime3)
      SELECT INTO "nl:"
       FROM person_name p
       WHERE p.person_name_id=person_name_id
       DETAIL
        CALL fh_setids(dhistid,0.0,p.person_id),
        CALL fh_setdata(dttrans,p.contributor_system_cd,0),
        CALL fh_setcategory(dnamecatcd),
        CALL fh_setdouble(1,"person_name_id",p.person_name_id),
        CALL fh_setdouble(1,"name_type_cd",p.name_type_cd),
        CALL fh_setstring(1,"name_first",p.name_first),
        CALL fh_setstring(1,"name_middle",p.name_middle),
        CALL fh_setstring(1,"name_last",p.name_last),
        CALL fh_setstring(1,"name_degree",p.name_degree),
        CALL fh_setstring(1,"name_prefix",p.name_prefix),
        CALL fh_setstring(1,"name_suffix",p.name_suffix),
        CALL fh_setstring(1,"name_title",p.name_title),
        CALL fh_setstring(1,"name_full",p.name_full),
        CALL fh_setstring(1,"name_initials",p.name_initials)
       WITH nocounter
      ;end select
      CALL fh_processhistory(0)
      CALL fh_clearrecord(0)
      SET person_id = save_person_id
     ENDIF
     UPDATE  FROM prsnl pr
      SET pr.name_first = request->person_list[x].prsnl_name_first, pr.name_last = request->
       person_list[x].prsnl_name_last, pr.name_first_key = cnvtupper(cnvtalphanum(request->
         person_list[x].prsnl_name_first)),
       pr.name_last_key = cnvtupper(cnvtalphanum(request->person_list[x].prsnl_name_last)), pr
       .name_full_formatted = name_ff, pr.prsnl_type_cd = prsnl_type_cd,
       pr.email = request->person_list[x].email, pr.physician_ind = request->person_list[x].
       physician_ind, pr.position_cd = request->person_list[x].position_code_value,
       pr.free_text_ind = 0, pr.username = request->person_list[x].username, pr.prim_assign_loc_cd =
       request->person_list[x].primary_work_loc_code_value,
       pr.contributor_system_cd = 0, pr.data_status_cd = auth_cd, pr.data_status_dt_tm = cnvtdatetime
       (curdate,curtime3),
       pr.data_status_prsnl_id = 0, pr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pr
       .create_dt_tm = cnvtdatetime(curdate,curtime3),
       pr.create_prsnl_id = reqinfo->updt_id, pr.active_ind = active_ind, pr.active_status_cd =
       active_cd,
       pr.active_status_prsnl_id = 0, pr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pr
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = (pr.updt_cnt+ 1), pr.updt_id = reqinfo
       ->updt_id,
       pr.updt_task = reqinfo->updt_task, pr.external_ind = request->person_list[x].external_ind
      WHERE (pr.person_id=request->person_list[x].person_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Error writing new prsnl row for prsnl: ",request->
       person_list[x].name_first," ",
       request->person_list[x].name_last)
     ELSE
      SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
       "Prsnl row successfully added for: ",request->person_list[x].name_first," ",
       request->person_list[x].name_last)
     ENDIF
    ENDIF
   ENDIF
   IF (shared_domain_ind=0
    AND username_upd=1)
    SET add_user = uar_sec_user(nullterm(request->person_list[x].username),nullterm(request->
      person_list[x].username),name_ff)
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Person_ID required, error updating prsnl: ",request->
    person_list[x].name_first," ",
    request->person_list[x].name_last)
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_prsnl(x)
  IF ((request->person_list[x].person_id > 0))
   UPDATE  FROM prsnl p
    SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1)
    WHERE (p.person_id=request->person_list[x].person_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error inactivating prsnl - unable to update prsnl table: ",
     request->person_list[x].name_first," ",
     request->person_list[x].name_last)
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully inactivated prsnl: ",cnvtstring(request->person_list[x].person_id)," ",
     request->person_list[x].name_first," ",request->person_list[x].name_last)
   ENDIF
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_alias(x,y)
   SET alias_type_cd = 0.0
   SET al_code_set = 0.0
   IF ((request->person_list[x].alias_list[y].person_prsnl_flag=1))
    SET al_code_set = 320
   ELSEIF ((request->person_list[x].alias_list[y].person_prsnl_flag=2))
    SET al_code_set = 4
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Person_prsnl_flag not set for alias: ",request->
     person_list[x].alias_list[y].alias,". Unable to add alias for prsnl: ",
     request->person_list[x].name_first,request->person_list[x].name_last,".")
   ENDIF
   IF ((request->person_list[x].alias_list[y].alias_type_code_value=0))
    IF (trim(request->person_list[x].alias_list[y].alias_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=al_code_set
        AND (c.cdf_meaning=request->person_list[x].alias_list[y].alias_type_mean))
      DETAIL
       alias_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (alias_type_cd=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Code value not found for alias type mean: ",request->
       person_list[x].alias_list[y].alias_type_mean,". Unable to add alias for prsnl: ",
       request->person_list[x].name_first,request->person_list[x].name_last,".")
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Alias type code value not available, unable to add ",
      "alias for prsnl: ",request->person_list[x].name_first,
      request->person_list[x].name_last,".")
    ENDIF
   ELSE
    SET alias_type_cd = request->person_list[x].alias_list[y].alias_type_code_value
   ENDIF
   SET alias_pool_cd = 0.0
   IF ((request->person_list[x].alias_list[y].alias_pool_code_value=0))
    IF (trim(request->person_list[x].alias_list[y].alias_pool_disp) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=263
        AND c.display_key=cnvtupper(cnvtalphanum(request->person_list[x].alias_list[y].
         alias_pool_disp)))
      DETAIL
       alias_pool_cd = c.code_value
      WITH nocounter
     ;end select
     IF (alias_pool_cd=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Code value not found for alias pool disp: ",request->
       person_list[x].alias_list[y].alias_pool_disp,". Unable to add alias for prsnl: ",
       request->person_list[x].name_first,request->person_list[x].name_last,".")
     ENDIF
    ELSE
     SET alias_pool_cd = 0.0
    ENDIF
   ELSE
    SET alias_pool_cd = request->person_list[x].alias_list[y].alias_pool_code_value
   ENDIF
   IF (alias_type_cd > 0)
    IF ((request->person_list[x].alias_list[y].person_prsnl_flag=1))
     SET alias_id = 0.0
     SELECT INTO "nl:"
      j = seq(prsnl_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       alias_id = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Unable to generate new prsnl_alias_id for prsnl: ",
       request->person_list[x].name_first,request->person_list[x].name_last,
       ".")
     ELSE
      INSERT  FROM prsnl_alias pra
       SET pra.prsnl_alias_id = alias_id, pra.person_id = person_id, pra.alias_pool_cd =
        alias_pool_cd,
        pra.prsnl_alias_type_cd = alias_type_cd, pra.alias = request->person_list[x].alias_list[y].
        alias, pra.contributor_system_cd = 0,
        pra.updt_id = reqinfo->updt_id, pra.updt_cnt = 0, pra.updt_applctx = reqinfo->updt_applctx,
        pra.updt_task = reqinfo->updt_task, pra.updt_dt_tm = cnvtdatetime(curdate,curtime3), pra
        .active_ind = 1,
        pra.active_status_cd = active_cd, pra.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        pra.active_status_prsnl_id = reqinfo->updt_id,
        pra.data_status_cd = auth_cd, pra.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pra
        .data_status_prsnl_id = reqinfo->updt_id,
        pra.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pra.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,">>","Error writing alias",request->person_list[x].
        alias_list[y].alias," for prsnl: ",
        request->person_list[x].name_first," ",request->person_list[x].name_last,".")
      ELSE
       SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
        "Successfully added alias for prsnl: ",request->person_list[x].name_first," ",
        request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
      ENDIF
     ENDIF
    ELSEIF ((request->person_list[x].alias_list[y].person_prsnl_flag=2))
     SET alias_id = 0.0
     SELECT INTO "nl:"
      j = seq(person_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       alias_id = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Unable to generate new prsnl_alias_id for prsnl: ",
       request->person_list[x].name_first,request->person_list[x].name_last,
       ".")
     ELSE
      INSERT  FROM person_alias pea
       SET pea.person_alias_id = alias_id, pea.person_id = person_id, pea.alias_pool_cd =
        alias_pool_cd,
        pea.person_alias_type_cd = alias_type_cd, pea.alias = request->person_list[x].alias_list[y].
        alias, pea.contributor_system_cd = 0,
        pea.updt_id = reqinfo->updt_id, pea.updt_cnt = 0, pea.updt_applctx = reqinfo->updt_applctx,
        pea.updt_task = reqinfo->updt_task, pea.updt_dt_tm = cnvtdatetime(curdate,curtime3), pea
        .active_ind = 1,
        pea.active_status_cd = active_cd, pea.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        pea.active_status_prsnl_id = 0,
        pea.data_status_cd = auth_cd, pea.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pea
        .data_status_prsnl_id = 0,
        pea.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pea.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,">>","Error writing alias",request->person_list[x].
        alias_list[y].alias," for prsnl: ",
        request->person_list[x].name_first," ",request->person_list[x].name_last,".")
      ELSE
       SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
        "Successfully added alias for prsnl: ",request->person_list[x].name_first," ",
        request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_alias(x,y)
  IF ((request->person_list[x].alias_list[y].alias_id > 0))
   IF ((request->person_list[x].alias_list[y].person_prsnl_flag=1))
    UPDATE  FROM prsnl_alias pra
     SET pra.person_id = request->person_list[x].person_id, pra.alias_pool_cd = request->person_list[
      x].alias_list[y].alias_pool_code_value, pra.prsnl_alias_type_cd = request->person_list[x].
      alias_list[y].alias_type_code_value,
      pra.alias = request->person_list[x].alias_list[y].alias, pra.contributor_system_cd = 0, pra
      .updt_id = reqinfo->updt_id,
      pra.updt_cnt = (pra.updt_cnt+ 1), pra.updt_applctx = reqinfo->updt_applctx, pra.updt_task =
      reqinfo->updt_task,
      pra.updt_dt_tm = cnvtdatetime(curdate,curtime3), pra.active_ind = 1, pra.active_status_cd =
      active_cd,
      pra.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pra.active_status_prsnl_id = 0, pra
      .data_status_cd = auth_cd,
      pra.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pra.data_status_prsnl_id = 0, pra
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      pra.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     WHERE (pra.prsnl_alias_id=request->person_list[x].alias_list[y].alias_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error updating alias",request->person_list[x].alias_list[
      y].alias," for prsnl: ",
      request->person_list[x].name_first," ",request->person_list[x].name_last,".")
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully updated alias for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ENDIF
   ELSEIF ((request->person_list[x].alias_list[y].person_prsnl_flag=2))
    UPDATE  FROM person_alias pea
     SET pea.person_id = request->person_list[x].person_id, pea.alias_pool_cd = request->person_list[
      x].alias_list[y].alias_pool_code_value, pea.person_alias_type_cd = request->person_list[x].
      alias_list[y].alias_type_code_value,
      pea.alias = request->person_list[x].alias_list[y].alias, pea.contributor_system_cd = 0, pea
      .updt_id = reqinfo->updt_id,
      pea.updt_cnt = (pea.updt_cnt+ 1), pea.updt_applctx = reqinfo->updt_applctx, pea.updt_task =
      reqinfo->updt_task,
      pea.updt_dt_tm = cnvtdatetime(curdate,curtime3), pea.active_ind = 1, pea.active_status_cd =
      active_cd,
      pea.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pea.active_status_prsnl_id = 0, pea
      .data_status_cd = auth_cd,
      pea.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pea.data_status_prsnl_id = 0, pea
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      pea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     WHERE (pea.person_alias_id=request->person_list[x].alias_list[y].alias_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error updating alias",request->person_list[x].alias_list[
      y].alias," for prsnl: ",
      request->person_list[x].name_first," ",request->person_list[x].name_last,". Alias: ",request->
      person_list[x].alias_list[y].alias)
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully updated alias for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>",
     "Invalid person_prsnl_flag value, error updating alias for prsnl: ",request->person_list[x].
     name_first," ",
     request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Alias_ID required, error updating alias for prsnl: ",
    request->person_list[x].name_first," ",
    request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_alias(x,y)
  IF ((request->person_list[x].alias_list[y].alias_id > 0))
   IF ((request->person_list[x].alias_list[y].person_prsnl_flag=1))
    UPDATE  FROM prsnl_alias pra
     SET pra.active_ind = 0, pra.active_status_cd = inactive_cd, pra.updt_cnt = (pra.updt_cnt+ 1),
      pra.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (pra.prsnl_alias_id=request->person_list[x].alias_list[y].alias_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error inactivating alias for prsnl: ",request->
      person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully inactivated alias for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ENDIF
   ELSEIF ((request->person_list[x].alias_list[y].person_prsnl_flag=2))
    UPDATE  FROM person_alias pea
     SET pea.active_ind = 0, pea.active_status_cd = inactive_cd, pea.updt_cnt = (pea.updt_cnt+ 1),
      pea.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (pea.person_alias_id=request->person_list[x].alias_list[y].alias_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error inactivating person alias for prsnl: ",request->
      person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully inactivated person alias for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Invalid person_prsnl_flag for prsnl alias: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Alias_ID required, error inactivating alias for prsnl: ",
    request->person_list[x].name_first," ",
    request->person_list[x].name_last," alias: ",request->person_list[x].alias_list[y].alias,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_address(x,y)
   SET address_type_cd = 0.0
   IF ((request->person_list[x].address_list[y].address_type_code_value=0))
    IF (trim(request->person_list[x].address_list[y].address_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=212
        AND (c.cdf_meaning=request->person_list[x].address_list[y].address_type_mean))
      DETAIL
       address_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (address_type_cd=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Code value not found for address type mean: ",request->
       person_list[x].address_list[y].address_type_mean,". Unable to add address for personnel: ",
       request->person_list[x].name_first," ",request->person_list[x].name_last,".")
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>",
      "Address type code value not available, unable to add address for prsnl: ",request->
      person_list[x].name_first," ",
      request->person_list[x].name_last,".")
    ENDIF
   ELSE
    SET address_type_cd = request->person_list[x].address_list[y].address_type_code_value
   ENDIF
   IF (address_type_cd > 0)
    SET state_display = " "
    IF ((request->person_list[x].address_list[y].state_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->person_list[x].address_list[y].state_code_value)
       AND cv.active_ind=1
      DETAIL
       state_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET county_display = " "
    IF ((request->person_list[x].address_list[y].county_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->person_list[x].address_list[y].county_code_value)
       AND cv.active_ind=1
      DETAIL
       county_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET country_display = " "
    IF ((request->person_list[x].address_list[y].country_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->person_list[x].address_list[y].country_code_value)
       AND cv.active_ind=1
      DETAIL
       country_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    INSERT  FROM address a
     SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "PERSON", a.parent_entity_id
       = person_id,
      a.address_type_cd = address_type_cd, a.address_type_seq = request->person_list[x].address_list[
      y].address_type_seq, a.updt_id = reqinfo->updt_id,
      a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task,
      a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.active_ind = 1, a.active_status_cd = active_cd,
      a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
      updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.street_addr = request->person_list[x].
      address_list[y].street_addr, a.street_addr2 = request->person_list[x].address_list[y].
      street_addr2,
      a.street_addr3 = request->person_list[x].address_list[y].street_addr3, a.street_addr4 = request
      ->person_list[x].address_list[y].street_addr4, a.city = request->person_list[x].address_list[y]
      .city,
      a.state = state_display, a.state_cd = request->person_list[x].address_list[y].state_code_value,
      a.zipcode = request->person_list[x].address_list[y].zipcode,
      a.county = county_display, a.county_cd = request->person_list[x].address_list[y].
      county_code_value, a.country = country_display,
      a.country_cd = request->person_list[x].address_list[y].country_code_value, a.contact_name =
      request->person_list[x].address_list[y].contact_name, a.residence_type_cd = request->
      person_list[x].address_list[y].residence_type_code_value,
      a.comment_txt = request->person_list[x].address_list[y].comment_txt, a.postal_barcode_info =
      " ", a.operation_hours = " ",
      a.zipcode_key = cnvtalphanum(request->person_list[x].address_list[y].zipcode), a.data_status_cd
       = auth_cd, a.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      a.data_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing address for personnel: ",request->
      person_list[x].name_first," ",
      request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
      address_type_mean,".")
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully wrote address for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
      address_type_mean,".")
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_address(x,y)
  IF ((request->person_list[x].address_list[y].address_id > 0))
   SET state_display = " "
   IF ((request->person_list[x].address_list[y].state_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->person_list[x].address_list[y].state_code_value)
      AND cv.active_ind=1
     DETAIL
      state_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET county_display = " "
   IF ((request->person_list[x].address_list[y].county_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->person_list[x].address_list[y].county_code_value)
      AND cv.active_ind=1
     DETAIL
      county_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   SET country_display = " "
   IF ((request->person_list[x].address_list[y].country_code_value > 0))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->person_list[x].address_list[y].country_code_value)
      AND cv.active_ind=1
     DETAIL
      country_display = cv.display
     WITH nocounter
    ;end select
   ENDIF
   UPDATE  FROM address a
    SET a.street_addr = request->person_list[x].address_list[y].street_addr, a.street_addr2 = request
     ->person_list[x].address_list[y].street_addr2, a.street_addr3 = request->person_list[x].
     address_list[y].street_addr3,
     a.street_addr4 = request->person_list[x].address_list[y].street_addr4, a.city = request->
     person_list[x].address_list[y].city, a.state = state_display,
     a.state_cd = request->person_list[x].address_list[y].state_code_value, a.zipcode = request->
     person_list[x].address_list[y].zipcode, a.county = county_display,
     a.county_cd = request->person_list[x].address_list[y].county_code_value, a.country =
     country_display, a.country_cd = request->person_list[x].address_list[y].country_code_value,
     a.contact_name = request->person_list[x].address_list[y].contact_name, a.residence_type_cd =
     request->person_list[x].address_list[y].residence_type_code_value, a.comment_txt = request->
     person_list[x].address_list[y].comment_txt,
     a.address_type_cd = request->person_list[x].address_list[y].address_type_code_value, a
     .address_type_seq = request->person_list[x].address_list[y].address_type_seq, a.updt_cnt = (a
     .updt_cnt+ 1),
     a.updt_id = reqinfo->updt_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->person_list[x].address_list[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error updating address for prsnl: ",request->person_list[x
     ].name_first," ",
     request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
     address_type_mean,".")
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully updated address for prsnl: ",request->person_list[x].name_first," ",
     request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
     address_type_mean,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Address_ID required, error updating address for prsnl: ",
    request->person_list[x].name_first," ",
    request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
    address_type_mean,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_address(x,y)
  IF ((request->person_list[x].address_list[y].address_id > 0))
   UPDATE  FROM address a
    SET a.active_ind = 0, a.active_status_cd = inactive_cd, a.updt_cnt = (a.updt_cnt+ 1),
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (a.address_id=request->person_list[x].address_list[y].address_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error inactivating address for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
     address_type_mean,".")
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully inactivated address for prsnl: ",request->person_list[x].name_first," ",
     request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
     address_type_mean,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Address_ID required, error inactivating address for prsnl: ",request->person_list[x].name_first,
    " ",
    request->person_list[x].name_last," address type: ",request->person_list[x].address_list[y].
    address_type_mean,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_phone(x,y)
   SET phone_type_cd = 0.0
   IF ((request->person_list[x].phone_list[y].phone_type_code_value=0))
    IF (trim(request->person_list[x].phone_list[y].phone_type_mean) > " ")
     SELECT INTO "nl:"
      FROM code_value c
      PLAN (c
       WHERE c.code_set=43
        AND (c.cdf_meaning=request->person_list[x].phone_list[y].phone_type_mean))
      DETAIL
       phone_type_cd = c.code_value
      WITH nocounter
     ;end select
     IF (phone_type_cd=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>","Code value not found for phone type mean: ",request->
       person_list[x].phone_list[y].phone_type_mean,". Unable to add phone for prsnl: ",
       request->person_list[x].name_first," ",request->person_list[x].name_last,".")
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Phone type code value not available, unable to add ",
      "phone for prsnl: ",request->person_list[x].name_first,
      " ",request->person_list[x].name_last,".")
    ENDIF
   ELSE
    SET phone_type_cd = request->person_list[x].phone_list[y].phone_type_code_value
   ENDIF
   IF (phone_type_cd > 0)
    SET phone_format_cd = 0.0
    IF ((request->person_list[x].phone_list[y].phone_format_code_value > 0))
     SET phone_format_cd = request->person_list[x].phone_list[y].phone_format_code_value
    ELSE
     IF (trim(request->person_list[x].phone_list[y].phone_format_mean) > " ")
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=281
         AND (cv.cdf_meaning=request->person_list[x].phone_list[y].phone_format_mean))
       DETAIL
        phone_format_cd = cv.code_value
       WITH nocounter
      ;end select
     ELSE
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=281
         AND cv.cdf_meaning="DEFAULT")
       DETAIL
        phone_format_cd = cv.code_value
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    SET contact_method_cd = 0.0
    IF (validate(request->person_list[x].phone_list[y].contact_method_code_value))
     SET contact_method_cd = request->person_list[x].phone_list[y].contact_method_code_value
    ENDIF
    SET contributor_system_cd = 0.0
    IF (validate(request->person_list[x].phone_list[y].contributor_system_code_value))
     SET contributor_system_cd = request->person_list[x].phone_list[y].contributor_system_code_value
    ENDIF
    INSERT  FROM phone p
     SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "PERSON", p.parent_entity_id =
      person_id,
      p.phone_type_cd = phone_type_cd, p.phone_format_cd = phone_format_cd, p.phone_num = trim(
       request->person_list[x].phone_list[y].phone_num),
      p.phone_num_key = trim(cnvtupper(cnvtalphanum(request->person_list[x].phone_list[y].phone_num))
       ), p.phone_type_seq = request->person_list[x].phone_list[y].sequence, p.description = trim(
       request->person_list[x].phone_list[y].description),
      p.contact = trim(request->person_list[x].phone_list[y].contact), p.call_instruction = trim(
       request->person_list[x].phone_list[y].call_instruction), p.extension = trim(request->
       person_list[x].phone_list[y].extension),
      p.paging_code = trim(request->person_list[x].phone_list[y].paging_code), p.operation_hours =
      " ", p.contact_method_cd = contact_method_cd,
      p.contributor_system_cd = contributor_system_cd, p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
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
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing phone for prsnl: ",request->person_list[x].
      name_first," ",
      request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
      phone_type_mean,".")
    ELSE
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "Successfully added phone for prsnl: ",request->person_list[x].name_first," ",
      request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
      phone_type_mean,".")
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_phone(x,y)
  IF ((request->person_list[x].phone_list[y].phone_id > 0))
   SET contact_method_cd = 0.0
   IF (validate(request->person_list[x].phone_list[y].contact_method_code_value))
    SET contact_method_cd = request->person_list[x].phone_list[y].contact_method_code_value
   ENDIF
   UPDATE  FROM phone p
    SET p.phone_format_cd = request->person_list[x].phone_list[y].phone_format_code_value, p
     .phone_num = request->person_list[x].phone_list[y].phone_num, p.phone_num_key = cnvtupper(
      cnvtalphanum(request->person_list[x].phone_list[y].phone_num)),
     p.phone_type_seq = request->person_list[x].phone_list[y].sequence, p.description = request->
     person_list[x].phone_list[y].description, p.contact = request->person_list[x].phone_list[y].
     contact,
     p.call_instruction = request->person_list[x].phone_list[y].call_instruction, p.paging_code =
     request->person_list[x].phone_list[y].paging_code, p.extension = request->person_list[x].
     phone_list[y].extension,
     p.phone_type_cd = request->person_list[x].phone_list[y].phone_type_code_value, p
     .contact_method_cd = contact_method_cd, p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->person_list[x].phone_list[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error updating phone for prsnl: ",request->person_list[x].
     name_first," ",
     request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
     phone_type_mean,".")
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully updated phone for prsnl: ",request->person_list[x].name_first," ",
     request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
     phone_type_mean,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Phone_ID required, error updating phone for prsnl: ",
    request->person_list[x].name_first," ",
    request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
    phone_type_mean,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_phone(x,y)
  IF ((request->person_list[x].phone_list[y].phone_id > 0))
   UPDATE  FROM phone p
    SET p.active_ind = 0, p.active_status_cd = inactive_cd, p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (p.phone_id=request->person_list[x].phone_list[y].phone_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error inactivating phone for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
     phone_type_mean,".")
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully inactivated phone for prsnl: ",request->person_list[x].name_first," ",
     request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
     phone_type_mean,".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Phone_ID required, error inactivating phone for prsnl: ",
    request->person_list[x].name_first," ",
    request->person_list[x].name_last," phone type: ",request->person_list[x].phone_list[y].
    phone_type_mean,".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_org(x,y)
   SET confid_level_cd = 0.0
   IF ((request->person_list[x].org_list[y].confid_level_code_value=0))
    IF ((request->person_list[x].org_list[y].confid_level_mean > " "))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=87
        AND (cv.cdf_meaning=request->person_list[x].org_list[y].confid_level_mean))
      ORDER BY cv.code_value
      HEAD cv.code_value
       confid_level_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET confid_level_cd = 0.0
     ENDIF
    ENDIF
   ELSE
    SET confid_level_cd = request->person_list[x].org_list[y].confid_level_code_value
   ENDIF
   SET org_found = "N"
   SET org_id = 0.0
   SET org_name = fillstring(100," ")
   IF ((request->person_list[x].org_list[y].organization_id=0))
    IF ((request->person_list[x].org_list[y].organization_name > " "))
     SELECT INTO "nl:"
      FROM organization o
      PLAN (o
       WHERE o.org_name_key=cnvtupper(cnvtalphanum(request->person_list[x].org_list[y].
         organization_name)))
      ORDER BY o.organization_id
      HEAD o.organization_id
       org_id = o.organization_id, org_name = o.org_name
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org_found = "N"
     ELSE
      SET org_found = "Y"
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>",
      "Error adding prsnl-org relationship - no org specified for prsnl: ",request->person_list[x].
      name_first," ",
      request->person_list[x].name_last)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE (o.organization_id=request->person_list[x].org_list[y].organization_id))
     ORDER BY o.organization_id
     HEAD o.organization_id
      org_id = o.organization_id, org_name = o.org_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET org_found = "N"
    ELSE
     SET org_found = "Y"
    ENDIF
   ENDIF
   SET new_nbr = 0.0
   IF (org_found="Y")
    SELECT INTO "nl:"
     FROM prsnl_org_reltn p
     WHERE p.person_id=person_id
      AND p.organization_id=org_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "nl:"
      j = seq(prsnl_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>",
       "Error generating new prsnl-org relationship id for prsnl: ",request->person_list[x].
       name_first," ",
       request->person_list[x].name_last," Org: ",org_name,".")
     ELSE
      INSERT  FROM prsnl_org_reltn p
       SET p.prsnl_org_reltn_id = new_nbr, p.person_id = person_id, p.organization_id = org_id,
        p.confid_level_cd = confid_level_cd, p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        p.active_ind = 1, p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,">>","Error inserting prsnl-org relationship for prsnl: ",
        request->person_list[x].name_first," ",
        request->person_list[x].name_last," Org: ",org_name,".")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error: Org not found for prsnl: ",request->person_list[x].
     name_first," ",
     request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_list[y].
      organization_id),".")
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_org(x,y)
  IF ((request->person_list[x].org_list[y].prsnl_org_reltn_id > 0))
   UPDATE  FROM prsnl_org_reltn por
    SET por.confid_level_cd = request->person_list[x].org_list[y].confid_level_code_value, por
     .updt_cnt = (por.updt_cnt+ 1), por.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (por.prsnl_org_reltn_id=request->person_list[x].org_list[y].prsnl_org_reltn_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error updating org reltn for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_list[y].
      organization_id),".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Error: Prsnl_org_reltn_id required to change relationship: ",request->person_list[x].name_first,
    " ",
    request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_list[y].
     organization_id),".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_org(x,y)
  IF ((request->person_list[x].org_list[y].prsnl_org_reltn_id > 0))
   UPDATE  FROM prsnl_org_reltn por
    SET por.updt_cnt = (por.updt_cnt+ 1), por.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     por.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (por.prsnl_org_reltn_id=request->person_list[x].org_list[y].prsnl_org_reltn_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error inactivating org reltn for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_list[y].
      organization_id),".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Error: Prsnl_org_reltn_id required to remove relationship: ",request->person_list[x].name_first,
    " ",
    request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_list[y].
     organization_id),".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE add_org_group(x,y)
   SET org_set_type_cd = 0.0
   IF ((request->person_list[x].org_group_list[y].org_set_type_code_value=0))
    IF ((request->person_list[x].org_group_list[y].org_set_type_mean > " "))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=28881
        AND (cv.cdf_meaning=request->person_list[x].org_group_list[y].org_set_type_mean))
      ORDER BY cv.code_value
      HEAD cv.code_value
       org_set_type_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org_set_type_cd = 0.0
     ENDIF
    ELSE
     IF ((request->person_list[x].org_group_list[y].org_set_type_disp > " "))
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_set=28881
         AND cv.display_key=cnvtupper(cnvtalphanum(request->person_list[x].org_group_list[y].
          org_set_type_disp)))
       ORDER BY cv.code_value
       HEAD cv.code_value
        org_set_type_cd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET org_set_type_cd = 0.0
      ENDIF
     ELSE
      SET org_set_type_cd = 0.0
     ENDIF
    ENDIF
   ELSE
    SET org_set_type_cd = request->person_list[x].org_group_list[y].org_set_type_code_value
   ENDIF
   SET org_group_found = "N"
   SET org_set_id = 0.0
   SET org_set_name = fillstring(100," ")
   IF ((request->person_list[x].org_group_list[y].org_set_id=0))
    IF ((request->person_list[x].org_group_list[y].org_set_name > " "))
     SELECT INTO "nl:"
      FROM org_set o
      PLAN (o
       WHERE cnvtupper(o.name)=cnvtupper(request->person_list[x].org_group_list[y].org_set_name))
      ORDER BY o.org_set_id
      HEAD o.org_set_id
       org_set_id = o.org_set_id, org_set_name = o.name
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET org_set_found = "N"
     ELSE
      SET org_set_found = "Y"
     ENDIF
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>",
      "Error adding org group for prsnl- no org group specified for prsnl: ",request->person_list[x].
      name_first," ",
      request->person_list[x].name_last)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM org_set o
     PLAN (o
      WHERE (o.org_set_id=request->person_list[x].org_group_list[y].org_set_id))
     ORDER BY o.org_set_id
     HEAD o.org_set_id
      org_set_id = o.org_set_id, org_set_name = o.name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET org_set_found = "N"
    ELSE
     SET org_set_found = "Y"
    ENDIF
   ENDIF
   SET org_group_reltn_id = 0.0
   IF (org_set_id > 0
    AND org_set_type_cd > 0)
    SELECT INTO "nl:"
     FROM org_set_prsnl_r ospr
     PLAN (ospr
      WHERE ospr.prsnl_id=person_id
       AND ospr.org_set_id=org_set_id
       AND ospr.active_ind=0)
     DETAIL
      osprid = ospr.org_set_prsnl_r_id
     WITH nocounter
    ;end select
    IF (osprid=0.0)
     SELECT INTO "nl:"
      j = seq(organization_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       org_group_reltn_id = cnvtreal(j)
      WITH format, counter
     ;end select
     IF (org_group_reltn_id > 0)
      INSERT  FROM org_set_prsnl_r ospr
       SET ospr.org_set_prsnl_r_id = org_group_reltn_id, ospr.org_set_id = org_set_id, ospr.prsnl_id
         = person_id,
        ospr.org_set_type_cd = org_set_type_cd, ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = 0,
        ospr.updt_applctx = reqinfo->updt_applctx, ospr.updt_task = reqinfo->updt_task, ospr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ospr.active_ind = 1, ospr.active_status_cd = active_cd, ospr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        ospr.active_status_prsnl_id = reqinfo->updt_id, ospr.beg_effective_dt_tm = cnvtdatetime(
         curdate,curtime3), ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "T"
       SET error_msg = concat(error_msg,">>","Error adding org group for prsnl: ",request->
        person_list[x].name_first," ",
        request->person_list[x].name_last," Org Group: ",org_set_name)
      ENDIF
     ELSE
      SET error_flag = "T"
      SET error_msg = concat(error_msg,">>",
       "Error adding org group for prsnl - unable to generate id: ",request->person_list[x].
       name_first," ",
       request->person_list[x].name_last," Org Group: ",org_set_name)
     ENDIF
    ELSE
     UPDATE  FROM org_set_prsnl_r ospr
      SET ospr.updt_id = reqinfo->updt_id, ospr.updt_cnt = (ospr.updt_cnt+ 1), ospr.updt_applctx =
       reqinfo->updt_applctx,
       ospr.updt_task = reqinfo->updt_task, ospr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ospr
       .active_ind = 1,
       ospr.active_status_cd = active_cd, ospr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       ospr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WHERE ospr.org_set_prsnl_r_id=osprid
      WITH nocounter
     ;end update
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>",
     "Error: Org group or org set type code not found for prsnl: ",request->person_list[x].name_first,
     " ",
     request->person_list[x].name_last," Org Group: ",request->person_list[x].org_group_list[y].
     org_set_name,".")
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE chg_org_group(x,y)
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Error: No data is changable for org groups: ",request->
    person_list[x].name_first," ",
    request->person_list[x].name_last," Org Group: ",request->person_list[x].org_group_list[y].
    org_set_name,".")
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE del_org_group(x,y)
  IF ((request->person_list[x].org_group_list[y].org_set_prsnl_r_id > 0))
   UPDATE  FROM org_set_prsnl_r ospr
    SET ospr.active_ind = 0, ospr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ospr.updt_cnt
      = (ospr.updt_cnt+ 1),
     ospr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (ospr.org_set_prsnl_r_id=request->person_list[x].org_group_list[y].org_set_prsnl_r_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error inactivating org group reltn for prsnl: ",request->
     person_list[x].name_first," ",
     request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_group_list[y].
      org_set_id),".")
   ELSE
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "Successfully inactivated org group relationship for prsnl: ",request->person_list[x].name_first,
     " ",
     request->person_list[x].name_last," Org: ",cnvtstring(request->person_list[x].org_group_list[y].
      org_set_id),".")
   ENDIF
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>",
    "Error: org_set_prsnl_r_id required to remove relationship: ",request->person_list[x].name_first,
    " ",
    request->person_list[x].name_last," Org: ",request->person_list[x].org_group_list[y].org_set_id,
    ".")
  ENDIF
  RETURN(1.0)
 END ;Subroutine
 SUBROUTINE get_position(xx)
  SET s_position_code = 0.0
  FOR (i = 1 TO posncnt)
    IF (cnvtupper(cnvtalphanum(s_position_disp))=cnvtupper(cnvtalphanum(position->position_list[i].
      disp)))
     SET s_position_code = position->position_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_sex_code(xx)
  SET s_sex_code = 0.0
  FOR (i = 1 TO sexcnt)
    IF (cnvtupper(s_sex_mean)=cnvtupper(sex->sex_list[i].mean))
     SET s_sex_code = sex->sex_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_alias_type(xx)
  SET s_alias_type_code = 0.0
  FOR (i = 1 TO altypecnt)
    IF (cnvtupper(s_alias_type_mean)=cnvtupper(alias_type->alias_type_list[i].mean))
     SET s_alias_type_code = alias_type->alias_type_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_alias_pool(xx)
  SET s_alias_pool_code = 0.0
  FOR (i = 1 TO alpocnt)
    IF (cnvtupper(cnvtalphanum(s_alias_pool_disp))=cnvtupper(cnvtalphanum(alias_pool->
      alias_pool_list[i].disp)))
     SET s_alias_pool_code = alias_pool->alias_pool_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_address_type(xx)
  SET s_address_type_code = 0.0
  FOR (i = 1 TO adtypecnt)
    IF (cnvtupper(s_address_type_mean)=cnvtupper(address_type->address_type_list[i].mean))
     SET s_address_type_code = address_type->address_type_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_state(xx)
  SET s_state_code = 0.0
  FOR (i = 1 TO statecnt)
    IF (cnvtupper(cnvtalphanum(s_state_disp))=cnvtupper(cnvtalphanum(state->state_list[i].disp)))
     SET s_state_code = state->state_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_country(xx)
  SET s_country_code = 0.0
  FOR (i = 1 TO countrycnt)
    IF (cnvtupper(cnvtalphanum(s_country_disp))=cnvtupper(cnvtalphanum(country->country_list[i].disp)
     ))
     SET s_country_code = country->country_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_county(xx)
  SET s_county_code = 0.0
  FOR (i = 1 TO countycnt)
    IF (cnvtupper(cnvtalphanum(s_county_disp))=cnvtupper(cnvtalphanum(county->county_list[i].disp)))
     SET s_county_code = county->county_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_phone_type(xx)
  SET s_phone_type_code = 0.0
  FOR (i = 1 TO phtypecnt)
    IF (cnvtupper(s_phone_type_mean)=cnvtupper(phone_type->phone_type_list[i].mean))
     SET s_phone_type_code = phone_type->phone_type_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_phone_format(xx)
  SET s_phone_format_code = 0.0
  FOR (i = 1 TO phformatcnt)
    IF (cnvtupper(s_phone_format_mean)=cnvtupper(phone_format->phone_format_list[i].mean))
     SET s_phone_format_code = phone_format->phone_format_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_confid_level(xx)
  SET s_confid_level_code = 0.0
  FOR (i = 1 TO confidcnt)
    IF (cnvtupper(s_confid_level_mean)=cnvtupper(confid_level->confid_level_list[i].mean))
     SET s_confid_level_code = confid_level->confid_level_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_org_set_type(xx)
  SET s_org_set_type_code = 0.0
  FOR (i = 1 TO ostypecnt)
    IF (cnvtupper(s_org_set_type_mean)=cnvtupper(org_set_type->org_set_type_list[i].mean)
     AND cnvtupper(cnvtalphanum(s_org_set_type_disp))=cnvtupper(cnvtalphanum(org_set_type->
      org_set_type_list[i].disp)))
     SET s_org_set_type_code = org_set_type->org_set_type_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_task_activity(xx)
  SET s_task_activity_code = 0.0
  FOR (i = 1 TO taskactcnt)
    IF (cnvtupper(s_task_activity_mean)=cnvtupper(task_activity->task_activity_list[i].mean))
     SET s_task_activity_code = task_activity->task_activity_list[i].code
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_org(xx)
  SET s_org_id = 0.0
  FOR (i = 1 TO s_orgcnt)
    IF (cnvtupper(cnvtalphanum(s_org_name))=cnvtupper(cnvtalphanum(org->org_list[i].name)))
     SET s_org_id = org->org_list[i].id
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_org_set(xx)
  SET s_org_set_id = 0.0
  FOR (i = 1 TO s_oscnt)
    IF (cnvtupper(cnvtalphanum(s_org_set_name))=cnvtupper(cnvtalphanum(org_set->org_set_list[i].name)
     ))
     SET s_org_set_id = org_set->org_set_list[i].id
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE ens_prsnl_comments(x)
   FREE SET old_comments
   RECORD old_comments(
     1 comment_list[*]
       2 comment = vc
       2 type_code_value = f8
       2 prsnl_comment_id = f8
       2 long_text_id = f8
   )
   SELECT INTO "nl:"
    FROM code_value cv,
     prsnl_comment pc,
     long_text_reference ltr
    PLAN (cv
     WHERE cv.code_set=4300005.00
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curr_dt_tm)
      AND cv.end_effective_dt_tm > cnvtdatetime(curr_dt_tm))
     JOIN (pc
     WHERE pc.prsnl_id=outerjoin(person_id)
      AND pc.comment_type_cd=outerjoin(cv.code_value))
     JOIN (ltr
     WHERE ltr.long_text_id=outerjoin(pc.comment_long_text_id))
    HEAD REPORT
     prsnl_comment_count = 0
    HEAD cv.code_value
     prsnl_comment_count = (prsnl_comment_count+ 1), stat = alterlist(old_comments->comment_list,
      prsnl_comment_count)
     IF (ltr.long_text_id != 0.0)
      old_comments->comment_list[prsnl_comment_count].comment = ltr.long_text
     ENDIF
     old_comments->comment_list[prsnl_comment_count].type_code_value = cv.code_value, old_comments->
     comment_list[prsnl_comment_count].long_text_id = ltr.long_text_id, old_comments->comment_list[
     prsnl_comment_count].prsnl_comment_id = pc.prsnl_comment_id
    WITH nocounter
   ;end select
   SET request_comment_count = size(request->person_list[x].comment_list,5)
   SET old_comment_count = size(old_comments->comment_list,5)
   SET stat = alterlist(new_comments->comment_list,request_comment_count)
   DECLARE request_comment_index = i4 WITH protect, noconstant(0)
   DECLARE old_comment_index = i4 WITH protect, noconstant(0)
   FOR (request_comment_index = 1 TO request_comment_count)
     FOR (old_comment_index = 1 TO old_comment_count)
       IF ((request->person_list[x].comment_list[request_comment_index].type_code_value=old_comments
       ->comment_list[old_comment_index].type_code_value))
        IF ((old_comments->comment_list[old_comment_index].comment="")
         AND (request->person_list[x].comment_list[request_comment_index].comment != ""))
         SET new_comments->comment_list[request_comment_index].comment = request->person_list[x].
         comment_list[request_comment_index].comment
         SET new_comments->comment_list[request_comment_index].type_code_value = request->
         person_list[x].comment_list[request_comment_index].type_code_value
         SET new_comments->comment_list[request_comment_index].action_flag = 1
        ELSEIF ((old_comments->comment_list[old_comment_index].comment != "")
         AND (request->person_list[x].comment_list[request_comment_index].comment=""))
         SET new_comments->comment_list[request_comment_index].prsnl_comment_id = old_comments->
         comment_list[old_comment_index].prsnl_comment_id
         SET new_comments->comment_list[request_comment_index].long_text_id = old_comments->
         comment_list[old_comment_index].long_text_id
         SET new_comments->comment_list[request_comment_index].action_flag = 3
        ELSEIF ((request->person_list[x].comment_list[request_comment_index].comment != old_comments
        ->comment_list[old_comment_index].comment))
         SET new_comments->comment_list[request_comment_index].comment = request->person_list[x].
         comment_list[request_comment_index].comment
         SET new_comments->comment_list[request_comment_index].prsnl_comment_id = old_comments->
         comment_list[old_comment_index].prsnl_comment_id
         SET new_comments->comment_list[request_comment_index].long_text_id = old_comments->
         comment_list[old_comment_index].long_text_id
         SET new_comments->comment_list[request_comment_index].action_flag = 2
        ELSE
         SET new_comments->comment_list[request_comment_index].comment = request->person_list[x].
         comment_list[request_comment_index].comment
         SET new_comments->comment_list[request_comment_index].prsnl_comment_id = old_comments->
         comment_list[old_comment_index].prsnl_comment_id
         SET new_comments->comment_list[request_comment_index].long_text_id = old_comments->
         comment_list[old_comment_index].long_text_id
         SET new_comments->comment_list[request_comment_index].action_flag = 0
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_comment(x,new_comment_index)
   SELECT INTO "nl:"
    yyy = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     new_comments->comment_list[new_comment_index].prsnl_comment_id = cnvtreal(yyy)
    WITH format, counter
   ;end select
   SELECT INTO "nl:"
    zzz = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_comments->comment_list[new_comment_index].long_text_id = cnvtreal(zzz)
    WITH format, counter
   ;end select
   INSERT  FROM long_text_reference ltr
    SET ltr.long_text_id = new_comments->comment_list[new_comment_index].long_text_id, ltr
     .parent_entity_id = new_comments->comment_list[new_comment_index].prsnl_comment_id, ltr
     .parent_entity_name = "PRSNL_COMMENT",
     ltr.long_text = new_comments->comment_list[new_comment_index].comment, ltr.active_ind = 1, ltr
     .active_status_cd = act_status_cd,
     ltr.active_status_dt_tm = cnvtdatetime(curr_dt_tm), ltr.active_status_prsnl_id = reqinfo->
     updt_id, ltr.updt_applctx = reqinfo->updt_applctx,
     ltr.updt_cnt = 0, ltr.updt_dt_tm = cnvtdatetime(curr_dt_tm), ltr.updt_id = reqinfo->updt_id,
     ltr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
     "New LONG_TEXT_REFERENCE row written for: ",trim(request->person_list[x].name_first)," ",
     trim(request->person_list[x].name_last))
    INSERT  FROM prsnl_comment pc
     SET pc.prsnl_comment_id = new_comments->comment_list[new_comment_index].prsnl_comment_id, pc
      .comment_long_text_id = new_comments->comment_list[new_comment_index].long_text_id, pc
      .comment_type_cd = new_comments->comment_list[new_comment_index].type_code_value,
      pc.prsnl_id = person_id, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0,
      pc.updt_dt_tm = cnvtdatetime(curr_dt_tm), pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo
      ->updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "New PRSNL_COMMENT row written for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error writing new PRSNL_COMMENT row for: ",trim(request->
       person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
   ELSE
    SET error_flag = "T"
    SET error_msg = concat(error_msg,">>","Error writing new LONG_TEXT_REFERENCE row for: ",trim(
      request->person_list[x].name_first)," ",
     trim(request->person_list[x].name_last))
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_comment(x,new_comment_index)
  IF ((new_comments->comment_list[new_comment_index].long_text_id > 0.0))
   UPDATE  FROM long_text_reference ltr
    SET ltr.long_text = new_comments->comment_list[new_comment_index].comment, ltr.updt_applctx =
     reqinfo->updt_applctx, ltr.updt_cnt = (ltr.updt_cnt+ 1),
     ltr.updt_dt_tm = cnvtdatetime(curr_dt_tm), ltr.updt_id = reqinfo->updt_id, ltr.updt_task =
     reqinfo->updt_task
    WHERE (ltr.long_text_id=new_comments->comment_list[new_comment_index].long_text_id)
    WITH nocounter
   ;end update
  ENDIF
  IF (curqual > 0)
   SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
    "PRSNL_COMMENT row updated for: ",trim(request->person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Error updating PRSNL_COMMENT row for: ",trim(request->
     person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ENDIF
 END ;Subroutine
 SUBROUTINE del_comment(x,new_comment_index)
   IF ((new_comments->comment_list[new_comment_index].prsnl_comment_id > 0.0)
    AND (new_comments->comment_list[new_comment_index].long_text_id > 0.0))
    DELETE  FROM prsnl_comment pc
     WHERE (pc.prsnl_comment_id=new_comments->comment_list[new_comment_index].prsnl_comment_id)
     WITH nocounter
    ;end delete
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "PRSNL_COMMENT row deleted for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error deleting PRSNL_COMMENT row for: ",trim(request->
       person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
    DELETE  FROM long_text_reference ltr
     WHERE (ltr.long_text_id=new_comments->comment_list[new_comment_index].long_text_id)
     WITH nocounter
    ;end delete
    IF (curqual > 0)
     SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
      "LONG_TEXT_REFERENCE row deleted for: ",trim(request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ELSE
     SET error_flag = "T"
     SET error_msg = concat(error_msg,">>","Error deleting LONG_TEXT_REFERENCE row for: ",trim(
       request->person_list[x].name_first)," ",
      trim(request->person_list[x].name_last))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_result_delivery_method(x,result_delivery_method_index)
  INSERT  FROM prsnl_code_value_r pcvr
   SET pcvr.prsnl_code_value_r_id = seq(reference_seq,nextval), pcvr.prsnl_id = person_id, pcvr
    .code_set = 4348005,
    pcvr.code_value = request->person_list[x].result_delivery_method_list[
    result_delivery_method_index].type_code_value, pcvr.updt_applctx = reqinfo->updt_applctx, pcvr
    .updt_cnt = 0,
    pcvr.updt_dt_tm = cnvtdatetime(curr_dt_tm), pcvr.updt_id = reqinfo->updt_id, pcvr.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual > 0)
   SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
    "New PRSNL_CODE_VALUE_R row written for: ",trim(request->person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Error writing new PRSNL_CODE_VALUE_R row for: ",trim(
     request->person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ENDIF
 END ;Subroutine
 SUBROUTINE del_result_delivery_method(x,result_delivery_method_index)
  DELETE  FROM prsnl_code_value_r pcvr
   WHERE pcvr.prsnl_id=person_id
    AND (pcvr.code_value=request->person_list[x].result_delivery_method_list[
   result_delivery_method_index].type_code_value)
    AND pcvr.code_set=4348005
   WITH nocounter
  ;end delete
  IF (curqual > 0)
   SET reply->person_list[x].status_msg = concat(reply->person_list[x].status_msg,">>",
    "PRSNL_CODE_VALUE_R row deleted for: ",trim(request->person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ELSE
   SET error_flag = "T"
   SET error_msg = concat(error_msg,">>","Error deleting PRSNL_CODE_VALUE_R row for: ",trim(request->
     person_list[x].name_first)," ",
    trim(request->person_list[x].name_last))
  ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM_NAME:  BED_ENS_PRSNL   >> ERROR MESSAGE: ",error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "ENS"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BED_ENS_PRSNL"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->audit_mode_ind=1))
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
