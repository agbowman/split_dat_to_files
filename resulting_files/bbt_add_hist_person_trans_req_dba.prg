CREATE PROGRAM bbt_add_hist_person_trans_req:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_name = c40 WITH public, constant("bbt_add_hist_trans_req")
 DECLARE code_set = i4 WITH public, constant(1611)
 DECLARE i = i4 WITH private, noconstant(0)
 DECLARE exists_ind = i2 WITH public, noconstant(0)
 DECLARE item_prsnl_id = f8 WITH private, noconstant(0.0)
 DECLARE item_dt_tm = q8 WITH private, noconstant(cnvtdatetime(sysdate))
 IF ( NOT ((request->contributor_system_cd > 0.0)))
  CALL fill_out_status_data("F","Validate contrib_sys_cd","Contributor system code not > 0")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(request->qual,5))
   IF (perform_data_validation(request->qual[i].person_id,request->qual[i].encntr_id,request->qual[i]
    .requirement_cd,code_set)=0)
    GO TO exit_script
   ENDIF
   IF ((request->qual[i].trans_req_prsnl_id > 0.0))
    SET item_prsnl_id = request->qual[i].trans_req_prsnl_id
   ELSE
    SET item_prsnl_id = request->active_status_prsnl_id
   ENDIF
   IF ((request->qual[i].trans_req_dt_tm > 0))
    SET item_dt_tm = request->qual[i].trans_req_dt_tm
   ELSE
    SET item_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (check_if_attribute_exists(request->qual[i].person_id,request->qual[i].requirement_cd,request->
    contributor_system_cd)=0)
    GO TO exit_script
   ENDIF
   IF (exists_ind=0)
    IF (insert_attribute(request->qual[i].person_id,request->qual[i].encntr_id,request->qual[i].
     requirement_cd,1,item_dt_tm,
     item_prsnl_id,request->contributor_system_cd)=0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE (perform_data_validation(person_id_new=f8,encounter_id=f8,attribute_cd=f8,code_set_new=i4
  ) =i2)
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
   IF (encounter_id > 0.0)
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e
     WHERE e.encntr_id=encounter_id
      AND e.encntr_id > 0.0
      AND e.person_id=person_id_new
     WITH nocounter
    ;end select
    IF (check_for_ccl_error("Select on encounter")=0)
     RETURN(0)
    ELSE
     IF (curqual=0)
      CALL fill_out_status_data("F","Validate encntr_id",concat("Encntr_id ",trim(cnvtstring(
          encounter_id,32,0))," for person ",trim(cnvtstring(person_id_new,32,0)),
        " does not exist on encounter table"))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=attribute_cd
     AND cv.code_set=code_set_new
     AND cv.code_value > 0.0
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on code_value")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Validate attribute_cd",concat("Requirement_cd ",trim(cnvtstring(
         attribute_cd,32,0))," does not exist on code_set ",trim(cnvtstring(code_set_new))))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (check_if_attribute_exists(person_id_new=f8,attribute_cd=f8,contributor_system_cd_new=f8
  ) =i2)
   SET exists_ind = 0
   SELECT INTO "nl:"
    ptr.requirement_cd
    FROM person_trans_req ptr
    WHERE ptr.requirement_cd=attribute_cd
     AND ptr.person_id=person_id_new
     AND ptr.requirement_cd > 0.0
     AND active_ind=1
     AND ptr.contributor_system_cd=contributor_system_cd_new
    DETAIL
     exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_for_ccl_error("Select on person_trans_req")=0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (insert_attribute(person_id_new=f8,encounter_id=f8,attribute_cd=f8,active_ind_new=i2,
  active_status_dt_tm=dq8,active_status_prsnl_id_new=f8,contributor_system_cd_new=f8) =i2)
   DECLARE new_pathnet_id = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_id = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM person_trans_req ptr
    SET ptr.person_trans_req_id = new_pathnet_id, ptr.person_id = person_id_new, ptr.encntr_id =
     encounter_id,
     ptr.requirement_cd = attribute_cd, ptr.active_ind = active_ind_new, ptr.active_status_cd =
     IF (active_ind_new=1) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     ,
     ptr.active_status_dt_tm = cnvtdatetime(active_status_dt_tm), ptr.active_status_prsnl_id =
     active_status_prsnl_id_new, ptr.updt_cnt = 0,
     ptr.updt_dt_tm = cnvtdatetime(sysdate), ptr.updt_id = reqinfo->updt_id, ptr.updt_task = reqinfo
     ->updt_task,
     ptr.updt_applctx = reqinfo->updt_applctx, ptr.contributor_system_cd = contributor_system_cd_new,
     ptr.added_prsnl_id = reqinfo->updt_id,
     ptr.added_dt_tm = cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
   IF (check_for_ccl_error("Insert person_trans_req")=0)
    RETURN(0)
   ELSE
    IF (curqual=0)
     CALL fill_out_status_data("F","Insert person_trans_req",concat("Unable to insert requirement ",
       trim(cnvtstring(attribute_cd,32,0))," for person ",trim(cnvtstring(person_id_new,32,0))))
     RETURN(0)
    ENDIF
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
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
