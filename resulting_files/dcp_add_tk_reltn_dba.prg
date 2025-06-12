CREATE PROGRAM dcp_add_tk_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET tk_cnt = cnvtint(size(request->reltn,5))
 INSERT  FROM template_keyword_reltn tk,
   (dummyt d  WITH seq = value(tk_cnt))
  SET tk.template_keyword_reltn_id = cnvtreal(seq(reference_seq,nextval)), tk.template_id = request->
   reltn[d.seq].template_id, tk.note_template_keyword_id = request->reltn[d.seq].
   note_template_keyword_id,
   tk.updt_dt_tm = cnvtdatetime(curdate,curtime), tk.updt_id = reqinfo->updt_id, tk.updt_task =
   reqinfo->updt_task,
   tk.updt_applctx = reqinfo->updt_applctx, tk.updt_cnt = 0
  PLAN (d)
   JOIN (tk)
  WITH nocounter, outerjoin = d
 ;end insert
 IF (curqual != tk_cnt)
  SET failed = "T"
  SET cs_table = "TEMPLATE KEYWORD RELTN"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cs_table
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
