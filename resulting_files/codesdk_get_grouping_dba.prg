CREATE PROGRAM codesdk_get_grouping:dba
 RECORD reply(
   1 codes[*]
     2 code_value = f8
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cap = i4 WITH public, noconstant(0)
 IF ((request->by_parent.code_value > 0.0))
  SELECT INTO "nl:"
   FROM code_value_group c
   WHERE (c.parent_code_value=request->by_parent.code_value)
   ORDER BY c.collation_seq, c.child_code_value
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap *= 2
     ENDIF
     stat = alterlist(reply->codes,cap)
    ENDIF
    cnt += 1, reply->codes[cnt].code_value = c.child_code_value, reply->codes[cnt].collation_seq = c
    .collation_seq
   FOOT REPORT
    stat = alterlist(reply->codes,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM code_value_group c
   WHERE (c.child_code_value=request->by_child.code_value)
   ORDER BY c.parent_code_value
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap *= 2
     ENDIF
     stat = alterlist(reply->codes,cap)
    ENDIF
    cnt += 1, reply->codes[cnt].code_value = c.parent_code_value
   FOOT REPORT
    stat = alterlist(reply->codes,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
