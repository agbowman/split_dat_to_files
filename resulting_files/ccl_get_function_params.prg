CREATE PROGRAM ccl_get_function_params
 RECORD reply(
   1 qual[*]
     2 qualifier_ind = c1
     2 format_ind = c1
     2 optional_flag = c1
     2 param_type = c20
     2 description = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed_cnt = 0
#begin_script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET findstat = findfile("ccluserdir:cclfuncs.dat")
 IF (findstat=0)
  EXECUTE vccl_funcs_gen
 ENDIF
 SELECT DISTINCT INTO "nl:"
  f.qualifier_ind, f.format_ind, fp.optional_flag,
  fp.param_type, fp.description
  FROM ccl_funcs f,
   ccl_fparams fp
  WHERE f.function_name=cnvtupper(request->function_name)
   AND f.function_id=fp.function_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].qualifier_ind = f.qualifier_ind, reply->qual[cnt].format_ind = f.format_ind,
   reply->qual[cnt].optional_flag = fp.optional_flag,
   reply->qual[cnt].param_type = fp.param_type, reply->qual[cnt].description = fp.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET failed_cnt = (failed_cnt+ 1)
  IF (failed_cnt > 1)
   CALL echo("***error go to exit_script***")
   GO TO exit_script
  ELSE
   CALL echo("****call execute vccl_funcs_gen***")
   EXECUTE vccl_funcs_gen
   CALL echo("***go to begin_script***")
   GO TO begin_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dtable"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
