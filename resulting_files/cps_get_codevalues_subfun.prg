CREATE PROGRAM cps_get_codevalues_subfun
 SET kount = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE  $1
   AND  $2
   AND  $3
   AND  $4
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->codelist,(kount+ 100))
   ENDIF
   reply->codelist[kount].code_value = c.code_value, reply->codelist[kount].display = c.display,
   reply->codelist[kount].display_key = c.display_key,
   reply->codelist[kount].description = c.description, reply->codelist[kount].definition = c
   .definition, reply->codelist[kount].beg_effective_dt = c.begin_effective_dt_tm,
   reply->codelist[kount].end_effective_dt = c.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET stat = alter(reply->codelist,kount)
 SET reply->code_count = kount
 CALL echo("code count is",0)
 CALL echo(kount)
 IF (curqual <= 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
