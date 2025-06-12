CREATE PROGRAM aps_get_dc_prsnl_grp_prsnl:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
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
 IF ((request->study_id=0))
  SELECT INTO "nl:"
   pgr.prsnl_group_id, p.person_id
   FROM prsnl_group_reltn pgr,
    prsnl p
   PLAN (pgr
    WHERE (request->prsnl_grp_id=pgr.prsnl_group_id)
     AND 1=pgr.active_ind)
    JOIN (p
    WHERE pgr.person_id=p.person_id
     AND 1=p.active_ind)
   HEAD REPORT
    pcnt = 0, stat = alterlist(reply->qual,10)
   DETAIL
    pcnt = (pcnt+ 1)
    IF (mod(pcnt,10)=1
     AND pcnt != 1)
     stat = alterlist(reply->qual,(pcnt+ 9))
    ENDIF
    reply->qual[pcnt].name_full_formatted = p.name_full_formatted, reply->qual[pcnt].person_id = p
    .person_id
   FOOT REPORT
    stat = alterlist(reply->qual,pcnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   CALL handle_errors("SELECT","Z","TABLE","PRSNL_GROUP")
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   ade.study_id
   FROM ap_dc_event ade,
    ap_dc_event_prsnl adep,
    prsnl p
   PLAN (ade
    WHERE (request->study_id=ade.study_id)
     AND (request->eval_case_id=ade.case_id)
     AND (request->corr_case_id=ade.correlate_case_id)
     AND (request->prsnl_grp_id=ade.prsnl_group_id))
    JOIN (adep
    WHERE ade.event_id=adep.event_id
     AND (request->prsnl_grp_id=adep.prsnl_group_id))
    JOIN (p
    WHERE adep.prsnl_id=p.person_id)
   HEAD REPORT
    pcnt = 0, stat = alterlist(reply->qual,10)
   DETAIL
    pcnt = (pcnt+ 1)
    IF (mod(pcnt,10)=1
     AND pcnt != 1)
     stat = alterlist(reply->qual,(pcnt+ 9))
    ENDIF
    reply->qual[pcnt].name_full_formatted = p.name_full_formatted, reply->qual[pcnt].person_id = p
    .person_id
   FOOT REPORT
    stat = alterlist(reply->qual,pcnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   CALL handle_errors("SELECT","Z","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
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
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(build("errors->",error_cnt))
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
