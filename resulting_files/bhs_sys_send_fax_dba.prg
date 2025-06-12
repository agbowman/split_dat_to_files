CREATE PROGRAM bhs_sys_send_fax:dba
 FREE RECORD fax_request
 RECORD fax_request(
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
 DECLARE ms_pcp_lastname = vc WITH protect, noconstant(" ")
 DECLARE ms_fax_nbr = vc WITH protect, noconstant(trim( $4))
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE mc_failed = c1 WITH protect, noconstant("F")
 IF (cnvtint( $2)=0)
  CALL echo("pcp_id = 0")
 ENDIF
 SET output_dest_cd =  $3
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
 SET fax_request->output_dest_cd = output_dest_cd
 IF (findstring(".dat", $1)=0)
  SET fax_request->file_name = build("bhscust:", $1,".dat")
 ELSE
  SET fax_request->file_name = build("bhscust:", $1)
 ENDIF
 SET fax_request->copies = 1
 SET fax_request->number_of_copies = 1
 SET fax_request->transmit_dt_tm = cnvtdatetime(curdate,curtime3)
 SET fax_request->priority_value = 0
 SET fax_request->report_title = concat("autofax-",trim(ms_pcp_lastname),"-",trim(fax_request->
   file_name))
 SET fax_request->country_code = " "
 SET fax_request->area_code = " "
 SET fax_request->exchange = " "
 SET fax_request->suffix = trim(ms_fax_nbr)
 SET fax_request->number_of_pages = 1
 SET fax_request->local_only = 0
 EXECUTE sys_outputdest_print  WITH replace(request,fax_request), replace(reply,fax_reply)
 IF ((fax_reply->sts=1))
  SET mc_failed = "S"
 ENDIF
#exit_script
 IF (mc_failed="F")
  CALL echo("Report not added to Queue")
 ELSE
  COMMIT
  CALL echo("Report was added to Queue")
 ENDIF
END GO
