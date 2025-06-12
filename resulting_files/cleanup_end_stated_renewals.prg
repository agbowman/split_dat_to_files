CREATE PROGRAM cleanup_end_stated_renewals
 SET curecho = 0
 DECLARE report_only = i4 WITH noconstant(1)
 DECLARE replaced = f8 WITH constant(uar_get_code_by("MEANING",3420,"REPLACED"))
 DECLARE unmatched = f8 WITH constant(uar_get_code_by("MEANING",3420,"UNMATCHED"))
 DECLARE verified = f8 WITH constant(uar_get_code_by("MEANING",3420,"VERIFIED"))
 DECLARE sys_match_o = f8 WITH constant(uar_get_code_by("MEANING",3420,"SYS_MATCH_O"))
 DECLARE sys_match_p = f8 WITH constant(uar_get_code_by("MEANING",3420,"SYS_MATCH_P"))
 DECLARE delivered = f8 WITH constant(uar_get_code_by("MEANING",3401,"DELIVERED"))
 DECLARE error_val = f8 WITH constant(uar_get_code_by("MEANING",3401,"ERROR"))
 DECLARE temp_date = c6
 DECLARE temp_time = c6
 DECLARE begin_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE end_dt_tm = dq8 WITH protect, noconstant(0)
 CALL clear(1,1)
 CALL text(3,4,
  "This program will cleanup the eRx Renewals which were processed and sent to the pharmacy, but still appear"
  )
 CALL text(4,4,
  "un-addressed on the Order Profile and message due to the Improper Argument error being thrown after"
  )
 CALL text(5,4,"accept/reject (CR 1-000000232104).")
 CALL text(7,4,"The program can be run in report-only mode which will not make any updates.")
 CALL text(9,4,"Choose the mode of execution ('R' for report-only, 'U' to update)")
 CALL accept(9,70,"P;CU","R")
 IF (cnvtupper(curaccept)="U")
  SET report_only = 0
 ELSE
  SET report_only = 1
 ENDIF
 SET y = "  /  /  T  :  :  "
 CALL clear(11,1)
 WHILE (begin_dt_tm <= 0)
   CALL clear(12,1)
   CALL clear(13,1)
   CALL text(12,4,
    "Enter the earliest date and time(MM/dd/yyThh:mm:ss) from which you want to Report/Update affected 10.6"
    )
   CALL text(13,4,"eRx Renewals: ")
   CALL accept(13,19,"99D99D99D99D99D99;CU",y)
   SET temp_date = concat(substring(1,2,curaccept),substring(4,2,curaccept),substring(7,4,curaccept))
   SET temp_time = concat(substring(10,2,curaccept),substring(13,2,curaccept),substring(16,2,
     curaccept))
   SET begin_dt_tm = cnvtdatetime(cnvtdate(temp_date),cnvtint(temp_time))
   IF (begin_dt_tm <= 0)
    CALL clear(11,1)
    CALL text(11,1,"A Begin Date must be specified before script may execute. Please retry.")
   ENDIF
 ENDWHILE
 CALL clear(15,1)
 WHILE (end_dt_tm <= 0)
   CALL clear(16,1)
   CALL clear(17,1)
   CALL text(16,4,
    "Enter the latest date and time(MM/dd/yyThh:mm:ss) to which you want to Report/Update affected 10.6"
    )
   CALL text(17,4,"eRx Renewals: ")
   CALL accept(17,19,"99D99D99D99D99D99;CU",y)
   SET temp_date = concat(substring(1,2,curaccept),substring(4,2,curaccept),substring(7,4,curaccept))
   SET temp_time = concat(substring(10,2,curaccept),substring(13,2,curaccept),substring(16,2,
     curaccept))
   SET end_dt_tm = cnvtdatetime(cnvtdate(temp_date),cnvtint(temp_time))
   IF (end_dt_tm <= 0)
    CALL clear(15,1)
    CALL text(15,1,"A End Date must be specified before script may execute. Please retry.")
   ENDIF
 ENDWHILE
 CALL clear(18,1)
 CALL text(19,4,build2("Using begin date and time of: ",format(begin_dt_tm,";;Q")))
 CALL text(20,4,build2("Using end date and time of: ",format(end_dt_tm,";;Q")))
 CALL clear(21,1)
 CALL echo(" querying for data ... this may take a few minutes.")
 SELECT DISTINCT INTO mine
  i.ib_rx_req_id, patient = p.name_full_formatted"#########################################",
  ordering_prsnl = pl.name_full_formatted"#########################################",
  encntr_id = ia.proposed_encntr_id, i.ref_order_id, id.drug_description_txt
  "#####################################################################",
  i.updt_dt_tm
  FROM ib_rx_req i,
   ib_rx_req_action ia,
   ib_rx_req_drug id,
   messaging_audit ma,
   task_subactivity tsa,
   person p,
   prsnl pl
  WHERE i.sure_script_version_flag=2
   AND i.req_type_flag=1
   AND i.ib_rx_req_id=ia.ib_rx_req_id
   AND ia.req_status_cd IN (unmatched, verified, sys_match_o, sys_match_p)
   AND ia.active_ind=1
   AND ia.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
   AND ia.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ma.ref_trans_identifier=i.trans_identifier
   AND ma.status_cd IN (delivered, error_val)
   AND tsa.ib_rx_req_id=i.ib_rx_req_id
   AND  EXISTS (
  (SELECT
   tsa2.ib_rx_req_id
   FROM task_subactivity tsa2
   WHERE tsa2.task_id=tsa.task_id
    AND tsa2.ib_rx_req_id=0))
   AND i.ib_rx_req_id=id.ib_rx_req_id
   AND id.renewal_type_flag=2
   AND ia.proposed_person_id=p.person_id
   AND i.to_prsnl_id=pl.person_id
  ORDER BY i.to_prsnl_id, ia.proposed_person_id, i.updt_dt_tm DESC
  WITH nocounter, separator = "|", format(date,";;q")
 ;end select
 SET output_file_106 = "aaa_106_cleanup_end_stated_renewals.csv"
 SELECT DISTINCT INTO value(output_file_106)
  i.ib_rx_req_id, patient = p.name_full_formatted"#########################################",
  ordering_prsnl = pl.name_full_formatted"#########################################",
  encntr_id = ia.proposed_encntr_id, i.ref_order_id, id.drug_description_txt
  "#####################################################################",
  i.updt_dt_tm
  FROM ib_rx_req i,
   ib_rx_req_action ia,
   ib_rx_req_drug id,
   messaging_audit ma,
   task_subactivity tsa,
   person p,
   prsnl pl
  WHERE i.sure_script_version_flag=2
   AND i.req_type_flag=1
   AND i.ib_rx_req_id=ia.ib_rx_req_id
   AND ia.req_status_cd IN (unmatched, verified, sys_match_o, sys_match_p)
   AND ia.active_ind=1
   AND ia.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
   AND ia.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
   AND ma.ref_trans_identifier=i.trans_identifier
   AND ma.status_cd IN (delivered, error_val)
   AND tsa.ib_rx_req_id=i.ib_rx_req_id
   AND  EXISTS (
  (SELECT
   tsa2.ib_rx_req_id
   FROM task_subactivity tsa2
   WHERE tsa2.task_id=tsa.task_id
    AND tsa2.ib_rx_req_id=0))
   AND i.ib_rx_req_id=id.ib_rx_req_id
   AND id.renewal_type_flag=2
   AND ia.proposed_person_id=p.person_id
   AND i.to_prsnl_id=pl.person_id
  ORDER BY i.to_prsnl_id, ia.proposed_person_id, i.updt_dt_tm DESC
  WITH nocounter, separator = "|", format(date,";;q")
 ;end select
 IF (report_only=0)
  CALL echo(" updating tables ... this may take a few minutes.")
  UPDATE  FROM ib_rx_req_action ia
   SET ia.req_status_cd = replaced, ia.updt_id = reqinfo->updt_id, ia.updt_dt_tm = cnvtdatetime(
     sysdate)
   WHERE ia.ib_rx_req_action_id IN (
   (SELECT DISTINCT
    irra.ib_rx_req_action_id
    FROM ib_rx_req irr,
     ib_rx_req_action irra,
     messaging_audit ma,
     task_subactivity tsa
    WHERE irr.sure_script_version_flag=2
     AND irr.req_type_flag=1
     AND irr.ib_rx_req_id=irra.ib_rx_req_id
     AND irra.req_status_cd IN (sys_match_o, sys_match_p, unmatched, verified)
     AND irra.active_ind=1
     AND ia.updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND irra.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ma.ref_trans_identifier=irr.trans_identifier
     AND ma.status_cd IN (delivered, error_val)
     AND tsa.ib_rx_req_id=irr.ib_rx_req_id
     AND  EXISTS (
    (SELECT
     tsa2.ib_rx_req_id
     FROM task_subactivity tsa2
     WHERE tsa2.task_id=tsa.task_id
      AND tsa2.ib_rx_req_id=0))))
  ;end update
  COMMIT
 ENDIF
 CALL echo("-----------------")
 CALL echo("Report/Update complete.")
 CALL echo(concat("Query results written to CCLUSERDIR\",output_file_106))
 CALL pause(2)
#exit_script
END GO
