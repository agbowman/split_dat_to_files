CREATE PROGRAM cva_del_outbound:dba
 RECORD reply(
   1 qual[*]
     2 status = i4
     2 errnum = i4
     2 errmsg = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE statcnt = i4 WITH private, noconstant(0)
 SET reply->status_data.status = "S"
 SET number_to_delete = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_delete)
 DELETE  FROM code_value_outbound c,
   (dummyt d  WITH seq = value(number_to_delete))
  SET c.seq = 1
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=request->qual[d.seq].code_set)
    AND (c.code_value=request->qual[d.seq].code_value)
    AND (c.contributor_source_cd=request->qual[d.seq].contributor_source_cd)
    AND (c.alias_type_meaning=request->qual[d.seq].alias_type_meaning))
  WITH nocounter, status(reply->qual[d.seq].status,reply->qual[d.seq].errnum,reply->qual[d.seq].
   errmsg)
 ;end delete
 FOR (statcnt = 1 TO number_to_delete)
   IF ((reply->qual[statcnt].errnum != 0))
    SET reply->status_data.status = "F"
    SET statcnt = (number_to_delete+ 1)
   ENDIF
 ENDFOR
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
