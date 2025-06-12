CREATE PROGRAM ams_add_oef_fields:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 DECLARE order_var = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
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
 SET vfailed = false
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
  SET vfailed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD format_fields
 RECORD format_fields(
   1 formats[*]
     2 format_name = vc
     2 fields[*]
       3 field_desc = vc
       3 label_name = vc
       3 acceptance = vc
       3 status_line = vc
       3 default_value = vc
       3 nurse_review = i2
       3 doctor_cosign = i2
       3 phar_verify = i2
       3 clin_disp_line = i2
       3 dept_disp_line = i2
 )
 FREE RECORD orig_data
 RECORD orig_data(
   1 qual[*]
     2 format_name = vc
     2 field_desc = vc
     2 label_name = vc
     2 acceptance = vc
     2 status_line = vc
     2 default_value = vc
     2 nurse_review = i2
     2 doctor_cosign = i2
     2 phar_verify = i2
     2 clin_disp_line = i2
     2 dept_disp_line = i2
 )
 DECLARE cnt = i4
 DECLARE lbcnt = i4
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0
  HEAD r.line
   line1 = r.line
   IF (row_count > 0)
    stat = alterlist(orig_data->qual,row_count), orig_data->qual[row_count].format_name = piece(r
     .line,",",1,"not found"), orig_data->qual[row_count].field_desc = piece(r.line,",",2,"not found"
     ),
    orig_data->qual[row_count].label_name = piece(r.line,",",3,"not found"), orig_data->qual[
    row_count].acceptance = piece(r.line,",",4,"not found"), orig_data->qual[row_count].status_line
     = piece(r.line,",",5,"not found"),
    orig_data->qual[row_count].default_value = piece(r.line,",",6,"not found"), orig_data->qual[
    row_count].nurse_review = cnvtint(piece(r.line,",",7,"not found")), orig_data->qual[row_count].
    doctor_cosign = cnvtint(piece(r.line,",",8,"not found")),
    orig_data->qual[row_count].phar_verify = cnvtint(piece(r.line,",",9,"not found")), orig_data->
    qual[row_count].clin_disp_line = cnvtint(piece(r.line,",",10,"not found")), orig_data->qual[
    row_count].dept_disp_line = cnvtint(piece(r.line,",",11,"not found"))
   ENDIF
   row_count = (row_count+ 1)
  WITH nocounter
 ;end select
 SET cnt = 0
 CALL echo(size(orig_data->qual,5))
 FOR (i = 1 TO size(orig_data->qual,5))
   IF (trim(orig_data->qual[i].format_name) != "")
    SET cnt = (cnt+ 1)
    SET lbcnt = 0
    SET stat = alterlist(format_fields->formats,cnt)
    SET format_fields->formats[cnt].format_name = orig_data->qual[i].format_name
   ENDIF
   SET lbcnt = (lbcnt+ 1)
   SET stat = alterlist(format_fields->formats[cnt].fields,lbcnt)
   SET format_fields->formats[cnt].fields[lbcnt].field_desc = orig_data->qual[i].field_desc
   SET format_fields->formats[cnt].fields[lbcnt].label_name = orig_data->qual[i].label_name
   SET format_fields->formats[cnt].fields[lbcnt].acceptance = orig_data->qual[i].acceptance
   SET format_fields->formats[cnt].fields[lbcnt].status_line = orig_data->qual[i].status_line
   SET format_fields->formats[cnt].fields[lbcnt].default_value = orig_data->qual[i].default_value
   SET format_fields->formats[cnt].fields[lbcnt].nurse_review = orig_data->qual[i].nurse_review
   SET format_fields->formats[cnt].fields[lbcnt].doctor_cosign = orig_data->qual[i].doctor_cosign
   SET format_fields->formats[cnt].fields[lbcnt].phar_verify = orig_data->qual[i].phar_verify
   SET format_fields->formats[cnt].fields[lbcnt].clin_disp_line = orig_data->qual[i].clin_disp_line
   SET format_fields->formats[cnt].fields[lbcnt].dept_disp_line = orig_data->qual[i].dept_disp_line
 ENDFOR
 CALL echorecord(format_fields)
 FREE RECORD add_fields
 RECORD add_fields(
   1 qual[*]
     2 format_name = c200
     2 field_qual[*]
       3 field_name = c200
       3 added = i2
 )
 DECLARE format_idex = i4
 DECLARE field_idex = i4
 DECLARE found = i2
 SET format_idex = 0
 SET field_idex = 0
 FOR (format_idex = 1 TO value(size(format_fields->formats,5)))
   SET found = 0
   SET stat = alterlist(add_fields->qual,format_idex)
   FOR (field_idex = 1 TO value(size(format_fields->formats[format_idex].fields,5)))
    SET stat = alterlist(add_fields->qual[format_idex].field_qual,field_idex)
    SELECT
     found_cnt = count(off.oe_field_id)
     FROM oe_format_fields off
     WHERE off.oe_format_id IN (
     (SELECT
      oef.oe_format_id
      FROM order_entry_format oef
      WHERE (oef.oe_format_name=format_fields->formats[format_idex].format_name)))
      AND off.oe_field_id IN (
     (SELECT
      oef.oe_field_id
      FROM order_entry_fields oef
      WHERE (oef.description=format_fields->formats[format_idex].fields[field_idex].field_desc)))
     DETAIL
      found = cnvtint(found_cnt),
      CALL echo("found"),
      CALL echo(found)
      IF (found > 0)
       CALL echo("inside if"), add_fields->qual[format_idex].format_name = format_fields->formats[
       format_idex].format_name, add_fields->qual[format_idex].field_qual[field_idex].field_name =
       format_fields->formats[format_idex].fields[field_idex].field_desc,
       add_fields->qual[format_idex].field_qual[field_idex].added = 0
      ELSE
       add_fields->qual[format_idex].field_qual[field_idex].added = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
 ENDFOR
 SET x = size(format_fields->formats,5)
 SET init_cnt = 0
 FOR (init_cnt = 1 TO value(size(format_fields->formats,5)))
   FREE SET request_new
   RECORD request_new(
     1 oe_format_id = f8
     1 oe_field_id = f8
     1 action_type_cd = f8
     1 accept_flag = i2
     1 default_value = vc
     1 input_mask = vc
     1 require_cosign_ind = i2
     1 prolog_method = f8
     1 epilog_method = f8
     1 status_line = vc
     1 label_text = vc
     1 group_seq = i4
     1 field_seq = i4
     1 max_nbr_occur = i4
     1 value_required_ind = i2
     1 core_ind = i2
     1 clin_line_ind = i2
     1 clin_line_label = c25
     1 clin_suffix_ind = i2
     1 disp_yes_no_flag = i2
     1 dept_line_ind = i2
     1 dept_line_label = c25
     1 dept_suffix_ind = i2
     1 disp_dept_yes_no_flag = i2
     1 def_prev_order_ind = i2
     1 filter_params = c255
     1 require_cosign_ind = i2
     1 require_verify_ind = i2
     1 require_review_ind = i2
     1 lock_on_modify_flag = i2
     1 carry_fwd_plan_ind = i2
   )
   SET reqinfo->updt_id = reqinfo->updt_id
   SET reqinfo->updt_task = 0
   SELECT INTO "nl:"
    FROM order_entry_format oef
    PLAN (oef
     WHERE (oef.oe_format_name=format_fields->formats[init_cnt].format_name))
    HEAD oef.oe_format_id
     request_new->oe_format_id = oef.oe_format_id
    WITH nocounter
   ;end select
   FOR (sub_cnt = 1 TO size(format_fields->formats[init_cnt].fields,5))
     SELECT INTO "nl:"
      FROM order_entry_fields oef
      PLAN (oef
       WHERE (oef.description=format_fields->formats[init_cnt].fields[sub_cnt].field_desc))
      HEAD oef.oe_field_id
       request_new->oe_field_id = oef.oe_field_id
      WITH nocounter
     ;end select
     SET request_new->action_type_cd = order_var
     IF (cnvtupper(format_fields->formats[init_cnt].fields[sub_cnt].acceptance)="REQUIRED")
      SET request_new->accept_flag = 0
     ELSEIF (cnvtupper(format_fields->formats[init_cnt].fields[sub_cnt].acceptance)="OPTIONAL")
      SET request_new->accept_flag = 1
     ELSEIF (cnvtupper(format_fields->formats[init_cnt].fields[sub_cnt].acceptance)="NO DISPLAY")
      SET request_new->accept_flag = 2
     ELSEIF (cnvtupper(format_fields->formats[init_cnt].fields[sub_cnt].acceptance)="DISPLAY ONLY")
      SET request_new->accept_flag = 3
     ENDIF
     SET request_new->default_value = format_fields->formats[init_cnt].fields[sub_cnt].default_value
     SET request_new->input_mask = " "
     SET request_new->require_cosign_ind = 0
     SET request_new->prolog_method = 0.0
     SET request_new->epilog_method = 0.0
     SET request_new->status_line = format_fields->formats[init_cnt].fields[sub_cnt].status_line
     SET request_new->label_text = format_fields->formats[init_cnt].fields[sub_cnt].label_name
     SELECT INTO "nl:"
      seq = max(off.group_seq)
      FROM oe_format_fields off
      WHERE off.oe_format_id IN (
      (SELECT
       oef.oe_format_id
       FROM order_entry_format oef
       WHERE (oef.oe_format_name=format_fields->formats[init_cnt].format_name)))
      ORDER BY off.group_seq DESC
      HEAD seq
       request_new->group_seq = (seq+ 1)
      WITH nocounter
     ;end select
     SET request_new->field_seq = 0
     SET request_new->max_nbr_occur = 1
     SET request_new->value_required_ind = 0
     SET request_new->core_ind = 1
     SET request_new->require_verify_ind = format_fields->formats[init_cnt].fields[sub_cnt].
     nurse_review
     SET request_new->require_cosign_ind = format_fields->formats[init_cnt].fields[sub_cnt].
     doctor_cosign
     SET request_new->require_verify_ind = format_fields->formats[init_cnt].fields[sub_cnt].
     phar_verify
     SET request_new->clin_line_ind = format_fields->formats[init_cnt].fields[sub_cnt].clin_disp_line
     SET request_new->clin_line_label = " "
     SET request_new->dept_line_ind = format_fields->formats[init_cnt].fields[sub_cnt].dept_disp_line
     SET request_new->dept_line_label = " "
     CALL echorecord(request_new)
     EXECUTE orm_add_fmtflds:dba  WITH replace("REQUEST",request_new), replace("REPLY",reply)
   ENDFOR
 ENDFOR
 SELECT INTO  $1
  qual_format_name = add_fields->qual[d1.seq].format_name, qual_field_name = add_fields->qual[d1.seq]
  .field_qual[d2.seq].field_name, qual_added = add_fields->qual[d1.seq].field_qual[d2.seq].added
  FROM (dummyt d1  WITH seq = value(size(add_fields->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(add_fields->qual[d1.seq].field_qual,5)))
   JOIN (d2)
  ORDER BY qual_format_name
  HEAD REPORT
   row + 0
  HEAD qual_added
   cnt = 0
   IF (qual_added=0)
    col 10, "Following fields were NOT added to respected formats", row + 1
   ENDIF
  DETAIL
   IF (qual_added=0)
    chk = 0, cnt = (cnt+ 1)
    IF (chk=0)
     col 15, "FORMAT NAME", col 30,
     "FIELD NAME", row + 1, chk = (chk+ 1)
    ENDIF
    col 15, qual_format_name, col 30,
    qual_field_name, row + 1
   ENDIF
  FOOT  qual_added
   row + 1
   IF (qual_added=0)
    col 10, "Total number of formats NOT updated :", col 50,
    cnt, row + 1, col 10,
    "Fileds might already be associated with the given format or given field name is not there in the Database",
    row + 2
   ENDIF
  FOOT REPORT
   IF (cnt > 0
    AND cnt < value(size(add_fields->qual,5)))
    col 10, "some of the given fields are updated", row + 1
   ELSEIF (cnt > 0)
    col 10, "All of the given fields are updated", row + 1
   ENDIF
  WITH nocounter, separator = " ", format,
   maxcol = 300
 ;end select
#exit_script
 IF (vfailed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (vfailed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
