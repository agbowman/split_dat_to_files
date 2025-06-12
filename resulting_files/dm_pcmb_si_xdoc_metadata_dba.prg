CREATE PROGRAM dm_pcmb_si_xdoc_metadata:dba
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 si_xdoc_metadata_id = f8
     2 repo_document_unique_ident = vc
     2 home_community_ident = vc
     2 repository_unique_ident = vc
     2 doc_action_status_cd = f8
     2 doc_retr_status_cd = f8
     2 doc_retr_start_dt_tm = dq8
     2 doc_retr_complete_dt_tm = dq8
     2 media_object_identifier = vc
     2 media_object_version_nbr = i4
     2 related_si_xdoc_metadata_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 si_xdoc_metadata_id = f8
     2 repo_document_unique_ident = vc
     2 home_community_ident = vc
     2 repository_unique_ident = vc
     2 media_object_identifier = vc
     2 media_object_version_nbr = i4
 )
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 DECLARE lstatus = i4 WITH noconstant(0), private
 DECLARE fromidcnt = i4 WITH noconstant(0)
 DECLARE toidcnt = i4 WITH noconstant(0)
 DECLARE fromloop = i4 WITH noconstant(0)
 DECLARE toloop = i4 WITH noconstant(0)
 DECLARE bfound = i2 WITH noconstant(0)
 DECLARE foundtoloopentry = i4 WITH noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "SI_XDOC_METADATA"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_si_xdoc_metadata"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM si_xdoc_metadata sxm
  WHERE sxm.person_id IN (request->xxx_combine[icombine].from_xxx_id, request->xxx_combine[icombine].
  to_xxx_id)
   AND sxm.active_ind=1
  DETAIL
   IF ((sxm.person_id=request->xxx_combine[icombine].from_xxx_id))
    fromidcnt += 1, stat = alterlist(rreclist->from_rec,fromidcnt), rreclist->from_rec[fromidcnt].
    si_xdoc_metadata_id = sxm.si_xdoc_metadata_id,
    rreclist->from_rec[fromidcnt].repo_document_unique_ident = trim(sxm.repo_document_unique_ident),
    rreclist->from_rec[fromidcnt].home_community_ident = trim(sxm.home_community_ident), rreclist->
    from_rec[fromidcnt].repository_unique_ident = trim(sxm.repository_unique_ident),
    rreclist->from_rec[fromidcnt].doc_action_status_cd = sxm.doc_action_status_cd, rreclist->
    from_rec[fromidcnt].doc_retr_status_cd = sxm.doc_retr_status_cd, rreclist->from_rec[fromidcnt].
    doc_retr_start_dt_tm = sxm.doc_retr_start_dt_tm,
    rreclist->from_rec[fromidcnt].doc_retr_complete_dt_tm = sxm.doc_retr_complete_dt_tm, rreclist->
    from_rec[fromidcnt].media_object_identifier = sxm.media_object_identifier, rreclist->from_rec[
    fromidcnt].media_object_version_nbr = sxm.media_object_version_nbr
   ELSE
    toidcnt += 1, stat = alterlist(rreclist->to_rec,toidcnt), rreclist->to_rec[toidcnt].
    si_xdoc_metadata_id = sxm.si_xdoc_metadata_id,
    rreclist->to_rec[toidcnt].repo_document_unique_ident = trim(sxm.repo_document_unique_ident),
    rreclist->to_rec[toidcnt].home_community_ident = trim(sxm.home_community_ident), rreclist->
    to_rec[toidcnt].repository_unique_ident = trim(sxm.repository_unique_ident),
    rreclist->to_rec[toidcnt].media_object_identifier = sxm.media_object_identifier, rreclist->
    to_rec[toidcnt].media_object_version_nbr = sxm.media_object_version_nbr
   ENDIF
  WITH forupdatewait(sxm)
 ;end select
 IF (fromidcnt > 0)
  IF (toidcnt > 0)
   FOR (fromloop = 1 TO fromidcnt)
     SET foundtoloopentry = 0
     FOR (toloop = 1 TO toidcnt)
       IF ((rreclist->from_rec[fromloop].repo_document_unique_ident=rreclist->to_rec[toloop].
       repo_document_unique_ident)
        AND (rreclist->from_rec[fromloop].home_community_ident=rreclist->to_rec[toloop].
       home_community_ident)
        AND (rreclist->from_rec[fromloop].repository_unique_ident=rreclist->to_rec[toloop].
       repository_unique_ident))
        SET bfound = true
        SET foundtoloopentry = toloop
        SET rreclist->from_rec[fromloop].related_si_xdoc_metadata_id = rreclist->to_rec[toloop].
        si_xdoc_metadata_id
       ENDIF
     ENDFOR
     IF (bfound)
      IF ((((rreclist->to_rec[foundtoloopentry].media_object_identifier=" ")) OR ((rreclist->to_rec[
      foundtoloopentry].media_object_identifier=null)))
       AND (rreclist->from_rec[fromloop].media_object_identifier > " "))
       SET lstatus = transfer_multimedia_from(0)
      ELSE
       SET lstatus = inactivate_from(0)
      ENDIF
     ELSE
      SET lstatus = update_from(0)
     ENDIF
   ENDFOR
  ELSE
   FOR (fromloop = 1 TO fromidcnt)
     SET lstatus = update_from(0)
   ENDFOR
  ENDIF
 ELSE
  GO TO exit_script
 ENDIF
 SUBROUTINE (update_from(dummy=i4) =i4)
   UPDATE  FROM si_xdoc_metadata sxm
    SET sxm.person_id = request->xxx_combine[icombine].to_xxx_id, sxm.updt_cnt = (sxm.updt_cnt+ 1),
     sxm.updt_id = reqinfo->updt_id,
     sxm.updt_applctx = reqinfo->updt_applctx, sxm.updt_task = reqinfo->updt_task, sxm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (sxm.si_xdoc_metadata_id=rreclist->from_rec[fromloop].si_xdoc_metadata_id)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[fromloop].
   si_xdoc_metadata_id
   SET request->xxx_combine_det[icombinedet].entity_name = "SI_XDOC_METADATA"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("error in updating si_xdoc_metadata record-ID=",cnvtstring(
      rreclist->from_rec[fromloop].si_xdoc_metadata_id))
    SET reply->error_msg = concat("error in updating si_xdoc_metadata record-ID=",cnvtstring(rreclist
      ->from_rec[fromloop].si_xdoc_metadata_id))
    GO TO exit_script
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (inactivate_from(dummy=i4) =i4)
   UPDATE  FROM si_xdoc_metadata sxm
    SET sxm.active_ind = 0, sxm.active_status_cd = combinedaway, sxm.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime),
     sxm.updt_cnt = (sxm.updt_cnt+ 1), sxm.updt_id = reqinfo->updt_id, sxm.updt_applctx = reqinfo->
     updt_applctx,
     sxm.updt_task = reqinfo->updt_task, sxm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (sxm.si_xdoc_metadata_id=rreclist->from_rec[fromloop].si_xdoc_metadata_id)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[fromloop].
   si_xdoc_metadata_id
   SET request->xxx_combine_det[icombinedet].entity_name = "SI_XDOC_METADATA"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("error in inactivating an si_xdoc_metadata record-ID=",
     cnvtstring(rreclist->from_rec[fromloop].si_xdoc_metadata_id))
    SET reply->error_msg = concat("error in inactivating an si_xdoc_metadata record-ID=",cnvtstring(
      rreclist->from_rec[fromloop].si_xdoc_metadata_id))
    GO TO exit_script
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (transfer_multimedia_from(dummy=i4) =i4)
   UPDATE  FROM si_xdoc_metadata sxm
    SET sxm.media_object_identifier = rreclist->from_rec[fromloop].media_object_identifier, sxm
     .media_object_version_nbr = rreclist->from_rec[fromloop].media_object_version_nbr, sxm
     .doc_retr_status_cd = rreclist->from_rec[fromloop].doc_retr_status_cd,
     sxm.doc_retr_start_dt_tm = cnvtdatetime(rreclist->from_rec[fromloop].doc_retr_start_dt_tm), sxm
     .doc_retr_complete_dt_tm = cnvtdatetime(rreclist->from_rec[fromloop].doc_retr_complete_dt_tm),
     sxm.doc_action_status_cd = rreclist->from_rec[fromloop].doc_action_status_cd,
     sxm.updt_cnt = (sxm.updt_cnt+ 1), sxm.updt_id = reqinfo->updt_id, sxm.updt_applctx = reqinfo->
     updt_applctx,
     sxm.updt_task = reqinfo->updt_task, sxm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (sxm.si_xdoc_metadata_id=rreclist->from_rec[fromloop].related_si_xdoc_metadata_id)
   ;end update
   UPDATE  FROM si_xdoc_metadata sxm
    SET sxm.active_ind = 0, sxm.active_status_cd = combinedaway, sxm.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime),
     sxm.updt_cnt = (sxm.updt_cnt+ 1), sxm.updt_id = reqinfo->updt_id, sxm.updt_applctx = reqinfo->
     updt_applctx,
     sxm.updt_task = reqinfo->updt_task, sxm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (sxm.si_xdoc_metadata_id=rreclist->from_rec[fromloop].si_xdoc_metadata_id)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[fromloop].
   si_xdoc_metadata_id
   SET request->xxx_combine_det[icombinedet].entity_name = "SI_XDOC_METADATA"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("error in transfering an si_xdoc_metadata record-ID=",
     cnvtstring(rreclist->from_rec[fromloop].si_xdoc_metadata_id))
    SET reply->error_msg = concat("error in transfering an si_xdoc_metadata record-ID=",cnvtstring(
      rreclist->from_rec[fromloop].si_xdoc_metadata_id))
    GO TO exit_script
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 FREE SET rreclist
END GO
