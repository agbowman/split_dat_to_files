CREATE PROGRAM aps_chg_case_synoptic_ws:dba
 IF ((validate(reply->curqual,- (99))=- (99)))
  RECORD reply(
    1 ws_qual[*]
      2 entity_key = i4
      2 case_worksheet_id = f8
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD foreign_ws_qual(
   1 ins_qual[*]
     2 case_worksheet_id = f8
     2 ap_case_synoptic_ws_data_id = f8
     2 question_concept_cki = vc
     2 answer_concept_cki = vc
     2 answer_value = vc
     2 answer_long_text_id = f8
     2 answer_unit_cd = f8
     2 answer_unit = vc
     2 answer_text_format_cd = f8
     2 answer_type_flag = i2
     2 answer_long_text_value = vc
     2 question_desc = vc
     2 question_coding_sys = vc
     2 answer_desc = vc
     2 answer_coding_sys = vc
     2 alt_question_cki = vc
     2 alt_question_desc = vc
     2 alt_question_coding_sys = vc
     2 alt_answer_cki = vc
     2 alt_answer_desc = vc
     2 alt_answer_coding_sys = vc
     2 answer_unit_ident = vc
     2 answer_unit_desc = vc
     2 answer_unit_coding_sys = vc
     2 answer_type_text = vc
     2 sub_answer_type_text = vc
     2 answer_sub_ident = vc
     2 data_type_flag = i2
     2 legacy_mode = i2
   1 del_qual[*]
     2 case_worksheet_id = f8
   1 del_answer_text_qual[*]
     2 answer_long_text_id = f8
 ) WITH protect
 RECORD aps_add_db_codeset_request(
   1 qual[1]
     2 code_set = i4
     2 display = c40
     2 description = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 collation_seq = i4
 ) WITH protect
 RECORD aps_add_db_codeset_reply(
   1 qual[1]
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE deleteforeignwsdata(no_param=i2) = i2 WITH protect
 DECLARE insertforeignwsdata(no_param=i2) = i2 WITH protect
 DECLARE populateqapairfields(insidx=i4) = i2 WITH protect
 DECLARE checkcodeset(dcodeval=f8,lcodeset=i4,smeaning=vc) = i2 WITH protect
 DECLARE active_status_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE nsub_error = i2 WITH protect, constant(0)
 DECLARE nsub_success = i2 WITH protect, constant(1)
 DECLARE ws_ckey_type = i2 WITH protect, constant(5)
 DECLARE ws_fld_question_ckey = vc WITH protect, constant("question_ckey")
 DECLARE ws_fld_answer_ckey = vc WITH protect, constant("answer_ckey")
 DECLARE ws_fld_answer_value = vc WITH protect, constant("answer_value")
 DECLARE ws_fld_answer_unit = vc WITH protect, constant("answer_unit")
 DECLARE ws_fld_cer_ans_txt_format_cd = vc WITH protect, constant("cer_answer_text_format_cd")
 DECLARE ws_fld_cer_ans_type = vc WITH protect, constant("cer_answer_type")
 DECLARE ws_fld_question_text = vc WITH protect, constant("question_text")
 DECLARE ws_fld_question_coding_sys = vc WITH protect, constant("question_coding_system")
 DECLARE ws_fld_answer_text = vc WITH protect, constant("answer_text")
 DECLARE ws_fld_answer_coding_sys = vc WITH protect, constant("answer_coding_system")
 DECLARE ws_fld_alt_question_ckey = vc WITH protect, constant("alt_question_ckey")
 DECLARE ws_fld_alt_question_text = vc WITH protect, constant("alt_question_text")
 DECLARE ws_fld_alt_question_coding_sys = vc WITH protect, constant("alt_question_coding_system")
 DECLARE ws_fld_alt_answer_text = vc WITH protect, constant("alt_answer_text")
 DECLARE ws_fld_alt_answer_coding_sys = vc WITH protect, constant("alt_answer_coding_system")
 DECLARE ws_fld_alt_answer_ckey = vc WITH protect, constant("alt_answer_ckey")
 DECLARE ws_fld_answer_unit_text = vc WITH protect, constant("answer_unit_text")
 DECLARE ws_fld_answer_unit_coding_sys = vc WITH protect, constant("answer_unit_coding_system")
 DECLARE ws_fld_sub_answer_type = vc WITH protect, constant("sub_answer_type")
 DECLARE ws_fld_answer_sub_ident = vc WITH protect, constant("answer_sub_ident")
 DECLARE ws_fld_data_type_flag = vc WITH protect, constant("data_type_flag")
 DECLARE ws_fld_answer_type = vc WITH protect, constant("answer_type")
 SUBROUTINE deleteforeignwsdata(no_param)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE answer_long_text_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    d.seq
    FROM ap_case_synoptic_ws_data apd,
     (dummyt d  WITH seq = value(size(foreign_ws_qual->del_qual,5)))
    PLAN (d)
     JOIN (apd
     WHERE (foreign_ws_qual->del_qual[d.seq].case_worksheet_id > 0.0)
      AND (apd.case_worksheet_id=foreign_ws_qual->del_qual[d.seq].case_worksheet_id))
    DETAIL
     IF (apd.answer_long_text_id > 0)
      answer_long_text_cnt = (answer_long_text_cnt+ 1), stat = alterlist(foreign_ws_qual->
       del_answer_text_qual,answer_long_text_cnt), foreign_ws_qual->del_answer_text_qual[
      answer_long_text_cnt].answer_long_text_id = apd.answer_long_text_id
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    RETURN(0)
   ENDIF
   DELETE  FROM ap_case_synoptic_ws_data apd,
     (dummyt d  WITH seq = value(size(foreign_ws_qual->del_qual,5)))
    SET apd.seq = 1
    PLAN (d)
     JOIN (apd
     WHERE (foreign_ws_qual->del_qual[d.seq].case_worksheet_id > 0.0)
      AND (apd.case_worksheet_id=foreign_ws_qual->del_qual[d.seq].case_worksheet_id))
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    RETURN(0)
   ENDIF
   IF (answer_long_text_cnt > 0)
    DELETE  FROM long_text lt,
      (dummyt d  WITH seq = value(answer_long_text_cnt))
     SET lt.seq = 1
     PLAN (d
      WHERE (foreign_ws_qual->del_answer_text_qual[d.seq].answer_long_text_id > 0))
      JOIN (lt
      WHERE (foreign_ws_qual->del_answer_text_qual[d.seq].answer_long_text_id=lt.long_text_id))
     WITH nocounter
    ;end delete
    IF (curqual != answer_long_text_cnt)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE insertforeignwsdata(no_param)
   DECLARE ws_data_idx = i4 WITH protect, noconstant(0)
   DECLARE ws_data_cnt = i4 WITH protect, noconstant(0)
   DECLARE text_answer_cnt = i4 WITH protect, noconstant(0)
   DECLARE answer_unit_cd = f8 WITH protect, noconstant(0.0)
   DECLARE answer_unit_disp = vc WITH protect, noconstant("")
   SET ws_data_cnt = size(foreign_ws_qual->ins_qual,5)
   IF (ws_data_cnt > 0)
    FOR (ws_data_idx = 1 TO ws_data_cnt)
      SELECT INTO "nl:"
       seq_nbr = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        foreign_ws_qual->ins_qual[ws_data_idx].ap_case_synoptic_ws_data_id = cnvtreal(seq_nbr)
       WITH format, nocounter
      ;end select
      IF ((foreign_ws_qual->ins_qual[ws_data_idx].answer_value != null)
       AND size(foreign_ws_qual->ins_qual[ws_data_idx].answer_value,1) > 255)
       SELECT INTO "nl:"
        seq_nbr = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         foreign_ws_qual->ins_qual[ws_data_idx].answer_long_text_id = cnvtreal(seq_nbr),
         text_answer_cnt = (text_answer_cnt+ 1)
        WITH format, nocounter
       ;end select
       SET foreign_ws_qual->ins_qual[ws_data_idx].answer_long_text_value = foreign_ws_qual->ins_qual[
       ws_data_idx].answer_value
       SET foreign_ws_qual->ins_qual[ws_data_idx].answer_value = null
      ELSE
       SET foreign_ws_qual->ins_qual[ws_data_idx].answer_long_text_id = 0.0
      ENDIF
      IF ((foreign_ws_qual->ins_qual[ws_data_idx].legacy_mode=1))
       SET answer_unit_cd = 0.0
       SET foreign_ws_qual->ins_qual[ws_data_idx].answer_unit_cd = 0.0
       IF ((foreign_ws_qual->ins_qual[ws_data_idx].answer_unit != null)
        AND size(foreign_ws_qual->ins_qual[ws_data_idx].answer_unit,1) > 0)
        SELECT INTO "nl:"
         FROM code_value cv
         WHERE cv.code_set=54
          AND (cv.display=foreign_ws_qual->ins_qual[ws_data_idx].answer_unit)
          AND cv.active_ind=1
         DETAIL
          answer_unit_cd = cv.code_value
         WITH nocounter
        ;end select
        IF (answer_unit_cd > 0)
         SET foreign_ws_qual->ins_qual[ws_data_idx].answer_unit_cd = answer_unit_cd
        ELSE
         SET aps_add_db_codeset_request->qual[1].code_set = 54
         SET aps_add_db_codeset_request->qual[1].display = foreign_ws_qual->ins_qual[ws_data_idx].
         answer_unit
         SET aps_add_db_codeset_request->qual[1].description = foreign_ws_qual->ins_qual[ws_data_idx]
         .answer_unit
         SET aps_add_db_codeset_request->qual[1].active_ind = 1
         EXECUTE aps_add_db_codeset  WITH replace("REQUEST","APS_ADD_DB_CODESET_REQUEST"), replace(
          "REPLY","APS_ADD_DB_CODESET_REPLY")
         IF ((aps_add_db_codeset_reply->status_data.status="S")
          AND size(aps_add_db_codeset_reply->qual,5)=1)
          SET foreign_ws_qual->ins_qual[ws_data_idx].answer_unit_cd = aps_add_db_codeset_reply->qual[
          1].code_value
         ELSE
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (text_answer_cnt > 0)
     INSERT  FROM long_text lt,
       (dummyt d  WITH seq = value(ws_data_cnt))
      SET lt.long_text_id = foreign_ws_qual->ins_qual[d.seq].answer_long_text_id, lt
       .parent_entity_name = "AP_CASE_SYNOPTIC_WS_DATA", lt.parent_entity_id = foreign_ws_qual->
       ins_qual[d.seq].ap_case_synoptic_ws_data_id,
       lt.long_text = foreign_ws_qual->ins_qual[d.seq].answer_long_text_value, lt.active_ind = 1, lt
       .active_status_cd = active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      PLAN (d
       WHERE (foreign_ws_qual->ins_qual[d.seq].answer_long_text_id > 0))
       JOIN (lt)
      WITH nocounter
     ;end insert
     IF (curqual != text_answer_cnt)
      RETURN(0)
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     has_answer_cki = decode(ccr.seq,1,0)
     FROM cmt_concept_reltn ccr,
      (dummyt d  WITH seq = value(ws_data_cnt))
     PLAN (d
      WHERE size(foreign_ws_qual->ins_qual[d.seq].answer_concept_cki,1) <= 0
       AND (foreign_ws_qual->ins_qual[d.seq].legacy_mode=1))
      JOIN (ccr
      WHERE ccr.relation_cki=outerjoin("CAP_ECC!ABE1269E-363C-47D0-B50D-C59D72CA3BC4")
       AND ccr.concept_cki2=outerjoin(foreign_ws_qual->ins_qual[d.seq].question_concept_cki)
       AND ccr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND ccr.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
     DETAIL
      IF (has_answer_cki=1)
       foreign_ws_qual->ins_qual[d.seq].answer_concept_cki = ccr.concept_cki1
      ENDIF
     WITH nocounter
    ;end select
    INSERT  FROM ap_case_synoptic_ws_data asd,
      (dummyt d  WITH seq = value(ws_data_cnt))
     SET asd.ap_case_synoptic_ws_data_id = foreign_ws_qual->ins_qual[d.seq].
      ap_case_synoptic_ws_data_id, asd.case_worksheet_id = foreign_ws_qual->ins_qual[d.seq].
      case_worksheet_id, asd.question_concept_cki = foreign_ws_qual->ins_qual[d.seq].
      question_concept_cki,
      asd.answer_concept_cki =
      IF ((foreign_ws_qual->ins_qual[d.seq].answer_concept_cki != null)
       AND size(foreign_ws_qual->ins_qual[d.seq].answer_concept_cki,1) > 0) foreign_ws_qual->
       ins_qual[d.seq].answer_concept_cki
      ELSE null
      ENDIF
      , asd.answer_value =
      IF ((foreign_ws_qual->ins_qual[d.seq].answer_value != null)
       AND size(foreign_ws_qual->ins_qual[d.seq].answer_value,1) > 0) foreign_ws_qual->ins_qual[d.seq
       ].answer_value
      ELSE null
      ENDIF
      , asd.answer_long_text_id = foreign_ws_qual->ins_qual[d.seq].answer_long_text_id,
      asd.answer_unit_cd = foreign_ws_qual->ins_qual[d.seq].answer_unit_cd, asd.answer_text_format_cd
       = foreign_ws_qual->ins_qual[d.seq].answer_text_format_cd, asd.answer_type_flag =
      foreign_ws_qual->ins_qual[d.seq].answer_type_flag,
      asd.question_txt = foreign_ws_qual->ins_qual[d.seq].question_desc, asd
      .question_coding_sys_ident = foreign_ws_qual->ins_qual[d.seq].question_coding_sys, asd
      .answer_txt = foreign_ws_qual->ins_qual[d.seq].answer_desc,
      asd.answer_coding_sys_ident = foreign_ws_qual->ins_qual[d.seq].answer_coding_sys, asd
      .alt_question_cki = foreign_ws_qual->ins_qual[d.seq].alt_question_cki, asd.alt_question_txt =
      foreign_ws_qual->ins_qual[d.seq].alt_question_desc,
      asd.alt_question_coding_sys_ident = foreign_ws_qual->ins_qual[d.seq].alt_question_coding_sys,
      asd.alt_answer_cki = foreign_ws_qual->ins_qual[d.seq].alt_answer_cki, asd.alt_answer_txt =
      foreign_ws_qual->ins_qual[d.seq].alt_answer_desc,
      asd.alt_answer_coding_sys_ident = foreign_ws_qual->ins_qual[d.seq].alt_answer_coding_sys, asd
      .answer_unit_ident = foreign_ws_qual->ins_qual[d.seq].answer_unit_ident, asd.answer_unit_txt =
      foreign_ws_qual->ins_qual[d.seq].answer_unit_desc,
      asd.answer_unit_coding_sys_ident = foreign_ws_qual->ins_qual[d.seq].answer_unit_coding_sys, asd
      .answer_type_txt = foreign_ws_qual->ins_qual[d.seq].answer_type_text, asd.sub_answer_type_txt
       = foreign_ws_qual->ins_qual[d.seq].sub_answer_type_text,
      asd.answer_sub_ident = foreign_ws_qual->ins_qual[d.seq].answer_sub_ident, asd.rec_type_flag =
      foreign_ws_qual->ins_qual[d.seq].data_type_flag, asd.updt_dt_tm = cnvtdatetime(curdate,curtime),
      asd.updt_id = reqinfo->updt_id, asd.updt_task = reqinfo->updt_task, asd.updt_applctx = reqinfo
      ->updt_applctx,
      asd.updt_cnt = 0
     PLAN (d
      WHERE (foreign_ws_qual->ins_qual[d.seq].case_worksheet_id > 0)
       AND (foreign_ws_qual->ins_qual[d.seq].ap_case_synoptic_ws_data_id > 0))
      JOIN (asd)
     WITH nocounter
    ;end insert
    IF (curqual=ws_data_cnt)
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE populateqapairfields(insidx)
   DECLARE field_idx = i4 WITH protect, noconstant(0)
   SET foreign_ws_qual->ins_qual[insidx].question_concept_cki = curquesanspair->question_concept_cki
   SET foreign_ws_qual->ins_qual[insidx].answer_concept_cki = curquesanspair->answer_concept_cki
   SET foreign_ws_qual->ins_qual[insidx].answer_value = curquesanspair->answer_value
   SET foreign_ws_qual->ins_qual[insidx].answer_unit = curquesanspair->answer_unit
   SET foreign_ws_qual->ins_qual[insidx].answer_text_format_cd = curquesanspair->
   answer_text_format_cd
   SET foreign_ws_qual->ins_qual[insidx].answer_type_flag = curquesanspair->answer_type_flag
   FOR (field_idx = 1 TO size(curquesanspair->fields,5))
     CASE (nullterm(cnvtlower(curquesanspair->fields[field_idx].field_name)))
      OF ws_fld_question_ckey:
       SET foreign_ws_qual->ins_qual[insidx].question_concept_cki = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_ckey:
       SET foreign_ws_qual->ins_qual[insidx].answer_concept_cki = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_value:
       SET foreign_ws_qual->ins_qual[insidx].answer_value = nullterm(curquesanspair->fields[field_idx
        ].field_value_str)
      OF ws_fld_answer_unit:
       SET foreign_ws_qual->ins_qual[insidx].answer_unit_ident = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_cer_ans_txt_format_cd:
       SET foreign_ws_qual->ins_qual[insidx].answer_text_format_cd = curquesanspair->fields[field_idx
       ].field_value_dbl
      OF ws_fld_cer_ans_type:
       SET foreign_ws_qual->ins_qual[insidx].answer_type_flag = curquesanspair->fields[field_idx].
       field_value_num
      OF ws_fld_question_text:
       SET foreign_ws_qual->ins_qual[insidx].question_desc = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_question_coding_sys:
       SET foreign_ws_qual->ins_qual[insidx].question_coding_sys = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_text:
       SET foreign_ws_qual->ins_qual[insidx].answer_desc = nullterm(curquesanspair->fields[field_idx]
        .field_value_str)
      OF ws_fld_answer_coding_sys:
       SET foreign_ws_qual->ins_qual[insidx].answer_coding_sys = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_alt_question_ckey:
       SET foreign_ws_qual->ins_qual[insidx].alt_question_cki = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_alt_question_text:
       SET foreign_ws_qual->ins_qual[insidx].alt_question_desc = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_alt_question_coding_sys:
       SET foreign_ws_qual->ins_qual[insidx].alt_question_coding_sys = nullterm(curquesanspair->
        fields[field_idx].field_value_str)
      OF ws_fld_alt_answer_ckey:
       SET foreign_ws_qual->ins_qual[insidx].alt_answer_cki = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_alt_answer_text:
       SET foreign_ws_qual->ins_qual[insidx].alt_answer_desc = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_alt_answer_coding_sys:
       SET foreign_ws_qual->ins_qual[insidx].alt_answer_coding_sys = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_unit_text:
       SET foreign_ws_qual->ins_qual[insidx].answer_unit_desc = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_unit_coding_sys:
       SET foreign_ws_qual->ins_qual[insidx].answer_unit_coding_sys = nullterm(curquesanspair->
        fields[field_idx].field_value_str)
      OF ws_fld_sub_answer_type:
       SET foreign_ws_qual->ins_qual[insidx].sub_answer_type_text = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_answer_sub_ident:
       SET foreign_ws_qual->ins_qual[insidx].answer_sub_ident = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
      OF ws_fld_data_type_flag:
       SET foreign_ws_qual->ins_qual[insidx].data_type_flag = curquesanspair->fields[field_idx].
       field_value_num
      OF ws_fld_answer_type:
       SET foreign_ws_qual->ins_qual[insidx].answer_type_text = nullterm(curquesanspair->fields[
        field_idx].field_value_str)
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE checkcodeset(dcodeval,lcodeset,smeaning)
  IF (dcodeval <= 0)
   CALL subevent_add("ERROR","F",sscript,build("An error occured retrieving ",smeaning,
     " for codeset: ",lcodeset))
   RETURN(nsub_error)
  ENDIF
  RETURN(nsub_success)
 END ;Subroutine
 DECLARE ninscount = i4 WITH protect, noconstant(0)
 DECLARE nupdcount = i4 WITH protect, noconstant(0)
 DECLARE ndelcount = i4 WITH protect, noconstant(0)
 DECLARE nreplycount = i4 WITH protect, noconstant(0)
 DECLARE sfailed = c1 WITH protect, noconstant("N")
 DECLARE long_text_d_cnt = i4 WITH protect, noconstant(0)
 DECLARE legacy_fe = i2 WITH protect, noconstant(0)
 DECLARE nforeignwsdatacount = i4 WITH protect, noconstant(0)
 DECLARE nwsdataidx = i4 WITH protect, noconstant(0)
 DECLARE nlocator = i4 WITH protect, noconstant(0)
 DECLARE nwsckeyidx = i4 WITH protect, noconstant(0)
 DECLARE reqwsidx = i4 WITH protect, noconstant(0)
 DECLARE statidx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF (checkcodeset(active_status_cd,48,"ACTIVE")=nsub_error)
  SET sfailed = "F"
  GO TO exit_script
 ENDIF
 SET nreplycount = 0
 IF (size(request->ins_qual,5) > 0)
  EXECUTE gm_i_ap_case_syno7778_def
  DECLARE gm_i_ap_case_syno7778_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_ap_case_syno7778_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) = i2
  DECLARE gm_i_ap_case_syno7778_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) = i2
  SUBROUTINE gm_i_ap_case_syno7778_f8(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "case_specimen_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].case_specimen_id = ival
      SET gm_i_ap_case_syno7778_req->case_specimen_idi = 1
     OF "scr_pattern_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].scr_pattern_id = ival
      SET gm_i_ap_case_syno7778_req->scr_pattern_idi = 1
     OF "scd_story_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].scd_story_id = ival
      SET gm_i_ap_case_syno7778_req->scd_story_idi = 1
     OF "task_assay_cd":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].task_assay_cd = ival
      SET gm_i_ap_case_syno7778_req->task_assay_cdi = 1
     OF "report_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].report_id = ival
      SET gm_i_ap_case_syno7778_req->report_idi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_ap_case_syno7778_i2(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "status_flag":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].status_flag = ival
      SET gm_i_ap_case_syno7778_req->status_flagi = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_i_ap_case_syno7778_i4(icol_name,ival,iqual,null_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_i_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_i_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "sequence":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_i_ap_case_syno7778_req->qual[iqual].sequence = ival
      SET gm_i_ap_case_syno7778_req->sequencei = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_i_ap_case_syno7778_req->allow_partial_ind = 0
  SET gm_i_ap_case_syno7778_req->case_specimen_idi = 1
  SET gm_i_ap_case_syno7778_req->sequencei = 1
  SET gm_i_ap_case_syno7778_req->scr_pattern_idi = 1
  SET gm_i_ap_case_syno7778_req->scd_story_idi = 1
  SET gm_i_ap_case_syno7778_req->task_assay_cdi = 1
  SET gm_i_ap_case_syno7778_req->report_idi = 1
  SET gm_i_ap_case_syno7778_req->status_flagi = 1
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(size(request->ins_qual,5)))
   PLAN (d)
   DETAIL
    ninscount = (ninscount+ 1), stat = alterlist(gm_i_ap_case_syno7778_req->qual,ninscount),
    gm_i_ap_case_syno7778_req->qual[ninscount].case_specimen_id = request->ins_qual[d.seq].
    case_specimen_id,
    gm_i_ap_case_syno7778_req->qual[ninscount].sequence = request->ins_qual[d.seq].sequence,
    gm_i_ap_case_syno7778_req->qual[ninscount].scr_pattern_id = request->ins_qual[d.seq].
    scr_pattern_id, gm_i_ap_case_syno7778_req->qual[ninscount].scd_story_id = request->ins_qual[d.seq
    ].scd_story_id,
    gm_i_ap_case_syno7778_req->qual[ninscount].task_assay_cd = request->ins_qual[d.seq].task_assay_cd,
    gm_i_ap_case_syno7778_req->qual[ninscount].report_id = request->ins_qual[d.seq].report_id,
    gm_i_ap_case_syno7778_req->qual[ninscount].status_flag = request->ins_qual[d.seq].status_flag,
    gm_i_ap_case_syno7778_req->qual[ninscount].foreign_ws_ident = null
    IF ((request->ins_qual[d.seq].foreign_ws_ident != null))
     IF (size(request->ins_qual[d.seq].foreign_ws_ident,1) > 0)
      gm_i_ap_case_syno7778_req->qual[ninscount].foreign_ws_ident = request->ins_qual[d.seq].
      foreign_ws_ident
     ENDIF
    ENDIF
    gm_i_ap_case_syno7778_req->qual[ninscount].foreign_ws_result_text = request->ins_qual[d.seq].
    foreign_ws_result_text, nwsckeyidx = locateval(nlocator,1,size(request->ins_qual[d.seq].
      foreign_ws_data,5),ws_ckey_type,request->ins_qual[d.seq].foreign_ws_data[nlocator].
     answer_type_flag)
    IF (nwsckeyidx > 0)
     gm_i_ap_case_syno7778_req->qual[ninscount].concept_cki = request->ins_qual[d.seq].
     foreign_ws_data[nwsckeyidx].question_concept_cki, gm_i_ap_case_syno7778_req->qual[ninscount].
     concept_ident = request->ins_qual[d.seq].foreign_ws_data[nwsckeyidx].answer_concept_cki
    ENDIF
   WITH nocounter
  ;end select
  EXECUTE gm_i_ap_case_syno7778  WITH replace("REQUEST","GM_I_AP_CASE_SYNO7778_REQ"), replace("REPLY",
   "GM_I_AP_CASE_SYNO7778_REP")
  IF ((gm_i_ap_case_syno7778_rep->status_data.status != "S"))
   SET sfailed = "F"
  ELSE
   IF ((request->process_foreign_ws_ind=1))
    SET nforeignwsdatacount = 0
    FOR (reqwsidx = 1 TO size(gm_i_ap_case_syno7778_rep->qual,5))
     SET legacy_fe = locateval(nlocator,1,size(request->ins_qual[reqwsidx].foreign_ws_data,5),
      ws_ckey_type,request->ins_qual[reqwsidx].foreign_ws_data[nlocator].answer_type_flag)
     FOR (nwsdataidx = 1 TO size(request->ins_qual[reqwsidx].foreign_ws_data,5))
       IF ((request->ins_qual[reqwsidx].foreign_ws_data[nwsdataidx].answer_type_flag != ws_ckey_type)
        AND ((legacy_fe < 1) OR ((request->ins_qual[reqwsidx].foreign_ws_data[nwsdataidx].
       question_concept_cki != "CAP_ECC!437728003"))) )
        SET nforeignwsdatacount = (nforeignwsdatacount+ 1)
        SET stat = alterlist(foreign_ws_qual->ins_qual,nforeignwsdatacount)
        SET foreign_ws_qual->ins_qual[nforeignwsdatacount].case_worksheet_id =
        gm_i_ap_case_syno7778_rep->qual[reqwsidx].case_worksheet_id
        IF (legacy_fe > 0)
         SET foreign_ws_qual->ins_qual[nforeignwsdatacount].legacy_mode = 1
        ENDIF
        SET curalias curquesanspair request->ins_qual[reqwsidx].foreign_ws_data[nwsdataidx]
        CALL populateqapairfields(nforeignwsdatacount)
        SET curalias curquesanspair off
       ENDIF
     ENDFOR
    ENDFOR
    IF (insertforeignwsdata(0)=0)
     SET sfailed = "F"
     CALL subevent_add("DISCRETE_DATA","F","SAVE","Failed to save delete data")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(gm_i_ap_case_syno7778_rep->qual,5)))
    PLAN (d)
    DETAIL
     nreplycount = (nreplycount+ 1), stat = alterlist(reply->ws_qual,nreplycount), reply->ws_qual[
     nreplycount].case_worksheet_id = gm_i_ap_case_syno7778_rep->qual[d.seq].case_worksheet_id,
     reply->ws_qual[nreplycount].updt_cnt = 0, reply->ws_qual[nreplycount].entity_key = request->
     ins_qual[d.seq].entity_key
    WITH nocounter
   ;end select
   IF ((request->report_stale_ind=1))
    UPDATE  FROM case_report cr,
      (dummyt d  WITH seq = value(size(request->ins_qual,5)))
     SET cr.synoptic_stale_dt_tm = cnvtdatetime(request->report_stale_dt_tm)
     PLAN (d)
      JOIN (cr
      WHERE (request->ins_qual[d.seq].report_id=cr.report_id))
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  EXECUTE gm_i_ap_case_syno7778_cln
 ENDIF
 IF (size(request->upd_qual,5) > 0
  AND sfailed="N")
  EXECUTE gm_u_ap_case_syno7778_def
  DECLARE gm_u_ap_case_syno7778_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_ap_case_syno7778_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  DECLARE gm_u_ap_case_syno7778_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
  SUBROUTINE gm_u_ap_case_syno7778_f8(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "case_worksheet_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->case_worksheet_idf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].case_worksheet_id = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->case_worksheet_idw = 1
      ENDIF
     OF "case_specimen_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->case_specimen_idf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].case_specimen_id = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->case_specimen_idw = 1
      ENDIF
     OF "scr_pattern_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->scr_pattern_idf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].scr_pattern_id = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->scr_pattern_idw = 1
      ENDIF
     OF "scd_story_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->scd_story_idf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].scd_story_id = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->scd_story_idw = 1
      ENDIF
     OF "task_assay_cd":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->task_assay_cdf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].task_assay_cd = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->task_assay_cdw = 1
      ENDIF
     OF "report_id":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->report_idf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].report_id = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->report_idw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_ap_case_syno7778_i2(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "status_flag":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->status_flagf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].status_flag = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->status_flagw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SUBROUTINE gm_u_ap_case_syno7778_i4(icol_name,ival,iqual,null_ind,wq_ind)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_u_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_u_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "sequence":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->sequencef = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].sequence = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->sequencew = 1
      ENDIF
     OF "updt_cnt":
      IF (null_ind=1)
       CALL echo("error can not set this column to null")
       RETURN(0)
      ENDIF
      SET gm_u_ap_case_syno7778_req->updt_cntf = 1
      SET gm_u_ap_case_syno7778_req->qual[iqual].updt_cnt = ival
      IF (wq_ind=1)
       SET gm_u_ap_case_syno7778_req->updt_cntw = 1
      ENDIF
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_u_ap_case_syno7778_req->allow_partial_ind = 0
  SET gm_u_ap_case_syno7778_req->case_worksheet_idw = 1
  SET gm_u_ap_case_syno7778_req->updt_cntw = 1
  SET gm_u_ap_case_syno7778_req->case_specimen_idf = 1
  SET gm_u_ap_case_syno7778_req->sequencef = 1
  SET gm_u_ap_case_syno7778_req->scr_pattern_idf = 1
  SET gm_u_ap_case_syno7778_req->scd_story_idf = 1
  SET gm_u_ap_case_syno7778_req->task_assay_cdf = 1
  SET gm_u_ap_case_syno7778_req->report_idf = 1
  SET gm_u_ap_case_syno7778_req->status_flagf = 1
  SET gm_u_ap_case_syno7778_req->process_foreign_ws_ind = request->process_foreign_ws_ind
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(size(request->upd_qual,5)))
   PLAN (d)
   DETAIL
    nupdcount = (nupdcount+ 1), stat = alterlist(gm_u_ap_case_syno7778_req->qual,nupdcount),
    gm_u_ap_case_syno7778_req->qual[nupdcount].case_worksheet_id = request->upd_qual[d.seq].
    case_worksheet_id,
    gm_u_ap_case_syno7778_req->qual[nupdcount].case_specimen_id = request->upd_qual[d.seq].
    case_specimen_id, gm_u_ap_case_syno7778_req->qual[nupdcount].sequence = request->upd_qual[d.seq].
    sequence, gm_u_ap_case_syno7778_req->qual[nupdcount].scr_pattern_id = request->upd_qual[d.seq].
    scr_pattern_id,
    gm_u_ap_case_syno7778_req->qual[nupdcount].scd_story_id = request->upd_qual[d.seq].scd_story_id,
    gm_u_ap_case_syno7778_req->qual[nupdcount].task_assay_cd = request->upd_qual[d.seq].task_assay_cd,
    gm_u_ap_case_syno7778_req->qual[nupdcount].report_id = request->upd_qual[d.seq].report_id,
    gm_u_ap_case_syno7778_req->qual[nupdcount].status_flag = request->upd_qual[d.seq].status_flag,
    gm_u_ap_case_syno7778_req->qual[nupdcount].updt_cnt = request->upd_qual[d.seq].updt_cnt,
    gm_u_ap_case_syno7778_req->qual[nupdcount].foreign_ws_ident = null
    IF ((request->upd_qual[d.seq].foreign_ws_ident != null))
     IF (size(request->upd_qual[d.seq].foreign_ws_ident,1) > 0)
      gm_u_ap_case_syno7778_req->qual[nupdcount].foreign_ws_ident = request->upd_qual[d.seq].
      foreign_ws_ident
     ENDIF
    ENDIF
    gm_u_ap_case_syno7778_req->qual[nupdcount].foreign_ws_result_text = request->upd_qual[d.seq].
    foreign_ws_result_text, nwsckeyidx = locateval(nlocator,1,size(request->upd_qual[d.seq].
      foreign_ws_data,5),ws_ckey_type,request->upd_qual[d.seq].foreign_ws_data[nlocator].
     answer_type_flag)
    IF (nwsckeyidx > 0)
     gm_u_ap_case_syno7778_req->qual[nupdcount].concept_cki = request->upd_qual[d.seq].
     foreign_ws_data[nwsckeyidx].question_concept_cki, gm_u_ap_case_syno7778_req->qual[nupdcount].
     concept_ident = request->upd_qual[d.seq].foreign_ws_data[nwsckeyidx].answer_concept_cki
    ENDIF
    IF (size(request->upd_qual[d.seq].foreign_ws_data,5) > 0)
     stat = moverec(request->upd_qual[d.seq].foreign_ws_data,gm_u_ap_case_syno7778_req->qual[
      nupdcount].foreign_ws_data)
    ENDIF
   WITH nocounter
  ;end select
  EXECUTE gm_u_ap_case_syno7778  WITH replace("REQUEST","GM_U_AP_CASE_SYNO7778_REQ"), replace("REPLY",
   "GM_U_AP_CASE_SYNO7778_REP")
  IF ((gm_u_ap_case_syno7778_rep->status_data.status != "S"))
   SET sfailed = "F"
   FOR (statidx = 1 TO size(gm_u_ap_case_syno7778_rep->status_data.subeventstatus,5))
     CALL subevent_add(gm_u_ap_case_syno7778_rep->status_data.subeventstatus[statidx].operationname,
      gm_u_ap_case_syno7778_rep->status_data.subeventstatus[statidx].operationstatus,
      gm_u_ap_case_syno7778_rep->status_data.subeventstatus[statidx].targetobjectname,
      gm_u_ap_case_syno7778_rep->status_data.subeventstatus[statidx].targetobjectvalue)
   ENDFOR
  ELSE
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(gm_u_ap_case_syno7778_rep->qual,5)))
    PLAN (d)
    DETAIL
     nreplycount = (nreplycount+ 1), stat = alterlist(reply->ws_qual,nreplycount), reply->ws_qual[
     nreplycount].updt_cnt = (request->upd_qual[d.seq].updt_cnt+ 1),
     reply->ws_qual[nreplycount].entity_key = request->upd_qual[d.seq].entity_key
    WITH nocounter
   ;end select
   IF ((request->report_stale_ind=1))
    UPDATE  FROM case_report cr,
      (dummyt d  WITH seq = value(size(request->upd_qual,5)))
     SET cr.synoptic_stale_dt_tm = cnvtdatetime(request->report_stale_dt_tm)
     PLAN (d)
      JOIN (cr
      WHERE (request->upd_qual[d.seq].report_id=cr.report_id))
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  EXECUTE gm_u_ap_case_syno7778_cln
 ENDIF
 IF (size(request->del_qual,5) > 0
  AND sfailed="N")
  EXECUTE gm_d_ap_case_syno7778_def
  DECLARE gm_d_ap_case_syno7778_f8(icol_name=vc,ival=f8,iqual=i4) = i2
  SUBROUTINE gm_d_ap_case_syno7778_f8(icol_name,ival,iqual)
    DECLARE stat = i2 WITH protect, noconstant(0)
    IF (size(gm_d_ap_case_syno7778_req->qual,5) < iqual)
     SET stat = alterlist(gm_d_ap_case_syno7778_req->qual,iqual)
     IF (stat=0)
      CALL echo("can not expand request structure")
      RETURN(0)
     ENDIF
    ENDIF
    CASE (cnvtlower(icol_name))
     OF "case_worksheet_id":
      SET gm_d_ap_case_syno7778_req->qual[iqual].case_worksheet_id = ival
      SET gm_d_ap_case_syno7778_req->case_worksheet_idw = 1
     OF "case_specimen_id":
      SET gm_d_ap_case_syno7778_req->qual[iqual].case_specimen_id = ival
      SET gm_d_ap_case_syno7778_req->case_specimen_idw = 1
     OF "report_id":
      SET gm_d_ap_case_syno7778_req->qual[iqual].report_id = ival
      SET gm_d_ap_case_syno7778_req->report_idw = 1
     ELSE
      CALL echo("invalid column name passed")
      RETURN(0)
    ENDCASE
    RETURN(1)
  END ;Subroutine
  SET gm_d_ap_case_syno7778_req->allow_partial_ind = 0
  SET gm_d_ap_case_syno7778_req->case_worksheet_idw = 1
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(size(request->del_qual,5)))
   PLAN (d)
   DETAIL
    ndelcount = (ndelcount+ 1), stat = alterlist(gm_d_ap_case_syno7778_req->qual,ndelcount),
    gm_d_ap_case_syno7778_req->qual[ndelcount].case_worksheet_id = request->del_qual[d.seq].
    case_worksheet_id,
    stat = alterlist(foreign_ws_qual->del_qual,ndelcount), foreign_ws_qual->del_qual[ndelcount].
    case_worksheet_id = request->del_qual[d.seq].case_worksheet_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   d.seq
   FROM ap_case_synoptic_ws z,
    (dummyt d  WITH seq = value(size(request->del_qual,5)))
   PLAN (d)
    JOIN (z
    WHERE (z.case_worksheet_id=request->del_qual[d.seq].case_worksheet_id))
   DETAIL
    gm_d_ap_case_syno7778_req->qual[d.seq].foreign_ws_result_text_id = z.foreign_ws_result_text_id
    IF ((gm_d_ap_case_syno7778_req->qual[d.seq].foreign_ws_result_text_id > 0))
     long_text_d_cnt = (long_text_d_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  IF (deleteforeignwsdata(0) != 1)
   CALL subevent_add("DELETE","F","TABLE","AP_CASE_SYNOPTIC_WS_DATA")
   SET sfailed = "F"
   GO TO exit_script
  ENDIF
  DELETE  FROM ap_case_synoptic_ws ap,
    (dummyt d  WITH seq = value(size(request->del_qual,5)))
   SET ap.seq = 1
   PLAN (d)
    JOIN (ap
    WHERE (ap.case_worksheet_id=request->del_qual[d.seq].case_worksheet_id))
   WITH nocounter
  ;end delete
  IF (curqual != ndelcount)
   SET sfailed = "F"
  ENDIF
  IF (long_text_d_cnt > 0)
   DELETE  FROM long_text lt,
     (dummyt d  WITH seq = value(size(gm_d_ap_case_syno7778_req->qual,5)))
    SET lt.seq = 1
    PLAN (d
     WHERE (gm_d_ap_case_syno7778_req->qual[d.seq].foreign_ws_result_text_id > 0))
     JOIN (lt
     WHERE (lt.long_text_id=gm_d_ap_case_syno7778_req->qual[d.seq].foreign_ws_result_text_id))
    WITH nocounter
   ;end delete
   IF (curqual != long_text_d_cnt)
    CALL subevent_add("DELETE","F","TABLE","LONG_TEXT")
    SET sfailed = "F"
    GO TO exit_script
   ENDIF
  ENDIF
  EXECUTE gm_d_ap_case_syno7778_cln
 ENDIF
#exit_script
 IF (sfailed="N")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
