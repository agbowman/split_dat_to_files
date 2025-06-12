CREATE PROGRAM ct_del_prot_role:dba
 RECORD reply(
   1 qual[*]
     2 id = f8
     2 debug = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lock_prot_role_error = i2 WITH private, constant(1)
 DECLARE update_prot_role_error = i2 WITH private, constant(2)
 DECLARE lock_entity_access_error = i2 WITH private, constant(3)
 DECLARE update_entity_access_error = i2 WITH private, constant(4)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE estring = c132 WITH private, noconstant(fillstring(132," "))
 DECLARE ecode = i2 WITH private, noconstant(0)
 DECLARE cur_updt_cnt = i2 WITH private, noconstant(0)
 DECLARE num_to_del = i2 WITH private, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE multiple_roles_found = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "Z"
 SET num_to_del = size(request->qual,5)
 FOR (i = 1 TO num_to_del)
  SELECT INTO "nl:"
   pr.*
   FROM prot_role pr
   WHERE (pr.prot_role_id=request->qual[i].prot_role_id)
   DETAIL
    cur_updt_cnt = pr.updt_cnt, amendment_id = pr.prot_amendment_id, person_id = pr.person_id
   WITH nocounter, forupdate(pr)
  ;end select
  IF (curqual > 0
   AND (cur_updt_cnt=request->qual[i].updt_cnt))
   CALL echo("before update")
   UPDATE  FROM prot_role pr
    SET pr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), pr.updt_id = reqinfo->updt_id,
     pr.updt_cnt = (pr.updt_cnt+ 1), pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo
     ->updt_task
    WHERE (pr.prot_role_id=request->qual[i].prot_role_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET stat = alterlist(reply->qual,i)
    SET reply->qual[i].id = request->qual[i].prot_role_id
    SET ecode = error(estring,1)
    SET reply->qual[i].debug = build(estring," ; ")
    SET fail_flag = update_prot_role_error
    GO TO check_error
   ELSE
    SET multiple_roles_found = 0
    SELECT INTO "nl:"
     pr.*
     FROM prot_role pr
     WHERE pr.person_id=person_id
      AND pr.prot_amendment_id=amendment_id
      AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND (pr.prot_role_id != request->qual[i].prot_role_id)
     DETAIL
      multiple_roles_found = 1
     WITH nocounter
    ;end select
    IF (multiple_roles_found=0)
     SELECT INTO "nl:"
      ea.*
      FROM entity_access ea
      WHERE ea.person_id=person_id
       AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND ea.prot_amendment_id=amendment_id
      WITH forupdate(ea)
     ;end select
     IF (curqual > 0)
      UPDATE  FROM entity_access ea
       SET ea.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ea.updt_cnt = (ea.updt_cnt+ 1),
        ea.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ea.updt_id = reqinfo->updt_id, ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task =
        reqinfo->updt_task
       WHERE ea.person_id=person_id
        AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND ea.prot_amendment_id=amendment_id
       WITH nocounter
      ;end update
      CALL echo(build("Curqual for entity update is: ",curqual))
      IF (curqual=0)
       SET stat = alterlist(reply->qual,i)
       SET ecode = error(estring,1)
       SET reply->qual[i].debug = build(estring," ; ")
       SET fail_flag = update_entity_access_error
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET fail_flag = lock_prot_role_error
   SET stat = alterlist(reply->qual,i)
   SET reply->qual[i].id = pr.prot_role_id
   SET ecode = error(estring,1)
   SET reply->qual[i].debug = build(estring," ; ")
   GO TO check_error
  ENDIF
 ENDFOR
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF lock_prot_role_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking prot_role table"
   OF update_prot_role_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Updating prot_role table"
   OF lock_entity_access_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Locking entity_access table"
   OF update_entity_access_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Updating entity_access table"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "002"
 SET mod_date = "June 12, 2012"
END GO
