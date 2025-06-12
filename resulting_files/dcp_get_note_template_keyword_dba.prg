CREATE PROGRAM dcp_get_note_template_keyword:dba
 RECORD reply(
   1 note_template[10]
     2 note_template_keyword_id = f8
     2 template_keyword = vc
     2 data_status_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM note_template_keyword nt
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 1)
    stat = alter(reply->note_template,(cnt+ 9))
   ENDIF
   reply->note_template[cnt].note_template_keyword_id = nt.note_template_keyword_id, reply->
   note_template[cnt].template_keyword = trim(nt.template_keyword), reply->note_template[cnt].
   data_status_ind = nt.data_status_ind
  WITH nocounter
 ;end select
 SET stat = alter(reply->note_template,cnt)
 CALL echo(build("count: ",cnt))
 FOR (x = 1 TO cnt)
   CALL echo(build("note_tmp_keywd_reltn_cd :",reply->note_template[x].note_template_keyword_id))
   CALL echo(build("template_keyword :",reply->note_template[x].template_keyword))
   CALL echo(build("Status  :",reply->status_data.status))
 ENDFOR
#exit_script
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
