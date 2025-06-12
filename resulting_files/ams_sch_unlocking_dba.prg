CREATE PROGRAM ams_sch_unlocking:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter File Name" = "",
  "Path" = ""
  WITH outdev, file, path
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
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD request
 RECORD request(
   1 call_echo_ind = i2
   1 qual[*]
     2 sch_lock_id = f8
     2 updt_cnt = i4
     2 allow_partial_ind = i2
     2 force_updt_ind = i2
 )
 FREE RECORD orig_content
 RECORD orig_content(
   1 qual[*]
     2 f_name = vc
     2 l_name = vc
 )
 SET file_name = build( $PATH,":", $FILE)
 DEFINE rtl2 value(file_name)
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
     orig_content->qual[row_count].f_name = piece(line1,",",1,"Not Found"), orig_content->qual[
     row_count].l_name = piece(line1,",",2,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 CALL echorecord(orig_content)
 SET rcnt = 0
 FOR (i = 1 TO size(orig_content->qual,5))
   SELECT
    p.person_id, sl.sch_lock_id
    FROM prsnl p,
     sch_lock sl
    WHERE trim(cnvtupper(p.name_first_key),3)=trim(cnvtupper(orig_content->qual[i].f_name),3)
     AND trim(cnvtupper(p.name_last_key),3)=trim(cnvtupper(orig_content->qual[i].l_name),3)
     AND sl.granted_prsnl_id=p.person_id
    ORDER BY p.person_id
    HEAD p.person_id
     null
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(request->qual,rcnt), request->call_echo_ind = 1,
     request->qual[rcnt].sch_lock_id = sl.sch_lock_id, request->qual[rcnt].updt_cnt = 0, request->
     qual[rcnt].allow_partial_ind = 1,
     request->qual[rcnt].force_updt_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO  $1
  unlocked_id = request->qual[d1.seq].sch_lock_id
  FROM (dummyt d1  WITH seq = value(size(request->qual,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(request)
 EXECUTE sch_del_lock:dba  WITH replace("REQUEST",request)
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "000 03/28/2016 MD035288  Initial Release"
END GO
