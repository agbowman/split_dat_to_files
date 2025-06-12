CREATE PROGRAM bed_ens_oc_coll_req:dba
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
 RECORD parent_container_seqs(
   1 aliquot_parent_seqs[*]
     2 coll_info_seq = f8
   1 alternate_parent_seqs[*]
     2 coll_info_seq = f8
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
 DECLARE clist_cnt = i4 WITH protect, constant(size(request->clist,5))
 DECLARE units_cd = f8 WITH protect, noconstant(0.0)
 DECLARE srlist_cnt = i4 WITH protect, noconstant(0)
 DECLARE crlist_cnt = i4 WITH protect, noconstant(0)
 DECLARE parent_seq = f8 WITH protect, noconstant(0.0)
 IF (clist_cnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=54
    AND cv.cdf_meaning="ML"
   DETAIL
    units_cd = cv.code_value
   WITH nocounter
  ;end select
  FOR (c = 1 TO clist_cnt)
    DELETE  FROM procedure_specimen_type pst
     WHERE (pst.catalog_cd=request->clist[c].catalog_cd)
      AND (pst.specimen_type_cd=request->clist[c].specimen_type_cd)
     WITH nocounter
    ;end delete
    INSERT  FROM procedure_specimen_type pst
     SET pst.catalog_cd = request->clist[c].catalog_cd, pst.specimen_type_cd = request->clist[c].
      specimen_type_cd, pst.default_collection_method_cd = request->collection_method_cd,
      pst.default_ind = null, pst.accession_class_cd = request->clist[c].accession_class_cd, pst
      .updt_applctx = reqinfo->updt_applctx,
      pst.updt_dt_tm = cnvtdatetime(curdate,curtime), pst.updt_id = reqinfo->updt_id, pst.updt_cnt =
      0,
      pst.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET srlist_cnt = size(request->clist[c].srlist,5)
    IF (srlist_cnt=0)
     GO TO exit_script
    ENDIF
    FOR (s = 1 TO srlist_cnt)
      DECLARE aliquot_parent_cnt = i4 WITH protect, noconstant(0)
      DECLARE alternate_parent_cnt = i4 WITH protect, noconstant(0)
      SELECT INTO "nl:"
       FROM collection_info_qualifiers ciq
       WHERE (ciq.catalog_cd=request->clist[c].catalog_cd)
        AND (ciq.specimen_type_cd=request->clist[c].specimen_type_cd)
        AND (ciq.service_resource_cd=request->clist[c].srlist[s].service_resource_cd)
       DETAIL
        IF (ciq.aliquot_seq > 0)
         aliquot_parent_cnt = (aliquot_parent_cnt+ 1), stat = alterlist(parent_container_seqs->
          aliquot_parent_seqs,aliquot_parent_cnt), parent_container_seqs->aliquot_parent_seqs[
         aliquot_parent_cnt].coll_info_seq = ciq.aliquot_seq
        ENDIF
       WITH nocounter
      ;end select
      IF (aliquot_parent_cnt > 0)
       FOR (a = 1 TO aliquot_parent_cnt)
         DELETE  FROM aliquot_info_qualifiers aiq
          WHERE (aiq.catalog_cd=request->clist[c].catalog_cd)
           AND (aiq.specimen_type_cd=request->clist[c].specimen_type_cd)
           AND (aiq.coll_info_seq=parent_container_seqs->aliquot_parent_seqs[a].coll_info_seq)
          WITH nocounter
         ;end delete
       ENDFOR
      ENDIF
      SELECT INTO "nl:"
       FROM collection_info_qualifiers ciq,
        alt_collection_info aci
       PLAN (ciq
        WHERE (ciq.catalog_cd=request->clist[c].catalog_cd)
         AND (ciq.specimen_type_cd=request->clist[c].specimen_type_cd)
         AND (ciq.service_resource_cd=request->clist[c].srlist[s].service_resource_cd))
        JOIN (aci
        WHERE aci.coll_info_seq=ciq.sequence)
       ORDER BY ciq.sequence
       HEAD ciq.sequence
        alternate_parent_cnt = (alternate_parent_cnt+ 1), stat = alterlist(parent_container_seqs->
         alternate_parent_seqs,alternate_parent_cnt), parent_container_seqs->alternate_parent_seqs[
        alternate_parent_cnt].coll_info_seq = ciq.sequence
       WITH nocounter
      ;end select
      IF (alternate_parent_cnt > 0)
       FOR (b = 1 TO alternate_parent_cnt)
         DELETE  FROM alt_collection_info aci
          WHERE (aci.catalog_cd=request->clist[c].catalog_cd)
           AND (aci.specimen_type_cd=request->clist[c].specimen_type_cd)
           AND (aci.coll_info_seq=parent_container_seqs->alternate_parent_seqs[b].coll_info_seq)
          WITH nocounter
         ;end delete
       ENDFOR
      ENDIF
      DELETE  FROM collection_info_qualifiers ciq
       WHERE (ciq.catalog_cd=request->clist[c].catalog_cd)
        AND (ciq.specimen_type_cd=request->clist[c].specimen_type_cd)
        AND (ciq.service_resource_cd=request->clist[c].srlist[s].service_resource_cd)
       WITH nocounter
      ;end delete
      SET crlist_cnt = size(request->clist[c].srlist[s].crlist,5)
      FOR (r = 1 TO crlist_cnt)
        SELECT INTO "nl:"
         next_ref_seq = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          parent_seq = cnvtreal(next_ref_seq)
         WITH format, nocounter
        ;end select
        DECLARE aliquot_seq = f8 WITH protect, noconstant(0.0)
        IF ((request->clist[c].srlist[s].crlist[r].aliquot_ind=1))
         SET aliquot_seq = parent_seq
        ELSE
         SET aliquot_seq = 0.0
        ENDIF
        INSERT  FROM collection_info_qualifiers ciq
         SET ciq.age_from_minutes = request->clist[c].srlist[s].crlist[r].age_from_minutes, ciq
          .age_to_minutes = request->clist[c].srlist[s].crlist[r].age_to_minutes, ciq.aliquot_ind =
          request->clist[c].srlist[s].crlist[r].aliquot_ind,
          ciq.aliquot_route_sequence = request->clist[c].srlist[s].crlist[r].aliquot_route_sequence,
          ciq.aliquot_seq = aliquot_seq, ciq.catalog_cd = request->clist[c].catalog_cd,
          ciq.coll_class_cd = request->clist[c].srlist[s].crlist[r].collection_class_cd, ciq.min_vol
           = request->clist[c].srlist[s].crlist[r].minimum_volume, ciq.min_vol_units = "ML",
          ciq.required_ind = null, ciq.sequence = parent_seq, ciq.spec_cntnr_cd = request->clist[c].
          srlist[s].crlist[r].container_cd,
          ciq.spec_hndl_cd = request->clist[c].srlist[s].crlist[r].special_handling_cd, ciq
          .species_cd = 0.0, ciq.specimen_type_cd = request->clist[c].specimen_type_cd,
          ciq.updt_applctx = reqinfo->updt_applctx, ciq.updt_cnt = 0, ciq.updt_dt_tm = cnvtdatetime(
           curdate,curtime),
          ciq.updt_id = reqinfo->updt_id, ciq.updt_task = reqinfo->updt_task, ciq.service_resource_cd
           = request->clist[c].srlist[s].service_resource_cd,
          ciq.optional_ind = 0, ciq.additional_labels = request->clist[c].srlist[s].crlist[r].
          extra_labels, ciq.units_cd = units_cd,
          ciq.collection_priority_cd = request->clist[c].srlist[s].crlist[r].collection_priority_cd
         WITH nocounter
        ;end insert
        IF ((request->clist[c].srlist[s].crlist[r].aliquot_ind=1))
         IF (size(request->clist[c].srlist[s].crlist[r].aliquot_info_qual,5) > 0)
          INSERT  FROM aliquot_info_qualifiers aiq,
            (dummyt d  WITH seq = size(request->clist[c].srlist[s].crlist[r].aliquot_info_qual,5))
           SET aiq.catalog_cd = request->clist[c].catalog_cd, aiq.specimen_type_cd = request->clist[c
            ].specimen_type_cd, aiq.coll_info_seq = parent_seq,
            aiq.aliquot_seq = seq(reference_seq,nextval), aiq.min_vol = request->clist[c].srlist[s].
            crlist[r].aliquot_info_qual[d.seq].min_vol, aiq.min_vol_units = request->clist[c].srlist[
            s].crlist[r].aliquot_info_qual[d.seq].min_vol_units,
            aiq.units_cd = request->clist[c].srlist[s].crlist[r].aliquot_info_qual[d.seq].units_cd,
            aiq.spec_cntnr_cd = request->clist[c].srlist[s].crlist[r].aliquot_info_qual[d.seq].
            spec_cntnr_cd, aiq.coll_class_cd = request->clist[c].srlist[s].crlist[r].
            aliquot_info_qual[d.seq].coll_class_cd,
            aiq.spec_hndl_cd = request->clist[c].srlist[s].crlist[r].aliquot_info_qual[d.seq].
            spec_hndl_cd, aiq.net_ind = request->clist[c].srlist[s].crlist[r].aliquot_info_qual[d.seq
            ].net_ind, aiq.storage_temp_cd = request->clist[c].srlist[s].crlist[r].aliquot_info_qual[
            d.seq].storage_temp_cd,
            aiq.updt_applctx = reqinfo->updt_applctx, aiq.updt_cnt = 0, aiq.updt_dt_tm = cnvtdatetime
            (curdate,curtime),
            aiq.updt_id = reqinfo->updt_id, aiq.updt_task = reqinfo->updt_task
           PLAN (d)
            JOIN (aiq)
           WITH nocounter
          ;end insert
         ENDIF
        ENDIF
        IF (size(request->clist[c].srlist[s].crlist[r].alt_containers,5) > 0)
         INSERT  FROM alt_collection_info aci,
           (dummyt d  WITH seq = size(request->clist[c].srlist[s].crlist[r].alt_containers,5))
          SET aci.alt_collection_info_id = seq(reference_seq,nextval), aci.catalog_cd = request->
           clist[c].catalog_cd, aci.coll_class_cd = request->clist[c].srlist[s].crlist[r].
           alt_containers[d.seq].collection_class_cd,
           aci.coll_info_seq = parent_seq, aci.min_vol_amt = request->clist[c].srlist[s].crlist[r].
           alt_containers[d.seq].min_volume, aci.specimen_type_cd = request->clist[c].
           specimen_type_cd,
           aci.spec_cntnr_cd = request->clist[c].srlist[s].crlist[r].alt_containers[d.seq].
           spec_container_cd, aci.spec_hndl_cd = request->clist[c].srlist[s].crlist[r].
           alt_containers[d.seq].special_handlding_cd, aci.updt_applctx = reqinfo->updt_applctx,
           aci.updt_cnt = 0, aci.updt_dt_tm = cnvtdatetime(curdate,curtime), aci.updt_id = reqinfo->
           updt_id,
           aci.updt_task = reqinfo->updt_task
          PLAN (d)
           JOIN (aci)
          WITH nocounter
         ;end insert
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
 ELSEIF ((request->action_flag=3))
  FOR (c = 1 TO clist_cnt)
    DELETE  FROM procedure_specimen_type pst
     WHERE (pst.catalog_cd=request->clist[c].catalog_cd)
      AND (pst.specimen_type_cd=request->clist[c].specimen_type_cd)
     WITH nocounter
    ;end delete
    DELETE  FROM aliquot_info_qualifiers aiq
     WHERE (aiq.catalog_cd=request->clist[c].catalog_cd)
      AND (aiq.specimen_type_cd=request->clist[c].specimen_type_cd)
    ;end delete
    DELETE  FROM alt_collection_info aci
     WHERE (aci.catalog_cd=request->clist[c].catalog_cd)
      AND (aci.specimen_type_cd=request->clist[c].specimen_type_cd)
     WITH nocounter
    ;end delete
    DELETE  FROM collection_info_qualifiers ciq
     WHERE (ciq.catalog_cd=request->clist[c].catalog_cd)
      AND (ciq.specimen_type_cd=request->clist[c].specimen_type_cd)
     WITH nocounter
    ;end delete
  ENDFOR
 ENDIF
#exit_script
 CALL bedexitscript(1)
END GO
