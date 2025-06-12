CREATE PROGRAM cp_update_mm_fields:dba
 RECORD reply(
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
 SET chart_format_id = 0.0
 DECLARE fields_count = i4
 DECLARE mmimage_count = i4
 DELETE  FROM chart_form_mm_flds mf
  WHERE (mf.chart_format_id=request->chart_format_id)
  WITH nocounter
 ;end delete
 SET fields_count = request->num_fields
 INSERT  FROM chart_form_mm_flds mf,
   (dummyt d  WITH seq = value(fields_count))
  SET mf.chart_format_id = request->chart_format_id, mf.cdf_meaning = request->mm_field_list[d.seq].
   cdf_meaning, mf.field_desc = request->mm_field_list[d.seq].field_desc,
   mf.field_seq = request->mm_field_list[d.seq].field_seq, mf.active_ind = 1, mf.active_status_cd =
   reqdata->active_status_cd,
   mf.active_status_dt_tm = cnvtdatetime(curdate,curtime3), mf.active_status_prsnl_id = reqinfo->
   updt_id, mf.updt_cnt = 0,
   mf.updt_dt_tm = cnvtdatetime(curdate,curtime3), mf.updt_id = reqinfo->updt_id, mf.updt_task =
   reqinfo->updt_task,
   mf.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (mf)
  WITH nocounter
 ;end insert
 IF (curqual=0
  AND fields_count != 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DELETE  FROM chart_image_mm_flds mf
  WHERE (mf.chart_format_id=request->chart_format_id)
  WITH nocounter
 ;end delete
 SET mmimage_count = request->num_image_fields
 INSERT  FROM chart_image_mm_flds mf,
   (dummyt d1  WITH seq = value(mmimage_count))
  SET mf.chart_format_id = request->chart_format_id, mf.field_seq = request->mm_image_field_list[d1
   .seq].field_seq, mf.cdf_meaning = request->mm_image_field_list[d1.seq].cdf_meaning,
   mf.location_ind = request->mm_image_field_list[d1.seq].location_ind, mf.active_ind = 1, mf
   .active_status_cd = reqdata->active_status_cd,
   mf.active_status_dt_tm = cnvtdatetime(curdate,curtime3), mf.active_status_prsnl_id = reqinfo->
   updt_id, mf.updt_cnt = 0,
   mf.updt_dt_tm = cnvtdatetime(curdate,curtime3), mf.updt_id = reqinfo->updt_id, mf.updt_task =
   reqinfo->updt_task,
   mf.updt_applctx = reqinfo->updt_applctx
  PLAN (d1)
   JOIN (mf)
  WITH nocounter
 ;end insert
 IF (curqual=0
  AND mmimage_count != 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
