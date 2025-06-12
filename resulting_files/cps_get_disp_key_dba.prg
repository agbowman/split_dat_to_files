CREATE PROGRAM cps_get_disp_key:dba
 FREE SET reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 code_value = f8
     2 display_key = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF ((((request->display_key=null)) OR ( NOT ((request->display_key > " ")))) )
   PLAN (cv
    WHERE (cv.code_set=request->code_set)
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND cv.active_ind > 0)
  ELSE
   PLAN (cv
    WHERE (cv.code_set=request->code_set)
     AND cv.display_key=cnvtupper(cnvtalphanum(request->display_key))
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND cv.active_ind > 0)
  ENDIF
  INTO "nl:"
  FROM code_value cv
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].code_value = cv.code_value, reply->qual[knt].display_key = cv.display_key
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSE
  IF (curqual < 1)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
END GO
