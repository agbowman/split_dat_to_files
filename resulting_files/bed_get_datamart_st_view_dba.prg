CREATE PROGRAM bed_get_datamart_st_view:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 pref_id = f8
     2 name = vc
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM predefined_prefs pp
  WHERE pp.predefined_type_meaning="SNCASETYPE"
   AND pp.active_ind=1
  HEAD REPORT
   scnt = 0, tcnt = 0, stat = alterlist(reply->views,10)
  DETAIL
   scnt = (scnt+ 1), tcnt = (tcnt+ 1)
   IF (tcnt > 10)
    stat = alterlist(reply->views,(scnt+ 10)), tcnt = 1
   ENDIF
   reply->views[scnt].pref_id = pp.predefined_prefs_id, reply->views[scnt].name = pp.name, reply->
   views[scnt].mean = pp.predefined_type_meaning
  FOOT REPORT
   stat = alterlist(reply->views,scnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
