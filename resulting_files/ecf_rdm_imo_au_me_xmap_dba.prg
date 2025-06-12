CREATE PROGRAM ecf_rdm_imo_au_me_xmap:dba
 DECLARE kia_get_ver_num_by_ft(mean=vc,ver_ft=vc) = i4
 DECLARE kia_chk_version_number(mean=vc) = i4
 DECLARE kia_get_version_number(mean=vc) = i4
 DECLARE kia_get_version_ft(mean=vc) = vc
 DECLARE kia_insert_cmt_version(beg_date=vc,ver_ft=vc) = null
 DECLARE kia_rdm_log(log_str=vc) = null
 DECLARE display_logfile(logfile=vc,log_instance=i4) = null
 DECLARE obs_report(vocab_mean=vc) = null
 DECLARE new_nomen_report(vocab_mean=vc) = null
 DECLARE ext_report(vocab_mean=vc) = null
 DECLARE rel_report(vocab_mean=vc) = null
 DECLARE log_sub(log_str=vc) = null
 DECLARE kia_copy_log_rows(var=vc) = null
 DECLARE check_script_status(logfile=vc) = c1
 DECLARE kia_chk_status_info(chk_object=vc,obj_type=vc) = null
 DECLARE kia_set_status_success(suc_obj=vc) = null
 DECLARE kia_chk_status_readme(readme_nbr=i4,chk_str=vc) = i2
 DECLARE kia_chk_error(dmy_var=vc) = null
 DECLARE kia_rdm_next_seq(seq_name=vc) = f8
 DECLARE kia_rdm_get_cd(mean=vc) = f8
 DECLARE get_counts(vocab_mean=vc) = null
 DECLARE kia_rdm_purge_info(package_number=i4,readme_number=i4) = null
 DECLARE kia_get_parse_info(package_number=i4,readme_number=i4,parse_script=vc,blocks=i4) = null
 DECLARE kia_load_file(kia_csv_name=vc,kia_load_script=vc,kia_log_name=vc) = null
 DECLARE kia_db2_check(var=vc) = null
 DECLARE kia_rdm_get_pent_id(var=i2) = f8
 DECLARE kia_load_dmp(kia_dmp_filename=vc,kia_tbl=vc,kia_exp_count=i4) = null
 DECLARE kia_rdm_purge_all_info(package_number=i4,readme_number=i4) = null
 DECLARE kia_inhouse_chk(var=vc) = null
 DECLARE kia_set_parse_row_success(suc_obj=vc) = null
 DECLARE kia_script_inc(pkg=i4,ccl_obj=vc) = i2
 DECLARE script_status = c1 WITH public, noconstant(" ")
 DECLARE csv_stat = i4 WITH public, noconstant(1)
 DECLARE start_time_var = q8 WITH private
 DECLARE stop_time_var = q8 WITH private
 DECLARE kia_exe = vc WITH public, noconstant("")
 DECLARE kia_notreadme = i2 WITH public, noconstant(0)
 DECLARE kia_full_load = i2 WITH public, noconstant(1)
 DECLARE kia_vocab_cnt = i4 WITH public, noconstant(0)
 DECLARE kia_vocab_cd = f8 WITH public, noconstant(0.0)
 DECLARE kia_long_desc = vc WITH public, noconstant("")
 DECLARE kia_short_desc = vc WITH public, noconstant("")
 DECLARE kia_parse_script = vc WITH public, noconstant("")
 DECLARE kia_parse_blocks = i4 WITH public, noconstant(0)
 DECLARE kia_pkg_nbr = i4 WITH public, noconstant(0)
 DECLARE kia_rdm_nbr = i4 WITH public, noconstant(0)
 DECLARE kia_rdm_exp_cnt = f8 WITH public, noconstant(0.0)
 DECLARE kia_rdm_act_cnt = f8 WITH public, noconstant(0.0)
 DECLARE kia_obj_suc_ind = i2 WITH public, noconstant(0)
 DECLARE kia_rdm_latest_ver = i4 WITH public, noconstant(0)
 DECLARE kia_late_xm_to_ver = i4 WITH public, noconstant(0)
 DECLARE kia_late_xm_from_ver = i4 WITH public, noconstant(0)
 DECLARE kia_rdm_cur_ver = i4 WITH public, noconstant(0)
 DECLARE kia_dmp_name = vc WITH public, noconstant("")
 DECLARE new_cmt_id = f8 WITH public, noconstant(0.0)
 DECLARE kia_cur_xm_to_ver = i4 WITH public, noconstant(0)
 DECLARE kia_cur_xm_from_ver = i4 WITH public, noconstant(0)
 DECLARE dcl_command = vc WITH public, noconstant("")
 DECLARE dcl_length = i4 WITH public, noconstant(0)
 DECLARE dcl_flag = i2 WITH public, noconstant(0)
 DECLARE kia_cmt_log_id = f8 WITH public, noconstant(0.0)
 DECLARE kia_rdm_input_name = vc WITH public, noconstant("")
 DECLARE kia_rdm_err_cnt = i4 WITH public, noconstant(0)
 DECLARE kia_rdm_latest_ft = vc WITH public, noconstant("")
 DECLARE kia_rdm_vocab_mean = vc WITH public, noconstant("")
 DECLARE kia_rdm_cont_type = i2 WITH public, noconstant(0)
 DECLARE kia_rdm_pent_name = vc WITH public, noconstant("")
 DECLARE kia_rdm_pent_mean = vc WITH public, noconstant("")
 DECLARE new_ver_id = f8 WITH public, noconstant(0.0)
 DECLARE kia_version_chk = i2 WITH public, noconstant(0)
 DECLARE kia_rdm_log_name = vc WITH public, noconstant("kia_rdm.log")
 IF (validate(readme_data,"0")="0")
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
  SET kia_notreadme = 1
 ENDIF
 SUBROUTINE kia_get_ver_num_by_ft(mean,ver_ft)
   DECLARE ft_ver_cd = f8 WITH public, noconstant(0.0)
   DECLARE ft_ver_num = i4 WITH public, noconstant(0)
   DECLARE ft_ret_val = i4 WITH public, noconstant(0)
   SET ft_ver_cd = kia_rdm_get_cd(mean)
   SET kia_vocab_cd = ft_ver_cd
   IF (ft_ver_cd > 0)
    SELECT INTO "nl:"
     FROM cmt_content_version c
     WHERE c.source_vocabulary_cd=ft_ver_cd
      AND c.version_ft=ver_ft
     ORDER BY c.beg_effective_dt_tm DESC
     DETAIL
      ft_ver_num = c.version_number
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (ft_ver_num=kia_rdm_cur_ver)
     CALL echo(concat("Version already exists: ",mean," - ",trim(cnvtstring(kia_rdm_cur_ver))))
     CALL log_sub("THIS VERSION HAS ALREADY BEEN INSTALLED")
     SET readme_data->status = "S"
     SET readme_data->message = "SUCCESS - Version already installed"
     GO TO exit_script
    ELSEIF (ft_ver_num > 0)
     SET ft_ret_val = ft_ver_num
    ELSE
     SET ft_ret_val = 0
     IF (trim(mean)="SNMCT")
      CALL echo("Check for pre-Jul02 rows...")
      SELECT INTO "nl:"
       FROM cmt_concept c
       WHERE c.concept_source_mean="SNOMED"
        AND c.beg_effective_dt_tm < cnvtdatetime("01-JUL-2002")
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SELECT INTO "nl:"
        FROM cmt_concept c
        WHERE c.concept_source_mean="SNOMED"
         AND c.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
        WITH nocounter
       ;end select
       IF (curqual < 1)
        SET readme_data->message = "Failed - Need to install 14143"
        CALL echo("Please install package 14143 before installing this package.")
        CALL log_sub("You must first install package 14143 before installing this package.")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ft_ret_val = - (1)
    CALL echo(concat(mean," cdf_meaning not found on code_set 400"))
    CALL log_sub(concat(mean," cdf_meaning not found on code_set 400"))
    SET readme_data->message = concat("FAILED - ",mean," mean not on cs400")
    GO TO exit_script
   ENDIF
   RETURN(ft_ret_val)
 END ;Subroutine
 SUBROUTINE kia_chk_version_number(mean)
   DECLARE chk_cd = f8 WITH public, noconstant(0.0)
   DECLARE chk_ret_val = i4 WITH public, noconstant(0)
   SET chk_cd = kia_rdm_get_cd(mean)
   IF (chk_cd > 0)
    SELECT INTO "nl:"
     FROM cmt_content_version c
     WHERE c.source_vocabulary_cd=chk_cd
     ORDER BY c.beg_effective_dt_tm DESC
     DETAIL
      chk_ret_val = c.version_number
     WITH nocounter, maxqual(c,1)
    ;end select
   ELSE
    SET chk_ret_val = - (1)
    CALL echo(concat(mean," cdf_meaning not found on code_set 400"))
    CALL log_sub(concat(mean," cdf_meaning not found on code_set 400"))
    SET readme_data->message = concat("FAILED - ",mean," mean not on cs400")
    GO TO exit_script
   ENDIF
   RETURN(chk_ret_val)
 END ;Subroutine
 SUBROUTINE kia_get_version_number(mean)
   DECLARE sub_cd_val = f8 WITH public, noconstant(0.0)
   DECLARE sub_ver_num = i4 WITH public, noconstant(0)
   DECLARE sub_ret_val = i4 WITH public, noconstant(0)
   SET par_ent_id = kia_rdm_get_pent_id(1)
   SET sub_cd_val = kia_rdm_get_cd(mean)
   SET kia_vocab_cd = sub_cd_val
   IF (sub_cd_val > 0)
    IF (trim(kia_rdm_pent_name) IN (null, "", " "))
     SET kia_rdm_pent_name = " "
    ENDIF
    SELECT INTO "nl:"
     FROM cmt_content_version c
     WHERE c.source_vocabulary_cd=sub_cd_val
      AND c.content_type_flag=kia_rdm_cont_type
      AND c.parent_entity_name=kia_rdm_pent_name
      AND c.parent_entity_id=par_ent_id
      AND c.package_nbr=kia_pkg_nbr
     ORDER BY c.version_number DESC
     DETAIL
      sub_ver_num = c.version_number
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (sub_ver_num=kia_rdm_cur_ver)
     CALL echo(concat("Version already exists: ",mean," - ",trim(cnvtstring(kia_rdm_cur_ver))))
     CALL log_sub("THIS VERSION HAS ALREADY BEEN INSTALLED")
     SET readme_data->status = "S"
     SET readme_data->message = "SUCCESS - Version already installed"
     GO TO exit_script
    ELSEIF (sub_ver_num > 0)
     SET sub_ret_val = sub_ver_num
    ELSE
     SET sub_ret_val = 0
    ENDIF
   ELSE
    SET sub_ret_val = - (1)
    CALL echo(concat(mean," cdf_meaning not found on code_set 400"))
    CALL log_sub(concat(mean," cdf_meaning not found on code_set 400"))
    SET readme_data->message = concat("FAILED - ",mean," mean not on cs400")
    GO TO exit_script
   ENDIF
   RETURN(sub_ret_val)
 END ;Subroutine
 SUBROUTINE kia_get_version_ft(mean)
   DECLARE sub_cd_val1 = f8 WITH public, noconstant(0.0)
   DECLARE sub_ver_ft = vc WITH public, noconstant("")
   DECLARE sub_ret_ft = vc WITH public, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=400
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cnvtdatetime(curdate,curtime3) < cv.end_effective_dt_tm
     AND cv.cdf_meaning=trim(mean)
    DETAIL
     sub_cd_val1 = cv.code_value
    WITH nocounter
   ;end select
   IF (sub_cd_val1 > 0)
    SELECT INTO "nl:"
     FROM cmt_content_version c
     WHERE c.source_vocabulary_cd=sub_cd_val1
     ORDER BY c.beg_effective_dt_tm DESC
     DETAIL
      sub_ver_ft = c.version_ft
     WITH nocounter, maxqual(c,1)
    ;end select
    IF (trim(sub_ver_ft) > "")
     SET sub_ret_ft = sub_ver_ft
    ENDIF
   ELSE
    SET sub_ret_ft = "-1"
   ENDIF
   RETURN(sub_ret_ft)
 END ;Subroutine
 SUBROUTINE kia_insert_cmt_version(beg_date,ver_ft)
   SET par_ent_id = kia_rdm_get_pent_id(1)
   SET new_ver_id = 0.0
   SET new_ver_id = kia_rdm_next_seq("reference_seq")
   SET new_ver_cd = kia_rdm_get_cd(trim(kia_rdm_vocab_mean))
   UPDATE  FROM cmt_content_version c
    SET c.ver_end_effective_dt_tm = datetimeadd(cnvtdatetime(concat(trim(beg_date)," 23:59:59")),- (1
      )), c.updt_applctx = 0, c.updt_cnt = (c.updt_cnt+ 1),
     c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = 0, c.updt_task = 0
    WHERE c.source_vocabulary_cd=new_ver_cd
     AND c.ver_beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cnvtdatetime(curdate,curtime3) <= c.ver_end_effective_dt_tm
     AND c.content_type_flag=kia_rdm_cont_type
     AND c.parent_entity_id=par_ent_id
     AND c.parent_entity_name=kia_rdm_pent_name
    WITH nocounter
   ;end update
   COMMIT
   INSERT  FROM cmt_content_version c
    SET c.active_ind = 1, c.beg_effective_dt_tm = cnvtdatetime(beg_date), c.cmt_content_version_id =
     new_ver_id,
     c.content_type_flag = kia_rdm_cont_type, c.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 23:59:59"), c.package_nbr = kia_pkg_nbr,
     c.parent_entity_id =
     IF (par_ent_id > 0) par_ent_id
     ELSE 0
     ENDIF
     , c.parent_entity_name =
     IF ( NOT (trim(kia_rdm_pent_name) IN ("", " ", null))) trim(kia_rdm_pent_name)
     ELSE " "
     ENDIF
     , c.source_vocabulary_cd = new_ver_cd,
     c.version_ft = ver_ft, c.version_number = kia_rdm_cur_ver, c.ver_beg_effective_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.ver_end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"), c.updt_applctx = 0, c.updt_cnt
      = 0,
     c.updt_id = 0, c.updt_task = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE kia_rdm_log(log_str)
   SELECT INTO "kia_rdm_snmct_concept.log"
    FROM dual
    DETAIL
     col 0, log_str, row + 1
    WITH append, nocounter, noformfeed,
     format = variable, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE display_logfile(logfile,log_instance)
   DECLARE breakpoint = i2 WITH public, noconstant(1)
   FREE DEFINE rtl2
   DEFINE rtl2 value(logfile)
   SELECT
    r.*
    FROM rtl2t r
    HEAD REPORT
     col 0, "Display log file: ", logfile,
     row + 2
    DETAIL
     IF (log_instance=0)
      log_line = substring(1,130,trim(r.line)), col 0, log_line,
      row + 1
     ELSEIF (findstring("END",cnvtupper(trim(r.line)),0)
      AND ((findstring("WARNING",cnvtupper(trim(r.line)),0)) OR (((findstring("SUCCESS",cnvtupper(
       trim(r.line)),0)) OR (findstring("FAILURE",cnvtupper(trim(r.line))))) )) )
      breakpoint = (breakpoint+ 1)
      IF ((breakpoint=(log_instance+ 1)))
       log_line = substring(1,130,trim(r.line)), col 0, log_line,
       row + 1, log_instance = (log_instance+ 2)
      ENDIF
     ELSEIF (breakpoint=log_instance)
      log_line = substring(1,130,trim(r.line)), col 0, log_line,
      row + 1
     ENDIF
    WITH check
   ;end select
 END ;Subroutine
 SUBROUTINE obs_report(vocab_mean)
   SELECT
    n.source_identifier, n.beg_effective_dt_tm, n.end_effective_dt_tm,
    n.source_string
    FROM nomenclature n,
     code_value cv
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (n
     WHERE n.source_vocabulary_cd=cv.code_value
      AND n.end_effective_dt_tm=cnvtdatetime("31-DEC-2002")
      AND n.updt_id=0)
    ORDER BY n.source_identifier
    HEAD REPORT
     col 0, "OBSOLETE TERMS AND NOMEN REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     col 40, "SourceString", row + 2
    DETAIL
     source_id = substring(1,10,n.source_identifier), col 0, source_id,
     beg_dt = format(n.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(n.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     col 40, n.source_string, row + 1
    FOOT  n.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE new_nomen_report(vocab_mean)
   SELECT
    n.source_identifier, n.beg_effective_dt_tm, n.end_effective_dt_tm,
    n.source_string
    FROM nomenclature n,
     code_value cv
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (n
     WHERE n.source_vocabulary_cd=cv.code_value
      AND n.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND n.updt_id=0)
    ORDER BY n.source_identifier
    HEAD REPORT
     col 0, "NEW AND CHANGED TERMS REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     col 40, "SourceString", row + 2
    DETAIL
     source_id = substring(1,10,n.source_identifier), col 0, source_id,
     beg_dt = format(n.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(n.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     col 40, n.source_string, row + 1
    FOOT  n.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE ext_report(vocab_mean)
   SELECT
    a.source_identifier, a.beg_effective_dt_tm, a.end_effective_dt_tm
    FROM apc_extension a
    WHERE a.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
     AND a.updt_id=0
    ORDER BY a.source_identifier
    HEAD REPORT
     col 0, "EXTENSION REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     row + 2
    DETAIL
     source_id = substring(1,10,a.source_identifier), col 0, source_id,
     beg_dt = format(a.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(a.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     row + 1
    FOOT  a.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE rel_report(vocab_mean)
   SELECT
    v.source_identifier, v.beg_effective_dt_tm, v.end_effective_dt_tm,
    v.related_vocab_cd, v.related_identifier
    FROM vocab_related_code v,
     code_value cv,
     code_value cv1
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (v
     WHERE v.source_vocab_cd=cv.code_value
      AND v.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND v.updt_id=0)
     JOIN (cv1
     WHERE cv1.code_value=v.related_vocab_cd
      AND cv1.code_set=400)
    ORDER BY v.source_identifier
    HEAD REPORT
     col 0, "RELATED REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "APC SourceID", col 16,
     "BegDate", col 30, "EndDate",
     col 44, "RelatedMean", col 58,
     "RelatedID", row + 2
    DETAIL
     source_id = substring(1,10,v.source_identifier), col 0, source_id,
     beg_dt = format(v.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 16, beg_dt,
     end_dt = format(v.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 30, end_dt,
     rel_mean = trim(cv1.cdf_meaning), col 44, rel_mean,
     rel_id = substring(1,10,v.related_identifier), col 58, rel_id,
     row + 1
    FOOT  v.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE log_sub(log_str)
   IF (validate(kia_rdm_log_name,"0")="0")
    DECLARE kia_rdm_log_name = vc WITH public, noconstant("kia_rdm.log")
   ENDIF
   DECLARE tmp_log_str = vc WITH public, noconstant(substring(1,131,log_str))
   SELECT INTO value(kia_rdm_log_name)
    FROM dual
    DETAIL
     row + 1, col 0, tmp_log_str
    WITH append, nocounter, noformfeed,
     format = variable, maxcol = 132, maxrow = 2
   ;end select
 END ;Subroutine
 SUBROUTINE kia_copy_log_rows(var)
  SELECT INTO "nl:"
   FROM dprotect d
   WHERE d.object="T"
    AND d.object_name="KIA_RMS_LOG"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   INSERT  FROM cmt_import_log c,
     kia_rms_log k
    SET c.cmt_import_log_id = k.cmt_import_log_id, c.package_nbr = k.package_nbr, c.readme = k.readme,
     c.start_dt_tm = cnvtdatetime(k.start_dt_tm), c.end_dt_tm = cnvtdatetime(k.end_dt_tm), c
     .input_filename = trim(k.input_filename),
     c.start_record = k.start_record, c.block_size = k.block_size, c.script_name = trim(k.script_name
      ),
     c.logfile_name = trim(k.logfile_name), c.log_level = k.log_level, c.status_flag = k.status_flag,
     c.updt_applctx = k.updt_applctx, c.updt_cnt = k.updt_cnt, c.updt_dt_tm = cnvtdatetime(k
      .updt_dt_tm),
     c.updt_id = k.updt_id, c.updt_task = k.updt_task
    PLAN (k
     WHERE k.cmt_import_log_id > 0
      AND  NOT ( EXISTS (
     (SELECT
      x
      FROM cmt_import_log y
      WHERE y.cmt_import_log_id=k.cmt_import_log_id))))
     JOIN (c)
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    FROM dprotect d
    WHERE d.object="T"
     AND d.object_name="KIA_RMS_MSG"
    WITH nocounter
   ;end select
   IF (curqual > 0)
    INSERT  FROM cmt_import_log_msg c,
      kia_rms_msg k
     SET c.cmt_import_log_id = k.cmt_import_log_id, c.cmt_import_log_msg_id = k.cmt_import_log_msg_id,
      c.log_instance = k.log_instance,
      c.log_message = trim(k.log_message), c.log_seq = k.log_seq, c.updt_applctx = k.updt_applctx,
      c.updt_cnt = k.updt_cnt, c.updt_dt_tm = cnvtdatetime(k.updt_dt_tm), c.updt_id = k.updt_id,
      c.updt_task = k.updt_task
     PLAN (k
      WHERE k.cmt_import_log_msg_id > 0
       AND k.cmt_import_log_id > 0
       AND  NOT ( EXISTS (
      (SELECT
       x
       FROM cmt_import_log_msg y
       WHERE y.cmt_import_log_msg_id=k.cmt_import_log_msg_id))))
      JOIN (c)
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE check_script_status(logfile)
   DECLARE script_stat = c1 WITH public, noconstant("F")
   FREE DEFINE rtl2
   DEFINE rtl2 value(logfile)
   SELECT INTO "nl:"
    r.*
    FROM rtl2t r
    HEAD REPORT
     script_stat = "F"
    FOOT REPORT
     IF (((findstring("SUCCESS",cnvtupper(trim(r.line)),0)) OR (findstring("WARNING",cnvtupper(trim(r
        .line)),0))) )
      script_stat = "S"
     ENDIF
    WITH check
   ;end select
   RETURN(script_stat)
 END ;Subroutine
 SUBROUTINE kia_chk_status_info(chk_object,obj_type)
   SET kia_obj_suc_ind = 0
   SELECT INTO "nl:"
    FROM cmt_import_log c
    WHERE c.input_filename=trim(cnvtupper(chk_object))
     AND c.package_nbr=kia_pkg_nbr
     AND c.readme=kia_rdm_nbr
     AND c.status_flag=1
    DETAIL
     kia_obj_suc_ind = 1
    WITH nocounter
   ;end select
   CALL echo("**********************************************************")
   CALL echo(concat("CHECKING CMT_IMPORT_LOG for '",trim(cnvtupper(chk_object)),"': ",trim(cnvtstring
      (kia_obj_suc_ind))))
   CALL echo("**********************************************************")
   IF (trim(obj_type)="table"
    AND kia_obj_suc_ind=1)
    CALL echo("This readme has already run successfully for this package.")
    CALL log_sub("This readme has already run successfully for this package.")
    SET readme_data->status = "S"
    SET readme_data->message = concat("SUCCESS - ",trim(kia_long_desc))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_set_status_success(suc_obj)
   SET new_cmt_id = 0.0
   SET new_cmt_id = kia_rdm_next_seq("reference_seq")
   INSERT  FROM cmt_import_log c
    SET c.cmt_import_log_id = new_cmt_id, c.end_dt_tm = cnvtdatetime(curdate,curtime3), c
     .input_filename = trim(cnvtupper(suc_obj)),
     c.logfile_name = "STATUS_INFO", c.package_nbr = kia_pkg_nbr, c.readme = kia_rdm_nbr,
     c.script_name = kia_parse_script, c.status_flag = 1
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE kia_chk_status_readme(readme_nbr,chk_str)
   SET kia_obj_suc_ind = 0
   SELECT INTO "nl:"
    FROM cmt_import_log c
    WHERE c.input_filename=trim(cnvtupper(chk_str))
     AND c.logfile_name="PARSING_INFO"
     AND c.package_nbr=kia_pkg_nbr
     AND c.readme=readme_nbr
    DETAIL
     kia_obj_suc_ind = 1
    WITH nocounter
   ;end select
   RETURN(kia_obj_suc_ind)
 END ;Subroutine
 SUBROUTINE kia_chk_error(dmy_var)
   FREE SET kia_error_message
   FREE SET error_number
   DECLARE kia_error_message = vc WITH public, noconstant("")
   DECLARE kia_error_number = i4 WITH public, noconstant(0)
   SET kia_error_number = error(kia_error_message,0)
   IF (kia_error_number > 0)
    CALL echo("ERRORS FOUND, NOW LOGGING ERRORS")
    CALL echo("ERRORS FOUND, NOW LOGGING ERRORS")
    CALL echo("ERRORS FOUND, NOW LOGGING ERRORS")
    IF (validate(readme_data,0))
     SET readme_data->status = "F"
     SET readme_data->message = concat("FAILED - ",cnvtupper(kia_error_message))
    ENDIF
    CALL log_sub(concat("FAILED - ",cnvtupper(kia_error_message)))
    CALL kia_log_errors(kia_error_message)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_rdm_next_seq(seq_name)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = number
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL echo(concat("Failure from sequence ",seq_name))
   ELSE
    RETURN(next_seq)
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_rdm_get_cd(mean)
   SET kia_sub_cd = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning=trim(mean)
     AND cv.code_set=400
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cnvtdatetime(curdate,curtime3) < cv.end_effective_dt_tm
    DETAIL
     kia_sub_cd = cv.code_value
    WITH nocounter
   ;end select
   RETURN(kia_sub_cd)
 END ;Subroutine
 SUBROUTINE get_counts(vocab_mean)
   DECLARE vocab_cd = f8 WITH public, noconstant(0.0)
   DECLARE new_cnt = i4 WITH public, noconstant(0)
   DECLARE obs_cnt = i4 WITH public, noconstant(0)
   DECLARE ext_cnt = i4 WITH public, noconstant(0)
   DECLARE rel_cnt = i4 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning=vocab_mean
     AND cv.code_set=400
    DETAIL
     vocab_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.source_vocabulary_cd=vocab_cd
     AND n.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
     AND n.updt_id=0
    DETAIL
     new_cnt = (new_cnt+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.source_vocabulary_cd=vocab_cd
     AND n.end_effective_dt_tm=cnvtdatetime("31-DEC-2002")
     AND n.updt_id=0
    DETAIL
     obs_cnt = (obs_cnt+ 1)
    WITH nocounter
   ;end select
   IF (vocab_mean="APC")
    SELECT INTO "nl:"
     FROM apc_extension a
     WHERE a.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND a.updt_id=0
     DETAIL
      ext_cnt = (ext_cnt+ 1)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM vocab_related_code v
     WHERE v.source_vocab_cd=vocab_cd
      AND v.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND v.updt_id=0
     DETAIL
      rel_cnt = (rel_cnt+ 1)
     WITH nocounter
    ;end select
   ENDIF
   SELECT
    FROM dual
    HEAD REPORT
     col 0, "Counts report:", row + 2
    DETAIL
     line1 = concat("New and changed terms: ",cnvtstring(new_cnt)), col 0, line1,
     row + 2, line2 = concat("Obs terms and nomen:   ",cnvtstring(obs_cnt)), col 0,
     line2, row + 2
     IF (vocab_mean="APC")
      line3 = concat("Extension:             ",cnvtstring(ext_cnt)), col 0, line3,
      row + 2, line4 = concat("Related                ",cnvtstring(rel_cnt)), col 0,
      line4, row + 2
     ENDIF
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE kia_rdm_purge_info(package_number,readme_number)
  DELETE  FROM cmt_import_log c
   WHERE c.readme=readme_number
    AND c.package_nbr=package_number
    AND c.status_flag != 0
    AND c.input_filename="*.CSV"
    AND c.logfile_name="STATUS_INFO"
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE kia_get_parse_info(package_number,readme_number,parse_script,blocks)
   SET kia_parse_script = ""
   SET kia_parse_blocks = 0
   SELECT INTO "nl:"
    FROM cmt_import_log c
    WHERE c.logfile_name="PARSING_INFO"
     AND c.package_nbr=package_number
     AND c.readme=readme_number
    DETAIL
     kia_parse_script = c.script_name, kia_parse_blocks = c.block_size
    WITH nocounter
   ;end select
   IF (((curqual < 1) OR (((trim(kia_parse_script) <= "") OR (kia_parse_blocks < 1)) )) )
    SET kia_parse_script = parse_script
    SET kia_parse_blocks = blocks
    SET new_cmt_id = 0.0
    SET new_cmt_id = kia_rdm_next_seq("reference_seq")
    INSERT  FROM cmt_import_log c
     SET c.block_size = kia_parse_blocks, c.cmt_import_log_id = new_cmt_id, c.input_filename = trim(
       concat("README INFO - ",trim(cnvtstring(readme_number)))),
      c.logfile_name = "PARSING_INFO", c.package_nbr = package_number, c.readme = readme_number,
      c.script_name = kia_parse_script, c.start_dt_tm = cnvtdatetime(curdate,curtime3), c
      .start_record = 0,
      c.status_flag = 0, c.updt_id = readme_number, c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_load_file(kia_csv_name,kia_load_script,kia_log_name)
   SET kia_exe = ""
   SET kia_rdm_input_name = ""
   SET kia_rdm_input_name = trim(kia_csv_name)
   SET kia_rdm_err_cnt = 0
   SET kia_cmt_log_id = 0.0
   SET kia_cmt_log_id = kia_rdm_next_seq("reference_seq")
   CALL kia_chk_status_info(kia_csv_name,"csv")
   IF (kia_obj_suc_ind=0)
    CALL echo(concat("Loading ",kia_csv_name))
    SET csv_stat = findfile(concat("cer_install:",kia_csv_name))
    IF (csv_stat=0)
     CALL echo(concat("Failed to find csv file: ",kia_csv_name))
     CALL log_sub(concat("Failed to find csv file: ",kia_csv_name))
     SET readme_data->message = concat("Fail-",trim(kia_short_desc),"- not found: ",kia_csv_name)
     SET readme_data->status = "F"
     GO TO exit_script
    ENDIF
    IF (kia_parse_script="dm_readme_import")
     SET kia_exe = 'execute dm_readme_import "'
    ELSE
     SET kia_exe = concat("execute ",trim(kia_parse_script),' "cer_install:')
    ENDIF
    SET kia_exe = concat(trim(kia_exe),kia_csv_name,'",')
    SET kia_exe = concat(trim(kia_exe),' "',kia_load_script,'", ',trim(cnvtstring(kia_parse_blocks)),
     ", 0 go")
    CALL parser(kia_exe)
    SET script_status = check_script_status(kia_log_name)
    CALL echo(build("script status :",script_status))
    CALL echo(build("script status :",script_status))
    CALL echo(build("script status :",script_status))
    CALL echo(build("kia_log_name :",kia_log_name))
    CALL echo(build("kia_log_name :",kia_log_name))
    CALL echo(build("kia_log_name :",kia_log_name))
    IF (script_status="F")
     CALL echo(concat("Failed to load ",kia_csv_name," - exiting load scripts"))
     CALL log_sub(concat("Failed to load ",kia_csv_name," - exiting load scripts"))
     SET readme_data->message = concat("Fail-",trim(kia_short_desc),"- error on: ",kia_csv_name)
     SET readme_data->status = "F"
     GO TO exit_script
    ENDIF
    CALL kia_set_status_success(kia_csv_name)
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_db2_check(var)
   IF (currdb="DB2UDB")
    SET readme_data->status = "S"
    SET readme_data->message = "THIS VERSION IS NOT COMPATIBLE WITH DB2"
    GO TO db2_exit
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_rdm_get_pent_id(var)
   SET ret_id = 0.0
   SET kia_cs_var = 0.0
   CASE (kia_rdm_cont_type)
    OF 0:
     SET ret_id = 0
    OF 1:
     SET kia_cs_var = 15849
    OF 2:
     SET kia_cs_var = 29754
    OF 3:
     SELECT INTO "nl:"
      FROM cmt_subset c
      WHERE c.subset_mean=trim(kia_rdm_pent_mean)
      DETAIL
       ret_id = c.subset_id
      WITH nocounter
     ;end select
     IF (ret_id=0)
      CALL echo("Parent Entity Id not found for Parent Entity Name on CMT_SUBSET")
      CALL log_sub("Parent Entity Id not found for Parent Entity Name on CMT_SUBSET")
      GO TO exit_script
     ENDIF
   ENDCASE
   IF (((kia_rdm_cont_type=1) OR (kia_rdm_cont_type=2)) )
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=kia_cs_var
      AND cv.cdf_meaning=trim(kia_rdm_pent_mean)
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cnvtdatetime(curdate,curtime3) <= cv.end_effective_dt_tm
     DETAIL
      ret_id = cv.code_value
     WITH nocounter
    ;end select
    IF (ret_id=0)
     CALL echo(concat("Parent Entity Id not found for Parent Entity Name on code_set ",trim(
        cnvtstring(kia_cs_var))))
     CALL log_sub(concat("Parent Entity Id not found for Parent Entity Name on code_set ",trim(
        cnvtstring(kia_cs_var))))
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(ret_id)
 END ;Subroutine
 SUBROUTINE kia_load_dmp(kia_dmp_filename,kia_tbl,kia_exp_count)
  CALL kia_chk_status_info(kia_dmp_filename,"dmp")
  IF (kia_obj_suc_ind=0)
   SET kia_exe = concat('execute dm_readme_oracle_import "',trim(kia_dmp_filename),'.dmp", "',trim(
     kia_dmp_filename),'.par", 0 go')
   CALL parser(kia_exe)
   SET kia_rdm_act_cnt = 0
   CALL echo("CHECKING COUNT ON TABLE")
   SET kia_exe = concat("select into 'nl:' rows = count(*) from ",kia_tbl,
    " detail kia_rdm_act_cnt = rows with nocounter go")
   CALL parser(kia_exe)
   IF (cursys="AIX")
    SET dcl_command = concat("mv $CCLUSERDIR/",trim(kia_dmp_filename),".log $cer_install")
   ELSE
    SET dcl_command = concat("copy ccluserdir:",trim(kia_dmp_filename),".log cer_install")
   ENDIF
   SET dcl_flag = 0
   SET dcl_length = size(dcl_command)
   CALL echo(dcl_command)
   CALL dcl(dcl_command,dcl_length,dcl_flag)
   IF (kia_rdm_act_cnt < kia_exp_count)
    CALL log_sub(concat("Expected count: ",trim(cnvtstring(kia_exp_count)),"  Actual count: ",trim(
       cnvtstring(kia_rdm_act_cnt))))
    SET readme_data->status = "F"
    SET readme_data->message = concat("FAILED - LOADING ",trim(kia_dmp_filename),
     ".dmp - COUNT NOT CORRECT")
    CALL echo("TABLE COUNT IS NOT CORRECT.")
    GO TO exit_script
   ELSE
    CALL echo("TABLE COUNT IS CORRECT.")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE kia_rdm_purge_all_info(package_number,readme_number)
   DELETE  FROM cmt_import_log c
    WHERE c.readme=readme_number
     AND c.package_nbr=package_number
     AND c.status_flag != 0
     AND c.logfile_name="STATUS_INFO"
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE kia_inhouse_chk(var)
   IF ( NOT (cnvtupper(curuser) IN ("P30INS", "DD011127", "JL2501", "JP017059", "CERLWS",
   "SE2323", "KW4926", "CERFTS", "RS011138", "RK010957",
   "BG2117", "AJ057503", "SA034725", "SB030736", "WC9492",
   "DM029128", "JB9616", "MG4109", "LB020844", "DK8704",
   "KV011080", "JB026288", "CA024256", "HK052182", "SB050430",
   "RK055213", "D_1801E", "R_1801E", "R_18S1E", "CM025745",
   "D_1002E", "D_1201E", "D_718E", "D_719E", "D_CMTMAK",
   "D_7EMAK", "D_CLNMAK", "D_DEVMAK", "D_1501E", "R_1501E",
   "D_1501D", "D_INDMAK", "D_INTMAK", "D_MAEMAK", "D_PRVMAK",
   "D_SOLMAK", "D_SRDMAK", "R_1002SE", "R_12S1E", "R_1201E",
   "R_15S1E", "D_SWEDV", "EB069836", "AM070474", "MB054958",
   "AR073761", "RK015945")))
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET readme_data->status = "S"
     SET readme_data->message = "SUCCESS - SCRIPT DOES NOT RUN IN A INHOUSE DOMAIN"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_set_parse_row_success(suc_obj)
   SELECT INTO "nl:"
    FROM cmt_import_log c
    WHERE c.readme=kia_rdm_nbr
     AND c.package_nbr=kia_pkg_nbr
     AND c.logfile_name="PARSING_INFO"
    WITH nocounter
   ;end select
   IF (curqual > 0)
    UPDATE  FROM cmt_import_log c
     SET c.input_filename = trim(cnvtupper(suc_obj)), c.status_flag = 1
     WHERE c.readme=kia_rdm_nbr
      AND c.package_nbr=kia_pkg_nbr
      AND c.logfile_name="PARSING_INFO"
     WITH nocounter
    ;end update
   ELSE
    SET new_cmt_id = 0.0
    SET new_cmt_id = kia_rdm_next_seq("reference_seq")
    INSERT  FROM cmt_import_log c
     SET c.block_size = 500, c.cmt_import_log_id = new_cmt_id, c.input_filename = trim(cnvtupper(
        suc_obj)),
      c.logfile_name = "PARSING_INFO", c.package_nbr = kia_pkg_nbr, c.readme = kia_rdm_nbr,
      c.script_name = "kia_dm_dbimport", c.start_dt_tm = cnvtdatetime(curdate,curtime3), c
      .start_record = 0,
      c.status_flag = 0, c.updt_id = kia_rdm_nbr, c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE kia_chk_script_failure(tmp_var)
   IF ((readme_data->status="F"))
    CALL kia_log_errors(concat("*** ERROR DURING ",cnvtupper(tmp_var)," ***"))
    CALL kia_log_errors(readme_data->message)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_log_errors(err_message)
   CALL log_sub(err_message)
   SET new_cmt_id = 0.0
   SET new_cmt_id = kia_rdm_next_seq("reference_seq")
   FREE SET tmp_seq
   SET tmp_seq = 0
   SELECT INTO "nl:"
    FROM cmt_import_log_msg c
    WHERE (c.cmt_import_log_id=
    (SELECT
     x.cmt_import_log_id
     FROM cmt_import_log x
     WHERE x.readme=kia_rdm_nbr
      AND x.package_nbr=kia_pkg_nbr
      AND x.logfile_name="PARSING_INFO"))
    ORDER BY c.log_seq
    DETAIL
     tmp_seq = (c.log_seq+ 1)
    WITH nocounter
   ;end select
   INSERT  FROM cmt_import_log_msg c
    SET c.cmt_import_log_msg_id = new_cmt_id, c.cmt_import_log_id =
     (SELECT
      x.cmt_import_log_id
      FROM cmt_import_log x
      WHERE x.readme=kia_rdm_nbr
       AND x.package_nbr=kia_pkg_nbr
       AND x.logfile_name="PARSING_INFO"), c.log_instance = 0,
     c.log_message = trim(substring(1,250,err_message)), c.log_seq = tmp_seq, c.updt_applctx = 0.0,
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = 0.0,
     c.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
 SUBROUTINE kia_chk_nomen_dups(tbl,vocab)
   FREE RECORD duprow
   RECORD duprow(
     1 lst[*]
       2 source_vocab_cd = f8
       2 princ_type_cd = f8
       2 source_identifier = vc
       2 source_string = vc
   )
   FREE RECORD fixdups
   RECORD fixdups(
     1 lst[*]
       2 source_vocab_cd = f8
       2 princ_type_cd = f8
       2 source_identifier = vc
       2 source_string = vc
       2 source_string_fix = vc
       2 cmti = vc
   )
   DECLARE dt_str = vc
   DECLARE dup_ctr = i4
   DECLARE fixdup_ctr = i4
   SET dup_ctr = 0
   SET fixdup_ctr = 0
   SET dt_str = ""
   CALL echo("CHECKING FOR DUP ROWS ON _LOAD TABLE")
   CALL echo("CHECKING FOR DUP ROWS ON _LOAD TABLE")
   CALL echo("CHECKING FOR DUP ROWS ON _LOAD TABLE")
   SELECT INTO "nl:"
    n.source_identifier, n.source_string, n.principle_type_cd,
    n.source_vocabulary_cd
    FROM (value(tbl) n)
    WHERE n.source_vocabulary_mean=vocab
    GROUP BY n.source_identifier, n.source_string, n.principle_type_cd,
     n.source_vocabulary_cd
    HAVING count(*) > 1
    DETAIL
     dup_ctr = (dup_ctr+ 1), stat = alterlist(duprow->lst,dup_ctr), duprow->lst[dup_ctr].
     princ_type_cd = n.principle_type_cd,
     duprow->lst[dup_ctr].source_vocab_cd = n.source_vocabulary_cd, duprow->lst[dup_ctr].
     source_identifier = n.source_identifier, duprow->lst[dup_ctr].source_string = n.source_string
    WITH nocounter
   ;end select
   IF (dup_ctr > 0)
    SELECT INTO "nl:"
     FROM (value(tbl) n),
      (dummyt d  WITH seq = value(dup_ctr))
     PLAN (d)
      JOIN (n
      WHERE (n.source_string=duprow->lst[d.seq].source_string)
       AND (n.source_identifier=duprow->lst[d.seq].source_identifier)
       AND (n.source_vocabulary_cd=duprow->lst[d.seq].source_vocab_cd)
       AND (n.principle_type_cd=duprow->lst[d.seq].princ_type_cd))
     DETAIL
      dt_str = "", fixdup_ctr = (fixdup_ctr+ 1), stat = alterlist(fixdups->lst,fixdup_ctr),
      dt_str = concat(substring(1,240,trim(n.source_string)),format(n.beg_effective_dt_tm,
        "DD-MMM-YYYY;;D")," <?>"), fixdups->lst[fixdup_ctr].princ_type_cd = n.principle_type_cd,
      fixdups->lst[fixdup_ctr].source_vocab_cd = n.source_vocabulary_cd,
      fixdups->lst[fixdup_ctr].source_identifier = n.source_identifier, fixdups->lst[fixdup_ctr].
      source_string = n.source_string, fixdups->lst[fixdup_ctr].source_string_fix = dt_str,
      fixdups->lst[fixdup_ctr].cmti = n.cmti
     WITH nocounter
    ;end select
    CALL echo("UPDATING DUP ROWS ON _LOAD TABLE")
    UPDATE  FROM (value(tbl) n),
      (dummyt d  WITH seq = value(fixdup_ctr))
     SET n.source_string = fixdups->lst[d.seq].source_string_fix
     PLAN (d)
      JOIN (n
      WHERE (n.cmti=fixdups->lst[d.seq].cmti)
       AND (n.source_string=fixdups->lst[d.seq].source_string)
       AND (n.source_identifier=fixdups->lst[d.seq].source_identifier)
       AND (n.source_vocabulary_cd=fixdups->lst[d.seq].source_vocab_cd)
       AND (n.principle_type_cd=fixdups->lst[d.seq].princ_type_cd)
       AND n.end_effective_dt_tm < cnvtdatetime("30-DEC-2100")
       AND n.source_vocabulary_mean=vocab)
     WITH nocounter, maxcommit = 500
    ;end update
    CALL kia_chk_error(1)
    COMMIT
   ENDIF
   FREE RECORD duprow
   FREE RECORD fixdups
 END ;Subroutine
 SUBROUTINE kia_script_inc(pkg,ccl_obj)
   DECLARE obj_prs = vc
   DECLARE dat_file = vc
   DECLARE dat_dir = vc
   DECLARE dat_str = vc
   DECLARE backup_dat = vc
   SET dat_file = build("dicocd0",pkg,".dat")
   IF (cursys="AXP")
    SET dat_dir = build("cer_ocd:[0",pkg,"]")
   ELSE
    SET dat_dir = build("cer_ocd:/0",pkg,"/")
   ENDIF
   SET dat_str = concat(dat_dir,dat_file)
   SET backup_dat = "LIVE"
   IF (findfile(dat_str)=0)
    CALL echo(build("File not found:",dat_str))
    RETURN(0)
   ENDIF
   SELECT INTO "NL:"
    FROM dprotect d
    WHERE d.object="P"
     AND d.object_name="EUC_COPY_CCL"
    WITH counter
   ;end select
   IF (curqual < 1)
    SET obj_prs = concat('cclocdimport "',dat_file,'","',ccl_obj,'","backup" go')
   ELSE
    SET obj_prs = "euc"
    SET obj_prs = concat(obj_prs,'_copy_ccl "',dat_str,'","',backup_dat,
     '","',ccl_obj,'",1,0 go')
   ENDIF
   CALL echo(obj_prs)
   FREE RECORD request
   CALL parser(obj_prs)
 END ;Subroutine
 DECLARE kia_cur_ver_beg_dt = vc WITH public, noconstant("")
 SET kia_tbl_desc = "IMO-AU-ME XMAP"
 SET kia_short_desc = "IMO-AU-ME XMAP"
 SET kia_rdm_log_name = "ecf_rdm_imo_au_me_xmap.log"
 SET kia_rdm_nbr = 9931
 SET kia_rdm_vocab_mean = "IMO_AU-ME"
 SET readme_data->status = "F"
 SET readme_data->message = concat("Failed - ",trim(kia_tbl_desc))
 SET script_status = " "
 SET csv_stat = 1
 CALL kia_inhouse_chk(1)
 CALL kia_db2_check(1)
 EXECUTE kia_dm_dbimport "cer_install:imo_au_me_version.csv", "kia_get_rdm_vars", 100,
 0
 CALL kia_chk_script_failure("KIA_GET_RDM_VARS")
 SET start_time_var = cnvtdatetime(curdate,curtime3)
 CALL log_sub(concat("ecf_rdm_imo_au_me_xmap Begin> ",format(cnvtdatetime(curdate,curtime3),
    "dd-mmm-yyyy hh:mm:ss;;d")))
 SET kia_rdm_latest_ver = kia_get_version_number(kia_rdm_vocab_mean)
 CALL kia_chk_status_info(kia_tbl_desc,"table")
 CALL kia_get_parse_info(kia_pkg_nbr,kia_rdm_nbr,"kia_dm_dbimport",1000)
 CALL kia_chk_status_info("kia_load_xmap","check")
 IF (kia_obj_suc_ind=0)
  EXECUTE kia_load_xmap kia_rdm_vocab_mean, ""
  CALL kia_chk_script_failure("kia_load_xmap")
  CALL kia_set_status_success("kia_load_xmap")
 ENDIF
 CALL kia_rdm_purge_all_info(kia_pkg_nbr,kia_rdm_nbr)
 CALL kia_set_parse_row_success(kia_tbl_desc)
 CALL echo(build("README'S ALREADY COMPLETED:",kia_version_chk))
 CALL kia_insert_cmt_version(kia_cur_ver_beg_dt,kia_long_desc)
 SET readme_data->status = "S"
 SET readme_data->message = concat("SUCCESS - ",trim(kia_tbl_desc))
#exit_script
 SET stop_time_var = cnvtdatetime(curdate,curtime3)
 CALL log_sub(concat("Script Elapsed Time (in seconds): ",cnvtstring(datetimediff(stop_time_var,
     start_time_var,5))))
 IF ((readme_data->status="F"))
  CALL log_sub(concat("END > FAILURE ",format(cnvtdatetime(curdate,curtime3),
     "dd-mmm-yyyy hh:mm:ss;;d")))
 ELSE
  CALL log_sub(concat("END > SUCCESS ",format(cnvtdatetime(curdate,curtime3),
     "dd-mmm-yyyy hh:mm:ss;;d")))
 ENDIF
#db2_exit
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SUBROUTINE my_echo(my_msg)
   CALL echo("*************************************************")
   CALL echo(my_msg)
   CALL echo("*************************************************")
 END ;Subroutine
END GO
