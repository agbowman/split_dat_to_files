CREATE PROGRAM bb_ref_chg_code_set:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nrequestsize = i4
 SET nrequestsize = size(request->codes,5)
 SET serrormsg = fillstring(255," ")
 SET error_check = error(serrormsg,1)
 SET reqinfo->commit_ind = 0
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(nrequestsize))
  SET c.description = request->codes[d.seq].sdescription, c.cdf_meaning = request->codes[d.seq].
   scdfmeaning, c.active_dt_tm =
   IF ((request->codes[d.seq].nactiveind=1)) cnvtdatetime(curdate,curtime3)
   ELSE null
   ENDIF
   ,
   c.inactive_dt_tm =
   IF ((request->codes[d.seq].nactiveind=0)) cnvtdatetime(curdate,curtime3)
   ELSE null
   ENDIF
   , c.active_ind = request->codes[d.seq].nactiveind, c.active_type_cd =
   IF ((request->codes[d.seq].nactiveind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   ,
   c.end_effective_dt_tm =
   IF ((request->codes[d.seq].nactiveind=1)) cnvtdatetime("31 DEC 2100 00:00")
   ELSE cnvtdatetime(curdate,curtime3)
   ENDIF
   , c.data_status_cd = reqdata->data_status_cd, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task,
   c.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->codes[d.seq].dcode))
  WITH nocounter
 ;end update
 SET error_check = error(serrormsg,0)
 IF (error_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error updating code_value table. BB_REF_CHG_CODE_SET"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
