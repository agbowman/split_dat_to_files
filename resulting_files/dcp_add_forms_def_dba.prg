CREATE PROGRAM dcp_add_forms_def:dba
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
 SET count1 = size(request->qual,5)
 INSERT  FROM dcp_forms_def dfd,
   (dummyt d1  WITH seq = value(count1))
  SET dfd.seq = 1, dfd.dcp_forms_def_id = seq(carenet_seq,nextval), dfd.dcp_forms_ref_id = request->
   qual[d1.seq].dcp_forms_ref_id,
   dfd.dcp_section_ref_id = request->qual[d1.seq].dcp_section_ref_id, dfd.section_seq = request->
   qual[d1.seq].section_seq, dfd.active_ind = 1,
   dfd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dfd.updt_id = reqinfo->updt_id, dfd.updt_task =
   reqinfo->updt_task,
   dfd.updt_applctx = reqinfo->updt_applctx, dfd.updt_cnt = 0
  PLAN (d1)
   JOIN (dfd)
  WITH nocounter
 ;end insert
 IF (curqual != count1)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_FORMS_DEF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_ADD_FORMS_DEF"
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
