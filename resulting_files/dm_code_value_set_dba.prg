CREATE PROGRAM dm_code_value_set:dba
 DECLARE cs_log_id = f8 WITH protect, noconstant(0.00)
 DECLARE cs_pkg_nbr = i4 WITH protect, noconstant(0)
 DECLARE cs_pkg_ind = i2 WITH protect, noconstant(0)
 DECLARE cs_tmp_smallint = i2 WITH protect, noconstant(0)
 DECLARE cs_oil_column_ind = i2 WITH protect, noconstant(0)
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET display_key = cnvtupper(cnvtalphanum(dmrequest->display))
 SET extension_ind = 0
 SET definition_ind = 0
 SET definition_rec_ind = 0
 RANGE OF cvs IS code_value_set
 IF (evaluate(validate(cvs.definition_dup_ind,- (999999)),- (999999),0,1))
  SET definition_ind = 1
 ENDIF
 IF ((validate(dmrequest->definition_dup_ind,- (999999)) != - (999999)))
  SET definition_rec_ind = 1
 ENDIF
 IF (validate(anumber,0) != 0
  AND validate(anumber,1) != 1
  AND validate(call_script,"NOT_SET") != "DM_OCD_MENU")
  SET cs_pkg_ind = 1
  SET cs_pkg_nbr = anumber
  SET cs_oil_column_ind = dilc_check_oil_column(null)
 ENDIF
 SELECT INTO "nl:"
  y = count(*)
  FROM code_set_extension cse
  WHERE (cse.code_set=dmrequest->code_set)
  DETAIL
   extension_ind = y
  WITH nocounter
 ;end select
 IF (((definition_ind=0) OR (definition_rec_ind=0)) )
  IF ((validate(cvs_inhouse,- (999999)) != - (999999)))
   CALL echo(
    "Inhouse process: definition_dup_ind doesn't exit in record DMREQUEST or table CODE_VALUE_SET")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ELSE
   IF (definition_rec_ind=1
    AND definition_ind=0)
    IF ((dmrequest->definition_dup_ind=1))
     CALL echo("***************************************************************************")
     CALL echo("ERROR: definition_dup_ind(value is 1) doesn't exit on table CODE_VALUE_SET")
     CALL echo("***************************************************************************")
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM code_value_set c
    SET c.display = dmrequest->display, c.display_key = display_key, c.description = dmrequest->
     description,
     c.definition = dmrequest->definition, c.table_name = dmrequest->table_name, c.cache_ind =
     dmrequest->cache_ind,
     c.extension_ind = extension_ind, c.add_access_ind = dmrequest->add_access_ind, c.chg_access_ind
      = dmrequest->chg_access_ind,
     c.del_access_ind = dmrequest->del_access_ind, c.inq_access_ind = dmrequest->inq_access_ind, c
     .def_dup_rule_flag = dmrequest->def_dup_rule_flag,
     c.cdf_meaning_dup_ind = dmrequest->cdf_meaning_dup_ind, c.display_key_dup_ind = dmrequest->
     display_key_dup_ind, c.active_ind_dup_ind = dmrequest->active_ind_dup_ind,
     c.display_dup_ind = dmrequest->display_dup_ind, c.alias_dup_ind = dmrequest->alias_dup_ind, c
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
     c.updt_applctx = reqinfo->updt_applctx
    WHERE (c.code_set=dmrequest->code_set)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM code_value_set c
     SET c.code_set = dmrequest->code_set, c.display = dmrequest->display, c.display_key =
      display_key,
      c.description = dmrequest->description, c.definition = dmrequest->definition, c.table_name =
      dmrequest->table_name,
      c.cache_ind = dmrequest->cache_ind, c.extension_ind = extension_ind, c.add_access_ind =
      dmrequest->add_access_ind,
      c.chg_access_ind = dmrequest->chg_access_ind, c.del_access_ind = dmrequest->del_access_ind, c
      .inq_access_ind = dmrequest->inq_access_ind,
      c.def_dup_rule_flag = dmrequest->def_dup_rule_flag, c.cdf_meaning_dup_ind = dmrequest->
      cdf_meaning_dup_ind, c.display_key_dup_ind = dmrequest->display_key_dup_ind,
      c.active_ind_dup_ind = dmrequest->active_ind_dup_ind, c.display_dup_ind = dmrequest->
      display_dup_ind, c.alias_dup_ind = dmrequest->alias_dup_ind,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_cnt = 0,
      c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (cs_pkg_ind=1
     AND cs_oil_column_ind=1)
     SET cs_tmp_smallint = dilc_insert_cs_row(cs_pkg_nbr,cnvtreal(dmrequest->code_set),dmrequest->
      description)
    ENDIF
   ENDIF
  ENDIF
 ELSEIF (definition_ind=1
  AND definition_rec_ind=1)
  UPDATE  FROM code_value_set c
   SET c.display = dmrequest->display, c.display_key = display_key, c.description = dmrequest->
    description,
    c.definition = dmrequest->definition, c.table_name = dmrequest->table_name, c.cache_ind =
    dmrequest->cache_ind,
    c.extension_ind = extension_ind, c.add_access_ind = dmrequest->add_access_ind, c.chg_access_ind
     = dmrequest->chg_access_ind,
    c.del_access_ind = dmrequest->del_access_ind, c.inq_access_ind = dmrequest->inq_access_ind, c
    .def_dup_rule_flag = dmrequest->def_dup_rule_flag,
    c.cdf_meaning_dup_ind = dmrequest->cdf_meaning_dup_ind, c.display_key_dup_ind = dmrequest->
    display_key_dup_ind, c.active_ind_dup_ind = dmrequest->active_ind_dup_ind,
    c.display_dup_ind = dmrequest->display_dup_ind, c.alias_dup_ind = dmrequest->alias_dup_ind, c
    .definition_dup_ind = dmrequest->definition_dup_ind,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_cnt = 0,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
   WHERE (c.code_set=dmrequest->code_set)
   WITH nocounter
  ;end update
  CALL echo(build(dmrequest->code_set,"/",curqual))
  IF (curqual=0)
   INSERT  FROM code_value_set c
    SET c.code_set = dmrequest->code_set, c.display = dmrequest->display, c.display_key = display_key,
     c.description = dmrequest->description, c.definition = dmrequest->definition, c.table_name =
     dmrequest->table_name,
     c.cache_ind = dmrequest->cache_ind, c.extension_ind = extension_ind, c.add_access_ind =
     dmrequest->add_access_ind,
     c.chg_access_ind = dmrequest->chg_access_ind, c.del_access_ind = dmrequest->del_access_ind, c
     .inq_access_ind = dmrequest->inq_access_ind,
     c.def_dup_rule_flag = dmrequest->def_dup_rule_flag, c.cdf_meaning_dup_ind = dmrequest->
     cdf_meaning_dup_ind, c.display_key_dup_ind = dmrequest->display_key_dup_ind,
     c.active_ind_dup_ind = dmrequest->active_ind_dup_ind, c.display_dup_ind = dmrequest->
     display_dup_ind, c.alias_dup_ind = dmrequest->alias_dup_ind,
     c.definition_dup_ind = dmrequest->definition_dup_ind, c.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), c.updt_id = reqinfo->updt_id,
     c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (cs_pkg_ind=1
    AND cs_oil_column_ind=1)
    SET cs_tmp_smallint = dilc_insert_cs_row(cs_pkg_nbr,cnvtreal(dmrequest->code_set),dmrequest->
     description)
   ENDIF
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
 FREE RANGE cvs
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
