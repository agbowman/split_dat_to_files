CREATE PROGRAM bed_get_ord_related_results:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_sets[*]
      2 event_set_name = vc
      2 event_set_code_value = f8
      2 event_set_display = vc
      2 sequence = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET ecnt = 0
 SELECT INTO "nl:"
  FROM catalog_event_sets c,
   v500_event_set_code v
  PLAN (c
   WHERE (c.catalog_cd=request->catalog_code_value))
   JOIN (v
   WHERE v.event_set_name=c.event_set_name)
  ORDER BY c.sequence
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(reply->event_sets,ecnt), reply->event_sets[ecnt].event_set_name
    = c.event_set_name,
   reply->event_sets[ecnt].event_set_code_value = v.event_set_cd, reply->event_sets[ecnt].
   event_set_display = v.event_set_cd_disp, reply->event_sets[ecnt].sequence = c.sequence
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
