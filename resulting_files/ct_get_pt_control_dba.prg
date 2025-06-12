CREATE PROGRAM ct_get_pt_control:dba
 RECORD reply(
   1 qual[*]
     2 pt_control_id = f8
     2 follow_up_status = vc
     2 initial_prot_enroll_status = vc
     2 reason_for_no_prot_enroll = vc
     2 pt_status = vc
     2 change_dt_tm = dq8
     2 not_on_prot_comment_txt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET counter = 0
 DECLARE audit_mode = i2 WITH protect, constant(0)
 SELECT INTO "nl:"
  pc.person_id
  FROM pt_control pc
  WHERE (pc.person_id=request->personid)
  ORDER BY cnvtdatetime(pc.end_effective_dt_tm)
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   counter += 1
   IF (mod(counter,10)=1
    AND counter != 1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].pt_control_id = pc.pt_control_id, reply->qual[counter].change_dt_tm = pc
   .change_dt_tm, reply->qual[counter].not_on_prot_comment_txt = pc.not_on_prot_comment_txt,
   reply->qual[counter].follow_up_status = uar_get_code_display(pc.follow_up_status_cd), reply->qual[
   counter].initial_prot_enroll_status = uar_get_code_display(pc.initial_prot_enroll_status_cd),
   reply->qual[counter].reason_for_no_prot_enroll = uar_get_code_display(pc
    .reason_for_no_prot_enroll_cd),
   reply->qual[counter].pt_status = uar_get_code_display(pc.pt_status_cd)
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("there were no records for the selected person")
  GO TO exit_script
 ELSE
  CALL echo(build("number of records for this person: ",counter))
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->personid > 0))
  EXECUTE cclaudit audit_mode, "Psinfo_view", "View",
  "Person", "Patient", "Patient",
  "AccessUse", request->personid, ""
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
END GO
