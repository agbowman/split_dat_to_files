CREATE PROGRAM bed_aud_iview_mill_report:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 iviews[*]
      2 view_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 wvs[*]
     2 id = f8
     2 name = vc
     2 sections[*]
       3 id = f8
       3 name = vc
       3 status = vc
       3 event_set_name = vc
       3 event_set_cd = f8
       3 event_set_status = vc
       3 event_set_esh_status = vc
       3 subsection[*]
         4 id = f8
         4 name = vc
         4 display = vc
         4 prim_disp = vc
         4 disp_assoc = i2
         4 disp_assoc_name = vc
         4 disp_assoc_cd = f8
         4 prim_event_set = vc
         4 prim_event_set_name = vc
         4 item_status = vc
         4 event_set_cd = f8
         4 event_set_status = vc
         4 event_set_esh_status = vc
         4 da_list[*]
           5 prim_event_set = vc
         4 details[*]
           5 da_prim_event_set = vc
           5 assay_mnemonic = vc
           5 dynamic = vc
           5 dynamic_type = vc
           5 dynamic_id = f8
 )
 FREE RECORD dynamic_added
 RECORD dynamic_added(
   1 dadd[*]
     2 label_id = f8
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
 DECLARE yes = vc WITH protect, constant("Yes")
 DECLARE no = vc WITH protect, constant("No")
 DECLARE updated = vc WITH protect, constant("Yes, needs updated")
 DECLARE det_cnt = i4 WITH protect, noconstant(0)
 DECLARE da_cnt = i4 WITH protect, noconstant(0)
 DECLARE wvs_event = f8 WITH protect, noconstant(0.0)
 DECLARE eventsetsize = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE foundidx = i4 WITH protect, noconstant(0)
 SET tot_col = 14
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "View"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Section Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Section Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Section Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Subsection Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Subsection Display"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Display Association"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Dynamic Group"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Primitive Event Set Name"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Primitive Event Set Display"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Item Status"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Assay Display"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "In ESH"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "In ESH Working View Sections"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET req_cnt = size(request->iviews,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM v500_event_set_code ve
  WHERE cnvtupper(ve.event_set_name)="WORKING VIEW SECTIONS"
  DETAIL
   wvs_event = ve.event_set_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("working view sections error")
 FREE RECORD geteventhierrequest
 RECORD geteventhierrequest(
   1 event_set_code_value = f8
   1 max_reply = i4
 )
 FREE RECORD geteventhierreply
 RECORD geteventhierreply(
   1 event_sets[*]
     2 code_value = f8
     2 display = vc
     2 sequence = i4
     2 display_association_ind = i2
     2 event_set_name = vc
     2 parent_event_set_code = f8
     2 event_codes[*]
       3 code_value = f8
       3 display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = initrec(geteventhierrequest)
 SET stat = initrec(geteventhierreply)
 SET geteventhierrequest->event_set_code_value = wvs_event
 EXECUTE bed_get_eces_hier_xpld  WITH replace("REQUEST",geteventhierrequest), replace("REPLY",
  geteventhierreply)
 IF ((geteventhierreply->status_data.status != "S"))
  CALL bederror("bed_get_eces_hier_xpld did not return success")
 ENDIF
 SET eventsetsize = size(geteventhierreply->event_sets,5)
 SET row_nbr = 0
 SET tot_wvcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   working_view wv,
   working_view_section wvs,
   v500_event_set_code vsi,
   v500_event_set_code ves,
   working_view_item wvi
  PLAN (d)
   JOIN (wv
   WHERE (wv.working_view_id=request->iviews[d.seq].view_id)
    AND wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
   JOIN (vsi
   WHERE cnvtupper(vsi.event_set_name)=outerjoin(cnvtupper(wvi.parent_event_set_name)))
   JOIN (ves
   WHERE cnvtupper(ves.event_set_name)=outerjoin(cnvtupper(wvi.primitive_event_set_name)))
  ORDER BY wv.display_name, wv.working_view_id, wvs.working_view_section_id,
   wvi.working_view_item_id
  HEAD REPORT
   wvcnt = 0, tot_wvcnt = 0, stat = alterlist(temp->wvs,100)
  HEAD wv.working_view_id
   wvcnt = (wvcnt+ 1), tot_wvcnt = (tot_wvcnt+ 1)
   IF (wvcnt > 100)
    stat = alterlist(temp->wvs,(tot_wvcnt+ 100)), wvcnt = 1
   ENDIF
   temp->wvs[tot_wvcnt].id = wv.working_view_id, temp->wvs[tot_wvcnt].name = wv.display_name, wscnt
    = 0,
   tot_wscnt = 0, stat = alterlist(temp->wvs[tot_wvcnt].sections,100)
  HEAD wvs.working_view_section_id
   wicnt = 0, tot_wicnt = 0, wvs_set = 0
  HEAD wvi.working_view_item_id
   IF (wvs_set=0
    AND ((wvs.section_type_flag=1) OR (wvi.working_view_item_id > 0)) )
    wvs_set = 1, wscnt = (wscnt+ 1), tot_wscnt = (tot_wscnt+ 1)
    IF (wscnt > 100)
     stat = alterlist(temp->wvs[tot_wvcnt].sections,(tot_wscnt+ 100)), wscnt = 1
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].id = wvs.working_view_section_id, temp->wvs[tot_wvcnt].
    sections[tot_wscnt].name = wvs.display_name, temp->wvs[tot_wvcnt].sections[tot_wscnt].
    event_set_name = wvs.event_set_name,
    temp->wvs[tot_wvcnt].sections[tot_wscnt].event_set_cd = vsi.event_set_cd
    IF (vsi.event_set_cd=0)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].event_set_status = no, temp->wvs[tot_wvcnt].sections[
     tot_wscnt].event_set_esh_status = no
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].event_set_esh_status = yes, num = 1, foundidx =
     locateval(num,1,eventsetsize,vsi.event_set_cd,geteventhierreply->event_sets[num].code_value)
     IF (foundidx > 0)
      temp->wvs[tot_wvcnt].sections[tot_wscnt].event_set_status = yes
     ELSE
      temp->wvs[tot_wvcnt].sections[tot_wscnt].event_set_status = no
     ENDIF
    ENDIF
    IF (wvs.included_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Included"
    ELSEIF (wvs.required_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Required"
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].status = "Excluded"
    ENDIF
    stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,100)
   ENDIF
   IF (wvi.working_view_item_id > 0)
    wicnt = (wicnt+ 1), tot_wicnt = (tot_wicnt+ 1)
    IF (wicnt > 100)
     stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,(tot_wicnt+ 100)), wicnt =
     1
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].id = wvi.working_view_item_id
    IF (cnvtupper(wvi.parent_event_set_name) != cnvtupper(wvs.event_set_name))
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].name = wvi.parent_event_set_name,
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].display = vsi.event_set_cd_disp
    ENDIF
    IF (wvi.included_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].item_status = "Included"
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].item_status = "Excluded"
    ENDIF
    IF (ves.event_set_cd=0)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_status = no, temp->wvs[
     tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_esh_status = no
    ELSE
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_esh_status = yes, num
      = 1, foundidx = locateval(num,1,eventsetsize,ves.event_set_cd,geteventhierreply->event_sets[num
      ].code_value)
     IF (foundidx > 0)
      temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_status = yes
     ELSE
      temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_status = no
     ENDIF
    ENDIF
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].prim_event_set = ves
    .event_set_cd_disp, temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].event_set_cd
     = ves.event_set_cd, temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].
    prim_event_set_name = wvi.primitive_event_set_name,
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].prim_disp = ves.event_set_cd_disp,
    temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc = ves
    .display_association_ind
    IF (ves.display_association_ind=1)
     temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc_name = ves
     .event_set_name, temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection[tot_wicnt].disp_assoc_cd =
     ves.event_set_cd
    ENDIF
   ENDIF
  FOOT  wvs.working_view_section_id
   stat = alterlist(temp->wvs[tot_wvcnt].sections[tot_wscnt].subsection,tot_wicnt)
  FOOT  wv.working_view_id
   stat = alterlist(temp->wvs[tot_wvcnt].sections,tot_wscnt)
  FOOT REPORT
   stat = alterlist(temp->wvs,tot_wvcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("working view retrieval error")
 FOR (x = 1 TO tot_wvcnt)
  SET sec_cnt = size(temp->wvs[x].sections,5)
  FOR (y = 1 TO sec_cnt)
   SET sub_cnt = size(temp->wvs[x].sections[y].subsection,5)
   IF (sub_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sub_cnt),
      v500_event_code vc,
      v500_event_set_code vsc,
      v500_event_set_explode ve,
      discrete_task_assay dta,
      dynamic_label_template dgt,
      doc_set_ref dsr
     PLAN (d
      WHERE (temp->wvs[x].sections[y].subsection[d.seq].disp_assoc != 1))
      JOIN (vsc
      WHERE cnvtupper(vsc.event_set_name)=cnvtupper(temp->wvs[x].sections[y].subsection[d.seq].
       prim_event_set_name))
      JOIN (ve
      WHERE ve.event_set_cd=vsc.event_set_cd
       AND ve.event_set_level=0)
      JOIN (vc
      WHERE vc.event_cd=ve.event_cd)
      JOIN (dta
      WHERE dta.event_cd=outerjoin(vc.event_cd))
      JOIN (dgt
      WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
      JOIN (dsr
      WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
       AND dsr.active_ind=outerjoin(1))
     ORDER BY d.seq, dta.mnemonic
     HEAD d.seq
      ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,100
       )
     DETAIL
      ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
      IF (ecnt > 100)
       stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,(etot_cnt+ 100)), ecnt = 1
      ENDIF
      temp->wvs[x].sections[y].subsection[d.seq].details[etot_cnt].assay_mnemonic = dta.mnemonic
      IF (dsr.doc_set_ref_id > 0)
       temp->wvs[x].sections[y].subsection[d.seq].details[etot_cnt].dynamic_type = "Template", temp->
       wvs[x].sections[y].subsection[d.seq].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].details,etot_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("non-display associations retrieval error")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sub_cnt),
      v500_event_set_canon vs,
      v500_event_set_code vc
     PLAN (d
      WHERE (temp->wvs[x].sections[y].subsection[d.seq].disp_assoc=1))
      JOIN (vs
      WHERE (vs.parent_event_set_cd=temp->wvs[x].sections[y].subsection[d.seq].disp_assoc_cd))
      JOIN (vc
      WHERE vc.event_set_cd=vs.event_set_cd)
     ORDER BY d.seq
     HEAD d.seq
      ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,100
       )
     HEAD vc.event_set_cd
      ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
      IF (ecnt > 100)
       stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,(etot_cnt+ 100)), ecnt = 1
      ENDIF
      temp->wvs[x].sections[y].subsection[d.seq].da_list[etot_cnt].prim_event_set = vc.event_set_name
     FOOT  d.seq
      stat = alterlist(temp->wvs[x].sections[y].subsection[d.seq].da_list,etot_cnt)
     WITH nocounter
    ;end select
    CALL bederrorcheck("display associations retrieval error")
    FOR (z = 1 TO sub_cnt)
      IF ((temp->wvs[x].sections[y].subsection[z].disp_assoc=1))
       SET da_cnt = size(temp->wvs[x].sections[y].subsection[z].da_list,5)
       IF (da_cnt > 0)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = da_cnt),
          v500_event_code vc,
          discrete_task_assay dta,
          dynamic_label_template dgt,
          doc_set_ref dsr
         PLAN (d)
          JOIN (vc
          WHERE cnvtupper(vc.event_set_name)=outerjoin(cnvtupper(temp->wvs[x].sections[y].subsection[
            z].da_list[d.seq].prim_event_set)))
          JOIN (dta
          WHERE dta.event_cd=outerjoin(vc.event_cd))
          JOIN (dgt
          WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
          JOIN (dsr
          WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
           AND dsr.active_ind=outerjoin(1))
         ORDER BY d.seq, dta.mnemonic
         HEAD REPORT
          ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,100
           )
         DETAIL
          ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
          IF (ecnt > 100)
           stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,(etot_cnt+ 100)), ecnt = 1
          ENDIF
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].da_prim_event_set = temp->wvs[x].
          sections[y].subsection[z].da_list[d.seq].prim_event_set, temp->wvs[x].sections[y].
          subsection[z].details[etot_cnt].assay_mnemonic = dta.mnemonic
          IF (dsr.doc_set_ref_id > 0)
           temp->wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_type = "Template", temp->
           wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
          ENDIF
         FOOT REPORT
          stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,etot_cnt)
         WITH nocounter
        ;end select
        CALL bederrorcheck("disp event code retrieval error")
       ELSE
        SELECT INTO "nl:"
         FROM v500_event_code vc,
          discrete_task_assay dta,
          dynamic_label_template dgt,
          doc_set_ref dsr
         PLAN (vc
          WHERE (vc.event_set_name=temp->wvs[x].sections[y].subsection[z].disp_assoc_name))
          JOIN (dta
          WHERE dta.event_cd=outerjoin(vc.event_cd))
          JOIN (dgt
          WHERE dgt.label_template_id=outerjoin(dta.label_template_id))
          JOIN (dsr
          WHERE dsr.doc_set_ref_id=outerjoin(dgt.doc_set_ref_id)
           AND dsr.active_ind=outerjoin(1))
         ORDER BY dta.mnemonic
         HEAD REPORT
          ecnt = 0, etot_cnt = 0, stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,100
           )
         DETAIL
          ecnt = (ecnt+ 1), etot_cnt = (etot_cnt+ 1)
          IF (ecnt > 100)
           stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,(etot_cnt+ 100)), ecnt = 1
          ENDIF
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].assay_mnemonic = dta.mnemonic,
          temp->wvs[x].sections[y].subsection[z].details[etot_cnt].da_prim_event_set = vc
          .event_set_name
          IF (dsr.doc_set_ref_id > 0)
           temp->wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_type = "Template", temp->
           wvs[x].sections[y].subsection[z].details[etot_cnt].dynamic_id = dsr.doc_set_ref_id
          ENDIF
         FOOT REPORT
          stat = alterlist(temp->wvs[x].sections[y].subsection[z].details,etot_cnt)
         WITH nocounter
        ;end select
        CALL bederrorcheck("no disp event code retrieval error")
       ENDIF
      ENDIF
      SET det_cnt = size(temp->wvs[x].sections[y].subsection[z].details,5)
      IF (det_cnt > 0)
       FOR (a = 1 TO det_cnt)
        IF ((temp->wvs[x].sections[y].subsection[z].details[a].dynamic_id > 0))
         SELECT INTO "nl:"
          FROM discrete_task_assay dta,
           doc_set_element_ref der,
           doc_set_section_ref_r drr,
           v500_event_set_explode ve,
           v500_event_set_code v
          PLAN (drr
           WHERE (drr.doc_set_ref_id=temp->wvs[x].sections[y].subsection[z].details[a].dynamic_id)
            AND drr.active_ind=1)
           JOIN (der
           WHERE der.doc_set_section_ref_id=drr.doc_set_section_ref_id
            AND der.active_ind=1
            AND der.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND der.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (dta
           WHERE dta.task_assay_cd=der.task_assay_cd)
           JOIN (ve
           WHERE dta.event_cd=ve.event_cd
            AND ve.event_set_level=0)
           JOIN (v
           WHERE v.event_set_cd=ve.event_set_cd)
          ORDER BY der.doc_set_elem_sequence
          DETAIL
           found_label_ind = 0, dy_size = size(dynamic_added->dadd,5)
           IF (dy_size > 0)
            FOR (da = 1 TO dy_size)
              IF ((dynamic_added->dadd[da].label_id=der.doc_set_element_id))
               found_label_ind = 1
              ENDIF
            ENDFOR
           ENDIF
           IF (((dy_size=0) OR (found_label_ind=0)) )
            dy_size = (dy_size+ 1), stat = alterlist(dynamic_added->dadd,dy_size), dynamic_added->
            dadd[dy_size].label_id = der.doc_set_element_id,
            stat = add_label(x,y,z,v.event_set_name,v.event_set_cd_disp,
             dta.mnemonic)
           ENDIF
          WITH nocounter
         ;end select
         CALL bederrorcheck("dynamic label retrieval error")
        ENDIF
        SET stat = add_rep(x,y,z,a)
       ENDFOR
      ELSE
       SET stat = add_rep(x,y,z,0)
      ENDIF
    ENDFOR
   ELSE
    SET stat = add_rep(x,y,0,0)
   ENDIF
  ENDFOR
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,tot_col)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->wvs[p1].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->wvs[p1].sections[p2].event_set_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->wvs[p1].sections[p2].name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->wvs[p1].sections[p2].status
   SET reply->rowlist[row_nbr].celllist[14].string_value = temp->wvs[p1].sections[p2].
   event_set_status
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->wvs[p1].sections[p2].
   event_set_esh_status
   IF (p3 > 0)
    SET reply->rowlist[row_nbr].celllist[5].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    name
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    display
    SET reply->rowlist[row_nbr].celllist[7].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    disp_assoc_name
    SET reply->rowlist[row_nbr].celllist[9].string_value = temp->wvs[p1].sections[p2].subsection[p3].
    prim_event_set_name
    SET reply->rowlist[row_nbr].celllist[10].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .prim_disp
    SET reply->rowlist[row_nbr].celllist[11].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .item_status
    SET reply->rowlist[row_nbr].celllist[14].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .event_set_status
    SET reply->rowlist[row_nbr].celllist[13].string_value = temp->wvs[p1].sections[p2].subsection[p3]
    .event_set_esh_status
    IF (p4 > 0)
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->wvs[p1].sections[p2].subsection[p3]
     .details[p4].dynamic_type
     SET reply->rowlist[row_nbr].celllist[12].string_value = temp->wvs[p1].sections[p2].subsection[p3
     ].details[p4].assay_mnemonic
     IF ((temp->wvs[p1].sections[p2].subsection[p3].disp_assoc=1))
      SET reply->rowlist[row_nbr].celllist[9].string_value = temp->wvs[p1].sections[p2].subsection[p3
      ].details[p4].da_prim_event_set
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_label(l1,l2,l3,l4,l5,l6)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,tot_col)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->wvs[l1].name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->wvs[l1].sections[l2].event_set_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->wvs[l1].sections[l2].name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->wvs[l1].sections[l2].status
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   name
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   display
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   disp_assoc_name
   SET reply->rowlist[row_nbr].celllist[8].string_value = "Label"
   SET reply->rowlist[row_nbr].celllist[9].string_value = l4
   SET reply->rowlist[row_nbr].celllist[10].string_value = l5
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->wvs[l1].sections[l2].subsection[l3].
   item_status
   SET reply->rowlist[row_nbr].celllist[12].string_value = l6
   RETURN(1)
 END ;Subroutine
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_mill_design_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
