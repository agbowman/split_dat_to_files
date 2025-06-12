CREATE PROGRAM ct_chg_screener_access:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE insert_error = i2 WITH private, constant(2)
 DECLARE all_access = c5 WITH protect, constant("RCUDE")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE entity_access_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE screening_cd = f8 WITH protect, noconstant(0.0)
 DECLARE list_cnt = i2 WITH protect, noconstant(0)
 DECLARE screening_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17311,"PRESCREEN"))
 SET reply->status_data.status = "F"
 SET list_cnt = size(request->person_list,5)
 FOR (i = 1 TO list_cnt)
  SET entity_access_id = 0.0
  IF ((request->person_list[i].action_ind=1))
   CALL echo("new row")
   SELECT INTO "nl:"
    ea.*
    FROM entity_access ea
    WHERE ea.functionality_cd=screening_cd
     AND (ea.person_id=request->person_list[i].person_id)
     AND (ea.prot_amendment_id=request->person_list[i].prot_amendment_id)
     AND ea.access_mask=all_access
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     entity_access_id = ea.entity_access_id
    WITH nocounter
   ;end select
   IF (entity_access_id=0.0)
    INSERT  FROM entity_access ro
     SET ro.entity_access_id = seq(protocol_def_seq,nextval), ro.prot_amendment_id = request->
      person_list[i].prot_amendment_id, ro.person_id = request->person_list[i].person_id,
      ro.functionality_cd = screening_cd, ro.access_mask = all_access, ro.beg_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ro.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ro.updt_id = reqinfo->updt_id,
      ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo->updt_task, ro.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error inserting into entity_access table."
     SET fail_flag = insert_error
     GO TO check_error
    ENDIF
   ENDIF
  ELSE
   CALL echo("delete req")
   SELECT INTO "nl:"
    ea.*
    FROM entity_access ea
    WHERE ea.functionality_cd=screening_cd
     AND (ea.person_id=request->person_list[i].person_id)
     AND (ea.prot_amendment_id=request->person_list[i].prot_amendment_id)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     entity_access_id = ea.entity_access_id
    WITH nocounter, forupdate(ea)
   ;end select
   IF (curqual > 0
    AND entity_access_id > 0.0)
    UPDATE  FROM entity_access ea
     SET ea.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ea.updt_dt_tm = cnvtdatetime(
       curdate,curtime), ea.updt_id = reqinfo->updt_id,
      ea.updt_cnt = (ea.updt_cnt+ 1)
     WHERE ea.entity_access_id=entity_access_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error logically deleting from entity_access table."
     SET fail_flag = update_error
     GO TO check_error
    ENDIF
   ELSE
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error locking entity_access table."
    SET fail_flag = lock_error
    GO TO check_error
   ENDIF
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
  CALL echo("fail_flag != 0")
  CASE (fail_flag)
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "August 5, 2008"
END GO
