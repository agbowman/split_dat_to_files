CREATE PROGRAM bed_ens_rln_alias:dba
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
 DECLARE lab_source_cd = f8 WITH protect
 DECLARE glab_result_type_bill_cd = f8 WITH protect
 DECLARE ut_auth_cd = f8 WITH protect
 DECLARE cntr = i4 WITH protect
 DECLARE x = i4 WITH protect
 DECLARE i_event_cd_disp_key = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE msg = vc WITH protect
 DECLARE event_code_exists = i4 WITH protect
 DECLARE code_value_cnt = i4 WITH protect
 DECLARE i_def_docmnt_format_cd = f8 WITH protect
 DECLARE i_def_docmnt_storage_cd = f8 WITH protect
 DECLARE i_def_event_class_cd = f8 WITH protect
 DECLARE i_def_event_confid_level_cd = f8 WITH protect
 DECLARE i_event_cd_subclass_cd = f8 WITH protect
 DECLARE i_code_status_cd = f8 WITH protect
 DECLARE i_event_code_status_cd = f8 WITH protect
 RECORD internal(
   1 int_rec[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
 )
 RECORD dm_post_event_code_request(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 DECLARE glbcreatedtaevtcdsfornewdta(mnemonic=vc) = i2
 DECLARE posteventcodefordta(dummyvar=i2) = i2
 DECLARE verifycurqual(table_name=vc,data_field=vc) = i2
 DECLARE setdmposteventrequest(event_set_name=vc,event_cd_disp=vc,event_cd_descr=vc,
  event_cd_definition=vc,parent_cd=vc) = null
 SUBROUTINE glbcreatedtaevtcdsfornewdta(mnemonic)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=73
     AND cv.display_key="LAB"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     lab_source_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=289
     AND cv.display_key="17"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     glab_result_type_bill_cd = cv.code_value
    WITH nocounter
   ;end select
   SET cntr = 0
   SET x = 0
   SELECT INTO "nl:"
    dta.mnemonic, dta.task_assay_cd
    FROM discrete_task_assay dta
    WHERE dta.mnemonic=mnemonic
     AND dta.activity_type_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=106
      AND cv.cdf_meaning="GLB"
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     WITH nocounter))
     AND dta.default_result_type_cd != glab_result_type_bill_cd
     AND dta.active_ind=1
    HEAD REPORT
     cntr = 0
    DETAIL
     cntr = (cntr+ 1), stat = alterlist(internal->int_rec,cntr), internal->int_rec[cntr].
     task_assay_cd = dta.task_assay_cd,
     internal->int_rec[cntr].mnemonic = dta.mnemonic
    WITH nocounter
   ;end select
   IF (cntr > 0)
    FOR (x = 1 TO cntr)
     CALL setdmposteventrequest(substring(1,40,internal->int_rec[x].mnemonic),substring(1,40,internal
       ->int_rec[x].mnemonic),substring(1,60,internal->int_rec[x].mnemonic),internal->int_rec[x].
      mnemonic,internal->int_rec[x].task_assay_cd)
     IF (posteventcodefordta(0))
      SET msg = concat("Successfully Added code value events for assay: ",trim(
        dm_post_event_code_request->event_cd_definition),"..")
      CALL bedlogmessage(msg,"")
     ELSE
      SET msg = concat("Failed to add code value/ events for assay: ",trim(dm_post_event_code_request
        ->event_cd_definition),"..")
      CALL bedlogmessage(msg,"")
      RETURN(false)
     ENDIF
    ENDFOR
    CALL setdmposteventrequest(fillstring(40," "),"LAB","LAB","LAB",lab_source_cd)
    IF (posteventcodefordta(0))
     SET msg = concat("Sccessfully Added code value/events for assay: ",trim(
       dm_post_event_code_request->event_cd_definition),"..")
     CALL bedlogmessage(msg,"")
    ELSE
     SET msg = concat("Failed to add code value/events  for assay: ",trim(dm_post_event_code_request
       ->event_cd_definition),"..")
     CALL bedlogmessage(msg,"")
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE posteventcodefordta(dummyvar)
   SET i_event_cd_disp_key = cnvtupper(cnvtalphanum(dm_post_event_code_request->event_cd_disp))
   SET cnt = 0
   SELECT INTO "nl:"
    y = count(*)
    FROM code_value_event_r dpec
    WHERE (dpec.parent_cd=dm_post_event_code_request->parent_cd)
     AND (dpec.flex1_cd=dm_post_event_code_request->flex1_cd)
     AND (dpec.flex2_cd=dm_post_event_code_request->flex2_cd)
     AND (dpec.flex3_cd=dm_post_event_code_request->flex3_cd)
     AND (dpec.flex4_cd=dm_post_event_code_request->flex4_cd)
     AND (dpec.flex5_cd=dm_post_event_code_request->flex5_cd)
    DETAIL
     cnt = y
    WITH nocounter
   ;end select
   SET dm_post_event_code_request->event_cd = 0
   IF (cnt=0)
    SET event_code_exists = 0
    SELECT INTO "nl:"
     vec.event_cd
     FROM v500_event_code vec
     WHERE vec.event_cd_disp_key=i_event_cd_disp_key
      AND (vec.event_cd_disp=dm_post_event_code_request->event_cd_disp)
     DETAIL
      dm_post_event_code_request->event_cd = vec.event_cd, event_code_exists = 1
     WITH nocounter
    ;end select
    SET code_value_cnt = 0
    IF (event_code_exists=1)
     SELECT INTO "nl:"
      y = count(*)
      FROM code_value cv
      WHERE (cv.code_value=dm_post_event_code_request->event_cd)
      DETAIL
       code_value_cnt = y
      WITH nocounter
     ;end select
    ENDIF
    IF (event_code_exists=0)
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       dm_post_event_code_request->event_cd = y
      WITH nocounter
     ;end select
     SET i_def_docmnt_format_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->format)
       AND cv.code_set=23
      DETAIL
       i_def_docmnt_format_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_docmnt_storage_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->storage)
       AND cv.code_set=25
      DETAIL
       i_def_docmnt_storage_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_event_class_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_class)
       AND cv.code_set=53
      DETAIL
       i_def_event_class_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_def_event_confid_level_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_confid_level)
       AND cv.code_set=87
      DETAIL
       i_def_event_confid_level_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_event_cd_subclass_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_subclass)
       AND cv.code_set=102
      DETAIL
       i_event_cd_subclass_cd = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    IF (((event_code_exists=0) OR (code_value_cnt=0)) )
     SET i_code_status_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->status)
       AND cv.code_set=48
      DETAIL
       i_code_status_cd = cv.code_value
      WITH nocounter
     ;end select
     SET i_event_code_status_cd = 0.0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE (cv.cdf_meaning=dm_post_event_code_request->event_code_status)
       AND cv.code_set=8
      DETAIL
       i_event_code_status_cd = cv.code_value
      WITH nocounter
     ;end select
     INSERT  FROM code_value cv
      (cv.display, cv.code_set, cv.display_key,
      cv.description, cv.definition, cv.collation_seq,
      cv.active_type_cd, cv.active_ind, cv.active_dt_tm,
      cv.updt_dt_tm, cv.updt_id, cv.updt_cnt,
      cv.updt_task, cv.updt_applctx, cv.begin_effective_dt_tm,
      cv.end_effective_dt_tm, cv.data_status_cd, cv.data_status_dt_tm,
      cv.data_status_prsnl_id, cv.active_status_prsnl_id, cv.code_value)
      VALUES(dm_post_event_code_request->event_cd_disp, 72, i_event_cd_disp_key,
      dm_post_event_code_request->event_cd_descr, dm_post_event_code_request->event_cd_definition, 1,
      i_code_status_cd, 1, cnvtdatetime(curdate,curtime3),
      cnvtdatetime(curdate,curtime3), 12087, 1,
      12087, 12087, cnvtdatetime(curdate,curtime3),
      cnvtdatetime("31-dec-2100"), i_event_code_status_cd, cnvtdatetime(curdate,curtime3),
      0, 0, dm_post_event_code_request->event_cd)
      WITH nocounter
     ;end insert
     IF (verifycurqual("code_value",trim(dm_post_event_code_request->event_cd_definition))=false)
      RETURN(false)
     ENDIF
     IF (event_code_exists=0)
      INSERT  FROM v500_event_code
       (event_cd, event_cd_definition, event_cd_descr,
       event_cd_disp, event_cd_disp_key, code_status_cd,
       def_docmnt_format_cd, def_docmnt_storage_cd, def_event_class_cd,
       def_event_confid_level_cd, event_add_access_ind, event_cd_subclass_cd,
       event_chg_access_ind, event_set_name, event_code_status_cd,
       updt_dt_tm, updt_applctx, updt_cnt,
       updt_id, updt_task)
       VALUES(dm_post_event_code_request->event_cd, dm_post_event_code_request->event_cd_definition,
       dm_post_event_code_request->event_cd_descr,
       dm_post_event_code_request->event_cd_disp, i_event_cd_disp_key, i_code_status_cd,
       i_def_docmnt_format_cd, i_def_docmnt_storage_cd, i_def_event_class_cd,
       i_def_event_confid_level_cd, 0, i_event_cd_subclass_cd,
       0, dm_post_event_code_request->event_set_name, i_event_code_status_cd,
       cnvtdatetime(curdate,curtime3), 12087, 1,
       12087, 12087)
       WITH nocounter
      ;end insert
      IF (verifycurqual("v500_event_code",trim(dm_post_event_code_request->event_cd_definition))=
      false)
       RETURN(false)
      ENDIF
     ENDIF
    ENDIF
    INSERT  FROM code_value_event_r
     (event_cd, parent_cd, flex1_cd,
     flex2_cd, flex3_cd, flex4_cd,
     flex5_cd, updt_dt_tm, updt_id,
     updt_cnt, updt_task, updt_applctx)
     VALUES(dm_post_event_code_request->event_cd, dm_post_event_code_request->parent_cd,
     dm_post_event_code_request->flex1_cd,
     dm_post_event_code_request->flex2_cd, dm_post_event_code_request->flex3_cd,
     dm_post_event_code_request->flex4_cd,
     dm_post_event_code_request->flex5_cd, cnvtdatetime(curdate,curtime3), 12087,
     1, 12087, 12087)
     WITH nocounter
    ;end insert
    IF (verifycurqual("code_value_event_r",trim(dm_post_event_code_request->event_cd_definition))=
    false)
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE verifycurqual(table_name,data_field)
   CALL bederrorcheck(concat("Failed to add new code to table:",table_name,""))
   IF (curqual=0)
    SET msg = concat("Failed to add code value/events for assay: ",data_field," to the table :",
     table_name)
    CALL bedlogmessage(msg,"")
    RETURN(false)
   ENDIF
   SET msg = concat("Added code values/events for assay: ",data_field," to the table :",table_name)
   CALL bedlogmessage(msg,"")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setdmposteventrequest(event_set_name,event_cd_disp,event_cd_descr,event_cd_definition,
  parent_cd)
   SET dm_post_event_code_request->event_set_name = event_set_name
   SET dm_post_event_code_request->event_cd_disp = event_cd_disp
   SET dm_post_event_code_request->event_cd_descr = event_cd_descr
   SET dm_post_event_code_request->event_cd_definition = event_cd_definition
   SET dm_post_event_code_request->status = "ACTIVE"
   SET dm_post_event_code_request->format = "UNKNOWN"
   SET dm_post_event_code_request->storage = "UNKNOWN"
   SET dm_post_event_code_request->event_class = "UNKNOWN"
   SET dm_post_event_code_request->event_confid_level = "ROUTCLINICAL"
   SET dm_post_event_code_request->event_subclass = "UNKNOWN"
   SET dm_post_event_code_request->event_code_status = "AUTH"
   SET dm_post_event_code_request->event_cd = 0.0
   SET dm_post_event_code_request->parent_cd = parent_cd
   SET dm_post_event_code_request->flex1_cd = 0.0
   SET dm_post_event_code_request->flex2_cd = 0.0
   SET dm_post_event_code_request->flex3_cd = 0.0
   SET dm_post_event_code_request->flex4_cd = 0.0
   SET dm_post_event_code_request->flex5_cd = 0.0
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE dta_display = vc WITH protect, noconstant("")
 DECLARE associated_event_code = vc
 DECLARE dup_dta_event_entry_found = vc
 DECLARE newlogmsg = vc
 SELECT INTO "nl:"
  FROM code_value a
  WHERE (a.code_set=request->code_set)
   AND (a.code_value=request->code_value)
  DETAIL
   dta_display = a.display
  WITH maxrec = 1
 ;end select
 SET associated_event_code = "N"
 SET dup_dta_event_entry_found = "N"
 DECLARE updateoutboundandalias(dummyvar=i2) = i2
 DECLARE verifyeventcodes(dummyvar=i2) = i2
 DECLARE savenewdtatoclinicalevents(assay_new_disp=vc) = i2
 CALL updateoutboundandalias(0)
 SUBROUTINE updateoutboundandalias(dummyvar)
   UPDATE  FROM code_value_outbound a
    SET a.alias = request->alias, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo
     ->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
     .updt_cnt+ 1)
    WHERE (a.code_set=request->code_set)
     AND (a.contributor_source_cd=request->contributor_source_cd)
     AND (a.code_value=request->code_value)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 001: Error updating in the code_value_outbound table.")
   UPDATE  FROM code_value_alias a
    SET a.alias = request->alias, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo
     ->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
     .updt_cnt+ 1)
    WHERE (a.code_set=request->code_set)
     AND (a.contributor_source_cd=request->contributor_source_cd)
     AND (a.code_value=request->code_value)
    WITH nocounter
   ;end update
   CALL bederrorcheck("ERROR 002: Error updating in the code_value_alias table.")
   CALL bedlogmessage("Exiting","updateOutboundAndAlias")
   CALL verifyeventcodes(0)
 END ;Subroutine
 SUBROUTINE verifyeventcodes(dummyvar)
   CALL bedlogmessage("verifying event codes","verifyEventCodes")
   SELECT INTO "nl:"
    FROM code_value_event_r cvr
    PLAN (cvr
     WHERE (cvr.parent_cd=request->code_value))
    DETAIL
     associated_event_code = "Y"
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM v500_event_code vec
    PLAN (vec
     WHERE vec.event_cd_disp=dta_display)
    DETAIL
     dup_dta_event_entry_found = "Y"
    WITH nocounter
   ;end select
   IF (dup_dta_event_entry_found="N"
    AND associated_event_code="N")
    CALL bedlogmessage("calling","saveNewDTAToClinicalEvents")
    CALL savenewdtatoclinicalevents(dta_display)
   ENDIF
 END ;Subroutine
 SUBROUTINE savenewdtatoclinicalevents(assay_new_disp)
  SET newlogmsg = ""
  IF (glbcreatedtaevtcdsfornewdta(assay_new_disp))
   SET newlogmsg = concat("The DTA is qualified to add it to the clinical Events Table",
    assay_new_disp,"")
   CALL bedlogmessage(newlogmsg,"")
  ELSE
   SET newlogmsg = concat("The DTA is not qualified to add it to the clinical Events Table",
    assay_new_disp,"")
   CALL bedlogmessage(newlogmsg,"")
  ENDIF
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
