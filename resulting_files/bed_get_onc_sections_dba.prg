CREATE PROGRAM bed_get_onc_sections:dba
 FREE SET reply
 RECORD reply(
   1 sections[*]
     2 id = f8
     2 name = vc
     2 content_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
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
 SELECT INTO "nl:"
  FROM ccr_section cs,
   code_value cv
  PLAN (cs
   WHERE cs.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cs.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND cs.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=cs.content_type_cd
    AND cv.active_ind=1)
  ORDER BY cs.section_name
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->sections,scnt), reply->sections[scnt].id = cs.section_id,
   reply->sections[scnt].name = cs.section_name, reply->sections[scnt].content_type.code_value = cv
   .code_value, reply->sections[scnt].content_type.display = cv.display,
   reply->sections[scnt].content_type.mean = cv.cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
