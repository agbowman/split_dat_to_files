CREATE PROGRAM bhs_auto_vitals
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
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}\fs22 ")
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
 DECLARE vitals_tabs = c20 WITH constant("\pard\tx2160\tx5040 ")
 SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf,vitals_tabs,blank_return)
 SET work->vitals_replace_rtf = build2(work->vitals_replace_rtf," \b\ul ","Vitals: ","\ul0\b0 ",
  newline)
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
       SET bld_output = build2(result_info->dates[d].date_time,"\tab ",substring(1,30,result_info->
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
 SET reply->text = concat(beg_doc," ",work->vitals_replace_rtf,end_doc)
#exit_script
 CALL echorecord(result_info)
 CALL echo(work->vitals_replace_rtf)
 CALL echorecord(text)
END GO
