CREATE PROGRAM afc_rpt_susp_analysis:dba
 PAINT
 DECLARE afc_rpt_susp_analysis_version = vc
 SET afc_rpt_susp_analysis_version = "98372.FT.010"
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET message = nowindow
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
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
 RECORD susp(
   1 charge[*]
     2 charge_desc = c200
     2 process_flg = i4
     2 charge_event_id = f8
     2 ext_i_reference_id = f8
     2 ext_i_reference_cont_disp = c50
     2 field1_disp = c50
     2 field6 = c200
     2 item_display = c200
 )
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE suspense = f8
 DECLARE addonbill = f8
 DECLARE addonprice = f8
 DECLARE manual = f8
 DECLARE nobillitem = f8
 DECLARE nocdm = f8
 DECLARE nocpt4 = f8
 DECLARE noicd9proc = f8
 DECLARE noparentbi = f8
 DECLARE nopayorsched = f8
 DECLARE noppayorsche = f8
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE rptheader = vc
 DECLARE rptpage = vc
 DECLARE rptdate = vc
 DECLARE hdritemdescription = vc
 DECLARE hdritemcodevalue = vc
 DECLARE hdritemquantity = vc
 DECLARE hdrsuspreason = vc
 DECLARE dtlsuspreason = vc
 DECLARE dtlitemdescription = vc
 DECLARE ftrendofreport = vc
 DECLARE ftrsuspcount = vc
 DECLARE ftrtotalsuspcharges = vc
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET codeset = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,suspense)
 CALL echo(build("the suspense code value is: ",suspense))
 SET codeset = 13030
 SET cdf_meaning = "ADDONBILL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,addonbill)
 CALL echo(build("the addonbill code value is: ",addonbill))
 SET codeset = 13030
 SET cdf_meaning = "ADDONPRICE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,addonprice)
 CALL echo(build("the addonprice code value is: ",addonprice))
 SET codeset = 13030
 SET cdf_meaning = "MANUAL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,manual)
 CALL echo(build("the manual code value is: ",manual))
 SET codeset = 13030
 SET cdf_meaning = "NOBILLITEM"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,nobillitem)
 CALL echo(build("the nobillitem code value is: ",nobillitem))
 SET codeset = 13030
 SET cdf_meaning = "NOCDM"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,nocdm)
 CALL echo(build("the nocdm code value is: ",nocdm))
 SET codeset = 13030
 SET cdf_meaning = "NOCPT4"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,nocpt4)
 CALL echo(build("the nocpt4 code value is: ",nocpt4))
 SET codeset = 13030
 SET cdf_meaning = "NOICD9PROC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,noicd9proc)
 CALL echo(build("the noicd9proc code value is: ",noicd9proc))
 SET codeset = 13030
 SET cdf_meaning = "NOPARENTBI"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,noparentbi)
 CALL echo(build("the noparentbi code value is: ",noparentbi))
 SET codeset = 13030
 SET cdf_meaning = "NOPAYORSCHED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,nopayorsched)
 CALL echo(build("the nopayorsched code value is: ",nopayorsched))
 SET codeset = 13030
 SET cdf_meaning = "NOPPAYORSCHE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,noppayorsche)
 CALL echo(build("the noppayorsche code value is: ",noppayorsche))
 SET count = 0
 SET structsize = 1000
 SET stat = alterlist(susp->charge,structsize)
 SELECT INTO "nl:"
  c.charge_description, c.process_flg, ce.charge_event_id,
  ce.ext_i_reference_id, ce.ext_i_reference_cont_cd, cm.charge_mod_type_cd,
  cm.field1_id, cv.display, cv2.display,
  cv3.display
  FROM charge c,
   charge_event ce,
   charge_mod cm
  PLAN (c
   WHERE c.process_flg IN (1, 2, 3, 4)
    AND c.active_ind=1)
   JOIN (cm
   WHERE c.charge_item_id=cm.charge_item_id
    AND cm.charge_mod_type_cd=suspense
    AND cm.active_ind=1)
   JOIN (ce
   WHERE ce.charge_event_id=outerjoin(c.charge_event_id))
  DETAIL
   count = (count+ 1)
   IF (count=structsize)
    structsize = (structsize+ 1000), stat = alterlist(susp->charge,structsize)
   ENDIF
   stat = alterlist(susp->charge,count), susp->charge[count].charge_desc = c.charge_description, susp
   ->charge[count].process_flg = c.process_flg,
   susp->charge[count].charge_event_id = c.charge_event_id, susp->charge[count].ext_i_reference_id =
   ce.ext_i_reference_id, susp->charge[count].ext_i_reference_cont_disp = uar_get_code_display(ce
    .ext_i_reference_cont_cd),
   susp->charge[count].field1_disp = uar_get_code_display(cm.field1_id), susp->charge[count].
   item_display = uar_get_code_display(ce.ext_i_reference_id)
  WITH nocounter
 ;end select
 SET stat = alterlist(susp->charge,count)
 CALL echo(build("Number of charges  ",size(susp->charge,5)))
 IF (curqual > 0)
  SET total_cnt = 0
  SET reas_cnt = 0
  SET item_reas_cnt = 0
  SET count1 = 1
  SET dt = format(curdate,"dd-mmm-yyyy;;d")
  SET tm = format(curtime,"hh:mm;;s")
  SET rptheader = uar_i18ngetmessage(i18nhandle,"k1","SUSPENDED CHARGE REASON ANALYSIS")
  SET hdritemdescription = uar_i18ngetmessage(i18nhandle,"k1","ITEM DESCRIPTION")
  SET hdritemcodevalue = uar_i18ngetmessage(i18nhandle,"k1","ITEM CODE VALUE")
  SET hdritemquantity = uar_i18ngetmessage(i18nhandle,"k1","QUANTITY")
  SET rptpage = uar_i18ngetmessage(i18nhandle,"k1","PAGE:")
  SET rptdate = uar_i18ngetmessage(i18nhandle,"k1","REPORT DATE:")
  SET hdrsuspreason = uar_i18ngetmessage(i18nhandle,"k1","REASON:")
  SET ftrsuspcount = uar_i18ngetmessage(i18nhandle,"k1","COUNT FOR: ")
  SET ftrtotalsuspcharges = uar_i18ngetmessage(i18nhandle,"k1","TOTAL NUMBER OF SUSPENDED CHARGES:")
  SET ftrendofreport = uar_i18ngetmessage(i18nhandle,"k1","END OF REPORT")
  SELECT INTO value(prtr_name)
   reason = susp->charge[d.seq].field1_disp, item_desc = susp->charge[d.seq].item_display, code_value
    = susp->charge[d.seq].ext_i_reference_id
   FROM (dummyt d  WITH seq = value(count))
   ORDER BY reason, item_desc
   HEAD REPORT
    row + 1, col 40, rptheader,
    row + 1
   HEAD PAGE
    col 93, rptpage, col 99,
    curpage, row + 1, col 86,
    rptdate, col 99, dt,
    row + 1, col 00, "========================================",
    col 40, "======================================================================", row + 1,
    col 7, hdritemdescription, col 75,
    hdritemcodevalue, col 98, hdritemquantity,
    row + 1, col 00, "========================================",
    col 40, "======================================================================", row + 2
   HEAD reason
    reas_cnt = 0, col 00, hdrsuspreason,
    dtlsuspreason = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(reason))), col 09, dtlsuspreason,
    row + 2
   HEAD item_desc
    item_reas_cnt = 0
   DETAIL
    reas_cnt = (reas_cnt+ 1), item_reas_cnt = (item_reas_cnt+ 1), total_cnt = (total_cnt+ 1),
    count1 = (count1+ 1)
   FOOT  item_desc
    dtlitemdescription = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(item_desc))), col 05,
    dtlitemdescription"#################################################",
    col 60, code_value"##############################", col 95,
    item_reas_cnt"##########", row + 1
   FOOT  reason
    row + 1, col 25, ftrsuspcount,
    col 37, dtlsuspreason"##################################################", col 95,
    reas_cnt"##########", row + 2
   FOOT REPORT
    col 25, ftrtotalsuspcharges, col 90,
    total_cnt"###############", row + 3, col 35,
    "*************  ", ftrendofreport, col + 1,
    " ***************"
   WITH nocounter, compress, nolandscape,
    maxrow = 60, maxcol = 132
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo("No charges qualified.")
 ENDIF
 FREE SET susp
END GO
