CREATE PROGRAM bed_get_ps_avail_srch_settings:dba
 FREE SET reply
 RECORD reply(
   1 search_filters[*]
     2 name = vc
     2 display = vc
   1 default_filters[*]
     2 name = vc
   1 encntr_info[*]
     2 name = vc
     2 display = vc
   1 reltn_info[*]
     2 name = vc
     2 display = vc
   1 person_info[*]
     2 name = vc
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->search_mean="SEARCH_FILTERS"))
  SELECT INTO "nl:"
   FROM br_person_search_settings b
   PLAN (b
    WHERE (b.setting_mean=request->search_mean))
   ORDER BY b.display
   HEAD REPORT
    fcnt = 0
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(reply->search_filters,fcnt), reply->search_filters[fcnt].
    display = b.display,
    reply->search_filters[fcnt].name = b.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->search_mean="DEFAULT_FILTERS"))
  SELECT INTO "nl:"
   FROM br_person_search_settings b
   PLAN (b
    WHERE (b.setting_mean=request->search_mean))
   ORDER BY b.description
   HEAD REPORT
    fcnt = 0
   DETAIL
    fcnt = (fcnt+ 1), stat = alterlist(reply->default_filters,fcnt), reply->default_filters[fcnt].
    name = b.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->search_mean="ENCOUNTER_RESULTS"))
  SELECT INTO "nl:"
   FROM br_person_search_settings b
   PLAN (b
    WHERE (b.setting_mean=request->search_mean))
   ORDER BY b.display
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->encntr_info,rcnt), reply->encntr_info[rcnt].display = b
    .display,
    reply->encntr_info[rcnt].name = b.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->search_mean="RELTN_RESULTS"))
  SELECT INTO "nl:"
   FROM br_person_search_settings b
   PLAN (b
    WHERE (b.setting_mean=request->search_mean))
   ORDER BY b.display
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->reltn_info,rcnt), reply->reltn_info[rcnt].display = b
    .display,
    reply->reltn_info[rcnt].name = b.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->search_mean="PERSON_RESULTS"))
  SELECT INTO "nl:"
   FROM br_person_search_settings b
   PLAN (b
    WHERE (b.setting_mean=request->search_mean))
   ORDER BY b.display
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->person_info,rcnt), reply->person_info[rcnt].display = b
    .display,
    reply->person_info[rcnt].name = b.description
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
