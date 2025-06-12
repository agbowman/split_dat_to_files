CREATE PROGRAM ct_add_pt_control:dba
 RECORD audit(
   1 updt_dt_tm = dq8
   1 pt_status = f8
   1 follow_up_status = f8
   1 initial_prot_enroll_status = f8
   1 reason_for_no_prot_enroll = f8
   1 change_dt_tm = dq8
 )
 RECORD reply(
   1 ptcontrol_id = f8
   1 beg_effective_dt_tm = dq8
   1 change_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE pt_control_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE participant_name = vc WITH public, noconstant("")
 DECLARE ptcontrol_id = vc WITH public, noconstant("")
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm = vc WITH public, noconstant("")
 SET reply->status_data.status = "F"
 SET reply->ptcontrol_id = 0.0
 SET failed = "F"
 SET reply->beg_effective_dt_tm = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  pc.pt_control_id
  FROM pt_control pc
  WHERE (pc.person_id=request->personid)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  CALL echo("this is a new patient")
  SELECT INTO "nl:"
   nextseqnum = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    pt_control_id = nextseqnum
   WITH format, nocounter
  ;end select
  SET reply->ptcontrol_id = pt_control_id
  INSERT  FROM pt_control pc
   SET pc.pt_control_id = pt_control_id, pc.person_id = request->personid, pc
    .initial_prot_enroll_status_cd = request->initial_prot_enroll_status,
    pc.reason_for_no_prot_enroll_cd = request->reason_for_no_prot_enroll, pc.follow_up_status_cd =
    request->follow_up_status, pc.pt_status_cd = request->pt_status,
    pc.change_dt_tm = cnvtdatetime(cnvtdate2(request->change_dt_tm,"YYYYMMDD"),0), pc
    .beg_effective_dt_tm = cnvtdatetime(reply->beg_effective_dt_tm), pc.end_effective_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00.00"),
    pc.not_on_prot_comment_txt = request->not_on_prot_comment_txt, pc.updt_dt_tm = cnvtdatetime(
     sysdate), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL echo("failed to insert new row for new person")
   GO TO exit_script
  ELSEIF ((((request->pt_status > 0)) OR ((((request->follow_up_status > 0)) OR ((((request->
  initial_prot_enroll_status > 0)) OR ((request->reason_for_no_prot_enroll > 0))) )) )) )
   EXECUTE cclaudit audit_mode, "Psinfo_add", "Add",
   "Person", "Patient", "Patient",
   "Origination", request->personid, ""
  ENDIF
 ELSE
  CALL echo("the patient already exists")
  SELECT
   pc.updt_dt_tm, pc.pt_status_cd
   FROM pt_control pc
   WHERE (pc.pt_control_id=request->ptcontrolid)
   DETAIL
    audit->updt_dt_tm = pc.updt_dt_tm, audit->pt_status = pc.pt_status_cd, audit->follow_up_status =
    pc.follow_up_status_cd,
    audit->initial_prot_enroll_status = pc.initial_prot_enroll_status_cd, audit->change_dt_tm = pc
    .change_dt_tm, audit->reason_for_no_prot_enroll = pc.reason_for_no_prot_enroll_cd
  ;end select
  SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(audit->updt_dt_tm,0,
    "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
  CALL echo("Updating old record into Patient Control ")
  UPDATE  FROM pt_control pc
   SET pc.end_effective_dt_tm = cnvtdatetime(reply->beg_effective_dt_tm), pc.updt_dt_tm =
    cnvtdatetime(sysdate), pc.updt_cnt = (pc.updt_cnt+ 1),
    pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->
    updt_applctx
   WHERE (pc.pt_control_id=request->ptcontrolid)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL echo("failed to update old row")
   GO TO exit_script
  ELSEIF (curqual=1)
   CALL echo("updated old row in patient control")
  ENDIF
  CALL echo("now creating new record for existing patient")
  SELECT INTO "nl:"
   nextseqnum = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    pt_control_id = nextseqnum
   WITH format, nocounter
  ;end select
  SET reply->ptcontrol_id = pt_control_id
  INSERT  FROM pt_control pc
   SET pc.pt_control_id = pt_control_id, pc.person_id = request->personid, pc
    .initial_prot_enroll_status_cd = request->initial_prot_enroll_status,
    pc.reason_for_no_prot_enroll_cd = request->reason_for_no_prot_enroll, pc.follow_up_status_cd =
    request->follow_up_status, pc.pt_status_cd = request->pt_status,
    pc.change_dt_tm = cnvtdatetime(cnvtdate2(request->change_dt_tm,"YYYYMMDD"),0), pc
    .beg_effective_dt_tm = cnvtdatetime(reply->beg_effective_dt_tm), pc.end_effective_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00.00"),
    pc.not_on_prot_comment_txt = request->not_on_prot_comment_txt, pc.updt_dt_tm = cnvtdatetime(
     sysdate), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL echo("failed to insert new row for already existing person")
   GO TO exit_script
  ELSEIF (curqual=1)
   CALL echo("Success in inserting new row for existing person")
   IF ((((audit->pt_status != request->pt_status)) OR ((((audit->follow_up_status != request->
   follow_up_status)) OR ((((audit->initial_prot_enroll_status != request->initial_prot_enroll_status
   )) OR ((((audit->change_dt_tm != cnvtdatetime(cnvtdate2(request->change_dt_tm,"YYYYMMDD"),0))) OR
   ((audit->reason_for_no_prot_enroll != request->reason_for_no_prot_enroll))) )) )) )) )
    SET ptcontrol_id = build3(3,"PT_CONTROL_ID: ",pt_control_id)
    SET participant_name = concat(ptcontrol_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
    EXECUTE cclaudit audit_mode, "Psinfo_modify", "Modify",
    "Person", "Patient", "Patient",
    "Amendment", request->personid, participant_name
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "002"
 SET mod_date = "Jul 1, 2019"
END GO
