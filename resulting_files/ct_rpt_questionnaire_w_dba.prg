CREATE PROGRAM ct_rpt_questionnaire_w:dba
 RECORD reply(
   1 filename = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_request_struct(
   1 output_dest_cd = f8
   1 file_name = vc
   1 copies = i4
   1 output_handle_id = f8
   1 number_of_copies = i4
   1 transmit_dt_tm = dq8
   1 priority_value = i4
   1 report_title = vc
   1 server = vc
   1 country_code = c3
   1 area_code = c10
   1 exchange = c10
   1 suffix = c50
 )
 RECORD ct_reply_struct(
   1 sts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE spt_elig_tracking_id = c15 WITH public, noconstant("")
 DECLARE selig_mode_ind = vc WITH public, noconstant("")
 DECLARE temp_time = c6 WITH public, noconstant("")
 DECLARE hold_file = c23 WITH public, noconstant("")
 DECLARE boutputdest = i2 WITH public, noconstant(0)
 DECLARE squeuename = vc WITH public, noconstant("")
 SET spt_elig_tracking_id = cnvtstring(request->pt_elig_tracking_id)
 SET selig_mode_ind = cnvtstring(request->elig_mode_ind)
 SET temp_time = cnvtstring(curtime3,6,0,r)
 SET hold_file = build("CER_PRINT:","CT",temp_time,".DAT")
 SET boutputdest = false
 SET squeuename = ""
 SET reply->node = curnode
 IF ((((request->output_dest_cd > 0)) OR (textlen(trim(request->printer_id,3)) > 0)) )
  IF ((request->output_dest_cd > 0))
   SELECT INTO "nl:"
    FROM output_dest od,
     device d
    PLAN (od
     WHERE (od.output_dest_cd=request->output_dest_cd))
     JOIN (d
     WHERE d.device_cd=od.device_cd)
    DETAIL
     squeuename = d.name
    WITH nocounter
   ;end select
  ENDIF
  IF (((textlen(trim(request->printer_id,3))=0) OR ((request->output_dest_cd > 0)
   AND (request->printer_id != squeuename))) )
   IF ((request->output_dest_cd > 0))
    SET boutputdest = true
    SET ct_request_struct->file_name = hold_file
    SET ct_request_struct->output_dest_cd = request->output_dest_cd
    SET ct_request_struct->copies = 1
    SET ct_request_struct->number_of_copies = 1
    SET ct_request_struct->transmit_dt_tm = cnvtdatetime(curdate,curtime3)
    SET ct_request_struct->priority_value = 0
    SET ct_request_struct->report_title = "Questionnaire Report"
    SET ct_request_struct->country_code = " "
    SET ct_request_struct->area_code = " "
    SET ct_request_struct->exchange = " "
    SET ct_request_struct->suffix = " "
   ENDIF
  ELSE
   SET hold_file = value(request->printer_id)
  ENDIF
 ELSE
  SET reply->filename = hold_file
 ENDIF
 EXECUTE reportrtl
 EXECUTE ct_rpt_questionnaire_layout hold_file, spt_elig_tracking_id, selig_mode_ind
 IF (boutputdest)
  EXECUTE sys_outputdest_print  WITH replace("REQUEST","CT_REQUEST_STRUCT"), replace("REPLY",
   "CT_REPLY_STRUCT")
  IF ((ct_reply_struct->sts=1))
   COMMIT
   SET reply->filename = hold_file
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
