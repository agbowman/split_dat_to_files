CREATE PROGRAM dm2_tz_update_parent_qual
 PROMPT
  "Enter From Value: " = 0,
  "Enter To Value: " = 0,
  "Enter Number of Sessions (default: 1): " = 1,
  "Enter Date: (format: MM/DD/YYYY HH:MM:SS)" = ""
 DECLARE from_val = i4 WITH protect, noconstant( $1)
 DECLARE to_val = i4 WITH protect, noconstant( $2)
 DECLARE nbr_sessions = i4 WITH protect, noconstant( $3)
 DECLARE d_date = vc WITH protect, noconstant(cnvtupper( $4))
 DECLARE tab_name = vc WITH protect, noconstant("")
 DECLARE col_name = vc WITH protect, noconstant("")
 DECLARE index_column = vc WITH protect, noconstant("")
 DECLARE append_ind = i4 WITH protect, noconstant(0)
 DECLARE complete_ind = i4 WITH protect, noconstant(0)
 DECLARE filename = vc WITH protect, noconstant("dm2_tz_update")
 DECLARE str_qual = vc WITH protect, noconstant("")
 FREE RECORD table_column
 RECORD table_column(
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
     2 indexed_column = vc
     2 qualification = vc
 )
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET stat = alterlist(table_column->qual,46)
 SET table_column->qual[1].table_name = "ORDERS"
 SET table_column->qual[2].table_name = "ORDERS"
 SET table_column->qual[3].table_name = "ORDERS"
 SET table_column->qual[4].table_name = "ORDERS"
 SET table_column->qual[5].table_name = "ORDERS"
 SET table_column->qual[6].table_name = "ORDERS"
 SET table_column->qual[7].table_name = "ORDER_ACTION"
 SET table_column->qual[8].table_name = "ORDER_ACTION"
 SET table_column->qual[9].table_name = "ORDER_ACTION"
 SET table_column->qual[10].table_name = "ORDER_ACTION"
 SET table_column->qual[11].table_name = "ORDER_DETAIL"
 SET table_column->qual[12].table_name = "ORDER_REVIEW"
 SET table_column->qual[13].table_name = "FILL_BATCH_HX"
 SET table_column->qual[14].table_name = "FILL_BATCH_HX"
 SET table_column->qual[15].table_name = "FILL_BATCH_HX"
 SET table_column->qual[16].table_name = "FILL_CYCLE"
 SET table_column->qual[17].table_name = "FILL_CYCLE"
 SET table_column->qual[18].table_name = "FILL_CYCLE_HX"
 SET table_column->qual[19].table_name = "FILL_CYCLE_HX"
 SET table_column->qual[20].table_name = "ORDER_DISPENSE"
 SET table_column->qual[21].table_name = "ORDER_DISPENSE"
 SET table_column->qual[22].table_name = "ORDER_DISPENSE"
 SET table_column->qual[23].table_name = "ORDER_DISPENSE"
 SET table_column->qual[24].table_name = "ORDER_DISPENSE"
 SET table_column->qual[25].table_name = "MED_ADMIN_EVENT"
 SET table_column->qual[26].table_name = "MED_ADMIN_EVENT"
 SET table_column->qual[27].table_name = "MED_ADMIN_MED_ERROR"
 SET table_column->qual[28].table_name = "MED_ADMIN_MED_ERROR"
 SET table_column->qual[29].table_name = "MED_ADMIN_MED_ERROR"
 SET table_column->qual[30].table_name = "DCP_FORMS_ACTIVITY"
 SET table_column->qual[31].table_name = "PERSON"
 SET table_column->qual[32].table_name = "EEM_ABN_CHECK"
 SET table_column->qual[33].table_name = "SCH_EVENT_DISP"
 SET table_column->qual[34].table_name = "TASK_ACTIVITY"
 SET table_column->qual[35].table_name = "CE_DATE_RESULT"
 SET table_column->qual[36].table_name = "CE_MED_RESULT"
 SET table_column->qual[37].table_name = "CE_MED_RESULT"
 SET table_column->qual[38].table_name = "CLINICAL_EVENT"
 SET table_column->qual[39].table_name = "CE_EVENT_NOTE"
 SET table_column->qual[40].table_name = "CE_EVENT_PRSNL"
 SET table_column->qual[41].table_name = "CE_EVENT_PRSNL"
 SET table_column->qual[42].table_name = "CE_SPECIMEN_COLL"
 SET table_column->qual[43].table_name = "CE_SUSCEPTIBILITY"
 SET table_column->qual[44].table_name = "CLINICAL_EVENT"
 SET table_column->qual[45].table_name = "CLINICAL_EVENT"
 SET table_column->qual[46].table_name = "CLINICAL_EVENT"
 SET table_column->qual[1].column_name = "ORIG_ORDER_TZ"
 SET table_column->qual[2].column_name = "CURRENT_START_TZ"
 SET table_column->qual[3].column_name = "DISCONTINUE_EFFECTIVE_TZ"
 SET table_column->qual[4].column_name = "PROJECTED_STOP_TZ"
 SET table_column->qual[5].column_name = "RESUME_EFFECTIVE_TZ"
 SET table_column->qual[6].column_name = "SUSPEND_EFFECTIVE_TZ"
 SET table_column->qual[7].column_name = "EFFECTIVE_TZ"
 SET table_column->qual[8].column_name = "ORDER_TZ"
 SET table_column->qual[9].column_name = "PROJECTED_STOP_TZ"
 SET table_column->qual[10].column_name = "ACTION_TZ"
 SET table_column->qual[11].column_name = "OE_FIELD_TZ"
 SET table_column->qual[12].column_name = "REVIEW_TZ"
 SET table_column->qual[13].column_name = "FROM_TZ"
 SET table_column->qual[14].column_name = "START_TZ"
 SET table_column->qual[15].column_name = "TO_TZ"
 SET table_column->qual[16].column_name = "FROM_TZ"
 SET table_column->qual[17].column_name = "TO_TZ"
 SET table_column->qual[18].column_name = "FROM_TZ"
 SET table_column->qual[19].column_name = "TO_TZ"
 SET table_column->qual[20].column_name = "NEXT_DISPENSE_TZ"
 SET table_column->qual[21].column_name = "RESUME_TZ"
 SET table_column->qual[22].column_name = "START_DISPENSE_TZ"
 SET table_column->qual[23].column_name = "STOP_TZ"
 SET table_column->qual[24].column_name = "SUSPEND_TZ"
 SET table_column->qual[25].column_name = "SCHEDULED_TZ"
 SET table_column->qual[26].column_name = "VERIFICATION_TZ"
 SET table_column->qual[27].column_name = "ADMIN_TZ"
 SET table_column->qual[28].column_name = "SCHEDULED_TZ"
 SET table_column->qual[29].column_name = "VERIFICATION_TZ"
 SET table_column->qual[30].column_name = "FORM_TZ"
 SET table_column->qual[31].column_name = "BIRTH_TZ"
 SET table_column->qual[32].column_name = "BIRTH_TZ"
 SET table_column->qual[33].column_name = "DISP_TZ"
 SET table_column->qual[34].column_name = "TASK_TZ"
 SET table_column->qual[35].column_name = "RESULT_TZ"
 SET table_column->qual[36].column_name = "ADMIN_END_TZ"
 SET table_column->qual[37].column_name = "ADMIN_START_TZ"
 SET table_column->qual[38].column_name = "EVENT_END_TZ"
 SET table_column->qual[39].column_name = "NOTE_TZ"
 SET table_column->qual[40].column_name = "ACTION_TZ"
 SET table_column->qual[41].column_name = "REQUEST_TZ"
 SET table_column->qual[42].column_name = "COLLECT_TZ"
 SET table_column->qual[43].column_name = "RESULT_TZ"
 SET table_column->qual[44].column_name = "EVENT_START_TZ"
 SET table_column->qual[45].column_name = "PERFORMED_TZ"
 SET table_column->qual[46].column_name = "VERIFIED_TZ"
 SET table_column->qual[1].indexed_column = "ORDER_ID"
 SET table_column->qual[2].indexed_column = "ORDER_ID"
 SET table_column->qual[3].indexed_column = "ORDER_ID"
 SET table_column->qual[4].indexed_column = "ORDER_ID"
 SET table_column->qual[5].indexed_column = "ORDER_ID"
 SET table_column->qual[6].indexed_column = "ORDER_ID"
 SET table_column->qual[7].indexed_column = "ORDER_ID"
 SET table_column->qual[8].indexed_column = "ORDER_ID"
 SET table_column->qual[9].indexed_column = "ORDER_ID"
 SET table_column->qual[10].indexed_column = "ORDER_ID"
 SET table_column->qual[11].indexed_column = "ORDER_ID"
 SET table_column->qual[12].indexed_column = "ORDER_ID"
 SET table_column->qual[13].indexed_column = "FILL_HX_ID"
 SET table_column->qual[14].indexed_column = "FILL_HX_ID"
 SET table_column->qual[15].indexed_column = "FILL_HX_ID"
 SET table_column->qual[16].indexed_column = "FILL_CYCLE_ID"
 SET table_column->qual[17].indexed_column = "FILL_CYCLE_ID"
 SET table_column->qual[18].indexed_column = "FILL_HX_ID"
 SET table_column->qual[19].indexed_column = "FILL_HX_ID"
 SET table_column->qual[20].indexed_column = "ORDER_ID"
 SET table_column->qual[21].indexed_column = "ORDER_ID"
 SET table_column->qual[22].indexed_column = "ORDER_ID"
 SET table_column->qual[23].indexed_column = "ORDER_ID"
 SET table_column->qual[24].indexed_column = "ORDER_ID"
 SET table_column->qual[25].indexed_column = "MED_ADMIN_EVENT_ID"
 SET table_column->qual[26].indexed_column = "MED_ADMIN_EVENT_ID"
 SET table_column->qual[27].indexed_column = "MED_ADMIN_MED_ERROR_ID"
 SET table_column->qual[28].indexed_column = "MED_ADMIN_MED_ERROR_ID"
 SET table_column->qual[29].indexed_column = "MED_ADMIN_MED_ERROR_ID"
 SET table_column->qual[30].indexed_column = "DCP_FORMS_ACTIVITY_ID"
 SET table_column->qual[31].indexed_column = "PERSON_ID"
 SET table_column->qual[32].indexed_column = "ABN_CHECK_ID"
 SET table_column->qual[33].indexed_column = "SCH_EVENT_ID"
 SET table_column->qual[34].indexed_column = "TASK_ID"
 SET table_column->qual[35].indexed_column = "EVENT_ID"
 SET table_column->qual[36].indexed_column = "EVENT_ID"
 SET table_column->qual[37].indexed_column = "EVENT_ID"
 SET table_column->qual[38].indexed_column = "CLINICAL_EVENT_ID"
 SET table_column->qual[39].indexed_column = "CE_EVENT_NOTE_ID"
 SET table_column->qual[40].indexed_column = "CE_EVENT_PRSNL_ID"
 SET table_column->qual[41].indexed_column = "CE_EVENT_PRSNL_ID"
 SET table_column->qual[42].indexed_column = "EVENT_ID"
 SET table_column->qual[43].indexed_column = "EVENT_ID"
 SET table_column->qual[44].indexed_column = "CLINICAL_EVENT_ID"
 SET table_column->qual[45].indexed_column = "CLINICAL_EVENT_ID"
 SET table_column->qual[46].indexed_column = "CLINICAL_EVENT_ID"
 SET table_column->qual[1].qualification = concat("EXISTS(SELECT 1 from ORDER_ACTION oa WHERE","^)",
  char(10),char(13)," asis(",
  "^"," a.order_id=oa.order_id and oa.action_sequence=1 and","^)",char(10),char(13),
  " asis(","^"," oa.action_dt_tm<=to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[2].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[3].qualification = concat(
  "NOT EXISTS(SELECT 1 FROM ORDER_ACTION oa, CODE_VALUE cv WHERE","^)",char(10),char(13)," asis(",
  "^"," a.order_id = oa.order_id and oa.action_type_cd = cv.code_value and","^)",char(10),char(13),
  " asis(","^"," cv.cdf_meaning in('DISCONTINUE', 'FUTUREDC') and cv.code_set =  6003 and  ","^)",
  char(10),
  char(13)," asis(","^"," oa.action_dt_tm > to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[4].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[5].qualification = concat(
  "NOT EXISTS(SELECT 1 FROM ORDER_ACTION oa, CODE_VALUE cv WHERE","^)",char(10),char(13)," asis(",
  "^"," a.order_id = oa.order_id and oa.action_type_cd = cv.code_value and","^)",char(10),char(13),
  " asis(","^"," cv.cdf_meaning = 'RESUME' and cv.code_set =  6003 and","^)",char(10),
  char(13)," asis(","^"," oa.action_dt_tm > to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[6].qualification = concat(
  "NOT EXISTS(SELECT 1 FROM ORDER_ACTION oa, CODE_VALUE cv WHERE","^)",char(10),char(13)," asis(",
  "^"," a.order_id = oa.order_id and oa.action_type_cd = cv.code_value and","^)",char(10),char(13),
  " asis(","^"," cv.cdf_meaning = 'SUSPEND' and cv.code_set =  6003 and","^)",char(10),
  char(13)," asis(","^"," oa.action_dt_tm > to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[7].qualification = concat("a.ACTION_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[8].qualification = concat("a.ACTION_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[9].qualification = concat("a.ACTION_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[10].qualification = concat("a.ACTION_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[11].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[12].qualification = concat("a.REVIEW_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[13].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[14].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[15].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[16].qualification = concat(
  "EXISTS(SELECT 1 from FILL_CYCLE_HX fc where fc.fill_hx_id = ","a.fill_cycle_id and ","^)",char(10),
  char(13),
  " asis(","^","   start_dt_tm <= to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[17].qualification = concat(
  "EXISTS(SELECT 1 from FILL_CYCLE_HX fc where fc.fill_hx_id = ","a.fill_cycle_id and ","^)",char(10),
  char(13),
  " asis(","^","    start_dt_tm <= to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS'))")
 SET table_column->qual[18].qualification = concat("a.START_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[19].qualification = concat("a.START_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[20].qualification = concat("a.pharm_type_cd in( ",trim(cnvtstring(cinpatient)
   ),",0) and","^)",char(10),
  char(13)," asis(","^"," ((to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS') > ","^)",char(10),char(13)," asis(",
  "^","(select max(oa.action_dt_tm) from","^)",char(10),char(13),
  " asis(","^"," order_action oa, code_value cv  where cv.code_set = 6003 and","^)",char(10),
  char(13)," asis(","^",
  " (cv.cdf_meaning = 'MODIFY' or cv.cdf_meaning = 'RESUME' or cv.cdf_meaning = 'RENEW' or","^)",
  char(10),char(13)," asis(","^"," cv.cdf_meaning = 'ORDER' or cv.cdf_meaning = 'RESCHEDULE') and",
  "^)",char(10),char(13)," asis(","^",
  " oa.action_type_cd = cv.code_value and oa.order_id = a.order_id))","^)",char(10),char(13)," asis(",
  "^"," or (to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS') > (select max(dh.updt_dt_tm)","^)",
  char(10),char(13)," asis(","^"," from dispense_hx dh, code_value cv where",
  "^)",char(10),char(13)," asis(","^",
  " cv.code_set = 4032 and (cv.cdf_meaning = 'CHGONADMIN' or","^)",char(10),char(13),"asis(",
  "^"," cv.cdf_meaning = 'CRDTONADMIN' or cv.cdf_meaning = 'DEVICEDISPEN' or","^)",char(10),char(13),
  " asis(","^"," cv.cdf_meaning = 'DEVICERETURN' or","^)",char(10),
  char(13)," asis(","^"," cv.cdf_meaning = 'MANUALCHARGE' or cv.cdf_meaning = 'MANUALCREDIT' or","^)",
  char(10),char(13)," asis(","^"," cv.cdf_meaning = 'FIRSTDOSE' or",
  "^)",char(10),char(13),"asis(","^",
  " cv.cdf_meaning ='INITIALDOSE' or cv.cdf_meaning='FILLLIST') and dh.disp_event_type_cd =","^)",
  char(10),char(13)," asis(",
  "^"," cv.code_value and dh.order_id = a.order_id)))")
 SET table_column->qual[21].qualification = concat("to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS') > ",
  "^)",char(10),
  char(13)," asis(","^"," (select max(oa.action_dt_tm) from order_action oa, code_value cv","^)",
  char(10),char(13)," asis(","^","   where cv.code_set = 6003 and  cv.cdf_meaning ",
  "^)",char(10),char(13)," asis(","^",
  "  = 'RESUME' and oa.order_id = a.order_id and oa.action_type_cd = cv.code_value)")
 SET table_column->qual[22].qualification = concat("to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS') > ",
  "^)",char(10),
  char(13)," asis(","^","(select max(odet.updt_dt_tm) from order_detail odet where","^)",
  char(10),char(13)," asis(","^"," odet.order_id = a.order_id and odet.oe_field_meaning_id = 2389)")
 SET table_column->qual[23].qualification = concat("to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS') > ",
  "^)",char(10),
  char(13)," asis(","^","(select max(odet.updt_dt_tm) from order_detail odet where","^)",
  char(10),char(13)," asis(","^"," odet.order_id = a.order_id and odet.oe_field_meaning_id = 2073 )")
 SET table_column->qual[24].qualification = concat("to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS') > ",
  "^)",char(10),
  char(13)," asis(","^","(select max(oa.action_dt_tm) from order_action oa, code_value cv where","^)",
  char(10),char(13)," asis(","^"," cv.code_set = 6003 and",
  "^)",char(10),char(13)," asis(","^",
  " cv.cdf_meaning = 'SUSPEND' and oa.order_id = a.order_id and ","^)",char(10),char(13)," asis(",
  "^","   oa.action_type_cd = cv.code_value) ")
 SET table_column->qual[25].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[26].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[27].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[28].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[29].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[30].qualification = concat("a.LAST_ACTIVITY_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')","^)",char(10),
  char(13)," asis(","^"," OR a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[31].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[32].qualification = concat("a.ACTIVE_STATUS_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[33].qualification = concat("a.DISP_FIELD_ID = 15 AND","^)",char(10),char(13),
  " asis(",
  "^"," a.UPDT_DT_TM <= to_date('",d_date,"','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[34].qualification = concat("a.UPDT_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[35].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[36].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[37].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[38].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[39].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[40].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[41].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[42].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[43].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[44].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[45].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 SET table_column->qual[46].qualification = concat("a.VALID_FROM_DT_TM <= to_date('",d_date,
  "','MM/DD/YYYY HH24:MI:SS')")
 IF (((from_val < 0) OR (to_val < 0)) )
  CALL echo("The To and From values cannot be negative")
  GO TO exit_program
 ENDIF
 IF (from_val=to_val)
  CALL echo("The To value must be different than the From value")
  GO TO exit_program
 ENDIF
 IF (trim(d_date)="")
  CALL echo("You must enter a Date in the correct format")
  GO TO exit_program
 ENDIF
 FOR (idx = 1 TO size(table_column->qual,5))
   SET nbr_sessions =  $3
   IF (idx=1)
    SET complete_ind = 0
    SET append_ind = 0
   ELSE
    SET complete_ind = 0
    SET append_ind = 1
   ENDIF
   SET tab_name = table_column->qual[idx].table_name
   SET col_name = table_column->qual[idx].column_name
   SET str_qual = trim(table_column->qual[idx].qualification)
   IF (nbr_sessions=1)
    SET index_colum = ""
   ELSE
    SET index_column = table_column->qual[idx].indexed_column
    IF (index_column="")
     SET nbr_sessions = 1
    ELSE
     SELECT INTO "nl:"
      FROM dba_tab_columns d
      WHERE d.table_name=tab_name
       AND d.column_name=index_column
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET nbr_sessions = 1
      SET index_column = ""
     ENDIF
    ENDIF
   ENDIF
   CALL echo("***********************************************************************")
   CALL echo(concat("Creating file for table ",tab_name," column ",col_name," ..."))
   CALL echo("***********************************************************************")
   EXECUTE dm2_tz_column_update tab_name, col_name, from_val,
   to_val, nbr_sessions, str_qual,
   index_column, "dm2_tz_update", append_ind,
   complete_ind, 0
 ENDFOR
 FOR (idx = 1 TO size(table_column->qual,5))
   SET nbr_sessions =  $3
   IF (idx=size(table_column->qual,5))
    SET complete_ind = 1
    SET append_ind = 1
   ELSE
    SET complete_ind = 0
    SET append_ind = 1
   ENDIF
   SET tab_name = table_column->qual[idx].table_name
   SET col_name = table_column->qual[idx].column_name
   SET str_qual = trim(table_column->qual[idx].qualification)
   IF (nbr_sessions=1)
    SET index_colum = ""
   ELSE
    SET index_column = table_column->qual[idx].indexed_column
    IF (index_column="")
     SET nbr_sessions = 1
    ELSE
     SELECT INTO "nl:"
      FROM dba_tab_columns d
      WHERE d.table_name=tab_name
       AND d.column_name=index_column
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET nbr_sessions = 1
      SET index_column = ""
     ENDIF
    ENDIF
   ENDIF
   CALL echo("***********************************************************************")
   CALL echo(concat("Creating file for table ",tab_name," column ",col_name," ..."))
   CALL echo("***********************************************************************")
   EXECUTE dm2_tz_column_update tab_name, col_name, to_val,
   from_val, nbr_sessions, str_qual,
   index_column, "dm2_tz_update", append_ind,
   complete_ind, 1
 ENDFOR
#exit_program
END GO
