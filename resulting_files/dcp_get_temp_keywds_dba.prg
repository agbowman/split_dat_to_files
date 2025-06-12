CREATE PROGRAM dcp_get_temp_keywds:dba
 RECORD reply(
   1 qual[5]
     2 template_keyword_reltn_id = f8
     2 note_template_keyword_id = f8
     2 template_keyword = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  t.template_keyword_reltn_id, n.note_template_keyword_id, n.template_keyword
  FROM template_keyword_reltn t,
   note_template_keyword n
  PLAN (t
   WHERE (t.template_id=request->template_id))
   JOIN (n
   WHERE n.note_template_keyword_id=t.note_template_keyword_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,5)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 5))
   ENDIF
   reply->qual[count1].template_keyword_reltn_id = t.template_keyword_reltn_id, reply->qual[count1].
   note_template_keyword_id = n.note_template_keyword_id, reply->qual[count1].template_keyword = trim
   (n.template_keyword)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
 CALL echo(build("count1: ",count1))
 FOR (x = 1 TO count1)
   CALL echo(build("note_tmp_keywd_reltn_cd :",reply->qual[x].template_keyword_reltn_id))
   CALL echo(build("template_keyword :",reply->qual[x].template_keyword))
   CALL echo(build("status  :",reply->status_data.status))
 ENDFOR
END GO
