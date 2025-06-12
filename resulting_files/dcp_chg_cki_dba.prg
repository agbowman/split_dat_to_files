CREATE PROGRAM dcp_chg_cki:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cki = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD internal_record(
   1 element[*]
     2 status = i1
 )
 SET reply->status_data.status = "F"
 SET number_to_update = size(request->qual,5)
 SET stat = alterlist(internal_record->element,number_to_update)
 SET failures = 0
 SET cur_updt_cnt = 0
 SET x = 1
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   (dummyt d  WITH seq = value(number_to_update))
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->qual[d.seq].code_value))
  DETAIL
   IF ((c.updt_cnt=request->qual[d.seq].updt_cnt))
    internal_record->element[d.seq].status = 1
   ENDIF
  WITH nocounter, forupdate(c)
 ;end select
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(number_to_update))
  SET c.cki = request->qual[d.seq].cki, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
   reqinfo->updt_id,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt
   + 1)
  PLAN (d
   WHERE (internal_record->element[d.seq].status=1))
   JOIN (c
   WHERE (c.code_value=request->qual[d.seq].code_value))
  WITH nocounter, status(internal_record->element[d.seq].status)
 ;end update
 IF (curqual != number_to_update)
  FOR (x = 1 TO number_to_update)
    IF ((internal_record->element[x].status=0))
     SET failures = (failures+ 1)
     SET stat = alterlist(reply->qual,failures)
     SET reply->qual[failures].code_value = request->qual[x].code_value
     SET reply->qual[failures].cki = request->qual[x].cki
     SET reply->qual[failures].updt_cnt = request->qual[x].updt_cnt
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures < number_to_update)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
