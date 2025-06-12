CREATE PROGRAM bed_del_vb_views:dba
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
 FREE RECORD psat_reply
 RECORD psat_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(cmn_mie_del_import_info_reply)))
  RECORD cmn_mie_del_import_info_reply(
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
 DECLARE req_size = i4 WITH protect, constant(size(request->views,5))
 DECLARE viewpointcnt = i4 WITH protect, noconstant(0)
 DECLARE delreports(null) = i2
 DECLARE delorphaneddata(null) = i2
 DECLARE deltext(null) = i2
 DECLARE delvaluesetmeasdet(null) = i2
 DECLARE delvaluesetmeas(null) = i2
 DECLARE delvaluesets(null) = i2
 DECLARE delviewpointsreltn(null) = i2
 DECLARE delmappingtypes(null) = i2
 DECLARE delsmarttemplate(null) = i2
 DECLARE delimportactivity(null) = i2
 DECLARE delcategory(null) = i2
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 CALL delreports(null)
 CALL delimportactivity(null)
 CALL delorphaneddata(null)
 CALL deltext(null)
 CALL delvaluesetmeasdet(null)
 CALL delvaluesetmeas(null)
 CALL delvaluesets(null)
 CALL delviewpointsreltn(null)
 CALL delmappingtypes(null)
 CALL delsmarttemplate(null)
 CALL delcategory(null)
 SUBROUTINE delreports(null)
   CALL bedlogmessage("delReports","Entering ...")
   RECORD delreportrequest(
     1 views[*]
       2 br_datamart_category_id = f8
   )
   SET stat = moverec(request,delreportrequest)
   EXECUTE bed_del_dmart_reports_by_cat  WITH replace("REQUEST",delreportrequest)
   CALL bedlogmessage("delReports","Exiting ...")
 END ;Subroutine
 SUBROUTINE delorphaneddata(null)
   CALL bedlogmessage("delOrphanedData","Entering ...")
   DELETE  FROM br_datamart_value b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_value table")
   DELETE  FROM br_datamart_default b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE b.br_datamart_filter_id IN (
     (SELECT
      br_datamart_filter_id
      FROM br_datamart_filter
      WHERE (br_datamart_category_id=request->views[d.seq].br_datamart_category_id))))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_default table")
   DELETE  FROM br_datamart_text b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_text table")
   DELETE  FROM br_datamart_filter b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_filter table")
   CALL bedlogmessage("delOrphanedData","Exiting ...")
 END ;Subroutine
 SUBROUTINE deltext(null)
   CALL bedlogmessage("delText","Entering ...")
   DELETE  FROM br_datamart_text b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_text table")
   CALL bedlogmessage("delText","Exiting ...")
 END ;Subroutine
 SUBROUTINE delvaluesetmeasdet(null)
   CALL bedlogmessage("delValueSetMeasDet","Entering ...")
   DELETE  FROM br_datam_val_set_item_meas b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE b.br_datam_val_set_item_id IN (
     (SELECT
      br_datam_val_set_item_id
      FROM br_datam_val_set_item
      WHERE br_datam_val_set_id IN (
      (SELECT
       br_datam_val_set_id
       FROM br_datam_val_set
       WHERE (br_datamart_category_id=request->views[d.seq].br_datamart_category_id))))))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datam_val_set_item_meas table")
   CALL bedlogmessage("delValueSetMeasDet","Exiting ...")
 END ;Subroutine
 SUBROUTINE delvaluesetmeas(null)
   CALL bedlogmessage("delValueSetMeas","Entering ...")
   DELETE  FROM br_datam_val_set_item b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE b.br_datam_val_set_id IN (
     (SELECT
      br_datam_val_set_id
      FROM br_datam_val_set
      WHERE (br_datamart_category_id=request->views[d.seq].br_datamart_category_id))))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datam_val_set_item table")
   CALL bedlogmessage("delValueSetMeas","Exiting ...")
 END ;Subroutine
 SUBROUTINE delvaluesets(null)
   CALL bedlogmessage("delValueSets","Entering ...")
   DELETE  FROM br_datam_val_set b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datam_val_set table")
   CALL bedlogmessage("delValueSets","Exiting ...")
 END ;Subroutine
 SUBROUTINE delviewpointsreltn(null)
   CALL bedlogmessage("delViewPointsReltn","Entering ...")
   RECORD delviewpoints(
     1 viewpoints[*]
       2 reltn_id = f8
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(req_size)),
     mp_viewpoint_reltn b
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    ORDER BY b.mp_viewpoint_reltn_id
    HEAD b.mp_viewpoint_reltn_id
     viewpointcnt = (viewpointcnt+ 1), stat = alterlist(delviewpoints->viewpoints,viewpointcnt),
     delviewpoints->viewpoints[viewpointcnt].reltn_id = b.mp_viewpoint_reltn_id
    WITH nocounter
   ;end select
   DECLARE viewsinviewpointcnt = i4 WITH protect, noconstant(0)
   DECLARE viewpoint_id = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO viewpointcnt)
     DECLARE mp_viewpoint_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      FROM mp_viewpoint_reltn mpvr,
       mp_viewpoint mpv
      WHERE (mpvr.mp_viewpoint_reltn_id=delviewpoints->viewpoints[x].reltn_id)
       AND mpv.mp_viewpoint_id=mpvr.mp_viewpoint_id
      DETAIL
       mp_viewpoint_id = mpv.mp_viewpoint_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM mp_viewpoint_reltn mpvr
      WHERE mpvr.mp_viewpoint_id=mp_viewpoint_id
      HEAD REPORT
       viewsinviewpointcnt = 0
      DETAIL
       viewsinviewpointcnt = (viewsinviewpointcnt+ 1), viewpoint_id = mpvr.mp_viewpoint_id
      WITH nocounter
     ;end select
     IF (viewsinviewpointcnt=1)
      UPDATE  FROM mp_viewpoint mpv
       SET mpv.active_ind = 0
       WHERE mpv.mp_viewpoint_id=mp_viewpoint_id
      ;end update
      CALL bederrorcheck("Error updating mp_viewpoint table")
     ENDIF
   ENDFOR
   IF (viewpointcnt > 0)
    DELETE  FROM mp_viewpoint_encntr b,
      (dummyt d  WITH seq = value(viewpointcnt))
     SET b.seq = 1
     PLAN (d)
      JOIN (b
      WHERE (b.mp_viewpoint_reltn_id=delviewpoints->viewpoints[d.seq].reltn_id))
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Error deleting from mp_viewpoint_encntr table")
   ENDIF
   DELETE  FROM mp_viewpoint_reltn b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from mp_viewpoint_reltn table")
   CALL bedlogmessage("delViewPointsReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE delmappingtypes(null)
   CALL bedlogmessage("delMappingTypes","Entering ...")
   DELETE  FROM br_datam_mapping_type b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datam_mapping_type table")
   CALL bedlogmessage("delMappingTypes","Exiting ...")
 END ;Subroutine
 SUBROUTINE delcategory(null)
   CALL bedlogmessage("delCategory","Entering ...")
   DELETE  FROM br_datamart_category b,
     (dummyt d  WITH seq = value(req_size))
    SET b.seq = 1
    PLAN (d)
     JOIN (b
     WHERE (b.br_datamart_category_id=request->views[d.seq].br_datamart_category_id))
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error deleting from br_datamart_category table")
   CALL bedlogmessage("delCategory","Exiting ...")
 END ;Subroutine
 SUBROUTINE delsmarttemplate(null)
   CALL bedlogmessage("delSmartTemplate","Entering ...")
   SET stat = tdbexecute(3202004,3202004,4410016,"REC",request,
    "REC",psat_reply)
   IF (stat != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Delete"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "pex_stw_autodelete_template"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "tdbexecute failed for pex_stw_autodelete_template"
    CALL bederror(reply->status_data.subeventstatus[1].targetobjectvalue)
   ENDIF
   CALL bederrorcheck("Error executing tdb for pex_stw_autodelete_template")
   CALL bedlogmessage("delSmartTemplate","Exiting ...")
 END ;Subroutine
 SUBROUTINE delimportactivity(null)
   CALL bedlogmessage("delImportActivity","Entering ...")
   DECLARE failure_message = vc WITH protect, noconstant("")
   IF (checkprg("CMN_MIE_DEL_IMPORT_INFO") > 0)
    EXECUTE cmn_mie_del_import_info  WITH replace("CMN_MIE_DEL_IMPORT_INFO_REQUEST",request)
    IF ((cmn_mie_del_import_info_reply->status_data.status="F"))
     SET failure_message = build("Service call to CMN_MIE_DEL_IMPORT_INFO did not return Success.",
      cmn_mie_del_import_info_reply->status_data.subeventstatus[1].targetobjectvalue)
     IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
      CALL echo(failure_message)
      CALL echorecord(cmn_mie_del_import_info_reply)
     ENDIF
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Delete"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cmn_mie_del_import_info"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = failure_message
     CALL bederror(failure_message)
    ENDIF
   ELSE
    IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
     CALL echo("Service cmn_mie_del_import_info does not exist in object library")
    ENDIF
   ENDIF
   CALL bederrorcheck(failure_message)
   CALL bedlogmessage("delImportActivity","Exiting ...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
