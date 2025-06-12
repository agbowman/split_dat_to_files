CREATE PROGRAM aps_get_cyto_prev_screen:dba
 RECORD reply(
   1 screener_qual[*]
     2 sequence = i4
     2 screener_id = f8
     2 screen_dt_tm = dq8
     2 initial_screener_ind = i2
     2 split_ind = i2
     2 specimen_grouping_cd = f8
     2 reference_range_factor_id = f8
     2 diagnostic_category_cd = f8
     2 endocerv_ind = i2
     2 adequacy_flag = i2
     2 standard_rpt_cd = f8
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 nomenclature_id = f8
     2 verify_ind = i2
     2 review_reason_flag = i2
     2 updt_cnt = i4
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
 SET cnt = 0
 SELECT INTO "nl:"
  cse.sequence
  FROM cyto_screening_event cse
  WHERE (request->case_id=cse.case_id)
   AND 1=cse.active_ind
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->screener_qual[cnt].sequence = cse.sequence, reply->screener_qual[cnt].
   screener_id = cse.screener_id,
   reply->screener_qual[cnt].screen_dt_tm = cse.screen_dt_tm, reply->screener_qual[cnt].
   initial_screener_ind = cse.initial_screener_ind, reply->screener_qual[cnt].split_ind = cse
   .split_ind,
   reply->screener_qual[cnt].specimen_grouping_cd = cse.specimen_grouping_cd, reply->screener_qual[
   cnt].reference_range_factor_id = cse.reference_range_factor_id, reply->screener_qual[cnt].
   endocerv_ind = cse.endocerv_ind,
   reply->screener_qual[cnt].adequacy_flag = cse.adequacy_flag, reply->screener_qual[cnt].
   standard_rpt_cd = cse.standard_rpt_id, reply->screener_qual[cnt].event_id = cse.event_id,
   reply->screener_qual[cnt].valid_from_dt_tm = cse.valid_from_dt_tm, reply->screener_qual[cnt].
   nomenclature_id = cse.nomenclature_id, reply->screener_qual[cnt].diagnostic_category_cd = cse
   .diagnostic_category_cd,
   reply->screener_qual[cnt].verify_ind = cse.verify_ind, reply->screener_qual[cnt].
   review_reason_flag = cse.review_reason_flag, reply->screener_qual[cnt].updt_cnt = cse.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","CYTO_SCREENING_EVENT")
  SET reply->status_data.status = "Z"
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
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
