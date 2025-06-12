CREATE PROGRAM dcp_del_dtawizard_dtainfo:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 ref_range_qual[*]
     2 ref_range_id = f8
 )
 SET failed = "F"
 SET ref_range_cnt = 0
 DECLARE num_alphas = i2
 SET num_alphas = 0
 DECLARE io_total_group_id = f8 WITH noconstant(0.0)
 IF ((request->task_assay_cd=0))
  SET failed = "T"
  SET reply->status_data.targetobjectvalue = "Attempted to use a task_assay_cd of zero."
  GO TO exit_script
 ENDIF
 DELETE  FROM data_map d
  WHERE (d.task_assay_cd=request->task_assay_cd)
  WITH nocounter
 ;end delete
 CALL parser("rdb alter table code_value disable all triggers go")
 DELETE  FROM code_value c
  WHERE c.code_set=14003
   AND (c.code_value=request->task_assay_cd)
  WITH nocounter
 ;end delete
 CALL parser("rdb alter table code_value enable all triggers go")
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.targetobjectvalue = "Failed to delete task_assay_cd from code_value table."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  r.reference_range_factor_id
  FROM reference_range_factor r
  WHERE (r.task_assay_cd=request->task_assay_cd)
  HEAD REPORT
   ref_range_cnt = ref_range_cnt
  DETAIL
   ref_range_cnt = (ref_range_cnt+ 1)
   IF (ref_range_cnt > size(internal->ref_range_qual,5))
    stat = alterlist(internal->ref_range_qual,(ref_range_cnt+ 10))
   ENDIF
   internal->ref_range_qual[ref_range_cnt].ref_range_id = r.reference_range_factor_id
  FOOT REPORT
   stat = alterlist(internal->ref_range_qual,ref_range_cnt)
  WITH nocounter
 ;end select
 IF (ref_range_cnt=0)
  GO TO continue
 ENDIF
 SELECT INTO "nl:"
  FROM alpha_responses a,
   (dummyt d  WITH seq = value(ref_range_cnt))
  PLAN (d)
   JOIN (a
   WHERE (a.reference_range_factor_id=internal->qual[d.seq].ref_range_id))
  WITH nocounter
 ;end select
 SET num_alphas = curqual
 DELETE  FROM alpha_responses a,
   (dummyt d1  WITH seq = value(ref_range_cnt))
  SET a.seq = 1
  PLAN (d1)
   JOIN (a
   WHERE (a.reference_range_factor_id=internal->ref_range_qual[d1.seq].ref_range_id))
  WITH nocounter
 ;end delete
 IF (curqual != num_alphas)
  SET failed = "T"
  SET reply->status_data.targetobjectvalue =
  "Number of alpha details to delete does not equal number deleted."
  GO TO exit_script
 ENDIF
 DELETE  FROM reference_range_factor r,
   (dummyt d2  WITH seq = value(ref_range_cnt))
  SET r.seq = 1
  PLAN (d2)
   JOIN (r
   WHERE (r.reference_range_factor_id=internal->ref_range_qual[d2.seq].ref_range_id)
    AND r.reference_range_factor_id > 0)
  WITH nocounter
 ;end delete
 IF (curqual != value(ref_range_cnt))
  SET failed = "T"
  SET reply->status_data.targetobjectvalue =
  "Number of ref ranges to delete does not equal number deleted."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM io_total_definition i
  WHERE (i.task_assay_cd=request->task_assay_cd)
   AND i.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   io_total_group_id = i.io_total_group_id
  WITH nocounter
 ;end select
 IF (io_total_group_id > 0.0)
  DELETE  FROM io_total_definition i
   SET i.seq = 1
   WHERE i.io_total_group_id=io_total_group_id
   WITH nocounter
  ;end delete
  DELETE  FROM io_def_element_reltn ier
   SET ier.seq = 1
   WHERE ier.io_total_group_id=io_total_group_id
   WITH nocounter
  ;end delete
  DELETE  FROM io_total_group_definition ig
   SET ig.seq = 1
   WHERE ig.io_total_group_id=io_total_group_id
   WITH nocounter
  ;end delete
 ENDIF
#continue
 DELETE  FROM discrete_task_assay d
  WHERE (d.task_assay_cd=request->task_assay_cd)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.targetobjectvalue =
  "Failed to delete task_assay_cd from discrete_task_assay table."
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.targetobjectname = "DCP_DTAWIZARD"
  SET reply->status_data.operationname = "DEL"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
