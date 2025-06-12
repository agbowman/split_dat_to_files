CREATE PROGRAM bhs_dup_bwh_load_temp:dba
 FREE DEFINE rtl3
 DEFINE rtl3 "bhscust:bwh_mrn_missing.csv"
 RECORD temp_rec(
   1 list[*]
     2 corp_mrn = vc
     2 facility_code = vc
     2 facility_id = vc
     2 start_date = vc
     2 inactive_date = vc
 )
 DECLARE l_cnt = i4 WITH protect
 DECLARE l_loop = i4 WITH protect
 DECLARE column1end = i4 WITH protect
 DECLARE column1len = i4 WITH protect
 DECLARE column2end = i4 WITH protect
 DECLARE column2len = i4 WITH protect
 DECLARE column3end = i4 WITH protect
 DECLARE column3len = i4 WITH protect
 DECLARE column4end = i4 WITH protect
 DECLARE column4len = i4 WITH protect
 DECLARE column5end = i4 WITH protect
 DECLARE column5len = i4 WITH protect
 DECLARE temp_err_msg = vc WITH protect
 SELECT INTO "nl:"
  r.line
  FROM rtl3t r
  HEAD REPORT
   l_cnt = 0
  DETAIL
   IF (r.line != "CORP_MRN,FACILITY_CODE,FACILITY_ID,START_DATE,INACTIVE_DATE")
    l_cnt = (l_cnt+ 1)
    IF (mod(l_cnt,10)=1)
     stat = alterlist(temp_rec->list,(l_cnt+ 9))
    ENDIF
    column1end = findstring("|",r.line,1), column1len = (column1end - 1), temp_rec->list[l_cnt].
    corp_mrn = trim(substring(1,column1len,r.line),2),
    column2end = findstring("|",r.line,(column1end+ 1)), column2len = (column2end - (column1end+ 1)),
    temp_rec->list[l_cnt].facility_code = trim(substring((column1end+ 1),column2len,r.line),2),
    column3end = findstring("|",r.line,(column2end+ 1)), column3len = (column3end - (column2end+ 1)),
    temp_rec->list[l_cnt].facility_id = trim(substring((column2end+ 1),column3len,r.line),2),
    column4end = findstring("|",r.line,(column3end+ 1)), column4len = (column4end - (column3end+ 1)),
    temp_rec->list[l_cnt].start_date = trim(substring((column3end+ 1),column4len,r.line),2),
    column5end = textlen(trim(r.line)), column5len = (column5end - column4end), temp_rec->list[l_cnt]
    .inactive_date = trim(substring((column4end+ 1),column5len,r.line),2)
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_rec->list,l_cnt)
  WITH format, separator = " ", maxcol = 135
 ;end select
 FOR (l_loop = 1 TO l_cnt)
  UPDATE  FROM cust_dup_mrn j
   SET j.bwh_mrn = temp_rec->list[l_loop].facility_id
   WHERE j.cn=format(temp_rec->list[l_loop].corp_mrn,"#######;rp0")
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("-----")
   CALL echo(format(temp_rec->list[l_loop].corp_mrn,"#######;rp0"))
   CALL echo("*****")
  ENDIF
 ENDFOR
#exit_program
 CALL echo("******")
 CALL echo(l_cnt)
 CALL echo("------")
END GO
