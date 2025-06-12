CREATE PROGRAM ams_pha_iv_sets_driver:dba
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
 SET path = value(logical(trim( $DIRECTORY)))
 SET infile =  $INPUTFILE
 SET file_path = build(path,"/",infile)
 DEFINE rtl2 value(file_path)
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 name_iv_set = vc
     2 short_desc = vc
     2 dispense_catagory = vc
     2 mnemonic = vc
     2 diluent_mnemonic = vc
     2 diluent_code = vc
     2 diluent = vc
     2 diluent_volumn = vc
     2 diluent_unit = vc
     2 addi[*]
       3 additive_mnemonic = vc
       3 additive_code = vc
       3 additive = vc
       3 additive_dose1 = vc
       3 additive_unit1 = vc
       3 additive_dose2 = vc
       3 additive_unit2 = vc
     2 std_conc_hh = vc
     2 max_conc_hh = vc
     2 dose_range = vc
     2 starting_dose = vc
     2 infuse_over = vc
     2 infuse_value = vc
     2 conc = vc
     2 conc_unit = vc
     2 label_comments = vc
     2 comments = vc
     2 mar = vc
     2 label = vc
     2 fill_list = vc
     2 nat_cen_res = vc
     2 build_cpoe = vc
     2 build_pharm = vc
     2 build_prod = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, addi_count = 0, i = 0,
   count = 0, stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line, count = (count+ 1)
   IF (count != 1)
    IF (size(trim(line1),1) > 0)
     IF (piece(line1,",",1,"Not Found") != "")
      addi_count = 1, row_count = (row_count+ 1)
      IF (mod(row_count,10)=0)
       stat = alterlist(file_content->qual,(row_count+ 9))
      ENDIF
      stat = alterlist(file_content->qual[row_count].addi,addi_count),
      CALL echo("Row Count"),
      CALL echo(row_count),
      file_content->qual[row_count].name_iv_set = piece(line1,",",1,"Not Found"), file_content->qual[
      row_count].short_desc = piece(line1,",",2,"Not Found"), file_content->qual[row_count].
      dispense_catagory = piece(line1,",",3,"Not Found"),
      file_content->qual[row_count].mnemonic = piece(line1,",",4,"Not Found"), file_content->qual[
      row_count].diluent_mnemonic = piece(line1,",",5,"Not Found"), file_content->qual[row_count].
      diluent_code = piece(line1,",",6,"Not Found"),
      file_content->qual[row_count].diluent = piece(line1,",",7,"Not Found"), file_content->qual[
      row_count].diluent_volumn = piece(piece(line1,",",8,"Not Found")," ",1,"Not Found"),
      file_content->qual[row_count].diluent_unit = piece(piece(line1,",",8,"Not Found")," ",2,
       "Not Found"),
      file_content->qual[row_count].addi[addi_count].additive_mnemonic = piece(line1,",",9,
       "Not Found"), file_content->qual[row_count].addi[addi_count].additive_code = piece(line1,",",
       10,"Not Found"), file_content->qual[row_count].addi[addi_count].additive = piece(line1,",",11,
       "Not Found"),
      file_content->qual[row_count].addi[addi_count].additive_dose1 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",1," ")," ",1," "), file_content->qual[row_count].addi[addi_count].
      additive_dose2 = piece(piece(piece(line1,",",12,"Not Found"),"/",2," ")," ",1," "),
      file_content->qual[row_count].addi[addi_count].additive_unit1 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",1," ")," ",2," "),
      file_content->qual[row_count].addi[addi_count].additive_unit2 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",2," ")," ",2," "), file_content->qual[row_count].std_conc_hh = piece(line1,
       ",",13,"Not Found"), file_content->qual[row_count].max_conc_hh = piece(line1,",",14,
       "Not Found"),
      file_content->qual[row_count].dose_range = piece(line1,",",15,"Not Found"), file_content->qual[
      row_count].starting_dose = piece(line1,",",16,"Not Found"), file_content->qual[row_count].
      infuse_over = piece(piece(line1,",",17,"Not Found")," ",1,"Not Found"),
      file_content->qual[row_count].infuse_value = piece(piece(line1,",",17,"Not Found")," ",2,
       "Not Found"), file_content->qual[row_count].conc = piece(line1,",",19,"Not Found"),
      file_content->qual[row_count].conc_unit = piece(line1,",",20,"Not Found"),
      file_content->qual[row_count].label_comments = piece(line1,",",21,"Not Found"), file_content->
      qual[row_count].comments = piece(line1,",",22,"Not Found"), file_content->qual[row_count].mar
       = piece(line1,",",23,"Not Found"),
      file_content->qual[row_count].label = piece(line1,",",24,"Not Found"), file_content->qual[
      row_count].fill_list = piece(line1,",",25,"Not Found"), file_content->qual[row_count].
      nat_cen_res = piece(line1,",",26,"Not Found")
     ELSE
      addi_count = (addi_count+ 1), stat = alterlist(file_content->qual[row_count].addi,addi_count),
      file_content->qual[row_count].addi[addi_count].additive_mnemonic = piece(line1,",",9,
       "Not Found"),
      file_content->qual[row_count].addi[addi_count].additive_code = piece(line1,",",10,"Not Found"),
      file_content->qual[row_count].addi[addi_count].additive = piece(line1,",",11,"Not Found"),
      file_content->qual[row_count].addi[addi_count].additive_dose1 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",1," ")," ",1," "),
      file_content->qual[row_count].addi[addi_count].additive_dose2 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",2," ")," ",1," "), file_content->qual[row_count].addi[addi_count].
      additive_unit1 = piece(piece(piece(line1,",",12,"Not Found"),"/",1," ")," ",2," "),
      file_content->qual[row_count].addi[addi_count].additive_unit2 = piece(piece(piece(line1,",",12,
         "Not Found"),"/",2," ")," ",2," ")
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $1
   qual_name_iv_set = substring(1,30,file_content->qual[d1.seq].name_iv_set), qual_short_descrption
    = substring(1,30,file_content->qual[d1.seq].short_desc), qual_dispense_catagory = substring(1,30,
    file_content->qual[d1.seq].dispense_catagory),
   qual_mnemonic = substring(1,30,file_content->qual[d1.seq].mnemonic), qual_diluent_mnemonic =
   substring(1,30,file_content->qual[d1.seq].diluent_mnemonic), qual_diluent_code = substring(1,30,
    file_content->qual[d1.seq].diluent_code),
   qual_diluent = substring(1,30,file_content->qual[d1.seq].diluent), qual_diluent_volumn = substring
   (1,30,file_content->qual[d1.seq].diluent_volumn), addi_additive_mnemonic = substring(1,30,
    file_content->qual[d1.seq].addi[d2.seq].additive_mnemonic),
   addi_additive_code = substring(1,30,file_content->qual[d1.seq].addi[d2.seq].additive_code),
   addi_additive = substring(1,30,file_content->qual[d1.seq].addi[d2.seq].additive),
   addi_additive_dose = substring(1,30,file_content->qual[d1.seq].addi[d2.seq].additive_dose),
   qual_std_conc_hh = substring(1,30,file_content->qual[d1.seq].std_conc_hh), qual_max_conc_hh =
   substring(1,30,file_content->qual[d1.seq].max_conc_hh), qual_dose_range = substring(1,30,
    file_content->qual[d1.seq].dose_range),
   qual_starting_dose = substring(1,30,file_content->qual[d1.seq].starting_dose), qual_infuse_over =
   substring(1,30,file_content->qual[d1.seq].infuse_over), qual_infuse_value = substring(1,30,
    file_content->qual[d1.seq].infuse_value),
   qual_conc = substring(1,30,file_content->qual[d1.seq].conc), qual_conc_unit = substring(1,30,
    file_content->qual[d1.seq].conc_unit), qual_label_comments = substring(1,30,file_content->qual[d1
    .seq].label_comments),
   qual_comments = substring(1,30,file_content->qual[d1.seq].comments), qual_mar = substring(1,30,
    file_content->qual[d1.seq].mar), qual_label = substring(1,30,file_content->qual[d1.seq].label),
   qual_fill_list = substring(1,30,file_content->qual[d1.seq].fill_list), qual_nat_cen_res =
   substring(1,30,file_content->qual[d1.seq].nat_cen_res)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(file_content->qual[d1.seq].addi,5)))
    JOIN (d2)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_pha_iv_sets_add_procedures:dba
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
 SET script_ver = " 000 04/01/16 DS042261  Initial Release "
END GO
