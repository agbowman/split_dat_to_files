CREATE PROGRAM bbt_get_prod_antigens:dba
 RECORD reply(
   1 qual[*]
     2 special_testing_cd = f8
     2 special_testing_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  s.product_id, s.special_testing_cd
  FROM special_testing s,
   code_value cv
  PLAN (s
   WHERE (s.product_id=request->product_id)
    AND s.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=s.special_testing_cd
    AND cv.active_ind=1)
  ORDER BY cv.collation_seq, s.special_testing_cd
  HEAD REPORT
   qual_cnt = 0
  HEAD s.special_testing_cd
   qual_cnt += 1
   IF (mod(qual_cnt,3)=1)
    stat = alterlist(reply->qual,(qual_cnt+ 2))
   ENDIF
   reply->qual[qual_cnt].special_testing_cd = s.special_testing_cd
  DETAIL
   row + 0
  FOOT  s.special_testing_cd
   row + 0
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   sth.product_id, sth.special_testing_cd
   FROM bbhist_special_testing sth
   PLAN (sth
    WHERE (sth.product_id=request->product_id)
     AND sth.active_ind=1)
   ORDER BY sth.special_testing_cd
   HEAD REPORT
    qual_cnt = 0
   HEAD sth.special_testing_cd
    qual_cnt += 1
    IF (mod(qual_cnt,3)=1)
     stat = alterlist(reply->qual,(qual_cnt+ 2))
    ENDIF
    reply->qual[qual_cnt].special_testing_cd = sth.special_testing_cd
   DETAIL
    row + 0
   FOOT  sth.special_testing_cd
    row + 0
   FOOT REPORT
    stat = alterlist(reply->qual,qual_cnt), reply->status_data.status = "S"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "special testing"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "unable to find antigens for product specified"
   GO TO end_script
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
