CREATE PROGRAM ams_nomenclature_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = "",
  "Select Audit/Commit" = ""
  WITH outdev, directory, inputfile,
  auditcommit
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
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_appts(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 DECLARE locateroles = c500
 DECLARE sub_content = vc
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 terminology = vc
     2 short_identifier = vc
     2 term = vc
     2 short_string = vc
     2 mnemonic = vc
     2 principle_type = vc
     2 terminology_axis = vc
     2 contributor_system = vc
     2 language = vc
     2 concept_name = vc
     2 concept_cki = vc
     2 primary_display_term = vc
     2 parent_concept = vc
     2 child_concept = vc
     2 beg_date = vc
     2 end_date = vc
     2 active_term = vc
     2 string_identifier = vc
     2 external_source = vc
     2 string_status = vc
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
     file_content->qual[row_count].terminology = piece(line1,",",1,"Not Found"), file_content->qual[
     row_count].short_identifier = piece(line1,",",2,"Not Found"), file_content->qual[row_count].term
      = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].short_string = piece(line1,",",4,"Not Found"), file_content->qual[
     row_count].mnemonic = piece(line1,",",5,"Not Found"), file_content->qual[row_count].
     principle_type = piece(line1,",",6,"Not Found"),
     file_content->qual[row_count].terminology_axis = piece(line1,",",7,"Not Found"), file_content->
     qual[row_count].contributor_system = piece(line1,",",8,"Not Found"), file_content->qual[
     row_count].language = piece(line1,",",9,"Not Found"),
     file_content->qual[row_count].concept_name = piece(line1,",",10,"Not Found"), file_content->
     qual[row_count].concept_cki = piece(line1,",",11,"Not Found"), file_content->qual[row_count].
     primary_display_term = piece(line1,",",12,"Not Found"),
     file_content->qual[row_count].parent_concept = piece(line1,",",13,"Not Found"), file_content->
     qual[row_count].child_concept = piece(line1,",",14,"Not Found"), file_content->qual[row_count].
     beg_date = piece(line1,",",15,"Not Found"),
     file_content->qual[row_count].end_date = piece(line1,",",16,"Not Found"), file_content->qual[
     row_count].active_term = piece(line1,",",17,"Not Found"), file_content->qual[row_count].
     string_identifier = piece(line1,",",18,"Not Found"),
     file_content->qual[row_count].external_source = piece(line1,",",19,"Not Found"), file_content->
     qual[row_count].string_status = piece(line1,",",20,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   terminology = substring(1,30,file_content->qual[d1.seq].terminology), short_identifier = substring
   (1,30,file_content->qual[d1.seq].short_identifier), term = substring(1,30,file_content->qual[d1
    .seq].term),
   short_string = substring(1,30,file_content->qual[d1.seq].short_string), mnemonic = substring(1,30,
    file_content->qual[d1.seq].mnemonic), principle_type = substring(1,30,file_content->qual[d1.seq].
    principle_type),
   terminology_axis = substring(1,30,file_content->qual[d1.seq].terminology_axis), contributor_system
    = substring(1,30,file_content->qual[d1.seq].contributor_system), language = substring(1,30,
    file_content->qual[d1.seq].language),
   concept_name = substring(1,30,file_content->qual[d1.seq].concept_name), concept_cki = substring(1,
    30,file_content->qual[d1.seq].concept_cki), primary_display_term = substring(1,30,file_content->
    qual[d1.seq].primary_display_term),
   parent_concept = substring(1,30,file_content->qual[d1.seq].parent_concept), child_concept =
   substring(1,30,file_content->qual[d1.seq].child_concept), beg_date = substring(1,30,file_content->
    qual[d1.seq].beg_date),
   end_date = substring(1,30,file_content->qual[d1.seq].end_date), active_term = substring(1,30,
    file_content->qual[d1.seq].active_term), string_identifier = substring(1,30,file_content->qual[d1
    .seq].string_identifier),
   external_source = substring(1,30,file_content->qual[d1.seq].external_source)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_add_nomenclature:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
 IF (failed_mess != false)
  SELECT INTO  $OUTDEV
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed_mess != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET script_ver = " 000 05/01/15 SD0303079         Initial Release "
END GO
