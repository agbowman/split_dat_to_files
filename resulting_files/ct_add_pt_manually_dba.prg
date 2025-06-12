CREATE PROGRAM ct_add_pt_manually:dba
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
 DECLARE pt_prot_prescreen_id = f8 WITH protect, noconstant(0.0)
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE added_by_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE audit_mode = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE insert_error = i2 WITH private, constant(20)
 DECLARE duplicate_error = i2 WITH private, constant(30)
 SELECT INTO "nl:"
  FROM pt_prot_prescreen pt
  WHERE (pt.prot_master_id=request->protid)
   AND (pt.person_id=request->personid)
   AND pt.screening_status_cd != syscancel_cd
  DETAIL
   person_exists_ind = 1
  WITH nocounter
 ;end select
 IF (person_exists_ind=1)
  SET fail_flag = duplicate_error
  GO TO check_error
 ENDIF
 IF ( NOT (curenv))
  SET added_by_id = 0.0
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.username=curuser
    AND p.active_ind=1
   DETAIL
    added_by_id = p.person_id
   WITH nocounter
  ;end select
 ELSE
  SET added_by_id = reqinfo->updt_id
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   pt_prot_prescreen_id = cnvtreal(num)
  WITH format, counter
 ;end select
 INSERT  FROM pt_prot_prescreen ppp
  SET ppp.person_id = request->personid, ppp.added_via_flag = 1, ppp.pt_prot_prescreen_id =
   pt_prot_prescreen_id,
   ppp.prot_master_id = request->protid, ppp.screener_person_id = added_by_id, ppp
   .screening_status_cd = pending_cd,
   ppp.screened_dt_tm = cnvtdatetime(sysdate), ppp.updt_cnt = 0, ppp.updt_applctx = reqinfo->
   updt_applctx,
   ppp.updt_task = reqinfo->updt_task, ppp.updt_id = reqinfo->updt_id, ppp.updt_dt_tm = cnvtdatetime(
    sysdate)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error inserting into pt_prot_prescreen table."
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
  SET audit_mode = 0
  EXECUTE cclaudit audit_mode, "Prescreened_Manual", "Add",
  "Person", "Patient", "Patient",
  "Origination", request->personid, ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "I"
   OF duplicate_error:
    SET reply->status_data.status = "D"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Duplicate error."
    SET reply->status_data.subeventstatus[1].operationstatus = "D"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "U"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "002"
 SET mod_date = "MAY 20, 2019"
END GO
