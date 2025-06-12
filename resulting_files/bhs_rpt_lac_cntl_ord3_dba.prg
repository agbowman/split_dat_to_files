CREATE PROGRAM bhs_rpt_lac_cntl_ord3:dba
 PROMPT
  "FACILITY:" = - (l)
  WITH facility
 FREE RECORD cntl_lac_svc
 RECORD cntl_lac_svc(
   1 md_beg_dt_tm = dq8
   1 md_end_dt_tm = dq8
   1 encntrs[*]
     2 mf_encntr_id = f8
     2 ms_patient_fin = vc
     2 ms_patient_mrn = vc
     2 ms_patient_name = vc
     2 ms_orig_order_dt_tm = vc
     2 mf_order_id = f8
     2 ms_rsn_for_consult = vc
     2 mc_ord_provider = vc
 ) WITH protect
 FREE RECORD lac_nurse_units
 RECORD lac_nurse_units(
   1 nrsunts[*]
     2 mf_nurse_unit = f8
 ) WITH protect
 SET month = month((curdate - 36))
 IF (((month=1) OR (((3) OR (((5) OR (((7) OR (((8) OR (((10) OR (12)) )) )) )) )) )) )
  SET days = 37
 ELSEIF (month=2)
  SET days = 28
 ELSEIF (((month=4) OR (((6) OR (((9) OR (11)) )) )) )
  SET days = 30
 ENDIF
 CALL echo(build("month",month))
 SET cntl_lac_svc->md_beg_dt_tm = cnvtdatetime((curdate - days),000000)
 SET cntl_lac_svc->md_end_dt_tm = cnvtdatetime((curdate - 6),235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(cntl_lac_svc->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(cntl_lac_svc->md_end_dt_tm),";;q"))
#exit_script
END GO
