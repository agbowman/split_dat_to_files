CREATE PROGRAM bbt_add_hist_person_aborh:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_name = c40 WITH public, constant("bbt_add_hist_person_aborh")
 DECLARE abo_cd_new = f8 WITH public, noconstant(0.0)
 DECLARE rh_cd_new = f8 WITH public, noconstant(0.0)
 DECLARE multiple_actives_exist_ind = i2 WITH public, noconstant(0)
 DECLARE actives_exist_ind = i2 WITH public, noconstant(0)
 DECLARE person_aborh_rows_exist_ind = i2 WITH public, noconstant(0)
 DECLARE unreviewed_record_exists_ind = i2 WITH public, noconstant(0)
 DECLARE new_person_aborh_id = f8 WITH public, noconstant(0.0)
 DECLARE new_upload_review_id = f8 WITH public, noconstant(0.0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE exit_loop_ind = i4 WITH public, noconstant(0)
 DECLARE item_aborh_prsnl_id = f8 WITH private, noconstant(0.0)
 DECLARE item_aborh_dt_tm = q8 WITH private, noconstant(cnvtdatetime(sysdate))
 DECLARE cs_aborh_result = i4 WITH public, constant(1643)
 DECLARE cs_standard_aborh = i4 WITH public, constant(1640)
 DECLARE abo_only = c12 WITH public, constant("ABOOnly_cd")
 DECLARE rh_only = c12 WITH public, constant("RhOnly_cd")
 DECLARE aborh = c12 WITH public, constant("ABORH_cd")
 EXECUTE srvrtl
 EXECUTE crmrtl
 RECORD personaborhs(
   1 personaborhlist[*]
     2 person_aborh_id = f8
     2 active_ind = i2
     2 abo_cd = f8
     2 rh_cd = f8
     2 updt_cnt = i4
     2 active_status_dt_tm = dq8
 )
 IF ( NOT ((request->contributor_system_cd > 0.0)))
  CALL fill_out_status_data("F","Validate contrib_sys_cd","Contributor system code not > 0")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(request->qual,5))
   IF (perform_data_validation(request->qual[i].person_id,request->qual[i].aborh_cd)=0)
    GO TO exit_script
   ENDIF
   IF (get_abo_and_rh_values(request->qual[i].aborh_cd)=0)
    GO TO exit_script
   ENDIF
   IF (fill_out_person_aborhs(request->qual[i].person_id)=0)
    GO TO exit_script
   ENDIF
   IF ((request->qual[i].aborh_prsnl_id > 0.0))
    SET item_aborh_prsnl_id = request->qual[i].aborh_prsnl_id
   ELSE
    SET item_aborh_prsnl_id = request->active_status_prsnl_id
   ENDIF
   IF ((request->qual[i].aborh_dt_tm > 0))
    SET item_aborh_dt_tm = request->qual[i].aborh_dt_tm
   ELSE
    SET item_aborh_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (person_aborh_rows_exist_ind=0)
    IF (insert_person_aborh_row(request->qual[i].person_id,1,abo_cd_new,rh_cd_new,item_aborh_prsnl_id,
     item_aborh_dt_tm)=0)
     GO TO exit_script
    ENDIF
   ELSE
    IF (multiple_actives_exist_ind=1)
     IF (update_multiple_active_aborh(request->qual[i].person_id)=0)
      GO TO exit_script
     ENDIF
     CALL fill_out_status_data("F","Validate person_aborh",concat("Person ",trim(cnvtstring(request->
         qual[i].person_id,32,0))," has multiple active person_aborh rows.",
       " Upload cancelled, no person ABO/Rh"," upload data applied. Please resolve."))
     GO TO exit_script
    ELSE
     IF (check_for_unreviewed_upload_review(0)=0)
      GO TO exit_script
     ELSE
      IF (unreviewed_record_exists_ind=1)
       CALL fill_out_status_data("F","Validate inactive UR",concat("Person ",trim(cnvtstring(request
           ->qual[i].person_id,32,0))," has active BB Review Queue rows.",
         " Upload cancelled, no person ABO/Rh"," upload data applied.",
         " Please investigate BB Review Queue."))
       GO TO exit_script
      ENDIF
     ENDIF
     IF (actives_exist_ind=0)
      IF (insert_person_aborh_row(request->qual[i].person_id,1,abo_cd_new,rh_cd_new,
       item_aborh_prsnl_id,
       item_aborh_dt_tm)=0)
       GO TO exit_script
      ENDIF
     ELSE
      SET exit_loop_ind = 0
      SET j = 1
      WHILE (j <= size(personaborhs->personaborhlist,5)
       AND exit_loop_ind=0)
       IF ((personaborhs->personaborhlist[j].active_ind=1))
        IF (insert_person_aborh_row(request->qual[i].person_id,0,abo_cd_new,rh_cd_new,
         item_aborh_prsnl_id,
         item_aborh_dt_tm)=0)
         GO TO exit_script
        ENDIF
        IF ((personaborhs->personaborhlist[j].abo_cd=abo_cd_new)
         AND (personaborhs->personaborhlist[j].rh_cd=rh_cd_new))
         SET j = j
        ELSE
         IF (insert_upload_review_row(request->qual[i].person_id,new_person_aborh_id,personaborhs->
          personaborhlist[j].person_aborh_id,personaborhs->personaborhlist[j].active_status_dt_tm)=0)
          GO TO exit_script
         ENDIF
         IF (update_person_aborh_row(0,personaborhs->personaborhlist[j].person_aborh_id,personaborhs
          ->personaborhlist[j].updt_cnt)=0)
          GO TO exit_script
         ENDIF
         CALL fill_out_status_data(" ","Conflicting aborh",concat("Upload Abo/rh for person ",trim(
            cnvtstring(request->qual[i].person_id,32,0))," conflicts with existing Abo/rh."))
        ENDIF
        SET exit_loop_ind = 1
       ENDIF
       SET j += 1
      ENDWHILE
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE (perform_data_validation(person_id_new=f8,aborh_cd=f8) =i2)
   SELECT INTO "nl:"
    p.person_id
    FROM person p
    WHERE p.person_id=person_id_new
     AND p.person_id > 0.0
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on person")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Validate person_id",concat("Person ",trim(cnvtstring(
         person_id_new,32,0))," does not exist on person table"))
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    cv.code_value, cv.code_set
    FROM code_value cv
    WHERE cv.code_value=aborh_cd
     AND cv.code_set=1643
     AND cv.code_value > 0.0
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on code_value")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Validate aborh_cd",concat("Aborh_cd ",trim(cnvtstring(aborh_cd,32,
         0))," for person ",cnvtstring(person_id_new,32,0)," not found on code_set 1643"))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (get_abo_and_rh_values(aborh_cd=f8) =i2)
   SET abo_cd_new = 0.0
   SET rh_cd_new = 0.0
   SELECT INTO "nl:"
    cve1.code_value, cve2.code_value
    FROM code_value_extension cve1,
     code_value_extension cve2
    PLAN (cve1
     WHERE cve1.code_value=aborh_cd
      AND cve1.code_set=cs_aborh_result
      AND cve1.field_name=aborh)
     JOIN (cve2
     WHERE cve2.code_value=cnvtreal(cve1.field_value)
      AND cve2.code_set=cs_standard_aborh)
    DETAIL
     IF (cve2.field_name=abo_only)
      abo_cd_new = cnvtreal(cve2.field_value)
     ELSEIF (cve2.field_name=rh_only)
      rh_cd_new = cnvtreal(cve2.field_value)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on code_value_extension")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Retrieval abo and rh",concat(
       "Abo and Rh code values not found for aborh_cd ",trim(cnvtstring(aborh_cd,32,0))))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (fill_out_person_aborhs(person_id_new=f8) =i2)
   SET multiple_actives_exist_ind = 0
   SET actives_exist_ind = 0
   SET person_aborh_rows_exist_ind = 0
   SELECT INTO "nl:"
    pa.person_aborh_id
    FROM person_aborh pa
    WHERE pa.person_id=person_id_new
     AND pa.person_id > 0.0
    HEAD REPORT
     count = 0, active_cnt = 0, stat = alterlist(personaborhs->personaborhlist,count)
    DETAIL
     person_aborh_rows_exist_ind = 1, count += 1, stat = alterlist(personaborhs->personaborhlist,
      count)
     IF (pa.active_ind=1)
      active_cnt += 1, actives_exist_ind = 1
     ENDIF
     personaborhs->personaborhlist[count].person_aborh_id = pa.person_aborh_id, personaborhs->
     personaborhlist[count].active_ind = pa.active_ind, personaborhs->personaborhlist[count].abo_cd
      = pa.abo_cd,
     personaborhs->personaborhlist[count].rh_cd = pa.rh_cd, personaborhs->personaborhlist[count].
     updt_cnt = pa.updt_cnt, personaborhs->personaborhlist[count].active_status_dt_tm = pa
     .active_status_dt_tm
    FOOT REPORT
     stat = alterlist(personaborhs->personaborhlist,count)
     IF (active_cnt > 1)
      multiple_actives_exist_ind = 1
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_for_ccl_error("Select person_aborh")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (check_for_ccl_error(target_object_name=vc) =i2)
   DECLARE error_msg = c132 WITH private, noconstant(fillstring(132," "))
   DECLARE new_error = c132 WITH private, noconstant(fillstring(132," "))
   DECLARE error_ind = i4 WITH private, noconstant(0)
   SET error_ind = error(new_error,0)
   IF (error_ind != 0)
    WHILE (error_ind != 0)
     SET error_msg = concat(error_msg," ",new_error)
     SET error_ind = error(new_error,0)
    ENDWHILE
    CALL fill_out_status_data("F",target_object_name,error_msg)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (fill_out_status_data(status=c1,target_object_name=vc,target_object_value=vc) =null)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationstatus = status
   SET reply->status_data.subeventstatus[1].operationname = script_name
   SET reply->status_data.subeventstatus[1].targetobjectname = target_object_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = target_object_value
 END ;Subroutine
 SUBROUTINE (insert_person_aborh_row(person_id_new=f8,active_ind_new=i2,abo_cd_new=f8,rh_cd_new=f8,
  aborh_prsnl_id=f8,aborh_dt_tm=dq8) =i2)
   SET new_person_aborh_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_person_aborh_id = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM person_aborh pa
    SET pa.person_aborh_id = new_person_aborh_id, pa.abo_cd = abo_cd_new, pa.rh_cd = rh_cd_new,
     pa.active_ind = active_ind_new, pa.person_id = person_id_new, pa.active_status_cd =
     IF (active_ind_new=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     ,
     pa.active_status_prsnl_id = aborh_prsnl_id, pa.active_status_dt_tm = cnvtdatetime(aborh_dt_tm),
     pa.begin_effective_dt_tm = cnvtdatetime(aborh_dt_tm),
     pa.end_effective_dt_tm =
     IF (active_ind_new=1) cnvtdatetime("31-DEC-2100 23:59:00")
     ELSE cnvtdatetime(sysdate)
     ENDIF
     , pa.contributor_system_cd = request->contributor_system_cd, pa.updt_cnt = 0,
     pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx, pa.updt_dt_tm =
     cnvtdatetime(sysdate),
     pa.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("Insert person_aborh")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Insert person_aborh",concat(
       "Unable to insert person-aborh row for person ",trim(cnvtstring(person_id_new,32,0))))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (update_person_aborh_row(active_ind_new=i2,sub_person_aborh_id=f8,updt_cnt=i4) =i2)
   SELECT INTO "nl:"
    pa.person_aborh_id
    FROM person_aborh pa
    WHERE pa.person_aborh_id=sub_person_aborh_id
     AND pa.updt_cnt=updt_cnt
    WITH nocounter, forupdate(pa)
   ;end select
   IF (check_for_ccl_error("lock person_aborh")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","lock person_aborh",concat("Unable to lock person_aborh row ",trim
       (cnvtstring(sub_person_aborh_id,32,0))," for update"))
     RETURN(0)
    ENDIF
   ENDIF
   UPDATE  FROM person_aborh pa
    SET pa.active_ind = active_ind_new, pa.active_status_cd =
     IF (active_ind_new=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , pa.active_status_prsnl_id = reqinfo->updt_id,
     pa.active_status_dt_tm = cnvtdatetime(sysdate), pa.updt_cnt = (updt_cnt+ 1), pa.updt_task =
     reqinfo->updt_task,
     pa.updt_applctx = reqinfo->updt_applctx, pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id =
     reqinfo->updt_id
    WHERE pa.person_aborh_id=sub_person_aborh_id
     AND pa.updt_cnt=updt_cnt
    WITH nocounter
   ;end update
   IF (check_for_ccl_error("update person_aborh")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","update person_aborh",concat("Person_aborh row ",trim(cnvtstring(
         sub_person_aborh_id,32,0))," not updated."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (insert_upload_review_row(person_id_new=f8,upload_person_aborh_id_new=f8,
  demog_person_aborh_id_new=f8,demog_dt_tm=dq8) =i2)
   SET new_upload_review_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_upload_review_id = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM bb_upload_review bur
    SET bur.bb_upload_review_id = new_upload_review_id, bur.person_id = person_id_new, bur
     .upload_person_aborh_id = upload_person_aborh_id_new,
     bur.demog_person_aborh_id = demog_person_aborh_id_new, bur.upload_dt_tm = cnvtdatetime(sysdate),
     bur.demog_aborh_dt_tm = cnvtdatetime(demog_dt_tm),
     bur.reviewed_ind = 0, bur.updt_cnt = 0, bur.updt_task = reqinfo->updt_task,
     bur.updt_applctx = reqinfo->updt_applctx, bur.updt_dt_tm = cnvtdatetime(sysdate), bur.updt_id =
     reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("Insert bb_upload_review")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Insert bb_upload_review",concat(
       "Unable to insert upload_review row for person ",trim(cnvtstring(person_id_new,32,0))))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (check_for_unreviewed_upload_review(dummy=i2) =i2)
   SET exit_script_ind = 0
   SET unreviewed_record_exists_ind = 0
   SELECT INTO "nl:"
    bur.bb_upload_review_id, d.seq
    FROM bb_upload_review bur,
     (dummyt d  WITH seq = value(size(personaborhs->personaborhlist,5)))
    PLAN (d
     WHERE (personaborhs->personaborhlist[d.seq].active_ind=0))
     JOIN (bur
     WHERE (((bur.upload_person_aborh_id=personaborhs->personaborhlist[d.seq].person_aborh_id)) OR ((
     bur.demog_person_aborh_id=personaborhs->personaborhlist[d.seq].person_aborh_id)))
      AND bur.reviewed_ind=0)
    DETAIL
     unreviewed_record_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select bb_upload_review")=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    bur.bb_upload_review_id, bupa.bb_upload_person_aborh_r_id, d.seq
    FROM bb_upload_review bur,
     bb_upload_person_aborh_r bupa,
     (dummyt d  WITH seq = value(size(personaborhs->personaborhlist,5)))
    PLAN (d
     WHERE (personaborhs->personaborhlist[d.seq].active_ind=0))
     JOIN (bupa
     WHERE (bupa.person_aborh_id=personaborhs->personaborhlist[d.seq].person_aborh_id))
     JOIN (bur
     WHERE (bur.bb_upload_review_id=(bupa.bb_upload_review_id+ 0))
      AND bur.reviewed_ind=0)
    DETAIL
     unreviewed_record_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select bupa-bur")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (update_multiple_active_aborh(person_id_new=i2) =i2)
   DECLARE crmstatus = i4 WITH noconstant(0)
   DECLARE app_number = i4 WITH noconstant(0)
   DECLARE task_number = i4 WITH noconstant(0)
   DECLARE req_number = i4 WITH noconstant(0)
   DECLARE happ = i4 WITH noconstant(0)
   DECLARE htask = i4 WITH noconstant(0)
   DECLARE hdata = i4 WITH noconstant(0)
   DECLARE hstatus = i4 WITH noconstant(0)
   DECLARE hstep = i4 WITH noconstant(0)
   DECLARE hreq = i4 WITH noconstant(0)
   DECLARE status_value = c1 WITH noconstant(" ")
   DECLARE error = vc
   SET app_number = 225082
   SET crmstatus = uar_crmbeginapp(app_number,happ)
   IF (crmstatus)
    IF ((request->debug_ind=1))
     CALL echo(concat("Begin app failed with status: ",cnvtstring(crmstatus)))
    ENDIF
    CALL fill_out_status_data("F","bb_upd_mult_act_aborh","Error beginning app")
    RETURN(0)
   ENDIF
   SET task_number = 225568
   SET crmstatus = uar_crmbegintask(happ,task_number,htask)
   IF (crmstatus)
    CALL uar_crmendapp(happ)
    IF ((request->debug_ind=1))
     CALL echo(concat("Begin task failed with status: ",cnvtstring(crmstatus)))
    ENDIF
    CALL fill_out_status_data("F","bb_upd_mult_act_aborh","Error beginning task")
    RETURN(0)
   ENDIF
   SET req_number = 225912
   SET crmstatus = uar_crmbeginreq(htask,0,req_number,hreq)
   IF (crmstatus)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    IF ((request->debug_ind=1))
     CALL echo(concat("Begin request failed with status: ",cnvtstring(crmstatus)))
    ENDIF
    CALL fill_out_status_data("F","bb_upd_mult_act_aborh","Error beginning request")
    RETURN(0)
   ENDIF
   SET hdata = uar_crmgetrequest(hreq)
   SET srvstat = uar_srvsetdouble(hdata,"person_id",person_id_new)
   SET crmstatus = uar_crmperform(hreq)
   IF (crmstatus)
    CALL uar_crmendreq(hreq)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    IF ((request->debug_ind=1))
     CALL echo(concat("Perform failed with status: ",cnvtstring(crmstatus)))
    ENDIF
    CALL fill_out_status_data("F","bb_upd_mult_act_aborh","Error performing request")
    RETURN(0)
   ENDIF
   IF ((request->debug_ind=1))
    CALL echo("Perform successful for bb_upd_mult_act_aborh")
   ENDIF
   SET hreply = uar_crmgetreply(hreq)
   SET hdata = uar_srvgetstruct(hreply,"status_data")
   SET status_value = uar_srvgetstringptr(hdata,"status")
   IF (status_value="F")
    SET hlist = uar_srvgetitem(hdata,"SubEventStatus",0)
    CALL fill_out_status_data("F","bb_upd_mult_act_aborh",uar_srvgetstringptr(hlist,
      "TargetObjectValue"))
    CALL uar_crmendreq(hreq)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ELSE
    CALL uar_crmendreq(hreq)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD personaborhs
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ENDIF
END GO
