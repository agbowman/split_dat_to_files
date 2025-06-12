CREATE PROGRAM bed_get_sets_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 segments[*]
     2 segment = vc
     2 code_sets[*]
       3 code_set = i4
       3 code_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SELECT INTO "NL:"
  FROM br_contr_cs_r b,
   code_value_set cvs
  PLAN (b
   WHERE (b.contributor_system_cd=request->contributor_system_code_value))
   JOIN (cvs
   WHERE cvs.code_set=b.codeset)
  ORDER BY b.segment_name
  HEAD b.segment_name
   scnt = (scnt+ 1), stat = alterlist(reply->segments,scnt), reply->segments[scnt].segment = b
   .segment_name,
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->segments[scnt].code_sets,ccnt), reply->segments[scnt].
   code_sets[ccnt].code_set = b.codeset,
   reply->segments[scnt].code_sets[ccnt].code_set_name = cvs.display
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
