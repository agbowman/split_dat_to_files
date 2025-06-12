CREATE PROGRAM cv_get_cv_number_list:dba
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->datacoll,500)
 FOR (i = 1 TO 500)
  SET reply->datacoll[i].currcv = cnvtstring(i)
  SET reply->datacoll[i].description = trim(cnvtstring(i),3)
 ENDFOR
 SET reply->status_data.status = "S"
END GO
