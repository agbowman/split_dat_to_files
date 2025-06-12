CREATE PROGRAM dm_collect_old_purge_timings:dba
 DECLARE dcopt_formatdate = vc WITH protect, noconstant("")
 DECLARE dcopt_curtext = vc WITH protect, noconstant("")
 DECLARE dcopt_rowstr = vc WITH protect, noconstant("")
 DECLARE dcopt_adminlink = vc WITH protect, noconstant("")
 DECLARE dcopt_idxcoalescetmsum = f8 WITH protect, noconstant(0.0)
 DECLARE dcopt_tblpurgetmsum = f8 WITH protect, noconstant(0.0)
 DECLARE dcopt_rowidcollectiontm = f8 WITH protect, noconstant(0.0)
 DECLARE dcopt_idxcnt = i4 WITH protect, noconstant(0)
 DECLARE dcopt_tablecnt = i4 WITH protect, noconstant(0)
 DECLARE dcopt_loop = i4 WITH protect, noconstant(0)
 DECLARE dcopt_templatecount = i4 WITH protect, noconstant(0)
 DECLARE dcopt_curtablecnt = i4 WITH protect, noconstant(0)
 DECLARE dcopt_lvalidx = i4 WITH protect, noconstant(0)
 DECLARE dcopt_templateidx = i4 WITH protect, noconstant(0)
 DECLARE dcopt_curtemplatenbr = i4 WITH protect, noconstant(0)
 DECLARE dcopt_tableidx = i4 WITH protect, noconstant(0)
 DECLARE dcopt_periodpos = i2 WITH protect, noconstant(0)
 DECLARE dcopt_choice = i2 WITH protect, noconstant(0)
 DECLARE dcopt_linkexistsind = i2 WITH protect, noconstant(0)
 DECLARE dcopt_startdttm = dq8 WITH protect, noconstant(0.0)
 DECLARE dcopt_basefilename = vc WITH protect, constant(build("dm_purge_log_report_",cnvtstring(
    cnvtdatetime(curdate,curtime3))))
 DECLARE dcopt_hroutfile = vc WITH protect, constant(concat(dcopt_basefilename,".txt"))
 DECLARE dcopt_hrcclpath = vc WITH protect, constant(concat("ccluserdir:",dcopt_hroutfile))
 DECLARE dcopt_hrospath = vc WITH protect, noconstant("")
 DECLARE dcopt_csvoutfile = vc WITH protect, constant(concat(dcopt_basefilename,".csv"))
 DECLARE dcopt_csvcclpath = vc WITH protect, constant(concat("ccluserdir:",dcopt_csvoutfile))
 DECLARE dcopt_csvospath = vc WITH protect, noconstant("")
 IF (cursys="AXP")
  SET dcopt_hrospath = dcopt_hrcclpath
  SET dcopt_csvospath = dcopt_csvcclpath
 ELSE
  SET dcopt_hrospath = concat("$CCLUSERDIR/",dcopt_hroutfile)
  SET dcopt_csvospath = concat("$CCLUSERDIR/",dcopt_csvoutfile)
 ENDIF
 DECLARE dcopt_format_minutes(dcptfm_rawminutes=f8) = vc
 FREE RECORD dcopt_tablestats
 RECORD dcopt_tablestats(
   1 list_0[*]
     2 templatenbr = i4
     2 tables[*]
       3 tablename = vc
       3 rowcnt = f8
       3 lastanalyzed = dq8
 )
 FREE RECORD dcopt_purgestats
 RECORD dcopt_purgestats(
   1 list_0[*]
     2 tablename = vc
     2 rowcnt = f8
 )
 CALL echo("Fetching the trigger creation date/time...")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM PURGE"
   AND di.info_name="PURGE HISTORY START"
  DETAIL
   dcopt_startdttm = di.info_date
  WITH nocounter
 ;end select
 CALL echo("Done.")
 IF (dcopt_startdttm=0.0)
  CALL echo(
   "Either no DM_INFO date row exists, or there was an error while obtaining the date/time; exiting..."
   )
  GO TO exit_script
 ENDIF
 CALL echo(concat("Searching for purge job log entries since: ",format(cnvtdatetime(dcopt_startdttm),
    "@SHORTDATETIME")))
 CALL echo("Collecting statistics for all jobs that have run since trigger creation...")
 CALL echo("Looking up link to admin database...")
 SELECT DISTINCT INTO "nl:"
  ds.db_link
  FROM dba_synonyms ds
  WHERE ds.synonym_name="DM_ENVIRONMENT"
  DETAIL
   dcopt_periodpos = findstring(".WORLD",ds.db_link), dcopt_adminlink = cnvtupper(substring(1,(
     dcopt_periodpos - 1),ds.db_link)), dcopt_linkexistsind = 1
  WITH nocounter
 ;end select
 CALL echo("Done.")
 IF (dcopt_linkexistsind=1)
  CALL echo("Admin database link found.")
 ELSE
  CALL echo("No link found to admin database; statistics for admin tables will not be collected.")
 ENDIF
 CALL echo("Collecting purge table information from local database...")
 SELECT INTO "nl:"
  FROM dm_purge_table dpt,
   user_tables ut
  PLAN (dpt
   WHERE (dpt.schema_dt_tm=
   (SELECT
    max(dpt2.schema_dt_tm)
    FROM dm_purge_table dpt2
    WHERE dpt2.template_nbr=dpt.template_nbr)))
   JOIN (ut
   WHERE ((ut.table_name=cnvtupper(dpt.parent_table)) OR (ut.table_name=cnvtupper(dpt.child_table)))
   )
  ORDER BY dpt.template_nbr, ut.table_name
  HEAD REPORT
   dcopt_templatecount = 0
  HEAD dpt.template_nbr
   dcopt_templatecount = (dcopt_templatecount+ 1), dcopt_curtablecnt = 0
   IF (mod(dcopt_templatecount,10)=1)
    stat = alterlist(dcopt_tablestats->list_0,(dcopt_templatecount+ 9))
   ENDIF
   dcopt_tablestats->list_0[dcopt_templatecount].templatenbr = dpt.template_nbr
  HEAD ut.table_name
   dcopt_curtablecnt = (dcopt_curtablecnt+ 1), stat = alterlist(dcopt_tablestats->list_0[
    dcopt_templatecount].tables,dcopt_curtablecnt), dcopt_tablestats->list_0[dcopt_templatecount].
   tables[dcopt_curtablecnt].tablename = ut.table_name,
   dcopt_tablestats->list_0[dcopt_templatecount].tables[dcopt_curtablecnt].rowcnt = ut.num_rows,
   dcopt_tablestats->list_0[dcopt_templatecount].tables[dcopt_curtablecnt].lastanalyzed = ut
   .last_analyzed
  WITH nocounter
 ;end select
 CALL echo("Done.")
 IF (dcopt_linkexistsind=1)
  CALL echo("Collecting purge table information from admin database...")
  SELECT INTO "nl:"
   FROM dm_purge_table dpt,
    (value(concat("USER_TABLES@",dcopt_adminlink)) ut)
   PLAN (dpt
    WHERE (dpt.schema_dt_tm=
    (SELECT
     max(dpt2.schema_dt_tm)
     FROM dm_purge_table dpt2
     WHERE dpt2.template_nbr=dpt.template_nbr)))
    JOIN (ut
    WHERE ((ut.table_name=cnvtupper(dpt.parent_table)) OR (ut.table_name=cnvtupper(dpt.child_table)
    )) )
   ORDER BY dpt.template_nbr, ut.table_name
   HEAD dpt.template_nbr
    dcopt_templateidx = locateval(dcopt_lvalidx,1,dcopt_templatecount,dpt.template_nbr,
     dcopt_tablestats->list_0[dcopt_lvalidx].templatenbr)
    IF (dcopt_templateidx=0)
     dcopt_templatecount = (dcopt_templatecount+ 1), dcopt_curtablecnt = 0
     IF (mod(dcopt_templatecount,10)=1)
      stat = alterlist(dcopt_tablestats->list_0,(dcopt_templatecount+ 9))
     ENDIF
     dcopt_tablestats->list_0[dcopt_templatecount].templatenbr = dpt.template_nbr, dcopt_templateidx
      = dcopt_templatecount
    ELSE
     dcopt_curtablecnt = size(dcopt_tablestats->list_0[dcopt_templateidx].tables,5)
    ENDIF
   HEAD ut.table_name
    dcopt_tableidx = locateval(dcopt_lvalidx,1,dcopt_curtablecnt,ut.table_name,dcopt_tablestats->
     list_0[dcopt_templateidx].tables[dcopt_lvalidx].tablename)
    IF (dcopt_tableidx=0)
     dcopt_curtablecnt = (dcopt_curtablecnt+ 1), stat = alterlist(dcopt_tablestats->list_0[
      dcopt_templateidx].tables,dcopt_curtablecnt), dcopt_tablestats->list_0[dcopt_templateidx].
     tables[dcopt_curtablecnt].tablename = ut.table_name,
     dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_curtablecnt].rowcnt = ut.num_rows,
     dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_curtablecnt].lastanalyzed = ut
     .last_analyzed
    ENDIF
   WITH nocounter
  ;end select
  CALL echo("Done.")
 ENDIF
 SET stat = alterlist(dcopt_tablestats->list_0,dcopt_templatecount)
 CALL echo("Collecting purge job information into human-readable format...")
 SELECT INTO value(dcopt_hrcclpath)
  FROM dm_purge_job dpj,
   dm_purge_job_log dpjl,
   dm_purge_job_log_tab dpjlta
  PLAN (dpj)
   JOIN (dpjl
   WHERE dpjl.job_id=dpj.job_id
    AND  NOT ( EXISTS (
   (SELECT
    dpjlt.job_log_timing_id
    FROM dm_purge_job_log_timing dpjlt
    WHERE dpjlt.log_id=dpjl.log_id)))
    AND dpjl.start_dt_tm >= cnvtdatetime(dcopt_startdttm))
   JOIN (dpjlta
   WHERE dpjlta.log_id=dpjl.log_id
    AND dpjlta.table_name > " ")
  ORDER BY dpj.template_nbr, dpjl.log_id DESC, dpjlta.table_name
  HEAD REPORT
   dcopt_formatdate = format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"), row + 1, col 0,
   "Report Generated: ", dcopt_formatdate
  HEAD dpj.template_nbr
   row + 1, col 0, " ",
   dcopt_curtemplatenbr = dpj.template_nbr, dcopt_curtext = trim(cnvtstring(dcopt_curtemplatenbr),3),
   row + 1,
   col 0, "Template Number: ", dcopt_curtext,
   dcopt_templateidx = locateval(dcopt_lvalidx,1,dcopt_templatecount,dcopt_curtemplatenbr,
    dcopt_tablestats->list_0[dcopt_lvalidx].templatenbr)
   IF (dcopt_templateidx > 0)
    row + 1, col 0, "Tables purged by template:"
    FOR (dcopt_loop = 1 TO size(dcopt_tablestats->list_0[dcopt_templateidx].tables,5))
      row + 1, col 2, dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_loop].tablename
      IF ((dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_loop].lastanalyzed=0.0))
       row + 1, col 4, "No usable statistics found"
      ELSE
       dcopt_curtext = trim(cnvtstring(dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_loop]
         .rowcnt),3), row + 1, col 4,
       "Row Count: ", dcopt_curtext, dcopt_formatdate = format(dcopt_tablestats->list_0[
        dcopt_templateidx].tables[dcopt_loop].lastanalyzed,"@SHORTDATETIME"),
       row + 1, col 4, "Current as of: ",
       dcopt_formatdate
      ENDIF
    ENDFOR
   ELSE
    row + 1, col 0, "No valid table statistics found"
   ENDIF
  HEAD dpjl.log_id
   dcopt_idxcnt = 0, dcopt_tblpurgetmsum = 0.0, dcopt_idxcoalescetmsum = 0.0,
   dcopt_rowidcollectiontm = 0.0, stat = alterlist(dcopt_purgestats->list_0,0), dcopt_tablecnt = 0
  HEAD dpjlta.table_name
   dcopt_tablecnt = (dcopt_tablecnt+ 1), stat = alterlist(dcopt_purgestats->list_0,dcopt_tablecnt),
   dcopt_purgestats->list_0[dcopt_tablecnt].tablename = dpjlta.table_name,
   dcopt_purgestats->list_0[dcopt_tablecnt].rowcnt = dpjlta.num_rows
  FOOT  dpjl.log_id
   row + 1, col 0, " ",
   row + 1, col 2, "JOB LOG",
   dcopt_curtext = trim(cnvtstring(dpjl.log_id),3), row + 1, col 4,
   "Log ID: ", dcopt_curtext, dcopt_formatdate = format(dpjl.start_dt_tm,"@SHORTDATETIME"),
   row + 1, col 4, "Start Date/Time: ",
   dcopt_formatdate, dcopt_formatdate = format(dpjl.end_dt_tm,"@SHORTDATETIME"), row + 1,
   col 4, "End Date/Time: ", dcopt_formatdate,
   dcopt_curtext = dcopt_format_minutes(datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm,4)), row + 1,
   col 4,
   "Duration: ", dcopt_curtext, dcopt_curtext = build(dpjl.err_code),
   row + 1, col 4, "Error Code: ",
   dcopt_curtext, row + 1, col 4,
   "Error Message: ", dpjl.err_msg, row + 1,
   col 4, "Table Purging Statistics:"
   FOR (dcopt_loop = 1 TO dcopt_tablecnt)
     IF ((dcopt_purgestats->list_0[dcopt_loop].rowcnt=1))
      dcopt_rowstr = "row"
     ELSE
      dcopt_rowstr = "rows"
     ENDIF
     dcopt_curtext = concat(dcopt_purgestats->list_0[dcopt_loop].tablename,": ",trim(cnvtstring(
        dcopt_purgestats->list_0[dcopt_loop].rowcnt),3)," ",dcopt_rowstr,
      " purged"), row + 1, col 6,
     dcopt_curtext
   ENDFOR
  FOOT  dpj.template_nbr
   row + 1, col 0, "==============================================="
  WITH nocounter, maxrow = 1, maxcol = 800,
   format = variable
 ;end select
 CALL echo("Done.")
 CALL echo("Collecting purge job information into CSV...")
 SELECT INTO value(dcopt_csvcclpath)
  FROM dm_purge_job dpj,
   dm_purge_job_log dpjl,
   dm_purge_job_log_tab dpjlta
  PLAN (dpj)
   JOIN (dpjl
   WHERE dpjl.job_id=dpj.job_id
    AND  NOT ( EXISTS (
   (SELECT
    dpjlt.job_log_timing_id
    FROM dm_purge_job_log_timing dpjlt
    WHERE dpjlt.log_id=dpjl.log_id)))
    AND dpjl.start_dt_tm >= cnvtdatetime(dcopt_startdttm))
   JOIN (dpjlta
   WHERE dpjlta.log_id=dpjl.log_id
    AND dpjlta.table_name > " ")
  ORDER BY dpj.template_nbr, dpjl.log_id DESC, dpjlta.table_name
  HEAD REPORT
   dcopt_curtext = build(
    "template_nbr,coalescing_ind,table_purge,table_row_cnt,table_anlyzd_date,log_id,",
    "log_start_dt_tm,log_end_dt_tm,log_duration,err_code,err_msg,rowid_gather_tm,purge_tm,",
    "coalesce_tm,num_indexes,log_table_purged,log_purge_count"), row + 1, col 0,
   dcopt_curtext
  HEAD dpj.template_nbr
   dcopt_curtext = build(dpj.template_nbr,",-1,,,,,,,,,,,,,,,"), row + 1, col 0,
   dcopt_curtext, dcopt_templateidx = locateval(dcopt_lvalidx,1,dcopt_templatecount,dpj.template_nbr,
    dcopt_tablestats->list_0[dcopt_lvalidx].templatenbr)
   IF (dcopt_templateidx > 0)
    FOR (dcopt_loop = 1 TO size(dcopt_tablestats->list_0[dcopt_templateidx].tables,5))
      IF ((dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_loop].lastanalyzed > 0.0))
       dcopt_curtext = build(dpj.template_nbr,",,",dcopt_tablestats->list_0[dcopt_templateidx].
        tables[dcopt_loop].tablename,",",cnvtstring(dcopt_tablestats->list_0[dcopt_templateidx].
         tables[dcopt_loop].rowcnt),
        ",",format(dcopt_tablestats->list_0[dcopt_templateidx].tables[dcopt_loop].lastanalyzed,
         "@SHORTDATETIME"),",,,,,,,,,,,,"), row + 1, col 0,
       dcopt_curtext
      ENDIF
    ENDFOR
   ENDIF
  HEAD dpjl.log_id
   dcopt_idxcnt = 0, dcopt_tblpurgetmsum = 0.0, dcopt_idxcoalescetmsum = 0.0,
   dcopt_rowidcollectiontm = 0.0, stat = alterlist(dcopt_purgestats->list_0,0), dcopt_tablecnt = 0
  HEAD dpjlta.table_name
   dcopt_tablecnt = (dcopt_tablecnt+ 1), stat = alterlist(dcopt_purgestats->list_0,dcopt_tablecnt),
   dcopt_purgestats->list_0[dcopt_tablecnt].tablename = dpjlta.table_name,
   dcopt_purgestats->list_0[dcopt_tablecnt].rowcnt = dpjlta.num_rows
  FOOT  dpjl.log_id
   dcopt_curtext = build(dpj.template_nbr,",,,,,",cnvtstring(dpjl.log_id),",",format(dpjl.start_dt_tm,
     "@SHORTDATETIME"),
    ",",format(dpjl.end_dt_tm,"@SHORTDATETIME"),",",datetimediff(dpjl.end_dt_tm,dpjl.start_dt_tm,4),
    ",",
    dpjl.err_code,",",'"',dpjl.err_msg,'"',
    ",0",",0",",0",",0",",,"), row + 1, col 0,
   dcopt_curtext
   FOR (dcopt_loop = 1 TO dcopt_tablecnt)
     dcopt_curtext = build(dpj.template_nbr,",,,,,",cnvtstring(dpjl.log_id),",,,,,,,,,,",
      dcopt_purgestats->list_0[dcopt_loop].tablename,
      ",",cnvtstring(dcopt_purgestats->list_0[dcopt_loop].rowcnt)), row + 1, col 0,
     dcopt_curtext
   ENDFOR
  WITH nocounter, maxrow = 1, maxcol = 800,
   format = variable
 ;end select
 CALL echo("Done.")
 CALL echo("Report generation completed")
 CALL echo("Human-readable report:")
 CALL echo(concat("  CCL location: ",dcopt_hrcclpath))
 CALL echo(concat("  OS location: ",dcopt_hrospath))
 CALL echo("CSV report:")
 CALL echo(concat("  CCL location: ",dcopt_csvcclpath))
 CALL echo(concat("  OS location: ",dcopt_csvospath))
 SUBROUTINE dcopt_format_minutes(dcptfm_rawminutes)
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
 FREE RECORD dcopt_tablestats
 FREE RECORD dcopt_purgestats
END GO
