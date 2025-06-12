CREATE PROGRAM bed_get_coll_oc_by_serv_res:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 coll_reqs_ind = i2
    1 catalog_cd = f8
    1 specimen_type_cd = f8
    1 activity_subtype_cd = f8
    1 service_resources[*]
      2 code_value = f8
      2 requirements[*]
        3 age_from_minutes = i4
        3 age_to_minutes = i4
        3 minimum_volume = f8
        3 priority_code_value = f8
        3 container_code_value = f8
        3 coll_class_code_value = f8
        3 spec_hand_code_value = f8
    1 activity_type = c12
    1 return_all_subtypes_ind = i2
    1 collection_method_cd = f8
    1 accession_class_cd = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 clist[*]
      2 catalog_cd = f8
      2 primary_mnemonic = c100
      2 sr_list[*]
        3 code_value = f8
        3 requirements[*]
          4 age_from_minutes = i4
          4 age_to_minutes = i4
          4 minimum_volume = f8
          4 priority_code_value = f8
          4 container_code_value = f8
          4 coll_class_code_value = f8
          4 spec_hand_code_value = f8
          4 aliquot_ind = i2
          4 aliquot_route_sequence = i4
          4 aliquot_seq = i4
          4 extra_labels = i4
          4 aliquot_info_qual[*]
            5 coll_info_seq = i4
            5 aliquot_seq = i4
            5 min_vol = f8
            5 min_vol_units = vc
            5 units_cd = f8
            5 spec_cntnr_cd = f8
            5 coll_class_cd = f8
            5 spec_hndl_cd = f8
            5 net_ind = i2
            5 storage_temp_cd = f8
            5 aliquot_seq_f8 = f8
            5 coll_info_seq_f8 = f8
          4 aliquot_seq_f8 = f8
          4 alt_containers[*]
            5 min_volume = f8
            5 spec_container_cd = f8
            5 collection_class_cd = f8
            5 special_handlding_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD oc(
   1 sr_list[*]
     2 code_value = f8
     2 requirements[*]
       3 age_from_minutes = i4
       3 age_to_minutes = i4
       3 minimum_volume = f8
       3 priority_code_value = f8
       3 container_code_value = f8
       3 coll_class_code_value = f8
       3 spec_hand_code_value = f8
       3 aliquot_ind = i2
       3 aliquot_route_sequence = i4
       3 aliquot_seq = i4
       3 extra_labels = i4
       3 aliquot_info_qual[*]
         4 coll_info_seq = i4
         4 aliquot_seq = i4
         4 min_vol = f8
         4 min_vol_units = vc
         4 units_cd = f8
         4 spec_cntnr_cd = f8
         4 coll_class_cd = f8
         4 spec_hndl_cd = f8
         4 net_ind = i2
         4 storage_temp_cd = f8
         4 aliquot_seq_f8 = f8
         4 coll_info_seq_f8 = f8
       3 aliquot_seq_f8 = f8
       3 alt_containers[*]
         4 min_volume = f8
         4 spec_container_cd = f8
         4 collection_class_cd = f8
         4 special_handlding_cd = f8
 ) WITH protect
 RECORD temp1(
   1 list[*]
     2 catalog_cd = f8
     2 primary_mnemonic = c100
     2 resource_route_lvl = i4
 ) WITH protect
 RECORD temp2(
   1 list[*]
     2 catalog_cd = f8
     2 primary_mnemonic = c100
     2 resource_route_lvl = i4
     2 copy_mode_match_on_all_row = i2
 ) WITH protect
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
 DECLARE glb_catalog_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"
   ))
 DECLARE glb_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE ap_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"AP"))
 DECLARE bb_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"BB"))
 DECLARE hla_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLA"))
 DECLARE main_sr_cnt = i4 WITH protect, noconstant(size(request->service_resources,5))
 DECLARE main_req_cnt = i4 WITH protect, noconstant(0)
 DECLARE main_sr_cnt_without_all_row = i4 WITH protect, noconstant(0)
 DECLARE all_coll_reqs_match = i2 WITH protect, noconstant(0)
 DECLARE alterlist_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp1_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp2_cnt = i4 WITH protect, noconstant(0)
 DECLARE found_idx = i4 WITH protect, noconstant(0)
 DECLARE single_match = i2 WITH protect, noconstant(0)
 DECLARE clist_cnt = i2 WITH protect, noconstant(0)
 DECLARE aliquot_cnt = i4 WITH protect, noconstant(0)
 DECLARE alternate_cnt = i4 WITH protect, noconstant(0)
 IF (main_sr_cnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->coll_reqs_ind=1))
  DECLARE found_coll_req_for_non_all_row = i2 WITH protect, noconstant(0)
  FOR (x = 1 TO main_sr_cnt)
    IF ((request->service_resources[x].code_value > 0))
     SET main_req_cnt = size(request->service_resources[x].requirements,5)
     IF (main_req_cnt > 0)
      SET found_coll_req_for_non_all_row = 1
      SET x = (main_sr_cnt+ 1)
     ENDIF
    ENDIF
  ENDFOR
  IF (found_coll_req_for_non_all_row=0)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (s = 1 TO main_sr_cnt)
   IF ((request->service_resources[s].code_value != 0))
    SET main_sr_cnt_without_all_row = (main_sr_cnt_without_all_row+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(temp1->list,20)
 IF ((request->activity_type="GLB"))
  DECLARE glb_oc_parse = vc WITH protect, noconstant(concat(
    "oc.catalog_type_cd = glb_catalog_type_cd"," and oc.activity_type_cd = glb_activity_type_cd",
    " and oc.catalog_cd != request->catalog_cd"," and oc.active_ind  = 1"))
  IF ((request->return_all_subtypes_ind != 1))
   SET glb_oc_parse = concat(glb_oc_parse,
    " and oc.activity_subtype_cd = request->activity_subtype_cd")
  ENDIF
  SELECT INTO "nl:"
   FROM order_catalog oc
   WHERE parser(glb_oc_parse)
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 20)
     stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
    ENDIF
    temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc.catalog_cd, temp1->list[
    temp1_cnt].primary_mnemonic = oc.primary_mnemonic,
    temp1->list[temp1_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="AP"))
  DECLARE ap_oc_parse = vc WITH protect, noconstant(concat("oc.catalog_type_cd = glb_catalog_type_cd",
    " and oc.activity_type_cd = ap_activity_type_cd"," and oc.catalog_cd != request->catalog_cd",
    " and oc.active_ind  = 1"))
  IF ((request->return_all_subtypes_ind != 1))
   SET ap_oc_parse = concat(ap_oc_parse," and oc.activity_subtype_cd = request->activity_subtype_cd")
  ENDIF
  SELECT INTO "nl:"
   FROM order_catalog oc
   WHERE parser(ap_oc_parse)
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 20)
     stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
    ENDIF
    temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc.catalog_cd, temp1->list[
    temp1_cnt].primary_mnemonic = oc.primary_mnemonic,
    temp1->list[temp1_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="BB"))
  SELECT INTO "nl:"
   FROM order_catalog oc
   WHERE oc.catalog_type_cd=glb_catalog_type_cd
    AND oc.activity_type_cd=bb_activity_type_cd
    AND (oc.catalog_cd != request->catalog_cd)
    AND oc.active_ind=1
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 20)
     stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
    ENDIF
    temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc.catalog_cd, temp1->list[
    temp1_cnt].primary_mnemonic = oc.primary_mnemonic,
    temp1->list[temp1_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="HLA"))
  DECLARE hla_oc_parse = vc WITH protect, noconstant(concat(
    "oc.catalog_type_cd = glb_catalog_type_cd"," and oc.activity_type_cd = hla_activity_type_cd",
    " and oc.catalog_cd != request->catalog_cd"," and oc.active_ind = 1"))
  IF ((request->return_all_subtypes_ind != 1))
   SET hla_oc_parse = concat(hla_oc_parse,
    " and oc.activity_subtype_cd = request->activity_subtype_cd")
  ENDIF
  SELECT INTO "nl:"
   FROM order_catalog oc
   WHERE parser(hla_oc_parse)
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 20)
     stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
    ENDIF
    temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc.catalog_cd, temp1->list[
    temp1_cnt].primary_mnemonic = oc.primary_mnemonic,
    temp1->list[temp1_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="HLX"))
  DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
  DECLARE cyg_code = f8 WITH protect, noconstant(0.0)
  DECLARE mdx_code = f8 WITH protect, noconstant(0.0)
  DECLARE spc_code = f8 WITH protect, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
  SET stat = uar_get_meaning_by_codeset(106,"CYG",1,cyg_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_MDX",1,mdx_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_SPECIMEN",1,spc_code)
  IF ((request->return_all_subtypes_ind=1))
   SELECT INTO "nl:"
    FROM order_catalog oc1,
     order_catalog oc2
    WHERE (oc1.catalog_cd=request->catalog_cd)
     AND oc2.catalog_type_cd=glb_catalog_type_cd
     AND oc2.activity_type_cd IN (hlx_code, cyg_code)
     AND oc2.activity_subtype_cd IN (mdx_code, spc_code, 0, null)
     AND oc2.active_ind=1
     AND oc2.catalog_cd != oc1.catalog_cd
     AND oc2.orderable_type_flag=oc1.orderable_type_flag
    DETAIL
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 20)
      stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
     ENDIF
     temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc2.catalog_cd, temp1->list[
     temp1_cnt].primary_mnemonic = oc2.primary_mnemonic,
     temp1->list[temp1_cnt].resource_route_lvl = oc2.resource_route_lvl
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM order_catalog oc1,
     order_catalog oc2
    WHERE (oc1.catalog_cd=request->catalog_cd)
     AND oc2.catalog_type_cd=glb_catalog_type_cd
     AND oc2.activity_type_cd=oc1.activity_type_cd
     AND oc2.activity_subtype_cd IN (mdx_code, spc_code, 0, null)
     AND oc2.catalog_cd != oc1.catalog_cd
     AND oc2.orderable_type_flag=oc1.orderable_type_flag
     AND oc2.active_ind=1
    DETAIL
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 20)
      stat = alterlist(temp1->list,(temp1_cnt+ 20)), alterlist_cnt = 1
     ENDIF
     temp1_cnt = (temp1_cnt+ 1), temp1->list[temp1_cnt].catalog_cd = oc2.catalog_cd, temp1->list[
     temp1_cnt].primary_mnemonic = oc2.primary_mnemonic,
     temp1->list[temp1_cnt].resource_route_lvl = oc2.resource_route_lvl
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(temp1->list,temp1_cnt)
 SET stat = alterlist(temp2->list,20)
 SET alterlist_cnt = 0
 FOR (t1 = 1 TO temp1_cnt)
   DECLARE hold_coll_meth = f8 WITH protect, noconstant(0.0)
   DECLARE hold_acc_class = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM procedure_specimen_type pst
    WHERE (pst.catalog_cd=temp1->list[t1].catalog_cd)
     AND (pst.specimen_type_cd=request->specimen_type_cd)
    DETAIL
     hold_coll_meth = pst.default_collection_method_cd, hold_acc_class = pst.accession_class_cd
    WITH nocounter
   ;end select
   IF (((curqual=0
    AND (request->coll_reqs_ind=0)) OR (curqual=1
    AND (request->coll_reqs_ind=1)
    AND (hold_coll_meth=request->collection_method_cd)
    AND (hold_acc_class=request->accession_class_cd))) )
    SET alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 20)
     SET stat = alterlist(temp2->list,(temp2_cnt+ 20))
     SET alterlist_cnt = 1
    ENDIF
    SET temp2_cnt = (temp2_cnt+ 1)
    SET temp2->list[temp2_cnt].catalog_cd = temp1->list[t1].catalog_cd
    SET temp2->list[temp2_cnt].primary_mnemonic = temp1->list[t1].primary_mnemonic
    SET temp2->list[temp2_cnt].resource_route_lvl = temp1->list[t1].resource_route_lvl
   ELSEIF (curqual=1
    AND (request->coll_reqs_ind=0)
    AND (hold_coll_meth=request->collection_method_cd)
    AND (hold_acc_class=request->accession_class_cd))
    DECLARE coll_reqs_exist = i2 WITH protect, noconstant(0)
    FOR (x = 1 TO main_sr_cnt)
      IF ((request->service_resources[x].code_value > 0))
       SELECT INTO "nl:"
        FROM collection_info_qualifiers ciq
        WHERE (ciq.catalog_cd=temp1->list[t1].catalog_cd)
         AND (ciq.specimen_type_cd=request->specimen_type_cd)
         AND (ciq.service_resource_cd=request->service_resources[x].code_value)
        DETAIL
         coll_reqs_exist = 1
        WITH nocounter
       ;end select
       IF (coll_reqs_exist=1)
        SET x = (main_sr_cnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
    IF (coll_reqs_exist=0)
     DECLARE req_cnt = i4 WITH protect, noconstant(0)
     SET stat = initrec(oc)
     SET stat = alterlist(oc->sr_list,1)
     SELECT INTO "nl:"
      FROM collection_info_qualifiers ciq
      WHERE (ciq.catalog_cd=temp1->list[t1].catalog_cd)
       AND (ciq.specimen_type_cd=request->specimen_type_cd)
       AND ciq.service_resource_cd=0
      DETAIL
       req_cnt = (req_cnt+ 1), stat = alterlist(oc->sr_list[1].requirements,req_cnt), oc->sr_list[1].
       requirements[req_cnt].age_from_minutes = ciq.age_from_minutes,
       oc->sr_list[1].requirements[req_cnt].age_to_minutes = ciq.age_to_minutes, oc->sr_list[1].
       requirements[req_cnt].minimum_volume = ciq.min_vol, oc->sr_list[1].requirements[req_cnt].
       priority_code_value = ciq.collection_priority_cd,
       oc->sr_list[1].requirements[req_cnt].container_code_value = ciq.spec_cntnr_cd, oc->sr_list[1].
       requirements[req_cnt].coll_class_code_value = ciq.coll_class_cd, oc->sr_list[1].requirements[
       req_cnt].spec_hand_code_value = ciq.spec_hndl_cd,
       oc->sr_list[1].requirements[req_cnt].aliquot_ind = ciq.aliquot_ind, oc->sr_list[1].
       requirements[req_cnt].aliquot_route_sequence = ciq.aliquot_route_sequence, oc->sr_list[1].
       requirements[req_cnt].aliquot_seq_f8 = ciq.aliquot_seq,
       oc->sr_list[1].requirements[req_cnt].extra_labels = ciq.additional_labels
      WITH nocounter
     ;end select
     SET found_idx = 0
     FOR (s1 = 1 TO main_sr_cnt)
       IF ((request->service_resources[s1].code_value=0))
        SET found_idx = s1
        SET s1 = (main_sr_cnt+ 1)
       ENDIF
     ENDFOR
     SET s1 = found_idx
     SET s2 = 1
     SET main_req_cnt = size(request->service_resources[s1].requirements,5)
     SET req_cnt = size(oc->sr_list[s2].requirements,5)
     IF (((main_req_cnt=0) OR (req_cnt=0)) )
      SET all_coll_reqs_match = 0
     ELSE
      SET all_coll_reqs_match = 1
      FOR (r1 = 1 TO main_req_cnt)
        SET single_match = 0
        FOR (r2 = 1 TO req_cnt)
          IF ((request->service_resources[s1].requirements[r1].age_from_minutes=oc->sr_list[s2].
          requirements[r2].age_from_minutes)
           AND (request->service_resources[s1].requirements[r1].age_to_minutes=oc->sr_list[s2].
          requirements[r2].age_to_minutes)
           AND (request->service_resources[s1].requirements[r1].minimum_volume=oc->sr_list[s2].
          requirements[r2].minimum_volume)
           AND (request->service_resources[s1].requirements[r1].priority_code_value=oc->sr_list[s2].
          requirements[r2].priority_code_value)
           AND (request->service_resources[s1].requirements[r1].container_code_value=oc->sr_list[s2].
          requirements[r2].container_code_value)
           AND (request->service_resources[s1].requirements[r1].coll_class_code_value=oc->sr_list[s2]
          .requirements[r2].coll_class_code_value)
           AND (request->service_resources[s1].requirements[r1].spec_hand_code_value=oc->sr_list[s2].
          requirements[r2].spec_hand_code_value))
           SET single_match = 1
           SET r2 = (req_cnt+ 1)
          ENDIF
        ENDFOR
        IF (single_match=0)
         SET all_coll_reqs_match = 0
         SET r1 = (main_req_cnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (all_coll_reqs_match=1)
      SET alterlist_cnt = (alterlist_cnt+ 1)
      IF (alterlist_cnt > 20)
       SET stat = alterlist(temp2->list,(temp2_cnt+ 20))
       SET alterlist_cnt = 1
      ENDIF
      SET temp2_cnt = (temp2_cnt+ 1)
      SET temp2->list[temp2_cnt].catalog_cd = temp1->list[t1].catalog_cd
      SET temp2->list[temp2_cnt].primary_mnemonic = temp1->list[t1].primary_mnemonic
      SET temp2->list[temp2_cnt].resource_route_lvl = temp1->list[t1].resource_route_lvl
      SET temp2->list[temp2_cnt].copy_mode_match_on_all_row = 1
     ENDIF
    ENDIF
    SET stat = alterlist(oc->sr_list,0)
   ENDIF
 ENDFOR
 SET stat = alterlist(temp2->list,temp2_cnt)
 IF (temp2_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp2->list,temp2_cnt)
 SET stat = alterlist(reply->clist,20)
 SET alterlist_cnt = 0
 FOR (t2 = 1 TO temp2_cnt)
   DECLARE sr_cnt = i4 WITH protect, noconstant(0)
   SET stat = initrec(oc)
   IF ((temp2->list[t2].resource_route_lvl=1))
    SELECT INTO "nl:"
     FROM orc_resource_list orl,
      code_value cv
     PLAN (orl
      WHERE (orl.catalog_cd=temp2->list[t2].catalog_cd)
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
     DETAIL
      sr_cnt = (sr_cnt+ 1), stat = alterlist(oc->sr_list,sr_cnt), oc->sr_list[sr_cnt].code_value =
      orl.service_resource_cd
     WITH nocounter
    ;end select
   ELSEIF ((temp2->list[t2].resource_route_lvl=2))
    DECLARE already_in_list = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM profile_task_r ptr,
      assay_resource_list asl,
      code_value cv
     PLAN (ptr
      WHERE (ptr.catalog_cd=temp2->list[t2].catalog_cd)
       AND ptr.active_ind=1)
      JOIN (asl
      WHERE asl.task_assay_cd=ptr.task_assay_cd
       AND asl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=asl.service_resource_cd
       AND cv.active_ind=1)
     DETAIL
      already_in_list = 0
      FOR (x = 1 TO sr_cnt)
        IF ((oc->sr_list[x].code_value=asl.service_resource_cd))
         already_in_list = 1, x = (sr_cnt+ 1)
        ENDIF
      ENDFOR
      IF (already_in_list=0)
       sr_cnt = (sr_cnt+ 1), stat = alterlist(oc->sr_list,sr_cnt), oc->sr_list[sr_cnt].code_value =
       asl.service_resource_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (main_sr_cnt > main_sr_cnt_without_all_row)
    SET sr_cnt = (sr_cnt+ 1)
    SET stat = alterlist(oc->sr_list,sr_cnt)
    SET oc->sr_list[sr_cnt].code_value = 0.0
   ENDIF
   DECLARE all_serv_res_match = i2 WITH protect, noconstant(1)
   FOR (s1 = 1 TO main_sr_cnt)
     SET single_match = 0
     FOR (s2 = 1 TO sr_cnt)
       IF ((oc->sr_list[s2].code_value=request->service_resources[s1].code_value))
        SET single_match = 1
        SET s2 = (sr_cnt+ 1)
       ENDIF
     ENDFOR
     IF (single_match=0)
      SET all_serv_res_match = 0
      SET s1 = (main_sr_cnt+ 1)
     ENDIF
   ENDFOR
   IF (all_serv_res_match=1)
    SET req_cnt = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = sr_cnt),
      collection_info_qualifiers ciq,
      aliquot_info_qualifiers aiq,
      alt_collection_info aci
     PLAN (d)
      JOIN (ciq
      WHERE (ciq.catalog_cd=temp2->list[t2].catalog_cd)
       AND (ciq.specimen_type_cd=request->specimen_type_cd)
       AND (ciq.service_resource_cd=oc->sr_list[d.seq].code_value))
      JOIN (aiq
      WHERE aiq.catalog_cd=outerjoin(ciq.catalog_cd)
       AND aiq.specimen_type_cd=outerjoin(ciq.specimen_type_cd)
       AND aiq.coll_info_seq=outerjoin(ciq.aliquot_seq))
      JOIN (aci
      WHERE aci.catalog_cd=outerjoin(ciq.catalog_cd)
       AND aci.specimen_type_cd=outerjoin(ciq.specimen_type_cd)
       AND aci.coll_info_seq=outerjoin(ciq.sequence))
     ORDER BY ciq.service_resource_cd, ciq.sequence, aiq.aliquot_seq,
      aci.alt_collection_info_id
     HEAD ciq.service_resource_cd
      req_cnt = 0
     HEAD ciq.sequence
      req_cnt = (req_cnt+ 1), stat = alterlist(oc->sr_list[d.seq].requirements,req_cnt), oc->sr_list[
      d.seq].requirements[req_cnt].age_from_minutes = ciq.age_from_minutes,
      oc->sr_list[d.seq].requirements[req_cnt].age_to_minutes = ciq.age_to_minutes, oc->sr_list[d.seq
      ].requirements[req_cnt].minimum_volume = ciq.min_vol, oc->sr_list[d.seq].requirements[req_cnt].
      priority_code_value = ciq.collection_priority_cd,
      oc->sr_list[d.seq].requirements[req_cnt].container_code_value = ciq.spec_cntnr_cd, oc->sr_list[
      d.seq].requirements[req_cnt].coll_class_code_value = ciq.coll_class_cd, oc->sr_list[d.seq].
      requirements[req_cnt].spec_hand_code_value = ciq.spec_hndl_cd,
      oc->sr_list[d.seq].requirements[req_cnt].aliquot_ind = ciq.aliquot_ind, oc->sr_list[d.seq].
      requirements[req_cnt].aliquot_route_sequence = ciq.aliquot_route_sequence, oc->sr_list[d.seq].
      requirements[req_cnt].aliquot_seq_f8 = ciq.aliquot_seq,
      oc->sr_list[d.seq].requirements[req_cnt].extra_labels = ciq.additional_labels, aliquot_cnt = 0,
      alternate_cnt = 0
     HEAD aiq.aliquot_seq
      IF (ciq.aliquot_ind=1)
       aliquot_cnt = (aliquot_cnt+ 1), stat = alterlist(oc->sr_list[d.seq].requirements[req_cnt].
        aliquot_info_qual,aliquot_cnt), oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[
       aliquot_cnt].coll_info_seq = aiq.coll_info_seq,
       oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].aliquot_seq_f8 = aiq
       .aliquot_seq, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].min_vol
        = aiq.min_vol, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].
       min_vol_units = aiq.min_vol_units,
       oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].units_cd = aiq
       .units_cd, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].
       spec_cntnr_cd = aiq.spec_cntnr_cd, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[
       aliquot_cnt].coll_class_cd = aiq.coll_class_cd,
       oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].spec_hndl_cd = aiq
       .spec_hndl_cd, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].net_ind
        = aiq.net_ind, oc->sr_list[d.seq].requirements[req_cnt].aliquot_info_qual[aliquot_cnt].
       storage_temp_cd = aiq.storage_temp_cd
      ENDIF
     HEAD aci.alt_collection_info_id
      IF (aci.alt_collection_info_id > 0)
       alternate_cnt = (alternate_cnt+ 1), stat = alterlist(oc->sr_list[d.seq].requirements[req_cnt].
        alt_containers,alternate_cnt), oc->sr_list[d.seq].requirements[req_cnt].alt_containers[
       alternate_cnt].min_volume = aci.min_vol_amt,
       oc->sr_list[d.seq].requirements[req_cnt].alt_containers[alternate_cnt].spec_container_cd = aci
       .spec_cntnr_cd, oc->sr_list[d.seq].requirements[req_cnt].alt_containers[alternate_cnt].
       collection_class_cd = aci.coll_class_cd, oc->sr_list[d.seq].requirements[req_cnt].
       alt_containers[alternate_cnt].special_handlding_cd = aci.spec_hndl_cd
      ENDIF
     WITH nocounter
    ;end select
    SET all_coll_reqs_match = 1
    IF ((request->coll_reqs_ind=1))
     FOR (s1 = 1 TO main_sr_cnt)
       SET found_idx = 0
       FOR (s2 = 1 TO sr_cnt)
         IF ((request->service_resources[s1].code_value=oc->sr_list[s2].code_value))
          SET found_idx = s2
          SET s2 = (sr_cnt+ 1)
         ENDIF
       ENDFOR
       SET s2 = found_idx
       SET main_req_cnt = size(request->service_resources[s1].requirements,5)
       SET req_cnt = size(oc->sr_list[s2].requirements,5)
       IF (main_req_cnt=0
        AND req_cnt=0)
        SET all_coll_reqs_match = 1
       ELSE
        IF (req_cnt > 0
         AND main_req_cnt=req_cnt)
         FOR (r1 = 1 TO main_req_cnt)
           SET single_match = 0
           FOR (r2 = 1 TO req_cnt)
             IF ((request->service_resources[s1].requirements[r1].age_from_minutes=oc->sr_list[s2].
             requirements[r2].age_from_minutes)
              AND (request->service_resources[s1].requirements[r1].age_to_minutes=oc->sr_list[s2].
             requirements[r2].age_to_minutes)
              AND (request->service_resources[s1].requirements[r1].minimum_volume=oc->sr_list[s2].
             requirements[r2].minimum_volume)
              AND (request->service_resources[s1].requirements[r1].priority_code_value=oc->sr_list[s2
             ].requirements[r2].priority_code_value)
              AND (request->service_resources[s1].requirements[r1].container_code_value=oc->sr_list[
             s2].requirements[r2].container_code_value)
              AND (request->service_resources[s1].requirements[r1].coll_class_code_value=oc->sr_list[
             s2].requirements[r2].coll_class_code_value)
              AND (request->service_resources[s1].requirements[r1].spec_hand_code_value=oc->sr_list[
             s2].requirements[r2].spec_hand_code_value))
              SET single_match = 1
              SET r2 = (req_cnt+ 1)
             ENDIF
           ENDFOR
           IF (single_match=0)
            SET all_coll_reqs_match = 0
            SET r1 = (main_req_cnt+ 1)
           ENDIF
         ENDFOR
         IF (all_coll_reqs_match=0)
          SET s1 = (main_sr_cnt+ 1)
         ENDIF
        ELSE
         SET all_coll_reqs_match = 0
         SET s1 = (main_sr_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (all_coll_reqs_match=1)
     SET alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 20)
      SET stat = alterlist(reply->clist,(clist_cnt+ 20))
      SET alterlist_cnt = 1
     ENDIF
     SET clist_cnt = (clist_cnt+ 1)
     SET reply->clist[clist_cnt].catalog_cd = temp2->list[t2].catalog_cd
     SET reply->clist[clist_cnt].primary_mnemonic = temp2->list[t2].primary_mnemonic
     DECLARE oc_sr_cnt = i4 WITH protect, noconstant(size(oc->sr_list,5))
     SET stat = alterlist(reply->clist[clist_cnt].sr_list,oc_sr_cnt)
     FOR (sr1 = 1 TO oc_sr_cnt)
       SET reply->clist[clist_cnt].sr_list[sr1].code_value = oc->sr_list[sr1].code_value
       DECLARE oc_req_cnt = i4 WITH protect, noconstant(size(oc->sr_list[sr1].requirements,5))
       SET stat = alterlist(reply->clist[clist_cnt].sr_list[sr1].requirements,oc_req_cnt)
       FOR (req1 = 1 TO oc_req_cnt)
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].age_from_minutes = oc->sr_list[
         sr1].requirements[req1].age_from_minutes
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].age_to_minutes = oc->sr_list[sr1
         ].requirements[req1].age_to_minutes
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].minimum_volume = oc->sr_list[sr1
         ].requirements[req1].minimum_volume
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].priority_code_value = oc->
         sr_list[sr1].requirements[req1].priority_code_value
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].container_code_value = oc->
         sr_list[sr1].requirements[req1].container_code_value
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].coll_class_code_value = oc->
         sr_list[sr1].requirements[req1].coll_class_code_value
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].spec_hand_code_value = oc->
         sr_list[sr1].requirements[req1].spec_hand_code_value
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_ind = oc->sr_list[sr1].
         requirements[req1].aliquot_ind
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_route_sequence = oc->
         sr_list[sr1].requirements[req1].aliquot_route_sequence
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_seq_f8 = oc->sr_list[sr1
         ].requirements[req1].aliquot_seq_f8
         SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].extra_labels = oc->sr_list[sr1].
         requirements[req1].extra_labels
         SET aliquot_cnt = size(oc->sr_list[sr1].requirements[req1].aliquot_info_qual,5)
         SET stat = alterlist(reply->clist[clist_cnt].sr_list[sr1].requirements[req1].
          aliquot_info_qual,aliquot_cnt)
         FOR (a = 1 TO aliquot_cnt)
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           coll_info_seq_f8 = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           coll_info_seq_f8
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           aliquot_seq_f8 = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].aliquot_seq_f8
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].min_vol
            = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].min_vol
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           min_vol_units = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].min_vol_units
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].units_cd
            = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].units_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           spec_cntnr_cd = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].spec_cntnr_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           coll_class_cd = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].coll_class_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           spec_hndl_cd = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].spec_hndl_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].net_ind
            = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].net_ind
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].aliquot_info_qual[a].
           storage_temp_cd = oc->sr_list[sr1].requirements[req1].aliquot_info_qual[a].storage_temp_cd
         ENDFOR
         SET alternate_cnt = size(oc->sr_list[sr1].requirements[req1].alt_containers,5)
         SET stat = alterlist(reply->clist[clist_cnt].sr_list[sr1].requirements[req1].alt_containers,
          alternate_cnt)
         FOR (b = 1 TO alternate_cnt)
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].alt_containers[b].min_volume
            = oc->sr_list[sr1].requirements[req1].alt_containers[b].min_volume
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].alt_containers[b].
           spec_container_cd = oc->sr_list[sr1].requirements[req1].alt_containers[b].
           spec_container_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].alt_containers[b].
           collection_class_cd = oc->sr_list[sr1].requirements[req1].alt_containers[b].
           collection_class_cd
           SET reply->clist[clist_cnt].sr_list[sr1].requirements[req1].alt_containers[b].
           special_handlding_cd = oc->sr_list[sr1].requirements[req1].alt_containers[b].
           special_handlding_cd
         ENDFOR
       ENDFOR
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->clist,clist_cnt)
#exit_script
 CALL bedexitscript(0)
END GO
