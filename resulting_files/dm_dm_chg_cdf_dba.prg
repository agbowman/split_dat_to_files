CREATE PROGRAM dm_dm_chg_cdf:dba
 RECORD reply(
   1 qual[*]
     2 cdf_meaning = c12
     2 status = c2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_add)
 SET failures = 0
 SET x = 0
 FOR (x = 1 TO number_to_add)
   INSERT  FROM dm_adm_common_data_foundation c
    SET c.code_set = request->qual[x].code_set, c.schema_date = cnvtdatetime(request->schema_date), c
     .cdf_meaning = trim(cnvtupper(request->qual[x].cdf_meaning)),
     c.display = substring(1,40,request->qual[x].display), c.definition = substring(1,100,request->
      qual[x].definition), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
     c.updt_applctx = reqinfo->updt_applctx, c.delete_ind = request->qual[x].delete_ind
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual > 0)
  FOR (x = 1 TO number_to_add)
   SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
   SET reply->qual[x].status = "S"
  ENDFOR
 ELSE
  FOR (x = 1 TO number_to_add)
   SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
   SET reply->qual[x].status = "I"
  ENDFOR
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
END GO
