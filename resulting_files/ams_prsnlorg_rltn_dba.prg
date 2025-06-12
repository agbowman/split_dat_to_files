CREATE PROGRAM ams_prsnlorg_rltn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter File Name" = "",
  "Path" = ""
  WITH outdev, file, path
 FREE RECORD request
 RECORD request(
   1 organization_id = f8
   1 qual[*]
     2 person_id = f8
     2 confid_level_cd = f8
 )
 FREE RECORD orig_content
 RECORD orig_content(
   1 qual[*]
     2 org_id = f8
     2 username = vc
 )
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
 DECLARE rcnt = i4
 DECLARE teststr = vc
 DECLARE conf_cd = f8
 DECLARE cnt = i4
 SET cnt = 0
 SET path = value(logical(trim( $PATH)))
 SET file =  $FILE
 SET file_name = build(path,"/",file)
 CALL echo(file_name)
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
     orig_content->qual[row_count].org_id = cnvtint(piece(line1,",",1,"Not Found")), orig_content->
     qual[row_count].username = piece(line1,",",2,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 CALL echo("original")
 CALL echorecord(orig_content)
 CALL echo(value(size(orig_content->qual,5)))
 SET rcnt = 0
 FOR (i = 1 TO value(size(orig_content->qual,5)))
   CALL echo("username")
   CALL echo(cnvtupper(orig_content->qual[i].username))
   SELECT
    pr.person_id
    FROM prsnl pr
    WHERE cnvtupper(pr.username)=cnvtupper(orig_content->qual[i].username)
    HEAD pr.person_id
     rcnt = (rcnt+ 1), stat = alterlist(request->qual,rcnt), request->organization_id = orig_content
     ->qual[i].org_id,
     request->qual[rcnt].person_id = pr.person_id, request->qual[rcnt].confid_level_cd = 0.00
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(request)
 SELECT INTO  $OUTDEV
  org_id = request->organization_id, per_id = request->qual[d.seq].person_id, conf_level_cd = request
  ->qual[d.seq].confid_level_cd
  FROM (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
  WITH format, nocounter
 ;end select
 EXECUTE uzr_add_prsnl_to_org:dba  WITH replace("REQUEST",request)
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
 SET last_mod = "001 07/28/2015 KP035208  Initial Release"
END GO
