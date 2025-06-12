CREATE PROGRAM afc_rpt_charge_viewer:dba
 DECLARE afc_rpt_charge_viewer_version = vc
 SET afc_rpt_charge_viewer_version = "121604.FT.016"
 RECORD reply(
   1 report_file_name = vc
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE meaningval = c12
 DECLARE column1 = i4
 DECLARE column2 = i4
 DECLARE column3 = i4
 DECLARE cptcount = i4
 DECLARE cdmcount = i4
 DECLARE icd9count = i4
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
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE dmrncd = f8 WITH noconstant(getcodevalue(319,"MRN",0))
 DECLARE rpttitle = vc
 DECLARE rptpage = vc
 DECLARE rptdate = vc
 DECLARE hdrservice = vc
 DECLARE hdrdate = vc
 DECLARE hdrchargedescription = vc
 DECLARE hdrcdm = vc
 DECLARE hdrcpt = vc
 DECLARE hdrqty = vc
 DECLARE hdrprice = vc
 DECLARE hdrstatus = vc
 DECLARE hdrfin = vc
 DECLARE hdrmrn = vc
 DECLARE hdrorderingphys = vc
 DECLARE hdrtotalcharges = vc
 DECLARE hdrtotalamount = vc
 DECLARE dtlchargedescription = vc
 DECLARE dtlchargestatus = vc
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE code_set = i4
 DECLARE credit = f8
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,credit)
 DECLARE debit = f8
 SET code_set = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,debit)
 DECLARE nocharge = f8
 SET code_set = 13028
 SET cdf_meaning = "NO CHARGE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,nocharge)
 DECLARE 13019_bill_code = f8
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,13019_bill_code)
 SET totalcharges = 0
 SET totalamount = 0.0
 SET ncreditflg = 0
 SET nextcredit = 0.0
 SET column = 0
 SET myvariable = 0
 EXECUTE cpm_create_file_name "afc", "dat"
 SET reply->report_file_name = cpm_cfn_info->file_name_path
 DECLARE fin = c200 WITH noconstant("")
 SET maxbillcodecount = 1
 SET rpttitle = uar_i18ngetmessage(i18nhandle,"k1","CHARGE VIEWER REPORT")
 SET rptpage = uar_i18ngetmessage(i18nhandle,"k1","PAGE:")
 SET rptdate = uar_i18ngetmessage(i18nhandle,"k1","REPORT DATE:")
 SET hdrservice = uar_i18ngetmessage(i18nhandle,"k1","SERVICE")
 SET hdrdate = uar_i18ngetmessage(i18nhandle,"k1","DATE")
 SET hdrchargedescription = uar_i18ngetmessage(i18nhandle,"k1","CHARGE DESCRIPTION")
 SET hdrcdm = uar_i18ngetmessage(i18nhandle,"k1","CDM")
 SET hdrcpt = uar_i18ngetmessage(i18nhandle,"k1","CPT")
 SET hdrqty = uar_i18ngetmessage(i18nhandle,"k1","QTY")
 SET hdrprice = uar_i18ngetmessage(i18nhandle,"k1","PRICE")
 SET hdrstatus = uar_i18ngetmessage(i18nhandle,"k1","STATUS")
 SET hdrfin = uar_i18ngetmessage(i18nhandle,"k1","FIN:")
 SET hdrmrn = uar_i18ngetmessage(i18nhandle,"k1","MRN:")
 SET hdrorderingphys = uar_i18ngetmessage(i18nhandle,"k1","ORDERING PHYSICIAN:")
 SET hdrtotalcharges = uar_i18ngetmessage(i18nhandle,"k1","TOTAL CHARGES:")
 SET hdrtotalamount = uar_i18ngetmessage(i18nhandle,"k1","TOTAL AMOUNT:")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   (dummyt d1  WITH seq = value(size(request->charges,5)))
  PLAN (d1)
   JOIN (ea
   WHERE (ea.encntr_id=request->charges[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd=dmrncd
    AND ea.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
  DETAIL
   request->charges[d1.seq].mrn_nbr = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO cpm_cfn_info->file_name_path
  service_date_time = format(request->charges[d1.seq].service_dt_tm,"YYYYMMDD;;D"), description =
  request->charges[d1.seq].charge_description, fin = trim(request->charges[d1.seq].fin_nbr)
  FROM (dummyt d1  WITH seq = size(request->charges,5)),
   dummyt d2,
   dummyt d3
  PLAN (d1)
   JOIN (d3)
   JOIN (d2
   WHERE (d2.seq <= request->charges[d1.seq].bill_code_qual))
  ORDER BY fin, service_date_time
  HEAD REPORT
   todaysdate = concat(format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D")), dashes = fillstring(
    125,"="), underline = fillstring(125,"-"),
   col 50, rpttitle, row + 1
  HEAD PAGE
   col 106, rptpage, col 113,
   curpage, row + 1, col 99,
   rptdate, col 113, todaysdate,
   row + 1, col 0, dashes,
   row + 1, col 0, hdrservice,
   row + 1, col 0, hdrdate,
   row + 1, col 5, hdrchargedescription,
   col 55, hdrcdm, col 77,
   hdrcpt, col 88, hdrqty,
   col 95, hdrprice, col 112,
   hdrstatus, row + 1, col 0,
   dashes, row + 1
  HEAD fin
   col 0, hdrmrn, col 5,
   request->charges[d1.seq].mrn_nbr, row + 1, col 0,
   hdrfin, col 5, request->charges[d1.seq].fin_nbr,
   row + 1, col 0, request->charges[d1.seq].person_name,
   row + 2
  HEAD service_date_time
   formattedservicedate = format(request->charges[d1.seq].service_dt_tm,"DD-MMM-YY;;D"), col 0,
   formattedservicedate,
   row + 2
  DETAIL
   totalcharges = (totalcharges+ 1)
   IF ((request->charges[d1.seq].master_ind=1))
    tab = 0
   ELSE
    tab = 4
   ENDIF
   dtlchargedescription = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(request->charges[d1.seq].
      charge_description))), call reportmove('COL',(5+ tab),0), dtlchargedescription
   "#############################################",
   col 87, request->charges[d1.seq].item_quantity"####"
   IF ((request->charges[d1.seq].charge_type_cd=credit)
    AND (request->charges[d1.seq].item_extended_price != 0))
    nextcredit = (abs(request->charges[d1.seq].item_extended_price) * - (1)), col 93, nextcredit
    "#######.##"
   ELSEIF ((request->charges[d1.seq].charge_type_cd=nocharge))
    col 93, request->charges[d1.seq].item_extended_price"#######.## NC"
   ELSE
    col 93, request->charges[d1.seq].item_extended_price"#######.##"
   ENDIF
   IF ((request->charges[d1.seq].charge_type_cd=credit))
    ncreditflg = 1
   ELSE
    ncreditflg = 0
   ENDIF
   IF ((request->charges[d1.seq].process_flg=999))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Interfaced"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=0))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Pending"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=1))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Suspended"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=2))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Review"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=3))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","On Hold"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=4))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Manual"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=5))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Skipped"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=6))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Combined"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=7))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Absorbed"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=8))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","ABN Required"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=10))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Offset"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=11))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Adjusted"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=12))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Grouped"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=100))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Posted"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=177))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Bndld-ProFit"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=777))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Bundled"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=977))
    IF ((request->charges[d1.seq].charge_type_cd IN (credit, debit)))
     IF (ncreditflg=1)
      totalamount = (totalamount+ (abs(request->charges[d1.seq].item_extended_price) * - (1)))
     ELSE
      totalamount = (totalamount+ request->charges[d1.seq].item_extended_price)
     ENDIF
    ENDIF
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Bndld-Intrfcd"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=996))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","OMFStatsOnly"), col 112, dtlchargestatus
    "#############"
   ELSEIF ((request->charges[d1.seq].process_flg=997))
    dtlchargestatus = uar_i18ngetmessage(i18nhandle,"k1","Stats Only"), col 112, dtlchargestatus
    "#############"
   ENDIF
   CALL printbillcodes(d1.seq)
   IF (column1 > 0
    AND cptcount > 0)
    col column1, request->charges[d1.seq].bill_codes[cptcount].field6
   ENDIF
   IF (column2 > 0
    AND cdmcount > 0)
    col column2, request->charges[d1.seq].bill_codes[cdmcount].field6
   ENDIF
   column1 = 0, column2 = 0, cptcount = 0,
   cdmcount = 0, row + 1, call reportmove('COL',(5+ tab),0),
   hdrorderingphys, col + 2, request->charges[d1.seq].physician_name
   "##################################################"
   IF ((request->charges[d1.seq].master_ind=1))
    row + 2
   ELSE
    row + 3
   ENDIF
  FOOT REPORT
   row + 3, col 66, hdrtotalcharges,
   col + 2, totalcharges"####################", row + 1,
   col 66, hdrtotalamount, col + 3,
   totalamount"#################.##"
  WITH nocounter, compress, outerjoin = d3
 ;end select
 SUBROUTINE printbillcodes(curcharge)
   FOR (i = 1 TO request->charges[curcharge].bill_code_qual)
     IF ((request->charges[curcharge].bill_codes[i].charge_mod_type_cd=13019_bill_code))
      SET meaningval = uar_get_code_meaning(request->charges[curcharge].bill_codes[i].field1_id)
      IF (meaningval="CPT4"
       AND (request->charges[curcharge].bill_codes[i].field2_id=1))
       SET column1 = 77
       SET cptcount = i
      ELSEIF (meaningval="CDM_SCHED"
       AND (request->charges[curcharge].bill_codes[i].field2_id=1))
       SET column2 = 55
       SET cdmcount = i
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
END GO
