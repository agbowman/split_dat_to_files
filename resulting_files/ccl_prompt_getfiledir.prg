CREATE PROGRAM ccl_prompt_getfiledir
 PROMPT
  "DIR :" = "*"
  WITH dir
 DECLARE dirname = vc
 SET dirname =  $DIR
 SELECT DISTINCT
  pf.folder_name, pf.file_name
  FROM ccl_prompt_file pf
  WHERE pf.folder_name=patstring(dirname)
  ORDER BY pf.folder_name, pf.file_name
  HEAD REPORT
   delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
   stat = alterlist(reply->data,delta)
  DETAIL
   count = (count+ 1)
   IF (mod(count,delta)=1)
    stat = alterlist(reply->data,(count+ delta))
   ENDIF
   reply->data[count].buffer = concat(reportinfo(2),"$")
  FOOT REPORT
   stat = alterlist(reply->data,count)
  WITH maxrow = 1, reporthelp, check,
   format
 ;end select
END GO
