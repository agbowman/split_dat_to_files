CREATE PROGRAM cs_chg_cdf:dba
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
 SET reply->status_data.status = "F"
 SET number_to_chg = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET failures = 0
 SET x = 1
#start_loop
 FOR (x = x TO number_to_chg)
   SELECT INTO "nl:"
    c.*
    FROM common_data_foundation c
    WHERE (c.code_set=request->qual[x].code_set)
     AND (c.cdf_meaning=request->qual[x].cdf_meaning)
    DETAIL
     cur_updt_cnt = c.updt_cnt
    WITH nocounter, forupdate(c)
   ;end select
   IF (((curqual=0) OR ((cur_updt_cnt != request->qual[x].updt_cnt))) )
    GO TO next_item
   ENDIF
   UPDATE  FROM common_data_foundation c
    SET c.definition = request->qual[x].definition, c.display = request->qual[x].display, c
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = (cur_updt_cnt+ 1),
     c.updt_applctx = reqinfo->updt_applctx
    WHERE (c.code_set=request->qual[x].code_set)
     AND (c.cdf_meaning=request->qual[x].cdf_meaning)
    WITH nocounter
   ;end update
   IF (curqual=0)
    GO TO next_item
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->exception_data,failures)
 ENDIF
 SET reply->exception_data[failures].code_set = request->qual[x].code_set
 SET reply->exception_data[failures].cdf_meaning = request->qual[x].cdf_meaning
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
