CREATE PROGRAM dcp_add_nt_keyword:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
 )
 DECLARE cs_table = c50
 DECLARE ntk_cnt = i4 WITH noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 SET keyword_cd = 0
 SET ntk_cnt = cnvtint(size(request->keyword,5))
 INSERT  FROM note_template_keyword ntk,
   (dummyt d  WITH seq = value(ntk_cnt))
  SET ntk.note_template_keyword_id = cnvtreal(seq(reference_seq,nextval)), ntk.template_keyword =
   request->keyword[d.seq].template_keyword, ntk.data_status_ind = 1,
   ntk.updt_dt_tm = cnvtdatetime(curdate,curtime), ntk.updt_id = reqinfo->updt_id, ntk.updt_task =
   reqinfo->updt_task,
   ntk.updt_applctx = reqinfo->updt_applctx, ntk.updt_cnt = 0
  PLAN (d)
   JOIN (ntk)
  WITH nocounter, outerjoin = d
 ;end insert
 IF (curqual != ntk_cnt)
  SET failed = "T"
  SET cs_table = "NOTE TEMPLATE KEYWORD"
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
