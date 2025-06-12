CREATE PROGRAM bed_ens_org_instr:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET icnt = 0
 SET icnt = size(request->ilist,5)
 SET error_flag = " "
 DECLARE error_msg = vc
 SET org_id = 0.0
 IF ((request->organization_id=0))
  SET error_flag = "F"
  SET error_msg = concat("Required value missing in request, ","organization_id is required.")
  GO TO exit_script
 ENDIF
 IF (icnt > 0)
  SET stat = alterlist(reply->status_data.subeventstatus,icnt)
 ELSE
  SET error_flag = "N"
 ENDIF
 FOR (i = 1 TO icnt)
   IF ((request->ilist[i].action_flag=0))
    SET a = 1
   ELSEIF ((request->ilist[i].action_flag=1))
    SET stat = add_instr(i)
   ELSEIF ((request->ilist[i].action_flag=2))
    SET stat = upd_instr(i)
   ELSE
    IF ((request->ilist[i].action_flag=3))
     SET stat = del_instr(i)
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_instr(i)
  SELECT INTO "nl:"
   FROM br_instr_org_reltn bior
   PLAN (bior
    WHERE (bior.organization_id=request->organization_id)
     AND (bior.br_instr_id=request->ilist[i].br_instr_id)
     AND (bior.model_disp=requiest->ilist[i].model_disp))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET new_id = 0.0
   SELECT INTO "nl:"
    FROM br_instr_org_reltn bior
    PLAN (bior
     WHERE bior.br_instr_org_reltn_id > 0)
    ORDER BY bior.br_instr_org_reltn_id DESC
    HEAD REPORT
     new_id = bior.br_instr_org_reltn_id
    WITH nocounter
   ;end select
   SET new_id = (new_id+ 1)
   INSERT  FROM br_instr_org_reltn bior
    SET bior.br_instr_org_reltn_id = new_id, bior.organization_id = request->organization_id, bior
     .br_instr_id = request->ilist[i].br_instr_id,
     bior.model_disp = request->ilist[i].model_disp, bior.poc_ind = request->ilist[i].
     point_of_care_ind, bior.robotics_ind = request->ilist[i].robotics_ind,
     bior.multiplexor_ind = request->ilist[i].multiplexor_ind, bior.uni_ind = request->ilist[i].
     uni_ind, bior.bi_ind = request->ilist[i].bi_ind,
     bior.hq_ind = request->ilist[i].hq_ind
    WITH nocounter
   ;end insert
  ENDIF
 END ;Subroutine
 SUBROUTINE upd_instr(i)
   UPDATE  FROM br_instr_org_reltn bior
    SET bior.model_disp = request->ilist[i].model_disp, bior.poc_ind = request->ilist[i].
     point_of_care_ind, bior.robotics_ind = request->ilist[i].robotics_ind,
     bior.multiplexor_ind = request->ilist[i].multiplexor_ind, bior.uni_ind = request->ilist[i].
     uni_ind, bior.bi_ind = request->ilist[i].bi_ind,
     bior.hq_ind = request->ilist[i].hq_ind
    WHERE (bior.br_instr_org_reltn_id=request->ilist[i].br_instr_org_reltn_id)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE del_instr(i)
   DELETE  FROM br_instr_org_reltn bior
    PLAN (bior
     WHERE (bior.br_instr_org_reltn_id=request->ilist[i].br_instr_org_reltn_id))
    WITH nocounter
   ;end delete
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="F")
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ELSEIF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSEIF (error_flag="P")
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
