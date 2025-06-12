CREATE PROGRAM bed_get_funct_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 categories[*]
      2 category_id = f8
      2 stage_type_flag = i2
      2 category_name = vc
      2 measures[*]
        3 measure_id = f8
        3 measure_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE meas_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM br_datamart_category cat
  PLAN (cat
   WHERE cat.category_mean IN ("MUSE_FUNCTIONAL", "MUSE_FUNCTIONAL_2"))
  ORDER BY cat.category_name
  HEAD REPORT
   stat = alterlist(reply->categories,2)
  DETAIL
   cat_cnt = (cat_cnt+ 1), reply->categories[cat_cnt].category_id = cat.br_datamart_category_id,
   reply->categories[cat_cnt].category_name = cat.category_name
   IF (cat.category_mean="MUSE_FUNCTIONAL")
    reply->categories[cat_cnt].stage_type_flag = 1
   ELSEIF (cat.category_mean="MUSE_FUNCTIONAL_2")
    reply->categories[cat_cnt].stage_type_flag = 2
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->categories,cat_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("GETCATFAILURE1")
 IF (cat_cnt > 0
  AND (request->return_measures_ind > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cat_cnt),
    br_datamart_report rep
   PLAN (d)
    JOIN (rep
    WHERE (rep.br_datamart_category_id=reply->categories[d.seq].category_id))
   ORDER BY d.seq, rep.report_name
   HEAD d.seq
    meas_cnt = 0, cnt = 0, stat = alterlist(reply->categories[d.seq].measures,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > 10)
     cnt = 1, stat = alterlist(reply->categories[d.seq].measures,(meas_cnt+ 10))
    ENDIF
    meas_cnt = (meas_cnt+ 1), reply->categories[d.seq].measures[meas_cnt].measure_id = rep
    .br_datamart_report_id, reply->categories[d.seq].measures[meas_cnt].measure_name = rep
    .report_name
   FOOT  d.seq
    stat = alterlist(reply->categories[d.seq].measures,meas_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("GETREPFAILURE1")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
