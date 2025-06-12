CREATE PROGRAM cs_add_cdf:dba
 RECORD reply(
   1 exception_data[1]
     2 code_set = i4
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET stat = alter(internal->qual,number_to_add)
 SET failures = 0
 INSERT  FROM common_data_foundation c,
   (dummyt d  WITH seq = value(number_to_add))
  SET c.seq = 1, c.code_set = request->qual[d.seq].code_set, c.cdf_meaning = trim(cnvtupper(request->
     qual[d.seq].cdf_meaning)),
   c.display = substring(1,40,request->qual[d.seq].display), c.definition = substring(1,100,request->
    qual[d.seq].definition), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
   c.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (c)
  WITH nocounter, status(internal->qual[d.seq].status)
 ;end insert
 COMMIT
 IF (curqual != number_to_add)
  FOR (x = 1 TO number_to_add)
    IF ((internal->qual[x].status=0))
     SET failures = (failures+ 1)
     IF (failures > 1)
      SET stat = alter(reply->exception_data,failures)
     ENDIF
     SET reply->exception_data[failures].code_set = request->qual[x].code_set
     SET reply->exception_data[failures].cdf_meaning = request->qual[x].cdf_meaning
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
