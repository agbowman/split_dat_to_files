CREATE PROGRAM ct_del_role_multi_prots:dba
 SET modify = predeclare
 RECORD reply(
   1 person_access_list[*]
     2 person_id = f8
     2 entity_access_list[*]
       3 entity_access_id = f8
       3 prot_amendment_id = f8
       3 functionality_cd = f8
       3 access_mask = c5
   1 role_list[*]
     2 prot_role_id = f8
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
 DECLARE person_in_request = i2 WITH private, constant(5)
 SET reply->status_data.status = "F"
 DECLARE person_cnt = i2 WITH protect, noconstant(0)
 SET person_cnt = cnvtint(size(request->person_list,5))
 CALL echo(build("person_cnt is: ",person_cnt))
 IF (person_cnt <= 0)
  SET fail_flag = person_in_request
  GO TO check_error
 ENDIF
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE person_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE ea_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  pr.*
  FROM prot_role pr,
   prot_amendment pa,
   (dummyt d1  WITH seq = value(cnvtint(size(request->person_list,5)))),
   (dummyt d2  WITH seq = value(cnvtint(size(request->person_list[(row+ 1)].protocols,5))))
  PLAN (d1)
   JOIN (d2)
   JOIN (pa
   WHERE (pa.prot_master_id=request->person_list[d1.seq].protocols[d2.seq].prot_master_id))
   JOIN (pr
   WHERE (pr.person_id=request->person_list[d1.seq].person_id)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pr.prot_amendment_id=pa.prot_amendment_id
    AND (pr.prot_role_cd=request->person_list[d1.seq].protocols[d2.seq].prot_role_cd))
  DETAIL
   updt_cnt = (updt_cnt+ 1)
   IF (mod(updt_cnt,10)=1)
    stat = alterlist(reply->role_list,(updt_cnt+ 9))
   ENDIF
   reply->role_list[updt_cnt].prot_role_id = pr.prot_role_id,
   CALL echo(build("role id: ",reply->role_list[updt_cnt].prot_role_id))
  WITH nocounter
 ;end select
 CALL echo(build("update for non active is: ",updt_cnt))
 IF (updt_cnt > 0)
  SET stat = alterlist(reply->role_list,updt_cnt)
  IF (curqual=0)
   SET fail_flag = lock_prot_role_error
   GO TO check_error
  ENDIF
 ENDIF
 IF (updt_cnt > 0)
  UPDATE  FROM prot_role pr,
    (dummyt d1  WITH seq = value(cnvtint(size(reply->role_list,5))))
   SET pr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pr.updt_cnt = (pr.updt_cnt+ 1), pr
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pr.updt_id = reqinfo->updt_id, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->
    updt_task
   PLAN (d1)
    JOIN (pr
    WHERE (pr.prot_role_id=reply->role_list[d1.seq].prot_role_id))
   WITH nocounter
  ;end update
  CALL echo(build("Curqual for update1 is: ",curqual))
  IF (curqual=0)
   SET fail_flag = update_prot_role_error
   GO TO check_error
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ea.*
  FROM entity_access ea,
   prot_amendment pa,
   prot_role pr,
   (dummyt d1  WITH seq = value(cnvtint(size(request->person_list,5)))),
   (dummyt d2  WITH seq = value(cnvtint(size(request->person_list[(row+ 1)].protocols,5)))),
   dummyt d3,
   dummyt d4
  PLAN (d1)
   JOIN (d2)
   JOIN (pa
   WHERE (pa.prot_master_id=request->person_list[d1.seq].protocols[d2.seq].prot_master_id))
   JOIN (ea
   WHERE (ea.person_id=request->person_list[d1.seq].person_id)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.prot_amendment_id=pa.prot_amendment_id)
   JOIN (d3)
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND (pr.person_id=request->person_list[d1.seq].person_id)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d4)
  HEAD ea.person_id
   person_updt_cnt = (person_updt_cnt+ 1)
   IF (mod(person_updt_cnt,10)=1)
    stat = alterlist(reply->person_access_list,(person_updt_cnt+ 9))
   ENDIF
   reply->person_access_list[person_updt_cnt].person_id = ea.person_id, ea_updt_cnt = 0, stat =
   alterlist(reply->person_access_list[person_updt_cnt].entity_access_list,ea_updt_cnt)
  DETAIL
   IF (pr.prot_role_id=0.0)
    ea_updt_cnt = (ea_updt_cnt+ 1)
    IF (mod(ea_updt_cnt,10)=1)
     stat = alterlist(reply->person_access_list[person_updt_cnt].entity_access_list,(ea_updt_cnt+ 9))
    ENDIF
    reply->person_access_list[person_updt_cnt].entity_access_list[ea_updt_cnt].entity_access_id = ea
    .entity_access_id, reply->person_access_list[person_updt_cnt].entity_access_list[ea_updt_cnt].
    prot_amendment_id = ea.prot_amendment_id, reply->person_access_list[person_updt_cnt].
    entity_access_list[ea_updt_cnt].functionality_cd = ea.functionality_cd,
    reply->person_access_list[person_updt_cnt].entity_access_list[ea_updt_cnt].access_mask = ea
    .access_mask
   ENDIF
  FOOT  ea.person_id
   stat = alterlist(reply->person_access_list[person_updt_cnt].entity_access_list,ea_updt_cnt)
  WITH nocounter, dontcare = pr
 ;end select
 SET stat = alterlist(reply->person_access_list,person_updt_cnt)
 CALL echo(build("Person update is: ",person_updt_cnt))
 IF (person_updt_cnt > 0)
  IF (ea_updt_cnt > 0)
   IF (curqual=0)
    SET fail_flag = lock_entity_access_error
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
 IF (person_updt_cnt > 0
  AND ea_updt_cnt > 0)
  UPDATE  FROM entity_access ea,
    (dummyt d1  WITH seq = value(cnvtint(size(reply->person_access_list,5)))),
    (dummyt d2  WITH seq = value(cnvtint(size(reply->person_access_list[(row+ 1)].entity_access_list,
       5))))
   SET ea.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ea.updt_cnt = (ea.updt_cnt+ 1), ea
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ea.updt_id = reqinfo->updt_id, ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo->
    updt_task
   PLAN (d1)
    JOIN (d2)
    JOIN (ea
    WHERE (ea.entity_access_id=reply->person_access_list[d1.seq].entity_access_list[d2.seq].
    entity_access_id))
   WITH nocounter
  ;end update
  CALL echo(build("Curqual for entity update is: ",curqual))
  IF (curqual=0)
   SET fail_flag = update_entity_access_error
   GO TO check_error
  ENDIF
 ENDIF
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
   OF person_in_request:
    SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectname = "QUAL"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No items in qual list in request"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "003"
 SET mod_date = "August 10, 2009"
END GO
