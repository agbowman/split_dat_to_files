CREATE PROGRAM afc_rpt_susp_reason:dba
 PAINT
 SET width = 132
 SET modify = system
 EXECUTE cclseclogin
 SET suspense_desc = fillstring(50," ")
 DECLARE array_count = i4
 DECLARE susp_cnt = i4
 SET suspense_reason_line = fillstring(50,"-")
 SET count_line = fillstring(10,"-")
#prompt_beg_date
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 CALL text(10,2,"Enter a beginning date (dd/mmm/yyyy): ")
 CALL accept(10,40,"nndpppdnnnn;cs",format(curdate,"dd/mmm/yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd/mmm/yyyy;;d")=cnvtupper(curaccept))
 SET beg_date = concat(curaccept," 00:00:00.01")
 CALL text(11,2,concat("The beginning date you entered is: ",beg_date))
 CALL text(12,2,"Is this correct? (Y/N/Q): ")
 CALL accept(12,28,"X;C","Y"
  WHERE curaccept IN ("Y", "N", "Q", "y", "n",
  "q"))
 IF (cnvtupper(curaccept)="Y")
  CALL text(20,2,concat("Using beginning date of: ",beg_date))
  GO TO prompt_end_date
 ELSEIF (cnvtupper(curaccept)="Q")
  GO TO end_script
 ELSEIF (cnvtupper(curaccept)="N")
  GO TO prompt_beg_date
 ENDIF
#prompt_end_date
 CALL text(14,2,"Enter an ending date (dd/mmm/yyyy): ")
 CALL accept(14,40,"nndpppdnnnn;cs",format(curdate,"dd/mmm/yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd/mmm/yyyy;;d")=cnvtupper(curaccept))
 SET end_date = concat(curaccept," 23:59:59.99")
 CALL text(15,2,concat("The ending date you entered is: ",end_date))
 CALL text(16,2,"Is this correct? (Y/N/Q): ")
 CALL accept(16,28,"X;C","Y"
  WHERE curaccept IN ("Y", "N", "Q", "y", "n",
  "q"))
 IF (cnvtupper(curaccept)="Y")
  CALL text(20,51,concat("and ending date of: ",end_date))
  GO TO build_report
 ELSEIF (cnvtupper(curaccept)="Q")
  GO TO end_script
 ELSEIF (cnvtupper(curaccept)="N")
  GO TO prompt_end_date
 ENDIF
#build_report
 DECLARE suspense_code = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 SET code_set = 13019
 SET cdf_meaning = "SUSPENSE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,suspense_code)
 SELECT
  cm.field6, cm.field1_id, c.charge_description,
  c.service_dt_tm, ce.ext_p_event_id
  FROM charge c,
   charge_mod cm,
   charge_event ce
  PLAN (c
   WHERE c.service_dt_tm BETWEEN cnvtdatetime(beg_date) AND cnvtdatetime(end_date)
    AND c.active_ind=1)
   JOIN (ce
   WHERE ce.charge_event_id=c.charge_event_id
    AND ce.ext_p_event_id <= 0)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.charge_mod_type_cd=suspense_code)
  ORDER BY cm.field1_id
  HEAD REPORT
   col 45, "SUSPENSE REASONS REPORT"
  HEAD PAGE
   row + 2, col 10, "Suspense Reason",
   col 70, "Count", row + 1,
   col 10, suspense_reason_line, col 70,
   count_line
  HEAD cm.field1_id
   susp_cnt = (susp_cnt+ 1), suspense_desc = cm.field6
  DETAIL
   array_count = (array_count+ 1), susp_cnt = (susp_cnt+ 1)
  FOOT  cm.field1_id
   row + 2, col 10, suspense_desc,
   col 69, susp_cnt, susp_cnt = 0
 ;end select
#end_script
END GO
