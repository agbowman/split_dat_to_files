CREATE PROGRAM aps_del_spec_prefix_rep_sec_r:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE serror = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 DELETE  FROM ap_synoptic_rpt_section_r ap
  PLAN (ap
   WHERE (ap.cki_source=request->cki_source)
    AND (ap.cki_identifier=request->cki_identifier))
  WITH nocounter
 ;end delete
 IF (error(serror,0) > 0)
  CALL subevent_add("DELETE","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
  GO TO exit_script
 ENDIF
 DELETE  FROM ap_synoptic_spec_prefix_r ap
  PLAN (ap
   WHERE (ap.cki_source=request->cki_source)
    AND (ap.cki_identifier=request->cki_identifier))
 ;end delete
 IF (error(serror,0) > 0)
  CALL subevent_add("DELETE","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
