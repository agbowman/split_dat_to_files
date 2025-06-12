CREATE PROGRAM cpmdecoder_upd_cs_hits:dba
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
 SET number_to_chg = size(request->codelist,5)
 SET x = 1
 SELECT INTO "nl:"
  c.*
  FROM code_value_set c,
   (dummyt d  WITH seq = value(number_to_chg))
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->codelist[d.seq].codeset))
  WITH nocounter, forupdate(c)
 ;end select
 UPDATE  FROM code_value_set c,
   (dummyt d  WITH seq = value(number_to_chg))
  SET c.code_set_hits = request->codelist[d.seq].hits, c.code_values_cnt = request->codelist[d.seq].
   cd_val_cnt, c.updt_cnt = (c.updt_cnt+ 1),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->codelist[d.seq].codeset))
  WITH nocounter
 ;end update
 IF (curqual != number_to_chg)
  SET reply->status_data.status = "F"
  ROLLBACK
  GO TO end_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
#end_script
END GO
