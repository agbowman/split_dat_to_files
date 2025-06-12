CREATE PROGRAM dcp_upd_name_value:dba
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
 SET nv_cnt = request->nv_cnt
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 SELECT INTO "nl:"
  nvp.seq
  FROM name_value_prefs nvp,
   (dummyt d  WITH seq = value(nv_cnt))
  PLAN (d)
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=request->nv[d.seq].name_value_prefs_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), cur_updt_cnt[count1] = nvp.updt_cnt
  WITH nocounter, forupdate(nvp)
 ;end select
 UPDATE  FROM name_value_prefs nvp,
   (dummyt d1  WITH seq = value(nv_cnt))
  SET nvp.seq = 1, nvp.pvc_name = request->nv[d1.seq].pvc_name, nvp.pvc_value = request->nv[d1.seq].
   pvc_value,
   nvp.merge_id = request->nv[d1.seq].merge_id, nvp.merge_name = request->nv[d1.seq].merge_name, nvp
   .sequence = request->nv[d1.seq].sequence,
   nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
   updt_id,
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = (nvp
   .updt_cnt+ 1)
  PLAN (d1)
   JOIN (nvp
   WHERE (nvp.name_value_prefs_id=request->nv[d1.seq].name_value_prefs_id))
  WITH nocounter
 ;end update
 IF (curqual != nv_cnt)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "NAME_VALUE_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_UPD_NAME_VALUE"
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
