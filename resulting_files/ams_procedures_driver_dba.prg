CREATE PROGRAM ams_procedures_driver:dba
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
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 catalog_description = vc
     2 surgical_area = vc
     2 specialty = vc
     2 case_level = vc
     2 wound_class = vc
     2 anesthesia_type = vc
     2 procedure_count = vc
     2 setup_time = vc
     2 pre_incision_time = vc
     2 procedure_duration = vc
     2 post_closure_time = vc
     2 cleanup_time = vc
     2 specimen_required = vc
     2 frozen_section = vc
     2 blood_products = vc
     2 implants = vc
     2 xrays = vc
     2 xray_technician = vc
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
     file_content->qual[row_count].catalog_description = piece(line1,",",1,"Not Found"), file_content
     ->qual[row_count].surgical_area = piece(line1,",",2,"Not Found"), file_content->qual[row_count].
     specialty = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].case_level = piece(line1,",",4,"Not Found"), file_content->qual[
     row_count].wound_class = piece(line1,",",5,"Not Found"), file_content->qual[row_count].
     anesthesia_type = piece(line1,",",6,"Not Found"),
     file_content->qual[row_count].procedure_count = piece(line1,",",7,"Not Found"), file_content->
     qual[row_count].setup_time = piece(line1,",",8,"Not Found"), file_content->qual[row_count].
     pre_incision_time = piece(line1,",",9,"Not Found"),
     file_content->qual[row_count].procedure_duration = piece(line1,",",10,"Not Found"), file_content
     ->qual[row_count].post_closure_time = piece(line1,",",11,"Not Found"), file_content->qual[
     row_count].cleanup_time = piece(line1,",",12,"Not Found"),
     file_content->qual[row_count].specimen_required = piece(line1,",",13,"Not Found"), file_content
     ->qual[row_count].frozen_section = piece(line1,",",14,"Not Found"), file_content->qual[row_count
     ].blood_products = piece(line1,",",15,"Not Found"),
     file_content->qual[row_count].implants = piece(line1,",",16,"Not Found"), file_content->qual[
     row_count].xrays = piece(line1,",",17,"Not Found"), file_content->qual[row_count].
     xray_technician = piece(line1,",",18,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   qual_catalog_description = substring(1,30,file_content->qual[d1.seq].catalog_description),
   qual_surgical_area = substring(1,30,file_content->qual[d1.seq].surgical_area), qual_specialty =
   substring(1,30,file_content->qual[d1.seq].specialty),
   qual_case_level = substring(1,30,file_content->qual[d1.seq].case_level), qual_wound_class =
   substring(1,30,file_content->qual[d1.seq].wound_class), qual_anesthesia_type = substring(1,30,
    file_content->qual[d1.seq].anesthesia_type),
   qual_procedure_count = substring(1,30,file_content->qual[d1.seq].procedure_count), qual_setup_time
    = substring(1,30,file_content->qual[d1.seq].setup_time), qual_pre_incision_time = substring(1,30,
    file_content->qual[d1.seq].pre_incision_time),
   qual_procedure_duration = substring(1,30,file_content->qual[d1.seq].procedure_duration),
   qual_post_closure_time = substring(1,30,file_content->qual[d1.seq].post_closure_time),
   qual_cleanup_time = substring(1,30,file_content->qual[d1.seq].cleanup_time),
   qual_specimen_required = substring(1,30,file_content->qual[d1.seq].specimen_required),
   qual_frozen_section = substring(1,30,file_content->qual[d1.seq].frozen_section),
   qual_blood_products = substring(1,30,file_content->qual[d1.seq].blood_products),
   qual_implants = substring(1,30,file_content->qual[d1.seq].implants), qual_xrays = substring(1,30,
    file_content->qual[d1.seq].xrays), qual_xray_technician = substring(1,30,file_content->qual[d1
    .seq].xray_technician)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_add_procedures:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
 SET script_ver = " 000 05/01/15 SD0303079         Initial Release "
END GO
