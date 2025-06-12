CREATE PROGRAM br_get_unmatched_by_cd:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 catalog_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET ccnt = size(request->clist,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 FOR (x = 1 TO ccnt)
  SELECT INTO "nl:"
   FROM br_oc_work bow
   PLAN (bow
    WHERE (bow.match_orderable_cd=request->clist[x].catalog_code_value))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET cnt = (cnt+ 1)
   SET stat = alterlist(reply->qual,cnt)
   SET reply->qual[cnt].catalog_code_value = request->clist[x].catalog_code_value
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
