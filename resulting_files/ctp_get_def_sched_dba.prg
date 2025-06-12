CREATE PROGRAM ctp_get_def_sched:dba
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 IF (validate(schuar_def,999)=999)
  CALL echo("Declaring schuar_def")
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security(sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=f8(ref),parent3_id
   =f8(ref),sec_id=f8(ref),
   user_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security",
  persist
  DECLARE uar_sch_security_insert(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id=
   f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_security_insert",
  persist
  DECLARE uar_sch_security_perform() = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_perform",
  persist
  DECLARE uar_sch_check_security_ex(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),parent2_id
   =f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix = "libshrschuar.a(libshrschuar.o)",
  uar = "uar_sch_check_security_ex",
  persist
  DECLARE uar_sch_check_security_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_check_security_ex2",
  persist
  DECLARE uar_sch_security_insert_ex2(user_id=f8(ref),sec_type_cd=f8(ref),parent1_id=f8(ref),
   parent2_id=f8(ref),parent3_id=f8(ref),
   sec_id=f8(ref),position_cd=f8(ref)) = i4 WITH image_axp = "shrschuar", image_aix =
  "libshrschuar.a(libshrschuar.o)", uar = "uar_sch_security_insert_ex2",
  persist
 ENDIF
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 def_sched_id = f8
     2 mnem = vc
     2 desc = vc
     2 info_sch_text_id = f8
     2 info_sch_text = vc
     2 info_sch_text_updt_cnt = i4
     2 beg_tm = i4
     2 end_tm = i4
     2 interval = i4
     2 duration = i4
     2 apply_range = i4
     2 default_type_cd = f8
     2 default_type_meaning = c12
     2 updt_cnt = i4
     2 active_ind = i2
     2 candidate_id = f8
     2 res_list_cnt = i4
     2 res_list[*]
       3 res_cd = f8
       3 res_disp = c40
       3 res_desc = c60
       3 res_mean = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 slot_list_cnt = i4
     2 slot_list[*]
       3 def_slot_id = f8
       3 seq_nbr = i4
       3 vis_beg_units = i4
       3 vis_beg_units_cd = f8
       3 vis_beg_units_meaning = c12
       3 vis_end_units = i4
       3 vis_end_units_cd = f8
       3 vis_end_units_meaning = c12
       3 sch_flex_id = f8
       3 interval = i4
       3 slot_beg_offset = i4
       3 slot_end_offset = i4
       3 slot_duration = i4
       3 holiday_weekend_flag = i2
       3 beg_offset = i4
       3 end_offset = i4
       3 vis_beg_offset = i4
       3 vis_end_offset = i4
       3 slot_type_id = f8
       3 slot_mnem = vc
       3 slot_scheme_id = f8
       3 slot_desc = vc
       3 contiguous_ind = i2
       3 border_style = i4
       3 border_size = i4
       3 border_color = i4
       3 shape = i4
       3 pen_shape = i4
       3 duration = i4
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 group_capacity_default_qty = i4
     2 date_link_r_qual_cnt = i4
     2 date_link_r_qual[*]
       3 date_set_seq_nbr = i4
       3 parent_entity_id = f8
       3 parent_entity_name = c30
       3 sch_date_link_r_id = f8
       3 sch_date_set_id = f8
       3 updt_cnt = i4
       3 sch_date_set_mnem = vc
       3 sch_date_set_desc = vc
       3 sch_date_set_active_ind = i2
     2 granted_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET reply->qual_cnt = 0
 SET find_string = concat(cnvtupper(request->mnem),"*")
 DECLARE ml_index = i4 WITH protect, noconstant(0)
 DECLARE ml_curindex = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE m_logical_domain_id = f8 WITH protected, noconstant(0.0)
 DECLARE m_logical_domain_flag = i4 WITH protected, noconstant(0.0)
 DECLARE getlogicaldomainpref(dummy) = i4
 DECLARE s_logicaldomain_pref_cd = f8 WITH protect, noconstant(0.0)
 DECLARE s_logicaldomain_pref_value = f8 WITH protect, noconstant(- (1.0))
 DECLARE s_logicaldomain_pref = i4 WITH protect, noconstant(0)
 DECLARE s_logical_domain_id = f8 WITH protect, noconstant(0.0)
 SUBROUTINE getlogicaldomainpref(dummy)
   IF (s_logicaldomain_pref_cd <= 0.0)
    SET s_logicaldomain_pref_cd = loadcodevalue(23010,"LOGICALDMN",0)
   ENDIF
   IF (s_logicaldomain_pref_value < 0)
    SET s_logicaldomain_pref_value = 0
    SELECT INTO "nl:"
     a.pref_id
     FROM sch_pref a
     PLAN (a
      WHERE a.pref_type_cd=s_logicaldomain_pref_cd
       AND a.parent_table="SYSTEM"
       AND a.parent_id=0
       AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     DETAIL
      s_logicaldomain_pref_value = a.pref_value
     WITH nocounter
    ;end select
   ENDIF
   IF (s_logicaldomain_pref_value > 0)
    SET s_logicaldomain_pref = 1
   ENDIF
   RETURN(s_logicaldomain_pref)
 END ;Subroutine
 SUBROUTINE getlogicaldomainid(dummy)
   SET s_logical_domain_id = 0
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain
   IF ((acm_get_curr_logical_domain_rep->status_block.status_ind=true))
    SET s_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
   ELSE
    GO TO exit_script
   ENDIF
   RETURN(s_logical_domain_id)
 END ;Subroutine
 SET m_logical_domain_flag = getlogicaldomainpref(0)
 IF (m_logical_domain_flag > 0)
  SET m_logical_domain_id = getlogicaldomainid(0)
 ENDIF
 FREE RECORD srvrec
 RECORD srvrec(
   1 msg_id = i4
   1 hmsg = i4
   1 hreq = i4
   1 hrep = i4
   1 happ = i4
   1 htask = i4
   1 hstep = i4
   1 hreqitem = i4
   1 hrepitem = i4
   1 crmstatus = i2
 )
 DECLARE t_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE t_parent1_id = f8 WITH protect, noconstant(0.0)
 DECLARE t_check_org_sec = i2 WITH protect, noconstant(0)
 DECLARE t_defsched_org_sec_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  a.updt_cnt
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_meaning="ORGSECDEFORG"
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0.0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   t_check_org_sec = a.pref_value
  WITH nocounter
 ;end select
 IF (t_check_org_sec > 0)
  SET t_defsched_org_sec_cd = loadcodevalue(4002578,"DEFSCHED",1)
  IF (t_defsched_org_sec_cd=0.0)
   SET t_check_org_sec = 0
  ENDIF
 ENDIF
 IF (t_check_org_sec > 0)
  SET table_name = "NONE"
  SET srvrec->crmstatus = uar_crmbeginapp(650001,srvrec->happ)
  IF ((srvrec->crmstatus != 0))
   SET failed = execute_error
   GO TO exit_script
  ENDIF
  SET srvrec->crmstatus = uar_crmbegintask(srvrec->happ,659100,srvrec->htask)
  IF ((srvrec->crmstatus != 0))
   SET failed = execute_error
   CALL uar_crmendapp(srvrec->happ)
   GO TO exit_script
  ENDIF
  SET srvrec->crmstatus = uar_crmbeginreq(srvrec->htask,"",659101,srvrec->hstep)
  IF ((srvrec->crmstatus != 0))
   SET failed = execute_error
   CALL uar_crmendapp(srvrec->happ)
   CALL uar_crmendtask(srvrec->htask)
   GO TO exit_script
  ENDIF
 ENDIF
 SET table_name = "SCH_DEF_SCHED"
 SELECT INTO "nl:"
  dsc.def_sched_id, lt.long_text_id
  FROM sch_def_sched dsc,
   long_text_reference lt
  PLAN (dsc
   WHERE dsc.mnemonic_key=patstring(find_string)
    AND dsc.def_sched_id > 0
    AND dsc.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ((dsc.logical_domain_id=m_logical_domain_id) OR (m_logical_domain_flag=0)) )
   JOIN (lt
   WHERE lt.long_text_id=dsc.info_sch_text_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   count2 = 0, reply->qual[count1].def_sched_id = dsc.def_sched_id, reply->qual[count1].mnem = dsc
   .mnemonic,
   reply->qual[count1].desc = dsc.description, reply->qual[count1].info_sch_text_id = dsc
   .info_sch_text_id
   IF (dsc.info_sch_text_id > 0)
    reply->qual[count1].info_sch_text = lt.long_text, reply->qual[count1].info_sch_text_updt_cnt = lt
    .updt_cnt
   ENDIF
   reply->qual[count1].beg_tm = dsc.beg_tm, reply->qual[count1].end_tm = dsc.end_tm, reply->qual[
   count1].interval = dsc.interval,
   reply->qual[count1].duration = dsc.duration, reply->qual[count1].apply_range = dsc.apply_range,
   reply->qual[count1].default_type_cd = dsc.default_type_cd,
   reply->qual[count1].default_type_meaning = dsc.default_type_meaning, reply->qual[count1].updt_cnt
    = dsc.updt_cnt, reply->qual[count1].active_ind = dsc.active_ind,
   reply->qual[count1].candidate_id = dsc.candidate_id
  FOOT REPORT
   reply->qual_cnt = count1, stat = alterlist(reply->qual,count1)
   IF (t_check_org_sec > 0)
    srvrec->hreq = uar_crmgetrequest(srvrec->hstep), stat = uar_srvsetlong(srvrec->hreq,"qual_cnt",
     reply->qual_cnt), stat = uar_srvsetshort(srvrec->hreq,"sec_check_mod",1),
    stat = uar_srvsetdouble(srvrec->hreq,"user_id",reqinfo->updt_id), stat = uar_srvsetdouble(srvrec
     ->hreq,"sec_type_cd",0.0), stat = uar_srvsetdouble(srvrec->hreq,"org_sec_type_cd",
     t_defsched_org_sec_cd)
    FOR (i = 1 TO reply->qual_cnt)
     srvrec->hreqitem = uar_srvadditem(srvrec->hreq,"qual"),stat = uar_srvsetdouble(srvrec->hreqitem,
      "parent1_id",reply->qual[i].def_sched_id)
    ENDFOR
    srvrec->crmstatus = uar_crmperform(srvrec->hstep)
    IF ((srvrec->crmstatus != 0))
     failed = execute_error, reply->qual_cnt = 0,
     CALL uar_crmendapp(srvrec->happ),
     CALL uar_crmendtask(srvrec->htask)
    ELSE
     srvrec->hrep = uar_crmgetreply(srvrec->hstep), t_reply_cnt = uar_srvgetitemcount(srvrec->hrep,
      "qual")
     IF ((t_reply_cnt != reply->qual_cnt))
      failed = execute_error, reply->qual_cnt = 0
     ENDIF
     t_index = 1
     FOR (i = 1 TO reply->qual_cnt)
       srvrec->hrepitem = uar_srvgetitem(srvrec->hrep,"qual",(i - 1)), t_parent1_id =
       uar_srvgetdouble(srvrec->hrepitem,"parent1_id"), t_granted = uar_srvgetshort(srvrec->hrepitem,
        "granted_ind")
       IF (t_granted >= 1
        AND (t_parent1_id=reply->qual[i].def_sched_id))
        IF (t_index != i)
         reply->qual[t_index].def_sched_id = reply->qual[i].def_sched_id, reply->qual[t_index].mnem
          = reply->qual[i].mnem, reply->qual[t_index].desc = reply->qual[i].desc,
         reply->qual[t_index].beg_tm = reply->qual[i].beg_tm, reply->qual[t_index].end_tm = reply->
         qual[i].end_tm, reply->qual[t_index].interval = reply->qual[i].interval,
         reply->qual[t_index].duration = reply->qual[i].duration, reply->qual[t_index].apply_range =
         reply->qual[i].apply_range, reply->qual[t_index].default_type_cd = reply->qual[i].
         default_type_cd,
         reply->qual[t_index].default_type_meaning = reply->qual[i].default_type_meaning, reply->
         qual[t_index].updt_cnt = reply->qual[i].updt_cnt, reply->qual[t_index].active_ind = reply->
         qual[i].active_ind,
         reply->qual[t_index].candidate_id = reply->qual[i].candidate_id
        ENDIF
        reply->qual[t_index].granted_ind = t_granted, t_index += 1
       ENDIF
     ENDFOR
     reply->qual_cnt = (t_index - 1)
    ENDIF
    stat = alterlist(reply->qual,reply->qual_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->call_echo_ind=1))
  CALL echorecord(reply)
 ENDIF
 SET table_name = "SCH_DEF_SLOT"
 SELECT INTO "nl:"
  d.seq, dsl.def_sched_id
  FROM (dummyt d  WITH seq = value(reply->qual_cnt)),
   sch_def_slot dsl
  PLAN (d
   WHERE (reply->qual_cnt > 0))
   JOIN (dsl
   WHERE (dsl.def_sched_id=reply->qual[d.seq].def_sched_id)
    AND dsl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  HEAD d.seq
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual[d.seq].slot_list,(count1+ 9))
   ENDIF
   reply->qual[d.seq].slot_list[count1].def_slot_id = dsl.def_slot_id, reply->qual[d.seq].slot_list[
   count1].seq_nbr = dsl.seq_nbr, reply->qual[d.seq].slot_list[count1].vis_beg_units = dsl
   .vis_beg_units,
   reply->qual[d.seq].slot_list[count1].vis_beg_units_cd = dsl.vis_beg_units_cd, reply->qual[d.seq].
   slot_list[count1].vis_beg_units_meaning = dsl.vis_beg_units_meaning, reply->qual[d.seq].slot_list[
   count1].vis_end_units = dsl.vis_end_units,
   reply->qual[d.seq].slot_list[count1].vis_end_units_cd = dsl.vis_end_units_cd, reply->qual[d.seq].
   slot_list[count1].vis_end_units_meaning = dsl.vis_end_units_meaning, reply->qual[d.seq].slot_list[
   count1].sch_flex_id = dsl.sch_flex_id,
   reply->qual[d.seq].slot_list[count1].interval = dsl.interval, reply->qual[d.seq].slot_list[count1]
   .slot_beg_offset = dsl.slot_beg_offset, reply->qual[d.seq].slot_list[count1].slot_end_offset = dsl
   .slot_end_offset,
   reply->qual[d.seq].slot_list[count1].slot_duration = dsl.slot_duration, reply->qual[d.seq].
   slot_list[count1].holiday_weekend_flag = dsl.holiday_weekend_flag, reply->qual[d.seq].slot_list[
   count1].beg_offset = dsl.beg_offset,
   reply->qual[d.seq].slot_list[count1].end_offset = dsl.end_offset, reply->qual[d.seq].slot_list[
   count1].vis_beg_offset = dsl.vis_beg_offset, reply->qual[d.seq].slot_list[count1].vis_end_offset
    = dsl.vis_end_offset,
   reply->qual[d.seq].slot_list[count1].slot_type_id = dsl.slot_type_id, reply->qual[d.seq].
   slot_list[count1].slot_mnem = dsl.slot_mnemonic, reply->qual[d.seq].slot_list[count1].
   slot_scheme_id = dsl.slot_scheme_id,
   reply->qual[d.seq].slot_list[count1].slot_desc = dsl.description, reply->qual[d.seq].slot_list[
   count1].contiguous_ind = dsl.contiguous_ind, reply->qual[d.seq].slot_list[count1].border_style =
   dsl.border_style,
   reply->qual[d.seq].slot_list[count1].border_size = dsl.border_size, reply->qual[d.seq].slot_list[
   count1].border_color = dsl.border_color, reply->qual[d.seq].slot_list[count1].shape = dsl.shape,
   reply->qual[d.seq].slot_list[count1].pen_shape = dsl.pen_shape, reply->qual[d.seq].slot_list[
   count1].duration = dsl.duration, reply->qual[d.seq].slot_list[count1].updt_cnt = dsl.updt_cnt,
   reply->qual[d.seq].slot_list[count1].active_ind = dsl.active_ind, reply->qual[d.seq].slot_list[
   count1].candidate_id = dsl.candidate_id, reply->qual[d.seq].slot_list[count1].
   group_capacity_default_qty = dsl.group_capacity_qty
  FOOT  d.seq
   reply->qual[d.seq].slot_list_cnt = count1, stat = alterlist(reply->qual[d.seq].slot_list,count1)
  WITH nocounter
 ;end select
 SET table_name = "SCH_DEF_RES"
 SELECT INTO "nl:"
  d.seq, dr.def_sched_id
  FROM (dummyt d  WITH seq = value(reply->qual_cnt)),
   sch_def_res dr
  PLAN (d
   WHERE (reply->qual_cnt > 0))
   JOIN (dr
   WHERE (dr.def_sched_id=reply->qual[d.seq].def_sched_id)
    AND dr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  HEAD d.seq
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual[d.seq].res_list,(count1+ 9))
   ENDIF
   reply->qual[d.seq].res_list[count1].res_cd = dr.resource_cd, reply->qual[d.seq].res_list[count1].
   updt_cnt = dr.updt_cnt, reply->qual[d.seq].res_list[count1].active_ind = dr.active_ind,
   reply->qual[d.seq].res_list[count1].candidate_id = dr.candidate_id
  FOOT  d.seq
   reply->qual[d.seq].res_list_cnt = count1, stat = alterlist(reply->qual[d.seq].res_list,count1)
  WITH nocounter
 ;end select
 IF ((reply->qual_cnt > 0))
  SELECT INTO "nl:"
   FROM sch_date_link_r dlr,
    sch_date_set ds
   PLAN (dlr
    WHERE dlr.parent_entity_name="SCH_DEF_SCHED"
     AND expand(ml_index,1,reply->qual_cnt,dlr.parent_entity_id,reply->qual[ml_index].def_sched_id))
    JOIN (ds
    WHERE ds.sch_date_set_id=dlr.sch_date_set_id)
   ORDER BY dlr.parent_entity_id, dlr.date_set_seq_nbr
   DETAIL
    ml_curindex = locateval(ml_index,1,reply->qual_cnt,dlr.parent_entity_id,reply->qual[ml_index].
     def_sched_id), reply->qual[ml_curindex].date_link_r_qual_cnt += 1
    IF (mod(reply->qual[ml_curindex].date_link_r_qual_cnt,10)=1)
     stat = alterlist(reply->qual[ml_curindex].date_link_r_qual,(reply->qual[ml_curindex].
      date_link_r_qual_cnt+ 9))
    ENDIF
    t_index = reply->qual[ml_curindex].date_link_r_qual_cnt, reply->qual[ml_curindex].
    date_link_r_qual[t_index].date_set_seq_nbr = dlr.date_set_seq_nbr, reply->qual[ml_curindex].
    date_link_r_qual[t_index].parent_entity_id = dlr.parent_entity_id,
    reply->qual[ml_curindex].date_link_r_qual[t_index].parent_entity_name = dlr.parent_entity_name,
    reply->qual[ml_curindex].date_link_r_qual[t_index].sch_date_link_r_id = dlr.sch_date_link_r_id,
    reply->qual[ml_curindex].date_link_r_qual[t_index].sch_date_set_id = dlr.sch_date_set_id,
    reply->qual[ml_curindex].date_link_r_qual[t_index].updt_cnt = dlr.updt_cnt, reply->qual[
    ml_curindex].date_link_r_qual[t_index].sch_date_set_mnem = ds.mnemonic, reply->qual[ml_curindex].
    date_link_r_qual[t_index].sch_date_set_desc = ds.description,
    reply->qual[ml_curindex].date_link_r_qual[t_index].sch_date_set_active_ind = ds.active_ind
   WITH nocounter, expand = 2
  ;end select
  FOR (ml_cnt1 = 1 TO reply->qual_cnt)
    IF ((reply->qual[ml_cnt1].date_link_r_qual_cnt > 0))
     SET stat = alterlist(reply->qual[ml_cnt1].date_link_r_qual,reply->qual[ml_cnt1].
      date_link_r_qual_cnt)
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed=false)
  CASE (reply->qual_cnt)
   OF 0:
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
  ENDCASE
 ELSE
  SET reqinfo->commit_ind = false
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF version_insert_error:
     CALL s_add_subeventstatus("VERSION_INSERT","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF version_delete_error:
     CALL s_add_subeventstatus("VERSION_DELETE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCL_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
