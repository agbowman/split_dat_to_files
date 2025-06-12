CREATE PROGRAM dm_insert_code_value:dba
 DECLARE dilc_code_set = vc WITH protect, constant("CODE_SET")
 DECLARE dilc_code_value = vc WITH protect, constant("CODE_VALUE")
 DECLARE dilc_delimiter = c1 WITH protect, constant("~")
 DECLARE dilc_set_install_text(dsit_cs=f8,dsit_cv=f8,dsit_cvdesc=vc,dsit_cdfm=vc,dsit_display=vc,
  dsit_actind=i2) = vc
 DECLARE dilc_get_install_text(dgit_cs=f8(ref),dgit_cv=f8(ref),dgit_cvdesc=vc(ref),dgit_cdfm=vc(ref),
  dgit_display=vc(ref),
  dgit_actind=i2(ref),dgit_install_text=vc) = i2
 DECLARE dilc_insert_cs_row(disr_pkg_int=i4,disr_cs=f8,disr_cs_desc=vc) = i2
 DECLARE dilc_insert_cv_row(divr_pkg_int=i4,divr_cs=f8,divr_cv=f8,divr_desc=vc,divr_cdfm=vc,
  divr_disp=vc,divr_actind=i2) = i2
 DECLARE dilc_check_oil_column(null) = i2
 SUBROUTINE dilc_insert_cs_row(disr_pkg_int,disr_cs,disr_cs_desc)
   DECLARE disr_log_id = f8 WITH protect, noconstant(0.00)
   SELECT INTO "nl:"
    y = seq(dm_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     disr_log_id = y
    WITH nocounter
   ;end select
   INSERT  FROM ocd_install_log l
    SET l.log_id = disr_log_id, l.install_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd =
     disr_pkg_int,
     l.component_type = dilc_code_set, l.end_state = trim(format(disr_cs,";;I"),3), l.update_ind = 0,
     l.install_text = disr_cs_desc
    WITH nocounter
   ;end insert
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dilc_insert_cv_row(divr_pkg_int,divr_cs,divr_cv,divr_desc,divr_cdfm,divr_disp,divr_actind
  )
   DECLARE divr_cv_log_id = f8 WITH protect, noconstant(0.00)
   DECLARE divr_install_text = vc WITH protect, noconstant("NOT_SET")
   DECLARE divr_end_state = vc WITH protect, noconstant("NOT_SET")
   SET divr_install_text = dilc_set_install_text(divr_cs,divr_cv,divr_desc,divr_cdfm,divr_disp,
    divr_actind)
   SET divr_end_state = trim(format(divr_cv,";;I"),3)
   SELECT INTO "nl:"
    y = seq(dm_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     divr_cv_log_id = y
    WITH nocounter
   ;end select
   INSERT  FROM ocd_install_log l
    SET l.log_id = divr_cv_log_id, l.install_dt_tm = cnvtdatetime(curdate,curtime3), l.ocd =
     divr_pkg_int,
     l.component_type = dilc_code_value, l.end_state = divr_end_state, l.update_ind = 0,
     l.install_text = divr_install_text
    WITH nocounter
   ;end insert
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dilc_set_install_text(dsit_cs,dsit_cv,dsit_cvdesc,dsit_cdfm,dsit_display,dsit_actind)
   RETURN(build(dsit_cs,dilc_delimiter,dsit_cv,dilc_delimiter,check(dsit_cvdesc),
    dilc_delimiter,check(dsit_cdfm),dilc_delimiter,check(dsit_display),dilc_delimiter,
    dsit_actind))
 END ;Subroutine
 SUBROUTINE dilc_get_install_text(dgit_cs,dgit_cv,dgit_cvdesc,dgit_cdfm,dgit_display,dgit_actind,
  dgit_install_text)
   DECLARE dgit_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgit_cv_pos = i4 WITH protect, noconstant(0)
   DECLARE dgit_cvdesc_pos = i4 WITH protect, noconstant(0)
   DECLARE dgit_cdfm_pos = i4 WITH protect, noconstant(0)
   DECLARE dgit_disp_pos = i4 WITH protect, noconstant(0)
   SET dgit_cs_pos = findstring(dilc_delimiter,dgit_install_text,1,0)
   SET dgit_cs = cnvtreal(substring(1,(dgit_cs_pos - 1),dgit_install_text))
   SET dgit_cv_pos = findstring(dilc_delimiter,dgit_install_text,(dgit_cs_pos+ 1),0)
   SET dgit_cv = cnvtreal(substring((dgit_cs_pos+ 1),((dgit_cv_pos - 1) - dgit_cs_pos),
     dgit_install_text))
   SET dgit_cvdesc_pos = findstring(dilc_delimiter,dgit_install_text,(dgit_cv_pos+ 1),0)
   IF (((dgit_cvdesc_pos - dgit_cv_pos) > 1))
    SET dgit_cvdesc = substring((dgit_cv_pos+ 1),((dgit_cvdesc_pos - 1) - dgit_cv_pos),
     dgit_install_text)
   ELSE
    SET dgit_cvdesc = ""
   ENDIF
   SET dgit_cdfm_pos = findstring(dilc_delimiter,dgit_install_text,(dgit_cvdesc_pos+ 1),0)
   IF (((dgit_cdfm_pos - dgit_cvdesc_pos) > 1))
    SET dgit_cdfm = substring((dgit_cvdesc_pos+ 1),((dgit_cdfm_pos - 1) - dgit_cvdesc_pos),
     dgit_install_text)
   ELSE
    SET dgit_cdfm = ""
   ENDIF
   SET dgit_disp_pos = findstring(dilc_delimiter,dgit_install_text,(dgit_cdfm_pos+ 1),0)
   IF (((dgit_disp_pos - dgit_cdfm_pos) > 1))
    SET dgit_display = substring((dgit_cdfm_pos+ 1),((dgit_disp_pos - 1) - dgit_cdfm_pos),
     dgit_install_text)
   ELSE
    SET dgit_display = ""
   ENDIF
   SET dgit_actind = cnvtint(substring((dgit_disp_pos+ 1),1,dgit_install_text))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dilc_check_oil_column(null)
   SELECT INTO "nl:"
    utc.table_name, utc.column_name
    FROM dba_tab_columns utc
    WHERE utc.table_name="OCD_INSTALL_LOG"
     AND utc.column_name="INSTALL_TEXT"
     AND utc.owner="V500"
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
   IF (checkdic(concat("OCD_INSTALL_LOG",".","INSTALL_TEXT"),"A",0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE cv_pkg_nbr = i4 WITH protect, noconstant(0)
 DECLARE cv_pkg_ind = i2 WITH protect, noconstant(0)
 DECLARE cv_new_cs_ind = i2 WITH protect, noconstant(0)
 DECLARE cv_tmp_smallint = i2 WITH protect, noconstant(0)
 DECLARE cv_oil_column_ind = i2 WITH protect, noconstant(0)
 DECLARE new_description = vc WITH protect, noconstant(" ")
 DECLARE try_again_ind = i2 WITH protect, noconstant(1)
 DECLARE attempt_nbr = i4 WITH protect, noconstant(1)
 DECLARE check_rdds_error(cre_code_value=f8(ref)) = i2
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET def_dup_rule_flag = 0
 SET display_key_dup_ind = 1
 SET display_dup_ind = 1
 SET definition_dup_ind = 0
 SET def_dup_found_ind = 0
 SET cdf_meaning_dup_ind = 0
 SET active_ind_dup_ind = 0
 SET alias_dup_ind = 0
 SET updt_id = reqinfo->updt_id
 SET updt_task = reqinfo->updt_task
 SET updt_applctx = reqinfo->updt_applctx
 SET dkey = cnvtupper(cnvtalphanum(dmrequest->display))
 SET authentic_cd = 0.00
 SET unauthentic_cd = 0.00
 SET authcnt = 0
 SET activecnt = 0
 SET active_cd = 0.00
 SET inactive_cd = 0.00
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=48
   AND c.display_key IN ("ACTIVE", "INACTIVE")
  ORDER BY c.display_key
  DETAIL
   IF (activecnt=0)
    active_cd = c.code_value, activecnt = 1
   ELSE
    inactive_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
  ORDER BY c.cdf_meaning
  DETAIL
   IF (authcnt=0)
    authentic_cd = c.code_value, authcnt = 1
   ELSE
    unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (validate(dmrequest->contributor_source_display,"ZZZ") != "ZZZ")
  SELECT INTO "nl:"
   FROM code_value a
   WHERE a.code_set=73
    AND (a.display=dmrequest->contributor_source_display)
   DETAIL
    dmrequest->contributor_source_cd = a.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(anumber,0) != 0
  AND validate(anumber,1) != 1
  AND validate(call_script,"NOT_SET") != "DM_OCD_MENU")
  SET cv_oil_column_ind = dilc_check_oil_column(null)
  IF (cv_oil_column_ind=1)
   SET cv_pkg_ind = 1
   SET cv_pkg_nbr = anumber
   SELECT INTO "nl:"
    FROM ocd_install_log o
    WHERE o.component_type=dilc_code_set
     AND o.end_state=trim(format(dmrequest->code_set,";;I"),3)
     AND o.ocd=cv_pkg_nbr
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET cv_new_cs_ind = 1
   ENDIF
  ENDIF
 ENDIF
 SET new_code_value = 0.0
 SET new_definition = fillstring(100," ")
 SET exist_cki = fillstring(30," ")
 SET new_active_ind = 0
 SELECT INTO "nl:"
  a.code_value, a.definition, a.description,
  a.active_ind
  FROM code_value a
  WHERE (a.cki=dmrequest->cki)
  DETAIL
   new_code_value = a.code_value, new_definition = a.definition, new_description = a.description,
   new_active_ind = a.active_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  RANGE OF cvs IS code_value_set
  IF (evaluate(validate(cvs.definition_dup_ind,- (999999)),- (999999),0,1))
   SET def_dup_found_ind = 1
  ENDIF
  FREE RANGE cvs
  IF (def_dup_found_ind=1)
   SELECT INTO "nl:"
    cvs.def_dup_rule_flag, cvs.display_key_dup_ind, cvs.display_dup_ind,
    cvs.definition_dup_ind, cvs.cdf_meaning_dup_ind, cvs.active_ind_dup_ind,
    cvs.alias_dup_ind
    FROM code_value_set cvs
    WHERE (cvs.code_set=dmrequest->code_set)
    DETAIL
     def_dup_rule_flag =
     IF ((dmrequest->dup_rule_flag=0)) cvs.def_dup_rule_flag
     ELSE dmrequest->dup_rule_flag
     ENDIF
     , display_key_dup_ind = cvs.display_key_dup_ind, display_dup_ind = cvs.display_dup_ind,
     definition_dup_ind = cvs.definition_dup_ind, cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind,
     active_ind_dup_ind = cvs.active_ind_dup_ind,
     alias_dup_ind = cvs.alias_dup_ind
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    cvs.def_dup_rule_flag, cvs.display_key_dup_ind, cvs.display_dup_ind,
    cvs.cdf_meaning_dup_ind, cvs.active_ind_dup_ind, cvs.alias_dup_ind
    FROM code_value_set cvs
    WHERE (cvs.code_set=dmrequest->code_set)
    DETAIL
     def_dup_rule_flag =
     IF ((dmrequest->dup_rule_flag=0)) cvs.def_dup_rule_flag
     ELSE dmrequest->dup_rule_flag
     ENDIF
     , display_key_dup_ind = cvs.display_key_dup_ind, display_dup_ind = cvs.display_dup_ind,
     cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, active_ind_dup_ind = cvs.active_ind_dup_ind,
     alias_dup_ind = cvs.alias_dup_ind
    WITH nocounter
   ;end select
  ENDIF
  SET parser_buffer[20] = fillstring(132," ")
  SET parser_number = 0
  SET parser_buffer[1] = 'select into "nl:" c.*'
  IF (alias_dup_ind=1
   AND (dmrequest->contributor_source_cd > 0))
   SET parser_buffer[2] = "from code_value c, code_value_alias cva"
   SET parser_buffer[3] = "plan c where c.code_set = dmrequest->code_set"
  ELSE
   SET parser_buffer[2] = "from code_value c"
   SET parser_buffer[3] = "where c.code_set = dmrequest->code_set"
  ENDIF
  SET parser_number = 3
  IF (display_key_dup_ind=1)
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  and c.display_key = dkey"
  ENDIF
  IF (display_dup_ind=1)
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  and c.display = dmrequest->display"
  ENDIF
  IF (definition_dup_ind=1)
   IF ((dmrequest->definition > " "))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.definition = dmrequest->definition"
   ELSE
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.definition = NULL"
   ENDIF
  ENDIF
  IF (cdf_meaning_dup_ind=1)
   IF ((dmrequest->cdf_meaning > " "))
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] =
    "  and cnvtupper(c.cdf_meaning) = cnvtupper(dmrequest->cdf_meaning)"
   ELSE
    SET parser_number = (parser_number+ 1)
    SET parser_buffer[parser_number] = "  and c.cdf_meaning = NULL"
   ENDIF
  ENDIF
  IF (active_ind_dup_ind=1)
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  and c.active_ind = dmrequest->active_ind"
  ENDIF
  IF (display_dup_ind=0
   AND display_key_dup_ind=0
   AND cdf_meaning_dup_ind=0
   AND alias_dup_ind=0
   AND active_ind_dup_ind=0)
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "  and c.display = dmrequest->display"
  ENDIF
  IF (alias_dup_ind=1
   AND (dmrequest->contributor_source_cd > 0))
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = "join cva where cva.code_value=c.code_value"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] =
   " and cva.contributor_source_cd=dmrequest->contributor_source_cd"
   SET parser_number = (parser_number+ 1)
   SET parser_buffer[parser_number] = " and cva.alias=dmrequest->alias"
  ENDIF
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "detail"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "  exist_cki = c.cki"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "  new_code_value = c.code_value"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "  new_definition = c.definition"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "  new_description = c.description"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = " new_active_ind = c.active_ind"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = " with nocounter go"
  FOR (z = 1 TO parser_number)
    CALL parser(parser_buffer[z],1)
  ENDFOR
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   xyz = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_code_value = cnvtreal(xyz)
   WITH format, nocounter
  ;end select
  WHILE (try_again_ind=1
   AND attempt_nbr <= 2)
    SET try_again_ind = 0
    INSERT  FROM code_value c
     SET c.code_value = new_code_value, c.code_set = dmrequest->code_set, c.cdf_meaning =
      IF (trim(dmrequest->cdf_meaning) != null) cnvtupper(dmrequest->cdf_meaning)
      ELSE null
      ENDIF
      ,
      c.cki =
      IF (trim(dmrequest->cki) != null) dmrequest->cki
      ELSE null
      ENDIF
      , c.display = dmrequest->display, c.display_key = dkey,
      c.description = dmrequest->description, c.definition = dmrequest->definition, c.collation_seq
       = dmrequest->collation_seq,
      c.active_ind = dmrequest->active_ind, c.active_type_cd =
      IF ((dmrequest->active_ind=1)) active_cd
      ELSE inactive_cd
      ENDIF
      , c.data_status_cd = authentic_cd,
      c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), c.updt_id = updt_id,
      c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
     WITH nocounter
    ;end insert
    IF (check_rdds_error(new_code_value)=1)
     SET try_again_ind = 1
     SET attempt_nbr = (attempt_nbr+ 1)
    ENDIF
  ENDWHILE
  IF (cv_pkg_ind=1
   AND cv_new_cs_ind=0
   AND cv_oil_column_ind=1)
   SET cv_tmp_smallint = dilc_insert_cv_row(cv_pkg_nbr,dmrequest->code_set,new_code_value,dmrequest->
    description,cnvtupper(dmrequest->cdf_meaning),
    dmrequest->display,dmrequest->active_ind)
  ENDIF
 ELSE
  IF ((dmrequest->cki != exist_cki))
   IF (trim(exist_cki)=null)
    UPDATE  FROM code_value c
     SET c.code_set = dmrequest->code_set, c.cki = dmrequest->cki, c.description =
      IF (trim(new_description)="") dmrequest->description
      ELSE new_description
      ENDIF
      ,
      c.definition =
      IF (new_definition=" ") dmrequest->definition
      ELSE new_definition
      ENDIF
      , c.data_status_cd = authentic_cd, c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      c.updt_id = updt_id, c.updt_cnt = 0, c.updt_task = updt_task,
      c.updt_applctx = updt_applctx
     WHERE c.code_value=new_code_value
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL text("Update Failed")
     SET reply->status_data.status = "Z"
    ENDIF
   ELSE
    SELECT INTO "nl:"
     xyz = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_code_value = cnvtreal(xyz)
     WITH format, nocounter
    ;end select
    WHILE (try_again_ind=1
     AND attempt_nbr <= 2)
      SET try_again_ind = 0
      INSERT  FROM code_value c
       SET c.code_value = new_code_value, c.code_set = dmrequest->code_set, c.cdf_meaning =
        IF (trim(dmrequest->cdf_meaning) != null) cnvtupper(dmrequest->cdf_meaning)
        ELSE null
        ENDIF
        ,
        c.cki =
        IF (trim(dmrequest->cki) != null) dmrequest->cki
        ELSE null
        ENDIF
        , c.display = dmrequest->display, c.display_key = dkey,
        c.description = dmrequest->description, c.definition = dmrequest->definition, c.collation_seq
         = dmrequest->collation_seq,
        c.active_ind = dmrequest->active_ind, c.active_type_cd =
        IF ((dmrequest->active_ind=1)) active_cd
        ELSE inactive_cd
        ENDIF
        , c.data_status_cd = authentic_cd,
        c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), c.updt_id = updt_id,
        c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
       WITH nocounter
      ;end insert
      IF (check_rdds_error(new_code_value)=1)
       SET try_again_ind = 1
       SET attempt_nbr = (attempt_nbr+ 1)
      ENDIF
    ENDWHILE
    IF (cv_pkg_ind=1
     AND cv_new_cs_ind=0
     AND cv_oil_column_ind=1)
     SET cv_tmp_smallint = dilc_insert_cv_row(cv_pkg_nbr,dmrequest->code_set,new_code_value,dmrequest
      ->description,cnvtupper(dmrequest->cdf_meaning),
      dmrequest->display,dmrequest->active_ind)
    ENDIF
   ENDIF
  ELSE
   UPDATE  FROM code_value c
    SET c.code_set = dmrequest->code_set, c.description =
     IF (trim(new_description)="") dmrequest->description
     ELSE new_description
     ENDIF
     , c.definition =
     IF (new_definition=" ") dmrequest->definition
     ELSE new_definition
     ENDIF
     ,
     c.data_status_cd = authentic_cd, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id =
     updt_id,
     c.updt_cnt = 0, c.updt_task = updt_task, c.updt_applctx = updt_applctx
    WHERE c.code_value=new_code_value
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL text("Update Failed")
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
 SUBROUTINE check_rdds_error(cre_code_value)
   DECLARE cv_seq = vc WITH protect, noconstant("")
   DECLARE cv_seq_len = i4 WITH protect, noconstant(0)
   DECLARE ccl_error = i4 WITH protect, noconstant(0)
   DECLARE error_msg = vc WITH protect, noconstant("")
   SET ccl_error = error(error_msg,0)
   IF (ccl_error != 0)
    IF (findstring("ORA-20202",error_msg) > 0)
     SET cv_seq_len = (findstring(")",error_msg,1,1) - (findstring("(",error_msg,1,1)+ 1))
     SET cv_seq = substring((findstring("(",error_msg,1,1)+ 1),cv_seq_len,error_msg)
     IF (isnumeric(cv_seq) > 0)
      SET ccl_error = error(error_msg,1)
      CALL echo("The '-20202 Uptime RDDS' error can be ignored. The code value will be re-inserted")
      SET cre_code_value = cnvtreal(cv_seq)
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
END GO
