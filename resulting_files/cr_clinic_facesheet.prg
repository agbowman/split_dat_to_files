CREATE PROGRAM cr_clinic_facesheet
 CALL echo("<===== ESO_EFFECTIVE_TIME_ADJUST.INC  START =====>")
 CALL echo("MOD:000")
 CALL echo("<===== ESO_GET_CODE.INC Begin =====>")
 CALL echo("MOD:008")
 DECLARE eso_get_code_meaning(code) = c12
 DECLARE eso_get_code_display(code) = c40
 DECLARE eso_get_meaning_by_codeset(x_code_set,x_meaning) = f8
 DECLARE eso_get_code_set(code) = i4
 DECLARE eso_get_alias_or_display(code,contrib_src_cd) = vc
 SUBROUTINE eso_get_code_meaning(code)
   CALL echo("Entering eso_get_code_meaning subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_meaning
   DECLARE t_meaning = c12
   SET t_meaning = fillstring(12," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("    A Readme is calling this script")
     CALL echo("    selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_meaning = cv.cdf_meaning
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_meaning = uar_get_code_meaning(cnvtreal(code))
     IF (trim(t_meaning)="")
      CALL echo("    uar_get_code_meaning failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_meaning = cv.cdf_meaning
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_meaning=",t_meaning))
   CALL echo("Exiting eso_get_code_meaning subroutine")
   RETURN(trim(t_meaning,3))
 END ;Subroutine
 SUBROUTINE eso_get_code_display(code)
   CALL echo("Entering eso_get_code_display subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_display
   DECLARE t_display = c40
   SET t_display = fillstring(40," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_display = cv.display
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_display = uar_get_code_display(cnvtreal(code))
     IF (trim(t_display)="")
      CALL echo("    uar_get_code_display failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_display = cv.display
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_display=",t_display))
   CALL echo("Exiting eso_get_code_display subroutine")
   RETURN(trim(t_display,3))
 END ;Subroutine
 SUBROUTINE eso_get_meaning_by_codeset(x_code_set,x_meaning)
   CALL echo("Entering eso_get_meaning_by_codeset subroutine")
   CALL echo(build("    code_set=",x_code_set))
   CALL echo(build("    meaning=",x_meaning))
   FREE SET t_code
   DECLARE t_code = f8
   SET t_code = 0.0
   IF (x_code_set > 0
    AND trim(x_meaning) > "")
    FREE SET t_meaning
    DECLARE t_meaning = c12
    SET t_meaning = fillstring(12," ")
    SET t_meaning = x_meaning
    FREE SET t_rc
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_set=x_code_set
       AND cv.cdf_meaning=trim(x_meaning)
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_code = cv.code_value
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_rc = uar_get_meaning_by_codeset(cnvtint(x_code_set),nullterm(t_meaning),1,t_code)
     IF (t_code <= 0)
      CALL echo("    uar_get_meaning_by_codeset failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.cdf_meaning=trim(x_meaning)
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_code=",t_code))
   CALL echo("Exiting eso_get_meaning_by_codeset subroutine")
   RETURN(t_code)
 END ;Subroutine
 SUBROUTINE eso_get_code_set(code)
   CALL echo("Entering eso_get_code_set subroutine")
   CALL echo(build("    code=",code))
   DECLARE icode_set = i4 WITH private, noconstant(0)
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rowS from code_value table")
     SELECT INTO "nl:"
      cv.code_set
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       icode_set = cv.code_set
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET icode_set = uar_get_code_set(cnvtreal(code))
     IF ( NOT (icode_set > 0))
      CALL echo("    uar_get_code_set failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.code_set
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        icode_set = cv.code_set
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    Code_set=",icode_set))
   CALL echo("Exiting eso_get_code_set subroutine")
   RETURN(icode_set)
 END ;Subroutine
 SUBROUTINE eso_get_alias_or_display(code,contrib_src_cd)
   CALL echo("Entering eso_get_alias_or_display")
   CALL echo(build("   code            = ",code))
   CALL echo(build("   contrib_src_cd = ",contrib_src_cd))
   FREE SET t_alias_or_display
   DECLARE t_alias_or_display = vc
   SET t_alias_or_display = " "
   IF ( NOT (code > 0.0))
    RETURN(t_alias_or_display)
   ENDIF
   IF (contrib_src_cd > 0.0)
    SELECT INTO "nl:"
     cvo.alias
     FROM code_value_outbound cvo
     WHERE cvo.code_value=code
      AND cvo.contributor_source_cd=contrib_src_cd
     DETAIL
      IF (cvo.alias > "")
       t_alias_or_display = cvo.alias
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(trim(t_alias_or_display))=0)
    CALL echo("Alias not found, checking code value display")
    SET t_alias_or_display = eso_get_code_display(code)
   ENDIF
   CALL echo("Exiting eso_get_alias_or_display")
   RETURN(t_alias_or_display)
 END ;Subroutine
 CALL echo("<===== ESO_GET_CODE.INC End =====>")
 IF ( NOT (validate(g_desoefftmadj)))
  DECLARE desoefftmadjtmp = f8 WITH protect, noconstant(0.0)
  DECLARE desoeffectivetimeadjustcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,
    "ESOEFFTMADJ"))
  DECLARE desocontribdefault = f8 WITH protect, constant(eso_get_meaning_by_codeset(89,"ESODEFAULT"))
  SELECT INTO "nl:"
   op.contributor_system_cd, op.process_type_cd, op.null_string
   FROM outbound_field_processing op
   WHERE op.contributor_system_cd=desocontribdefault
    AND op.process_type_cd=desoeffectivetimeadjustcd
   DETAIL
    desoefftmadjtmp = (100 * cnvtreal(op.null_string))
   WITH nocounter
  ;end select
  DECLARE g_desoefftmadj = f8 WITH persist, constant(desoefftmadjtmp)
 ENDIF
 IF (validate(rp_hl7_form->initialized,"!")="!")
  SET trace = recpersist
  RECORD rp_hl7_form(
    1 initialized = c1
    1 current_name_cd = f8
  )
  SET trace = norecpersist
  SET rp_hl7_form->initialized = "Y"
  SET rp_hl7_form->current_name_cd = 0
  SELECT INTO "nl:"
   c.seq
   FROM code_value c
   WHERE c.code_set=213
    AND c.cdf_meaning="CURRENT"
    AND c.active_ind=1
    AND begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
   DETAIL
    rp_hl7_form->current_name_cd = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET prv_alias = 1
 SET prv_last_name = 2
 SET prv_first_name = 3
 SET prv_middle_name = 4
 SET prv_name_full_formatted = 5
 SET prv_prefix = 6
 SET prv_suffix = 7
 SET prv_degree = 8
 SET prv_username = 9
 DECLARE pm_hl7_provider(prv_row_id,prv_option) = c100
 SUBROUTINE pm_hl7_provider(prv_row_id,prv_option)
   SET prv_rtn_string = fillstring(132," ")
   SET prv_last_name_st = fillstring(132," ")
   SET prv_first_name_st = fillstring(132," ")
   SET prv_name_full_formatted_st = fillstring(132," ")
   SET prv_middle_name_st = fillstring(132," ")
   SET prv_suffix_st = fillstring(132," ")
   SET prv_prefix_st = fillstring(132," ")
   SET prv_free_text = false
   SET prv_username_st = fillstring(50," ")
   SELECT INTO "nl:"
    p.seq
    FROM prsnl p
    WHERE p.person_id=prv_row_id
    DETAIL
     prv_free_text = p.free_text_ind, prv_last_name_st = p.name_last, prv_first_name_st = p
     .name_first,
     prv_name_full_formatted_st = p.name_full_formatted, prv_username_st = p.username
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CASE (prv_option)
     OF prv_alias:
      SET prv_rtn_string = " "
     OF prv_last_name:
      SET prv_rtn_string = prv_last_name_st
     OF prv_first_name:
      SET prv_rtn_string = prv_first_name_st
     OF prv_name_full_formatted:
      SET prv_rtn_string = prv_name_full_formatted_st
     OF prv_username:
      SET prv_rtn_string = prv_username_st
     OF prv_middle_name:
      IF (prv_free_text=true)
       SET rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
        DETAIL
         prv_rtn_string = n.name_middle
        WITH nocounter
       ;end select
      ENDIF
     OF prv_prefix:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
        DETAIL
         prv_rtn_string = n.name_prefix
        WITH nocounter
       ;end select
      ENDIF
     OF prv_suffix:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
        DETAIL
         prv_rtn_string = n.name_suffix
        WITH nocounter
       ;end select
      ENDIF
     OF prv_degree:
      IF (prv_free_text=true)
       SET prv_rtn_string = " "
      ELSE
       SELECT INTO "nl:"
        n.seq
        FROM person_name n
        WHERE n.person_id=prv_row_id
         AND (n.name_type_cd=rp_hl7_form->current_name_cd)
         AND n.active_ind=1
         AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
         AND n.end_effective_dt_tm >= cnvtdatetime(curdate,(curtime3+ g_desoefftmadj))
        DETAIL
         prv_rtn_string = n.name_degree
        WITH nocounter
       ;end select
      ENDIF
    ENDCASE
   ENDIF
   RETURN(prv_rtn_string)
 END ;Subroutine
#initialize
 SET line1 = fillstring(95,"_")
 SET cur_person_id = request->patient_data.person.person_id
 SET cur_encntr_id = request->patient_data.person.encounter.encntr_id
 SET vnbr_alias = request->patient_data.person.encounter.visitnbr.alias
 SET vnbr_format = request->patient_data.person.encounter.visitnbr.alias_pool_cd
 SET vnbr = substring(1,15,cnvtalias(vnbr_alias,vnbr_format))
 SET fnbr_alias = request->patient_data.person.encounter.finnbr.alias
 SET fnbr_format = request->patient_data.person.encounter.finnbr.alias_pool_cd
 SET fnbr = substring(1,15,cnvtalias(fnbr_alias,fnbr_format))
 SET barcode_fnbr = concat("*",cnvtalphanum(fnbr_alias),"*")
 DECLARE track_type = f8
 SET track_id = 0
 SET track_type_dp = fillstring(2," ")
 SET track = fillstring(13," ")
 SELECT INTO "nl:"
  mm.media_type_cd, ma.alias
  FROM media_master mm,
   media_master_alias ma
  PLAN (mm
   WHERE mm.person_id=cur_person_id
    AND mm.encntr_id=cur_encntr_id
    AND mm.active_ind=1
    AND mm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mm.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ma
   WHERE mm.media_master_id=ma.media_master_id
    AND ma.active_ind=1
    AND ma.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ma.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   track_type = mm.media_type_cd, track_id = ma.alias
 ;end select
 SET pat_mrn = request->patient_data.person.mrn.alias
 SET pat_name = substring(1,25,request->patient_data.person.name_full_formatted)
 SET upat_name = cnvtupper(substring(1,25,request->patient_data.person.name_full_formatted))
 SET pat_dob = format(request->patient_data.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET pat_age = cnvtage(cnvtdate(request->patient_data.person.birth_dt_tm),cnvttime(request->
   patient_data.person.birth_dt_tm))
 SET upat_age = cnvtupper(cnvtage(cnvtdate(request->patient_data.person.birth_dt_tm),cnvttime(request
    ->patient_data.person.birth_dt_tm)))
 SET pat_prev_name = substring(1,20,request->patient_data.person.preferred_name.name_first)
 SET ssn_alias = request->patient_data.person.ssn.alias
 SET ssn_format = request->patient_data.person.ssn.alias_pool_cd
 SET pat_ssn = substring(1,15,cnvtalias(ssn_alias,ssn_format))
 SET pat_hm_addr = substring(1,50,request->patient_data.person.alt_address.street_addr)
 SET pat_hm_addr2 = substring(1,50,request->patient_data.person.alt_address.street_addr2)
 SET pat_hm_city = substring(1,25,request->patient_data.person.alt_address.city)
 SET pat_hm_zipcode = substring(1,12,request->patient_data.person.alt_address.zipcode)
 SET pat_hm_city_st = fillstring(30," ")
 SET hm_ph_num = request->patient_data.person.alt_phone.phone_num
 SET hm_ph_frm = request->patient_data.person.alt_phone.phone_format_cd
 SET pat_hm_phone = substring(1,25,cnvtphone(hm_ph_num,hm_ph_frm))
 SET pat_hm_ph_comment = request->patient_data.person.alt_phone.call_instruction
 SET pat_empl_name = substring(1,40,request->patient_data.person.employer_01.ft_org_name)
 SET pat_empl_job = substring(1,10,uar_get_code_display(request->patient_data.person.employer_01.
   empl_status_cd))
 SET wk_ph_num = request->patient_data.person.alt_pager.phone_num
 SET wk_ph_frm = request->patient_data.person.alt_pager.phone_format_cd
 SET pat_wk_phone = substring(1,25,cnvtphone(wk_ph_num,wk_ph_frm))
 SET pat_wk_ext = substring(1,10,request->patient_data.person.alt_pager.paging_code)
 SET pat_wkph_comment = request->patient_data.person.alt_pager.call_instruction
 SET pat_empl_addr = substring(1,30,request->patient_data.person.employer_01.address.street_addr)
 SET pat_empl_addr2 = substring(1,30,request->patient_data.person.employer_01.address.street_addr2)
 SET pat_empl_addr2_dp = fillstring(30," ")
 SET pat_empl_city = substring(1,25,request->patient_data.person.employer_01.address.city)
 SET pat_empl_zipcode = substring(1,12,request->patient_data.person.employer_01.address.zipcode)
 SET pat_empl_city_st = fillstring(30," ")
 SET pat_person_comments = substring(1,100,request->patient_data.person.comment_01.long_text)
 SET pat_person_comments1 = trim(substring(1,50,pat_person_comments))
 SET gua_reltn_cd = request->patient_data.person.guarantor_01.person_reltn_cd
 SET gua_mrn = substring(1,10,request->patient_data.person.guarantor_01.person.mrn.alias)
 SET gua_name = substring(1,25,request->patient_data.person.guarantor_01.person.name_full_formatted)
 SET gua_dob = format(request->patient_data.person.guarantor_01.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET gua_age = cnvtage(cnvtdate(request->patient_data.person.guarantor_01.person.birth_dt_tm),
  cnvttime(request->patient_data.person.guarantor_01.person.birth_dt_tm))
 SET gua_ssn_alias = request->patient_data.person.guarantor_01.person.ssn.alias
 SET gua_ssn_format = request->patient_data.person.guarantor_01.person.ssn.alias_pool_cd
 SET gua_ssn = substring(1,15,cnvtalias(gua_ssn_alias,gua_ssn_format))
 SET gua_hm_addr = substring(1,50,request->patient_data.person.guarantor_01.person.home_address.
  street_addr)
 SET gua_hm_addr2 = substring(1,50,request->patient_data.person.guarantor_01.person.home_address.
  street_addr2)
 SET gua_hm_city = substring(1,25,request->patient_data.person.guarantor_01.person.home_address.city)
 SET gua_hm_zipcode = substring(1,12,request->patient_data.person.guarantor_01.person.home_address.
  zipcode)
 SET gua_hm_city_st = fillstring(30," ")
 SET gua_hm_ph_num = request->patient_data.person.guarantor_01.person.home_phone.phone_num
 SET gua_hm_ph_frm = request->patient_data.person.guarantor_01.person.home_phone.phone_format_cd
 SET gua_hm_phone = substring(1,25,cnvtphone(gua_hm_ph_num,gua_hm_ph_frm))
 SET gua_hm_ph_comment = request->patient_data.person.guarantor_01.person.home_phone.call_instruction
 SET gua_empl_name = substring(1,40,request->patient_data.person.guarantor_01.person.employer_01.
  ft_org_name)
 SET gua_empl_job = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  empl_occupation_text)
 SET gua_wk_ph_num = request->patient_data.person.guarantor_01.person.bus_phone.phone_num
 SET gua_wk_ph_frm = request->patient_data.person.guarantor_01.person.bus_phone.phone_format_cd
 SET gua_wk_phone = substring(1,25,cnvtphone(gua_wk_ph_num,gua_wk_ph_frm))
 SET gua_wk_ph_comment = request->patient_data.person.guarantor_01.person.bus_phone.call_instruction
 SET gua_wk_ext = substring(1,5,request->patient_data.person.guarantor_01.person.bus_phone.extension)
 SET gua_empl_addr = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  address.street_addr)
 SET gua_empl_addr2 = substring(1,50,request->patient_data.person.guarantor_01.person.employer_01.
  address.street_addr2)
 SET gua_empl_addr2_dp = fillstring(30," ")
 SET gua_empl_city = substring(1,25,request->patient_data.person.guarantor_01.person.employer_01.
  address.city)
 SET gua_empl_zipcode = substring(1,12,request->patient_data.person.guarantor_01.person.employer_01.
  address.zipcode)
 SET gua_empl_city_st = fillstring(30," ")
 SET emc_name = substring(1,25,request->patient_data.person.nok.person.name_full_formatted)
 SET emc_dob = format(request->patient_data.person.nok.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET emc_age = cnvtage(cnvtdate(request->patient_data.person.nok.person.birth_dt_tm),cnvttime(request
   ->patient_data.person.nok.person.birth_dt_tm))
 SET emc_wk_ph_num = request->patient_data.person.nok.person.bus_phone.phone_num
 SET emc_wk_ph_frm = request->patient_data.person.nok.person.bus_phone.phone_format_cd
 SET emc_wk_phone = substring(1,25,cnvtphone(emc_wk_ph_num,emc_wk_ph_frm))
 SET emc_hm_addr = substring(1,50,request->patient_data.person.nok.person.home_address.street_addr)
 SET emc_hm_addr2 = substring(1,50,request->patient_data.person.nok.person.home_address.street_addr2)
 SET emc_hm_city = substring(1,25,request->patient_data.person.nok.person.home_address.city)
 SET emc_hm_zipcode = substring(1,12,request->patient_data.person.nok.person.home_address.zipcode)
 SET emc_hm_city_st = fillstring(30," ")
 SET emc_hm_ph_num = request->patient_data.person.nok.person.home_phone.phone_num
 SET emc_hm_ph_frm = request->patient_data.person.nok.person.home_phone.phone_format_cd
 SET emc_hm_phone = substring(1,25,cnvtphone(emc_hm_ph_num,emc_hm_ph_frm))
 SET emc_hm_comment = substring(1,20,request->patient_data.person.nok.person.home_phone.
  call_instruction)
 SET emc_wk_comment = substring(1,20,request->patient_data.person.nok.person.bus_phone.
  call_instruction)
 SET s1_last = substring(1,20,request->patient_data.person.subscriber_01.person.current_name.
  name_last)
 SET s1_first = substring(1,20,request->patient_data.person.subscriber_01.person.current_name.
  name_first)
 IF (textlen(trim(s1_last)) > 0)
  SET s1_name = concat(trim(s1_last),", ",trim(s1_first))
 ELSE
  SET s1_name = " "
 ENDIF
 SET s1_dob = format(request->patient_data.person.subscriber_01.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET s1_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_01.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_01.person.birth_dt_tm))
 SET s1_empl_name = substring(1,40,request->patient_data.person.subscriber_01.person.employer_01.
  ft_org_name)
 SET s1_empl_job = substring(1,20,request->patient_data.person.subscriber_01.person.employer_01.
  empl_occupation_text)
 SET s1_empl_addr = substring(1,50,request->patient_data.person.subscriber_01.person.employer_01.
  address.street_addr)
 SET s1_empl_addr2 = substring(1,50,request->patient_data.person.subscriber_01.person.employer_01.
  address.street_addr2)
 SET s1_empl_addr2_dp = fillstring(30," ")
 SET s1_empl_city = substring(1,25,request->patient_data.person.subscriber_01.person.employer_01.
  address.city)
 SET s1_empl_zipcode = substring(1,12,request->patient_data.person.subscriber_01.person.employer_01.
  address.zipcode)
 SET s1_empl_city_st = fillstring(30," ")
 SET s1_plan_name = substring(1,40,request->patient_data.person.subscriber_01.person.health_plan.
  plan_info.plan_name)
 SET s1_policy_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  member_nbr)
 SET s1_pat_policy_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  pat_member_nbr)
 SET s1_ph_num = request->patient_data.person.subscriber_01.person.health_plan.phone_num
 SET s1_ph_frm = request->patient_data.person.subscriber_01.person.health_plan.phone_format_cd
 SET s1_plan_phone = substring(1,25,cnvtphone(s1_ph_num,s1_ph_frm))
 SET s1_plan_addr = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.street_addr)
 SET s1_plan_addr2 = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.street_addr2)
 SET s1_plan_city = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.city)
 SET s1_plan_zipcode = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  address.zipcode)
 SET s1_plan_city_st = fillstring(30," ")
 SET s1_fin_class = request->patient_data.person.subscriber_01.person.health_plan.plan_info.
 financial_class_cd
 SET s1_precert_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  visit_info.auth_info_01.auth_nbr)
 SET s1_group_no = substring(1,20,request->patient_data.person.subscriber_01.person.health_plan.
  org_plan.group_nbr)
 SET s1_group_name = substring(1,17,request->patient_data.person.subscriber_01.person.health_plan.
  org_plan.group_name)
 SET s2_last = substring(1,20,request->patient_data.person.subscriber_02.person.current_name.
  name_last)
 SET s2_first = substring(1,20,request->patient_data.person.subscriber_02.person.current_name.
  name_first)
 IF (textlen(trim(s2_last)) > 0)
  SET s2_name = concat(trim(s2_last),", ",trim(s2_first))
 ELSE
  SET s2_name = " "
 ENDIF
 SET s2_dob = format(request->patient_data.person.subscriber_02.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET s2_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_02.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_02.person.birth_dt_tm))
 SET s2_empl_name = substring(1,40,request->patient_data.person.subscriber_02.person.employer_01.
  ft_org_name)
 SET s2_empl_job = substring(1,20,request->patient_data.person.subscriber_02.person.employer_01.
  empl_occupation_text)
 SET s2_empl_addr = substring(1,50,request->patient_data.person.subscriber_02.person.employer_01.
  address.street_addr)
 SET s2_empl_addr2 = substring(1,50,request->patient_data.person.subscriber_02.person.employer_01.
  address.street_addr2)
 SET s2_empl_addr2_dp = fillstring(30," ")
 SET s2_empl_city = substring(1,25,request->patient_data.person.subscriber_02.person.employer_01.
  address.city)
 SET s2_empl_zipcode = substring(1,12,request->patient_data.person.subscriber_02.person.employer_01.
  address.zipcode)
 SET s2_empl_city_st = fillstring(30," ")
 SET s2_plan_name = substring(1,40,request->patient_data.person.subscriber_02.person.health_plan.
  plan_info.plan_name)
 SET s2_policy_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  member_nbr)
 SET s2_pat_policy_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  pat_member_nbr)
 SET s2_ph_num = request->patient_data.person.subscriber_02.person.health_plan.phone_num
 SET s2_ph_frm = request->patient_data.person.subscriber_02.person.health_plan.phone_format_cd
 SET s2_plan_phone = substring(1,25,cnvtphone(s2_ph_num,s2_ph_frm))
 SET s2_plan_addr = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.street_addr)
 SET s2_plan_addr2 = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.street_addr2)
 SET s2_plan_city = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.city)
 SET s2_plan_zipcode = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  address.zipcode)
 SET s2_plan_city_st = fillstring(30," ")
 SET s2_precert_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  visit_info.auth_info_01.auth_nbr)
 SET s2_group_no = substring(1,20,request->patient_data.person.subscriber_02.person.health_plan.
  org_plan.group_nbr)
 SET s2_group_name = substring(1,17,request->patient_data.person.subscriber_02.person.health_plan.
  org_plan.group_name)
 SET s3_last = substring(1,20,request->patient_data.person.subscriber_03.person.current_name.
  name_last)
 SET s3_first = substring(1,20,request->patient_data.person.subscriber_03.person.current_name.
  name_first)
 IF (textlen(trim(s3_last)) > 0)
  SET s3_name = concat(trim(s3_last),", ",trim(s3_first))
 ELSE
  SET s3_name = " "
 ENDIF
 SET s3_dob = format(request->patient_data.person.subscriber_03.person.birth_dt_tm,"MM/DD/YYYY;;D")
 SET s3_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_03.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_03.person.birth_dt_tm))
 SET s3_empl_name = substring(1,40,request->patient_data.person.subscriber_03.person.employer_01.
  ft_org_name)
 SET s3_empl_job = substring(1,20,request->patient_data.person.subscriber_03.person.employer_01.
  empl_occupation_text)
 SET s3_empl_addr = substring(1,50,request->patient_data.person.subscriber_03.person.employer_01.
  address.street_addr)
 SET s3_empl_addr2 = substring(1,50,request->patient_data.person.subscriber_03.person.employer_01.
  address.street_addr2)
 SET s3_empl_addr2_dp = fillstring(30," ")
 SET s3_empl_city = substring(1,25,request->patient_data.person.subscriber_03.person.employer_01.
  address.city)
 SET s3_empl_zipcode = substring(1,12,request->patient_data.person.subscriber_03.person.employer_01.
  address.zipcode)
 SET s3_empl_city_st = fillstring(30," ")
 SET s3_plan_name = substring(1,40,request->patient_data.person.subscriber_03.person.health_plan.
  plan_info.plan_name)
 SET s3_policy_no = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  member_nbr)
 SET s3_pat_policy_no = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  pat_member_nbr)
 SET s3_ph_num = request->patient_data.person.subscriber_03.person.health_plan.phone_num
 SET s3_ph_frm = request->patient_data.person.subscriber_03.person.health_plan.phone_format_cd
 SET s3_plan_phone = substring(1,25,cnvtphone(s3_ph_num,s3_ph_frm))
 SET s3_plan_addr = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  address.street_addr)
 SET s3_plan_addr2 = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  address.street_addr2)
 SET s3_plan_city = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  address.city)
 SET s3_plan_zipcode = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  address.zipcode)
 SET s3_plan_city_st = fillstring(30," ")
 SET s3_precert_no = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  visit_info.auth_info_01.auth_nbr)
 SET s3_group_no = substring(1,20,request->patient_data.person.subscriber_03.person.health_plan.
  org_plan.group_nbr)
 SET s3_group_name = substring(1,17,request->patient_data.person.subscriber_03.person.health_plan.
  org_plan.group_name)
 SET wc_s4_plan_name = substring(1,30,request->patient_data.person.subscriber_04.person.health_plan.
  org_info.org_name)
 SET wc_s4_pt_ssn = substring(1,12,request->patient_data.person.subscriber_04.person.health_plan.
  pat_member_nbr)
 SET wc_s4_coverage_type = substring(1,15,uar_get_code_display(request->patient_data.person.
   subscriber_04.person.health_plan.coverage_type_cd))
 SET wc_s4_last = substring(1,20,request->patient_data.person.subscriber_04.person.current_name.
  name_last)
 SET wc_s4_first = substring(1,20,request->patient_data.person.subscriber_04.person.current_name.
  name_first)
 IF (textlen(trim(wc_s4_last)) > 0)
  SET wc_s4_name = concat(trim(wc_s4_last),", ",trim(wc_s4_first))
 ELSE
  SET wc_s4_name = " "
 ENDIF
 SET wc_s4_dob = format(request->patient_data.person.subscriber_04.person.birth_dt_tm,"MM/DD/YYYY;;D"
  )
 SET wc_s4_age = cnvtage(cnvtdate(request->patient_data.person.subscriber_04.person.birth_dt_tm),
  cnvttime(request->patient_data.person.subscriber_04.person.birth_dt_tm))
 SET wc_s4_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_04.
   person_reltn_cd))
 SET wc_s4_gender = uar_get_code_display(request->patient_data.person.subscriber_04.person.sex_cd)
 SET wc_s4_emp_name = substring(1,30,request->patient_data.person.subscriber_04.person.employer_01.
  ft_org_name)
 SET wc_s4_emp_status = uar_get_code_display(request->patient_data.person.subscriber_04.person.
  employer_01.empl_status_cd)
 SET cb_company_name = substring(1,40,request->patient_data.person.guarantor_01.guarantor_org.
  ft_org_name)
 SET cb_first_addr = substring(1,30,request->patient_data.person.guarantor_01.guarantor_org.address.
  street_addr)
 SET cb_second_addr = substring(1,30,request->patient_data.person.guarantor_01.guarantor_org.address.
  street_addr2)
 SET cb_city = substring(1,30,request->patient_data.person.guarantor_01.guarantor_org.address.city)
 SET cb_state = substring(1,2,uar_get_code_display(request->patient_data.person.guarantor_01.
   guarantor_org.address.state_cd))
 SET cb_zipcode = request->patient_data.person.guarantor_01.guarantor_org.address.zipcode
 SET cb_co_ph_num = request->patient_data.person.guarantor_01.guarantor_org.phone.phone_num
 SET cb_co_ph_frm = request->patient_data.person.guarantor_01.guarantor_org.phone.phone_format_cd
 SET cb_phone = substring(1,25,cnvtphone(cb_co_ph_num,cb_co_ph_frm))
 SET cb_phone_ext = substring(1,10,request->patient_data.person.guarantor_org.phone.extension)
 SET cb_co_contact = substring(1,30,request->patient_data.person.guarantor_01.guarantor_org.phone.
  contact)
 SET pcp_doctor = substring(1,30,pm_hl7_provider(request->patient_data.person.pcp.prsnl_person_id,
   prv_name_full_formatted))
 SET admit_doctor = substring(1,15,trim(pm_hl7_provider(request->patient_data.person.encounter.
    admitdoc.prsnl_person_id,prv_name_full_formatted)))
 SET attend_doctor = substring(1,30,pm_hl7_provider(request->patient_data.person.encounter.attenddoc.
   prsnl_person_id,prv_name_full_formatted))
 SET refer_doctor = substring(1,30,pm_hl7_provider(request->patient_data.person.encounter.referdoc.
   prsnl_person_id,prv_name_full_formatted))
 SET attend_doc_id = request->patient_data.person.encounter.attenddoc.prsnl_person_id
 SET attend_doc_no = fillstring(25," ")
 SELECT INTO "nl:"
  pa.alias
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.person_id=attend_doc_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   attend_doc_no = substring(1,25,trim(pa.alias))
 ;end select
 SET hlth_plan1_id = request->person.subscriber_01.person.health_plan.health_plan_id
 SET s1_payor_id = fillstring(10," ")
 SELECT INTO "nl:"
  hpa1.alias
  FROM health_plan_alias hpa1
  WHERE hpa1.health_plan_id=hlth_plan1_id
   AND ((hpa1.active_ind+ 0)=1)
   AND ((hpa1.plan_alias_type_cd+ 0)=1197393)
   AND ((hpa1.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
   AND ((hpa1.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
  DETAIL
   s1_payor_id = substring(1,20,trim(hpa1.alias))
 ;end select
 SET s1_effect_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi1.info_sub_type_cd
  FROM person_info pi1
  PLAN (pi1
   WHERE pi1.person_id=cur_person_id
    AND pi1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi1.info_sub_type_cd+ 0)=264465)
    AND ((pi1.active_ind+ 0)=1))
  DETAIL
   s1_effect_dt = format(pi1.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s1_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi1.info_sub_type_cd
  FROM person_info pi1
  PLAN (pi1
   WHERE pi1.person_id=cur_person_id
    AND pi1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi1.info_sub_type_cd+ 0)=112817)
    AND ((pi1.active_ind+ 0)=1))
  DETAIL
   s1_assign_dt = format(pi1.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s1_med_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi2.info_sub_type_cd
  FROM person_info pi2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND pi2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi2.info_sub_type_cd+ 0)=151561)
    AND ((pi2.active_ind+ 0)=1))
  DETAIL
   s1_med_assign_dt = format(pi2.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET hlth_plan2_id = request->person.subscriber_02.person.health_plan.health_plan_id
 SET s2_payor_id = fillstring(10," ")
 SELECT INTO "nl:"
  hpa2.alias
  FROM health_plan_alias hpa2
  WHERE hpa2.health_plan_id=hlth_plan2_id
   AND ((hpa2.active_ind+ 0)=1)
   AND ((hpa2.alias_pool_cd+ 0)=113939)
   AND ((hpa2.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
   AND ((hpa2.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
  DETAIL
   s2_payor_id = substring(1,20,trim(hpa2.alias))
 ;end select
 SET s2_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi2.info_sub_type_cd
  FROM person_info pi2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND pi2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi2.info_sub_type_cd+ 0)=112855)
    AND ((pi2.active_ind+ 0)=1))
  DETAIL
   s2_assign_dt = format(pi2.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s2_effect_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi2.info_sub_type_cd
  FROM person_info pi2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND pi2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi2.info_sub_type_cd+ 0)=264466)
    AND ((pi2.active_ind+ 0)=1))
  DETAIL
   s2_effect_dt = format(pi2.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s2_med_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi2.info_sub_type_cd
  FROM person_info pi2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND pi2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi2.info_sub_type_cd+ 0)=151559)
    AND ((pi2.active_ind+ 0)=1))
  DETAIL
   s2_med_assign_dt = format(pi2.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET hlth_plan3_id = request->person.subscriber_03.person.health_plan.health_plan_id
 SET s3_payor_id = fillstring(10," ")
 SELECT INTO "nl:"
  hpa3.alias
  FROM health_plan_alias hpa3
  WHERE hpa3.health_plan_id=hlth_plan3_id
   AND ((hpa3.active_ind+ 0)=1)
   AND ((hpa3.alias_pool_cd+ 0)=113939)
   AND ((hpa3.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
   AND ((hpa3.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
  DETAIL
   s3_payor_id = substring(1,20,trim(hpa3.alias))
 ;end select
 SET s3_effect_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi1.info_sub_type_cd
  FROM person_info pi1
  PLAN (pi1
   WHERE pi1.person_id=cur_person_id
    AND pi1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi1.info_sub_type_cd+ 0)=269786)
    AND ((pi1.active_ind+ 0)=1))
  DETAIL
   s3_effect_dt = format(pi1.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s3_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi1.info_sub_type_cd
  FROM person_info pi1
  PLAN (pi1
   WHERE pi1.person_id=cur_person_id
    AND pi1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi1.info_sub_type_cd+ 0)=112856)
    AND ((pi1.active_ind+ 0)=1))
  DETAIL
   s3_assign_dt = format(pi1.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET s3_med_assign_dt = fillstring(10," ")
 SELECT INTO "nl:"
  pi2.info_sub_type_cd
  FROM person_info pi2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND pi2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((pi2.info_sub_type_cd+ 0)=151560)
    AND ((pi2.active_ind+ 0)=1))
  DETAIL
   s3_med_assign_dt = format(pi2.value_dt_tm,"MM/DD/YY;;D")
 ;end select
 SET hlth_plan4_id = request->person.subscriber_04.person.health_plan.health_plan_id
 SET wc_s4_payor_id = fillstring(10," ")
 SELECT INTO "nl:"
  hpa4.alias
  FROM health_plan_alias hpa4
  WHERE hpa4.health_plan_id=hlth_plan4_id
   AND ((hpa4.active_ind+ 0)=1)
   AND ((hpa4.alias_pool_cd+ 0)=113939)
   AND ((hpa4.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
   AND ((hpa4.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))
  DETAIL
   wc_s4_payor_id = substring(1,20,trim(hpa4.alias))
 ;end select
 SET est_arrive_dt_tm = format(request->patient_data.person.encounter.est_arrive_dt_tm,
  "MM/DD/YYYY HH:MM;;D")
 SET est_arrive_dt = substring(1,10,est_arrive_dt_tm)
 SET est_arrive_tm = substring(12,16,est_arrive_dt_tm)
 SET appt_dt = fillstring(10," ")
 SET appt_tm = fillstring(8," ")
 SELECT INTO "nl:"
  sa1.beg_dt_tm
  FROM sch_appt sa1
  WHERE sa1.encntr_id=cur_encntr_id
   AND ((sa1.active_ind+ 0)=1)
  DETAIL
   appt_dt = format(sa1.beg_dt_tm,"MM/DD/YYYY;;D"), appt_tm = format(sa1.beg_dt_tm,"HH:MM;;S")
 ;end select
 SET encntr_comments = substring(1,100,request->patient_data.person.encounter.comment_01.long_text)
 SET encounter_comments1 = trim(substring(1,50,encntr_comments))
 SET acc_dt_tm = format(request->patient_data.person.encounter.accident_01.accident_dt_tm,
  "MM/DD/YYYY;;D")
 SET reg_clerk = fillstring(15," ")
 SET reg_dt = fillstring(10," ")
 SET reg_tm = fillstring(8," ")
 SELECT INTO "nl:"
  prs.name_full_formatted
  FROM prsnl prs,
   encounter en
  PLAN (en
   WHERE en.encntr_id=cur_encntr_id)
   JOIN (prs
   WHERE prs.person_id=en.updt_id)
  DETAIL
   reg_clerk = substring(1,15,prs.name_full_formatted), reg_dt = format(en.updt_dt_tm,"MM/DD/YYYY;;D"
    ), reg_tm = format(en.updt_dt_tm,"HH:MM;;S")
 ;end select
 SET s1_comment = fillstring(30," ")
 SELECT INTO "nl:"
  l.long_text
  FROM person_info pi,
   long_text l
  PLAN (pi
   WHERE pi.person_id=cur_person_id
    AND ((pi.info_type_cd+ 0)=1949)
    AND ((pi.internal_seq+ 0)=2)
    AND ((pi.active_ind+ 0)=1))
   JOIN (l
   WHERE l.long_text_id=pi.long_text_id)
  DETAIL
   s1_comment = substring(1,30,trim(l.long_text))
 ;end select
 SET s2_comment = fillstring(30," ")
 SELECT INTO "nl:"
  l2.long_text
  FROM person_info pi2,
   long_text l2
  PLAN (pi2
   WHERE pi2.person_id=cur_person_id
    AND ((pi2.info_type_cd+ 0)=1949)
    AND ((pi2.internal_seq+ 0)=3)
    AND ((pi2.active_ind+ 0)=1))
   JOIN (l2
   WHERE l2.long_text_id=pi2.long_text_id)
  DETAIL
   s2_comment = substring(1,30,trim(l2.long_text))
 ;end select
 SET s3_comment = fillstring(30," ")
 SELECT INTO "nl:"
  l3.long_text
  FROM person_info pi3,
   long_text l3
  PLAN (pi3
   WHERE pi3.person_id=cur_person_id
    AND ((pi3.info_type_cd+ 0)=1949)
    AND ((pi3.internal_seq+ 0)=4)
    AND ((pi3.active_ind+ 0)=1))
   JOIN (l3
   WHERE l3.long_text_id=pi3.long_text_id)
  DETAIL
   s3_comment = substring(1,30,trim(l3.long_text))
 ;end select
 SET client_alias = fillstring(20," ")
 SELECT INTO "nl:"
  o.alias
  FROM encntr_org_reltn eor,
   organization_alias o
  PLAN (eor
   WHERE eor.encntr_id=cur_encntr_id)
   JOIN (o
   WHERE o.organization_id=eor.organization_id
    AND ((o.alias_pool_cd+ 0)=357725)
    AND ((o.active_ind+ 0)=1))
  DETAIL
   client_alias = substring(1,20,o.alias)
 ;end select
#main
 SELECT INTO  $1
  pat_sex_dp = substring(1,6,uar_get_code_display(request->patient_data.person.sex_cd)), upat_sex_dp
   = cnvtupper(substring(1,6,uar_get_code_display(request->patient_data.person.sex_cd))), pat_race_dp
   = uar_get_code_display(request->patient_data.person.race_cd),
  pat_ms_dp = uar_get_code_display(request->patient_data.person.marital_type_cd), pat_relg_dp =
  substring(1,12,uar_get_code_display(request->patient_data.person.religion_cd)), pat_hm_st_dp =
  substring(1,14,uar_get_code_display(request->patient_data.person.alt_address.state_cd)),
  pat_empl_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.employer_01.
    address.state_cd)), gua_sex_dp = uar_get_code_display(request->patient_data.person.guarantor_01.
   person.sex_cd), gua_ms_dp = uar_get_code_display(request->patient_data.person.guarantor_01.person.
   marital_type_cd),
  gua_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.guarantor_01.
    person_reltn_cd)), gua_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.
    person.guarantor_01.person.home_address.state_cd)), gua_empl_status = substring(1,10,
   uar_get_code_display(request->patient_data.person.guarantor_01.person.employer_01.empl_status_cd)),
  emc_sex_dp = uar_get_code_display(request->patient_data.person.nok.person.sex_cd), emc_reltn_dp =
  substring(1,25,uar_get_code_display(request->patient_data.person.nok.person_reltn_cd)),
  emc_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.nok.person.
    home_address.state_cd)),
  s1_sex_dp = uar_get_code_display(request->patient_data.person.subscriber_01.person.sex_cd),
  s1_ms_dp = uar_get_code_display(request->patient_data.person.subscriber_01.person.marital_type_cd),
  s1_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_01.
    person_reltn_cd)),
  s1_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_01.person
    .home_address.state_cd)), s1_empl_st_dp = substring(1,14,uar_get_code_display(request->
    patient_data.person.subscriber_01.person.employer_01.address.state_cd)), s1_empl_status =
  substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_01.person.employer_01.
    empl_status_cd)),
  s1_plan_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_01.
    person.health_plan.address.state_cd)), s1_cov_type = substring(1,15,uar_get_code_display(request
    ->patient_data.person.subscriber_01.person.health_plan.coverage_type_cd)), s2_sex_dp =
  uar_get_code_display(request->patient_data.person.subscriber_02.person.sex_cd),
  s2_ms_dp = uar_get_code_display(request->patient_data.person.subscriber_02.person.marital_type_cd),
  s2_reltn_dp = substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_02.
    person_reltn_cd)), s2_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person
    .subscriber_02.person.home_address.state_cd)),
  s2_empl_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_02.
    person.employer_01.address.state_cd)), s2_empl_status = substring(1,10,uar_get_code_display(
    request->patient_data.person.subscriber_02.person.employer_01.empl_status_cd)), s2_plan_st_dp =
  substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_02.person.health_plan.
    address.state_cd)),
  s2_cov_type = substring(1,15,uar_get_code_display(request->patient_data.person.subscriber_02.person
    .health_plan.coverage_type_cd)), s3_sex_dp = uar_get_code_display(request->patient_data.person.
   subscriber_03.person.sex_cd), s3_reltn_dp = substring(1,10,uar_get_code_display(request->
    patient_data.person.subscriber_03.person_reltn_cd)),
  s3_hm_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_03.person
    .home_address.state_cd)), s3_empl_st_dp = substring(1,14,uar_get_code_display(request->
    patient_data.person.subscriber_03.person.employer_01.address.state_cd)), s3_empl_status =
  substring(1,10,uar_get_code_display(request->patient_data.person.subscriber_03.person.employer_01.
    empl_status_cd)),
  s3_plan_st_dp = substring(1,14,uar_get_code_display(request->patient_data.person.subscriber_03.
    person.health_plan.address.state_cd)), s3_cov_type = substring(1,15,uar_get_code_display(request
    ->patient_data.person.subscriber_03.person.health_plan.coverage_type_cd)), encntr_type_dp =
  substring(1,15,uar_get_code_display(request->patient_data.person.encounter.encntr_type_cd)),
  dept_dp = trim(uar_get_code_display(request->patient_data.person.encounter.loc_nurse_unit_cd)),
  facility_dp = substring(1,15,uar_get_code_display(request->patient_data.person.encounter.
    loc_building_cd)), acc_type_dp = substring(1,12,uar_get_code_display(request->patient_data.person
    .encounter.accident_01.accident_cd))
  FROM dummyt d
  PLAN (d)
  DETAIL
   track_type_dp = substring(1,2,uar_get_code_display(track_type)), track = concat(trim(track_type_dp
     ),"-",cnvtstring(track_id)), barcode_track = concat("*",cnvtalphanum(track),"*")
   IF (textlen(trim(pat_hm_city)) > 0)
    pat_hm_city_st = concat(trim(pat_hm_city),", ",trim(pat_hm_st_dp))
   ENDIF
   IF (textlen(trim(pat_empl_city)) > 0)
    pat_empl_city_st = concat(trim(pat_empl_city),", ",trim(pat_empl_st_dp))
   ENDIF
   IF (textlen(trim(gua_hm_city)) > 0)
    gua_hm_city_st = concat(trim(gua_hm_city),", ",trim(gua_hm_st_dp))
   ENDIF
   IF (textlen(trim(emc_hm_city)) > 0)
    emc_city_st = concat(trim(emc_hm_city),", ",trim(emc_hm_st_dp))
   ENDIF
   IF (textlen(trim(s1_empl_city)) > 0)
    s1_empl_city_st = concat(trim(s1_empl_city),", ",trim(s1_empl_st_dp))
   ENDIF
   IF (textlen(trim(s1_plan_city)) > 0)
    s1_plan_city_st = concat(trim(s1_plan_city),", ",trim(s1_plan_st_dp))
   ENDIF
   IF (textlen(trim(s2_empl_city)) > 0)
    s2_empl_city_st = concat(trim(s2_empl_city),", ",trim(s2_empl_st_dp))
   ENDIF
   IF (textlen(trim(s2_plan_city)) > 0)
    s2_plan_city_st = concat(trim(s2_plan_city),", ",trim(s2_plan_st_dp))
   ENDIF
   IF (textlen(trim(s3_empl_city)) > 0)
    s3_empl_city_st = concat(trim(s3_empl_city),", ",trim(s3_empl_st_dp))
   ENDIF
   IF (textlen(trim(s3_plan_city)) > 0)
    s3_plan_city_st = concat(trim(s3_plan_city),", ",trim(s3_plan_st_dp))
   ENDIF
   IF (textlen(trim(acc_dt_tm)) > 0)
    acc_ind = "Y"
   ELSE
    acc_ind = "N"
   ENDIF
   cur_row = 32, next_line = 9, next_section = 11,
   next_line2 = 14, name_col = 61, sex_col = 228,
   sex2_col = 260, age_col = 428, ms_col = 450,
   age2_col = 380, ssn_col = 283, ssn2_col = 240,
   hm_addr_col = 117, city1_col = 310, empl_addr_col = 117,
   claim_addr_col = 115, city2_col = 110, zip1_col = 380,
   zip2_col = 377, work1_col = 435, prev_date_col = 66,
   prev_type_col = 153, prev_phy_col = 235, visit_admit_col = 335,
   visit_type_col = 472, "{F/4}{CPI/14}{LPI/4}", "{POS/57/5}",
   "{B}METHODIST HEALTH SYSTEM{ENDB}", row + 1, "{POS/400/5}",
   "Printed:", col + 5, curdate"MM/DD/YYYY;;D",
   row + 1, "{POS/500/5}", curtime"HH:MM;;S",
   row + 1, row + 1,
   CALL print(calcpos(230,cur_row)),
   "{CPI/11}{FONT/4}{B}", "--- PATIENT INFORMATION ---{ENDB}", row + 1,
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Name: ", "{F/4}", pat_name,
   row + 1,
   CALL print(calcpos(323,cur_row)), "{F/7}DOB: ",
   "{F/4}", pat_dob, row + 1,
   CALL print(calcpos(age_col,cur_row)), "{F/7}Age: ", "{F/4}",
   pat_age, row + 1,
   CALL print(calcpos(510,cur_row)),
   "{F/7}MS: ", "{F/4}", pat_ms_dp,
   row + 1, cur_row += (next_line * 2), row + 1
   IF (pat_prev_name != " ")
    CALL print(calcpos(name_col,cur_row)), "{F/7}Pref Name: ", "{F/4}",
    pat_prev_name, row + 1
   ENDIF
   CALL print(calcpos(323,cur_row)), "{F/7}MRN: ", "{F/4}",
   pat_mrn, row + 1,
   CALL print(calcpos((age_col - 10),cur_row)),
   "{F/7}Gender: ", "{F/4}", pat_sex_dp,
   row + 1,
   CALL print(calcpos((age_col+ 80),cur_row)), "{F/7}SS#: ",
   "{F/4}", pat_ssn, row + 1,
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Home Addr: ", row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)),
   "{F/4}", pat_hm_addr, row + 1,
   CALL print(calcpos(323,cur_row)), "{F/7}City/State/Zip: ", row + 1,
   CALL print(calcpos(397,cur_row)), "{F/4}", pat_hm_city_st,
   row + 1,
   CALL print(calcpos(510,cur_row)), pat_hm_zipcode,
   row + 1, cur_row += next_line, row + 1,
   CALL print(calcpos(hm_addr_col,cur_row)), pat_hm_addr2, row + 1,
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Home Phone: ", "{F/4}", pat_hm_phone,
   row + 1
   IF (pat_hm_ph_comment != " ")
    CALL print(calcpos(ssn2_col,cur_row)), "{F/7}Hm Ph comment: ", "{F/4}",
    pat_hm_ph_comment, row + 1
   ENDIF
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Emp Name: ", "{F/4}", pat_empl_name,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "{F/7}Emp Status: ",
   "{F/4}", pat_empl_job, row + 1,
   cur_row += next_line, row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Work Phone: ", "{F/4}", pat_wk_phone,
   row + 1
   IF (pat_wk_ext != " ")
    CALL print(calcpos(ssn2_col,cur_row)), "{F/7}Ext: ", "{F/4}",
    pat_wk_ext, row + 1
   ENDIF
   IF (pat_wkph_comment != " ")
    CALL print(calcpos(323,cur_row)), "{F/7}Work Ph Comment: ", "{F/4}",
    pat_wkph_comment, row + 1
   ENDIF
   cur_row += (next_line * 2), cur_row2 = (cur_row+ (next_line * 1))
   IF (pat_person_comments1 != " ")
    CALL print(calcpos(name_col,cur_row)), "{F/7}Person Comments: ", "{F/4}",
    pat_person_comments1, row + 1
   ENDIF
   IF (cb_company_name=" ")
    cur_row += next_line, row + 1,
    CALL print(calcpos(58,cur_row)),
    line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
    row + 1,
    CALL print(calcpos(220,cur_row)), "{B}---GUARANTOR INFORMATION---{ENDB}",
    row + 1, cur_row += (next_line * 2), row + 1,
    CALL print(calcpos(name_col,cur_row)), "{F/7}Name: ", "{F/4}",
    gua_name, row + 1,
    CALL print(calcpos(323,cur_row)),
    "{F/7}DOB: ", "{F/4}", gua_dob,
    row + 1,
    CALL print(calcpos(age_col,cur_row)), "{F/7}Age: ",
    "{F/4}", gua_age, row + 1,
    CALL print(calcpos(510,cur_row)), "{F/7}MS: ", "{F/4}",
    gua_ms_dp, row + 1, cur_row += next_line,
    row + 1
    IF (gua_reltn_cd=149164)
     CALL print(calcpos(name_col,cur_row)), "{F/7}Account#: ", "{F/4}",
     pat_mrn, row + 1
    ELSE
     CALL print(calcpos(name_col,cur_row)), "{F/7}Account#: ", "{F/4}",
     gua_mrn, row + 1
    ENDIF
    cur_row += (next_line * 2), row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Rel to Pat: ", "{F/4}", gua_reltn_dp,
    row + 1,
    CALL print(calcpos(323,cur_row)), "{F/7}Gender: ",
    "{F/4}", gua_sex_dp, row + 1,
    CALL print(calcpos(age_col,cur_row)), "{F/7}SS#: ", "{F/4}",
    gua_ssn, row + 1, cur_row += next_line,
    row + 1,
    CALL print(calcpos(name_col,cur_row)), "{F/7}Home Addr: ",
    row + 1,
    CALL print(calcpos(hm_addr_col,cur_row)), "{F/4}",
    col + 2, gua_hm_addr, row + 1,
    CALL print(calcpos(323,cur_row)), "{F/7}City/State/Zip: ", row + 1,
    CALL print(calcpos(397,cur_row)), "{F/4}", gua_hm_city_st,
    row + 1,
    CALL print(calcpos(510,cur_row)), gua_hm_zipcode,
    row + 1, cur_row += next_line, row + 1,
    CALL print(calcpos(hm_addr_col,cur_row)), col + 2, gua_hm_addr2,
    row + 1, cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)), "{F/7}Home Phone: ", "{F/4}",
    gua_hm_phone, row + 1
    IF (gua_hm_ph_comment != " ")
     CALL print(calcpos(ssn2_col,cur_row)), "{F/7}Hm Ph comment: ", "{F/4}",
     gua_hm_ph_comment, row + 1
    ENDIF
    cur_row += next_line, row + 1
    IF (gua_reltn_dp != "Self")
     CALL print(calcpos(name_col,cur_row)), "{F/7}Work Phone: ", "{F/4}",
     gua_wk_phone, row + 1
    ELSE
     CALL print(calcpos(name_col,cur_row)), "{F/7}Work Phone: ", "{F/4}",
     pat_wk_phone, row + 1
    ENDIF
    IF (gua_wk_ph_comment != " ")
     CALL print(calcpos(ssn2_col,cur_row)), "{F/7}Wk Ph comment: ", "{F/4}",
     gua_wk_ph_comment, row + 1
    ENDIF
    cur_row += next_line, row + 1
    IF (gua_reltn_dp != "Self")
     CALL print(calcpos(name_col,cur_row)), "{F/7}Employer Name: ", "{F/4}",
     gua_empl_name, row + 1,
     CALL print(calcpos(age_col,cur_row)),
     "{F/7}Emp Status: ", "{F/4}", gua_empl_status,
     row + 1
    ELSE
     CALL print(calcpos(name_col,cur_row)), "{F/7}Employer Name: ", "{F/4}",
     pat_empl_name, row + 1,
     CALL print(calcpos(age_col,cur_row)),
     "{F/7}Emp Status: ", "{F/4}", pat_empl_job,
     row + 1
    ENDIF
   ENDIF
   cur_row += next_line, row + 1,
   CALL print(calcpos(58,cur_row)),
   line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
   row + 1,
   CALL print(calcpos(195,cur_row)), "{B}---EMERGENCY CONTACT INFORMATION---{ENDB}",
   row + 1, cur_row += (next_line * 2), row + 1
   IF (((emc_reltn_dp=" ") OR (emc_reltn_dp="None/Unknown")) )
    CALL print(calcpos(90,cur_row)), "THERE IS NO EMERGENCY CONTACT FOR THIS PATIENT.", row + 1
   ELSEIF (emc_reltn_dp != "None/Unknown")
    CALL print(calcpos(name_col,cur_row)), "{F/7}Name: ", "{F/4}",
    emc_name, row + 1,
    CALL print(calcpos(sex_col,cur_row)),
    "{F/7}Rel to Pat: ", "{F/4}", emc_reltn_dp,
    row + 1, cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)), "{F/7}Home Phone: ", "{F/4}",
    emc_hm_phone, row + 1
    IF (emc_hm_comment != " ")
     CALL print(calcpos(sex_col,cur_row)), "{F/7}Hm Ph comment: ", "{F/4}",
     emc_hm_comment, row + 1
    ENDIF
    cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Work Phone: ", "{F/4}", emc_wk_phone,
    row + 1
    IF (emc_wk_comment != " ")
     CALL print(calcpos(sex_col,cur_row)), "{F/7}Wk Ph comment: ", "{F/4}",
     emc_wk_comment, row + 1
    ENDIF
   ELSEIF (emc_reltn_dp != " ")
    cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Name: ", "{F/4}", emc_name,
    row + 1,
    CALL print(calcpos(sex_col,cur_row)), "{F/7}Rel to Pat: ",
    "{F/4}", emc_reltn_dp, row + 1,
    cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Home Phone: ", "{F/4}", emc_hm_phone,
    row + 1
    IF (emc_hm_comment != " ")
     CALL print(calcpos(sex_col,cur_row)), "{F/7}Hm_ph comment: ", "{F/4}",
     emc_hm_comment, row + 1
    ENDIF
    cur_row += next_line, row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Work Phone: ", "{F/4}", emc_wk_phone,
    row + 1
    IF (emc_wk_comment != " ")
     CALL print(calcpos(sex_col,cur_row)), "{F/7}Wk_ph comment: ", "{F/4}",
     emc_wk_comment, row + 1
    ENDIF
   ENDIF
   IF (cb_company_name=" ")
    IF (wc_s4_name=" ")
     cur_row += next_line, row + 1,
     CALL print(calcpos(58,cur_row)),
     line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
     row + 1,
     CALL print(calcpos(197,cur_row)), "{B}---PRIMARY INSURANCE INFORMATION---{ENDB}",
     row + 1, cur_row += (next_line * 2), row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Ins Name: ", "{F/4}",
     s1_plan_name, row + 1
     IF (s1_effect_dt != " ")
      CALL print(calcpos((ssn_col+ 20),cur_row)), "{F/7}Effective Date: ", "{F/4}",
      s1_effect_dt, row + 1
     ENDIF
     IF (s1_payor_id != " ")
      CALL print(calcpos((age_col+ 5),cur_row)), "{F/7}Payor ID: ", "{F/4}",
      s1_payor_id, row + 1
     ENDIF
     IF (s1_payor_id=" ")
      CALL print(calcpos(age_col,cur_row)), "{F/7}Payor ID: ", "{F/4}Invalid Payor",
      row + 1
     ENDIF
     cur_row += next_line, row + 1
     IF (s1_pat_policy_no != " ")
      CALL print(calcpos(name_col,cur_row)), "{F/7}Pat Pol#: ", "{F/4}",
      s1_pat_policy_no, row + 1
     ENDIF
     IF (s1_fin_class=65589)
      CALL print(calcpos(age_col,cur_row)), "{F/7}Medicare Assign Date: ", "{F/4}",
      s1_med_assign_dt, row + 1
     ELSEIF (s1_assign_dt != " ")
      CALL print(calcpos(age_col,cur_row)), "{F/7}Assign Date: ", "{F/4}",
      s1_assign_dt, row + 1
     ENDIF
     cur_row += next_line, row + 1
     IF (s1_group_no != " ")
      CALL print(calcpos(name_col,cur_row)), "{F/7}Group #: ", "{F/4}",
      s1_group_no, row + 1
     ENDIF
     IF (s1_group_name != " ")
      CALL print(calcpos(sex_col,cur_row)), "{F/7}Group Name: ", "{F/4}",
      s1_group_name, row + 1
     ENDIF
     CALL print(calcpos(age_col,cur_row)), "{F/7}Coverage Type: ", "{F/4}",
     s1_cov_type, row + 1, cur_row += next_line,
     row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Name: ",
     "{F/4}", s1_name, row + 1,
     CALL print(calcpos(323,cur_row)), "{F/7}DOB: ", "{F/4}",
     s1_dob, row + 1,
     CALL print(calcpos(age_col,cur_row)),
     "{F/7}Age: ", "{F/4}", s1_age,
     row + 1, cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Rel to Pat: ", "{F/4}",
     s1_reltn_dp, row + 1,
     CALL print(calcpos(323,cur_row)),
     "{F/7}Gender: ", "{F/4}", s1_sex_dp,
     row + 1, cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Emp Name: ", "{F/4}",
     s1_empl_name, row + 1,
     CALL print(calcpos(age_col,cur_row)),
     "{F/7}Emp Status: ", "{F/4}", s1_empl_status,
     row + 1, cur_row += next_line, row + 1
     IF (s1_comment != " ")
      IF (((s1_plan_name="Self File; 999995") OR (s1_plan_name="Unlisted Primary Payor; 999999")) )
       CALL print(calcpos(name_col,cur_row)), "{F/7}Comment: ", "{F/4}",
       s1_comment, row + 1
      ENDIF
     ENDIF
     cur_row += next_line, row + 1,
     CALL print(calcpos(58,cur_row)),
     line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
     row + 1,
     CALL print(calcpos(190,cur_row)), "{B}---SECONDARY INSURANCE INFORMATION---{ENDB}",
     row + 1, cur_row += (next_line * 2), row + 1
     IF (s2_name=" ")
      CALL print(calcpos(80,cur_row)), "THERE IS NO PAYOR2.", row + 1
     ELSE
      CALL print(calcpos((name_col+ 20),cur_row)), "{F/7}Ins Name: ", "{F/4}",
      s2_plan_name, row + 1
      IF (s2_effect_dt != " ")
       CALL print(calcpos((ssn_col+ 5),cur_row)), "{F/7}Effective Date: ", "{F/4}",
       s2_effect_dt, row + 1
      ENDIF
      IF (s2_payor_id != " ")
       CALL print(calcpos(age_col,cur_row)), "{F/7}Payor ID: ", "{F/4}",
       s2_payor_id, row + 1
      ENDIF
      cur_row += next_line, row + 1
      IF (s2_pat_policy_no != " ")
       CALL print(calcpos(name_col,cur_row)), "{F/7}Pat Pol#: ", "{F/4}",
       s2_pat_policy_no, row + 1
      ENDIF
      IF (((s2_plan_name="Medicare Nebraska 47") OR (((s2_plan_name="Medicare Iowa 1426") OR (
      s2_plan_name="RR Medicare; Augusta")) )) )
       CALL print(calcpos(age_col,cur_row)), "{F/7}Medicare Assign Date: ", "{F/4}",
       s2_med_assign_dt, row + 1
      ELSE
       CALL print(calcpos(age_col,cur_row)), "{F/7}Assign Date: ", "{F/4}",
       s2_assign_dt, row + 1
      ENDIF
      cur_row += next_line, row + 1
      IF (s2_group_no != " ")
       CALL print(calcpos(name_col,cur_row)), "{F/7}Group #: ", "{F/4}",
       s2_group_no, row + 1
      ENDIF
      IF (s2_group_name != " ")
       CALL print(calcpos(sex_col,cur_row)), "{F/7}Group Name: ", "{F/4}",
       s2_group_name, row + 1
      ENDIF
      CALL print(calcpos(age_col,cur_row)), "{F/7}Coverage Type: ", "{F/4}",
      s2_cov_type, row + 1, cur_row += next_line,
      row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Name: ",
      "{F/4}", s2_name, row + 1,
      CALL print(calcpos(323,cur_row)), "{F/7}DOB: ", "{F/4}",
      s2_dob, row + 1,
      CALL print(calcpos(age_col,cur_row)),
      "{F/7}Age: ", "{F/4}", s2_age,
      row + 1, cur_row += next_line, row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Rel to Pat: ", "{F/4}",
      s2_reltn_dp, row + 1,
      CALL print(calcpos(323,cur_row)),
      "{F/7}Gender: ", "{F/4}", s2_sex_dp,
      row + 1, cur_row += next_line, row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Emp Name: ", "{F/4}",
      s2_empl_name, row + 1,
      CALL print(calcpos(age_col,cur_row)),
      "{F/7}Emp Status: ", "{F/4}", s2_empl_status,
      row + 1
     ENDIF
     cur_row += next_line, row + 1
     IF (s2_comment != " ")
      IF (((s2_plan_name="Self File; 999995") OR (s2_plan_name="Unlisted Secondary Payor; 999998")) )
       CALL print(calcpos(name_col,cur_row)), "{F/7}Comment: ", "{F/4}",
       s2_comment, row + 1
      ENDIF
     ENDIF
     cur_row += next_line, row + 1,
     CALL print(calcpos(58,cur_row)),
     line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
     row + 1,
     CALL print(calcpos(197,cur_row)), "{B}---TERTIARY INSURANCE INFORMATION---{ENDB}",
     row + 1, cur_row += (next_line * 2), row + 1
     IF (s3_name=" ")
      CALL print(calcpos(80,cur_row)), "THERE IS NO PAYOR3.", row + 1
     ELSE
      CALL print(calcpos((name_col+ 20),cur_row)), "{F/7}Ins Name: ", "{F/4}",
      s3_plan_name, row + 1
      IF (s3_effect_dt != " ")
       CALL print(calcpos((ssn_col+ 5),cur_row)), "{F/7}Effective Date: ", "{F/4}",
       s3_effect_dt, row + 1
      ENDIF
      IF (s3_payor_id != " ")
       CALL print(calcpos(age_col,cur_row)), "{F/7}Payor ID: ", "{F/4}",
       s3_payor_id, row + 1
      ENDIF
      cur_row += next_line, row + 1
      IF (s3_pat_policy_no != " ")
       CALL print(calcpos(name_col,cur_row)), "{F/7}Pat Pol#: ", "{F/4}",
       s3_pat_policy_no, row + 1
      ENDIF
      IF (s3_med_assign_dt != " "
       AND ((s3_plan_name="Medicare Nebraska 47") OR (((s3_plan_name="Medicare Iowa 1426") OR (
      s3_plan_name="RR Medicare; Augusta")) )) )
       CALL print(calcpos(age_col,cur_row)), "{F/7}Medicare Assign Date: ", "{F/4}",
       s3_med_assign_dt, row + 1
      ELSE
       CALL print(calcpos(age_col,cur_row)), "{F/7}Assign Date: ", "{F/4}",
       s3_assign_dt, row + 1
      ENDIF
      cur_row += next_line, row + 1
      IF (s3_group_no != " ")
       CALL print(calcpos(name_col,cur_row)), "{F/7}Group #: ", "{F/4}",
       s3_group_no, row + 1
      ENDIF
      IF (s3_group_name != " ")
       CALL print(calcpos(sex_col,cur_row)), "{F/7}Group Name: ", "{F/4}",
       s3_group_name, row + 1
      ENDIF
      CALL print(calcpos(age_col,cur_row)), "{F/7}Coverage Type: ", "{F/4}",
      s3_cov_type, row + 1, cur_row += next_line,
      row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Name: ",
      "{F/4}", s3_name, row + 1,
      CALL print(calcpos(323,cur_row)), "{F/7}DOB: ", "{F/4}",
      s3_dob, row + 1,
      CALL print(calcpos(age_col,cur_row)),
      "{F/7}Age: ", "{F/4}", s3_age,
      row + 1, cur_row += next_line, row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Rel to Pat: ", "{F/4}",
      s3_reltn_dp, row + 1,
      CALL print(calcpos(323,cur_row)),
      "{F/7}Gender: ", "{F/4}", s3_sex_dp,
      row + 1, cur_row += next_line, row + 1,
      CALL print(calcpos(name_col,cur_row)), "{F/7}Emp Name: ", "{F/4}",
      s3_empl_name, row + 1,
      CALL print(calcpos(age_col,cur_row)),
      "{F/7}Emp Status: ", "{F/4}", s3_empl_status,
      row + 1
     ENDIF
     cur_row += next_line, row + 1
     IF (s3_comment != " ")
      IF (((s3_plan_name="Self File; 999995") OR (s3_plan_name="Unlisted Tertiary Payor; 999997")) )
       CALL print(calcpos(name_col,cur_row)), "{F/7}Comment: ", "{F/4}",
       s3_comment, row + 1
      ENDIF
     ENDIF
    ELSE
     cur_row += next_line, row + 1,
     CALL print(calcpos(58,cur_row)),
     line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
     row + 1,
     CALL print(calcpos(220,cur_row)), "{B}---WORKCOMP INFORMATION---{ENDB}",
     row + 1, cur_row += (next_line * 2), row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Ins Name: ", "{F/4}",
     wc_s4_plan_name, row + 1
     IF (wc_s4_payor_id != " ")
      CALL print(calcpos(ssn_col,cur_row)), "{F/7}Payor ID: ", "{F/4}",
      wc_s4_payor_id, row + 1
     ENDIF
     cur_row += next_line, row + 1
     IF (wc_s4_pt_ssn != " ")
      CALL print(calcpos(name_col,cur_row)), "{F/7}Pat SS#: ", "{F/4}",
      wc_s4_pt_ssn, row + 1
     ENDIF
     IF (wc_s4_coverage_type != " ")
      CALL print(calcpos(age_col,cur_row)), "{F/7}Coverage Type: ", "{F/4}",
      wc_s4_coverage_type, row + 1
     ENDIF
     cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)),
     "{F/7}Name: ", "{F/4}", wc_s4_name,
     row + 1,
     CALL print(calcpos(323,cur_row)), "{F/7}DOB: ",
     "{F/4}", wc_s4_dob, row + 1,
     CALL print(calcpos(age_col,cur_row)), "{F/7}Age: ", "{F/4}",
     wc_s4_age, row + 1, cur_row += next_line,
     row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Rel to Pat: ",
     "{F/4}", wc_s4_reltn_dp, row + 1,
     CALL print(calcpos(323,cur_row)), "{F/7}Gender: ", "{F/4}",
     wc_s4_gender, row + 1, cur_row += next_line,
     row + 1,
     CALL print(calcpos(name_col,cur_row)), "{F/7}Emp Name: ",
     "{F/4}", wc_s4_emp_name, row + 1,
     CALL print(calcpos(age_col,cur_row)), "{F/7}Emp Status: ", "{F/4}",
     wc_s4_emp_status, row + 1
    ENDIF
   ELSE
    cur_row += next_line, row + 1,
    CALL print(calcpos(58,cur_row)),
    line1, row + 1, cur_row = ((cur_row+ next_section)+ (next_line * 1)),
    row + 1,
    CALL print(calcpos(215,cur_row)), "{B}---COMPANY BILL INFORMATION---{ENDB}",
    row + 1, cur_row += (next_line * 2), row + 1
    IF (cb_company_name != " ")
     CALL print(calcpos(name_col,cur_row)), "{F/7}Company Name: ", "{F/4}",
     cb_company_name, row + 1
    ENDIF
    IF (client_alias != " ")
     CALL print(calcpos((age_col+ 10),cur_row)), "{F/7}Alias: ", "{F/4}",
     client_alias, row + 1
    ENDIF
    IF (cb_first_addr != " ")
     cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)),
     "{F/7}First Addr: ", "{F/4}", cb_first_addr,
     row + 1
    ENDIF
    IF (cb_second_addr != " ")
     cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)),
     "{F/7}Second Addr: ", "{F/4}", cb_second_addr,
     row + 1
    ENDIF
    IF (cb_city != " ")
     cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)),
     "{F/7}City: ", "{F/4}", cb_city,
     row + 1
    ENDIF
    IF (cb_state != " ")
     CALL print(calcpos(323,cur_row)), "{F/7}State: ", "{F/4}",
     cb_state, row + 1
    ENDIF
    IF (cb_zipcode != " ")
     CALL print(calcpos(age_col,cur_row)), "{F/7}Zip: ", "{F/4}",
     cb_zipcode, row + 1
    ENDIF
    IF (cb_phone != " ")
     cur_row += next_line, row + 1,
     CALL print(calcpos(name_col,cur_row)),
     "{F/7}Phone: ", "{F/4}", cb_phone,
     row + 1
    ENDIF
    IF (cb_phone_ext != " ")
     CALL print(calcpos(323,cur_row)), "{F/7}Extension: ", "{F/4}",
     cb_phone_ext, row + 1, cur_row += next_line,
     row + 1
    ENDIF
    IF (cb_co_contact != " ")
     CALL print(calcpos(name_col,cur_row)), "{F/7}Company Contact Person: ", "{F/4}",
     cb_co_contact, row + 1
    ENDIF
   ENDIF
   cur_row += next_line, row + 1,
   CALL print(calcpos(58,cur_row)),
   line1, row + 1, cur_row = ((cur_row+ next_section)+ next_line),
   row + 1,
   CALL print(calcpos(ssn2_col,cur_row)), "{B}---VISIT INFORMATION---{ENDB}",
   row + 1, cur_row += (next_line * 2), row + 1
   IF (vnbr != " "
    AND vnbr != "0000000-000")
    CALL print(calcpos(name_col,cur_row)), "{F/7}MIS#: ", "{F/4}",
    vnbr, row + 1
   ELSEIF (fnbr != " ")
    CALL print(calcpos(name_col,cur_row)), "{F/7}Fin#: ", "{F/4}",
    fnbr, row + 1
   ENDIF
   CALL print(calcpos(sex_col,cur_row)), "{F/7}Appt Date/Time: ", "{F/4}",
   appt_dt, col + 5, appt_tm,
   row + 1,
   CALL print(calcpos(age_col,cur_row)), "{F/7}Visit Type: ",
   "{F/4}", encntr_type_dp, row + 1,
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Dept: ", "{F/4}", dept_dp,
   row + 1,
   CALL print(calcpos(sex_col,cur_row)), "{F/7}Facility: ",
   "{F/4}", facility_dp, row + 1
   IF (reg_clerk != " ")
    CALL print(calcpos((sex_col+ 200),cur_row)), "{F/7}Checked In By: ", "{F/4}",
    reg_clerk, row + 1
   ENDIF
   cur_row += (next_line * 2), row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Attending MD/Lic#: ", "{F/4}", attend_doctor,
   col + 5, attend_doc_no, row + 1,
   cur_row += next_line, row + 1,
   CALL print(calcpos(name_col,cur_row)),
   "{F/7}Primary Care MD: ", "{F/4}", pcp_doctor,
   row + 1
   IF (refer_doctor != " ")
    CALL print(calcpos(323,cur_row)), "{F/7}Referring MD: ", "{F/4}",
    refer_doctor, row + 1
   ENDIF
   IF (encounter_comments1 != " ")
    cur_row += (next_line * 2), row + 1,
    CALL print(calcpos(name_col,cur_row)),
    "{F/7}Encounter Comments: ", "{F/4}", encounter_comments1,
    row + 1
   ENDIF
  WITH nocounter, maxrow = 100, maxcol = 1000,
   noformfeed, dio = postscript, print = "tray3"
 ;end select
#end_program
END GO
