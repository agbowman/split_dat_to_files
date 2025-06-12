CREATE PROGRAM cps_add_codes:dba
 RECORD reply(
   1 qual[10]
     2 code_set = i4
     2 display = c40
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c50
 )
 SET reply->status_data.status = "F"
 SET code_to_add = size(request->qual,5)
 SET idx = 0
 SET code_value = 0
 SET fail = "F"
 SET stat = alter(reply->qual,code_to_add)
 FOR (idx = 1 TO code_to_add)
   SELECT INTO "nl:"
    *
    FROM code_value v
    WHERE (v.code_set=request->qual[idx].code_set)
     AND v.display_key=cnvtupper(request->qual[idx].display)
     AND v.active_ind=1
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     nextseq = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      code_value = cnvtint(nextseq)
     WITH format, nocounter
    ;end select
    INSERT  FROM code_value c
     SET c.code_value = code_value, c.code_set = request->qual[idx].code_set, c.cdf_meaning =
      IF ((request->qual[idx].cdf_meaning > " ")) request->qual[idx].cdf_meaning
      ELSE null
      ENDIF
      ,
      c.primary_ind = 1, c.display = request->qual[idx].display, c.display_key = cnvtupper(request->
       qual[idx].display),
      c.description = request->qual[idx].description, c.definition = request->qual[idx].definition, c
      .active_type_cd = 14815,
      c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime), c.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      c.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET fail = "T"
    ENDIF
   ELSE
    SET fail = "T"
   ENDIF
   IF (fail="T")
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "ADD"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "cps_ADD_CODES"
    SET reqinfo->commit_ind = 0
   ELSE
    SET reply->qual[idx].code_set = request->qual[idx].code_set
    SET reply->qual[idx].display = request->qual[idx].display
    SET reply->qual[idx].code_value = code_value
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = 1
   ENDIF
 ENDFOR
 COMMIT
END GO
