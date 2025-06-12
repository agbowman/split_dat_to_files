CREATE PROGRAM cps_get_ord_cat_tree:dba
 FREE SET reply
 RECORD reply(
   1 cat_qual = i4
   1 cat_type[*]
     2 cat_type_cd = f8
     2 cat_type_dsply = c25
     2 act_type_qual = i4
     2 act_type[*]
       3 act_type_cd = f8
       3 act_type_dsply = c25
       3 subact_type_qual = i4
       3 subact_type[*]
         4 subact_type_cd = f8
         4 subact_type_dsply = c25
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET stat = alterlist(reply->cat_type,10)
 SET reply->cat_qual = 0
 SELECT DISTINCT INTO "nl:"
  c1.display, c2.display, c3.display,
  c1.code_value, c2.code_value
  FROM code_value c1,
   (dummyt d1  WITH seq = 1),
   code_value c2,
   (dummyt d2  WITH seq = 1),
   code_value c3
  PLAN (c1
   WHERE c1.code_set=6000
    AND c1.active_ind=1
    AND c1.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d1)
   JOIN (c2
   WHERE c2.code_set=106
    AND c2.definition=c1.cdf_meaning
    AND c2.active_ind=1
    AND c2.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c2.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d2)
   JOIN (c3
   WHERE c3.code_set=5801
    AND c3.definition=c2.cdf_meaning
    AND c3.active_ind=1
    AND c3.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND c3.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY c1.display, c2.display, c3.display
  HEAD REPORT
   knt1 = 0, stat = alterlist(reply->cat_type,10)
  HEAD c1.code_value
   knt1 += 1
   IF (mod(knt1,10)=1
    AND knt1 != 1)
    stat = alterlist(reply->cat_type,(knt1+ 9))
   ENDIF
   knt2 = 0, stat = alterlist(reply->cat_type[knt1].act_type,10), reply->cat_type[knt1].cat_type_cd
    = c1.code_value,
   reply->cat_type[knt1].cat_type_dsply = c1.display
  HEAD c2.code_value
   IF (c2.code_value > 0)
    knt2 += 1
    IF (mod(knt2,10)=1
     AND knt2 != 1)
     stat = alterlist(reply->cat_type[knt1].act_type,(knt2+ 9))
    ENDIF
    knt3 = 0, stat = alterlist(reply->cat_type[knt1].act_type[knt2].subact_type,10), reply->cat_type[
    knt1].act_type[knt2].act_type_cd = c2.code_value,
    reply->cat_type[knt1].act_type[knt2].act_type_dsply = c2.display
   ENDIF
  DETAIL
   IF (c3.code_value > 0)
    knt3 += 1
    IF (mod(knt3,10)=1
     AND knt3 != 1)
     stat = alterlist(reply->cat_type[knt1].act_type[knt2].subact_type,(knt3+ 9))
    ENDIF
    reply->cat_type[knt1].act_type[knt2].subact_type[knt3].subact_type_cd = c3.code_value, reply->
    cat_type[knt1].act_type[knt2].subact_type[knt3].subact_type_dsply = c3.display
   ENDIF
  FOOT  c2.code_value
   reply->cat_type[knt1].act_type[knt2].subact_type_qual = knt3, stat = alterlist(reply->cat_type[
    knt1].act_type[knt2].subact_type,knt3)
  FOOT  c1.code_value
   reply->cat_type[knt1].act_type_qual = knt2, stat = alterlist(reply->cat_type[knt1].act_type,knt2)
  FOOT REPORT
   reply->cat_qual = knt1, stat = alterlist(reply->cat_type,knt1)
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
