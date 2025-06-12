CREATE PROGRAM ccl_upd_custom_script_cache
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enable Custom Script Cache for Discern Reports:" = 1
  WITH outdev, customcache
 RECORD prompt_request(
   1 script_cache_ind = vc
   1 custom_objects[*]
     2 ccl_cust_script_objects_id = f8
     2 active_ind = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD upd_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE ccl_upd_cust_script_active_ind  WITH replace("REQUEST","PROMPT_REQUEST")
 IF ((upd_reply->status_data.status="S"))
  COMMIT
  SELECT INTO  $OUTDEV
   nvp.parent_entity_name, nvp.parent_entity_id, nvp.pvc_name,
   nvp.updt_dt_tm"@SHORTDATETIME", nvp.active_ind, nvp.pvc_value
   FROM name_value_prefs nvp
   WHERE nvp.pvc_name="DISCERN_CUSTOM_CACHE"
   HEAD REPORT
    row 1, col 5, "Custom Script Cache status: "
    IF (( $CUSTOMCACHE=1))
     compile_mode = "ENABLED"
    ELSE
     compile_mode = "DISABLED"
    ENDIF
    col + 5, compile_mode, row 1,
    col 93, "Date:", today = format(cnvtdatetime(sysdate),"@SHORTDATETIME"),
    row 1, col 105, today,
    row + 2
   HEAD nvp.pvc_name
    col 5, "Preference Name:", col 40,
    "Value:", col 55, "Last updated:",
    row + 1
   DETAIL
    pvc_value1 = substring(1,10,nvp.pvc_value), col 5, nvp.pvc_name,
    col 40, pvc_value1, col 55,
    nvp.updt_dt_tm, row + 1
   WITH noheading, format = variable, nullreport
  ;end select
 ELSE
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
END GO
