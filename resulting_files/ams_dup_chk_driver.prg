CREATE PROGRAM ams_dup_chk_driver
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = "",
  "Add / Modify Duplicate Check" = 0
  WITH outdev, directory, inputfile,
  add_mod
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
 SET failed_mess = false
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
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_appts(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 DECLARE locateroles = c500
 DECLARE sub_content = vc
 CALL echo("Entering")
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,"/",infile)
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 order_name = vc
     2 dup_check_seq = i4
     2 active = vc
     2 behind_action = vc
     2 behind_min = vc
     2 ahead_action = vc
     2 ahead_min = vc
     2 exact_action = vc
     2 output_behind_action = vc
     2 output_behind_min = vc
     2 output_ahead_action = vc
     2 output_ahead_min = vc
     2 output_exact_action = vc
     2 output_flex_indicator = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(file_content->qual,(row_count+ 9))
     ENDIF
     file_content->qual[row_count].order_name = piece(line1,",",1,"Not Found"), file_content->qual[
     row_count].dup_check_seq = cnvtint(piece(line1,",",2,"Not Found")), file_content->qual[row_count
     ].active = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].behind_action = piece(line1,",",4,"Not Found"), file_content->
     qual[row_count].behind_min = piece(line1,",",5,"Not Found"), file_content->qual[row_count].
     ahead_action = piece(line1,",",6,"Not Found"),
     file_content->qual[row_count].ahead_min = piece(line1,",",7,"Not Found"), file_content->qual[
     row_count].exact_action = piece(line1,",",8,"Not Found"), file_content->qual[row_count].
     output_behind_action = piece(line1,",",9,"Not Found"),
     file_content->qual[row_count].output_behind_min = piece(line1,",",10,"Not Found"), file_content
     ->qual[row_count].output_ahead_action = piece(line1,",",11,"Not Found"), file_content->qual[
     row_count].output_ahead_min = piece(line1,",",12,"Not Found"),
     file_content->qual[row_count].output_exact_action = piece(line1,",",13,"Not Found"),
     file_content->qual[row_count].output_flex_indicator = piece(line1,",",14,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 CALL echo("File content is")
 CALL echorecord(file_content)
 CALL echo("enetering ams add preferences")
 IF (( $ADD_MOD=1))
  EXECUTE ams_add_dup_check:group01
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ELSE
  EXECUTE ams_upd_dup_check:group01
  SET failed_mess = true
  SET serrmsg = "Successfully Modified"
 ENDIF
#exit_script
 SET script_ver = " 000 05/01/15 SS034541         Initial Release "
END GO
