CREATE PROGRAM dcp_chg_clinical_nt:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET temp_cnt = cnvtint(size(request->qual,5))
 UPDATE  FROM clinical_note_template nt,
   (dummyt d  WITH seq = value(temp_cnt))
  SET nt.template_name = request->qual[d.seq].template_name, nt.template_active_ind = request->qual[d
   .seq].template_active_ind, nt.owner_type_flag = request->qual[d.seq].owner_type_flag,
   nt.prsnl_id = request->qual[d.seq].prsnl_id, nt.cki = request->qual[d.seq].cki, nt.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   nt.updt_id = reqinfo->updt_id, nt.updt_task = reqinfo->updt_task, nt.updt_applctx = reqinfo->
   updt_applctx,
   nt.updt_cnt = (nt.updt_cnt+ 1)
  PLAN (d)
   JOIN (nt
   WHERE (request->qual[d.seq].template_id=nt.template_id))
  WITH nocounter
 ;end update
 IF (curqual != temp_cnt)
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
