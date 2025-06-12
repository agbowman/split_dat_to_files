CREATE PROGRAM dcp_clr_dup_prsnl_hist_tm:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = concat("Failed starting ",cnvtlower(curprog),"...")
 IF ((validate(drr_readmes_to_run->readme_cnt,- (1))=- (1)))
  SET readme_data->status = "S"
  SET readme_data->message =
  "Readme is made to only work as part of a report generation; auto-sucessing."
  GO TO exit_script
 ENDIF
 FREE RECORD timing_tables
 RECORD timing_tables(
   1 list_0[*]
     2 table_name = vc
     2 table_weight = f8
     2 row_count = i4
     2 table_found_ind = i2
 )
 FREE RECORD timed_readmes
 RECORD timed_readmes(
   1 list_0[*]
     2 readme_id = f8
 )
 DECLARE weightedtablecnt = i4 WITH protect, noconstant(0)
 DECLARE drivertablename = vc WITH protect, noconstant("")
 DECLARE range_increment = i4 WITH protect, noconstant(1)
 DECLARE readmecount = i4 WITH protect, noconstant(0)
 DECLARE timeperbatch = f8 WITH protect, noconstant(0.0)
 DECLARE executiontime = f8 WITH protect, noconstant(0.0)
 IF ((validate(mf_readme_num,- (1))=- (1)))
  DECLARE mf_readme_num = f8 WITH protect, noconstant(readme_data->readme_id)
 ENDIF
 IF (mf_readme_num=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Invalid readme ID; please run readme with a non-zero readme ID"
 ENDIF
 DECLARE setdrivertable(tablename=vc) = i4
 DECLARE fetchandsetdrivertable(readmeid=i4) = i2
 DECLARE addweightedtable(tablename=vc,tableweight=f8) = i4
 DECLARE setrangeincrement(range_inc=i4) = null
 DECLARE settimeperbatch(tpb=f8) = null
 DECLARE calculateruntime(null) = i2
 DECLARE timercleanup(null) = null
 DECLARE addtimedreadme(readme_id=i4) = i2
 DECLARE setreadmetimings(null) = null
 SUBROUTINE setdrivertable(tablename)
  SET drivertablename = cnvtupper(tablename)
  RETURN(addweightedtable(tablename,1.0))
 END ;Subroutine
 SUBROUTINE fetchandsetdrivertable(readmeid)
   SELECT INTO "nl:"
    FROM dm_readme dr
    WHERE dr.readme_id=readmeid
     AND (dr.instance=
    (SELECT
     max(dr2.instance)
     FROM dm_readme dr2
     WHERE dr2.readme_id=dr.readme_id))
    DETAIL
     drivertablename = dr.driver_table
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("No DM_README row found for readme ID ",format(readmeid,"####")
     )
    RETURN(0)
   ENDIF
   IF (drivertablename=" ")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme ",format(readmeid,"####"),
     " has no driver table listed for its latest ","instance on DM_README.")
    RETURN(0)
   ENDIF
   RETURN(setdrivertable(drivertablename))
 END ;Subroutine
 SUBROUTINE addweightedtable(tablename,tableweight)
   SET weightedtablecnt = (weightedtablecnt+ 1)
   SET stat = alterlist(timing_tables->list_0,weightedtablecnt)
   SET timing_tables->list_0[weightedtablecnt].table_name = cnvtupper(tablename)
   SET timing_tables->list_0[weightedtablecnt].table_weight = tableweight
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=cnvtupper(tablename)
    DETAIL
     timing_tables->list_0[weightedtablecnt].row_count = nullcheck(ut.num_rows,0.0,nullind(ut
       .num_rows))
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE setrangeincrement(range_inc)
   SET range_increment = range_inc
 END ;Subroutine
 SUBROUTINE settimeperbatch(tpb)
   SET timeperbatch = tpb
 END ;Subroutine
 SUBROUTINE calculateruntime(null)
   DECLARE calculatedruntime = f8 WITH protect, noconstant(0.0)
   DECLARE weightedrowcount = f8 WITH protect, noconstant(0.0)
   DECLARE lval_idx = i4 WITH protect, noconstant(0)
   DECLARE drivertableidx = i4 WITH protect, noconstant(0)
   IF (readmecount=0)
    SET readme_data->status = "F"
    SET readme_data->message = "No readmes have been specified to be timed."
    RETURN(0)
   ENDIF
   IF (weightedtablecnt=0)
    SET readme_data->status = "F"
    SET readme_data->message = "No weighted tables or driver tables have been set."
    RETURN(0)
   ENDIF
   IF (setreadmetimings(null)=0)
    RETURN(0)
   ENDIF
   SET readme_data->status = "S"
   SET readme_data->message = concat("Successfully calculated runtime estimate of ",trim(format((
      executiontime/ (24.0 * 60.0)),"DD.HH:MM:SS;3;z"),3)," for ",build(readmecount)," readme(s)")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE timercleanup(null)
  FREE RECORD timing_tables
  FREE RECORD timed_readmes
 END ;Subroutine
 SUBROUTINE addtimedreadme(readme_id)
   SET readmecount = (readmecount+ 1)
   SET stat = alterlist(timed_readmes->list_0,readmecount)
   SET timed_readmes->list_0[readmecount].readme_id = readme_id
 END ;Subroutine
 SUBROUTINE setreadmetimings(null)
   DECLARE drivertablerowcnt = i4 WITH protect, noconstant(0)
   DECLARE drivertableidx = i4 WITH protect, noconstant(0)
   DECLARE drrreadmeidx = i4 WITH protect, noconstant(0)
   DECLARE lval_idx = i4 WITH protect, noconstant(0)
   SET drivertableidx = locateval(lval_idx,1,weightedtablecnt,drivertablename,timing_tables->list_0[
    lval_idx].table_name)
   IF (drivertableidx=0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Could not find row count for the driver table ",
     drivertablename," in ","setReadmeTimings()")
    RETURN(0)
   ENDIF
   SET drivertablerowcnt = timing_tables->list_0[drivertableidx].row_count
   IF (drivertablerowcnt=0)
    SET executiontime = 0.01667
   ELSE
    SET executiontime = maxval(((timeperbatch/ readmecount) * ceil((cnvtreal(drivertablerowcnt)/ (
      range_increment * readmecount)))),0.01667)
   ENDIF
   FOR (i = 1 TO readmecount)
    SET drrreadmeidx = locateval(lval_idx,1,drr_readmes_to_run->readme_cnt,timed_readmes->list_0[i].
     readme_id,drr_readmes_to_run->readme[lval_idx].readme_id)
    IF (drrreadmeidx > 0)
     SET drr_readmes_to_run->readme[drrreadmeidx].estimated_time = executiontime
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 IF (fetchandsetdrivertable(3993)=0)
  GO TO exit_script
 ENDIF
 CALL setrangeincrement(250000)
 CALL settimeperbatch(0.191352)
 CALL addtimedreadme(3994)
 CALL addtimedreadme(3995)
 CALL addtimedreadme(3996)
 CALL calculateruntime(null)
#exit_script
 CALL timercleanup(null)
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
