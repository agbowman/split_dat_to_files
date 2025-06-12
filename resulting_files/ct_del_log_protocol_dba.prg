CREATE PROGRAM ct_del_log_protocol:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET fail_flag = 0
 SET reply->status_data.status = "F"
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 UPDATE  FROM prot_master pm
  SET pm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE (pm.parent_prot_master_id=request->protid)
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error deleting from prot_master table."
  SET fail_flag = delete_error
  GO TO check_error
 ENDIF
 INSERT  FROM ct_prot_reason_deleted del
  SET del.parent_prot_master_id = request->protid, del.ct_prot_reason_deleted_id = seq(
    protocol_def_seq,nextval), del.deletion_prsnl_id = reqinfo->updt_id,
   del.deletion_dt_tm = cnvtdatetime(curdate,curtime3), del.deletion_reason_txt = request->reason,
   del.updt_cnt = 0,
   del.updt_applctx = reqinfo->updt_applctx, del.updt_task = reqinfo->updt_task, del.updt_id =
   reqinfo->updt_id,
   del.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting into ct_prot_reason_deleted."
  SET fail_flag = insert_error
  GO TO check_error
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
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Sept 11, 2017"
END GO
