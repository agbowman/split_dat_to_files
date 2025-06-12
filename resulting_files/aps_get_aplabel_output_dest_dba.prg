CREATE PROGRAM aps_get_aplabel_output_dest:dba
 RECORD reply(
   1 qual[*]
     2 output_dest_cd = f8
     2 description = vc
     2 label_prog_name = vc
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
 SELECT INTO "nl:"
  o.*
  FROM output_dest o
  WHERE "APSLABEL"=o.label_prefix
  HEAD REPORT
   ocnt = 0
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(reply->qual,ocnt), reply->qual[ocnt].output_dest_cd = o
   .output_dest_cd,
   reply->qual[ocnt].description = o.description, reply->qual[ocnt].label_prog_name = o
   .label_program_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "P"
  CALL handle_errors("SELECT","F","TABLE","OUTPUT_DEST")
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
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
