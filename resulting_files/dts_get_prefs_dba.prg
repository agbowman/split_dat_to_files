CREATE PROGRAM dts_get_prefs:dba
 RECORD reply(
   1 prefs_qual = i2
   1 prefs[*]
     2 info_name = vc
     2 info_date = dq8
     2 info_char = vc
     2 info_number = f8
     2 info_long_id = f8
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
  di.info_name, di.info_char, di.info_number,
  di.info_long_id
  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->prefs,cnt), reply->prefs[cnt].info_name = di.info_name,
   reply->prefs[cnt].info_char = di.info_char, reply->prefs[cnt].info_number = di.info_number, reply
   ->prefs[cnt].info_long_id = di.info_long_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prefs,cnt)
 SET reply->prefs_qual = cnt
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO reply->prefs_qual)
   CALL echo(build("domain name _ ",request->info_domain))
   CALL echo(build("prefs_qual _ ",reply->prefs_qual))
   CALL echo(build("___info_name _",reply->prefs[cnt].info_name))
   CALL echo(build("___info_char _",reply->prefs[cnt].info_char))
   CALL echo(build("___info_numb _",reply->prefs[cnt].info_number))
   CALL echo(build("___info_long _",reply->prefs[cnt].info_long_id))
 ENDFOR
 CALL echo(build("___STATUS _",reply->status_data.status))
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_INFO"
 ENDIF
END GO
