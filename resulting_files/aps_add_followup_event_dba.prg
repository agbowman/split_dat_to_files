CREATE PROGRAM aps_add_followup_event:dba
 RECORD reply(
   1 person_id = f8
   1 followup_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 DECLARE new_followup_event_id = f8 WITH protect, noconstant(0.0)
 SET reply->person_id = reqinfo->updt_id
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_followup_event_id = seq_nbr, reply->followup_event_id = new_followup_event_id
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","PATHNET_SEQ")
  GO TO exit_script
 ENDIF
 INSERT  FROM ap_ft_event fte
  SET fte.followup_event_id = new_followup_event_id, fte.case_id = request->case_id, fte
   .followup_type_cd = request->followup_type_cd,
   fte.expected_term_dt = cnvtdatetime(request->expected_term_dt), fte.initial_notif_dt_tm =
   cnvtdatetime(request->initial_notif_dt_tm), fte.first_overdue_dt_tm = cnvtdatetime(request->
    first_overdue_dt_tm),
   fte.final_overdue_dt_tm = cnvtdatetime(request->final_overdue_dt_tm), fte.initial_notif_print_flag
    = 0, fte.first_overdue_print_flag = 0,
   fte.final_overdue_print_flag = 0, fte.person_id = request->person_id, fte.origin_flag = 1,
   fte.origin_dt_tm = cnvtdatetime(curdate,curtime), fte.origin_prsnl_id = reqinfo->updt_id, fte
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   fte.updt_id = reqinfo->updt_id, fte.updt_task = reqinfo->updt_task, fte.updt_applctx = reqinfo->
   updt_applctx,
   fte.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL handle_errors("INSERT","F","TABLE","AP_FT_EVENT")
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_cd = 0
  SET reply->status_disp = ""
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("***** commit *****")
 ENDIF
#end_of_program
END GO
