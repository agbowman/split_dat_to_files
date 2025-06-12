CREATE PROGRAM bed_get_oc_coll_req:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 catalog_cd = f8
    1 specimen_type_cd = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 catalog
      2 code_value = f8
      2 display = vc
      2 mean = vc
    1 specimen_type
      2 code_value = f8
      2 display = vc
      2 mean = vc
    1 accession_class
      2 code_value = f8
      2 display = vc
      2 mean = vc
    1 collection_method
      2 code_value = f8
      2 display = vc
      2 mean = vc
    1 srlist[*]
      2 code_value = f8
      2 display = vc
      2 mean = vc
      2 crlist[*]
        3 age_from_minutes = i4
        3 age_to_minutes = i4
        3 collection_priority
          4 code_value = f8
          4 display = vc
          4 mean = vc
        3 minimum_volume = f8
        3 container
          4 code_value = f8
          4 display = vc
          4 mean = vc
        3 collection_class
          4 code_value = f8
          4 display = vc
          4 mean = vc
        3 special_handling
          4 code_value = f8
          4 display = vc
          4 mean = vc
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
      2 collection_classes[*]
        3 code_value = f8
        3 display = vc
        3 mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD temp(
   1 sr_list[*]
     2 code_value = f8
     2 display = c40
     2 mean = vc
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
 DECLARE sr_cnt = i4 WITH protect, noconstant(0)
 DECLARE resource_route_lvl = i4 WITH protect, noconstant(0)
 DECLARE orderable_type_flag = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->catalog_cd)
   AND cv.active_ind=1
  DETAIL
   reply->catalog.code_value = cv.code_value, reply->catalog.display = cv.display, reply->catalog.
   mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 001 - Failed to retrieve requested catalog code.")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->specimen_type_cd)
   AND cv.active_ind=1
  DETAIL
   reply->specimen_type.code_value = cv.code_value, reply->specimen_type.display = cv.display, reply
   ->specimen_type.mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 002 - Failed to retrieve requested specimen type code.")
 SELECT INTO "nl:"
  FROM procedure_specimen_type pst,
   code_value cv1,
   code_value cv2
  PLAN (pst
   WHERE (pst.catalog_cd=request->catalog_cd)
    AND (pst.specimen_type_cd=request->specimen_type_cd))
   JOIN (cv1
   WHERE cv1.code_value=pst.accession_class_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=pst.default_collection_method_cd
    AND cv2.active_ind=1)
  DETAIL
   reply->accession_class.code_value = cv1.code_value, reply->accession_class.display = cv1.display,
   reply->accession_class.mean = cv1.cdf_meaning,
   reply->collection_method.code_value = cv2.code_value, reply->collection_method.display = cv2
   .display, reply->collection_method.mean = cv2.cdf_meaning
  WITH nocounter
 ;end select
 CALL bederrorcheck(
  "Error 003 - Failed to retrieve accession class or collection method information.")
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE (oc.catalog_cd=request->catalog_cd)
  DETAIL
   resource_route_lvl = oc.resource_route_lvl, orderable_type_flag = oc.orderable_type_flag
  WITH nocounter
 ;end select
 IF (resource_route_lvl=1)
  SELECT INTO "nl:"
   FROM orc_resource_list orl,
    code_value cv
   PLAN (orl
    WHERE (orl.catalog_cd=request->catalog_cd)
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_set=221
     AND cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   DETAIL
    sr_cnt = (sr_cnt+ 1), stat = alterlist(temp->sr_list,sr_cnt), temp->sr_list[sr_cnt].code_value =
    orl.service_resource_cd,
    temp->sr_list[sr_cnt].display = cv.display, temp->sr_list[sr_cnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 004 - Failed to retrieve service resource information.")
 ELSEIF (resource_route_lvl=2)
  DECLARE already_in_list = i2 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (ptr
    WHERE (ptr.catalog_cd=request->catalog_cd)
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_set=221
     AND cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
   DETAIL
    already_in_list = 0
    FOR (x = 1 TO sr_cnt)
      IF ((temp->sr_list[x].code_value=asl.service_resource_cd))
       already_in_list = 1, x = (sr_cnt+ 1)
      ENDIF
    ENDFOR
    IF (already_in_list=0)
     sr_cnt = (sr_cnt+ 1), stat = alterlist(temp->sr_list,sr_cnt), temp->sr_list[sr_cnt].code_value
      = asl.service_resource_cd,
     temp->sr_list[sr_cnt].display = cv.display, temp->sr_list[sr_cnt].mean = cv.cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 005 - Failed to retrieve service resource information at DTA level.")
 ENDIF
 IF (((orderable_type_flag=6) OR (((resource_route_lvl=1) OR (resource_route_lvl=2)) )) )
  SET sr_cnt = (sr_cnt+ 1)
  SET stat = alterlist(temp->sr_list,sr_cnt)
  SET temp->sr_list[sr_cnt].code_value = 0.0
  SET temp->sr_list[sr_cnt].display = " "
  SET temp->sr_list[sr_cnt].mean = " "
 ENDIF
 SET stat = alterlist(reply->srlist,sr_cnt)
 IF (sr_cnt=0)
  GO TO exit_script
 ENDIF
 FOR (s = 1 TO sr_cnt)
   SET reply->srlist[s].code_value = temp->sr_list[s].code_value
   SET reply->srlist[s].display = temp->sr_list[s].display
   SET reply->srlist[s].mean = temp->sr_list[s].mean
   SET stat = alterlist(reply->srlist[s].crlist,5)
   DECLARE alterlist_cnt = i4 WITH protect, noconstant(0)
   DECLARE crlist_cnt = i4 WITH protect, noconstant(0)
   DECLARE aliquot_cnt = i4 WITH protect, noconstant(0)
   DECLARE alternate_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM collection_info_qualifiers ciq,
     code_value cv1,
     code_value cv2,
     code_value cv3,
     code_value cv4,
     aliquot_info_qualifiers aiq,
     alt_collection_info aci
    PLAN (ciq
     WHERE (ciq.catalog_cd=request->catalog_cd)
      AND (ciq.specimen_type_cd=request->specimen_type_cd)
      AND (ciq.service_resource_cd=temp->sr_list[s].code_value))
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(ciq.collection_priority_cd)
      AND cv1.active_ind=outerjoin(1))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(ciq.spec_cntnr_cd)
      AND cv2.active_ind=outerjoin(1))
     JOIN (cv3
     WHERE cv3.code_value=outerjoin(ciq.coll_class_cd)
      AND cv3.active_ind=outerjoin(1))
     JOIN (cv4
     WHERE cv4.code_value=outerjoin(ciq.spec_hndl_cd)
      AND cv4.active_ind=outerjoin(1))
     JOIN (aiq
     WHERE aiq.catalog_cd=outerjoin(ciq.catalog_cd)
      AND aiq.specimen_type_cd=outerjoin(ciq.specimen_type_cd)
      AND aiq.coll_info_seq=outerjoin(ciq.aliquot_seq))
     JOIN (aci
     WHERE aci.catalog_cd=outerjoin(ciq.catalog_cd)
      AND aci.specimen_type_cd=outerjoin(ciq.specimen_type_cd)
      AND aci.coll_info_seq=outerjoin(ciq.sequence))
    ORDER BY ciq.sequence, ciq.age_from_minutes, aiq.aliquot_seq,
     aci.alt_collection_info_id
    HEAD ciq.sequence
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 5)
      stat = alterlist(reply->srlist[s].crlist,(crlist_cnt+ 5)), alterlist_cnt = 1
     ENDIF
     crlist_cnt = (crlist_cnt+ 1), reply->srlist[s].crlist[crlist_cnt].age_from_minutes = ciq
     .age_from_minutes, reply->srlist[s].crlist[crlist_cnt].age_to_minutes = ciq.age_to_minutes,
     reply->srlist[s].crlist[crlist_cnt].collection_priority.code_value = cv1.code_value, reply->
     srlist[s].crlist[crlist_cnt].collection_priority.display = cv1.display, reply->srlist[s].crlist[
     crlist_cnt].collection_priority.mean = cv1.cdf_meaning,
     reply->srlist[s].crlist[crlist_cnt].minimum_volume = ciq.min_vol, reply->srlist[s].crlist[
     crlist_cnt].container.code_value = cv2.code_value, reply->srlist[s].crlist[crlist_cnt].container
     .display = cv2.display,
     reply->srlist[s].crlist[crlist_cnt].container.mean = cv2.cdf_meaning, reply->srlist[s].crlist[
     crlist_cnt].collection_class.code_value = cv3.code_value, reply->srlist[s].crlist[crlist_cnt].
     collection_class.display = cv3.display,
     reply->srlist[s].crlist[crlist_cnt].collection_class.mean = cv3.cdf_meaning, reply->srlist[s].
     crlist[crlist_cnt].special_handling.code_value = cv4.code_value, reply->srlist[s].crlist[
     crlist_cnt].special_handling.display = cv4.display,
     reply->srlist[s].crlist[crlist_cnt].special_handling.mean = cv4.cdf_meaning, reply->srlist[s].
     crlist[crlist_cnt].aliquot_ind = ciq.aliquot_ind, reply->srlist[s].crlist[crlist_cnt].
     aliquot_route_sequence = ciq.aliquot_route_sequence,
     reply->srlist[s].crlist[crlist_cnt].aliquot_seq_f8 = ciq.aliquot_seq, reply->srlist[s].crlist[
     crlist_cnt].extra_labels = ciq.additional_labels, aliquot_cnt = 0,
     alternate_cnt = 0
    HEAD aiq.aliquot_seq
     IF (ciq.aliquot_ind=1)
      aliquot_cnt = (aliquot_cnt+ 1), stat = alterlist(reply->srlist[s].crlist[crlist_cnt].
       aliquot_info_qual,aliquot_cnt), reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[
      aliquot_cnt].coll_info_seq_f8 = aiq.coll_info_seq,
      reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].aliquot_seq_f8 = aiq
      .aliquot_seq, reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].min_vol = aiq
      .min_vol, reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].min_vol_units =
      aiq.min_vol_units,
      reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].units_cd = aiq.units_cd,
      reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].spec_cntnr_cd = aiq
      .spec_cntnr_cd, reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].
      coll_class_cd = aiq.coll_class_cd,
      reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].spec_hndl_cd = aiq
      .spec_hndl_cd, reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].net_ind = aiq
      .net_ind, reply->srlist[s].crlist[crlist_cnt].aliquot_info_qual[aliquot_cnt].storage_temp_cd =
      aiq.storage_temp_cd
     ENDIF
    HEAD aci.alt_collection_info_id
     IF (aci.alt_collection_info_id > 0)
      alternate_cnt = (alternate_cnt+ 1), stat = alterlist(reply->srlist[s].crlist[crlist_cnt].
       alt_containers,alternate_cnt), reply->srlist[s].crlist[crlist_cnt].alt_containers[
      alternate_cnt].min_volume = aci.min_vol_amt,
      reply->srlist[s].crlist[crlist_cnt].alt_containers[alternate_cnt].spec_container_cd = aci
      .spec_cntnr_cd, reply->srlist[s].crlist[crlist_cnt].alt_containers[alternate_cnt].
      collection_class_cd = aci.coll_class_cd, reply->srlist[s].crlist[crlist_cnt].alt_containers[
      alternate_cnt].special_handlding_cd = aci.spec_hndl_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 006 - Failed to process service resources.")
   IF (crlist_cnt > 0)
    SET stat = alterlist(reply->srlist[s].crlist,crlist_cnt)
   ELSE
    SET stat = alterlist(reply->srlist[s].crlist,1)
    SET reply->srlist[s].crlist[1].age_from_minutes = 0
    SET reply->srlist[s].crlist[1].age_to_minutes = 78840000
    SET reply->srlist[s].crlist[1].collection_priority.code_value = 0.0
    SET reply->srlist[s].crlist[1].minimum_volume = 1.0
    SET reply->srlist[s].crlist[1].container.code_value = 0.0
    SET reply->srlist[s].crlist[1].collection_class.code_value = 0.0
    SET reply->srlist[s].crlist[1].special_handling.code_value = 0.0
    SET reply->srlist[s].crlist[1].aliquot_ind = 0
    SET reply->srlist[s].crlist[1].aliquot_route_sequence = 0
    SET reply->srlist[s].crlist[1].aliquot_seq_f8 = 0.0
    SET reply->srlist[s].crlist[1].extra_labels = 0
   ENDIF
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_coll_class_instr_reltn b,
     code_value cv
    PLAN (b
     WHERE (b.service_resource_cd=reply->srlist[s].code_value))
     JOIN (cv
     WHERE cv.code_value=b.collection_class_cd)
    DETAIL
     ccnt = (ccnt+ 1), stat = alterlist(reply->srlist[s].collection_classes,ccnt), reply->srlist[s].
     collection_classes[ccnt].code_value = b.collection_class_cd,
     reply->srlist[s].collection_classes[ccnt].display = cv.display, reply->srlist[s].
     collection_classes[ccnt].mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 007 - Failed to retrieve collection class information.")
 ENDFOR
#exit_script
 CALL bedexitscript(0)
END GO
