CREATE PROGRAM dm_get_cv_filter_r:dba
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
 FREE RECORD reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 code_value_filter_id = f8
     2 code_set = i4
     2 code_value_cd = f8
     2 code_value_disp = c40
     2 code_value_mean = c12
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF ((request->filter_ind < 1)
   AND (request->cdf_meaning > " "))
   FROM code_value_filter_r cvfr,
    code_value cv
   PLAN (cvfr
    WHERE (cvfr.code_value_filter_id=request->code_value_filter_id))
    JOIN (cv
    WHERE cv.code_value=cvfr.code_value_cd
     AND (cv.cdf_meaning=request->cdf_meaning))
   WITH nocounter
  ELSEIF ((request->filter_ind > 0)
   AND (request->cdf_meaning > " "))
   FROM code_value_filter cvf,
    code_value cv,
    (dummyt d  WITH seq = 1),
    code_value_filter_r cvfr
   PLAN (cvf
    WHERE (cvf.code_value_filter_id=request->code_value_filter_id))
    JOIN (cv
    WHERE cv.code_set=cvf.code_set
     AND (cv.cdf_meaning=request->cdf_meaning))
    JOIN (d)
    JOIN (cvfr
    WHERE cvfr.code_value_cd=cv.code_value)
   WITH nocounter, outerjoin = d, dontexist
  ELSEIF ((request->filter_ind < 1))
   FROM code_value_filter_r cvfr,
    code_value cv
   PLAN (cvfr
    WHERE (cvfr.code_value_filter_id=request->code_value_filter_id))
    JOIN (cv
    WHERE cv.code_value=cvfr.code_value_cd)
   WITH nocounter
  ELSE
   FROM code_value_filter cvf,
    code_value cv,
    (dummyt d  WITH seq = 1),
    code_value_filter_r cvfr
   PLAN (cvf
    WHERE (cvf.code_value_filter_id=request->code_value_filter_id))
    JOIN (cv
    WHERE cv.code_set=cvf.code_set)
    JOIN (d)
    JOIN (cvfr
    WHERE cvfr.code_value_cd=cv.code_value)
   WITH nocounter, outerjoin = d, dontexist
  ENDIF
  INTO "nl:"
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,1)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].code_value_filter_id = request->code_value_filter_id, reply->qual[knt].
   code_value_cd = cv.code_value, reply->qual[knt].collation_seq = cv.collation_seq,
   reply->qual[knt].display_key = cv.display_key, reply->qual[knt].description = cv.description,
   reply->qual[knt].definition = cv.definition,
   reply->qual[knt].active_ind = cv.active_ind, reply->qual[knt].code_set = cv.code_set
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE_FILTER_R"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=delete_error)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GENERATE SEQ"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSEIF ((reply->qual_knt < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "003 04/10/03 SF3151"
END GO
