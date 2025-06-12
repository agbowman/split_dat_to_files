CREATE PROGRAM careset_dbtool
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter File Name" = "",
  "Path" = ""
  WITH outdev, file, path
 SET path = value(logical(trim( $PATH)))
 SET file =  $FILE
 SET file_name = build(path,"/",file)
 DEFINE rtl2 value(file_name)
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 FREE RECORD orig_content
 RECORD orig_content(
   1 qual[*]
     2 location = vc
     2 base_loc = vc
     2 upd_bed_status = vc
     2 active_ind = vc
     2 time_overdue = vc
     2 time_critical = vc
 )
 FREE RECORD request
 RECORD request(
   1 qual[*]
     2 tlplocation = f8
     2 tlpreason_def_cd = f8
     2 tlpreason_reqd_ind = i2
     2 tlpactiveind = i2
     2 tlpocolor = vc
     2 tlpoicon = i4
     2 tlpointerval = i4
     2 tlpccolor = vc
     2 tlpcicon = i4
     2 tlpcinterval = i4
     2 tlpncolor = vc
     2 tlpbaseind = i2
     2 tlpupdbedstatus = i2
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(orig_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(orig_content->qual,(row_count+ 9))
     ENDIF
     orig_content->qual[row_count].location = piece(line1,",",1,"Not Found"), orig_content->qual[
     row_count].base_loc = piece(line1,",",2,"Not Found"), orig_content->qual[row_count].
     upd_bed_status = piece(line1,",",3,"Not Found"),
     orig_content->qual[row_count].active_ind = piece(line1,",",4,"Not Found"), orig_content->qual[
     row_count].time_overdue = piece(line1,",",5,"Not Found"), orig_content->qual[row_count].
     time_critical = piece(line1,",",6,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 CALL echorecord(orig_content)
 SET rcnt = 0
 FOR (i = 1 TO value(size(orig_content->qual,5)))
   SET stat = alterlist(request->qual,i)
   SELECT
    cv.display, cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND trim(cv.display)=trim(orig_content->qual[i].location)
    HEAD cv.code_value
     request->qual[i].tlplocation = cv.code_value
    WITH nocounter
   ;end select
   IF ((orig_content->qual[i].base_loc="yes"))
    SET request->qual[i].tlpbaseind = 1
   ELSE
    SET request->qual[i].tlpbaseind = 0
   ENDIF
   IF ((orig_content->qual[i].upd_bed_status="yes"))
    SET request->qual[i].tlpupdbedstatus = 1
   ELSE
    SET request->qual[i].tlpupdbedstatus = 0
   ENDIF
   IF ((orig_content->qual[i].active_ind="yes"))
    SET request->qual[i].tlpactiveind = 1
   ELSE
    SET request->qual[i].tlpactiveind = 0
   ENDIF
   SET hour = cnvtint(piece(orig_content->qual[i].time_overdue,":",1,"Not Found"))
   CALL echo("anoopoverdue")
   CALL echo(hour)
   SET min = cnvtint(piece(orig_content->qual[i].time_overdue,":",2,"Not Found"))
   CALL echo(min)
   SET sec = cnvtint(piece(orig_content->qual[i].time_overdue,":",3,"Not Found"))
   CALL echo(sec)
   SET request->qual[i].tlpointerval = (((hour * 3600)+ (min * 60))+ sec)
   SET hour1 = cnvtint(piece(orig_content->qual[i].time_critical,":",1,"Not Found"))
   CALL echo("anoopcritical")
   CALL echo(hour1)
   SET min1 = cnvtint(piece(orig_content->qual[i].time_critical,":",2,"Not Found"))
   CALL echo(min1)
   SET sec1 = cnvtint(piece(orig_content->qual[i].time_critical,":",3,"Not Found"))
   CALL echo(sec1)
   SET request->qual[i].tlpcinterval = (((hour1 * 3600)+ (min1 * 60))+ sec1)
   SET request->qual[i].tlpreason_def_cd = 0.000000
   SET request->qual[i].tlpreason_reqd_ind = 0
   SET request->qual[i].tlpocolor = ""
   SET request->qual[i].tlpoicon = 0
   SET request->qual[i].tlpccolor = ""
   SET request->qual[i].tlpcicon = 0
   SET request->qual[i].tlpncolor = ""
 ENDFOR
 CALL echorecord(request)
 EXECUTE fn_insupd_trklocparam:dba  WITH replace("REQUEST",request)
#exit_script
END GO
