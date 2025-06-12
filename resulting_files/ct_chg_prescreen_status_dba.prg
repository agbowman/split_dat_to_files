CREATE PROGRAM ct_chg_prescreen_status:dba
 RECORD audit(
   1 pt_prot_prescreen_id = f8
   1 updt_dt_tm = dq8
   1 person_id = f8
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE audit_mode = i2 WITH protect, noconstant(0)
 DECLARE participantname = vc WITH protect, noconstant("")
 DECLARE prescreen_id = vc WITH protect, noconstant("")
 DECLARE lst_updt_dt_tm = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 IF ((request->pt_prot_prescreen_id > 0))
  CALL updateprotprecreenrecord(request->pt_prot_prescreen_id,request->status_cd,request->
   status_comment_text)
 ELSE
  SET cnt = size(request->qual,5)
  FOR (idx = 1 TO cnt)
    CALL updateprotprecreenrecord(request->qual[idx].pt_prot_prescreen_id,request->qual[idx].
     status_cd,request->qual[idx].status_comment_text)
  ENDFOR
 ENDIF
 SUBROUTINE (updateprotprecreenrecord(pt_prot_prescreen_id=f8,status_cd=f8,status_comment_text=vc) =
  i2)
   DECLARE status_mean = c12 WITH protect, noconstant(fillstring(12," "))
   DECLARE status_disp = c40 WITH protect, noconstant(fillstring(40," "))
   DECLARE status_dt_tm = vc WITH protect
   DECLARE full_comment_text = vc WITH protect
   DECLARE new_comment_text = vc WITH protect
   DECLARE referral_person = vc WITH protect
   DECLARE reason_comment = vc WITH protect
   SELECT INTO "NL:"
    FROM pt_prot_prescreen pps
    WHERE pps.pt_prot_prescreen_id=pt_prot_prescreen_id
    DETAIL
     reason_comment = trim(pps.reason_text,2), audit->pt_prot_prescreen_id = pps.pt_prot_prescreen_id,
     audit->updt_dt_tm = pps.updt_dt_tm,
     audit->person_id = pps.person_id
    WITH nocounter, forupdate(pps)
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     p.name_full_formatted
     FROM person p
     WHERE (p.person_id=reqinfo->updt_id)
     DETAIL
      referral_person = p.name_full_formatted
     WITH nocounter
    ;end select
    SET status_disp = uar_get_code_display(request->status_cd)
    SET status_mean = uar_get_code_meaning(request->status_cd)
    SET status_dt_tm = format(cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM:SS;;D")
    SET full_comment_text = concat("(",trim(status_disp)," on ",trim(status_dt_tm)," by ",
     trim(referral_person),") ",trim(status_comment_text))
    IF (reason_comment="")
     SET new_comment_text = full_comment_text
    ELSE
     SET new_comment_text = concat(full_comment_text,char(13),char(13),reason_comment)
    ENDIF
    CALL echo(new_comment_text)
    UPDATE  FROM pt_prot_prescreen pps
     SET pps.screening_status_cd = status_cd, pps.reason_text = new_comment_text, pps
      .referred_person_id =
      IF (status_mean="REFERRED") reqinfo->updt_id
      ELSE pps.referred_person_id
      ENDIF
      ,
      pps.referred_dt_tm =
      IF (status_mean="REFERRED") cnvtdatetime(sysdate)
      ELSE pps.referred_dt_tm
      ENDIF
      , pps.updt_dt_tm = cnvtdatetime(sysdate), pps.updt_id = reqinfo->updt_id,
      pps.updt_task = reqinfo->updt_task, pps.updt_applctx = reqinfo->updt_applctx, pps.updt_cnt = (
      pps.updt_cnt+ 1)
     WHERE pps.pt_prot_prescreen_id=pt_prot_prescreen_id
    ;end update
    IF (curqual=0)
     SET failed = "T"
     CALL echo("Failed to update row in pt_prot_prescreen table.")
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = "T"
    CALL echo("Failed to lock row in pt_prot_prescreen table.")
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  IF ((request->pt_prot_prescreen_id > 0))
   SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(audit->updt_dt_tm,0,
     "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
   SET prescreen_id = build3(3,"PT_PROTOCOL_PRESCREEN_ID: ",audit->pt_prot_prescreen_id)
   SET participantname = concat(prescreen_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
   EXECUTE cclaudit audit_mode, "Prescreened_Status", "Modify",
   "Person", "Patient", "Patient",
   "Amendment", audit->person_id, participantname
  ENDIF
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "004"
 SET mod_date = "March 21, 2022"
END GO
