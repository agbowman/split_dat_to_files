CREATE PROGRAM bed_ens_position:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 plist[*]
      2 code_value = f8
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
 RECORD copyrequest(
   1 copy_from_position_cd = f8
   1 copy_to_position_cd = f8
 )
 RECORD copyreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD copytasklistrequest(
   1 from_person_id = f8
   1 to_person_id = f8
   1 from_position_cd = f8
   1 to_position_cd = f8
 )
 RECORD copypalsettingsrequest(
   1 copy_from_position_code_value = f8
   1 copy_from_location_code_value = f8
   1 copy_to[*]
     2 position_code_value = f8
     2 location_code_value = f8
   1 always_delete_ind = i2
 )
 RECORD copypalsettingsreply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD basicpositionrequest(
   1 action_flag = i2
   1 code_value = f8
   1 display = vc
   1 description = vc
   1 long_description = vc
   1 pcoind = i2
   1 categories[*]
     2 action_flag = i2
     2 category_id = f8
     2 cat_phys_ind = i2
   1 applicationgroups[*]
     2 action_flag = i2
     2 app_group_cd = f8
 )
 RECORD basicpositionreply(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE pco_who_works = i2 WITH protect, noconstant(0)
 DECLARE replysize = i4 WITH protect, noconstant(0)
 DECLARE wpositioncd = f8 WITH protect, noconstant(0)
 DECLARE palloccnt = i4 WITH protect, noconstant(0)
 DECLARE add_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE addposition(pidx=i2,newpositioncd=f8(ref)) = i2
 DECLARE updateposition(pidx=i2,updatedpositioncd=f8(ref)) = i2
 DECLARE deleteposition(pidx=i2) = i2
 DECLARE updatepositionattributes(pidx=i2) = i2
 DECLARE copyallpreferences(pidx=i2,newpositioncd=f8) = i2
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="PCOPSNSELECTED"
  DETAIL
   pco_who_works = 1
  WITH nocounter
 ;end select
 FOR (posidx = 1 TO size(request->plist,5))
   IF ((request->plist[posidx].action_flag=add_flag))
    IF ( NOT (addposition(posidx,wpositioncd)))
     SET error_msg = concat("Failed adding a position. ",error_msg)
     SET error_flag = "F"
     GO TO exit_script
    ENDIF
    IF ( NOT (copyallpreferences(posidx,wpositioncd)))
     SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_POSITION","  >> ERROR MSG: ",error_msg
      )
     CALL bederror("Failed to copy preferences.")
    ENDIF
   ELSEIF ((request->plist[posidx].action_flag=update_flag))
    IF ( NOT (updateposition(posidx,wpositioncd)))
     SET error_msg = concat("Failed updating a position. ",error_msg)
     SET error_flag = "F"
     GO TO exit_script
    ENDIF
   ELSEIF ((request->plist[posidx].action_flag=delete_flag))
    IF ( NOT (deleteposition(posidx)))
     SET error_msg = concat("Failed deleting a position. ",error_msg)
     SET error_flag = "F"
     GO TO exit_script
    ENDIF
   ELSE
    IF ((request->plist[posidx].code_value > 0)
     AND ((size(request->plist[posidx].clist,5) > 0) OR (size(request->plist[posidx].alist,5) > 0)) )
     IF ( NOT (updatepositionattributes(posidx)))
      SET error_msg = concat("Failed updating position attributes. ",error_msg)
      SET error_flag = "F"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_POSITION","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE addposition(pidx,newpositioncd)
   CALL bedlogmessage("addPosition()","Entering...")
   SET newpositioncd = 0.0
   SET stat = initrec(basicpositionrequest)
   SET stat = initrec(basicpositionreply)
   DECLARE clistsize = i4 WITH protect, noconstant(0)
   DECLARE alistsize = i4 WITH protect, noconstant(0)
   DECLARE replysize = i4 WITH protect, noconstant(0)
   SET basicpositionrequest->action_flag = add_flag
   SET basicpositionrequest->display = request->plist[pidx].display
   SET basicpositionrequest->description = request->plist[pidx].description
   SET basicpositionrequest->pcoind = request->plist[pidx].pco_ind
   SET clistsize = size(request->plist[pidx].clist,5)
   IF (clistsize > 0)
    SET stat = alterlist(basicpositionrequest->categories,clistsize)
    FOR (i = 1 TO clistsize)
      SET basicpositionrequest->categories[i].action_flag = add_flag
      SET basicpositionrequest->categories[i].category_id = request->plist[pidx].clist[i].category_id
      SET basicpositionrequest->categories[i].cat_phys_ind = request->plist[pidx].clist[i].
      cat_phys_ind
    ENDFOR
   ENDIF
   SET alistsize = size(request->plist[pidx].alist,5)
   IF (alistsize > 0)
    SET stat = alterlist(basicpositionrequest->applicationgroups,alistsize)
    FOR (k = 1 TO alistsize)
     SET basicpositionrequest->applicationgroups[k].action_flag = add_flag
     SET basicpositionrequest->applicationgroups[k].app_group_cd = request->plist[pidx].alist[k].
     app_group_cd
    ENDFOR
   ENDIF
   IF (validate(request->plist[pidx].process_long_desc_ind,0) > 0
    AND (request->plist[pidx].process_long_desc_ind=1))
    SET basicpositionrequest->long_description = request->plist[pidx].long_description
   ENDIF
   EXECUTE bed_ens_basic_position  WITH replace("REQUEST",basicpositionrequest), replace("REPLY",
    basicpositionreply)
   IF ((((basicpositionreply->position_cd <= 0)) OR ((basicpositionreply->status_data.status="F"))) )
    SET error_msg = basicpositionreply->status_data.subeventstatus[1].targetobjectname
    RETURN(false)
   ENDIF
   SET replysize = (size(reply->plist,5)+ 1)
   SET stat = alterlist(reply->plist,replysize)
   SET reply->plist[replysize].code_value = basicpositionreply->position_cd
   SET newpositioncd = basicpositionreply->position_cd
   CALL bedlogmessage("addPosition()","Exiting")
 END ;Subroutine
 SUBROUTINE updateposition(pidx,updatedpositioncd)
   CALL bedlogmessage("updatePosition()","Entering...")
   SET updatedpositioncd = 0
   SET stat = initrec(basicpositionrequest)
   SET stat = initrec(basicpositionreply)
   DECLARE clistsize = i4 WITH protect, noconstant(0)
   DECLARE alistsize = i4 WITH protect, noconstant(0)
   DECLARE replysize = i4 WITH protect, noconstant(0)
   SET basicpositionrequest->action_flag = update_flag
   SET basicpositionrequest->code_value = request->plist[pidx].code_value
   SET basicpositionrequest->display = request->plist[pidx].display
   SET basicpositionrequest->description = request->plist[pidx].description
   SET basicpositionrequest->pcoind = request->plist[pidx].pco_ind
   SET clistsize = size(request->plist[pidx].clist,5)
   IF (clistsize > 0)
    SET stat = alterlist(basicpositionrequest->categories,clistsize)
    FOR (i = 1 TO clistsize)
      SET basicpositionrequest->categories[i].action_flag = request->plist[pidx].clist[i].action_flag
      SET basicpositionrequest->categories[i].category_id = request->plist[pidx].clist[i].category_id
      SET basicpositionrequest->categories[i].cat_phys_ind = request->plist[pidx].clist[i].
      cat_phys_ind
    ENDFOR
   ENDIF
   SET alistsize = size(request->plist[pidx].alist,5)
   IF (alistsize > 0)
    SET stat = alterlist(basicpositionrequest->applicationgroups,alistsize)
    FOR (k = 1 TO alistsize)
     SET basicpositionrequest->applicationgroups[k].action_flag = request->plist[pidx].alist[k].
     action_flag
     SET basicpositionrequest->applicationgroups[k].app_group_cd = request->plist[pidx].alist[k].
     app_group_cd
    ENDFOR
   ENDIF
   IF (validate(request->plist[pidx].process_long_desc_ind,0) > 0
    AND (request->plist[pidx].process_long_desc_ind=1))
    SET basicpositionrequest->long_description = request->plist[pidx].long_description
   ENDIF
   EXECUTE bed_ens_basic_position  WITH replace("REQUEST",basicpositionrequest), replace("REPLY",
    basicpositionreply)
   IF ((((basicpositionreply->position_cd <= 0)) OR ((basicpositionreply->status_data.status="F"))) )
    SET error_msg = basicpositionreply->status_data.subeventstatus[1].targetobjectname
    RETURN(false)
   ENDIF
   SET replysize = (size(reply->plist,5)+ 1)
   SET stat = alterlist(reply->plist,replysize)
   SET reply->plist[replysize].code_value = basicpositionreply->position_cd
   SET updatedpositioncd = basicpositionreply->position_cd
   CALL bedlogmessage("updatePosition()","Exiting...")
 END ;Subroutine
 SUBROUTINE updatepositionattributes(pidx)
   CALL bedlogmessage("updatePositionAttributes()","Entering...")
   SET stat = initrec(basicpositionrequest)
   SET stat = initrec(basicpositionreply)
   SET basicpositionrequest->action_flag = 4
   SET basicpositionrequest->code_value = request->plist[pidx].code_value
   SET clistsize = size(request->plist[pidx].clist,5)
   IF (clistsize > 0)
    SET stat = alterlist(basicpositionrequest->categories,clistsize)
    FOR (i = 1 TO clistsize)
      SET basicpositionrequest->categories[i].action_flag = request->plist[pidx].clist[i].action_flag
      SET basicpositionrequest->categories[i].category_id = request->plist[pidx].clist[i].category_id
      SET basicpositionrequest->categories[i].cat_phys_ind = request->plist[pidx].clist[i].
      cat_phys_ind
    ENDFOR
   ENDIF
   SET alistsize = size(request->plist[pidx].alist,5)
   IF (alistsize > 0)
    SET stat = alterlist(basicpositionrequest->applicationgroups,alistsize)
    FOR (k = 1 TO alistsize)
     SET basicpositionrequest->applicationgroups[k].action_flag = request->plist[pidx].alist[k].
     action_flag
     SET basicpositionrequest->applicationgroups[k].app_group_cd = request->plist[pidx].alist[k].
     app_group_cd
    ENDFOR
   ENDIF
   EXECUTE bed_ens_basic_position  WITH replace("REQUEST",basicpositionrequest), replace("REPLY",
    basicpositionreply)
   IF ((((basicpositionreply->position_cd <= 0)) OR ((basicpositionreply->status_data.status="F"))) )
    SET error_msg = basicpositionreply->status_data.subeventstatus[1].targetobjectname
    RETURN(false)
   ENDIF
   SET replysize = (size(reply->plist,5)+ 1)
   SET stat = alterlist(reply->plist,replysize)
   SET reply->plist[replysize].code_value = basicpositionreply->position_cd
   CALL bedlogmessage("updatePositionAttributes()","Exiting...")
 END ;Subroutine
 SUBROUTINE deleteposition(pidx,updatedpositioncd)
   CALL bedlogmessage("deletePosition()","Entering...")
   DECLARE pos_cat_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_position_category b
    WHERE b.description="Physician Office/Clinic"
    DETAIL
     pos_cat_id = b.category_id
    WITH nocounter
   ;end select
   IF (pos_cat_id > 0.0)
    DELETE  FROM br_position_cat_comp b
     WHERE b.category_id=pos_cat_id
      AND (b.position_cd=request->plist[pidx].code_value)
     WITH nocounter
    ;end delete
   ENDIF
   IF ((request->plist[pidx].pco_ind=1)
    AND pco_who_works=1)
    DELETE  FROM br_name_value bnv
     WHERE bnv.br_nv_key1="PCOPSNSELECTED"
      AND bnv.br_name="CVFROMCS88"
      AND bnv.br_value=cnvtstring(request->plist[pidx].code_value)
     WITH nocounter
    ;end delete
   ENDIF
   CALL bedlogmessage("deletePosition()","Exiting...")
 END ;Subroutine
 SUBROUTINE copyallpreferences(pidx,newpositioncd)
   CALL bedlogmessage("copyAllPreferences()","Entering")
   SET copyrequest->copy_from_position_cd = request->plist[pidx].copy_source_position_cd
   SET copyrequest->copy_to_position_cd = newpositioncd
   IF ((request->plist[pidx].copy_prefs_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_preferences_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_privs_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_privileges_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_prov_rel_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_prov_reltn_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_task_list_views_ind=1))
    SET stat = initrec(copyreply)
    SET copytasklistrequest->from_person_id = 0
    SET copytasklistrequest->to_person_id = 0
    SET copytasklistrequest->from_position_cd = request->plist[pidx].copy_source_position_cd
    SET copytasklistrequest->to_position_cd = newpositioncd
    EXECUTE tsk_add_copy_task_list  WITH replace("REQUEST",copytasklistrequest), replace("REPLY",
     copyreply)
   ENDIF
   IF ((request->plist[pidx].copy_task_reltn_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_task_reltn_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_note_type_reltn_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_note_type_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_time_frame_reltn_ind=1))
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_time_frame_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_pal_psn_views_ind=1))
    SET stat = initrec(copypalsettingsrequest)
    SET stat = initrec(copypalsettingsreply)
    SET copypalsettingsrequest->copy_from_position_code_value = request->plist[pidx].
    copy_source_position_cd
    SET copypalsettingsrequest->copy_from_location_code_value = 0
    SET stat = alterlist(copypalsettingsrequest->copy_to,1)
    SET copypalsettingsrequest->copy_to[1].position_code_value = newpositioncd
    SET copypalsettingsrequest->copy_to[1].location_code_value = 0
    SET trace = recpersist
    EXECUTE bed_copy_pal_settings  WITH replace("REQUEST",copypalsettingsrequest), replace("REPLY",
     copypalsettingsreply)
    SET trace = norecpersist
    IF ((copypalsettingsreply->status_data.status != "S"))
     SET error_msg = "The script bed_copy_pal_settings did not return success."
     RETURN(false)
    ENDIF
   ENDIF
   IF ((request->plist[pidx].copy_pal_psn_loc_views_ind=1))
    IF ( NOT (validate(pal,0)))
     RECORD pal(
       1 loclist[*]
         2 loc_cd = f8
     )
    ENDIF
    SET stat = initrec(pal)
    SET stat = initrec(copypalsettingsrequest)
    SET stat = initrec(copypalsettingsreply)
    SET palloccnt = 0
    SELECT INTO "nl:"
     FROM pip p
     PLAN (p
      WHERE (p.position_cd=request->plist[pidx].copy_source_position_cd)
       AND p.prsnl_id=0
       AND p.location_cd > 0)
     DETAIL
      palloccnt = (palloccnt+ 1), stat = alterlist(pal->loclist,palloccnt), pal->loclist[palloccnt].
      loc_cd = p.location_cd
     WITH nocounter
    ;end select
    FOR (lidx = 1 TO palloccnt)
      SET copypalsettingsrequest->copy_from_position_code_value = request->plist[pidx].
      copy_source_position_cd
      SET copypalsettingsrequest->copy_from_location_code_value = pal->loclist[lidx].loc_cd
      SET stat = alterlist(copypalsettingsrequest->copy_to,1)
      SET copypalsettingsrequest->copy_to[1].position_code_value = newpositioncd
      SET copypalsettingsrequest->copy_to[1].location_code_value = pal->loclist[lidx].loc_cd
      SET trace = recpersist
      EXECUTE bed_copy_pal_settings  WITH replace("REQUEST",copypalsettingsrequest), replace("REPLY",
       copypalsettingsreply)
      SET trace = norecpersist
      IF ((copypalsettingsreply->status_data.status != "S"))
       SET error_msg = "The script bed_copy_pal_settings did not return success."
       RETURN(false)
      ENDIF
    ENDFOR
   ENDIF
   IF (validate(request->plist[1].copy_clin_calc_equa_ind,0)=1)
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_clin_calc_eq_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   IF (validate(request->plist[1].copy_cust_col_ind,0)=1)
    SET stat = initrec(copyreply)
    EXECUTE bed_copy_custom_col_for_pos  WITH replace("REQUEST",copyrequest), replace("REPLY",
     copyreply)
    IF ((copyreply->status_data.status != "S"))
     SET error_msg = copyreply->status_data.subeventstatus[1].targetobjectname
     RETURN(false)
    ENDIF
   ENDIF
   CALL bedlogmessage("copyAllPreferences()","Exiting")
 END ;Subroutine
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
END GO
