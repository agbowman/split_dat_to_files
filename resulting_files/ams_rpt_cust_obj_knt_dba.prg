CREATE PROGRAM ams_rpt_cust_obj_knt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dp.object_name, dp.user_name, compiled_dt_tm = format(cnvtdatetime(dp.datestamp,dp.timestamp),
   "mm/dd/yyyy hh:mm:ss;;q"),
  dp.source_name
  FROM dprotect dp
  PLAN (dp
   WHERE dp.object="P"
    AND dp.group=0
    AND ((dp.user_name != "D_*") OR (dp.user_name="D_MAE*"
    AND dp.object_name != "BR_*")) )
  ORDER BY dp.object_name
  HEAD REPORT
   knt = 0, stat = alterlist(rdata->qual,1000)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(rdata->qual,(knt+ 999))
   ENDIF
   rdata->qual[knt].object_name = dp.object_name, rdata->qual[knt].user_name = dp.user_name, rdata->
   qual[knt].compiled_dt_tm = format(cnvtdatetime(dp.datestamp,dp.timestamp),"mm/dd/yyyy hh:mm:ss;;q"
    ),
   rdata->qual[knt].source_name = dp.source_name
  FOOT REPORT
   rdata->qual_knt = knt, stat = alterlist(rdata->qual,knt)
  WITH nocounter, time = 120
 ;end select
 IF ((rdata->qual_knt < 1))
  SET failed = exe_error
  SET serrmsg = "No Custom Code Found"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build2("***   qual_knt: ",rdata->qual_knt))
 CALL echo(build2('***   findstring(".",trim($OUTDEV,3)): ',findstring(".",trim( $OUTDEV,3))))
 CALL echo("***")
 IF (findstring(".",trim( $OUTDEV,3)) > 0)
  SELECT INTO value( $OUTDEV)
   object_name = trim(substring(1,100,rdata->qual[d.seq].object_name),3), user_name = trim(substring(
     1,100,rdata->qual[d.seq].user_name),3), compiled_dt_tm = trim(substring(1,100,rdata->qual[d.seq]
     .compiled_dt_tm),3),
   source_name = trim(substring(1,100,rdata->qual[d.seq].source_name),3)
   FROM (dummyt d  WITH seq = value(rdata->qual_knt))
   WITH nocounter, heading, pcformat('"',",",1),
    format = stream, maxcol = 1000
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   object_name = trim(substring(1,100,rdata->qual[d.seq].object_name),3), user_name = trim(substring(
     1,100,rdata->qual[d.seq].user_name),3), compiled_dt_tm = trim(substring(1,100,rdata->qual[d.seq]
     .compiled_dt_tm),3),
   source_name = trim(substring(1,100,rdata->qual[d.seq].source_name),3)
   FROM (dummyt d  WITH seq = value(rdata->qual_knt))
   WITH nocounter, heading, format,
    separator = " "
  ;end select
 ENDIF
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  WITH nocounter, format, separator = " "
 ;end select
 SET script_ver = "000 09/12/12 Initial Release"
END GO
