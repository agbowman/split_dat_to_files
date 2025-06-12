CREATE PROGRAM dm_del_code_filter:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET knt = 0
 SET reply->status_data.status = "F"
 FOR (knt = 1 TO value(size(request->qual,5)))
   DELETE  FROM code_domain_filter_display cd
    WHERE (cd.code_set=request->qual[knt].code_set)
    WITH nocounter
   ;end delete
   IF (curqual < 0)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "T"
    ROLLBACK
   ELSE
    CALL echo("delete in child table is success")
    SET reqinfo->commit_ind = 1
    SET reply->status_data.status = "S"
   ENDIF
   DELETE  FROM code_domain_filter cf
    WHERE (cf.code_set=request->qual[knt].code_set)
    WITH nocounter
   ;end delete
   IF (curqual < 0)
    SET reqinfo->commit_ind = 0
    SET reply->status_data.status = "T"
    ROLLBACK
   ELSE
    CALL echo("delete in parent table is success")
    SET reqinfo->commit_ind = 1
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
#exit_script
END GO
