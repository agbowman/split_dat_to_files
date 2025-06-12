CREATE PROGRAM cps_add_sum_readme:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 summary_sheet_id = f8
   1 sect[1]
     2 section_id = f8
   1 parent[1]
     2 parent_sect_id = f8
     2 child[*]
       3 child_sect_id = f8
       3 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD summary_sheet(
   1 summary_sheet_qual = i4
   1 sheet_array[1]
     2 summary_sheet_id = f8
     2 summary_section_qual = i4
     2 summary_section[*]
       3 section_id = f8
 )
 SET failed = false
 SET serrmsg = fillstring(132," ")
 SET script_name = fillstring(132," ")
 SET count = 0
 IF ((requestin->prsnl_id=0))
  DELETE  FROM summary_section_r
   WHERE summary_sheet_id > 0
  ;end delete
  DELETE  FROM summary_sheet
   WHERE summary_sheet_id > 0
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  s.summary_sheet_id
  FROM summary_sheet s
  PLAN (s
   WHERE (s.prsnl_id=requestin->prsnl_id)
    AND s.summary_sheet_id > 0)
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alter(summary_sheet->sheet_array,(count+ 10))
   ENDIF
   summary_sheet->sheet_array[count].summary_sheet_id = s.summary_sheet_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET summary_sheet->summary_sheet_qual = 0
 ELSE
  IF (curqual > 0)
   SET summary_sheet->summary_sheet_qual = count
  ELSE
   SET failed = select_error
   GO TO check_error
  ENDIF
 ENDIF
 EXECUTE cps_del_summary_section
 IF (failed != false)
  SET script_name = "cps_del_summary_section"
  GO TO check_error
 ENDIF
 EXECUTE cps_del_summary_sheet
 IF (failed != false)
  SET script_name = "cps_del_summary_sheet"
  GO TO error_check
 ENDIF
 SET current_date = cnvtdatetime(sysdate)
 SET script_name = "cps_add_sum_sheet"
 SET table_name = "SUMMARY_SHEET"
 IF ((requestin->summary_sheet_id=0))
  SELECT INTO "nl:"
   y = seq(cpo_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->summary_sheet_id = cnvtint(y)
   WITH format, counter
  ;end select
 ELSE
  SET reply->summary_sheet_id = requestin->summary_sheet_id
 ENDIF
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_code = code_value
 INSERT  FROM summary_sheet css
  SET css.summary_sheet_id = reply->summary_sheet_id, css.prsnl_id = requestin->prsnl_id, css.display
    = requestin->display,
   css.description = requestin->description, css.active_ind = 1, css.active_status_cd = active_code,
   css.active_status_dt_tm = cnvtdatetime(current_date), css.active_status_prsnl_id = 0, css
   .beg_effective_dt_tm = cnvtdatetime(current_date),
   css.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), css.updt_dt_tm = cnvtdatetime(current_date),
   css.updt_cnt = 0,
   css.updt_id = 0, css.updt_task = 0, css.updt_applctx = 0
  WITH nocounter
 ;end insert
 IF (curqual <= 0)
  SET failed = insert_error
  GO TO check_error
 ENDIF
 SET stat = alter(reply->sect,requestin->section_qual)
 FOR (i = 1 TO requestin->section_qual)
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = cnvtupper(requestin->section[i].subj_area_mean)
   CALL echo(cdf_meaning)
   SET code_set = 12004
   SET code_value = 0
   EXECUTE cpm_get_cd_for_cdf
   SET subj_area_cd = code_value
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = cnvtupper(requestin->section[i].section_type_mean)
   SET code_set = 12001
   SET code_value = 0
   EXECUTE cpm_get_cd_for_cdf
   SET sect_type_cd = code_value
   SET next_code = 0.0
   EXECUTE cpm_next_code
   SET reply->sect[i].section_id = next_code
   INSERT  FROM summary_section ss
    SET ss.section_id = reply->sect[i].section_id, ss.prsnl_id = 0, ss.display = requestin->section[i
     ].display,
     ss.subject_area_cd = subj_area_cd, ss.section_type_cd = sect_type_cd, ss.sortable_ind = 0,
     ss.script = " ", ss.max_qual = 0, ss.active_ind = 1,
     ss.active_status_cd = active_code, ss.active_status_dt_tm = cnvtdatetime(current_date), ss
     .active_status_prsnl_id = 0,
     ss.beg_effective_dt_tm = cnvtdatetime(current_date), ss.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), ss.updt_dt_tm = cnvtdatetime(current_date),
     ss.updt_cnt = 0, ss.updt_id = 0, ss.updt_task = 0,
     ss.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    SET failed = insert_error
    GO TO check_error
   ENDIF
   IF ((requestin->section[i].sequence > 0))
    SET table_name = "SHEET_SECTION_R"
    INSERT  FROM summary_section_r cds
     SET cds.summary_sheet_id = reply->summary_sheet_id, cds.section_id = reply->sect[i].section_id,
      cds.sequence = requestin->section[i].sequence,
      cds.default_expand_ind = 1, cds.active_ind = 1, cds.active_status_cd = active_code,
      cds.active_status_dt_tm = cnvtdatetime(current_date), cds.active_status_prsnl_id = 0, cds
      .beg_effective_dt_tm = cnvtdatetime(current_date),
      cds.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cds.updt_dt_tm = cnvtdatetime(
       current_date), cds.updt_cnt = 0,
      cds.updt_id = 0, cds.updt_task = 0, cds.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual <= 0)
     SET failed = insert_error
     CALL echo("******Error :sheet section r fail")
     GO TO check_error
    ELSE
     CALL echo("******summary_section id",0)
     CALL echo(reply->sect[i].section_id)
    ENDIF
   ENDIF
   IF ((requestin->section[i].attr_qual > 0))
    FOR (j = 1 TO requestin->section[i].attr_qual)
      SET cdf_meaning = fillstring(12," ")
      SET cdf_meaning = cnvtupper(requestin->section[i].attr[j].subj_area_dtl_mean)
      SET code_set = 12005
      SET code_value = 0
      EXECUTE cpm_get_cd_for_cdf
      SET subj_area_dtl_cd = code_value
      SET cdf_meaning = fillstring(12," ")
      SET cdf_meaning = cnvtupper(requestin->section[i].attr[j].detail_type_mean)
      SET code_set = 12002
      SET code_value = 0
      EXECUTE cpm_get_cd_for_cdf
      SET detail_type_cd = code_value
      SET table_name = "SECTION_ATTRIBUTE"
      INSERT  FROM section_attribute csa
       SET csa.section_id = reply->sect[i].section_id, csa.column_num = requestin->section[i].attr[j]
        .col_num, csa.subj_area_dtl_cd = subj_area_dtl_cd,
        csa.width =
        IF ((requestin->section[i].attr[j].width > 0)) requestin->section[i].attr[j].width
        ELSE 0
        ENDIF
        , csa.detail_type_cd = detail_type_cd, csa.detail_value = requestin->section[i].attr[j].
        detail_value,
        csa.output_mask = " ", csa.sort_direction_cd = 0, csa.height = 0,
        csa.sep_string = " ", csa.sep_str_length = 0, csa.trim_type_cd = 0,
        csa.trim_char = " ", csa.row_num = 0, csa.detail_sequence = requestin->section[i].attr[j].
        col_num,
        csa.active_ind = 1, csa.active_status_cd = active_code, csa.active_status_dt_tm =
        cnvtdatetime(current_date),
        csa.active_status_prsnl_id = 0, csa.beg_effective_dt_tm = cnvtdatetime(current_date), csa
        .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        csa.updt_dt_tm = cnvtdatetime(current_date), csa.updt_cnt = 0, csa.updt_id = 0,
        csa.updt_task = 0, csa.updt_applctx = 0
       WITH nocounter
      ;end insert
      IF (curqual <= 0)
       SET failed = insert_error
       GO TO check_error
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alter(reply->parent,(requestin->sect_with_child+ 10))
 FOR (k = 1 TO requestin->sect_with_child)
   SET table_name = "summary_section_parent_id"
   SELECT INTO "nl:"
    ss.section_id, c.code_value
    FROM summary_section ss,
     code_value c
    PLAN (c
     WHERE c.cdf_meaning=cnvtupper(requestin->parent[k].parent_sect_mean)
      AND c.code_set=12004
      AND c.active_ind=1)
     JOIN (ss
     WHERE c.code_value=ss.subject_area_cd
      AND ss.prsnl_id=0
      AND ss.beg_effective_dt_tm=cnvtdatetime(current_date))
    DETAIL
     reply->parent[k].parent_sect_id = ss.section_id
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = select_error
    GO TO check_error
   ENDIF
   SET count = 0
   SET stat = alterlist(reply->parent[k].child,requestin->parent[k].child_qual)
   SET table_name = "summary_section_child_ids"
   SELECT INTO "nl:"
    ss.section_id, c.code_value
    FROM summary_section ss,
     (dummyt d1  WITH seq = value(requestin->parent[k].child_qual)),
     code_value c
    PLAN (d1)
     JOIN (c
     WHERE c.cdf_meaning=cnvtupper(requestin->parent[k].child[d1.seq].child_sect_mean)
      AND c.code_set=12004
      AND c.active_ind=1)
     JOIN (ss
     WHERE c.code_value=ss.subject_area_cd
      AND ss.prsnl_id=0
      AND ss.beg_effective_dt_tm=cnvtdatetime(current_date))
    DETAIL
     count += 1, reply->parent[k].child[count].child_sect_id = ss.section_id
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = select_error
    GO TO check_error
   ENDIF
   SET table_name = "SECTION_SECTION_R"
   INSERT  FROM section_section_r csr,
     (dummyt d1  WITH seq = value(requestin->parent[k].child_qual))
    SET csr.parent_id = reply->parent[k].parent_sect_id, csr.child_id = reply->parent[k].child[d1.seq
     ].child_sect_id, csr.sequence = requestin->parent[k].child[d1.seq].sequence,
     csr.active_ind = 1, csr.active_status_cd = active_code, csr.active_status_dt_tm = cnvtdatetime(
      current_date),
     csr.active_status_prsnl_id = 0, csr.beg_effective_dt_tm = cnvtdatetime(current_date), csr
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     csr.updt_dt_tm = cnvtdatetime(current_date), csr.updt_cnt = 0, csr.updt_id = 0,
     csr.updt_task = 0, csr.updt_applctx = 0
    PLAN (d1)
     JOIN (csr)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    GO TO check_error
   ENDIF
 ENDFOR
 GO TO check_error
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  COMMIT
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = script_name
  SET reqinfo->commit_ind = false
  ROLLBACK
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  CALL echo("FAILED: Table = [",0)
  CALL echo(table_name,0)
  CALL echo("]  failed to [",0)
  SET op_name = reply->status_data.subeventstatus[1].operationname
  CALL echo(op_name,0)
  CALL echo("]  ",1)
  CALL echo("        CCL error = [",0)
  CALL echo(serrmsg,0)
  CALL echo("]",1)
 ENDIF
 GO TO end_program
#end_program
 SET pco_script_version = "001 10/03/02 SF3151"
END GO
