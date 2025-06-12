CREATE PROGRAM ct_chg_pt_settings:dba
 RECORD reply(
   1 not_interested_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE add_ind = i2 WITH protect, noconstant(0)
 DECLARE interest_add_ind = i2 WITH protect, noconstant(0)
 DECLARE participant_name = vc WITH protect, noconstant("")
 DECLARE ct_pt_settings_id = i4 WITH protect, noconstant(0)
 DECLARE settings_id = vc WITH protect, noconstant("")
 DECLARE audit_mode = i2 WITH protect, noconstant(0)
 DECLARE last_interest_updt_dt_tm = dq8 WITH protect
 DECLARE lst_updt_dt_tm = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM ct_pt_settings cts
  WHERE (cts.person_id=request->person_id)
   AND cts.active_ind=1
  DETAIL
   last_interest_updt_dt_tm = cts.not_interested_dt_tm, ct_pt_settings_id = cts.ct_pt_settings_id
  WITH nocounter, forupdate(cts)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM ct_pt_settings cts
   SET cts.active_ind = 0, cts.updt_dt_tm = cnvtdatetime(sysdate), cts.updt_id = reqinfo->updt_id,
    cts.updt_task = reqinfo->updt_task, cts.updt_applctx = reqinfo->updt_applctx, cts.updt_cnt = (cts
    .updt_cnt+ 1)
   WHERE (cts.person_id=request->person_id)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL echo("Failed to update row in ct_pt_settings table.")
   GO TO exit_script
  ELSE
   SET add_ind = 1
  ENDIF
 ELSE
  SET add_ind = 1
  SET interest_add_ind = 1
 ENDIF
 IF (add_ind=1)
  INSERT  FROM ct_pt_settings cts
   SET cts.ct_pt_settings_id = seq(protocol_def_seq,nextval), cts.person_id = request->person_id, cts
    .not_interested_ind = request->not_interested_ind,
    cts.not_interested_dt_tm = cnvtdatetime(sysdate), cts.not_interested_prsnl_id = reqinfo->updt_id,
    cts.updt_dt_tm = cnvtdatetime(sysdate),
    cts.updt_id = reqinfo->updt_id, cts.updt_task = reqinfo->updt_task, cts.updt_applctx = reqinfo->
    updt_applctx,
    cts.updt_cnt = 0, cts.active_ind = 1
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL echo("Failed to insert row in ct_pt_settings table.")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->not_interested_dt_tm = cnvtdatetime(sysdate)
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
 IF ((reply->status_data.status="S"))
  SET audit_mode = 0
  IF (interest_add_ind=1)
   EXECUTE cclaudit audit_mode, "Prescreen_Interest_Add", "Add",
   "Person", "Patient", "Patient",
   "Origination / Creation", request->person_id, ""
  ELSE
   SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(last_interest_updt_dt_tm,0,
     "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   SET settings_id = build3(3,"CT_PT_SETTINGS_ID: ",ct_pt_settings_id)
   SET participant_name = concat(settings_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
   EXECUTE cclaudit audit_mode, "PS_Interest_Change", "Modify",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, participant_name
  ENDIF
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "003"
 SET mod_date = "May 06, 2019"
END GO
