CREATE PROGRAM cva_chg_alias:dba
 RECORD reply(
   1 exception_data[1]
     2 code_set = i4
     2 contributor_source_cd = f8
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD status(
   1 qual[1]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_update = size(request->qual,5)
 SET stat = alter(status->qual,number_to_update)
 SET failures = 0
 SET cur_updt_cnt = 0
 SET x = 1
 SELECT INTO "nl:"
  a.*
  FROM code_value_alias a,
   (dummyt d  WITH seq = value(number_to_update))
  PLAN (d)
   JOIN (a
   WHERE (a.code_set=request->qual[d.seq].code_set)
    AND (a.contributor_source_cd=request->qual[d.seq].contributor_source_cd)
    AND (a.code_value=request->qual[d.seq].code_value))
  DETAIL
   IF ((a.updt_cnt=request->qual[d.seq].updt_cnt))
    status->qual[d.seq].status = 1
   ENDIF
  WITH nocounter, forupdate(a)
 ;end select
 UPDATE  FROM code_value_alias a,
   (dummyt d  WITH seq = value(number_to_update))
  SET a.alias = request->qual[d.seq].alias, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id
    = reqinfo->updt_id,
   a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a.updt_cnt
   + 1)
  PLAN (d
   WHERE (status->qual[d.seq].status=1))
   JOIN (a
   WHERE (a.code_set=request->qual[d.seq].code_set)
    AND (a.contributor_source_cd=request->qual[d.seq].contributor_source_cd)
    AND (a.code_value=request->qual[d.seq].code_value))
  WITH nocounter, status(status->qual[d.seq].status)
 ;end update
 COMMIT
 IF (curqual != number_to_update)
  FOR (x = 1 TO number_to_update)
    IF ((status->qual[x].status=0))
     SET failures = (failures+ 1)
     SET stat = alter(reply->exception_data,failures)
     SET reply->exception_data[failures].code_set = request->qual[x].code_set
     SET reply->exception_data[failures].contributor_source_cd = request->qual[x].
     contributor_source_cd
     SET reply->exception_data[failures].code_value = request->qual[x].code_value
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
