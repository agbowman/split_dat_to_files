CREATE PROGRAM bed_get_convert_string:dba
 FREE SET reply
 RECORD reply(
   1 converted_strings[*]
     2 string_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = size(request->strings,5)
 SET stat = alterlist(reply->converted_strings,scnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt))
  PLAN (d)
  DETAIL
   reply->converted_strings[d.seq].string_text = cnvtalphanum(cnvtupper(trim(request->strings[d.seq].
      string_text)))
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
