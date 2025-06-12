CREATE PROGRAM dm_del_code_filter_disp
 RECORD reply(
   1 code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (x = 1 TO value(size(request->qual,5)))
   DELETE  FROM code_domain_filter_display cd
    WHERE (cd.code_set=request->code_set)
     AND (cd.code_value=request->qual[x].code_value)
    WITH nocounter
   ;end delete
 ENDFOR
 IF (curqual < 0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "T"
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
