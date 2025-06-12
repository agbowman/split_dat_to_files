CREATE PROGRAM bhs_gen_wcc_smart_template
 RECORD work(
   1 encntr_id = f8
   1 person_id = f8
   1 birth_dt_tm = dq8
   1 age_in_days = i4
   1 template_name = vc
   1 template_id = f8
   1 original_rtf = vc
   1 modified_rtf = vc
   1 problem_find_rtf = vc
   1 allergy_find_rtf = vc
   1 scripts_find_rtf = vc
   1 vital_find_rtf = vc
   1 problem_replace_rtf = vc
   1 allergy_replace_rtf = vc
   1 scripts_replace_rtf = vc
   1 vitals_replace_rtf = vc
 )
 DECLARE var_output = vc
 DECLARE wcc_age_ranges_filename = vc WITH noconstant("bhs_gen_wcc_age_ranges.dat")
 DECLARE wcc_file_path2 = vc WITH constant(concat(trim(logical("ccluserdir"),3),"/"))
 DECLARE wcc_file_path1 = vc WITH constant(concat(trim(logical("bhscust"),3),"/"))
 DECLARE wcc_file_logical = vc
 DECLARE end_line = c5 WITH constant("\par ")
 SET work->problem_find_rtf = "<<Problem List>>"
 SET work->allergy_find_rtf = "<<Allergy List>>"
 SET work->scripts_find_rtf = "<<Medication list>>"
 SET work->vital_find_rtf = "<<Vital Signs>>"
 SET work->problem_replace_rtf = "No Problems Recorded"
 SET work->allergy_replace_rtf = "No Allergies Recorded"
 SET work->scripts_replace_rtf = "No Prescriptions Recorded"
 SET work->vitals_replace_rtf = " "
 IF (reflect(parameter(1,0)) > " ")
  SET work->encntr_id = cnvtreal( $1)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("no encntr_id given. exiting script")
  GO TO exit_script
 ENDIF
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
  )
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (work->encntr_id=e.encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
  DETAIL
   work->person_id = p.person_id, work->birth_dt_tm = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
     .birth_tz),1), work->age_in_days = cnvtint(datetimediff(cnvtdatetime(sysdate),cnvtdatetimeutc(
      datetimezone(p.birth_dt_tm,p.birth_tz),1)))
  WITH nocounter
 ;end select
 IF ((work->person_id <= 0.00))
  CALL echo("invalid encounter_id given. exiting script")
  GO TO exit_script
 ENDIF
 IF (findfile(concat(wcc_file_path1,wcc_age_ranges_filename))=1)
  SET logical wcc_file_logical value(concat(wcc_file_path1,wcc_age_ranges_filename))
 ELSEIF (findfile(concat(wcc_file_path2,wcc_age_ranges_filename))=1)
  SET logical wcc_file_logical value(concat(wcc_file_path2,wcc_age_ranges_filename))
 ELSE
  CALL echo(build2("file '",wcc_age_ranges_filename,"' not found. exiting script"))
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl "wcc_file_logical"
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   tmp_name = fillstring(100," "), beg_age = 0, end_age = 0
  DETAIL
   IF ((work->template_name <= " "))
    tmp_name = " ", beg_age = 0, end_age = 0,
    tmp_name = piece(r.line,"|",1," ",0), beg_age = cnvtint(piece(r.line,"|",2,"0",0)), end_age =
    cnvtint(piece(r.line,"|",3,"0",0))
    IF (beg_age=0
     AND (work->age_in_days <= end_age))
     work->template_name = trim(tmp_name,3)
    ELSEIF ((work->age_in_days >= beg_age)
     AND (work->age_in_days <= end_age))
     work->template_name = trim(tmp_name,3)
    ELSEIF ((work->age_in_days >= beg_age)
     AND end_age=0)
     work->template_name = trim(tmp_name,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 IF ((work->template_name <= " "))
  CALL echo("no wcc template name found. exiting script")
  GO TO exit_script
 ELSE
  CALL echo(build("Using template: ",work->template_name))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_note_template cnt,
   long_blob lb
  PLAN (cnt
   WHERE (work->template_name=cnt.template_name))
   JOIN (lb
   WHERE cnt.template_id=lb.parent_entity_id
    AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE")
  DETAIL
   work->template_id = cnt.template_id, work->original_rtf = trim(lb.long_blob,3)
  WITH nocounter
 ;end select
 IF ((work->template_id <= 0.00))
  CALL echo("wcc template not found in clinical_note_template table. exiting script")
  GO TO exit_script
 ENDIF
 IF (findstring(work->problem_find_rtf,work->original_rtf) <= 0)
  CALL echo("no problem list tag found.")
 ELSE
  EXECUTE bhs_sys_get_problems_req "person"
  SET stat = alterlist(bhs_problems_req->persons,1)
  SET bhs_problems_req->p_cnt = 1
  SET bhs_problems_req->persons[1].person_id = work->person_id
  EXECUTE bhs_sys_get_problems_run
  IF ((bhs_problems_reply->persons[1].p_cnt > 0))
   FOR (p = 1 TO bhs_problems_reply->persons[1].p_cnt)
     IF (p=1)
      SET work->problem_replace_rtf = trim(bhs_problems_reply->persons[1].problems[p].problem,3)
     ELSE
      SET work->problem_replace_rtf = build2(work->problem_replace_rtf,end_line,trim(
        bhs_problems_reply->persons[1].problems[p].problem,3))
     ENDIF
   ENDFOR
  ENDIF
  EXECUTE bhs_sys_get_problems_req "cleanup"
 ENDIF
 IF (findstring(work->allergy_find_rtf,work->original_rtf) <= 0)
  CALL echo("no allergy list tag found.")
 ELSE
  EXECUTE bhs_sys_get_allergies_req "person"
  SET stat = alterlist(bhs_allergies_req->persons,1)
  SET bhs_allergies_req->p_cnt = 1
  SET bhs_allergies_req->persons[1].person_id = work->person_id
  EXECUTE bhs_sys_get_allergies_run
  IF ((bhs_allergies_reply->persons[1].a_cnt > 0))
   FOR (a = 1 TO bhs_allergies_reply->persons[1].a_cnt)
     IF (a=1)
      SET work->allergy_replace_rtf = trim(bhs_allergies_reply->persons[1].allergies[a].
       substance_disp,3)
     ELSE
      SET work->allergy_replace_rtf = build2(work->allergy_replace_rtf,end_line,trim(
        bhs_allergies_reply->persons[1].allergies[a].substance_disp,3))
     ENDIF
   ENDFOR
  ENDIF
  EXECUTE bhs_sys_get_allergies_req "cleanup"
 ENDIF
 IF (findstring(work->scripts_find_rtf,work->original_rtf) <= 0)
  CALL echo("no scripts list tag found.")
 ELSE
  EXECUTE bhs_sys_get_medications_req "prescriptions"
  SET stat = alterlist(bhs_medications_req->persons,1)
  SET bhs_medications_req->p_cnt = 1
  SET bhs_medications_req->persons[1].person_id = work->person_id
  EXECUTE bhs_sys_get_medications_run
  IF ((bhs_medications_reply->persons[1].m_cnt > 0))
   FOR (m = 1 TO bhs_medications_reply->persons[1].m_cnt)
     IF (m=1)
      SET work->scripts_replace_rtf = build2(trim(bhs_medications_reply->persons[1].medications[m].
        hna_order_mnemonic,3)," (",trim(bhs_medications_reply->persons[1].medications[m].
        ordered_as_mnemonic,3),")")
     ELSE
      SET work->scripts_replace_rtf = build2(work->scripts_replace_rtf,end_line,trim(
        bhs_medications_reply->persons[1].medications[m].hna_order_mnemonic,3)," (",trim(
        bhs_medications_reply->persons[1].medications[m].ordered_as_mnemonic,3),
       ")")
     ENDIF
   ENDFOR
  ENDIF
  EXECUTE bhs_sys_get_medications_req "cleanup"
 ENDIF
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}\fs22")
 DECLARE end_doc = c1 WITH constant("}")
 DECLARE beg_lock = c44 WITH constant("{\*\txfieldstart\txfieldtype0\txfieldflags3}")
 DECLARE end_lock = c15 WITH constant("{\*\txfieldend}")
 DECLARE beg_bold = c2 WITH constant("\b")
 DECLARE end_bold = c3 WITH constant("\b0")
 DECLARE beg_ital = c2 WITH constant("\i")
 DECLARE end_ital = c3 WITH constant("\i0")
 DECLARE beg_uline = c3 WITH constant("\ul ")
 DECLARE end_uline = c4 WITH constant("\ul0 ")
 DECLARE newline = c6 WITH constant(concat("\par",char(10)))
 DECLARE blank_return = c2 WITH constant(concat(char(10),char(13)))
 DECLARE end_para = c5 WITH constant("\pard ")
 DECLARE indent0 = c4 WITH constant("\li0")
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 DECLARE indent3 = c6 WITH constant("\li864")
 DECLARE vitals_tabs = c20 WITH constant("\pard\tx2160\tx5040\par ")
 SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,vitals_tabs,blank_return)
 SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,"\ul ","Vitals: ","\ul0 ")
 SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,vitals_tabs,blank_return)
 EXECUTE bhs_get_ce_res_flowsrt 0.00, value(work->encntr_id), "CLINICALMEASUREMENTS",
 1, 0
 IF ((result_info->d_cnt <= 0))
  SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,"No Vitals found for last 24 hours")
  SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,newline)
 ELSE
  DECLARE bld_output = vc
  DECLARE bld_output2 = vc
  FOR (d = 1 TO result_info->d_cnt)
    FREE SET bld_output
    FOR (r = 1 TO result_info->dates[d].r_cnt)
      IF ((result_info->dates[d].results[r].display != null))
       SET bld_output = concat(result_info->dates[d].date_time,"\tab ",substring(1,30,result_info->
         dates[d].results[r].display))
       CALL echo(build("2:",bld_output))
       SET bld_output2 = concat(bld_output,"\tab ",substring(1,25,result_info->dates[d].results[r].
         value))
       CALL echo(build("3:",bld_output2))
       SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,bld_output2,newline)
       FREE SET bld_output
       FREE SET bld_output2
      ENDIF
    ENDFOR
    FREE SET bld_output
    FREE SET bld_output2
  ENDFOR
 ENDIF
 EXECUTE bhs_get_ce_res_flowsrt 0.00, value(work->encntr_id), "VITALSIGNSSECTION",
 1, 0
 IF ((result_info->d_cnt <= 0))
  SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,newline)
 ELSE
  DECLARE bld_output = vc
  DECLARE bld_output2 = vc
  FOR (d = 1 TO result_info->d_cnt)
    FREE SET bld_output
    FOR (r = 1 TO result_info->dates[d].r_cnt)
      IF ((result_info->dates[d].results[r].display != null))
       SET bld_output = concat(result_info->dates[d].date_time,"\tab ",substring(1,30,result_info->
         dates[d].results[r].display))
       CALL echo(build("2:",bld_output))
       SET bld_output2 = concat(bld_output,"\tab ",substring(1,25,result_info->dates[d].results[r].
         value))
       CALL echo(build("3:",bld_output2))
       SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,bld_output2,newline)
       FREE SET bld_output
       FREE SET bld_output2
      ENDIF
    ENDFOR
    FREE SET bld_output
    FREE SET bld_output2
  ENDFOR
 ENDIF
 SET work->modified_rtf = work->original_rtf
 SET work->modified_rtf = replace(work->modified_rtf,work->problem_find_rtf,work->problem_replace_rtf
  )
 SET work->modified_rtf = replace(work->modified_rtf,work->allergy_find_rtf,work->allergy_replace_rtf
  )
 SET work->modified_rtf = replace(work->modified_rtf,work->scripts_find_rtf,work->scripts_replace_rtf
  )
 SET work->modified_rtf = replace(work->modified_rtf,work->vital_find_rtf,work->vitals_replace_rtf)
 SET reply->text = work->modified_rtf
#exit_script
 IF (trim(var_output,3) > " ")
  CALL echorecord(result_info)
 ENDIF
END GO
