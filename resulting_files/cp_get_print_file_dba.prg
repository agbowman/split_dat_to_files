CREATE PROGRAM cp_get_print_file:dba
 RECORD reply(
   1 line = vgc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET file_type = ".dat"
 SET logical d value(trim(logical("cer_print")))
 SET strlf = concat(char(10),char(13))
 CALL echo(trim(concat("D:",trim(request->file_name),file_type)))
 SET stat = findfile(trim(concat("D:",trim(request->file_name),file_type)))
 IF (stat=1)
  FREE DEFINE rtl3
  DEFINE rtl3 concat("D:",request->file_name,file_type)
  SELECT INTO "nl:"
   r.line
   FROM rtl3t r
   DETAIL
    reply->line = concat(reply->line,trim(r.line),strlf)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
