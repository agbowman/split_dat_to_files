CREATE PROGRAM dcp_add_ntt_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reltn_cd = 0
 DECLARE ntt_cnt = i4 WITH noconstant(0)
 DECLARE cs_table = c15
 DECLARE failed = c1 WITH noconstant("F")
 SET ntt_cnt = cnvtint(size(request->reltn,5))
 INSERT  FROM note_type_template_reltn ntt,
   (dummyt d  WITH seq = value(ntt_cnt))
  SET ntt.note_type_template_reltn_id = cnvtreal(seq(reference_seq,nextval)), ntt.template_id =
   request->reltn[d.seq].template_id, ntt.note_type_id = request->reltn[d.seq].note_type_id,
   ntt.default_ind = request->reltn[d.seq].default_ind, ntt.updt_dt_tm = cnvtdatetime(curdate,curtime
    ), ntt.updt_id = reqinfo->updt_id,
   ntt.updt_task = reqinfo->updt_task, ntt.updt_applctx = reqinfo->updt_applctx, ntt.updt_cnt = 0
  PLAN (d)
   JOIN (ntt)
  WITH nocounter, outerjoin = d
 ;end insert
 IF (curqual != ntt_cnt)
  SET failed = "T"
  SET cs_table = "NOTE TYPE TEMPLATE RELTN"
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
