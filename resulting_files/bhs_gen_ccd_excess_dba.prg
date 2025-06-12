CREATE PROGRAM bhs_gen_ccd_excess:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Runner number:" = 0,
  "Runner count:" = 0
  WITH outdev, ml_run_num, ml_run_cnt
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 FREE RECORD temp_ccd
 RECORD temp_ccd(
   1 list_cnt = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
 )
 DECLARE ms_err_msg = vc WITH protect, noconstant(" ")
 DECLARE ml_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_template_param = vc WITH protect, constant(
  "T:680884409.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0")
 DECLARE ml_number_of_runners = i4 WITH protect, constant( $ML_RUN_CNT)
 DECLARE ml_runner_num = i4 WITH protect, constant( $ML_RUN_NUM)
 DECLARE ms_gen_ccd_file = vc WITH protect, constant(build(logical("bhscust"),
   "/bhs_ccd_gen/bhs_gen_ccd_",format(sysdate,"ddmmmyyyy;;d"),".dat"))
 FREE DEFINE rtl2
 DEFINE rtl2 value(ms_gen_ccd_file)
 IF (error(ms_err_msg,0) != 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  textlen_t_line = textlen(t.line)
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   temp_rec_cnt = 0, temp_person_id = 0.0, temp_encntr_id = 0.0,
   temp_comma_pos = 0, temp_ccd->list_cnt = 0
  DETAIL
   temp_comma_pos = findstring(",",t.line), temp_person_id = cnvtreal(trim(substring(1,(
      temp_comma_pos - 1),t.line),3)), temp_encntr_id = cnvtreal(trim(substring((temp_comma_pos+ 1),
      textlen_t_line,t.line),3))
   IF (temp_person_id > 0.0
    AND temp_encntr_id > 0.0)
    temp_rec_cnt += 1
    IF (((temp_rec_cnt=ml_runner_num) OR (mod((temp_rec_cnt - ml_runner_num),ml_number_of_runners)=0
    )) )
     temp_ccd->list_cnt += 1, stat = alterlist(temp_ccd->list,temp_ccd->list_cnt), temp_ccd->list[
     temp_ccd->list_cnt].person_id = temp_person_id,
     temp_ccd->list[temp_ccd->list_cnt].encntr_id = temp_encntr_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 FOR (ml_for_cnt = 1 TO temp_ccd->list_cnt)
   EXECUTE bhs_si_ccd_trigger 0, ms_template_param, temp_ccd->list[ml_for_cnt].person_id,
   temp_ccd->list[ml_for_cnt].encntr_id, ""
 ENDFOR
 CALL bhs_sbr_log("log","",0,"CCD",0.0,
  "",concat("CCD csv file generated: ",ms_gen_ccd_file),"R")
#exit_script
END GO
