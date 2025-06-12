CREATE PROGRAM cs_srv_get_codeset:dba
 CALL echo(concat("CS_SRV_GET_CODESET - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 DECLARE code_cnt = i2
 DECLARE extn_cnt = i2
 SET reply->status_data.status = "F"
 SET reply->code_value_qual = 0
 SET code_cnt = 0
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning, cv.display,
  cv.description, cve.field_name, cve.field_value,
  cve.field_type
  FROM code_value cv,
   code_value_extension cve,
   dummyt d
  PLAN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d)
   JOIN (cve
   WHERE cve.code_set=cv.code_set
    AND cve.code_value=cv.code_value)
  HEAD cv.code_value
   code_cnt += 1, reply->code_value_qual = code_cnt, stat = alterlist(reply->code_values,code_cnt),
   reply->code_values[code_cnt].code_value = cv.code_value, reply->code_values[code_cnt].cdf_meaning
    = cv.cdf_meaning, reply->code_values[code_cnt].display = cv.display,
   reply->code_values[code_cnt].description = cv.description, extn_cnt = 0
  DETAIL
   IF (size(trim(cve.field_name),1) > 0)
    extn_cnt += 1, reply->code_values[code_cnt].extension_qual = extn_cnt, stat = alterlist(reply->
     code_values[code_cnt].extensions,extn_cnt),
    reply->code_values[code_cnt].extensions[extn_cnt].field_name = cve.field_name, reply->
    code_values[code_cnt].extensions[extn_cnt].field_value = cve.field_value, reply->code_values[
    code_cnt].extensions[extn_cnt].field_type = cve.field_type
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (code_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
