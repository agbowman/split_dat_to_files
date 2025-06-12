CREATE PROGRAM bed_get_ps_sel_encntr_result:dba
 FREE SET reply
 RECORD reply(
   1 results[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
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
 SET setup_id = 0
 SELECT INTO "nl:"
  FROM pm_sch_setup p
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.person_id=0
    AND p.position_cd=0)
  DETAIL
   setup_id = p.setup_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pm_sch_result p,
   br_person_search_settings b
  PLAN (p
   WHERE p.setup_id=setup_id)
   JOIN (b
   WHERE b.setting_mean="ENCOUNTER_RESULTS"
    AND b.data_type_flag=p.data_type_flag
    AND ((b.meaning=p.meaning) OR (b.meaning="")) )
  ORDER BY p.sequence
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->results,rcnt), reply->results[rcnt].name = b.description
   IF (p.display > " ")
    reply->results[rcnt].display = p.display
   ELSE
    reply->results[rcnt].display = b.description
   ENDIF
   reply->results[rcnt].sequence = (rcnt - 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF ((request->empi_ind=1))
   SELECT INTO "nl:"
    FROM br_default_person_search b,
     br_person_search_settings b2
    PLAN (b
     WHERE b.setting_mean="ENCOUNTER_RESULTS"
      AND b.empi_ind=1)
     JOIN (b2
     WHERE b2.setting_mean=b.setting_mean
      AND b2.display=b.display)
    ORDER BY b.sequence
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reply->results,rcnt), reply->results[rcnt].name = b2
     .description,
     reply->results[rcnt].display = b2.display, reply->results[rcnt].sequence = b.sequence
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM br_default_person_search b,
     br_person_search_settings b2
    PLAN (b
     WHERE b.setting_mean="ENCOUNTER_RESULTS"
      AND b.empi_ind=0)
     JOIN (b2
     WHERE b2.setting_mean=b.setting_mean
      AND b2.display=b.display)
    ORDER BY b.sequence
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(reply->results,rcnt), reply->results[rcnt].name = b2
     .description,
     reply->results[rcnt].display = b2.display, reply->results[rcnt].sequence = b.sequence
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
