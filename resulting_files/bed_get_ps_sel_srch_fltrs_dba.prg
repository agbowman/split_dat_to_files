CREATE PROGRAM bed_get_ps_sel_srch_fltrs:dba
 FREE SET reply
 RECORD reply(
   1 filters[*]
     2 name = vc
     2 display = vc
     2 sequence = i4
     2 required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
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
  FROM pm_sch_filter p,
   br_person_search_settings b
  PLAN (p
   WHERE p.setup_id=setup_id
    AND p.data_type_flag > 0)
   JOIN (b
   WHERE b.setting_mean="SEARCH_FILTERS"
    AND b.data_type_flag=p.data_type_flag
    AND ((b.meaning=p.meaning) OR (b.meaning="")) )
  ORDER BY p.sequence
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(reply->filters,fcnt), reply->filters[fcnt].name = b.description
   IF (p.display > " ")
    reply->filters[fcnt].display = p.display
   ELSE
    reply->filters[fcnt].display = b.description
   ENDIF
   reply->filters[fcnt].sequence = (fcnt - 1), reply->filters[fcnt].required_ind = p.required_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF ((request->empi_ind=1))
   SELECT INTO "nl:"
    FROM br_default_person_search b,
     br_person_search_settings b2
    PLAN (b
     WHERE b.setting_mean="SEARCH_FILTERS"
      AND b.empi_ind=1)
     JOIN (b2
     WHERE b2.setting_mean=b.setting_mean
      AND b2.display=b.display)
    ORDER BY b.sequence
    DETAIL
     fcnt = (fcnt+ 1), stat = alterlist(reply->filters,fcnt), reply->filters[fcnt].name = b2
     .description,
     reply->filters[fcnt].display = b2.display, reply->filters[fcnt].sequence = b.sequence
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM br_default_person_search b,
     br_person_search_settings b2
    PLAN (b
     WHERE b.setting_mean="SEARCH_FILTERS"
      AND b.empi_ind=0)
     JOIN (b2
     WHERE b2.setting_mean=b.setting_mean
      AND b2.display=b.display)
    ORDER BY b.sequence
    DETAIL
     fcnt = (fcnt+ 1), stat = alterlist(reply->filters,fcnt), reply->filters[fcnt].name = b2
     .description,
     reply->filters[fcnt].display = b2.display, reply->filters[fcnt].sequence = b.sequence
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (fcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
