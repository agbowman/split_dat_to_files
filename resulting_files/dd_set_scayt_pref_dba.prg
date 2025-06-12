CREATE PROGRAM dd_set_scayt_pref:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "Preference Value (0 to disable; 1 to enable): " = ""
  WITH outdev, pvc_value
 SET the_pvc_name = "DynDoc.ScaytEnabled"
 SET providerid = 0.0
 IF (validate(record_data) != 1)
  RECORD record_data(
    1 provider_id = f8
    1 application_id = i4
    1 pref_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE deleteexistingprefs(null) = null WITH protect
 DECLARE maintainpreferences(null) = null WITH protect
 SET record_data->status_data.status = "F"
 CALL maintainpreferences(null)
 SET record_data->status_data.status = "S"
 SUBROUTINE maintainpreferences(null)
   DECLARE begin_date_time = q8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE lstat = i4 WITH protect, noconstant(0)
   IF (validate(dcp_reply) != 1)
    RECORD dcp_reply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   IF (validate(dcp_add_request) != 1)
    RECORD dcp_add_request(
      1 application_number = i4
      1 position_cd = f8
      1 prsnl_id = f8
      1 nv[*]
        2 pvc_name = c32
        2 pvc_value = vc
        2 sequence = i2
        2 merge_id = f8
        2 merge_name = vc
    )
   ENDIF
   SET dcp_add_request->application_number = 600005
   SET dcp_add_request->prsnl_id = providerid
   SET stat = alterlist(dcp_add_request->nv,1)
   SET dcp_add_request->nv[1].sequence = 0
   SET dcp_add_request->nv[1].pvc_name = the_pvc_name
   SET dcp_add_request->nv[1].pvc_value =  $PVC_VALUE
   EXECUTE dcp_add_app_prefs  WITH replace("REQUEST","DCP_ADD_REQUEST"), replace("REPLY","DCP_REPLY")
   IF ((dcp_reply->status_data.status="F"))
    SET stat = moverec(dcp_reply->status_data,record_data->status_data)
    GO TO exit_script
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(dcp_add_request)
    CALL echorecord(dcp_reply)
   ENDIF
   FREE RECORD dcp_reply
   FREE RECORD dcp_add_request
 END ;Subroutine
#exit_script
 CALL echorecord(record_data)
 FREE RECORD record_data
END GO
