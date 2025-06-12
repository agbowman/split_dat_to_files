CREATE PROGRAM bed_get_fn_dup_filter_check:dba
 RECORD reply(
   1 custom_filter_id = f8
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM name_value_prefs nvp,
   predefined_prefs pp
  PLAN (nvp
   WHERE nvp.parent_entity_name="PREDEFINED_PREFS"
    AND nvp.pvc_name="FILTERFIELD")
   JOIN (pp
   WHERE pp.predefined_prefs_id=nvp.parent_entity_id
    AND cnvtupper(pp.name)=cnvtupper(request->custom_filter_name))
  DETAIL
   reply->custom_filter_id = pp.predefined_prefs_id, reply->active_ind = pp.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
