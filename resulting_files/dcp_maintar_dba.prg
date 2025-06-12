CREATE PROGRAM dcp_maintar:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET ar_cnt = request->ar_cnt
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 SELECT INTO "nl:"
  ar.seq
  FROM alpha_responses ar,
   (dummyt d  WITH seq = value(ar_cnt))
  PLAN (d)
   JOIN (ar
   WHERE (ar.reference_range_factor_id=request->ar[d.seq].reference_range_factor_id)
    AND (ar.nomenclature_id=request->ar[d.seq].nomenclature_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), cur_updt_cnt[count1] = ar.updt_cnt
  WITH nocounter, forupdate(ar)
 ;end select
 UPDATE  FROM alpha_responses ar,
   (dummyt d1  WITH seq = value(ar_cnt))
  SET ar.sequence = request->ar[d1.seq].sequence, ar.result_value = request->ar[d1.seq].result_value,
   ar.default_ind = request->ar[d1.seq].default_ind,
   ar.result_value = request->ar[d1.seq].result_value, ar.multi_alpha_sort_order = request->ar[d1.seq
   ].multi_alpha_sort_order, ar.active_ind = 1,
   ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id, ar.updt_task =
   reqinfo->updt_task,
   ar.updt_applctx = reqinfo->updt_applctx, ar.updt_cnt = (ar.updt_cnt+ 1)
  PLAN (d1)
   JOIN (ar
   WHERE (ar.reference_range_factor_id=request->ar[d1.seq].reference_range_factor_id)
    AND (ar.nomenclature_id=request->ar[d1.seq].nomenclature_id))
  WITH nocounter
 ;end update
 IF (curqual != ar_cnt)
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALPHA_RESPONSES"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_MAINTAR"
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
