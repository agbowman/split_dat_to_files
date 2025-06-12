CREATE PROGRAM dcp_upd_pl_favorites:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE g_number_to_add = i4 WITH public, noconstant(size(request->patient_lists,5))
 DECLARE g_failed = c1 WITH public, noconstant("F")
 DECLARE x = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 DELETE  FROM dcp_pl_favorites plf
  WHERE (plf.prsnl_id=request->prsnl_id)
  WITH nocounter
 ;end delete
 FOR (x = 1 TO g_number_to_add)
   INSERT  FROM dcp_pl_favorites plf
    SET plf.favorites_id = seq(dcp_patient_list_seq,nextval), plf.patient_list_id = request->
     patient_lists[x].patient_list_id, plf.prsnl_id = request->prsnl_id,
     plf.sequence = request->patient_lists[x].sequence, plf.updt_applctx = reqinfo->updt_applctx, plf
     .updt_cnt = 0,
     plf.updt_dt_tm = cnvtdatetime(curdate,curtime3), plf.updt_id = reqinfo->updt_id, plf.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
