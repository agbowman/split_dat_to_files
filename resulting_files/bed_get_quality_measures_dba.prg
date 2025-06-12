CREATE PROGRAM bed_get_quality_measures:dba
 FREE SET reply
 RECORD reply(
   1 quality_measures[*]
     2 id = f8
     2 display = vc
     2 unique_code_value_display = vc
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   pca_source s,
   pca_quality_measure m,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=4002170
    AND cv1.cdf_meaning="SOURCE"
    AND cv1.display_key="MEANINGFULUSE"
    AND cv1.active_ind=1)
   JOIN (s
   WHERE s.source_cd=cv1.code_value)
   JOIN (m
   WHERE m.pca_source_id=s.pca_source_id)
   JOIN (cv2
   WHERE cv2.code_value=m.measure_cd
    AND cv2.active_ind=1)
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->quality_measures,rcnt), reply->quality_measures[rcnt].id
    = m.pca_quality_measure_id,
   reply->quality_measures[rcnt].display = m.display_txt, reply->quality_measures[rcnt].
   unique_code_value_display = cv2.display, reply->quality_measures[rcnt].cki = cv2.cki
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
