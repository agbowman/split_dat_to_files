CREATE PROGRAM afc_rpt_manual_charges:dba
 PROMPT
  "Service Date From (MMDDYYYY): " = "First day of current month",
  "Service Date To (MMDDYYYY): " = "Today"
 DECLARE afc_rpt_manual_charges_version = vc
 SET afc_rpt_manual_charges_version = "98372.FT.002"
 RECORD rpt(
   1 data[*]
     2 order_id = f8
     2 charge_item_id = f8
     2 name = c50
     2 encntr_type = c20
     2 fin = c20
     2 desc = c45
     2 qty = c4
     2 ext_price = f8
     2 cdm_num = c20
     2 cpt_num = c5
     2 dt_tm = dq8
     2 accession = c15
     2 encntr_id = f8
     2 person_id = f8
     2 charge_event_id = f8
     2 status = c13
     2 charge_type_cd = f8
 )
 RECORD reply(
   1 file_name = vc
   1 page_count = i4
   1 charge_qual = i2
   1 status_data
     2 status = c1
     2 subeventstatus[3]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE code_value = f8
 DECLARE cnt = i4
 DECLARE g_status_code_active = f8
 DECLARE g_encounter_alias_fin_num = f8
 DECLARE g_bill_item_type_billcode = f8
 DECLARE charge_credit = f8
 DECLARE charge_debit = f8
 DECLARE charge_nocharge = f8
 IF (validate(getcodevalue,char(128))=char(128))
  DECLARE getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE getcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 DECLARE dpharmcreditcd = f8 WITH noconstant(getcodevalue(13028,"PHARMCR",0))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE rpttitle = vc
 DECLARE rptpage = vc
 DECLARE rptdate = vc
 DECLARE hdrpersonname = vc
 DECLARE rptbegindate = vc
 DECLARE rptenddate = vc
 DECLARE hdrservice = vc
 DECLARE hdrcharge = vc
 DECLARE hdrfin = vc
 DECLARE hdrencountertype = vc
 DECLARE hdrdatetime = vc
 DECLARE hdrdescription = vc
 DECLARE hdraccession = vc
 DECLARE hdrqty = vc
 DECLARE hdrprice = vc
 DECLARE hdrstatus = vc
 DECLARE hdrcdm = vc
 DECLARE hdrcpt = vc
 DECLARE hdrendofreport = vc
 DECLARE dtlencntrtype = vc
 DECLARE dtlchargedesc = vc
 DECLARE dtlstatus = vc
 DECLARE dtlitemextprice = f8
 DECLARE opsind = i2 WITH noconstant(0)
 DECLARE dtsvcfromdate = f8 WITH noconstant(0.0), protect
 DECLARE dtsvctodate = f8 WITH noconstant(0.0), protect
 DECLARE from_date = f8 WITH noconstant(0.0), protect
 DECLARE to_date = f8 WITH noconstant(0.0), protect
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
 ELSE
  SET prtr_name = "MINE"
 ENDIF
 IF (validate(request->from_dt_tm,999) != 999)
  SET opsind = 1
  IF ((request->from_dt_tm > 0))
   SET frm_dt = cnvtdatetime(concat(format(request->from_dt_tm,"dd-mmm-yyyy;;d")," 00:00:00.00"))
   SET from_date = frm_dt
  ELSE
   SET frm_dt = datetimeadd(cnvtdatetime(curdate,0),- (1))
   SET from_date = frm_dt
  ENDIF
 ELSE
  IF (( $1="First day of current month"))
   SET dtsvcfromdate = cnvtdatetime(curdate,0)
  ELSE
   SET dtsvcfromdate = cnvtdatetime(cnvtdate( $1,"MMDDYYYY"),0)
  ENDIF
 ENDIF
 IF (validate(request->to_dt_tm,999) != 999)
  IF ((request->to_dt_tm > 0))
   SET rn_dt = cnvtdatetime(concat(format(request->to_dt_tm,"DD-MMM-YYYY;;d")," 23:59:59.99"))
   SET to_date = rn_dt
  ELSE
   SET rn_dt = datetimeadd(cnvtdatetime(curdate,235959),- (1))
   SET to_date = rn_dt
  ENDIF
 ELSE
  IF (( $2="Today"))
   SET dtsvctodate = cnvtdatetime(curdate,235959)
  ELSE
   SET dtsvctodate = cnvtdatetime(cnvtdate( $2,"MMDDYYYY"),235959)
  ENDIF
 ENDIF
 IF (opsind=1)
  CALL echo(build("From date is: ",format(frm_dt,"DD-MMM-YYYY HH:MM;;Q")))
  CALL echo(build("To date is: ",format(rn_dt,"DD-MMM-YYYY HH:MM;;Q")))
  CALL echo(build("From date is: ",frm_dt))
  CALL echo(build("To date is: ",rn_dt))
 ELSE
  CALL echo(build("dtSvcFromDate: ",format(cnvtdatetime(dtsvcfromdate),"MM/DD/YYYY HH:MM:SS;;Q")))
  CALL echo(build("dtSvcToDate: ",format(cnvtdatetime(dtsvctodate),"MM/DD/YYYY HH:MM:SS;;Q")))
 ENDIF
 SET reply->status_data.status = "F"
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_status_code_active)
 CALL echo(build("the code value is: ",g_status_code_active))
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_encounter_alias_fin_num)
 CALL echo(build("the code value is: ",g_encounter_alias_fin_num))
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_bill_item_type_billcode)
 CALL echo(build("the code value is: ",g_bill_item_type_billcode))
 SET code_set = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,charge_credit)
 CALL echo(build("the code value is: ",charge_credit))
 SET code_set = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,charge_debit)
 CALL echo(build("the code value is: ",charge_debit))
 SET code_set = 13028
 SET cdf_meaning = "NO CHARGE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,charge_nocharge)
 CALL echo(build("the code value is: ",charge_nocharge))
 SET count1 = 0
 IF (opsind=1)
  SELECT INTO "nl:"
   c.charge_item_id, c.charge_event_id, c.bill_item_id,
   c.payor_id, c.item_quantity, c.item_extended_price,
   c.charge_description, c.charge_type_cd, c.activity_dt_tm,
   c.process_flg, c.person_id, c.encntr_id,
   c.updt_dt_tm, c.order_id, c.admit_type_cd,
   c.person_id, c.encntr_id, c.charge_event_id
   FROM charge c
   WHERE c.active_ind=1
    AND c.manual_ind=1
    AND c.process_flg IN (0, 100, 999)
    AND c.service_dt_tm BETWEEN cnvtdatetime(frm_dt) AND cnvtdatetime(rn_dt)
   ORDER BY c.charge_item_id
   DETAIL
    count1 = (count1+ 1), stat = alterlist(rpt->data,count1), rpt->data[count1].order_id = c.order_id,
    rpt->data[count1].charge_item_id = c.charge_item_id, rpt->data[count1].dt_tm = c.service_dt_tm,
    rpt->data[count1].encntr_type = uar_get_code_display(c.admit_type_cd),
    rpt->data[count1].desc = format(c.charge_description,
     "#############################################"), rpt->data[count1].qty = format(c.item_quantity,
     "####"), rpt->data[count1].ext_price = c.item_extended_price
    IF (c.process_flg=0)
     rpt->data[count1].status = "Pending"
    ELSEIF (c.process_flg=999)
     rpt->data[count1].status = "Interfaced"
    ELSEIF (c.process_flg=100)
     rpt->data[count1].status = "Posted"
    ENDIF
    rpt->data[count1].encntr_id = c.encntr_id, rpt->data[count1].person_id = c.person_id, rpt->data[
    count1].charge_event_id = c.charge_event_id,
    rpt->data[count1].charge_type_cd = c.charge_type_cd
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   c.charge_item_id, c.charge_event_id, c.bill_item_id,
   c.payor_id, c.item_quantity, c.item_extended_price,
   c.charge_description, c.charge_type_cd, c.activity_dt_tm,
   c.process_flg, c.person_id, c.encntr_id,
   c.updt_dt_tm, c.order_id, c.admit_type_cd,
   c.person_id, c.encntr_id, c.charge_event_id
   FROM charge c
   WHERE c.active_ind=1
    AND c.manual_ind=1
    AND c.process_flg IN (0, 100, 999)
    AND c.service_dt_tm BETWEEN cnvtdatetime(dtsvcfromdate) AND cnvtdatetime(dtsvctodate)
   ORDER BY c.charge_item_id
   DETAIL
    count1 = (count1+ 1), stat = alterlist(rpt->data,count1), rpt->data[count1].order_id = c.order_id,
    rpt->data[count1].charge_item_id = c.charge_item_id, rpt->data[count1].dt_tm = c.service_dt_tm,
    rpt->data[count1].encntr_type = uar_get_code_display(c.admit_type_cd),
    rpt->data[count1].desc = format(c.charge_description,
     "#############################################"), rpt->data[count1].qty = format(c.item_quantity,
     "####"), rpt->data[count1].ext_price = c.item_extended_price
    IF (c.process_flg=0)
     rpt->data[count1].status = "Pending"
    ELSEIF (c.process_flg=999)
     rpt->data[count1].status = "Interfaced"
    ELSEIF (c.process_flg=100)
     rpt->data[count1].status = "Posted"
    ENDIF
    rpt->data[count1].encntr_id = c.encntr_id, rpt->data[count1].person_id = c.person_id, rpt->data[
    count1].charge_event_id = c.charge_event_id,
    rpt->data[count1].charge_type_cd = c.charge_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SET reply->charge_qual = count1
 CALL echo(build("Charge Qual is: ",reply->charge_qual))
 IF ((reply->charge_qual > 0))
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d1  WITH seq = value(size(rpt->data,5)))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=rpt->data[d1.seq].person_id)
     AND p.active_ind=1)
   DETAIL
    rpt->data[d1.seq].name = substring(1,50,trim(p.name_full_formatted))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(size(rpt->data,5)))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=rpt->data[d1.seq].encntr_id)
     AND ea.encntr_alias_type_cd=g_encounter_alias_fin_num
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    rpt->data[d1.seq].fin = substring(1,20,trim(ea.alias))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event c,
    (dummyt d1  WITH seq = value(size(rpt->data,5)))
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_event_id=rpt->data[d1.seq].charge_event_id))
   DETAIL
    rpt->data[d1.seq].accession = substring(1,15,trim(c.accession))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cm.field1_id, prm = cm.field2_id, trim(cm.field6,3)
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(reply->charge_qual)),
    code_value cv
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=rpt->data[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=g_bill_item_type_billcode
     AND cm.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=cm.field1_id
     AND cv.cdf_meaning="CDM_SCHED"
     AND cv.code_set=14002
     AND cv.active_ind=1)
   DETAIL
    IF (prm=1)
     rpt->data[d1.seq].cdm_num = trim(cm.field6,3)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cm.field1_id, prm = cm.field2_id, trim(cm.field6,3)
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(reply->charge_qual)),
    code_value cv
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=rpt->data[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=g_bill_item_type_billcode
     AND cm.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=cm.field1_id
     AND cv.cdf_meaning="CPT4"
     AND cv.code_set=14002
     AND cv.active_ind=1)
   DETAIL
    IF (prm=1)
     rpt->data[d1.seq].cpt_num = trim(cm.field6,3)
    ENDIF
   WITH nocounter
  ;end select
  SET pagecount = 0
  SET rpttitle = uar_i18ngetmessage(i18nhandle,"k1","RELEASED MANUAL CHARGES REPORT")
  SET rptpage = uar_i18ngetmessage(i18nhandle,"k1","PAGE:")
  SET rptdate = uar_i18ngetmessage(i18nhandle,"k1","REPORT DATE:")
  SET rptbegindate = uar_i18ngetmessage(i18nhandle,"k1","BEGIN DATE:")
  SET rptenddate = uar_i18ngetmessage(i18nhandle,"k1","END DATE:")
  SET hdrpersonname = uar_i18ngetmessage(i18nhandle,"k1","PERSON NAME")
  SET hdrservice = uar_i18ngetmessage(i18nhandle,"k1","SERVICE")
  SET hdrcharge = uar_i18ngetmessage(i18nhandle,"k1","CHARGE")
  SET hdrfin = uar_i18ngetmessage(i18nhandle,"k1","FIN")
  SET hdrencountertype = uar_i18ngetmessage(i18nhandle,"k1","ENCOUNTER TYPE")
  SET hdrdatetime = uar_i18ngetmessage(i18nhandle,"k1","DATE/TIME")
  SET hdrdescription = uar_i18ngetmessage(i18nhandle,"k1","DESCRIPTION")
  SET hdraccession = uar_i18ngetmessage(i18nhandle,"k1","ACCESSION")
  SET hdrqty = uar_i18ngetmessage(i18nhandle,"k1","QTY")
  SET hdrprice = uar_i18ngetmessage(i18nhandle,"k1","PRICE")
  SET hdrstatus = uar_i18ngetmessage(i18nhandle,"k1","STATUS")
  SET hdrcdm = uar_i18ngetmessage(i18nhandle,"k1","CDM")
  SET hdrcpt = uar_i18ngetmessage(i18nhandle,"k1","CPT")
  SET hdrendofreport = uar_i18ngetmessage(i18nhandle,"k1","END OF REPORT")
  SELECT INTO value(prtr_name)
   nm = rpt->data[d1.seq].name, dt = format(rpt->data[d1.seq].dt_tm,"YYYYMMDDHHMM;;Q")
   FROM (dummyt d1  WITH seq = value(count1))
   ORDER BY nm, dt
   HEAD REPORT
    line = fillstring(131,"="), todaysdate = concat(format(cnvtdatetime(curdate,curtime),
      "DD-MMM-YYYY;;D")), row + 1,
    col 50, rpttitle, row + 1
   HEAD PAGE
    col 112, rptpage, col 119,
    curpage, pagecount = curpage, row + 1,
    col 105, rptdate, col 119,
    todaysdate, row + 1
    IF (opsind=1)
     fbegdate = format(from_date,"DD-MMM-YYYY HH:MM;;Q"), fenddate = format(to_date,
      "DD-MMM-YYYY HH:MM;;Q")
    ELSE
     fbegdate = format(cnvtdatetime(dtsvcfromdate),"DD-MMM-YYYY HH:MM;;Q"), fenddate = format(
      cnvtdatetime(dtsvctodate),"DD-MMM-YYYY HH:MM;;Q")
    ENDIF
    col 0, rptbegindate, col 14,
    fbegdate, row + 1, col 0,
    rptenddate, col 14, fenddate,
    row + 1, col 0, line,
    row + 1, col 0, hdrpersonname,
    col 52, hdrfin, col 70,
    hdrencountertype, row + 1, col 1,
    hdrservice, col 17, hdrcharge,
    col 94, hdrcharge, row + 1,
    col 1, hdrdatetime, col 17,
    hdrdescription, col 63, hdraccession,
    col 78, hdrqty, col 85,
    hdrprice, col 94, hdrstatus,
    col 105, hdrcdm, col 126,
    hdrcpt, row + 1, col 0,
    line, row + 1
   HEAD nm
    row + 1, col 0, rpt->data[d1.seq].name"##################################################",
    col 52, rpt->data[d1.seq].fin"####################", dtlencntrtype = uar_i18ngetmessage(
     i18nhandle,"k1",rpt->data[d1.seq].encntr_type),
    col 70, dtlencntrtype"####################", row + 1
   DETAIL
    formattedservicedate = format(rpt->data[d1.seq].dt_tm,"DD-MMM-YY HH:MM;;Q"), col 1,
    formattedservicedate,
    dtlchargedesc = uar_i18ngetmessage(i18nhandle,"k1",rpt->data[d1.seq].desc), col 17, dtlchargedesc
    "#############################################",
    col 63, rpt->data[d1.seq].accession"###############", col 80,
    rpt->data[d1.seq].qty"####"
    IF ((((rpt->data[d1.seq].charge_type_cd=charge_credit)) OR ((rpt->data[d1.seq].charge_type_cd=
    dpharmcreditcd)))
     AND (rpt->data[d1.seq].ext_price != 0))
     dtlitemextprice = (abs(rpt->data[d1.seq].ext_price) * - (1))
    ELSE
     dtlitemextprice = rpt->data[d1.seq].ext_price
    ENDIF
    col 84, dtlitemextprice"######.##", dtlstatus = uar_i18ngetmessage(i18nhandle,"k1",rpt->data[d1
     .seq].status),
    col 94, dtlstatus"#############", col 105,
    rpt->data[d1.seq].cdm_num"####################", col 126, rpt->data[d1.seq].cpt_num"#####",
    row + 1
   FOOT REPORT
    row + 3, col 20, "****************************  ",
    col + 1, hdrendofreport, col + 1,
    " ****************************"
   WITH nocounter, compress, landscape,
    maxrow = 65, maxcol = 132
  ;end select
  SET reply->page_count = pagecount
  CALL echo(build("page_count = ",reply->page_count))
 ELSE
  CALL echo("No charges qualified.")
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET rpt
 FREE SET cdm_codes
 FREE SET cpt_codes
END GO
