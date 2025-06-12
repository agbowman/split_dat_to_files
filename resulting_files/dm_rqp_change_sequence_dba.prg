CREATE PROGRAM dm_rqp_change_sequence:dba
 SET rqp_emsg = fillstring(132," ")
 SET rqp_ecode = 0
 SET low_sequence = 0
 SET high_sequence = 0
 SET sequence_value = 0
 SET low_found = "N"
 SET high_found = "N"
 SET test_sequence = 0
 SET found_sequence = "N"
 SELECT INTO "NL:"
  rp.sequence
  FROM request_processing rp
  WHERE (dm_dcp_chg_seq->low_seq_request_number[1]=rp.request_number)
   AND (dm_dcp_chg_seq->low_seq_destination_step_id[1]=rp.destination_step_id)
   AND (dm_dcp_chg_seq->low_seq_format_script[1]=rp.format_script)
   AND (((dm_dcp_chg_seq->low_seq_service[1]=rp.service)) OR (rp.service=null
   AND (dm_dcp_chg_seq->low_seq_service[1]="                                                  ")))
   AND (dm_dcp_chg_seq->low_seq_target_request_number[1]=rp.target_request_number)
  HEAD REPORT
   found = "N"
  DETAIL
   found = "Y", low_sequence = rp.sequence
  FOOT REPORT
   IF (found="Y")
    low_found = "Y"
   ENDIF
  WITH nullreport
 ;end select
 SELECT INTO "NL:"
  rp.sequence
  FROM request_processing rp
  WHERE (dm_dcp_chg_seq->high_seq_request_number[1]=rp.request_number)
   AND (dm_dcp_chg_seq->high_seq_destination_step_id[1]=rp.destination_step_id)
   AND (dm_dcp_chg_seq->high_seq_format_script[1]=rp.format_script)
   AND (((dm_dcp_chg_seq->high_seq_service[1]=rp.service)) OR (rp.service=null
   AND (dm_dcp_chg_seq->high_seq_service[1]="                                                  ")))
   AND (dm_dcp_chg_seq->high_seq_target_request_number[1]=rp.target_request_number)
  HEAD REPORT
   found = "N"
  DETAIL
   found = "Y", high_sequence = rp.sequence
  FOOT REPORT
   IF (found="Y")
    high_found = "Y"
   ENDIF
  WITH nullreport
 ;end select
 IF (low_found="Y"
  AND high_found="Y")
  IF (low_sequence >= high_sequence)
   SELECT INTO "NL:"
    rp.sequence
    FROM request_processing rp
    WHERE (dm_dcp_chg_seq->high_seq_request_number[1]=rp.request_number)
    ORDER BY rp.sequence DESC
    HEAD REPORT
     sequence_value = (rp.sequence+ 1)
   ;end select
   UPDATE  FROM request_processing rp
    SET rp.sequence = sequence_value
    WHERE (dm_dcp_chg_seq->high_seq_request_number[1]=rp.request_number)
     AND high_sequence=rp.sequence
   ;end update
   SET rqp_ecode = error(rqp_emsg,1)
   IF (rqp_ecode != 0)
    SET dm_dcp_chg_seq->status = "F"
    SET dm_dcp_chg_seq->message = rqp_emsg
   ELSE
    SET dm_dcp_chg_seq->status = "S"
    SET dm_dcp_chg_seq->message = "Records are now in the correct order"
   ENDIF
  ELSE
   SET dm_dcp_chg_seq->status = "S"
   SET dm_dcp_chg_seq->message = "Records were in the correct order already"
  ENDIF
 ELSE
  IF (low_found="N")
   SET dm_dcp_chg_seq->status = "F"
   SET dm_dcp_chg_seq->message = "Low Record was not found"
  ENDIF
  IF (high_found="N")
   SET dm_dcp_chg_seq->status = "F"
   SET dm_dcp_chg_seq->message = "High Record was not found"
  ENDIF
  IF (low_found="N"
   AND high_found="N")
   SET dm_dcp_chg_seq->status = "F"
   SET dm_dcp_chg_seq->message = "Both records were not found"
  ENDIF
 ENDIF
END GO
