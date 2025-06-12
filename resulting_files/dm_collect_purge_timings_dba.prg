CREATE PROGRAM dm_collect_purge_timings:dba
 DECLARE dcpt_formatdate = vc WITH protect, noconstant("")
 DECLARE dcpt_curtext = vc WITH protect, noconstant("")
 DECLARE dcpt_passthrustmt = vc WITH protect, noconstant("")
 DECLARE dcpt_rowstr = vc WITH protect, noconstant("")
 DECLARE dcpt_adminlink = vc WITH protect, noconstant("")
 DECLARE dcpt_idxcoalescetmsum = f8 WITH protect, noconstant(0.0)
 DECLARE dcpt_tblpurgetmsum = f8 WITH protect, noconstant(0.0)
 DECLARE dcpt_rowidcollectiontm = f8 WITH protect, noconstant(0.0)
 DECLARE dcpt_idxcnt = i4 WITH protect, noconstant(0)
 DECLARE dcpt_tablecnt = i4 WITH protect, noconstant(0)
 DECLARE dcpt_loop = i4 WITH protect, noconstant(0)
 DECLARE dcpt_templatecount = i4 WITH protect, noconstant(0)
 DECLARE dcpt_curtablecnt = i4 WITH protect, noconstant(0)
 DECLARE dcpt_lvalidx = i4 WITH protect, noconstant(0)
 DECLARE dcpt_templateidx = i4 WITH protect, noconstant(0)
 DECLARE dcpt_curtemplatenbr = i4 WITH protect, noconstant(0)
 DECLARE dcpt_tableidx = i4 WITH protect, noconstant(0)
 DECLARE dcpt_periodpos = i2 WITH protect, noconstant(0)
 DECLARE dcpt_choice = i2 WITH protect, noconstant(0)
 DECLARE dcpt_linkexistsind = i2 WITH protect, noconstant(0)
 DECLARE dcpt_timingscollectind = i2 WITH protect, noconstant(0)
 DECLARE dcpt_basefilename = vc WITH protect, constant(build("dm_purge_log_report_",cnvtstring(
    cnvtdatetime(curdate,curtime3))))
 DECLARE dcpt_hroutfile = vc WITH protect, constant(concat(dcpt_basefilename,".txt"))
 DECLARE dcpt_hrcclpath = vc WITH protect, constant(concat("ccluserdir:",dcpt_hroutfile))
 DECLARE dcpt_hrospath = vc WITH protect, noconstant("")
 DECLARE dcpt_csvoutfile = vc WITH protect, constant(concat(dcpt_basefilename,".csv"))
 DECLARE dcpt_csvcclpath = vc WITH protect, constant(concat("ccluserdir:",dcpt_csvoutfile))
 DECLARE dcpt_csvospath = vc WITH protect, noconstant("")
 IF (cursys="AXP")
  SET dcpt_hrospath = dcpt_hrcclpath
  SET dcpt_csvospath = dcpt_csvcclpath
 ELSE
  SET dcpt_hrospath = concat("$CCLUSERDIR/",dcpt_hroutfile)
  SET dcpt_csvospath = concat("$CCLUSERDIR/",dcpt_csvoutfile)
 ENDIF
 DECLARE dcpt_format_minutes(dcptfm_rawminutes=f8) = vc
 FREE RECORD dcpt_tablestats
 RECORD dcpt_tablestats(
   1 list_0[*]
     2 templatenbr = i4
     2 tables[*]
       3 tablename = vc
       3 rowcnt = f8
       3 lastanalyzed = dq8
 )
 FREE RECORD dcpt_purgestats
 RECORD dcpt_purgestats(
   1 list_0[*]
     2 tablename = vc
     2 rowcnt = f8
 )
 SET message = nowindow
 SET message = window
 SET width = 132
 CALL clear(1,1)
 CALL video(n)
 CALL video(r)
 CALL box(1,1,20,132)
 CALL clear(2,2,130)
 CALL clear(3,2,130)
 CALL text(2,46,"DM Purge Job Timing Report Generator")
 CALL video(n)
 CALL text(6,8,"Please indicate the type of report you wish to generate: ")
 CALL text(7,12,"1. Three most-recent runs of each purge job")
 CALL text(8,12,"2. All runs of each purge job")
 CALL text(10,12,"0. Exit")
 CALL text(12,8,"Please enter a choice: ")
 CALL accept(12,31,"P;CU"," "
  WHERE curaccept IN ("1", "2", "0"))
 SET dcpt_choice = cnvtint(curaccept)
 CALL clear(1,1)
 SET message = nowindow
 IF (dcpt_choice=0)
  GO TO exit_script
 ELSEIF (dcpt_choice=1)
  CALL echo(
   "User has indicated that only three most-recent logs be reported for each purge template.")
  SET dcpt_passthrustmt = concat(
   "dpjl.job_id = dpj.job_id and (select count(*) from dm_purge_job_log dpjl2 ",
   "           where dpjl2.job_id = dpjl.job_id ",
   "             and dpjl2.log_id > dpjl.log_id) <= 2 ")
 ELSE
  CALL echo("User has indicated that all logs be reported for each purge template.")
  SET dcpt_passthrustmt = "dpjl.job_id = dpj.job_id"
 ENDIF
 CALL echo("Looking up link to admin database...")
 SELECT DISTINCT INTO "nl:"
  ds.db_link
  FROM dba_synonyms ds
  WHERE ds.synonym_name="DM_ENVIRONMENT"
  DETAIL
   dcpt_periodpos = findstring(".WORLD",ds.db_link), dcpt_adminlink = cnvtupper(substring(1,(
     dcpt_periodpos - 1),ds.db_link)), dcpt_linkexistsind = 1
  WITH nocounter
 ;end select
 CALL echo("Done.")
 IF (dcpt_linkexistsind=1)
  CALL echo("Admin database link found.")
 ELSE
  CALL echo("No link found to admin database; statistics for admin tables will not be collected.")
 ENDIF
 CALL echo("Collecting purge table information from local database...")
 SELECT INTO "nl:"
  FROM dm_purge_table dpt,
   user_tables ut
  PLAN (dpt
   WHERE dpt.template_nbr IN (
   (SELECT
    dpj.template_nbr
    FROM dm_purge_job dpj
    WHERE  EXISTS (
    (SELECT
     dpjl.log_id
     FROM dm_purge_job_log dpjl
     WHERE  EXISTS (
     (SELECT
      dpjlt.job_log_timing_id
      FROM dm_purge_job_log_timing dpjlt
      WHERE dpjlt.log_id=dpjl.log_id))))))
    AND (dpt.schema_dt_tm=
   (SELECT
    max(dpt2.schema_dt_tm)
    FROM dm_purge_table dpt2
    WHERE dpt2.template_nbr=dpt.template_nbr)))
   JOIN (ut
   WHERE ((ut.table_name=cnvtupper(dpt.parent_table)) OR (ut.table_name=cnvtupper(dpt.child_table)))
   )
  ORDER BY dpt.template_nbr, ut.table_name
  HEAD REPORT
   dcpt_templatecount = 0
  HEAD dpt.template_nbr
   dcpt_templatecount = (dcpt_templatecount+ 1), dcpt_curtablecnt = 0
   IF (mod(dcpt_templatecount,10)=1)
    stat = alterlist(dcpt_tablestats->list_0,(dcpt_templatecount+ 9))
   ENDIF
   dcpt_tablestats->list_0[dcpt_templatecount].templatenbr = dpt.template_nbr
  HEAD ut.table_name
   dcpt_curtablecnt = (dcpt_curtablecnt+ 1), stat = alterlist(dcpt_tablestats->list_0[
    dcpt_templatecount].tables,dcpt_curtablecnt), dcpt_tablestats->list_0[dcpt_templatecount].tables[
   dcpt_curtablecnt].tablename = ut.table_name,
   dcpt_tablestats->list_0[dcpt_templatecount].tables[dcpt_curtablecnt].rowcnt = ut.num_rows,
   dcpt_tablestats->list_0[dcpt_templatecount].tables[dcpt_curtablecnt].lastanalyzed = ut
   .last_analyzed
  WITH nocounter
 ;end select
 CALL echo("Done.")
 IF (dcpt_linkexistsind=1)
  CALL echo("Collecting purge table information from admin database...")
  SELECT INTO "nl:"
   FROM dm_purge_table dpt,
    (value(concat("USER_TABLES@",dcpt_adminlink)) ut)
   PLAN (dpt
    WHERE dpt.template_nbr IN (
    (SELECT
     dpj.template_nbr
     FROM dm_purge_job dpj
     WHERE  EXISTS (
     (SELECT
      dpjl.log_id
      FROM dm_purge_job_log dpjl
      WHERE  EXISTS (
      (SELECT
       dpjlt.job_log_timing_id
       FROM dm_purge_job_log_timing dpjlt
       WHERE dpjlt.log_id=dpjl.log_id))))))
     AND (dpt.schema_dt_tm=
    (SELECT
     max(dpt2.schema_dt_tm)
     FROM dm_purge_table dpt2
     WHERE dpt2.template_nbr=dpt.template_nbr)))
    JOIN (ut
    WHERE ((ut.table_name=cnvtupper(dpt.parent_table)) OR (ut.table_name=cnvtupper(dpt.child_table)
    )) )
   ORDER BY dpt.template_nbr, ut.table_name
   HEAD dpt.template_nbr
    dcpt_templateidx = locateval(dcpt_lvalidx,1,dcpt_templatecount,dpt.template_nbr,dcpt_tablestats->
     list_0[dcpt_lvalidx].templatenbr)
    IF (dcpt_templateidx=0)
     dcpt_templatecount = (dcpt_templatecount+ 1), dcpt_curtablecnt = 0
     IF (mod(dcpt_templatecount,10)=1)
      stat = alterlist(dcpt_tablestats->list_0,(dcpt_templatecount+ 9))
     ENDIF
     dcpt_tablestats->list_0[dcpt_templatecount].templatenbr = dpt.template_nbr, dcpt_templateidx =
     dcpt_templatecount
    ELSE
     dcpt_curtablecnt = size(dcpt_tablestats->list_0[dcpt_templateidx].tables,5)
    ENDIF
   HEAD ut.table_name
    dcpt_tableidx = locateval(dcpt_lvalidx,1,dcpt_curtablecnt,ut.table_name,dcpt_tablestats->list_0[
     dcpt_templateidx].tables[dcpt_lvalidx].tablename)
    IF (dcpt_tableidx=0)
     dcpt_curtablecnt = (dcpt_curtablecnt+ 1), stat = alterlist(dcpt_tablestats->list_0[
      dcpt_templateidx].tables,dcpt_curtablecnt), dcpt_tablestats->list_0[dcpt_templateidx].tables[
     dcpt_curtablecnt].tablename = ut.table_name,
     dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_curtablecnt].rowcnt = ut.num_rows,
     dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_curtablecnt].lastanalyzed = ut
     .last_analyzed
    ENDIF
   WITH nocounter
  ;end select
  CALL echo("Done.")
 ENDIF
 SET stat = alterlist(dcpt_tablestats->list_0,dcpt_templatecount)
 CALL echo("Collecting purge job information into human-readable format...")
 SELECT INTO value(dcpt_hrcclpath)
  FROM dm_purge_job dpj,
   dm_purge_job_log dpjl,
   dm_purge_job_log_tab dpjlta,
   dm_purge_job_log_timing dpjlt,
   dm_info di
  PLAN (dpj)
   JOIN (dpjl
   WHERE sqlpassthru(dcpt_passthrustmt))
   JOIN (dpjlta
   WHERE dpjlta.log_id=dpjl.log_id
    AND dpjlta.table_name > " ")
   JOIN (di
   WHERE di.info_domain="DM PURGE COALESCE"
    AND di.info_long_id=cnvtreal(dpj.template_nbr))
   JOIN (dpjlt
   WHERE dpjlt.log_id=dpjl.log_id)
  ORDER BY dpj.template_nbr, dpjl.log_id DESC, dpjlta.table_name
  HEAD REPORT
   dcpt_formatdate = format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"), row + 1, col 0,
   "Report Generated: ", dcpt_formatdate
  HEAD dpj.template_nbr
   row + 1, col 0, " ",
   dcpt_curtemplatenbr = dpj.template_nbr, dcpt_curtext = trim(cnvtstring(dcpt_curtemplatenbr),3),
   row + 1,
   col 0, "Template Number: ", dcpt_curtext,
   dcpt_curtext = evaluate(di.info_number,1.0,"ENABLED","DISABLED"), row + 1, col 0,
   "Coalescing: ", dcpt_curtext, dcpt_templateidx = locateval(dcpt_lvalidx,1,dcpt_templatecount,
    dcpt_curtemplatenbr,dcpt_tablestats->list_0[dcpt_lvalidx].templatenbr)
   IF (dcpt_templateidx > 0)
    row + 1, col 0, "Tables purged by template:"
    FOR (dcpt_loop = 1 TO size(dcpt_tablestats->list_0[dcpt_templateidx].tables,5))
      row + 1, col 2, dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_loop].tablename
      IF ((dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_loop].lastanalyzed=0.0))
       row + 1, col 4, "No usable statistics found"
      ELSE
       dcpt_curtext = trim(cnvtstring(dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_loop].
         rowcnt),3), row + 1, col 4,
       "Row Count: ", dcpt_curtext, dcpt_formatdate = format(dcpt_tablestats->list_0[dcpt_templateidx
        ].tables[dcpt_loop].lastanalyzed,"@SHORTDATETIME"),
       row + 1, col 4, "Current as of: ",
       dcpt_formatdate
      ENDIF
    ENDFOR
   ELSE
    row + 1, col 0, "No valid table statistics found"
   ENDIF
  HEAD dpjl.log_id
   dcpt_idxcnt = 0, dcpt_tblpurgetmsum = 0.0, dcpt_idxcoalescetmsum = 0.0,
   dcpt_rowidcollectiontm = 0.0, stat = alterlist(dcpt_purgestats->list_0,0), dcpt_tablecnt = 0,
   dcpt_timingscollectind = 0
  HEAD dpjlta.table_name
   dcpt_tablecnt = (dcpt_tablecnt+ 1), stat = alterlist(dcpt_purgestats->list_0,dcpt_tablecnt),
   dcpt_purgestats->list_0[dcpt_tablecnt].tablename = dpjlta.table_name,
   dcpt_purgestats->list_0[dcpt_tablecnt].rowcnt = dpjlta.num_rows
  HEAD dpjlt.value_key
   IF (dcpt_timingscollectind=0)
    IF (dpjlt.value_key=patstring("TBL_TM_*"))
     dcpt_tblpurgetmsum = (dcpt_tblpurgetmsum+ dpjlt.value_nbr)
    ELSEIF (dpjlt.value_key=patstring("IDX_TM_*"))
     dcpt_idxcoalescetmsum = (dcpt_idxcoalescetmsum+ dpjlt.value_nbr), dcpt_idxcnt = (dcpt_idxcnt+ 1)
    ELSE
     dcpt_rowidcollectiontm = dpjlt.value_nbr
    ENDIF
   ENDIF
  FOOT  dpjlta.table_name
   dcpt_timingscollectind = 1
  FOOT  dpjl.log_id
   row + 1, col 0, " ",
   row + 1, col 2, "JOB LOG",
   dcpt_curtext = trim(cnvtstring(dpjl.log_id),3), row + 1, col 4,
   "Log ID: ", dcpt_curtext, dcpt_formatdate = format(dpjl.start_dt_tm,"@SHORTDATETIME"),
   row + 1, col 4, "Start Date/Time: ",
   dcpt_formatdate, dcpt_formatdate = format(dpjl.end_dt_tm,"@SHORTDATETIME"), row + 1,
   col 4, "End Date/Time: ", dcpt_formatdate,
   dcpt_curtext = dcpt_format_minutes(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm,4)), row + 1, col
   4,
   "Duration: ", dcpt_curtext, dcpt_curtext = build(dpjl.err_code),
   row + 1, col 4, "Error Code: ",
   dcpt_curtext, row + 1, col 4,
   "Error Message: ", dpjl.err_msg, dcpt_curtext = dcpt_format_minutes(dcpt_rowidcollectiontm),
   row + 1, col 4, "Time Gathering ROWIDs: ",
   dcpt_curtext, dcpt_curtext = dcpt_format_minutes(dcpt_tblpurgetmsum), row + 1,
   col 4, "Time Purging Rows: ", dcpt_curtext,
   dcpt_curtext = dcpt_format_minutes(dcpt_idxcoalescetmsum), row + 1, col 4,
   "Time Coalescing Indexes: ", dcpt_curtext, dcpt_curtext = build(dcpt_idxcnt),
   row + 1, col 4, "Number of Indexes Coalesced: ",
   dcpt_curtext, row + 1, col 4,
   "Table Purging Statistics:"
   FOR (dcpt_loop = 1 TO dcpt_tablecnt)
     IF ((dcpt_purgestats->list_0[dcpt_loop].rowcnt=1))
      dcpt_rowstr = "row"
     ELSE
      dcpt_rowstr = "rows"
     ENDIF
     dcpt_curtext = concat(dcpt_purgestats->list_0[dcpt_loop].tablename,": ",trim(cnvtstring(
        dcpt_purgestats->list_0[dcpt_loop].rowcnt),3)," ",dcpt_rowstr,
      " purged"), row + 1, col 6,
     dcpt_curtext
   ENDFOR
  FOOT  dpj.template_nbr
   row + 1, col 0, "==============================================="
  WITH nocounter, maxrow = 1, maxcol = 800,
   format = variable
 ;end select
 CALL echo("Done.")
 CALL echo("Collecting purge job information into CSV...")
 SELECT INTO value(dcpt_csvcclpath)
  FROM dm_purge_job dpj,
   dm_purge_job_log dpjl,
   dm_purge_job_log_tab dpjlta,
   dm_purge_job_log_timing dpjlt,
   dm_info di
  PLAN (dpj)
   JOIN (dpjl
   WHERE sqlpassthru(dcpt_passthrustmt))
   JOIN (dpjlta
   WHERE dpjlta.log_id=dpjl.log_id
    AND dpjlta.table_name > " ")
   JOIN (di
   WHERE di.info_domain="DM PURGE COALESCE"
    AND di.info_long_id=cnvtreal(dpj.template_nbr))
   JOIN (dpjlt
   WHERE dpjlt.log_id=dpjl.log_id)
  ORDER BY dpj.template_nbr, dpjl.log_id DESC, dpjlta.table_name
  HEAD REPORT
   dcpt_curtext = build(
    "template_nbr,coalescing_ind,table_purge,table_row_cnt,table_anlyzd_date,log_id,",
    "log_start_dt_tm,log_end_dt_tm,log_duration,err_code,err_msg,rowid_gather_tm,purge_tm,",
    "coalesce_tm,num_indexes,log_table_purged,log_purge_count"), row + 1, col 0,
   dcpt_curtext
  HEAD dpj.template_nbr
   dcpt_curtext = build(dpj.template_nbr,",",cnvtstring(di.info_number),",,,,,,,,,,,,,,,"), row + 1,
   col 0,
   dcpt_curtext, dcpt_templateidx = locateval(dcpt_lvalidx,1,dcpt_templatecount,dpj.template_nbr,
    dcpt_tablestats->list_0[dcpt_lvalidx].templatenbr)
   IF (dcpt_templateidx > 0)
    FOR (dcpt_loop = 1 TO size(dcpt_tablestats->list_0[dcpt_templateidx].tables,5))
      IF ((dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_loop].lastanalyzed > 0.0))
       dcpt_curtext = build(dpj.template_nbr,",,",dcpt_tablestats->list_0[dcpt_templateidx].tables[
        dcpt_loop].tablename,",",cnvtstring(dcpt_tablestats->list_0[dcpt_templateidx].tables[
         dcpt_loop].rowcnt),
        ",",format(dcpt_tablestats->list_0[dcpt_templateidx].tables[dcpt_loop].lastanalyzed,
         "@SHORTDATETIME"),",,,,,,,,,,,,"), row + 1, col 0,
       dcpt_curtext
      ENDIF
    ENDFOR
   ENDIF
  HEAD dpjl.log_id
   dcpt_idxcnt = 0, dcpt_tblpurgetmsum = 0.0, dcpt_idxcoalescetmsum = 0.0,
   dcpt_rowidcollectiontm = 0.0, stat = alterlist(dcpt_purgestats->list_0,0), dcpt_tablecnt = 0,
   dcpt_timingscollectind = 0
  HEAD dpjlta.table_name
   dcpt_tablecnt = (dcpt_tablecnt+ 1), stat = alterlist(dcpt_purgestats->list_0,dcpt_tablecnt),
   dcpt_purgestats->list_0[dcpt_tablecnt].tablename = dpjlta.table_name,
   dcpt_purgestats->list_0[dcpt_tablecnt].rowcnt = dpjlta.num_rows
  HEAD dpjlt.value_key
   IF (dcpt_timingscollectind=0)
    IF (dpjlt.value_key=patstring("TBL_TM_*"))
     dcpt_tblpurgetmsum = (dcpt_tblpurgetmsum+ dpjlt.value_nbr)
    ELSEIF (dpjlt.value_key=patstring("IDX_TM_*"))
     dcpt_idxcoalescetmsum = (dcpt_idxcoalescetmsum+ dpjlt.value_nbr), dcpt_idxcnt = (dcpt_idxcnt+ 1)
    ELSE
     dcpt_rowidcollectiontm = dpjlt.value_nbr
    ENDIF
   ENDIF
  FOOT  dpjlta.table_name
   dcpt_timingscollectind = 1
  FOOT  dpjl.log_id
   dcpt_curtext = build(dpj.template_nbr,",,,,,",cnvtstring(dpjl.log_id),",",format(dpjl.start_dt_tm,
     "@SHORTDATETIME"),
    ",",format(dpjl.end_dt_tm,"@SHORTDATETIME"),",",datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm,4),
    ",",
    dpjl.err_code,",",'"',dpjl.err_msg,'"',
    ",",dcpt_rowidcollectiontm,",",dcpt_tblpurgetmsum,",",
    dcpt_idxcoalescetmsum,",",dcpt_idxcnt,",,"), row + 1, col 0,
   dcpt_curtext
   FOR (dcpt_loop = 1 TO dcpt_tablecnt)
     dcpt_curtext = build(dpj.template_nbr,",,,,,",cnvtstring(dpjlt.log_id),",,,,,,,,,,",
      dcpt_purgestats->list_0[dcpt_loop].tablename,
      ",",cnvtstring(dcpt_purgestats->list_0[dcpt_loop].rowcnt)), row + 1, col 0,
     dcpt_curtext
   ENDFOR
  WITH nocounter, maxrow = 1, maxcol = 800,
   format = variable
 ;end select
 CALL echo("Done.")
 CALL echo("Report generation completed")
 CALL echo("Human-readable report:")
 CALL echo(concat("  CCL location: ",dcpt_hrcclpath))
 CALL echo(concat("  OS location: ",dcpt_hrospath))
 CALL echo("CSV report:")
 CALL echo(concat("  CCL location: ",dcpt_csvcclpath))
 CALL echo(concat("  OS location: ",dcpt_csvospath))
 SUBROUTINE dcpt_format_minutes(dcptfm_rawminutes)
   DECLARE dcptfm_numhours = i2 WITH protect, noconstant(0)
   DECLARE dcptfm_numminutes = i2 WITH protect, noconstant(0)
   DECLARE dcptfm_numsecs = f8 WITH protect, noconstant(0.0)
   DECLARE dcptfm_formattime = vc WITH protect, noconstant("")
   SET dcptfm_numhours = floor((dcptfm_rawminutes/ 60.0))
   SET dcptfm_numminutes = floor((dcptfm_rawminutes - (dcptfm_numhours * 60.0)))
   SET dcptfm_numsecs = round((((dcptfm_rawminutes - (dcptfm_numhours * 60)) - dcptfm_numminutes) *
    60.0),2)
   SET dcptfm_formattime = concat(trim(cnvtstring(dcptfm_numhours),3),"hrs ",trim(cnvtstring(
      dcptfm_numminutes),3),"m ",trim(cnvtstring(dcptfm_numsecs),3),
    "s")
   RETURN(dcptfm_formattime)
 END ;Subroutine
#exit_script
 FREE RECORD dcpt_tablestats
 FREE RECORD dcpt_purgestats
END GO
