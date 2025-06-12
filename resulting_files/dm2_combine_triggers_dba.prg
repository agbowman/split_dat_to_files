CREATE PROGRAM dm2_combine_triggers:dba
 PROMPT
  "Enter table_name, or table_prefix* in quotes:  " = ""
 IF (build( $1) != char(42))
  IF (build( $1)="")
   CALL echo(concat("Usage:  ",curprog," '<table_name>' GO"))
   GO TO 9999_exit_program
  ENDIF
 ENDIF
 SET c_mod = "DM2_COMBINE_TRIGGERS -- mod - 040"
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_drop TO 2999_drop_exit
 EXECUTE FROM 3000_build TO 3999_build_exit
 GO TO 9999_exit_program
 SUBROUTINE ct_column_exists(ce_table,ce_column)
   SET ce_flag = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ce_table,3))
     AND l.attr_name=cnvtupper(trim(ce_column,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     ce_flag = 1
    WITH nocounter
   ;end select
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE ct_exists(e_trigger)
   SET e_flag = 0
   SELECT INTO "nl:"
    t.trigger_name
    FROM user_triggers t
    WHERE t.trigger_name=cnvtupper(trim(e_trigger,3))
    DETAIL
     e_flag = 2
     IF (t.status IN ("ENABLED", "Y"))
      e_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(e_flag)
 END ;Subroutine
 SUBROUTINE ct_kick(k_message)
   IF (validate(ct_error->err_ind,99) != 99)
    SET ct_error->err_ind = 1
   ENDIF
   SET ct_error->message = k_message
   GO TO 9999_exit_program
 END ;Subroutine
 SUBROUTINE ct_push(p_text)
   SET p_i = (size(ct_data->buffer,5)+ 1)
   SET p_stat = alterlist(ct_data->buffer,p_i)
   SET ct_data->buffer[p_i].text = p_text
 END ;Subroutine
 SUBROUTINE ct_run(r_dummy)
   SET r_count = size(ct_data->buffer,5)
   IF (r_count)
    FOR (r_i = 1 TO r_count)
     IF (r_i=1)
      CALL parser(concat("rdb asis(^",ct_data->buffer[r_i].text,char(10),"^)"),1)
     ELSE
      CALL parser(concat("asis(^",ct_data->buffer[r_i].text,char(10),"^)"),1)
     ENDIF
     IF (debug_ind)
      CALL echo(ct_data->buffer[r_i].text,1,0)
     ENDIF
    ENDFOR
    CALL parser("end go",1)
   ENDIF
   SET r_stat = alterlist(ct_data->buffer,0)
 END ;Subroutine
 SUBROUTINE ct_recompile_sql(p_ind1)
   SET stat = alterlist(ct_data->buffer,0)
   DECLARE ct_file_name = c35
   FOR (ct_i = 1 TO 2)
     SET ct_file_name = " "
     IF (person_prc_ind=0)
      SET ct_file_name = ct_person_prc
      SET person_prc_ind = 1
     ELSE
      SET ct_file_name = ct_encntr_prc
      SET encntr_prc_ind = 1
     ENDIF
     IF (trim(ct_file_name,3) > "")
      SET logical ct_file value(cnvtlower(build("cer_install:",ct_file_name,".sql")))
      CALL echo(logical("ct_file"))
      IF (findfile(logical("ct_file"))=1)
       FREE DEFINE rtl
       DEFINE rtl "ct_file"
       SELECT INTO "nl:"
        j.line
        FROM rtlt j
        DETAIL
         IF (trim(j.line,3) != ""
          AND trim(j.line,3) != "/")
          CALL ct_push(trim(j.line))
         ENDIF
        WITH nocounter
       ;end select
       CALL ct_run(0)
       SET r_stat = alterlist(ct_data->buffer,0)
      ELSE
       CALL echo("The procedure was found to be invalid and source sql file does not exist.")
       CALL echo("Exiting program.")
       GO TO 9999_exit_program
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE ct_type(t_parent,t_child)
   DECLARE ct_return_value = i4
   DECLARE ct_idx = i4
   DECLARE ct_pos = i4
   SET ct_return_value = - (1)
   IF (t_parent="ENCOUNTER")
    SET ct_pos = locateval(ct_idx,1,size(ct_data->encntr,5),t_child,ct_data->encntr[ct_idx].
     child_table)
    IF (ct_pos > 0)
     SET cmb_trigger_type = ct_data->encntr[ct_idx].trigger_type
    ELSE
     SET cmb_trigger_type = get_admin_trig_info(t_child,0)
    ENDIF
   ELSE
    SET ct_pos = locateval(ct_idx,1,size(ct_data->person,5),t_child,ct_data->person[ct_idx].
     child_table)
    IF (ct_pos > 0)
     SET cmb_trigger_type = ct_data->person[ct_idx].trigger_type
    ELSE
     SET cmb_trigger_type = get_admin_trig_info(t_child,1)
    ENDIF
   ENDIF
   CASE (cmb_trigger_type)
    OF "AUTO":
     SET ct_return_value = ct_auto
    OF "DEFAULT":
     SET ct_return_value = ct_default
    OF "NULL":
     SET ct_return_value = ct_null
   ENDCASE
   IF ((ct_return_value=- (1)))
    SET ct_return_value = ct_default
    SELECT INTO "nl:"
     e.child_entity
     FROM dm_cmb_exception e
     WHERE e.operation_type="COMBINE"
      AND e.parent_entity=t_parent
      AND e.child_entity=t_child
      AND cnvtupper(e.script_name)="NONE"
     DETAIL
      ct_return_value = ct_null
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ct_return_value)
 END ;Subroutine
 SUBROUTINE get_dm_info_metadata(null)
   FREE RECORD gdim_per_trig_info
   RECORD gdim_per_trig_info(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 trigger_type = vc
   )
   FREE RECORD gdim_enc_trig_info
   RECORD gdim_enc_trig_info(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 trigger_type = vc
   )
   FREE RECORD gdim_tab_suffix
   RECORD gdim_tab_suffix(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 table_suffix = vc
   )
   DECLARE rs_pos = i4
   DECLARE rs_idx = i4
   DECLARE rs_loc_val = i4
   DECLARE sffx_idx = i4
   DECLARE sffx_loc_val = i4
   SET gdim_per_trig_info->cnt = 0
   SET gdim_enc_trig_info->cnt = 0
   SET gdim_tab_suffix->cnt = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE info_domain="COMBINE_TRIGGER_TYPE_PERSON"
    DETAIL
     gdim_per_trig_info->cnt += 1
     IF (mod(gdim_per_trig_info->cnt,999)=1)
      stat = alterlist(gdim_per_trig_info->qual,(gdim_per_trig_info->cnt+ 999))
     ENDIF
     gdim_per_trig_info->qual[gdim_per_trig_info->cnt].table_name = di.info_name, gdim_per_trig_info
     ->qual[gdim_per_trig_info->cnt].trigger_type = cnvtupper(trim(di.info_char,3))
    FOOT REPORT
     stat = alterlist(gdim_per_trig_info->qual,gdim_per_trig_info->cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE info_domain="COMBINE_TRIGGER_TYPE_ENCNTR"
    DETAIL
     gdim_enc_trig_info->cnt += 1
     IF (mod(gdim_enc_trig_info->cnt,999)=1)
      stat = alterlist(gdim_enc_trig_info->qual,(gdim_enc_trig_info->cnt+ 999))
     ENDIF
     gdim_enc_trig_info->qual[gdim_enc_trig_info->cnt].table_name = di.info_name, gdim_enc_trig_info
     ->qual[gdim_enc_trig_info->cnt].trigger_type = cnvtupper(trim(di.info_char,3))
    FOOT REPORT
     stat = alterlist(gdim_enc_trig_info->qual,gdim_enc_trig_info->cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE info_domain="DM_TABLES_DOC_TABLE_SUFFIX"
    DETAIL
     gdim_tab_suffix->cnt += 1
     IF (mod(gdim_tab_suffix->cnt,999)=1)
      stat = alterlist(gdim_tab_suffix->qual,(gdim_tab_suffix->cnt+ 999))
     ENDIF
     gdim_tab_suffix->qual[gdim_tab_suffix->cnt].table_name = di.info_name, gdim_tab_suffix->qual[
     gdim_tab_suffix->cnt].table_suffix = di.info_char
    FOOT REPORT
     stat = alterlist(gdim_tab_suffix->qual,gdim_tab_suffix->cnt)
    WITH nocounter
   ;end select
   FOR (rs_index = 1 TO size(ct_data->person,5))
     SET rs_loc_val = locateval(rs_idx,1,gdim_per_trig_info->cnt,ct_data->person[rs_index].
      child_table,gdim_per_trig_info->qual[rs_idx].table_name)
     IF (rs_loc_val > 0)
      SET ct_data->person[rs_index].trigger_type = gdim_per_trig_info->qual[rs_loc_val].trigger_type
     ELSE
      SET ct_data->person[rs_index].trigger_type = get_admin_trig_info(ct_data->person[rs_index].
       child_table,1)
     ENDIF
     SET sffx_loc_val = locateval(sffx_idx,1,gdim_tab_suffix->cnt,ct_data->person[rs_index].
      child_table,gdim_tab_suffix->qual[sffx_idx].table_name)
     IF (sffx_loc_val > 0)
      SET ct_data->person[rs_index].child_table_suffix = gdim_tab_suffix->qual[sffx_loc_val].
      table_suffix
     ELSE
      SET ct_data->person[rs_index].child_table_suffix = get_admin_suffix_info(ct_data->person[
       rs_index].child_table)
     ENDIF
     SET ct_data->person[rs_index].suffix_child_table = concat(trim(substring(1,14,ct_data->person[
        rs_index].child_table)),ct_data->person[rs_index].child_table_suffix)
     SET ct_data->person[rs_index].trigger_name = build(ct_data->person[rs_index].trigger_name,
      ct_data->person[rs_index].child_table_suffix,"_",trim(substring(1,15,ct_data->person[rs_index].
        child_table)))
   ENDFOR
   SET rs_index = 1
   FOR (rs_index = 1 TO size(ct_data->encntr,5))
     SET rs_loc_val = locateval(rs_idx,1,gdim_enc_trig_info->cnt,ct_data->encntr[rs_index].
      child_table,gdim_enc_trig_info->qual[rs_idx].table_name)
     IF (rs_loc_val > 0)
      SET ct_data->encntr[rs_index].trigger_type = gdim_enc_trig_info->qual[rs_loc_val].trigger_type
     ELSE
      SET ct_data->encntr[rs_index].trigger_type = get_admin_trig_info(ct_data->encntr[rs_index].
       child_table,0)
     ENDIF
     SET sffx_loc_val = locateval(sffx_idx,1,gdim_tab_suffix->cnt,ct_data->encntr[rs_index].
      child_table,gdim_tab_suffix->qual[sffx_idx].table_name)
     IF (sffx_loc_val > 0)
      SET ct_data->encntr[rs_index].child_table_suffix = gdim_tab_suffix->qual[sffx_loc_val].
      table_suffix
     ELSE
      SET ct_data->encntr[rs_index].child_table_suffix = get_admin_suffix_info(ct_data->encntr[
       rs_index].child_table)
     ENDIF
     SET ct_data->encntr[rs_index].suffix_child_table = concat(trim(substring(1,14,ct_data->encntr[
        rs_index].child_table)),ct_data->encntr[rs_index].child_table_suffix)
     SET ct_data->encntr[rs_index].trigger_name = build(ct_data->encntr[rs_index].trigger_name,
      ct_data->encntr[rs_index].child_table_suffix,"_",trim(substring(1,15,ct_data->encntr[rs_index].
        child_table)))
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_admin_trig_info(i_table_name,i_pers_trig_ind)
   DECLARE gati_ret = vc WITH protect, noconstant("")
   IF (i_pers_trig_ind=0)
    SELECT INTO "nl:"
     FROM dm_tables_doc dtd
     WHERE dtd.table_name=i_table_name
     DETAIL
      gati_ret = cnvtupper(trim(dtd.encntr_cmb_trigger_type,3))
     WITH nocounter
    ;end select
   ELSEIF (i_pers_trig_ind=1)
    SELECT INTO "nl:"
     FROM dm_tables_doc dtd
     WHERE dtd.table_name=i_table_name
     DETAIL
      gati_ret = cnvtupper(trim(dtd.person_cmb_trigger_type,3))
     WITH nocounter
    ;end select
   ENDIF
   RETURN(gati_ret)
 END ;Subroutine
 SUBROUTINE get_admin_suffix_info(i_table_name)
   DECLARE gasi_ret = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM dm_tables_doc dtd
    WHERE dtd.table_name=i_table_name
    DETAIL
     gasi_ret = dtd.table_suffix
    WITH nocounter
   ;end select
   RETURN(gasi_ret)
 END ;Subroutine
#1000_initialize
 SET debug_ind = 0
 IF (validate(dm_debug,0))
  SET debug_ind = 1
 ENDIF
 IF ( NOT (validate(ct_error,0)))
  FREE RECORD ct_error
  RECORD ct_error(
    1 message = vc
    1 err_ind = i2
  )
 ENDIF
 IF ( NOT (validate(build_triggers,0)))
  SET build_triggers = 1
 ENDIF
 SET ct_default = 0
 SET ct_auto = 1
 SET ct_null = 2
 FREE RECORD ct_data
 RECORD ct_data(
   1 trigger[*]
     2 name = vc
     2 child_table = vc
     2 parent_table = vc
     2 when_clause = vc
     2 drop_ind = i2
   1 person[*]
     2 child_table = vc
     2 suffix_child_table = vc
     2 child_table_suffix = c4
     2 child_column = vc
     2 child_pk = vc
     2 trigger_event = vc
     2 trigger_name = vc
     2 trigger_type = vc
     2 sequence = i2
     2 special = i2
     2 multiple = i2
     2 encntr_col = vc
     2 parent_entity_name = vc
     2 exclude_ind = i2
   1 encntr[*]
     2 child_table = vc
     2 suffix_child_table = vc
     2 child_table_suffix = c4
     2 child_column = vc
     2 child_pk = vc
     2 trigger_event = vc
     2 trigger_name = vc
     2 trigger_type = vc
     2 sequence = i2
     2 exclude_ind = i2
   1 buffer[*]
     2 text = vc
 )
 SET ct_i = 0
 SET ct_j = 0
 DECLARE ct_type_flag = i4
 DECLARE ct_type_text = c10
 SET ct_type_flag = 0
 SET ct_type_text = fillstring(10," ")
 DECLARE ct_person_cnt = f8
 DECLARE ct_encntr_cnt = f8
 SET ct_person_cnt = 0
 SET ct_encntr_cnt = 0
 SET ct_temp_value =  $1
 SET ct_i_value = cnvtupper(build(ct_temp_value))
 FREE SET ct_temp_value
 FREE RECORD ct_str
 RECORD ct_str(
   1 str = vc
   1 str1 = vc
   1 str2 = vc
 )
 DECLARE ct_i_wildcard_ind = i4
 SET ct_i_wildcard_ind = 0
 DECLARE ct_exists_flag = i4
 SET ct_exists_flag = 0
 DECLARE ct_check_admin = i2 WITH protect, noconstant(0)
 DECLARE ct_ecode = i4 WITH protect, noconstant(0)
 DECLARE ct_errmsg = vc WITH protect, noconstant("")
 SET ct_errmsg = fillstring(132," ")
 IF (((findstring(char(42),ct_i_value,1)) OR (findstring("$C",ct_i_value,1))) )
  SET ct_str->str = "findstring('$C',TABLE_ALIAS.COLUMN_NAME) = 0 "
  SET ct_str->str1 = replace(ct_str->str,"TABLE_ALIAS.COLUMN_NAME","t.table_name",0)
  SET ct_str->str2 = replace(ct_str->str,"TABLE_ALIAS.COLUMN_NAME","c.child_table",0)
  IF (findstring(char(42),ct_i_value,1))
   SET ct_i_wildcard_ind = 1
  ENDIF
 ELSE
  SET ct_str->str = "1 = 1"
  SET ct_str->str1 = ct_str->str
  SET ct_str->str2 = ct_str->str
 ENDIF
 SET ct_str->str = ""
 IF (debug_ind)
  CALL echo(build("ct_str->str1 =",ct_str->str1))
  CALL echo(build("ct_str->str2 =",ct_str->str2))
 ENDIF
 IF (currdb="ORACLE")
  SET ct_person_prc = "DM_CMB_FIND_PERSON2"
  SET ct_encntr_prc = "DM_CMB_FIND_ENCOUNTER2"
  SET person_prc_ind = 0
  SET encntr_prc_ind = 0
  SELECT INTO "nl:"
   FROM user_objects t
   WHERE t.object_name IN (ct_person_prc, ct_encntr_prc)
    AND status="VALID"
   DETAIL
    IF (t.object_name=ct_person_prc)
     person_prc_ind = 1
    ELSEIF (t.object_name=ct_encntr_prc)
     encntr_prc_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("person_prc_ind =",person_prc_ind))
  CALL echo(build("encntr_prc_ind =",encntr_prc_ind))
  IF (((person_prc_ind=0) OR (encntr_prc_ind=0)) )
   CALL echo(
    "One or the other combine procedures wasn't found - rebuilding from the cer_install version",1,0)
   CALL ct_recompile_sql(0)
   SET stat = 0
  ENDIF
 ENDIF
 SET ct_cnt = 0
#1999_initialize_exit
#2000_drop
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COMBINE_TRIGGER_TYPE*"
  WITH nocounter, maxqual(di,1)
 ;end select
 IF (curqual=0)
  SET ct_check_admin = 1
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_TABLES_DOC_TABLE_SUFFIX"
  WITH nocounter, maxqual(di,1)
 ;end select
 IF (curqual=0)
  SET ct_check_admin = 1
 ENDIF
 IF (ct_check_admin=1)
  SELECT INTO "nl:"
   FROM dm_tables_doc dtd
   WITH nocounter, maxqual(dtd,1)
  ;end select
  SET ct_ecode = error(ct_errmsg,1)
  IF (ct_ecode != 0)
   IF (validate(ct_error->err_ind,99) != 99)
    SET ct_error->err_ind = 1
   ENDIF
   SET ct_error->message = ct_errmsg
   GO TO 9999_exit_program
  ENDIF
 ENDIF
 SET ct_i = 0
 SELECT INTO "nl:"
  t.trigger_name
  FROM user_triggers t
  WHERE t.trigger_name="TRG*CMB*"
   AND substring(1,4,t.trigger_name)="TRG_"
   AND t.table_name=patstring(ct_i_value)
   AND parser(ct_str->str1)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_info di
   WHERE di.info_domain="OBSOLETE_OBJECT"
    AND di.info_char="TABLE"
    AND di.info_name=t.table_name)))
  DETAIL
   ct_i += 1
   IF (mod(ct_i,10)=1)
    stat = alterlist(ct_data->trigger,(ct_i+ 9))
   ENDIF
   ct_data->trigger[ct_i].name = t.trigger_name, ct_data->trigger[ct_i].child_table = t.table_name,
   ct_data->trigger[ct_i].when_clause = t.when_clause
   IF (substring(1,8,t.trigger_name)="TRG_PCMB")
    ct_data->trigger[ct_i].parent_table = "PERSON"
   ELSEIF (substring(1,8,t.trigger_name)="TRG_ECMB")
    ct_data->trigger[ct_i].parent_table = "ENCOUNTER"
   ENDIF
  FOOT REPORT
   stat = alterlist(ct_data->trigger,ct_i)
  WITH nocounter
 ;end select
 IF (validate(drop_only,0))
  GO TO 9999_exit_program
 ENDIF
#2999_drop_exit
#3000_build
 IF ( NOT (build_triggers))
  GO TO 3000_continue
 ENDIF
 SELECT INTO "nl:"
  c.child_table
  FROM dm_cmb_children c
  WHERE c.parent_table IN ("PERSON", "ENCOUNTER")
   AND c.child_column > " "
   AND c.child_pk > " "
   AND c.child_table=patstring(ct_i_value)
   AND parser(ct_str->str2)
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_info di
   WHERE di.info_domain="OBSOLETE_OBJECT"
    AND di.info_char="TABLE"
    AND di.info_name=c.child_table)))
  ORDER BY c.parent_table, c.child_table, c.child_column
  HEAD c.parent_table
   row + 0
  HEAD c.child_table
   ct_j = 0
  HEAD c.child_column
   ct_j += 1
   IF (currdb="ORACLE")
    IF (c.parent_table="ENCOUNTER")
     ct_i = (size(ct_data->encntr,5)+ 1), stat = alterlist(ct_data->encntr,ct_i), ct_data->encntr[
     ct_i].child_table = trim(cnvtupper(c.child_table),3),
     ct_data->encntr[ct_i].child_column = trim(cnvtupper(c.child_column),3), ct_data->encntr[ct_i].
     child_pk = trim(cnvtupper(c.child_pk),3), ct_data->encntr[ct_i].sequence = ct_j,
     ct_data->encntr[ct_i].trigger_name = concat("TRG_ECMB",trim(cnvtstring(ct_j),3),"_")
    ELSE
     ct_i = (size(ct_data->person,5)+ 1), stat = alterlist(ct_data->person,ct_i), ct_data->person[
     ct_i].child_table = cnvtupper(trim(c.child_table,3)),
     ct_data->person[ct_i].child_column = cnvtupper(trim(c.child_column,3)), ct_data->person[ct_i].
     child_pk = trim(cnvtupper(c.child_pk),3), ct_data->person[ct_i].sequence = ct_j,
     ct_data->person[ct_i].trigger_name = concat("TRG_PCMB",trim(cnvtstring(ct_j),3),"_")
     IF (((c.child_table="ENCNTR_PLAN_RELTN") OR (c.child_table="ENCNTR_PERSON_RELTN")) )
      ct_data->person[ct_i].multiple = 1
     ENDIF
    ENDIF
   ELSEIF (currdb="DB2UDB")
    IF (c.parent_table="ENCOUNTER")
     ct_i = (size(ct_data->encntr,5)+ 1), stat = alterlist(ct_data->encntr,ct_i), ct_data->encntr[
     ct_i].child_table = trim(cnvtupper(c.child_table),3),
     ct_data->encntr[ct_i].child_column = trim(cnvtupper(c.child_column),3), ct_data->encntr[ct_i].
     child_pk = trim(cnvtupper(c.child_pk),3), ct_data->encntr[ct_i].sequence = ct_j,
     ct_data->encntr[ct_i].trigger_name = concat("TRG_",ct_data->encntr[ct_i].child_table_suffix,
      "_EUCMB",trim(cnvtstring(ct_j),3)), ct_data->encntr[ct_i].trigger_event = "update", ct_i = (
     size(ct_data->encntr,5)+ 1),
     stat = alterlist(ct_data->encntr,ct_i), ct_data->encntr[ct_i].child_table = trim(cnvtupper(c
       .child_table),3), ct_data->encntr[ct_i].child_column = trim(cnvtupper(c.child_column),3),
     ct_data->encntr[ct_i].child_pk = trim(cnvtupper(c.child_pk),3), ct_data->encntr[ct_i].sequence
      = ct_j, ct_data->encntr[ct_i].trigger_name = concat("TRG_",ct_data->encntr[ct_i].
      child_table_suffix,"_EICMB",trim(cnvtstring(ct_j),3)),
     ct_data->encntr[ct_i].trigger_event = "insert"
    ELSE
     ct_i = (size(ct_data->person,5)+ 1), stat = alterlist(ct_data->person,ct_i), ct_data->person[
     ct_i].child_table = cnvtupper(trim(c.child_table,3)),
     ct_data->person[ct_i].child_column = cnvtupper(trim(c.child_column,3)), ct_data->person[ct_i].
     child_pk = trim(cnvtupper(c.child_pk),3), ct_data->person[ct_i].sequence = ct_j,
     ct_data->person[ct_i].trigger_name = concat("TRG_",ct_data->person[ct_i].child_table_suffix,
      "_PUCMB",trim(cnvtstring(ct_j),3)), ct_data->person[ct_i].trigger_event = "update", ct_i = (
     size(ct_data->person,5)+ 1),
     stat = alterlist(ct_data->person,ct_i), ct_data->person[ct_i].child_table = cnvtupper(trim(c
       .child_table,3)), ct_data->person[ct_i].child_column = cnvtupper(trim(c.child_column,3)),
     ct_data->person[ct_i].child_pk = trim(cnvtupper(c.child_pk),3), ct_data->person[ct_i].sequence
      = ct_j, ct_data->person[ct_i].trigger_name = concat("TRG_",ct_data->person[ct_i].
      child_table_suffix,"_PICMB",trim(cnvtstring(ct_j),3)),
     ct_data->person[ct_i].trigger_event = "insert"
     IF (((c.child_table="ENCNTR_PLAN_RELTN") OR (c.child_table="ENCNTR_PERSON_RELTN")) )
      ct_data->person[ct_i].multiple = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL get_dm_info_metadata(null)
 IF (size(ct_data->person,5) > 0)
  SELECT INTO "nl:"
   c.child_table
   FROM dm_cmb_children c,
    (dummyt d  WITH seq = value(size(ct_data->person,5)))
   PLAN (d
    WHERE (ct_data->person[d.seq].child_column != "PERSON_ID"))
    JOIN (c
    WHERE c.parent_table="PERSON"
     AND (c.child_table=ct_data->person[d.seq].child_table)
     AND (c.child_column != ct_data->person[d.seq].child_column))
   DETAIL
    ct_data->person[d.seq].multiple = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.child_column
   FROM dm_cmb_children c,
    (dummyt d  WITH seq = value(size(ct_data->person,5)))
   PLAN (d
    WHERE (ct_data->person[d.seq].multiple <= 0))
    JOIN (c
    WHERE c.parent_table="ENCOUNTER"
     AND (c.child_table=ct_data->person[d.seq].child_table)
     AND c.child_column > " ")
   DETAIL
    ct_data->person[d.seq].encntr_col = c.child_column
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(ct_data->person,5)))
   PLAN (d
    WHERE (ct_data->person[d.seq].child_table="ENCOUNTER"))
   DETAIL
    ct_data->person[d.seq].encntr_col = "ENCNTR_ID"
   WITH nocounter
  ;end select
 ENDIF
 IF (((ct_i_wildcard_ind) OR (ct_i_value IN ("ADDRESS", "ADDRESS1504", "PHONE", "PHONE0390",
 "CHART_REQUEST_AUDIT",
 "CHART_REQUEST_6718"))) )
  IF (((ct_i_wildcard_ind) OR (ct_i_value IN ("ADDRESS", "ADDRESS1504"))) )
   IF (currdb="ORACLE")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "ADDRESS"
    SET ct_data->person[ct_i].suffix_child_table = "ADDRESS1504"
    SET ct_data->person[ct_i].child_table_suffix = "1504"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_1504_ADDRESS"
    SET ct_data->person[ct_i].special = 1
   ELSEIF (currdb="DB2UDB")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "ADDRESS"
    SET ct_data->person[ct_i].suffix_child_table = "ADDRESS1504"
    SET ct_data->person[ct_i].child_table_suffix = "1504"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_1504_PUCMB1"
    SET ct_data->person[ct_i].trigger_event = "update"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "ADDRESS"
    SET ct_data->person[ct_i].suffix_child_table = "ADDRESS1504"
    SET ct_data->person[ct_i].child_table_suffix = "1504"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_1504_PICMB1"
    SET ct_data->person[ct_i].trigger_event = "insert"
    SET ct_data->person[ct_i].special = 1
   ENDIF
  ENDIF
  IF (((ct_i_wildcard_ind) OR (ct_i_value IN ("PHONE", "PHONE0390"))) )
   IF (currdb="ORACLE")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "PHONE"
    SET ct_data->person[ct_i].suffix_child_table = "PHONE0390"
    SET ct_data->person[ct_i].child_table_suffix = "0390"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_0390_PHONE"
    SET ct_data->person[ct_i].special = 1
   ELSEIF (currdb="DB2UDB")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "PHONE"
    SET ct_data->person[ct_i].suffix_child_table = "PHONE0390"
    SET ct_data->person[ct_i].child_table_suffix = "0390"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_0390_PUCMB1"
    SET ct_data->person[ct_i].trigger_event = "update"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "PHONE"
    SET ct_data->person[ct_i].suffix_child_table = "PHONE0390"
    SET ct_data->person[ct_i].child_table_suffix = "0390"
    SET ct_data->person[ct_i].child_column = "PARENT_ENTITY_ID"
    SET ct_data->person[ct_i].parent_entity_name = "PARENT_ENTITY_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_0390_PICMB1"
    SET ct_data->person[ct_i].trigger_event = "insert"
    SET ct_data->person[ct_i].special = 1
   ENDIF
  ENDIF
  IF (((ct_i_wildcard_ind) OR (ct_i_value IN ("CHART_REQUEST_AUDIT", "CHART_REQUEST_6718"))) )
   IF (currdb="ORACLE")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "DEST_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "DEST_PE_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_PCMB1_6718_CHART_REQUEST_A"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "REQUESTOR_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "REQUESTOR_PE_NAME"
    SET ct_data->person[ct_i].sequence = 2
    SET ct_data->person[ct_i].trigger_name = "TRG_PCMB2_6718_CHART_REQUEST_A"
    SET ct_data->person[ct_i].special = 1
   ELSEIF (currdb="DB2UDB")
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "DEST_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "DEST_PE_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_6718_PUCMB1"
    SET ct_data->person[ct_i].trigger_event = "update"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "DEST_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "DEST_PE_NAME"
    SET ct_data->person[ct_i].sequence = 1
    SET ct_data->person[ct_i].trigger_name = "TRG_6718_PICMB1"
    SET ct_data->person[ct_i].trigger_event = "insert"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "REQUESTOR_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "REQUESTOR_PE_NAME"
    SET ct_data->person[ct_i].sequence = 2
    SET ct_data->person[ct_i].trigger_name = "TRG_6718_PUCMB2"
    SET ct_data->person[ct_i].trigger_event = "update"
    SET ct_data->person[ct_i].special = 1
    SET ct_i = (size(ct_data->person,5)+ 1)
    SET stat = alterlist(ct_data->person,ct_i)
    SET ct_data->person[ct_i].child_table = "CHART_REQUEST_AUDIT"
    SET ct_data->person[ct_i].suffix_child_table = "CHART_REQUEST_6718"
    SET ct_data->person[ct_i].child_table_suffix = "6718"
    SET ct_data->person[ct_i].child_column = "REQUESTOR_PE_ID"
    SET ct_data->person[ct_i].parent_entity_name = "REQUESTOR_PE_NAME"
    SET ct_data->person[ct_i].sequence = 2
    SET ct_data->person[ct_i].trigger_name = "TRG_6718_PICMB2"
    SET ct_data->person[ct_i].trigger_event = "insert"
    SET ct_data->person[ct_i].special = 1
   ENDIF
  ENDIF
 ENDIF
 IF (debug_ind)
  CALL echo(build("trigger_size =",size(ct_data->trigger,5)))
  CALL echo(build("person_size =",size(ct_data->person,5)))
 ENDIF
 IF (size(ct_data->person,5) > 0
  AND size(ct_data->trigger,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ct_data->person,5))),
    (dummyt d2  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d1)
    JOIN (d2
    WHERE (ct_data->trigger[d2.seq].name=build(substring(1,28,ct_data->person[d1.seq].trigger_name),
     "$C")))
   HEAD REPORT
    ctt_cnt = 0, ctt_found = 0
   DETAIL
    FOR (ctt_cnt = 1 TO size(ct_data->trigger,5))
      IF ((ct_data->person[d1.seq].trigger_name=ct_data->trigger[ctt_cnt].name))
       ctt_found = 1, ctt_cnt = size(ct_data->trigger,5)
      ENDIF
    ENDFOR
    IF ( NOT (ctt_found))
     ct_data->person[d1.seq].trigger_name = ct_data->trigger[d2.seq].name
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (debug_ind)
  CALL echo(build("trigger_size =",size(ct_data->trigger,5)))
  CALL echo(build("encntr_size =",size(ct_data->encntr,5)))
 ENDIF
 IF (size(ct_data->encntr,5) > 0
  AND size(ct_data->trigger,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ct_data->encntr,5))),
    (dummyt d2  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d1)
    JOIN (d2
    WHERE (ct_data->trigger[d2.seq].name=build(substring(1,28,ct_data->encntr[d1.seq].trigger_name),
     "$C")))
   HEAD REPORT
    ctt_cnt = 0, ctt_found = 0
   DETAIL
    FOR (ctt_cnt = 1 TO size(ct_data->trigger,5))
      IF ((ct_data->encntr[d1.seq].trigger_name=ct_data->trigger[ctt_cnt].name))
       ctt_found = 1, ctt_cnt = size(ct_data->trigger,5)
      ENDIF
    ENDFOR
    IF ( NOT (ctt_found))
     ct_data->encntr[d1.seq].trigger_name = ct_data->trigger[d2.seq].name
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (size(ct_data->trigger,5) > 0)
  SELECT INTO "nl:"
   FROM dm_cmb_exception dce,
    (dummyt d  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d
    WHERE (ct_data->trigger[d.seq].child_table=patstring(ct_i_value))
     AND (ct_data->trigger[d.seq].parent_table > " "))
    JOIN (dce
    WHERE dce.operation_type="COMBINE"
     AND (dce.parent_entity=ct_data->trigger[d.seq].parent_table)
     AND (dce.child_entity=ct_data->trigger[d.seq].child_table)
     AND dce.script_name="NONE")
   DETAIL
    ct_data->trigger[d.seq].drop_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_info di,
    (dummyt d  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d
    WHERE (ct_data->trigger[d.seq].child_table=patstring(ct_i_value))
     AND (ct_data->trigger[d.seq].parent_table > " "))
    JOIN (di
    WHERE (di.info_name=ct_data->trigger[d.seq].child_table)
     AND di.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(ct_data->trigger[d.seq].parent_table,
      "ENCOUNTER","ENCNTR","PERSON"))
     AND cnvtupper(trim(di.info_char,3))="NULL")
   DETAIL
    ct_data->trigger[d.seq].drop_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt p  WITH seq = value(size(ct_data->person,5))),
    (dummyt d  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d
    WHERE (ct_data->trigger[d.seq].child_table=patstring(ct_i_value))
     AND (ct_data->trigger[d.seq].parent_table="PERSON")
     AND (ct_data->trigger[d.seq].drop_ind=1))
    JOIN (p
    WHERE (ct_data->person[p.seq].child_table=ct_data->trigger[d.seq].child_table))
   DETAIL
    ct_data->person[p.seq].exclude_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt e  WITH seq = value(size(ct_data->encntr,5))),
    (dummyt d  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d
    WHERE (ct_data->trigger[d.seq].child_table=patstring(ct_i_value))
     AND (ct_data->trigger[d.seq].parent_table="ENCOUNTER")
     AND (ct_data->trigger[d.seq].drop_ind=1))
    JOIN (e
    WHERE (ct_data->encntr[e.seq].child_table=ct_data->trigger[d.seq].child_table))
   DETAIL
    ct_data->encntr[e.seq].exclude_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_triggers ut,
    (dummyt d  WITH seq = value(size(ct_data->trigger,5)))
   PLAN (d
    WHERE (ct_data->trigger[d.seq].child_table=patstring(ct_i_value))
     AND (ct_data->trigger[d.seq].parent_table > " "))
    JOIN (ut
    WHERE (ut.table_name=ct_data->trigger[d.seq].child_table)
     AND ut.trigger_name="TRG*CMB*"
     AND substring(1,4,ut.trigger_name)="TRG_"
     AND substring(11,4,ut.trigger_name)=substring(1,4,ut.table_name))
   DETAIL
    ct_data->trigger[d.seq].drop_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (debug_ind)
  CALL echorecord(ct_data)
 ENDIF
 IF (currdb="ORACLE")
  SET ct_drop_cnt = size(ct_data->trigger,5)
  FOR (ct_drop_i = 1 TO ct_drop_cnt)
    IF ((ct_data->trigger[ct_drop_i].drop_ind=1))
     CALL parser(concat("rdb drop trigger ",ct_data->trigger[ct_drop_i].name," go"),1)
     SET ct_exists_flag = ct_exists(ct_data->trigger[ct_drop_i].name)
     IF (ct_exists_flag=0)
      IF (ct_i_wildcard_ind=0)
       SET ct_error->message = concat(ct_error->message,"drop trigger ",trim(ct_data->trigger[
         ct_drop_i].name,3)," :: ")
      ENDIF
      IF (debug_ind)
       CALL echo(concat("*** drop trigger:",ct_data->trigger[ct_drop_i].name))
      ENDIF
     ELSEIF (ct_exists_flag IN (1, 2))
      CALL ct_kick(concat("Unable to drop trigger ",ct_data->trigger[ct_drop_i].name))
     ENDIF
    ENDIF
  ENDFOR
  SET ct_cnt = size(ct_data->person,5)
  SET ct_person_cnt = ct_cnt
  FOR (ct_i = 1 TO ct_cnt)
    SET ct_type_flag = ct_type("PERSON",ct_data->person[ct_i].child_table)
    IF (ct_type_flag=ct_null)
     SET ct_data->person[ct_i].exclude_ind = 1
    ENDIF
    IF ((ct_data->person[ct_i].exclude_ind != 1))
     SET ct_str->str = "before"
     IF (ct_type_flag IN (ct_default, ct_null))
      SET ct_str->str = "after"
     ENDIF
     CALL ct_push(concat("create or replace trigger ",trim(ct_data->person[ct_i].trigger_name)," ",
       ct_str->str))
     CALL ct_push(concat("  update or insert on ",ct_data->person[ct_i].child_table," for each row"))
     SET ct_str->str = trim(ct_data->person[ct_i].child_column)
     IF (ct_type_flag IN (ct_auto, ct_default))
      SET ct_type_text = "AUTOMATIC"
      IF ((ct_data->person[ct_i].special=1))
       CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0 "," and new.",
         ct_data->person[ct_i].parent_entity_name,
         " = 'PERSON'"," and new.updt_task != 100102 ",
         " and (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO'))"))
      ELSE
       CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column,
         " > 0 and new.updt_task != 100102",
         " and (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO'))"))
      ENDIF
      CALL ct_push(" declare")
      CALL ct_push("  npi number;")
      CALL ct_push("  ci number;")
      CALL ct_push("  eci number;")
      CALL ct_push("  cpi number;")
      CALL ct_push("  str varchar2(255);")
      CALL ct_push("  cmb_action number;")
      CALL ct_push("  active_status number;")
      CALL ct_push("  done number;")
      CALL ct_push("  spi number;")
      CALL ct_push(" begin")
      CALL ct_push(concat("  if inserting or updating('",ct_str->str,"') then"))
      CALL ct_push(concat("      -- CALL THE PROCEDURE TO CHECK TO SEE IF THE ",ct_str->str,
        " HAS BEEN COMBINED AWAY."))
      CALL ct_push(concat("      DM_CMB_FIND_PERSON2 (:NEW.",ct_str->str,", npi, ci);"))
      CALL ct_push(concat("      -- CHECK TO SEE IF THE ",ct_str->str," HAS BEEN COMBINED AWAY."))
      CALL ct_push("      if npi is null then")
      CALL ct_push("        -- THE PERSON HAS NOT BEEN COMBINED AWAY EXIT THE TRIGGER.")
      CALL ct_push("        null;")
      CALL ct_push("      else")
      CALL ct_push(concat("        -- FOUND A ",ct_str->str," THAT THE NEW ",ct_str->str,
        " HAS BEEN CHANGED TO "))
      IF (ct_type_flag=ct_default)
       IF (debug_ind)
        CALL echo(concat("*** Default person trigger commands set on:",ct_data->person[ct_i].
          child_table))
       ENDIF
       CALL ct_push("        -- Raise an error")
       CALL ct_push(concat("        str:= '",ct_str->str," ' || to_char(:new.",ct_str->str,") ||"))
       CALL ct_push(concat("              ' is or has been combined to a new ",ct_str->str," of ' ||"
         ))
       CALL ct_push("              to_char(npi) || '. This transaction will be rolled back.';")
       CALL ct_push("              raise_application_error(-20500,str);")
      ENDIF
      IF (ct_type_flag=ct_auto)
       CALL ct_push(concat("        -- Set new.",ct_str->str," equal to found ",ct_str->str))
       CALL ct_push(concat("        :new.",ct_str->str," := npi;"))
      ENDIF
      CALL ct_push("      end if; -- if npi is null")
      IF (size(trim(ct_data->person[ct_i].encntr_col,3)))
       CALL ct_push(concat("    if :new.",ct_data->person[ct_i].encntr_col," > 0 then"))
       CALL ct_push("        begin")
       CALL ct_push("          eci := 0;")
       CALL ct_push("          select pc.person_combine_id into eci")
       CALL ct_push("          from (select c.person_combine_id from person_combine c")
       CALL ct_push(concat("          where c.encntr_id = :new.",ct_data->person[ct_i].encntr_col))
       CALL ct_push("          and c.active_ind = 1")
       CALL ct_push("          order by c.updt_dt_tm desc) pc")
       CALL ct_push("          where rownum = 1;")
       CALL ct_push("         if eci > 0 then ")
       CALL ct_push("            cpi := 0;")
       IF ((ct_data->person[ct_i].child_table="ENCOUNTER"))
        CALL ct_push("           select c.to_person_id into cpi")
        CALL ct_push("           from person_combine c")
        CALL ct_push("           where c.person_combine_id = eci;")
        CALL ct_push("           if (cpi > 0) then")
        CALL ct_push("             DM_CMB_FIND_PERSON2(cpi, npi, eci);")
        CALL ct_push("             if (npi is not null) then")
        CALL ct_push("               cpi := npi;")
        CALL ct_push("             end if;")
        CALL ct_push("           end if;")
       ELSE
        CALL ct_push("           select e.person_id into cpi")
        CALL ct_push("      	    from encounter e")
        CALL ct_push(concat("           where e.encntr_id = :new.",ct_data->person[ct_i].encntr_col))
        CALL ct_push("      	    and e.active_ind = 1;")
       ENDIF
       CALL ct_push(concat("          if cpi > 0 and :new.",ct_str->str," != cpi then"))
       CALL ct_push(concat("            str:='ENCOUNTER ID ' || to_char(:new.",ct_data->person[ct_i].
         encntr_col,") || "))
       CALL ct_push("                   ' has been moved to a new person with an ID of ' ||")
       CALL ct_push("                   to_char(cpi) || '. This transaction will be rolled back.';")
       CALL ct_push("              raise_application_error(-20500,str);")
       CALL ct_push("            end if;")
       CALL ct_push("          end if; -- if eci > 0")
       CALL ct_push("        exception")
       CALL ct_push("    	    when no_data_found then")
       CALL ct_push("    	      null;")
       CALL ct_push("        end;")
       CALL ct_push(concat("      end if; -- if :new.",ct_data->person[ct_i].encntr_col," > 0"))
      ENDIF
      IF (ct_type_flag=ct_auto)
       IF (debug_ind)
        CALL echo(concat("*** Auto person trigger commands set on:",ct_data->person[ct_i].child_table
          ))
       ENDIF
       CALL ct_push("    if npi is not null then")
       CALL ct_push("    select c.code_value into cmb_action")
       CALL ct_push("      from code_value c")
       CALL ct_push("     where c.cdf_meaning = 'UPT'")
       CALL ct_push("       and c.code_set   = 327")
       CALL ct_push("       and c.active_ind = 1")
       CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
       CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
       CALL ct_push("    select c.code_value into active_status")
       CALL ct_push("      from code_value c")
       CALL ct_push("     where c.cdf_meaning = 'ACTIVE'")
       CALL ct_push("       and c.code_set   = 48")
       CALL ct_push("       and c.active_ind = 1")
       CALL ct_push("       and c.begin_effective_dt_tm <= sysdate")
       CALL ct_push("       and c.end_effective_dt_tm >= sysdate;")
       CALL ct_push("    insert into person_combine_det")
       CALL ct_push("      (person_combine_det_id, person_combine_id,")
       CALL ct_push("       updt_cnt, updt_dt_tm, updt_id, updt_task, updt_applctx,")
       CALL ct_push(
        "       active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id,")
       CALL ct_push("       entity_name, entity_id,")
       CALL ct_push("       combine_action_cd, attribute_name,")
       CALL ct_push("       prev_active_ind, prev_active_status_cd, prev_end_eff_dt_tm,")
       CALL ct_push("       combine_desc_cd, to_record_ind)")
       CALL ct_push("    values")
       CALL ct_push("      (person_combine_seq.nextval, ci,")
       CALL ct_push("       0, sysdate, 0, 0, 0,")
       CALL ct_push("       1, active_status, sysdate, 0,")
       CALL ct_push(concat("       '",ct_data->person[ct_i].child_table,"', :new.",ct_data->person[
         ct_i].child_pk,","))
       CALL ct_push(concat("     cmb_action, '",ct_data->person[ct_i].child_column,"',"))
       CALL ct_push("       0, 0, null,")
       CALL ct_push("       0, 0);")
       CALL ct_push("    end if; -- if npi is not null")
      ENDIF
      CALL ct_push("  end if; -- if inserting or updating")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
     ELSEIF (ct_type_flag=ct_null)
      IF (debug_ind)
       CALL echo(concat("*** Null person trigger commands set on:",ct_data->person[ct_i].child_table)
        )
      ENDIF
      SET ct_type_text = "NULL"
      CALL ct_push(" when (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO')")
      CALL ct_push(" begin")
     ENDIF
     CALL ct_push("  null;")
     CALL ct_push("end;")
     CALL ct_run(0)
     SET ct_exists_flag = ct_exists(ct_data->person[ct_i].trigger_name)
     IF (ct_exists_flag IN (0, 2))
      IF (ct_exists_flag=0)
       CALL ct_kick(concat("Unable to build ",trim(ct_type_text)," trigger (",ct_data->person[ct_i].
         trigger_name,")."))
      ELSE
       CALL ct_kick(concat("Trigger ",ct_data->person[ct_i].trigger_name,
         " does not have an ENABLED status."))
      ENDIF
     ELSEIF (ct_exists_flag=1)
      IF (ct_i_wildcard_ind=0)
       SET ct_error->message = concat(ct_error->message,"create trigger ",trim(ct_data->person[ct_i].
         trigger_name,3)," :: ")
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  SET ct_cnt = size(ct_data->encntr,5)
  SET ct_encntr_cnt = ct_cnt
  FOR (ct_i = 1 TO ct_cnt)
    SET ct_type_flag = ct_type("ENCOUNTER",ct_data->encntr[ct_i].child_table)
    IF (ct_type_flag=ct_null)
     SET ct_data->encntr[ct_i].exclude_ind = 1
    ENDIF
    IF ((ct_data->encntr[ct_i].exclude_ind != 1))
     SET ct_str->str = "before"
     IF (ct_type_flag IN (ct_default, ct_null))
      SET ct_str->str = "after"
     ENDIF
     CALL ct_push(concat("create or replace trigger ",ct_data->encntr[ct_i].trigger_name," ",ct_str->
       str))
     CALL ct_push(concat("  update or insert on ",ct_data->encntr[ct_i].child_table," for each row"))
     SET ct_str->str = ct_data->encntr[ct_i].child_column
     IF (ct_type_flag IN (ct_auto, ct_default))
      SET ct_type_text = "AUTOMATIC"
      CALL ct_push(concat("  when (new.",ct_data->encntr[ct_i].child_column," > 0",
        " and new.updt_task != 100102",
        " and (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO'))"))
      CALL ct_push("declare")
      CALL ct_push("  nei number;")
      CALL ct_push("  c_id number;")
      CASE (ct_type_flag)
       OF ct_default:
        CALL ct_push("  str varchar2(255);")
        CALL ct_push("  done number;")
        CALL ct_push("  sei number;")
       OF ct_auto:
        CALL ct_push("  n_id2 number;")
        CALL ct_push("  c_id2 number;")
        CALL ct_push("  cmb_action number;")
        CALL ct_push("  active_status number;")
      ENDCASE
      CALL ct_push("begin")
      CALL ct_push(concat("  if inserting or updating('",ct_str->str,"') then"))
      CALL ct_push(
       "    -- CALL THE PROCEDURE TO CHECK TO SEE IF THE ENCNTR_ID HAS BEEN COMBINED AWAY.")
      CALL ct_push(concat("    DM_CMB_FIND_ENCOUNTER2 (:NEW.",ct_str->str,", nei, c_id);"))
      CALL ct_push(concat("    -- CHECK TO SEE IF THE ",ct_str->str," HAS BEEN COMBINED AWAY."))
      CALL ct_push("    if nei is null then")
      CALL ct_push("      -- THE ENCNTR HAS NOT BEEN COMBINED AWAY EXIT THE TRIGGER.")
      CALL ct_push("      null;")
      CALL ct_push("    else")
      CASE (ct_type_flag)
       OF ct_default:
        IF (debug_ind)
         CALL echo(concat("Default encounter trigger commands set on:",ct_data->encntr[ct_i].
           child_table))
        ENDIF
        CALL ct_push(concat("      -- FOUND AN ",ct_str->str," THAT THE NEW ",ct_str->str,
          " HAS BEEN CHANGED TO"))
        CALL ct_push("      -- Raise an error")
        CALL ct_push(concat("      str:= '",ct_str->str," ' || to_char(:new.",ct_str->str,") ||"))
        CALL ct_push(concat("            ' is or has been combined to a new ",ct_str->str," of ' ||")
         )
        CALL ct_push("            to_char(nei) || '. This transaction will be rolled back.';")
        CALL ct_push("            raise_application_error(-20500,str);")
       OF ct_auto:
        IF (debug_ind)
         CALL echo(concat("*** Auto encounter trigger commands set on:",ct_data->encntr[ct_i].
           child_table))
        ENDIF
        CALL ct_push("      select c.code_value into cmb_action")
        CALL ct_push("      from code_value c")
        CALL ct_push("      where c.cdf_meaning = 'UPT'")
        CALL ct_push("      and c.code_set   = 327")
        CALL ct_push("      and c.active_ind = 1")
        CALL ct_push("      and c.begin_effective_dt_tm <= sysdate")
        CALL ct_push("      and c.end_effective_dt_tm >= sysdate;")
        CALL ct_push("      select c.code_value into active_status")
        CALL ct_push("      from code_value c")
        CALL ct_push("      where c.cdf_meaning = 'ACTIVE'")
        CALL ct_push("      and c.code_set   = 48")
        CALL ct_push("      and c.active_ind = 1")
        CALL ct_push("      and c.begin_effective_dt_tm <= sysdate")
        CALL ct_push("      and c.end_effective_dt_tm >= sysdate;")
        CALL ct_push("      insert into encntr_combine_det")
        CALL ct_push("      (encntr_combine_det_id, encntr_combine_id,")
        CALL ct_push("      updt_cnt, updt_dt_tm, updt_id, updt_task, updt_applctx,")
        CALL ct_push(
         "      active_ind, active_status_cd, active_status_dt_tm, active_status_prsnl_id,")
        CALL ct_push("      entity_name, entity_id,")
        CALL ct_push("      combine_action_cd, attribute_name,")
        CALL ct_push("      prev_active_ind, prev_active_status_cd, prev_end_eff_dt_tm,")
        CALL ct_push("      combine_desc_cd, to_record_ind)")
        CALL ct_push("      values")
        CALL ct_push("      (encounter_combine_seq.nextval, c_id,")
        CALL ct_push("      0, sysdate, 0, 0, 0,")
        CALL ct_push("      1, active_status, sysdate, 0,")
        CALL ct_push("      -- The child table name and the primary key column inserted here")
        CALL ct_push(concat("       '",ct_data->encntr[ct_i].child_table,"', :new.",ct_data->encntr[
          ct_i].child_pk,","))
        CALL ct_push(
         "      -- The combine_action code and the child combine column name inserted here")
        CALL ct_push(concat("      cmb_action, '",ct_str->str,"',"))
        CALL ct_push("      0, 0, null,")
        CALL ct_push("      0, 0);")
        CALL ct_push("      -- FOUND A ENCNTR_ID THAT THE NEW ENCNTR_ID HAS BEEN CHANGED TO	")
        CALL ct_push("      -- Set new.ENCNTR_ID equal to the found ENCNTR_ID")
        CALL ct_push(concat("      :new.",ct_str->str," := nei;"))
      ENDCASE
      CALL ct_push("      end if; -- if nei is null")
      CALL ct_push("    end if; -- if inserting or updating")
      CALL ct_push("exception")
      CALL ct_push("  when no_data_found then")
     ELSE
      IF (debug_ind)
       CALL echo(concat("*** Null encounter commands set on:",ct_data->encntr[ct_i].child_table))
      ENDIF
      SET ct_type_text = "NULL"
      CALL ct_push(" when (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO')")
      CALL ct_push("begin")
     ENDIF
     CALL ct_push("  null;")
     CALL ct_push("end;")
     CALL ct_run(0)
     SET ct_exists_flag = ct_exists(ct_data->encntr[ct_i].trigger_name)
     IF (ct_exists_flag IN (0, 2))
      IF (ct_exists_flag=0)
       CALL ct_kick(concat("Unable to build ",trim(ct_type_text)," trigger (",ct_data->encntr[ct_i].
         trigger_name,")."))
      ELSE
       CALL ct_kick(concat("Trigger ",ct_data->encntr[ct_i].trigger_name,
         " does not have an ENABLED status."))
      ENDIF
     ELSEIF (ct_exists_flag=1)
      IF (ct_i_wildcard_ind=0)
       SET ct_error->message = concat(ct_error->message,"create trigger ",trim(ct_data->encntr[ct_i].
         trigger_name,3)," :: ")
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF (currdb="DB2UDB")
  SET ct_cnt = size(ct_data->person,5)
  SET ct_person_cnt = ct_cnt
  FOR (ct_i = 1 TO ct_cnt)
    SET ct_type_flag = ct_type("PERSON",ct_data->person[ct_i].child_table)
    SET ct_str->str = "after"
    CALL ct_push(concat("create trigger ",trim(ct_data->person[ct_i].trigger_name)," ",ct_str->str))
    IF ((ct_data->person[ct_i].trigger_event="insert"))
     CALL ct_push(concat(" ",ct_data->person[ct_i].trigger_event," on ",ct_data->person[ct_i].
       suffix_child_table))
    ELSE
     CALL ct_push(concat(" ",ct_data->person[ct_i].trigger_event," of ",ct_data->person[ct_i].
       child_column))
     CALL ct_push(concat(" on ",ct_data->person[ct_i].suffix_child_table))
    ENDIF
    IF ((ct_data->person[ct_i].trigger_event="update"))
     CALL ct_push("referencing new as new old as old for each row mode db2sql")
    ELSEIF ((ct_data->person[ct_i].trigger_event="insert"))
     CALL ct_push("referencing new as new for each row mode db2sql")
    ENDIF
    SET ct_str->str = trim(ct_data->person[ct_i].child_column)
    IF ((ct_data->person[ct_i].special=1))
     CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0 "," and new.",
       ct_data->person[ct_i].parent_entity_name,
       " = 'PERSON'"," and new.updt_task != 100102) "))
    ELSEIF (ct_type_flag=ct_null)
     CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column," > 0 )"))
    ELSE
     CALL ct_push(concat("  when (new.",ct_data->person[ct_i].child_column,
       " > 0 and new.updt_task != 100102)"))
    ENDIF
    CALL ct_push("A1: begin atomic")
    IF (ct_type_flag IN (ct_auto, ct_default))
     SET ct_type_text = "AUTOMATIC"
     CALL ct_push("declare v_npi        bigint default -1;")
     CALL ct_push("declare v_ci         bigint default 0;")
     CALL ct_push("declare v_cpi        bigint default 0;")
     CALL ct_push("declare v_str        varchar(255);")
     CALL ct_push("declare v_check_person_id_in bigint;")
     CALL ct_push("declare v_hold_person_id   bigint;")
     CALL ct_push("declare v_hold_person_id2  bigint;")
     CALL ct_push("declare v_loop        int  default 1;")
     CALL ct_push("declare v_seq        int;")
     CALL ct_push("declare v_cnt        int;")
     CALL ct_push("declare v_max_updt_dt_tm   timestamp;")
     CALL ct_push(
      "declare v_max_updt_dt_tm2  timestamp default TIMESTAMP('1900-01-01-00.00.00.000000');")
     CALL ct_push("declare c_id bigint;")
     CALL ct_push("declare c_id2 bigint;")
     CALL ct_push("declare cmb_action      bigint;")
     CALL ct_push("declare active_status bigint;")
     CALL ct_push(concat("set v_check_person_id_in = new.",ct_data->person[ct_i].child_column,";"))
     IF (size(trim(ct_data->person[ct_i].encntr_col,3)))
      CALL ct_push(concat("    if (new.",ct_data->person[ct_i].encntr_col," > 0) then"))
      CALL ct_push("set v_ci = (select max(c.person_combine_id)")
      CALL ct_push("      	     from person_combine c")
      CALL ct_push(concat("     where c.encntr_id = new.",ct_data->person[ct_i].encntr_col))
      CALL ct_push("      	     and c.active_ind = 1);")
      CALL ct_push("if (v_ci > 0) then ")
      CALL ct_push("set v_cpi = ( select e.person_id")
      CALL ct_push("      	       from encounter e")
      CALL ct_push(concat("       where e.encntr_id = new.",ct_data->person[ct_i].encntr_col))
      CALL ct_push("      	       and e.active_ind = 1);")
      CALL ct_push(concat("if v_cpi > 0 and new.",ct_str->str," != v_cpi then"))
      CALL ct_push(concat("set v_str ='ENCOUNTER ID ' || rtrim(char(new.",ct_data->person[ct_i].
        encntr_col,")) || "))
      CALL ct_push("' has been moved to a new person id ' ||")
      CALL ct_push("rtrim(char(v_cpi)) || '. This transaction will be rolled back.';")
      CALL ct_push("signal sqlstate '70500' set message_text = v_str;")
      CALL ct_push("end if;")
      CALL ct_push("end if; -- if v_ci > 0")
      CALL ct_push(concat("end if; -- if :new.",ct_data->person[ct_i].encntr_col," > 0"))
     ENDIF
     CALL ct_push("set (v_hold_person_id, c_id,v_max_updt_dt_tm) = ")
     CALL ct_push("( select pc.to_person_id, pc.person_combine_id, pc.updt_dt_tm")
     CALL ct_push("  from person_combine pc, person p")
     CALL ct_push("  where p.person_id = v_check_person_id_in")
     CALL ct_push("  and p.active_ind = 0")
     CALL ct_push("  and pc.from_person_id = p.person_id")
     CALL ct_push("  and pc.encntr_id = 0")
     CALL ct_push("  and pc.active_ind = 1")
     CALL ct_push("  order by pc.updt_dt_tm desc")
     CALL ct_push("  fetch first 1 rows only);")
     CALL ct_push("if ( v_hold_person_id is null )    then")
     CALL ct_push("leave A1;")
     CALL ct_push("end if;")
     CALL ct_push("set v_hold_person_id2 = v_hold_person_id;")
     CALL ct_push("set c_id2 = c_id;")
     CALL ct_push("while ( v_loop = 1 ) do")
     CALL ct_push("set (v_hold_person_id, c_id,v_max_updt_dt_tm) = ")
     CALL ct_push("( select pc.to_person_id, pc.person_combine_id, pc.updt_dt_tm")
     CALL ct_push("from person_combine pc")
     CALL ct_push("where pc.from_person_id = v_hold_person_id2")
     CALL ct_push("and pc.encntr_id = 0")
     CALL ct_push("and pc.active_ind = 1")
     CALL ct_push("and pc.updt_dt_tm >= v_max_updt_dt_tm2")
     CALL ct_push("order by pc.updt_dt_tm desc")
     CALL ct_push("fetch first 1 rows only);")
     CALL ct_push("if ( v_hold_person_id is null )   then")
     CALL ct_push("set v_loop = 0;")
     CALL ct_push("end if;")
     CALL ct_push("if ( v_loop = 1)   then")
     CALL ct_push("set v_hold_person_id2 = v_hold_person_id;")
     CALL ct_push("set c_id2 = c_id;")
     CALL ct_push("set v_max_updt_dt_tm2 = v_max_updt_dt_tm;")
     CALL ct_push("end if;")
     CALL ct_push("end while;")
     CALL ct_push("set v_npi = v_hold_person_id2;")
     CALL ct_push("if ( v_npi = v_check_person_id_in )   then")
     CALL ct_push("leave A1;")
     CALL ct_push("end if;")
     CALL ct_push("        -- Raise an error")
     CALL ct_push(concat("      set v_str= '",ct_str->str," ' || rtrim(char(new.",ct_str->str,")) ||"
       ))
     CALL ct_push(concat("              ' is or has been combined to a new ",ct_str->str," of ' ||"))
     CALL ct_push("              rtrim(char(v_npi)) || '. This transaction will be rolled back.';")
     CALL ct_push("signal sqlstate '70500' set message_text = v_str;")
    ENDIF
    CALL ct_push("end")
    CALL ct_run(0)
    COMMIT
    SET ct_exists_flag = ct_exists(ct_data->person[ct_i].trigger_name)
    IF (ct_exists_flag IN (0, 2))
     IF (ct_exists_flag=0)
      CALL ct_kick(concat("Unable to build ",trim(ct_type_text)," trigger (",ct_data->person[ct_i].
        trigger_name,")."))
     ELSE
      CALL ct_kick(concat("Trigger ",ct_data->person[ct_i].trigger_name,
        " does not have an ENABLED status."))
     ENDIF
    ENDIF
  ENDFOR
  SET ct_cnt = size(ct_data->encntr,5)
  SET ct_encntr_cnt = ct_cnt
  FOR (ct_i = 1 TO ct_cnt)
    SET ct_type_flag = ct_type("ENCOUNTER",ct_data->encntr[ct_i].child_table)
    SET ct_str->str = "after"
    CALL ct_push(concat("create trigger ",trim(ct_data->encntr[ct_i].trigger_name)," ",ct_str->str))
    IF ((ct_data->encntr[ct_i].trigger_event="insert"))
     CALL ct_push(concat(" ",ct_data->encntr[ct_i].trigger_event," on ",ct_data->encntr[ct_i].
       suffix_child_table))
    ELSE
     CALL ct_push(concat(" ",ct_data->encntr[ct_i].trigger_event," of ",ct_data->encntr[ct_i].
       child_column))
     CALL ct_push(concat(" on ",ct_data->encntr[ct_i].suffix_child_table))
    ENDIF
    IF ((ct_data->encntr[ct_i].trigger_event="update"))
     CALL ct_push("referencing new as new old as old for each row mode db2sql")
    ELSEIF ((ct_data->encntr[ct_i].trigger_event="insert"))
     CALL ct_push("referencing new as new for each row mode db2sql")
    ENDIF
    SET ct_str->str = trim(ct_data->encntr[ct_i].child_column)
    IF (ct_type_flag=ct_null)
     CALL ct_push(concat("  when (new.",ct_data->encntr[ct_i].child_column," > 0",
       " and (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO'))"))
    ELSE
     CALL ct_push(concat("  when (new.",ct_data->encntr[ct_i].child_column,
       " > 0 and new.updt_task != 100102",
       " and (nvl(sys_context('CERNER','FIRE_CMB_TRG'),'DM2NULLVAL') != 'NO'))"))
    ENDIF
    CALL ct_push("A1: begin atomic")
    IF (ct_type_flag IN (ct_auto, ct_default))
     SET ct_type_text = "AUTOMATIC"
     CALL ct_push("declare v_npi        bigint default -1;")
     CALL ct_push("declare v_ci         bigint default 0;")
     CALL ct_push("declare v_cpi        bigint default 0;")
     CALL ct_push("declare v_str        varchar(255);")
     CALL ct_push("declare v_check_encntr_id_in bigint;")
     CALL ct_push("declare v_hold_encntr_id   bigint;")
     CALL ct_push("declare v_hold_encntr_id2  bigint;")
     CALL ct_push("declare v_loop        int  default 1;")
     CALL ct_push("declare v_seq        int;")
     CALL ct_push("declare v_cnt        int;")
     CALL ct_push("declare v_max_updt_dt_tm   timestamp;")
     CALL ct_push(
      "declare v_max_updt_dt_tm2  timestamp default TIMESTAMP('1900-01-01-00.00.00.000000');")
     CALL ct_push("declare c_id bigint;")
     CALL ct_push("declare c_id2 bigint;")
     CALL ct_push("declare cmb_action      bigint;")
     CALL ct_push("declare active_status bigint;")
     CALL ct_push(concat("set v_check_encntr_id_in = new.",ct_data->encntr[ct_i].child_column,";"))
     CALL ct_push("set (v_hold_encntr_id, c_id,v_max_updt_dt_tm) = ")
     CALL ct_push("( select ec.to_encntr_id, ec.encntr_combine_id, ec.updt_dt_tm")
     CALL ct_push("  from encntr_combine ec, encounter e")
     CALL ct_push("  where e.encntr_id = v_check_encntr_id_in")
     CALL ct_push("  and e.active_ind = 0")
     CALL ct_push("  and ec.from_encntr_id = e.encntr_id")
     CALL ct_push("  and ec.active_ind = 1")
     CALL ct_push("  order by ec.updt_dt_tm desc")
     CALL ct_push("  fetch first 1 rows only);")
     CALL ct_push("if ( v_hold_encntr_id is null )    then")
     CALL ct_push("leave A1;")
     CALL ct_push("end if;")
     CALL ct_push("set v_hold_encntr_id2 = v_hold_encntr_id;")
     CALL ct_push("set c_id2 = c_id;")
     CALL ct_push("while ( v_loop = 1 ) do")
     CALL ct_push("set (v_hold_encntr_id, c_id,v_max_updt_dt_tm) = ")
     CALL ct_push("( select ec.to_encntr_id, ec.encntr_combine_id, ec.updt_dt_tm")
     CALL ct_push("from encntr_combine ec")
     CALL ct_push("where ec.from_encntr_id = v_hold_encntr_id2")
     CALL ct_push("and ec.active_ind = 1")
     CALL ct_push("and ec.updt_dt_tm >= v_max_updt_dt_tm2")
     CALL ct_push("order by ec.updt_dt_tm desc")
     CALL ct_push("fetch first 1 rows only);")
     CALL ct_push("if ( v_hold_encntr_id is null )   then")
     CALL ct_push("set v_loop = 0;")
     CALL ct_push("end if;")
     CALL ct_push("if ( v_loop = 1)   then")
     CALL ct_push("set v_hold_encntr_id2 = v_hold_encntr_id;")
     CALL ct_push("set c_id2 = c_id;")
     CALL ct_push("set v_max_updt_dt_tm2 = v_max_updt_dt_tm;")
     CALL ct_push("end if;")
     CALL ct_push("end while;")
     CALL ct_push("set v_npi = v_hold_encntr_id2;")
     CALL ct_push("if ( v_npi = v_check_encntr_id_in )   then")
     CALL ct_push("leave A1;")
     CALL ct_push("end if;")
     CALL ct_push("        -- Raise an error")
     CALL ct_push(concat("      set v_str= '",ct_str->str," ' || rtrim(char(new.",ct_str->str,")) ||"
       ))
     CALL ct_push(concat("              ' is or has been combined to a new ",ct_str->str," of ' ||"))
     CALL ct_push("              rtrim(char(v_npi)) || '. This transaction will be rolled back.';")
     CALL ct_push("signal sqlstate '70500' set message_text = v_str;")
    ENDIF
    CALL ct_push("end")
    CALL ct_run(0)
    COMMIT
    SET ct_exists_flag = ct_exists(ct_data->encntr[ct_i].trigger_name)
    IF (ct_exists_flag IN (0, 2))
     IF (ct_exists_flag=0)
      CALL ct_kick(concat("Unable to build ",trim(ct_type_text)," trigger (",ct_data->encntr[ct_i].
        trigger_name,")."))
     ELSE
      CALL ct_kick(concat("Trigger ",ct_data->encntr[ct_i].trigger_name,
        " does not have an ENABLED status."))
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#3999_build_exit
#9999_exit_program
END GO
