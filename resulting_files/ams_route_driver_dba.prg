CREATE PROGRAM ams_route_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = "",
  "Select Audit/Commit" = ""
  WITH outdev, directory, inputfile,
  auditcommit
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
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,"/",infile)
 CALL echo(file_path)
 DEFINE rtl2 value("ccluserdir:input.csv")
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 short_description = vc
     2 long_description = vc
     2 order_type = vc
     2 active_ind = vc
     2 form = vc
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
     file_content->qual[row_count].short_description = piece(line1,",",1,"Not Found"), file_content->
     qual[row_count].long_description = piece(line1,",",2,"Not Found"), file_content->qual[row_count]
     .order_type = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].active_ind = piece(line1,",",4,"Not Found"), file_content->qual[
     row_count].form = piece(line1,",",5,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   qual_short_description = substring(1,30,file_content->qual[d1.seq].short_description),
   qual_long_description = substring(1,30,file_content->qual[d1.seq].long_description),
   qual_order_type = substring(1,30,file_content->qual[d1.seq].order_type),
   qual_active_ind = substring(1,30,file_content->qual[d1.seq].active_ind), qual_form = substring(1,
    30,file_content->qual[d1.seq].form)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_add_route:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
 SET script_ver = " 000 05/15/16 AR043066         Initial Release "
END GO
