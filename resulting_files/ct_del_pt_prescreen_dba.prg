CREATE PROGRAM ct_del_pt_prescreen:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD audit(
   1 qual[*]
     2 pt_prot_prescreen_id = f8
     2 updt_dt_tm = dq8
     2 person_id = f8
 )
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE auditcnt = i2 WITH protect, noconstant(0)
 DECLARE numofinsert = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE audit_mode = i2 WITH protect, noconstant(0)
 DECLARE participantname = vc WITH protect, noconstant("")
 DECLARE prescreen_id = vc WITH protect, noconstant("")
 DECLARE lst_updt_dt_tm = vc WITH protect, noconstant("")
 SET numofinserts = size(request->persons,5)
 SET stat = alterlist(audit->qual,numofinserts)
 SET fail_flag = 0
 SET reply->status_data.status = "F"
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 SELECT
  pps.person_id, pps.pt_prot_prescreen_id, pps.updt_dt_tm
  FROM pt_prot_prescreen pps
  WHERE expand(i,1,numofinserts,pps.person_id,request->persons[i].personid,
   pps.prot_master_id,request->protmasterid)
  DETAIL
   auditcnt += 1, audit->qual[auditcnt].person_id = pps.person_id, audit->qual[auditcnt].
   pt_prot_prescreen_id = pps.pt_prot_prescreen_id,
   audit->qual[auditcnt].updt_dt_tm = pps.updt_dt_tm
  WITH expand = 2, nocounter
 ;end select
 FOR (i = 1 TO numofinserts)
   DELETE  FROM pt_prot_prescreen p_p_p
    WHERE (p_p_p.person_id=request->persons[i].personid)
     AND (p_p_p.prot_master_id=request->protmasterid)
   ;end delete
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error deleting pt_prot_prescreen table."
    SET fail_flag = delete_error
    GO TO check_error
   ENDIF
   INSERT  FROM ct_reason_deleted del
    SET del.person_id = request->persons[i].personid, del.prot_master_id = request->protmasterid, del
     .ct_reason_del_id = seq(protocol_def_seq,nextval),
     del.deletion_dt_tm = cnvtdatetime(sysdate), del.deletion_reason = request->reason, del.updt_cnt
      = 0,
     del.updt_applctx = reqinfo->updt_applctx, del.updt_task = reqinfo->updt_task, del.updt_id =
     reqinfo->updt_id,
     del.updt_dt_tm = cnvtdatetime(sysdate), del.active_ind = 1, del.active_status_cd = reqdata->
     active_status_cd,
     del.active_status_dt_tm = cnvtdatetime(sysdate), del.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error inserting into ct_reason_deleted table."
    SET fail_flag = insert_error
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
  SET audit_mode = 0
  FOR (auditcnt = 1 TO numofinserts)
    SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(audit->qual[auditcnt].updt_dt_tm,
      0,"MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
    SET prescreen_id = build3(3,"PT_PROTOCOL_PRESCREEN_ID: ",audit->qual[auditcnt].
     pt_prot_prescreen_id)
    SET participantname = concat(prescreen_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
    EXECUTE cclaudit audit_mode, "Prescreened_Delete", "Delete",
    "Person", "Patient", "Patient",
    "Destruction", audit->qual[auditcnt].person_id, participantname
  ENDFOR
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "001"
 SET mod_date = "May 20, 2019"
END GO
