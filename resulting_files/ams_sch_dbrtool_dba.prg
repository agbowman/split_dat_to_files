CREATE PROGRAM ams_sch_dbrtool:dba
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
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD orig_content
 RECORD orig_content(
   1 qual[*]
     2 mnemonic = vc
     2 description = vc
     2 comments = vc
     2 booking_limit = vc
     2 type = vc
     2 username = vc
     2 flagtype = vc
 )
 FREE RECORD request
 RECORD request(
   1 call_echo_ind = i2
   1 allow_partial_ind = i2
   1 qual[*]
     2 res_type_flag = i2
     2 mnemonic = vc
     2 description = vc
     2 quota = i4
     2 info_sch_text_id = f8
     2 person_id = f8
     2 service_resource_cd = f8
     2 candidate_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 item_id = f8
     2 item_location_cd = f8
     2 info_sch_text = vc
     2 loc_partial_ind = i2
     2 loc[*]
       3 location_cd = f8
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
     2 date_link_r_partial_ind = i2
     2 date_link_r[*]
       3 sch_date_link_r_id = f8
       3 sch_date_set_id = f8
       3 date_set_seq_nbr = i4
       3 active_ind = i2
     2 organization_qual_cnt = i4
     2 organization[*]
       3 organization_id = f8
       3 action = i2
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
     orig_content->qual[row_count].mnemonic = piece(line1,",",1,"Not Found"), orig_content->qual[
     row_count].description = piece(line1,",",2,"Not Found"), orig_content->qual[row_count].comments
      = piece(line1,",",3,"Not Found"),
     orig_content->qual[row_count].booking_limit = piece(line1,",",4,"Not Found"), orig_content->
     qual[row_count].type = piece(line1,",",5,"Not Found"), orig_content->qual[row_count].username =
     piece(line1,",",6,"Not Found"),
     orig_content->qual[row_count].flagtype = piece(line1,",",7,"Not Found")
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
   SET request->qual[i].mnemonic = orig_content->qual[i].mnemonic
   SET request->qual[i].description = orig_content->qual[i].description
   SET request->qual[i].info_sch_text = orig_content->qual[i].comments
   SET request->qual[i].quota = cnvtint(orig_content->qual[i].booking_limit)
   SET request->qual[i].res_type_flag = cnvtint(orig_content->qual[i].flagtype)
   SET request->call_echo_ind = 0
   SET request->allow_partial_ind = 0
   SET request->qual[i].info_sch_text_id = 0.00
   SET request->qual[i].candidate_id = 0.00
   SET request->qual[i].active_ind = 1
   SET request->qual[i].active_status_cd = 0.00
   SET request->qual[i].item_id = 0.00
   SET request->qual[i].item_location_cd = 0.00
   SET request->qual[i].loc_partial_ind = 0
   SET request->qual[i].date_link_r_partial_ind = 0
   SET request->qual[i].organization_qual_cnt = 0
   IF (cnvtint(orig_content->qual[i].flagtype)=1)
    SET request->qual[i].res_type_flag = 1
    SET request->qual[i].person_id = 0.00
   ENDIF
   IF (cnvtint(orig_content->qual[i].flagtype)=2)
    SET request->qual[i].res_type_flag = 2
    CALL echo("anoop")
    CALL echo(orig_content->qual[i].type)
    SELECT
     pr.person_id
     FROM prsnl pr
     WHERE trim(pr.username)=trim(orig_content->qual[i].username)
     HEAD pr.person_id
      CALL echo(pr.person_id), request->qual[i].person_id = pr.person_id
     WITH nocounter
    ;end select
   ENDIF
   IF (cnvtint(orig_content->qual[i].flagtype)=3)
    SET request->qual[i].res_type_flag = 3
    SELECT
     cv.display, cv.code_value
     FROM code_value cv
     WHERE cv.code_set=221
      AND trim(cv.display)=trim(orig_content->qual[i].type)
     HEAD cv.display
      request->qual[i].service_resource_cd = cv.code_value
     WITH nocounter
    ;end select
    SET request->qual[i].person_id = 0.00
   ENDIF
 ENDFOR
 CALL echorecord(request)
 SELECT INTO  $OUTDEV
  mnemonic = request->qual[d.seq].mnemonic, description = request->qual[d.seq].description, comments
   = request->qual[d.seq].info_sch_text
  FROM (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
  WITH format, nocounter
 ;end select
 EXECUTE sch_addw_resource:dba  WITH replace("REQUEST",request)
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
 SET last_mode = "000 AN035214 07//02/2015 Initial Release"
END GO
