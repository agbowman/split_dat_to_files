CREATE PROGRAM bhs_sys_send_fax2
 DECLARE ms_pcp_lastname = vc WITH protect, noconstant("")
 RECORD him_request_struct(
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
   1 number_of_pages = i4
   1 local_only = i2
 )
 RECORD him_reply_struct(
   1 sts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetojbectname = c15
       3 targetobjectvalue = c100
 )
 SET failed = "F"
 CALL echo("Entering CoDE_VALUE select statement")
 SET fax_usage_cd = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=3000
   AND c.cdf_meaning="FAX"
   AND c.active_ind=1
  DETAIL
   fax_usage_cd = c.code_value
  WITH nocounter
 ;end select
 CALL echo("Entering DEVICE_XREF, OUTPUT_DEST select statement")
 SET output_dest_cd = 0
 SELECT INTO "nl:"
  FROM device_xref d,
   output_dest o
  PLAN (d
   WHERE d.parent_entity_name="PRSNL"
    AND d.parent_entity_id=cnvtint( $2)
    AND d.usage_type_cd=fax_usage_cd)
   JOIN (o
   WHERE o.device_cd=d.device_cd)
  DETAIL
   output_dest_cd = o.output_dest_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_last_key
  FROM prsnl p
  PLAN (p
   WHERE p.person_id=cnvtint( $2))
  DETAIL
   ms_pcp_lastname = p.name_last_key
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_pcp_lastname = concat("unknown-", $2)
 ENDIF
 CALL echo("Set up the request")
 SET him_request_struct->output_dest_cd = 6449499
 SET him_request_struct->file_name = build("bhscust:", $1,".dat")
 CALL echo(him_request_struct->file_name)
 CALL echo(cnvtstring(findfile(him_request_struct->file_name)))
 SET him_request_struct->copies = 1
 SET him_request_struct->number_of_copies = 1
 SET him_request_struct->transmit_dt_tm = cnvtdatetime(curdate,curtime3)
 SET him_request_struct->priority_value = 0
 SET him_request_struct->report_title = concat("autofax-",trim(ms_pcp_lastname),"-",trim(
   him_request_struct->file_name))
 SET him_request_struct->country_code = " "
 SET him_request_struct->area_code = " "
 SET him_request_struct->exchange = " "
 SET him_request_struct->suffix =  $3
 SET him_request_struct->number_of_pages = 1
 SET him_request_struct->local_only = 0
 EXECUTE sys_outputdest_print  WITH replace(request,him_request_struct), replace(reply,
  him_reply_struct)
 IF ((him_reply_struct->sts=1))
  CALL echo("SYS_OUTPUT_DEST Success")
 ELSE
  SET err = fillstring(50," ")
  SET err = build(trim("SYS_OUTPUT_DEST Error code: "),cnvtstring(him_reply_struct->sts))
  CALL echo(err)
  SET failed = "D"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="D")
  CALL echo("Report not added to Queue")
 ELSE
  COMMIT
  CALL echo("Report was added to Queue")
 ENDIF
END GO
