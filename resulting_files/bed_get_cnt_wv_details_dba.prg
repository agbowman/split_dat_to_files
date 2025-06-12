CREATE PROGRAM bed_get_cnt_wv_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 working_view_sections[*]
      2 cnt_wv_section_key_id = f8
      2 dcp_wv_section_ref_id = f8
      2 default_open_pref_flag = i2
      2 display_name = vc
      2 display_name_status = vc
      2 event_set_name = vc
      2 included_ind = i2
      2 included_status = vc
      2 required_ind = i2
      2 required_status = vc
      2 section_type_flag = i2
      2 wv_section_uid = vc
      2 section_status = vc
      2 working_view_items[*]
        3 cnt_wv_item_key_id = f8
        3 dcp_wv_item_ref_id = f8
        3 falloff_view_minutes = i4
        3 included_ind = i2
        3 included_ind_status = vc
        3 parent_event_set_name = vc
        3 primitive_event_set_name = vc
        3 prim_event_set_name_status = vc
        3 task_assay_guid = vc
        3 wv_item_uid = vc
        3 item_status = vc
        3 disp_assoc_dtas[*]
          4 task_assay_uid = vc
          4 mnemonic = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD existingdetails
 RECORD existingdetails(
   1 working_view_sections[*]
     2 working_view_section_id = f8
     2 display_name = vc
     2 event_set_name = vc
     2 included_ind = i2
     2 required_ind = i2
     2 section_type_flag = i2
     2 working_view_items[*]
       3 working_view_item_id = f8
       3 falloff_view_minutes = i4
       3 included_ind = i2
       3 parent_event_set_name = vc
       3 primitive_event_set_name = vc
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
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 DECLARE sectioncnt = i4 WITH protect, noconstant(0)
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE dacnt = i4 WITH protect, noconstant(0)
 DECLARE dcp_id = f8 WITH protect, noconstant(0.0)
 DECLARE getcurrentdcpworkingviewid(dummyvar=i2) = f8
 DECLARE loadcontentdetails(dummyvar=i2) = i2
 DECLARE loadexistingdetails(dummyvar=i2) = i2
 DECLARE comparedetails(dummyvar=i2) = i2
 SET dcp_id = getcurrentdcpworkingviewid(null)
 CALL loadcontentdetails(null)
 IF (dcp_id > 0
  AND (request->compare_ind=1))
  CALL loadexistingdetails(null)
 ENDIF
 IF ((request->compare_ind=1))
  CALL comparedetails(null)
 ENDIF
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getcurrentdcpworkingviewid(dummyvar)
   DECLARE cnt_dcp_id = f8 WITH protect, noconstant(0.0)
   DECLARE match_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM cnt_wv_key c
    PLAN (c
     WHERE (c.working_view_uid=request->working_view_uid)
      AND c.active_ind=1)
    DETAIL
     cnt_dcp_id = c.dcp_wv_ref_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not retrieve dcp id")
   IF (cnt_dcp_id > 0)
    SELECT INTO "nl:"
     FROM working_view wv
     PLAN (wv
      WHERE wv.working_view_id=cnt_dcp_id)
     DETAIL
      IF (wv.current_working_view=0)
       match_id = wv.working_view_id
      ELSE
       match_id = wv.current_working_view
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not retrieve version")
   ELSE
    SELECT INTO "nl:"
     FROM cnt_wv_key w,
      working_view wv
     PLAN (w
      WHERE (w.working_view_uid=request->working_view_uid)
       AND w.active_ind=1)
      JOIN (wv
      WHERE cnvtupper(wv.display_name)=cnvtupper(w.display_name)
       AND wv.current_working_view=0)
     DETAIL
      match_id = wv.working_view_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not retrieve name match")
   ENDIF
   RETURN(match_id)
 END ;Subroutine
 SUBROUTINE loadcontentdetails(dummyvar)
  SELECT INTO "nl:"
   FROM cnt_wv_section_r r,
    cnt_wv_section_key cs,
    cnt_wv_section_item_r ir,
    cnt_wv_item_key i,
    cnt_wv_item_dta idr,
    cnt_dta dta
   PLAN (r
    WHERE (r.working_view_uid=request->working_view_uid))
    JOIN (cs
    WHERE cs.wv_section_uid=r.wv_section_uid)
    JOIN (ir
    WHERE ir.wv_section_uid=outerjoin(cs.wv_section_uid))
    JOIN (i
    WHERE i.wv_item_uid=outerjoin(ir.wv_item_uid))
    JOIN (idr
    WHERE idr.wv_item_uid=outerjoin(i.wv_item_uid))
    JOIN (dta
    WHERE dta.task_assay_uid=outerjoin(idr.task_assay_uid))
   ORDER BY cs.cnt_wv_section_key_id, i.cnt_wv_item_key_id, dta.task_assay_uid
   HEAD cs.cnt_wv_section_key_id
    itemcnt = 0, sectioncnt = (sectioncnt+ 1), stat = alterlist(reply->working_view_sections,
     sectioncnt),
    reply->working_view_sections[sectioncnt].display_name_status = none, reply->
    working_view_sections[sectioncnt].included_status = none, reply->working_view_sections[sectioncnt
    ].required_status = none,
    reply->working_view_sections[sectioncnt].section_status = none, reply->working_view_sections[
    sectioncnt].cnt_wv_section_key_id = cs.cnt_wv_section_key_id, reply->working_view_sections[
    sectioncnt].dcp_wv_section_ref_id = cs.dcp_wv_section_ref_id,
    reply->working_view_sections[sectioncnt].default_open_pref_flag = cs.default_open_pref_flag,
    reply->working_view_sections[sectioncnt].display_name = cs.display_name, reply->
    working_view_sections[sectioncnt].event_set_name = cs.event_set_name,
    reply->working_view_sections[sectioncnt].included_ind = cs.included_ind, reply->
    working_view_sections[sectioncnt].required_ind = cs.required_ind, reply->working_view_sections[
    sectioncnt].section_type_flag = cs.section_type_flag,
    reply->working_view_sections[sectioncnt].wv_section_uid = cs.wv_section_uid
    IF (((dcp_id=0) OR ((request->compare_ind=0))) )
     reply->working_view_sections[sectioncnt].display_name_status = added, reply->
     working_view_sections[sectioncnt].included_status = added, reply->working_view_sections[
     sectioncnt].required_status = added,
     reply->working_view_sections[sectioncnt].section_status = added
    ENDIF
   HEAD i.cnt_wv_item_key_id
    IF (i.cnt_wv_item_key_id > 0)
     dacnt = 0, itemcnt = (itemcnt+ 1), stat = alterlist(reply->working_view_sections[sectioncnt].
      working_view_items,itemcnt),
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].included_ind_status = none,
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].prim_event_set_name_status
      = none, reply->working_view_sections[sectioncnt].working_view_items[itemcnt].item_status = none,
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].cnt_wv_item_key_id = i
     .cnt_wv_item_key_id, reply->working_view_sections[sectioncnt].working_view_items[itemcnt].
     dcp_wv_item_ref_id = i.dcp_wv_item_ref_id, reply->working_view_sections[sectioncnt].
     working_view_items[itemcnt].falloff_view_minutes = i.falloff_view_minutes,
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].included_ind = i
     .included_ind, reply->working_view_sections[sectioncnt].working_view_items[itemcnt].
     parent_event_set_name = i.parent_event_set_name, reply->working_view_sections[sectioncnt].
     working_view_items[itemcnt].primitive_event_set_name = i.primitive_event_set_name,
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].task_assay_guid = i
     .task_assay_guid, reply->working_view_sections[sectioncnt].working_view_items[itemcnt].
     wv_item_uid = i.wv_item_uid
     IF (((dcp_id=0) OR ((request->compare_ind=0))) )
      reply->working_view_sections[sectioncnt].working_view_items[itemcnt].included_ind_status =
      added, reply->working_view_sections[sectioncnt].working_view_items[itemcnt].
      prim_event_set_name_status = added, reply->working_view_sections[sectioncnt].
      working_view_items[itemcnt].item_status = added
     ENDIF
    ENDIF
   HEAD dta.task_assay_uid
    IF (dta.cnt_dta_key_id > 0)
     dacnt = (dacnt+ 1), stat = alterlist(reply->working_view_sections[sectioncnt].
      working_view_items[itemcnt].disp_assoc_dtas,dacnt), reply->working_view_sections[sectioncnt].
     working_view_items[itemcnt].disp_assoc_dtas[dacnt].task_assay_uid = dta.task_assay_uid,
     reply->working_view_sections[sectioncnt].working_view_items[itemcnt].disp_assoc_dtas[dacnt].
     mnemonic = dta.mnemonic
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Could not retrieve cnt details")
 END ;Subroutine
 SUBROUTINE loadexistingdetails(dummyvar)
   DECLARE wvs_cnt = i4 WITH protect, noconstant(0)
   DECLARE wvi_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM working_view wv,
     working_view_section wvs,
     working_view_item wvi
    PLAN (wv
     WHERE wv.working_view_id=dcp_id)
     JOIN (wvs
     WHERE wvs.working_view_id=wv.working_view_id)
     JOIN (wvi
     WHERE wvi.working_view_section_id=wvs.working_view_section_id)
    ORDER BY wvs.working_view_section_id, wvi.working_view_item_id
    HEAD wvs.working_view_section_id
     wvi_cnt = 0, wvs_cnt = (wvs_cnt+ 1), stat = alterlist(existingdetails->working_view_sections,
      wvs_cnt),
     existingdetails->working_view_sections[wvs_cnt].working_view_section_id = wvs
     .working_view_section_id, existingdetails->working_view_sections[wvs_cnt].display_name = wvs
     .display_name, existingdetails->working_view_sections[wvs_cnt].event_set_name = wvs
     .event_set_name,
     existingdetails->working_view_sections[wvs_cnt].included_ind = wvs.included_ind, existingdetails
     ->working_view_sections[wvs_cnt].required_ind = wvs.required_ind, existingdetails->
     working_view_sections[wvs_cnt].section_type_flag = wvs.section_type_flag
    HEAD wvi.working_view_item_id
     wvi_cnt = (wvi_cnt+ 1), stat = alterlist(existingdetails->working_view_sections[wvs_cnt].
      working_view_items,wvi_cnt), existingdetails->working_view_sections[wvs_cnt].
     working_view_items[wvi_cnt].working_view_item_id = wvi.working_view_item_id,
     existingdetails->working_view_sections[wvs_cnt].working_view_items[wvi_cnt].falloff_view_minutes
      = wvi.falloff_view_minutes, existingdetails->working_view_sections[wvs_cnt].working_view_items[
     wvi_cnt].included_ind = wvi.included_ind, existingdetails->working_view_sections[wvs_cnt].
     working_view_items[wvi_cnt].parent_event_set_name = wvi.parent_event_set_name,
     existingdetails->working_view_sections[wvs_cnt].working_view_items[wvi_cnt].
     primitive_event_set_name = wvi.primitive_event_set_name
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not retrieve exist details")
 END ;Subroutine
 SUBROUTINE comparedetails(dummyvar)
   DECLARE importedsectionsize = i4 WITH protect, constant(size(reply->working_view_sections,5))
   DECLARE existingsectionsize = i4 WITH protect, constant(size(existingdetails->
     working_view_sections,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE itemfoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   FOR (eidx = 1 TO existingsectionsize)
     SET num = 1
     SET foundidx = locateval(num,1,importedsectionsize,existingdetails->working_view_sections[eidx].
      working_view_section_id,reply->working_view_sections[num].dcp_wv_section_ref_id)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,importedsectionsize,existingdetails->working_view_sections[eidx]
       .event_set_name,reply->working_view_sections[num].event_set_name)
     ENDIF
     IF (foundidx > 0)
      IF ((reply->working_view_sections[foundidx].dcp_wv_section_ref_id=0))
       SET reply->working_view_sections[foundidx].dcp_wv_section_ref_id = existingdetails->
       working_view_sections[eidx].working_view_section_id
      ENDIF
      IF ((reply->working_view_sections[foundidx].required_ind != existingdetails->
      working_view_sections[eidx].required_ind))
       SET reply->working_view_sections[foundidx].required_status = modified
       SET reply->working_view_sections[foundidx].section_status = modified
       CALL echo("MODIFIED REQUIRED")
      ENDIF
      IF ((reply->working_view_sections[foundidx].included_ind != existingdetails->
      working_view_sections[eidx].included_ind))
       SET reply->working_view_sections[foundidx].included_status = modified
       SET reply->working_view_sections[foundidx].section_status = modified
       CALL echo("MODIFIED INCLUDED")
      ENDIF
      IF ((reply->working_view_sections[foundidx].display_name != existingdetails->
      working_view_sections[eidx].display_name))
       SET reply->working_view_sections[foundidx].display_name_status = modified
       SET reply->working_view_sections[foundidx].section_status = modified
       CALL echo("MODIFIED DISPLAY")
      ENDIF
      FOR (itemidx = 1 TO size(existingdetails->working_view_sections[eidx].working_view_items,5))
        SET num1 = 1
        SET itemfoundidx = locateval(num1,1,size(reply->working_view_sections[foundidx].
          working_view_items,5),existingdetails->working_view_sections[eidx].working_view_items[
         itemidx].working_view_item_id,reply->working_view_sections[foundidx].working_view_items[num1
         ].dcp_wv_item_ref_id)
        IF (itemfoundidx=0)
         SET num1 = 1
         SET itemfoundidx = locateval(num1,1,size(reply->working_view_sections[foundidx].
           working_view_items,5),existingdetails->working_view_sections[eidx].working_view_items[
          itemidx].primitive_event_set_name,reply->working_view_sections[foundidx].
          working_view_items[num1].primitive_event_set_name)
        ENDIF
        IF (itemfoundidx > 0)
         IF ((reply->working_view_sections[foundidx].working_view_items[itemfoundidx].
         dcp_wv_item_ref_id=0))
          SET reply->working_view_sections[foundidx].working_view_items[itemfoundidx].
          dcp_wv_item_ref_id = existingdetails->working_view_sections[eidx].working_view_items[
          itemidx].working_view_item_id
         ENDIF
         IF ((reply->working_view_sections[foundidx].working_view_items[itemfoundidx].
         primitive_event_set_name != existingdetails->working_view_sections[eidx].working_view_items[
         itemidx].primitive_event_set_name))
          SET reply->working_view_sections[foundidx].section_status = modified
          SET reply->working_view_sections[foundidx].working_view_items[itemfoundidx].item_status =
          modified
          SET reply->working_view_sections[foundidx].working_view_items[itemfoundidx].
          prim_event_set_name_status = modified
          CALL echo("MODIFIED PRIM EVENT SET")
         ENDIF
         IF ((reply->working_view_sections[foundidx].working_view_items[itemfoundidx].included_ind
          != existingdetails->working_view_sections[eidx].working_view_items[itemidx].included_ind))
          SET reply->working_view_sections[foundidx].section_status = modified
          SET reply->working_view_sections[foundidx].working_view_items[itemfoundidx].item_status =
          modified
          SET reply->working_view_sections[foundidx].working_view_items[itemfoundidx].
          included_ind_status = modified
          CALL echo("MODIFIED ITEM INCLUDE")
         ENDIF
        ELSE
         SET icnt = (size(reply->working_view_sections[foundidx].working_view_items,5)+ 1)
         SET stat = alterlist(reply->working_view_sections[foundidx].working_view_items,icnt)
         SET reply->working_view_sections[foundidx].working_view_items[icnt].
         prim_event_set_name_status = removed
         SET reply->working_view_sections[foundidx].working_view_items[icnt].primitive_event_set_name
          = existingdetails->working_view_sections[eidx].working_view_items[itemidx].
         primitive_event_set_name
         SET reply->working_view_sections[foundidx].working_view_items[icnt].parent_event_set_name =
         existingdetails->working_view_sections[eidx].working_view_items[itemidx].
         parent_event_set_name
         SET reply->working_view_sections[foundidx].working_view_items[icnt].included_ind_status =
         removed
         SET reply->working_view_sections[foundidx].working_view_items[icnt].included_ind =
         existingdetails->working_view_sections[eidx].working_view_items[itemidx].included_ind
         SET reply->working_view_sections[foundidx].working_view_items[icnt].falloff_view_minutes =
         existingdetails->working_view_sections[eidx].working_view_items[itemidx].
         falloff_view_minutes
         SET reply->working_view_sections[foundidx].working_view_items[icnt].dcp_wv_item_ref_id =
         existingdetails->working_view_sections[eidx].working_view_items[itemidx].
         working_view_item_id
         SET reply->working_view_sections[foundidx].working_view_items[icnt].item_status = removed
        ENDIF
      ENDFOR
     ELSE
      SET icnt = (size(reply->working_view_sections,5)+ 1)
      SET stat = alterlist(reply->working_view_sections,icnt)
      SET reply->working_view_sections[icnt].required_status = removed
      SET reply->working_view_sections[icnt].required_ind = existingdetails->working_view_sections[
      eidx].required_ind
      SET reply->working_view_sections[icnt].included_status = removed
      SET reply->working_view_sections[icnt].included_ind = existingdetails->working_view_sections[
      eidx].included_ind
      SET reply->working_view_sections[icnt].event_set_name = existingdetails->working_view_sections[
      eidx].event_set_name
      SET reply->working_view_sections[icnt].display_name_status = removed
      SET reply->working_view_sections[icnt].display_name = existingdetails->working_view_sections[
      eidx].display_name
      SET reply->working_view_sections[icnt].section_status = removed
      SET reply->working_view_sections[icnt].dcp_wv_section_ref_id = existingdetails->
      working_view_sections[eidx].working_view_section_id
     ENDIF
   ENDFOR
   FOR (eidx = 1 TO importedsectionsize)
     SET num = 1
     SET foundidx = locateval(num,1,existingsectionsize,reply->working_view_sections[eidx].
      dcp_wv_section_ref_id,existingdetails->working_view_sections[num].working_view_section_id)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,existingsectionsize,reply->working_view_sections[eidx].
       event_set_name,existingdetails->working_view_sections[num].event_set_name)
     ENDIF
     IF (foundidx <= 0)
      SET reply->working_view_sections[eidx].required_status = added
      SET reply->working_view_sections[eidx].included_status = added
      SET reply->working_view_sections[eidx].display_name_status = added
      SET reply->working_view_sections[eidx].section_status = added
      FOR (itemidx = 1 TO size(reply->working_view_sections[eidx].working_view_items,5))
        SET reply->working_view_sections[eidx].working_view_items[itemidx].prim_event_set_name_status
         = added
        SET reply->working_view_sections[eidx].working_view_items[itemidx].included_ind_status =
        added
        SET reply->working_view_sections[eidx].working_view_items[itemidx].item_status = added
      ENDFOR
     ELSE
      FOR (itemidx = 1 TO size(reply->working_view_sections[eidx].working_view_items,5))
        SET num1 = 1
        SET itemfoundidx = locateval(num1,1,size(existingdetails->working_view_sections[foundidx].
          working_view_items,5),reply->working_view_sections[eidx].working_view_items[itemidx].
         dcp_wv_item_ref_id,existingdetails->working_view_sections[foundidx].working_view_items[num1]
         .working_view_item_id)
        IF (itemfoundidx=0)
         SET num = 1
         SET itemfoundidx = locateval(num,1,size(existingdetails->working_view_sections[foundidx].
           working_view_items,5),reply->working_view_sections[eidx].working_view_items[itemidx].
          primitive_event_set_name,existingdetails->working_view_sections[foundidx].
          working_view_items[num].primitive_event_set_name)
        ENDIF
        IF (itemfoundidx <= 0)
         SET reply->working_view_sections[eidx].working_view_items[itemidx].
         prim_event_set_name_status = added
         SET reply->working_view_sections[eidx].working_view_items[itemidx].included_ind_status =
         added
         SET reply->working_view_sections[eidx].working_view_items[itemidx].item_status = added
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
