CREATE PROGRAM bed_ens_concki_cd_match:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 SET cnt = size(request->codes,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(cnt))
  SET c.concept_cki = request->codes[d.seq].concept_cki, c.updt_id = reqinfo->updt_id, c.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt
   + 1)
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->codes[d.seq].code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
