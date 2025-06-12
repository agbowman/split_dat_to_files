CREATE PROGRAM dm_dbimport:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ((validate(dm_dbi_parent_commit_ind,- (999))=- (999)))
  DECLARE dm_dbi_parent_commit_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dm_dbi_load_script,"None")="None")
  DECLARE dm_dbi_load_script = c40 WITH public
 ENDIF
 IF ((validate(dm_dbi_blocks,- (999))=- (999)))
  DECLARE dm_dbi_blocks = i4 WITH public, noconstant(1)
 ELSE
  SET dm_dbi_blocks = 1
 ENDIF
 IF (validate(dm_dbi_file_loc,"None")="None")
  DECLARE dm_dbi_file_loc = c100 WITH public
 ENDIF
 IF ((validate(dm_dbi_stat,- (999))=- (999)))
  DECLARE dm_dbi_stat = i4 WITH public, noconstant(1)
 ENDIF
 IF ((validate(dm_dbi_csv_rows,- (999))=- (999)))
  DECLARE dm_dbi_csv_rows = i4 WITH public, noconstant(0)
 ELSE
  SET dm_dbi_csv_rows = 0
 ENDIF
 IF ((validate(dm_dbi_start_row,- (999))=- (999)))
  DECLARE dm_dbi_start_row = i4 WITH public, noconstant(1)
 ELSE
  SET dm_dbi_start_row = 1
 ENDIF
 IF ((validate(dm_dbi_end_row,- (999))=- (999)))
  DECLARE dm_dbi_end_row = i4 WITH public, noconstant(1)
 ELSE
  SET dm_dbi_end_row = 1
 ENDIF
 IF (validate(dm_unique_logical,"None")="None")
  DECLARE dm_unique_logical = c30 WITH public
 ENDIF
 IF ((validate(dm_dbi_rtl3_ind,- (999))=- (999)))
  DECLARE dm_dbi_rtl3_ind = i2 WITH public, noconstant(0)
 ELSE
  SET dm_dbi_rtl3_ind = 0
 ENDIF
 SET dm_dbi_load_script = " "
 SET dm_dbi_file_loc = " "
 IF ((readme_data->readme_id > 0))
  SET dm_unique_logical = concat("dm_logical",trim(cnvtstring(readme_data->readme_id),3))
 ELSE
  SET dm_unique_logical = "dm_unique_logical"
 ENDIF
 SET dm_dbi_file_loc =  $1
 SET dm_dbi_load_script = cnvtupper( $2)
 SET dm_dbi_blocks =  $3
 IF (dm_dbi_blocks=0)
  SET dm_dbi_blocks = 500
 ENDIF
 CALL parser(concat("set logical ",trim(value(dm_unique_logical),3),' "',trim(dm_dbi_file_loc,3),
   '" go'))
 SET readme_data->status = "F"
 SET dm_dbi_stat = findfile(dm_dbi_file_loc)
 IF (dm_dbi_stat=0)
  CALL echo("*****************************************")
  CALL echo("********    Program failed     **********")
  CALL echo("**** CSV file could not be found ********")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "CSV File cound not be found."
  GO TO exit_script
 ENDIF
 CALL parser('select into "NL:"')
 CALL parser('from dprotect d where d.object = "P" and d.group = 0 and d.object_name =')
 CALL parser(build('"',dm_dbi_load_script,'"'))
 CALL parser("with nocounter go")
 IF (curqual=0)
  CALL echo("*****************************************")
  CALL echo("********    Program failed     **********")
  CALL echo("** Load program could not be found ******")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "Load program cound not be found."
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 value(dm_unique_logical)
 SELECT INTO "NL:"
  FROM rtl2t t
  DETAIL
   dm_dbi_csv_rows = (dm_dbi_csv_rows+ 1)
   IF (textlen(trim(t.line,3)) > 1999)
    dm_dbi_rtl3_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (dm_dbi_rtl3_ind=1)
  IF (dm_dbi_blocks > 500)
   SET dm_dbi_blocks = 500
  ENDIF
 ENDIF
 CALL echo(build("Numbers of rows to process: ",(dm_dbi_csv_rows - 1)))
 IF (dm_dbi_csv_rows=1)
  CALL echo("*****************************************")
  CALL echo("********    Program failed     **********")
  CALL echo("** Only one row in the csv file ******")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "Only one row in the CSV file, program failed"
  GO TO exit_script
 ENDIF
 SET dm_dbi_start_row = 1
 SET dm_dbi_end_row = 0
 FREE SET dm_dbi_csv_name
 FREE SET dm_dbi_validate_flag
 DECLARE dm_dbi_csv_name = c100 WITH public
 DECLARE dm_dbi_validate_flag = i2 WITH public, noconstant(0)
 DECLARE prepare_requestin(csv_name=vc,validate_flag=i2) = null
 SUBROUTINE prepare_requestin(csv_name,validate_flag)
  SET dm_dbi_csv_name = trim(csv_name,3)
  SET dm_dbi_validate_flag = validate_flag
 END ;Subroutine
 CALL prepare_requestin(trim(dm_dbi_file_loc,3),0)
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF (validate(requestin->dm_dbimport_validate,"Nope") != "Nope")
  SET rdm_status = "S"
  SET readme_data->status = "S"
  SET readme_data->message = "Requestin Already Created Successfully"
  GO TO exit_requestin
 ENDIF
 IF (validate(requestin,0))
  SET stat = alterlist(requestin->list_0,0)
 ENDIF
 FREE RECORD requestin
 FREE RECORD rec_info
 FREE RECORD rdm_line_data
 FREE RECORD str_data
 FREE RECORD columns_1
 FREE SET rdm_for_cnt
 FREE SET rdm_line_len
 FREE SET rdm_check_pos
 FREE SET rdm_field_total
 FREE SET rdm_csv_name
 FREE SET rdm_status
 FREE SET rdm_err_msg
 FREE SET rdm_col_size
 FREE SET delim
 FREE SET rdm_stat
 FREE SET dm_dbi_rtl3_ind
 FREE DEFINE rtl2
 FREE DEFINE rtl3
 IF ((validate(dm2_debug_flag,- (1))=- (1))
  AND (validate(dm2_debug_flag,- (2))=- (2)))
  FREE SET dm_rr_debug_flag
  DECLARE dm_rr_debug_flag = i2
  SET dm_rr_debug_flag = 0
 ELSE
  FREE SET dm_rr_debug_flag
  DECLARE dm_rr_debug_flag = i2
  SET dm_rr_debug_flag = dm2_debug_flag
 ENDIF
 IF ( NOT (validate(rec_info,0)))
  FREE RECORD rec_info
  RECORD rec_info(
    1 list_0[*]
      2 rec_line = vc
      2 assignment_line = vc
  ) WITH public
 ENDIF
 IF ( NOT (validate(rdm_line_data,0)))
  FREE RECORD rdm_line_data
  RECORD rdm_line_data(
    1 str = vc
  ) WITH public
 ENDIF
 IF ( NOT (validate(str_data,0)))
  FREE RECORD str_data
  RECORD str_data(
    1 string_qual = vc
  ) WITH public
 ENDIF
 IF ( NOT (validate(columns_1,0)))
  FREE RECORD columns_1
  RECORD columns_1(
    1 list_1[*]
      2 field_name = vc
  ) WITH public
 ENDIF
 IF ((validate(rdm_for_cnt,- (999))=- (999)))
  DECLARE rdm_for_cnt = i4 WITH public, noconstant(1)
 ENDIF
 IF ((validate(rdm_line_len,- (999))=- (999)))
  DECLARE rdm_line_len = i4 WITH public, noconstant(0)
 ENDIF
 IF ((validate(rdm_check_pos,- (999))=- (999)))
  DECLARE rdm_check_pos = i4 WITH public, noconstant(0)
 ENDIF
 IF ((validate(rdm_field_total,- (999))=- (999)))
  DECLARE rdm_field_total = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(rdm_csv_name,"Nothing")="Nothing")
  DECLARE rdm_csv_name = c100 WITH public
 ENDIF
 IF (validate(rdm_status,"Q")="Q")
  DECLARE rdm_status = c1 WITH public, noconstant("F")
 ENDIF
 IF (validate(rdm_err_msg,"Nothing")="Nothing")
  DECLARE rdm_err_msg = c132 WITH public
 ENDIF
 IF ((validate(rdm_col_size,- (999))=- (999)))
  DECLARE rdm_col_size = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(delim,"Q")="Q")
  DECLARE delim = c1 WITH public
 ENDIF
 IF ((validate(rdm_stat,- (999))=- (999)))
  DECLARE rdm_stat = i4 WITH public, noconstant(0)
 ENDIF
 IF ((validate(dm_dbi_rtl3_ind,- (999))=- (999)))
  DECLARE dm_dbi_rtl3_ind = i2 WITH public, noconstant(- (1))
 ENDIF
 FREE DEFINE rtl2
 SET rdm_stat = findfile(trim(dm_dbi_csv_name,3))
 IF (rdm_stat=0)
  CALL echo("*****************************************")
  CALL echo("********    Program failed     **********")
  CALL echo("**** DATA file could not be found *******")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "DATA File cound not be found."
  GO TO exit_requestin
 ENDIF
 IF ((readme_data->readme_id > 0))
  SET rdm_csv_name = concat("rdm_csv",trim(cnvtstring(readme_data->readme_id),3))
 ELSE
  SET rdm_csv_name = "rdm_csv_name"
 ENDIF
 CALL parser(concat("set logical ",trim(value(rdm_csv_name),3),' "',trim(dm_dbi_csv_name,3),'"'))
 CALL parser("go")
 DECLARE cur_csv_name = c100 WITH private, noconstant(value(rdm_csv_name))
 FREE DEFINE rtl2
 DEFINE rtl2 value(cur_csv_name)
 IF ((dm_dbi_rtl3_ind=- (1)))
  SELECT INTO "NL:"
   FROM rtl2t t
   DETAIL
    IF (textlen(trim(t.line,3)) > 1999)
     dm_dbi_rtl3_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (dm_rr_debug_flag >= 2)
  CALL echo("*")
  CALL echo(build("**** MEMORY:",curmem,"- End set logical, Begin define"))
  CALL echo("*")
 ENDIF
 IF (dm_dbi_rtl3_ind=1)
  SET maxcolwidth = 32000
  FREE DEFINE rtl3
  DEFINE rtl3 value(rdm_csv_name)
 ELSE
  FREE DEFINE rtl2
  DEFINE rtl2 value(rdm_csv_name)
 ENDIF
 IF (dm_rr_debug_flag >= 2)
  CALL echo("*")
  CALL echo(build("**** MEMORY:",curmem,"- End define, begin Create requestin def"))
  CALL echo("*")
 ENDIF
 SELECT
  IF (dm_dbi_rtl3_ind=1)
   FROM rtl3t t
   WHERE t.line > " "
  ELSE
   FROM rtl2t t
   WHERE t.line > " "
  ENDIF
  INTO "nl:"
  t.line
  HEAD REPORT
   rdm_line_data->str = " ", rdm_line_data->str = t.line, rdm_line_len = textlen(rdm_line_data->str),
   rdm_stat = alterlist(columns_1->list_1,10), rdm_continue = "Y",
   MACRO (setdelim)
    str_data->string_qual = replace(rdm_line_data->str," ","",0), str_data->string_qual = substring(1,
     1,rdm_line_data->str)
    IF ((str_data->string_qual != '"'))
     IF (findstring(",",rdm_line_data->str,1,0) > 0)
      delim = ","
     ELSEIF (findstring(char(9),rdm_line_data->str,1,0) > 0)
      delim = char(9)
     ELSEIF (findstring("|",rdm_line_data->str,1,0) > 0)
      delim = "|"
     ELSEIF (findstring("@",rdm_line_data->str,1,0) > 0)
      delim = "@"
     ELSEIF (findstring("~",rdm_line_data->str,1,0) > 0)
      delim = "~"
     ELSEIF (findstring("$",rdm_line_data->str,1,0) > 0)
      delim = "$"
     ELSEIF (findstring("^",rdm_line_data->str,1,0) > 0)
      delim = "^"
     ELSEIF (findstring("*",rdm_line_data->str,1,0) > 0)
      delim = "*"
     ELSEIF (findstring("#",rdm_line_data->str,1,0) > 0)
      delim = "#"
     ELSE
      delim = ","
     ENDIF
    ELSE
     match = findstring('"',rdm_line_data->str,2,0), delim = substring((match+ 1),1,rdm_line_data->
      str)
    ENDIF
   ENDMACRO
   ,
   setdelim
   WHILE (rdm_continue="Y")
     rdm_field_total = (rdm_field_total+ 1)
     IF (mod(rdm_field_total,10)=1
      AND rdm_field_total != 1)
      rdm_stat = alterlist(columns_1->list_1,(rdm_field_total+ 9))
     ENDIF
     IF ('"'=substring(1,1,rdm_line_data->str))
      IF ('""'=substring(2,2,rdm_line_data->str))
       rdm_check_pos = findstring('""",',rdm_line_data->str)
       IF (rdm_check_pos=0)
        rdm_continue = "N", rdm_check_pos = findstring('"""',substring(4,rdm_line_len,rdm_line_data->
          str)), columns_1->list_1[rdm_field_total].field_name = substring(4,(rdm_check_pos - 1),
         rdm_line_data->str)
       ELSE
        columns_1->list_1[rdm_field_total].field_name = substring(4,(rdm_check_pos - 4),rdm_line_data
         ->str), rdm_line_data->str = substring((rdm_check_pos+ 4),rdm_line_len,rdm_line_data->str)
        IF ((rdm_line_data->str=" "))
         rdm_continue = "N"
        ENDIF
       ENDIF
      ELSE
       rdm_check_pos = findstring('",',rdm_line_data->str)
       IF (rdm_check_pos=0)
        rdm_continue = "N", rdm_check_pos = findstring('"',substring(2,rdm_line_len,rdm_line_data->
          str)), columns_1->list_1[rdm_field_total].field_name = substring(2,(rdm_check_pos - 1),
         rdm_line_data->str)
       ELSE
        columns_1->list_1[rdm_field_total].field_name = substring(2,(rdm_check_pos - 2),rdm_line_data
         ->str), rdm_line_data->str = substring((rdm_check_pos+ 2),rdm_line_len,rdm_line_data->str)
        IF ((rdm_line_data->str=" "))
         rdm_continue = "N"
        ENDIF
       ENDIF
      ENDIF
     ELSE
      rdm_check_pos = findstring(delim,rdm_line_data->str)
      IF (rdm_check_pos=0)
       rdm_continue = "N", columns_1->list_1[rdm_field_total].field_name = substring(1,rdm_line_len,
        rdm_line_data->str)
      ELSE
       columns_1->list_1[rdm_field_total].field_name = substring(1,(rdm_check_pos - 1),rdm_line_data
        ->str), rdm_line_data->str = substring((rdm_check_pos+ 1),rdm_line_len,rdm_line_data->str)
       IF ((rdm_line_data->str=" "))
        rdm_continue = "N"
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
  WITH maxrec = 1
 ;end select
 IF (error(rdm_err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = rdm_err_msg
  GO TO exit_requestin
 ENDIF
 IF (dm_rr_debug_flag >= 2)
  CALL echo("*")
  CALL echo(build("**** MEMORY:",curmem,"- COLUMN REC FILLED, CALL PARSER TO CREATE DEF"))
  CALL echo("*")
 ENDIF
 SET rdm_stat = alterlist(columns_1->list_1,rdm_field_total)
 SET rdm_col_size = size(columns_1->list_1,5)
 SET rdm_stat = alterlist(rec_info->list_0,rdm_col_size)
 FOR (rdm_for_cnt = 1 TO rdm_col_size)
   SET rec_info->list_0[rdm_for_cnt].rec_line = concat("2 ",columns_1->list_1[rdm_for_cnt].field_name,
    " = VC")
 ENDFOR
 FREE RECORD requestin
 CALL parser("record requestin")
 CALL parser("(1 list_0[*]")
 FOR (rdm_for_cnt = 1 TO rdm_col_size)
  CALL parser(rec_info->list_0[rdm_for_cnt].rec_line)
  IF (error(rdm_err_msg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = rdm_err_msg
   GO TO exit_requestin
  ENDIF
 ENDFOR
 IF (dm_dbi_validate_flag=1)
  CALL parser("1 dm_dbimport_validate = c1")
 ENDIF
 CALL parser(")")
 IF ((readme_data->readme_id IN (2496, 2632, 2667, 2694, 2750,
 2772, 2933, 2939, 2958, 2984,
 3212, 3324, 3349, 3358, 3388,
 3413, 3414, 3466, 2630, 3350,
 3413, 3414, 2759, 2417, 2512)))
  CALL parser("with persistscript")
 ELSE
  CALL parser("with public")
 ENDIF
 CALL parser("go")
 IF (dm_dbi_validate_flag=1)
  CALL parser("set requestin->dm_dbimport_validate = 'Y' go")
 ENDIF
 IF (dm_rr_debug_flag >= 2)
  CALL echo("*")
  CALL echo(build("**** MEMORY:",curmem,"- DEF CREATED- CALL PARSER COMPLETE, POPULATING UNIT STR"))
  CALL echo("*")
 ENDIF
 SET rdm_status = "S"
 SET readme_data->status = "S"
 SET readme_data->message = "Requestin Created Successfully"
#exit_requestin
 IF ((readme_data->status="F"))
  CALL echo("*****************************************")
  CALL echo("********    Program failed     **********")
  CALL echo(concat("** ",readme_data->message," **"))
  CALL echo("*****************************************")
  GO TO exit_script
 ENDIF
 WHILE ((readme_data->status="S")
  AND dm_dbi_start_row < dm_dbi_csv_rows)
   SET dm_dbi_end_row = (dm_dbi_end_row+ dm_dbi_blocks)
   CALL echo(build("Processing rows: ",dm_dbi_start_row," to: ",dm_dbi_end_row))
   CALL echo(concat("Here is the csv file name: ",dm_dbi_file_loc))
   CALL echo("-----")
   EXECUTE rdm_dbimport dm_dbi_file_loc, dm_dbi_start_row, dm_dbi_end_row,
   dm_dbi_rtl3_ind
   CALL parser("execute ")
   CALL parser(dm_dbi_load_script)
   CALL parser(" go")
   IF ((readme_data->status="S"))
    IF (dm_dbi_parent_commit_ind != 1)
     COMMIT
    ENDIF
    IF (validate(requestin->dm_dbimport_validate,"Nope")="Nope"
     AND  NOT ((readme_data->readme_id IN (2496, 2632, 2667, 2694, 2750,
    2772, 2933, 2939, 2958, 2984,
    3212, 3324, 3349, 3358, 3388,
    3413, 3414, 3466, 2630, 3350,
    3413, 3414, 2759, 2417, 2512))))
     IF (validate(requestin,0))
      SET rdm_stat = alterlist(requestin->list_0,0)
     ENDIF
    ENDIF
   ELSE
    CALL echo("Load script has reported a failure, exiting script")
    CALL echo("*****************************************")
    CALL echo("** Load program reported a failure. *****")
    CALL echo("************ Exiting program *********** ")
    CALL echo("*****************************************")
    IF (dm_dbi_parent_commit_ind != 1)
     ROLLBACK
    ENDIF
    GO TO exit_script
   ENDIF
   SET dm_dbi_start_row = (dm_dbi_end_row+ 1)
 ENDWHILE
#exit_script
 IF (validate(requestin->dm_dbimport_validate,"Nope")="Nope"
  AND  NOT ((readme_data->readme_id IN (2496, 2632, 2667, 2694, 2750,
 2772, 2933, 2939, 2958, 2984,
 3212, 3324, 3349, 3358, 3388,
 3413, 3414, 3466, 2630, 3350,
 3413, 3414, 2759, 2417, 2512))))
  IF (validate(requestin,0))
   SET stat = alterlist(requestin->list_0,0)
  ENDIF
  FREE RECORD requestin
  FREE RECORD rec_info
  FREE RECORD rdm_line_data
  FREE RECORD str_data
  FREE RECORD columns_1
  FREE SET rdm_for_cnt
  FREE SET rdm_line_len
  FREE SET rdm_check_pos
  FREE SET rdm_field_total
  FREE SET rdm_csv_name
  FREE SET rdm_status
  FREE SET rdm_err_msg
  FREE SET rdm_col_size
  FREE SET delim
  FREE SET rdm_stat
  FREE SET dm_dbi_rtl3_ind
  FREE DEFINE rtl2
  FREE DEFINE rtl3
 ENDIF
END GO
