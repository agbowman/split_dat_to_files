CREATE PROGRAM bb_upd_mult_act_aborh:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD personaborhs(
   1 personaborhlist[*]
     2 person_aborh_id = f8
     2 active_ind = i2
     2 abo_cd = f8
     2 rh_cd = f8
     2 updt_cnt = i4
     2 active_status_dt_tm = dq8
 )
 DECLARE script_name = c40 WITH public, constant("bb_upd_mult_act_aborh")
 DECLARE new_person_aborh_id = f8 WITH public, noconstant(0.0)
 DECLARE new_upload_review_id = f8 WITH public, noconstant(0.0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE item_aborh_prsnl_id = f8 WITH private, noconstant(0.0)
 DECLARE item_aborh_dt_tm = q8 WITH private, noconstant(cnvtdatetime(sysdate))
 IF (fill_out_person_aborhs(request->person_id)=0)
  GO TO exit_script
 ENDIF
 IF (insert_upload_review_row(request->person_id,0,0,"")=0)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(personaborhs->personaborhlist,5))
   IF ((personaborhs->personaborhlist[i].active_ind=1))
    IF (insert_upload_person_aborh_r_row(new_upload_review_id,personaborhs->personaborhlist[i].
     person_aborh_id,personaborhs->personaborhlist[i].active_status_dt_tm)=0)
     GO TO exit_script
    ENDIF
    IF (update_person_aborh_row(0,personaborhs->personaborhlist[i].person_aborh_id,personaborhs->
     personaborhlist[i].updt_cnt)=0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE (fill_out_person_aborhs(person_id_new=f8) =i2)
   SET exit_script_ind = 0
   SET multiple_actives_exist_ind = 0
   SET actives_exist_ind = 0
   SELECT INTO "nl:"
    pa.person_aborh_id
    FROM person_aborh pa
    WHERE pa.person_id=person_id_new
     AND pa.person_id > 0.0
    HEAD REPORT
     count = 0, active_cnt = 0, stat = alterlist(personaborhs->personaborhlist,count)
    DETAIL
     count += 1, stat = alterlist(personaborhs->personaborhlist,count)
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
 SUBROUTINE (update_person_aborh_row(active_ind=i2,sub_person_aborh_id=f8,updt_cnt=i4) =i2)
   SELECT INTO "nl:"
    pa.person_aborh_id
    FROM person_aborh pa
    WHERE pa.person_aborh_id=sub_person_aborh_id
     AND ((pa.updt_cnt+ 0)=updt_cnt)
    WITH nocounter, forupdate(pa)
   ;end select
   IF (check_for_ccl_error("lock person_aborh")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","lock person_aborh",concat("Unable to lock person_aborh row ",trim
       (cnvtstring(sub_person_aborh_id,32,2))," for update"))
     RETURN(0)
    ENDIF
   ENDIF
   UPDATE  FROM person_aborh pa
    SET pa.active_ind = active_ind, pa.active_status_cd =
     IF (active_ind=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , pa.active_status_prsnl_id = reqinfo->updt_id,
     pa.active_status_dt_tm = cnvtdatetime(sysdate), pa.updt_cnt = (updt_cnt+ 1), pa.updt_task =
     reqinfo->updt_task,
     pa.updt_applctx = reqinfo->updt_applctx, pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id =
     reqinfo->updt_id
    WHERE pa.person_aborh_id=sub_person_aborh_id
     AND ((pa.updt_cnt+ 0)=updt_cnt)
    WITH nocounter
   ;end update
   IF (check_for_ccl_error("update person_aborh")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","update person_aborh",concat("Person_aborh row ",trim(cnvtstring(
         sub_person_aborh_id,32,2))," not updated."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (insert_upload_review_row(person_id_new=f8,upload_person_aborh_id_new=f8,
  demog_person_aborh_id_new=f8,demog_dt_tm=dq8) =i2)
   DECLARE new_upload_review_id = f8 WITH protect, noconstant(0.0)
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
       "Unable to insert upload_review row for person ",trim(cnvtstring(person_id_new,32,2))))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (insert_upload_person_aborh_r_row(upload_review_id_new=f8,person_aborh_id_new=f8,
  person_aborh_dt_tm=dq8) =i2)
   SET new_id = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_id = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM bb_upload_person_aborh_r bupa
    SET bupa.bb_upload_person_aborh_r_id = new_id, bupa.bb_upload_review_id = upload_review_id_new,
     bupa.person_aborh_id = person_aborh_id_new,
     bupa.demog_aborh_dt_tm = cnvtdatetime(person_aborh_dt_tm), bupa.updt_cnt = 0, bupa.updt_task =
     reqinfo->updt_task,
     bupa.updt_applctx = reqinfo->updt_applctx, bupa.updt_dt_tm = cnvtdatetime(sysdate), bupa.updt_id
      = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("Insert bupar")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Insert bupar","No rows inserted into bb_upload_person_aborh_r")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
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
