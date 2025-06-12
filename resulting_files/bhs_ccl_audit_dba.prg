CREATE PROGRAM bhs_ccl_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 ccl[*]
     2 f_app_nbr = f8
     2 s_object_name = vc
     2 l_cnt = i4
     2 s_beg_dt_tm = vc
     2 s_end_dt_tm = vc
     2 s_params = vc
     2 s_object_type = vc
     2 s_output_dev = vc
     2 s_status = vc
     2 s_owner = vc
     2 s_timestamp = vc
     2 s_source = vc
     2 n_group = i2
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $S_END_DT," 23:59:59"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_max_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  p.name_last, d.user_name, d.object_name,
  d.source_name
  FROM dprotect d,
   prsnl p,
   dummyt d1
  PLAN (d
   WHERE d.object="P")
   JOIN (d1)
   JOIN (p
   WHERE p.username=d.user_name)
  ORDER BY d.source_name
  HEAD REPORT
   pl_cnt = 0, pl_skip = 0
  DETAIL
   IF (((d.source_name="*cer_script*") OR (cnvtupper(d.source_name) != "*/*"
    AND d.source_name != "*\*"
    AND ((d.object_name="HIM*") OR (((d.object_name="HLA*") OR (((d.object_name="ACCESSION*") OR (((d
   .object_name="AFC*") OR (((d.object_name="ATR*") OR (((d.object_name="CCL*") OR (((d.object_name=
   "CERN*") OR (((d.object_name="CHART*") OR (((d.object_name="CLS*") OR (((d.object_name="CNT*") OR
   (((d.object_name="CPS*") OR (((d.object_name="CVA*") OR (((d.object_name="CV*") OR (((d
   .object_name="DCP*") OR (((d.object_name="DEPT*") OR (((d.object_name="DM*") OR (((d.object_name=
   "EC*") OR (((d.object_name="EKS*") OR (((d.object_name="ENCNTR*") OR (((d.object_name="ENS*") OR (
   ((d.object_name="FN*") OR (((d.object_name="FSI*") OR (((d.object_name="GT*") OR (((d.object_name=
   "GET*") OR (((d.object_name="GLB*") OR (((d.object_name="KIA*") OR (((d.object_name="LIST*") OR (
   ((d.object_name="MIC*") OR (((d.object_name="MMC*") OR (((d.object_name="MMR*") OR (((d
   .object_name="MM*") OR (((d.object_name="OCD*") OR (((d.object_name="OMF*") OR (((d.object_name=
   "OPF*") OR (((d.object_name="OPS*") OR (((d.object_name="OP*") OR (((d.object_name="ORDER*") OR (
   ((d.object_name="ORM*") OR (((d.object_name="ORG*") OR (((d.object_name="OS_*") OR (((d
   .object_name="PCS*") OR (((d.object_name="PC_*") OR (((d.object_name="PFMT*") OR (((d.object_name=
   "PFT*") OR (((d.object_name="PHA*") OR (((d.object_name="PM_*") OR (((d.object_name="PRSNL*") OR (
   ((d.object_name="RX*") OR (((d.object_name="SCH*") OR (((d.object_name="SN*") OR (((d.object_name=
   "USR*") OR (((d.object_name="VAM*") OR (((d.object_name="VCCL*") OR (d.object_name="VIEW*")) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
    pl_skip = 0
   ELSE
    pl_skip = 1
   ENDIF
   IF (pl_skip >= 0)
    ml_idx = locateval(ml_cnt,1,ml_max_cnt,d.object_name,m_rec->ccl[ml_cnt].s_object_name)
    IF (ml_idx > 0)
     ml_cnt = ml_idx
    ELSE
     pl_cnt = (pl_cnt+ 1), ml_cnt = pl_cnt
     IF (pl_cnt > size(m_rec->ccl,5))
      stat = alterlist(m_rec->ccl,(pl_cnt+ 25))
     ENDIF
    ENDIF
    IF (d.user_name="EN15469")
     ms_tmp = "Kauffman, Bob"
    ELSE
     ms_tmp = trim(p.name_full_formatted)
    ENDIF
    m_rec->ccl[ml_cnt].s_owner = ms_tmp, m_rec->ccl[ml_cnt].s_source = trim(d.source_name), m_rec->
    ccl[ml_cnt].s_timestamp = concat(trim(format(d.datestamp,"dd-mmm-yyyy;;d"))," ",trim(format(d
       .timestamp,"hh:mm;;d"))),
    m_rec->ccl[ml_cnt].n_group = d.group, m_rec->ccl[ml_cnt].s_object_name = trim(d.object_name)
   ENDIF
   pl_skip = 0
  FOOT REPORT
   stat = alterlist(m_rec->ccl,pl_cnt)
  WITH nocounter, outerjoin = d1, maxrow = 1,
   maxcol = 2000, format, separator = " "
 ;end select
 SELECT INTO value(ms_output)
  ps_object_name = m_rec->ccl[d.seq].s_object_name
  FROM (dummyt d  WITH seq = value(size(m_rec->ccl,5)))
  ORDER BY ps_object_name
  HEAD REPORT
   pl_cnt = 0, pl_col = 0, col pl_col,
   "Object_Name", pl_col = (pl_col+ 50), col pl_col,
   "CBO_Status", pl_col = (pl_col+ 15), col pl_col,
   "Priority", pl_col = (pl_col+ 15), col pl_col,
   "Source", pl_col = (pl_col+ 150), col pl_col,
   "Owner", pl_col = (pl_col+ 50), col pl_col,
   "Last_Included", pl_col = (pl_col+ 20), col pl_col,
   "Poor_Performer", pl_col = (pl_col+ 15), col pl_col,
   "Run_From", pl_col = (pl_col+ 15), col pl_col,
   "Rule_Name", pl_col = (pl_col+ 15), col pl_col,
   "Test_Script", pl_col = (pl_col+ 15), col pl_col,
   "Execute_Command", pl_col = (pl_col+ 100), col pl_col,
   "Description", pl_col = (pl_col+ 15), col pl_col,
   "Purpose", pl_col = (pl_col+ 15), col pl_col,
   "Fix_Notes", pl_col = (pl_col+ 15)
  DETAIL
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt < 10)
    CALL echo(m_rec->ccl[d.seq].s_timestamp)
   ENDIF
   IF (cnvtdatetime(m_rec->ccl[d.seq].s_timestamp) >= cnvtdatetime("03-JUN-2012 00:00:00"))
    CALL echo(m_rec->ccl[d.seq].s_timestamp), row + 1, pl_col = 0,
    col pl_col, m_rec->ccl[d.seq].s_object_name, pl_col = (pl_col+ 50),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, m_rec->ccl[d.seq].s_source, pl_col = (pl_col+ 150),
    col pl_col, m_rec->ccl[d.seq].s_owner, pl_col = (pl_col+ 50),
    col pl_col, m_rec->ccl[d.seq].s_timestamp, pl_col = (pl_col+ 20),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, m_rec->ccl[d.seq].s_params, pl_col = (pl_col+ 100),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15),
    col pl_col, " ", pl_col = (pl_col+ 15)
   ENDIF
  WITH nocounter, maxcol = 20000, format,
   separator = " ", maxrow = 1
 ;end select
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH skipreport = value(1)
 ;end select
#exit_script
 FREE RECORD m_rec
END GO
