CREATE PROGRAM dm_ins_upd_cdf:dba
 RECORD reply(
   1 qual[1]
     2 cdf_meaning = c12
     2 status = c2
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
 SET x = 0
 SET dm_cdf = fillstring(12," ")
 SET cur_updt_cnt = 0
 SET dup = 0
 FOR (x = 1 TO number_to_add)
   SET dup = 0
   IF (trim(request->qual[x].old_cdf_meaning) > " "
    AND trim(request->qual[x].old_cdf_meaning) != trim(request->qual[x].cdf_meaning))
    SELECT INTO "nl:"
     c.cdf_meaning
     FROM common_data_foundation c
     WHERE c.cdf_meaning=trim(request->qual[x].cdf_meaning)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET dup = 1
    ENDIF
   ENDIF
   IF (dup=0)
    SELECT
     IF (trim(request->qual[x].old_cdf_meaning)="")
      WHERE (c.cdf_meaning=request->qual[x].cdf_meaning)
       AND (c.code_set=request->code_set)
     ELSE
      WHERE (c.cdf_meaning=request->qual[x].old_cdf_meaning)
       AND (c.code_set=request->code_set)
     ENDIF
     INTO "nl:"
     c.*
     FROM common_data_foundation c
     DETAIL
      dm_cdf = trim(c.cdf_meaning), cur_updt_cnt = c.updt_cnt
     WITH nocounter, forupdate(c)
    ;end select
    IF (curqual > 0)
     IF ((cur_updt_cnt != request->qual[x].updt_cnt))
      SET reply->qual[x].cdf_meaning = dm_cdf
      SET reply->qual[x].status = "A"
     ELSE
      UPDATE  FROM common_data_foundation c
       SET c.cdf_meaning = trim(cnvtupper(request->qual[x].cdf_meaning)), c.display = substring(1,40,
         request->qual[x].display), c.definition = substring(1,100,request->qual[x].definition),
        c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
        reqinfo->updt_task,
        c.updt_cnt = (cur_updt_cnt+ 1), c.updt_applctx = reqinfo->updt_applctx
       WHERE (c.code_set=request->code_set)
        AND c.cdf_meaning=trim(dm_cdf)
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET reply->qual[x].cdf_meaning = dm_cdf
       SET reply->qual[x].status = "S"
       IF ((request->qual[x].cdf_meaning != request->qual[x].old_cdf_meaning)
        AND trim(request->qual[x].old_cdf_meaning) > "")
        UPDATE  FROM code_value c
         SET c.cdf_meaning = request->qual[x].cdf_meaning
         WHERE c.cdf_meaning=dm_cdf
          AND (c.code_set=request->code_set)
        ;end update
       ENDIF
      ELSE
       SET reply->qual[x].cdf_meaning = dm_cdf
       SET reply->qual[x].status = "U"
      ENDIF
     ENDIF
    ELSE
     INSERT  FROM common_data_foundation c
      SET c.code_set = request->code_set, c.cdf_meaning = trim(cnvtupper(request->qual[x].cdf_meaning
         )), c.display = substring(1,40,request->qual[x].display),
       c.definition = substring(1,100,request->qual[x].definition), c.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), c.updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task, c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
      SET reply->qual[x].status = "S"
     ELSE
      SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
      SET reply->qual[x].status = "I"
     ENDIF
    ENDIF
    COMMIT
   ELSE
    SET reply->qual[x].cdf_meaning = request->qual[x].cdf_meaning
    SET reply->qual[x].status = "Z"
   ENDIF
 ENDFOR
 COMMIT
 SET reply->status_data.status = "S"
END GO
