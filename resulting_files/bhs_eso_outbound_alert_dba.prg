CREATE PROGRAM bhs_eso_outbound_alert:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD eso_out
 RECORD eso_out(
   1 records[*]
     2 ms_type = vc
     2 ms_process_flag = vc
     2 mf_queue_id = f8
 )
 DECLARE ms_email_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 SET logical eso_fail_rpt "bhscust:bhs_eso_failed_msgs.csv"
 SET ms_email_filename = "bhs_eso_failed_msgs.csv"
 SELECT INTO "nl:"
  FROM cqm_fsieso_tr_1 t,
   cqm_fsieso_que q
  PLAN (t
   WHERE t.process_status_flag=70
    AND t.trigger_status_text="WARNING: NO TRIGGER MATCH")
   JOIN (q
   WHERE q.queue_id=t.queue_id
    AND  NOT (q.type IN ("POWERFORMS", "MICRO", "RADREMOVEXAM", "FT1")))
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(eso_out->records,ml_cnt), eso_out->records[ml_cnt].ms_type
    = q.type,
   eso_out->records[ml_cnt].ms_process_flag = cnvtstring(t.process_status_flag), eso_out->records[
   ml_cnt].mf_queue_id = t.queue_id
  WITH nocounter
 ;end select
 CALL echo(curqual)
 IF (curqual <= 0)
  GO TO exit_script
 ENDIF
 SELECT INTO eso_fail_rpt
  FROM (dummyt d  WITH seq = size(eso_out->records,5))
  PLAN (d)
  ORDER BY eso_out->records[d.seq].ms_type
  HEAD REPORT
   ms_line = build("MS Type",mc_delimiter,"MS Process Flag",mc_delimiter,"MS Queue ID"), row + 2, col
    0,
   ms_line
  DETAIL
   ms_line = build(eso_out->records[d.seq].ms_type,mc_delimiter,eso_out->records[d.seq].
    ms_process_flag,mc_delimiter,eso_out->records[d.seq].mf_queue_id), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, maxcol = 2000,
   format = variable, maxrow = 1
 ;end select
 CALL echo("emailing")
 IF (curqual > 0)
  SET email_list = "tracy.baker@bhs.org"
  SET ms_tmp_str = concat("Files Emailed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
   email_list,ms_tmp_str,1)
  IF (findfile(concat("bhscust:",ms_email_filename))=1)
   CALL echo("Unable to delete emailed file")
  ELSE
   CALL echo("Emailed File Deleted")
  ENDIF
 ENDIF
#exit_script
END GO
