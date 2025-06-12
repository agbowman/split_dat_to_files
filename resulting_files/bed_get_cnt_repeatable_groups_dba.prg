CREATE PROGRAM bed_get_cnt_repeatable_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 cnt_encounter_specific_ind = i2
    1 cnt_template_assays[*]
      2 task_assay_uid = vc
      2 task_assay_cd = f8
      2 mnemonic = vc
      2 template_assay_status = vc
    1 cnt_label_assays[*]
      2 task_assay_uid = vc
      2 task_assay_cd = f8
      2 mnemonic = vc
      2 sequence = i4
      2 seq_status = vc
      2 required_ind = i2
      2 required_status = vc
      2 label_assay_status = vc
    1 dcp_encounter_specific_ind = i2
    1 dcp_template_assays[*]
      2 task_assay_cd = f8
      2 mnemonic = vc
      2 template_assay_status = vc
    1 dcp_label_assays[*]
      2 task_assay_cd = f8
      2 mnemonic = vc
      2 sequence = i4
      2 seq_status = vc
      2 required_ind = i2
      2 required_status = vc
      2 label_assay_status = vc
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
 DECLARE added = vc WITH protect, constant("A")
 DECLARE removed = vc WITH protect, constant("R")
 DECLARE modified = vc WITH protect, constant("M")
 DECLARE none = vc WITH protect, constant("N")
 DECLARE dcp_id = f8 WITH protect, noconstant(0.0)
 DECLARE getcurrentrepeatablegroupid(dummyvar=i2) = f8
 DECLARE getcntlabelassays(dummyvar=i2) = null
 DECLARE getdcplabelassays(dummyvar=i2) = null
 DECLARE comparetemplates(dummyvar=i2) = i2
 DECLARE comparelabelassays(dummyvar=i2) = i2
 SET dcp_id = getcurrentrepeatablegroupid(null)
 CALL getcntlabelassays(0)
 IF (dcp_id > 0)
  CALL getdcplabelassays(0)
 ENDIF
 CALL comparetemplates(null)
 CALL comparelabelassays(null)
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE getcurrentrepeatablegroupid(dummyvar)
   DECLARE cnt_dcp_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM cnt_ds_key d
    PLAN (d
     WHERE (d.cnt_ds_key_uid=request->cnt_ds_key_uid)
      AND d.active_ind=1)
    DETAIL
     cnt_dcp_id = d.doc_set_ref_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not retrieve dcp id")
   IF (cnt_dcp_id=0)
    SELECT INTO "nl:"
     FROM cnt_ds_key c,
      doc_set_ref d
     PLAN (c
      WHERE (c.cnt_ds_key_uid=request->cnt_ds_key_uid)
       AND c.active_ind=1)
      JOIN (d
      WHERE cnvtupper(c.doc_set_name)=cnvtupper(d.doc_set_name))
     DETAIL
      cnt_dcp_id = d.doc_set_ref_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Could not retrieve name match")
   ENDIF
   RETURN(cnt_dcp_id)
 END ;Subroutine
 SUBROUTINE getcntlabelassays(dummyvar)
   CALL bedlogmessage("getCntLabelAssays","Entering ...")
   FREE RECORD labeltemplateids
   RECORD labeltemplateids(
     1 label_template[*]
       2 label_template_id = f8
   )
   FREE RECORD wvlabeltemplateids
   RECORD wvlabeltemplateids(
     1 label_template[*]
       2 label_template_id = f8
   )
   FREE RECORD wvdtaguids
   RECORD wvdtaguids(
     1 dtas[*]
       2 dta_guid = vc
   )
   DECLARE labeltemplatecnt = i4 WITH noconstant(0), protect
   DECLARE wvlabeltemplatecnt = i4 WITH noconstant(0), protect
   DECLARE wvdtacnt = i4 WITH noconstant(0), protect
   DECLARE assaycnt = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE num2 = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM cnt_wv_section_r s,
     cnt_wv_section_item_r ir,
     cnt_wv_item_key ik,
     cnt_dta dta
    PLAN (s
     WHERE (s.working_view_uid=request->working_view_uid))
     JOIN (ir
     WHERE ir.wv_section_uid=s.wv_section_uid)
     JOIN (ik
     WHERE ik.wv_item_uid=ir.wv_item_uid)
     JOIN (dta
     WHERE dta.task_assay_uid=ik.task_assay_guid
      AND dta.label_template_id > 0.0)
    ORDER BY dta.label_template_id, dta.task_assay_uid
    HEAD dta.label_template_id
     wvlabeltemplatecnt = (wvlabeltemplatecnt+ 1), stat = alterlist(wvlabeltemplateids->
      label_template,wvlabeltemplatecnt), wvlabeltemplateids->label_template[wvlabeltemplatecnt].
     label_template_id = dta.label_template_id
    HEAD dta.task_assay_uid
     wvdtacnt = (wvdtacnt+ 1), stat = alterlist(wvdtaguids->dtas,wvdtacnt), wvdtaguids->dtas[wvdtacnt
     ].dta_guid = dta.task_assay_uid
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not get WV Temp")
   SELECT INTO "nl:"
    FROM cnt_ds_key s,
     cnt_ds_label_r cr,
     cnt_ds_label_key lk,
     cnt_dta dta,
     cnt_dta_key2 dk,
     discrete_task_assay d1
    PLAN (s
     WHERE (s.cnt_ds_key_uid=request->cnt_ds_key_uid))
     JOIN (cr
     WHERE cr.cnt_ds_key_uid=s.cnt_ds_key_uid)
     JOIN (lk
     WHERE lk.cnt_ds_label_key_uid=cr.cnt_ds_label_key_uid)
     JOIN (dta
     WHERE dta.label_template_id=lk.label_template_id
      AND dta.label_template_id > 0.0)
     JOIN (dk
     WHERE dk.task_assay_uid=outerjoin(dta.task_assay_uid))
     JOIN (d1
     WHERE d1.mnemonic=outerjoin(dta.mnemonic))
    ORDER BY dta.cnt_dta_id
    HEAD dta.cnt_dta_id
     num = 0
     IF (locateval(num,1,wvlabeltemplatecnt,dta.label_template_id,wvlabeltemplateids->label_template[
      num].label_template_id) > 0)
      IF (locateval(num2,1,wvdtacnt,dta.task_assay_uid,wvdtaguids->dtas[num2].dta_guid) > 0)
       labeltemplatecnt = (labeltemplatecnt+ 1), stat = alterlist(labeltemplateids->label_template,
        labeltemplatecnt), labeltemplateids->label_template[labeltemplatecnt].label_template_id = dta
       .label_template_id,
       stat = alterlist(reply->cnt_template_assays,labeltemplatecnt), reply->cnt_template_assays[
       labeltemplatecnt].template_assay_status = none, reply->cnt_template_assays[labeltemplatecnt].
       mnemonic = dta.mnemonic,
       reply->cnt_template_assays[labeltemplatecnt].task_assay_uid = dta.task_assay_uid
       IF (dk.task_assay_cd > 0)
        reply->cnt_template_assays[labeltemplatecnt].task_assay_cd = dk.task_assay_cd
       ELSEIF (d1.task_assay_cd > 0)
        reply->cnt_template_assays[labeltemplatecnt].task_assay_cd = d1.task_assay_cd
       ENDIF
       IF (dcp_id=0)
        reply->cnt_template_assays[labeltemplatecnt].template_assay_status = added
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not get CNT Temp")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = labeltemplatecnt),
     cnt_ds_label_key lk,
     cnt_ds_label_r lr,
     cnt_ds_section_r sr,
     cnt_ds_section_element_r ser,
     cnt_ds_sec_element_key sek,
     cnt_dta dta,
     cnt_dta_key2 dk,
     discrete_task_assay d2
    PLAN (d1)
     JOIN (lk
     WHERE (lk.label_template_id=labeltemplateids->label_template[d1.seq].label_template_id))
     JOIN (lr
     WHERE lr.cnt_ds_label_key_uid=lk.cnt_ds_label_key_uid)
     JOIN (sr
     WHERE sr.cnt_ds_key_uid=lr.cnt_ds_key_uid)
     JOIN (ser
     WHERE ser.cnt_ds_section_key_uid=sr.cnt_ds_section_key_uid)
     JOIN (sek
     WHERE sek.cnt_ds_sec_element_key_uid=ser.cnt_ds_sec_element_key_uid)
     JOIN (dta
     WHERE dta.task_assay_uid=sek.task_assay_cd_uid)
     JOIN (dk
     WHERE dk.task_assay_uid=outerjoin(dta.task_assay_uid))
     JOIN (d2
     WHERE d2.mnemonic=outerjoin(dta.mnemonic))
    ORDER BY dta.task_assay_uid, sek.doc_set_elem_sequence
    HEAD dta.task_assay_uid
     assaycnt = (assaycnt+ 1), stat = alterlist(reply->cnt_label_assays,assaycnt), reply->
     cnt_label_assays[assaycnt].mnemonic = dta.mnemonic,
     reply->cnt_label_assays[assaycnt].task_assay_uid = dta.task_assay_uid
     IF (dk.task_assay_cd > 0)
      reply->cnt_label_assays[assaycnt].task_assay_cd = dk.task_assay_cd
     ELSEIF (d2.task_assay_cd > 0)
      reply->cnt_label_assays[assaycnt].task_assay_cd = d2.task_assay_cd
     ENDIF
     reply->cnt_label_assays[assaycnt].sequence = sek.doc_set_elem_sequence, reply->cnt_label_assays[
     assaycnt].seq_status = none, reply->cnt_label_assays[assaycnt].required_status = none,
     reply->cnt_label_assays[assaycnt].required_ind = sek.required_ind, reply->cnt_label_assays[
     assaycnt].label_assay_status = none, reply->cnt_encounter_specific_ind = lk
     .encounter_specific_ind
     IF (dcp_id=0)
      reply->cnt_label_assays[assaycnt].seq_status = added, reply->cnt_label_assays[assaycnt].
      required_status = added, reply->cnt_label_assays[assaycnt].label_assay_status = added
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not get CNT Label")
   CALL bedlogmessage("getCntLabelAssays","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdcplabelassays(dummyvar)
   CALL bedlogmessage("getDcpLabelAssays","Entering ...")
   FREE RECORD labeltemplateids
   RECORD labeltemplateids(
     1 label_template[*]
       2 label_template_id = f8
   )
   DECLARE labeltemplatecnt = i4 WITH noconstant(0), protect
   DECLARE assaycnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dynamic_label_template t,
     discrete_task_assay dta
    PLAN (t
     WHERE t.doc_set_ref_id=dcp_id)
     JOIN (dta
     WHERE dta.label_template_id=t.label_template_id
      AND dta.active_ind=1)
    ORDER BY dta.task_assay_cd
    HEAD dta.task_assay_cd
     labeltemplatecnt = (labeltemplatecnt+ 1), stat = alterlist(labeltemplateids->label_template,
      labeltemplatecnt), labeltemplateids->label_template[labeltemplatecnt].label_template_id = dta
     .label_template_id,
     stat = alterlist(reply->dcp_template_assays,labeltemplatecnt), reply->dcp_template_assays[
     labeltemplatecnt].template_assay_status = none, reply->dcp_template_assays[labeltemplatecnt].
     mnemonic = dta.mnemonic,
     reply->dcp_template_assays[labeltemplatecnt].task_assay_cd = dta.task_assay_cd
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not get DCP Temp")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = labeltemplatecnt),
     dynamic_label_template t,
     doc_set_ref r,
     doc_set_section_ref_r srr,
     doc_set_section_ref sr,
     doc_set_element_ref e,
     discrete_task_assay dta
    PLAN (d1)
     JOIN (t
     WHERE (t.label_template_id=labeltemplateids->label_template[d1.seq].label_template_id))
     JOIN (r
     WHERE r.doc_set_ref_id=t.doc_set_ref_id)
     JOIN (srr
     WHERE srr.doc_set_ref_id=r.doc_set_ref_id)
     JOIN (sr
     WHERE sr.doc_set_section_ref_id=srr.doc_set_section_ref_id)
     JOIN (e
     WHERE e.doc_set_section_ref_id=sr.doc_set_section_ref_id
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.task_assay_cd > 0
      AND e.active_ind=1)
     JOIN (dta
     WHERE dta.task_assay_cd=e.task_assay_cd)
    ORDER BY dta.task_assay_cd, e.doc_set_elem_sequence
    HEAD dta.task_assay_cd
     assaycnt = (assaycnt+ 1), stat = alterlist(reply->dcp_label_assays,assaycnt), reply->
     dcp_label_assays[assaycnt].mnemonic = dta.mnemonic,
     reply->dcp_label_assays[assaycnt].task_assay_cd = dta.task_assay_cd, reply->dcp_label_assays[
     assaycnt].sequence = e.doc_set_elem_sequence, reply->dcp_label_assays[assaycnt].seq_status =
     none,
     reply->dcp_label_assays[assaycnt].required_status = none, reply->dcp_label_assays[assaycnt].
     required_ind = e.required_ind, reply->dcp_label_assays[assaycnt].label_assay_status = none,
     reply->dcp_encounter_specific_ind = t.encounter_specific_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("Could not get DCP Label")
   CALL bedlogmessage("getDcpLabelAssays","Exiting ...")
 END ;Subroutine
 SUBROUTINE comparetemplates(dummyvar)
   DECLARE importedtemplatesize = i4 WITH protect, constant(size(reply->cnt_template_assays,5))
   DECLARE existingtemplatesize = i4 WITH protect, constant(size(reply->dcp_template_assays,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE itemfoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   FOR (eidx = 1 TO existingtemplatesize)
     SET num = 1
     SET foundidx = locateval(num,1,importedtemplatesize,reply->dcp_template_assays[eidx].
      task_assay_cd,reply->cnt_template_assays[num].task_assay_cd)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,importedtemplatesize,reply->dcp_template_assays[eidx].mnemonic,
       reply->cnt_template_assays[num].mnemonic)
     ENDIF
     IF (foundidx > 0)
      IF ((reply->cnt_template_assays[foundidx].task_assay_cd=0))
       SET reply->cnt_template_assays[foundidx].task_assay_cd = reply->dcp_template_assays[eidx].
       task_assay_cd
      ENDIF
     ELSE
      SET reply->dcp_template_assays[eidx].template_assay_status = removed
     ENDIF
   ENDFOR
   FOR (eidx = 1 TO importedtemplatesize)
     SET num = 1
     SET foundidx = locateval(num,1,existingtemplatesize,reply->cnt_template_assays[eidx].
      task_assay_cd,reply->dcp_template_assays[num].task_assay_cd)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,existingtemplatesize,reply->cnt_template_assays[eidx].mnemonic,
       reply->dcp_template_assays[num].mnemonic)
     ENDIF
     IF (foundidx <= 0)
      SET reply->cnt_template_assays[eidx].template_assay_status = added
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE comparelabelassays(dummyvar)
   DECLARE importedlabelsize = i4 WITH protect, constant(size(reply->cnt_label_assays,5))
   DECLARE existinglabelsize = i4 WITH protect, constant(size(reply->dcp_label_assays,5))
   DECLARE foundidx = i4 WITH protect, noconstant(0)
   DECLARE itemfoundidx = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE num1 = i4 WITH protect, noconstant(1)
   FOR (eidx = 1 TO existinglabelsize)
     SET num = 1
     SET foundidx = locateval(num,1,importedlabelsize,reply->dcp_label_assays[eidx].task_assay_cd,
      reply->cnt_label_assays[num].task_assay_cd)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,importedlabelsize,reply->dcp_label_assays[eidx].mnemonic,reply->
       cnt_label_assays[num].mnemonic)
     ENDIF
     IF (foundidx > 0)
      IF ((reply->cnt_label_assays[foundidx].task_assay_cd=0))
       SET reply->cnt_label_assays[foundidx].task_assay_cd = reply->dcp_label_assays[eidx].
       task_assay_cd
      ENDIF
      IF ((reply->cnt_label_assays[foundidx].sequence != reply->dcp_label_assays[eidx].sequence))
       SET reply->cnt_label_assays[foundidx].seq_status = modified
       SET reply->dcp_label_assays[eidx].seq_status = modified
       SET reply->cnt_label_assays[foundidx].label_assay_status = modified
       SET reply->dcp_label_assays[eidx].label_assay_status = modified
      ENDIF
      IF ((reply->cnt_label_assays[foundidx].required_ind != reply->dcp_label_assays[eidx].
      required_ind))
       SET reply->cnt_label_assays[foundidx].required_status = modified
       SET reply->dcp_label_assays[eidx].required_status = modified
       SET reply->cnt_label_assays[foundidx].label_assay_status = modified
       SET reply->dcp_label_assays[eidx].label_assay_status = modified
      ENDIF
     ELSE
      SET reply->dcp_label_assays[eidx].label_assay_status = removed
     ENDIF
   ENDFOR
   FOR (eidx = 1 TO importedlabelsize)
     SET num = 1
     SET foundidx = locateval(num,1,existinglabelsize,reply->cnt_label_assays[eidx].task_assay_cd,
      reply->dcp_label_assays[num].task_assay_cd)
     IF (foundidx=0)
      SET num = 1
      SET foundidx = locateval(num,1,existinglabelsize,reply->cnt_label_assays[eidx].mnemonic,reply->
       dcp_label_assays[num].mnemonic)
     ENDIF
     IF (foundidx <= 0)
      SET reply->cnt_label_assays[eidx].label_assay_status = added
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
