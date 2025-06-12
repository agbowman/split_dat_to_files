CREATE PROGRAM bbd_rpt_shipment_audit:dba
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_cerner_health_sys = vc
   1 rpt_title_1 = vc
   1 rpt_time = vc
   1 rpt_title_2 = vc
   1 rpt_as_of_date = vc
   1 ship_nbr = vc
   1 demographics = vc
   1 status = vc
   1 in_progress = vc
   1 shipped = vc
   1 canceled = vc
   1 needed = vc
   1 courier = vc
   1 actual = vc
   1 placed_by = vc
   1 ordered = vc
   1 notes = vc
   1 rpt_from = vc
   1 visual = vc
   1 rpt_return = vc
   1 number = vc
   1 type = vc
   1 weight = vc
   1 prod_number = vc
   1 owner_area = vc
   1 inventory_area = vc
   1 inspection = vc
   1 condition = vc
   1 return_dt_tm = vc
   1 none = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title_1 = uar_i18ngetmessage(i18nhandle,"rpt_title_1",
  "S H I P P I N G   A N D   T R A N S F E R")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_title_2 = uar_i18ngetmessage(i18nhandle,"rpt_title_2","R E P O R T")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->ship_nbr = uar_i18ngetmessage(i18nhandle,"ship_nbr","Ship Nbr")
 SET captions->demographics = uar_i18ngetmessage(i18nhandle,"demographics","Demographics")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status:")
 SET captions->in_progress = uar_i18ngetmessage(i18nhandle,"in_progress","In Progress")
 SET captions->shipped = uar_i18ngetmessage(i18nhandle,"shipped","Shipped")
 SET captions->canceled = uar_i18ngetmessage(i18nhandle,"canceled","Canceled")
 SET captions->needed = uar_i18ngetmessage(i18nhandle,"needed","Needed:")
 SET captions->courier = uar_i18ngetmessage(i18nhandle,"courier","Courier:")
 SET captions->actual = uar_i18ngetmessage(i18nhandle,"actual","Actual:")
 SET captions->placed_by = uar_i18ngetmessage(i18nhandle,"placed_by","Placed By:")
 SET captions->ordered = uar_i18ngetmessage(i18nhandle,"ordered","Ordered:")
 SET captions->notes = uar_i18ngetmessage(i18nhandle,"notes","Notes:")
 SET captions->rpt_from = uar_i18ngetmessage(i18nhandle,"rpt_from","From")
 SET captions->rpt_return = uar_i18ngetmessage(i18nhandle,"rpt_return","Return")
 SET captions->number = uar_i18ngetmessage(i18nhandle,"number","Number")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type")
 SET captions->weight = uar_i18ngetmessage(i18nhandle,"weight","Weight")
 SET captions->prod_number = uar_i18ngetmessage(i18nhandle,"prod_number","Product Number:")
 SET captions->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","Owner Area")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area")
 SET captions->inspection = uar_i18ngetmessage(i18nhandle,"inspection","Inspection")
 SET captions->condition = uar_i18ngetmessage(i18nhandle,"condition","Condition")
 SET captions->return_dt_tm = uar_i18ngetmessage(i18nhandle,"return_dt_tm","Return Date/Time")
 SET captions->visual = uar_i18ngetmessage(i18nhandle,"visual","Visual")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","(none)")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_SHIP")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(178,"_")
 SET line2 = fillstring(167,"-")
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("bbshp_",sfiledate,sfiletime)
 SELECT INTO concat("CER_PRINT:",sfilename,".txt")
  s.shipment_nbr, s.shipment_dt_tm, s.shipment_status_flag,
  s.needed_dt_tm, courier = uar_get_code_display(s.courier_cd), order_placed_by = substring(1,40,s
   .order_placed_by),
  s.order_dt_tm, owner_area = uar_get_code_display(s.owner_area_cd), inventory_area =
  uar_get_code_display(s.inventory_area_cd),
  l.long_text, o.org_name, c.container_nbr,
  container_type = uar_get_code_display(c.container_type_cd), container_condition =
  uar_get_code_display(c.container_condition_cd), c.total_weight,
  unit_of_measure = substring(1,5,uar_get_code_display(c.unit_of_meas_cd)), e.product_id,
  visual_inspection = substring(1,13,uar_get_code_display(e.vis_insp_cd)),
  return_inspection = substring(1,12,uar_get_code_display(e.return_vis_insp_cd)), e.return_dt_tm,
  return_condition = uar_get_code_display(e.return_condition_cd),
  from_owner_area = substring(1,18,uar_get_code_display(e.from_owner_area_cd)), from_inventory_area
   = substring(1,18,uar_get_code_display(e.from_inventory_area_cd)), p.product_nbr
  FROM bb_shipment s,
   (dummyt d1  WITH seq = 1),
   long_text l,
   (dummyt d2  WITH seq = 1),
   organization o,
   (dummyt d3  WITH seq = 1),
   bb_ship_container c,
   (dummyt d4  WITH seq = 1),
   bb_ship_event e,
   product p
  PLAN (s
   WHERE s.shipment_id > 0.0)
   JOIN (l
   WHERE l.long_text_id=s.long_text_id)
   JOIN (d1)
   JOIN (o
   WHERE o.organization_id=s.organization_id)
   JOIN (d2)
   JOIN (c
   WHERE c.shipment_id=s.shipment_id)
   JOIN (d3)
   JOIN (e
   WHERE e.container_id=c.container_id)
   JOIN (d4)
   JOIN (p
   WHERE p.product_id=e.product_id)
  ORDER BY s.shipment_id, c.container_id
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title_1,1,175),
   col 161, captions->rpt_time, col 171,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->rpt_title_2,1,175),
   col 157, captions->rpt_as_of_date, col 169,
   curdate"@DATECONDENSED;;d", row + 1
  HEAD s.shipment_id
   IF (row > 35)
    BREAK
   ENDIF
   row + 3, col 1, captions->ship_nbr,
   col 11, captions->demographics, row + 1,
   col 1, "--------", col 11,
   line2, row + 1, shipment_nbr_display = trim(cnvtstring(s.shipment_nbr),3),
   col 1, shipment_nbr_display
   IF (s.inventory_area_cd > 0.0)
    org_display = trim(inventory_area)
   ELSEIF (s.owner_area_cd > 0.0)
    org_display = trim(owner_area)
   ELSE
    org_display = trim(o.org_name)
   ENDIF
   col 11, org_display, row + 1,
   col 16, captions->status, col 28
   CASE (s.shipment_status_flag)
    OF 0:
     captions->ordered
    OF 1:
     captions->in_progress
    OF 2:
     captions->shipped
    OF 3:
     captions->canceled
   ENDCASE
   col 63, captions->needed, col 73,
   s.needed_dt_tm"@DATETIMECONDENSED;;d", row + 1, col 16,
   captions->courier, courier_display = trim(courier), col 28
   IF (s.courier_cd > 0.0)
    courier_display
   ELSE
    "N/A"
   ENDIF
   col 63, captions->actual, col 73
   IF (s.shipment_dt_tm > null)
    s.shipment_dt_tm"@DATETIMECONDENSED;;d"
   ELSE
    "N/A"
   ENDIF
   row + 1, col 16, captions->placed_by,
   order_placed_by_display = trim(order_placed_by), col 28, order_placed_by_display,
   col 63, captions->ordered, col 73,
   s.order_dt_tm"@DATETIMECONDENSED;;d", row + 1, col 16,
   captions->notes, notes_display = substring(1,140,l.long_text), col 28
   IF (l.long_text_id > 0.0)
    notes_display
   ENDIF
   IF (row > 40)
    BREAK
   ENDIF
   row + 2, col 75, captions->rpt_from,
   col 95, captions->rpt_from, col 115,
   captions->visual, col 130, captions->rpt_return,
   col 164, captions->rpt_return, row + 1,
   col 1, captions->number, col 9,
   captions->type, col 32, captions->condition,
   col 47, captions->weight, col 57,
   captions->prod_number, col 75, captions->owner_area,
   col 95, captions->inventory_area, col 115,
   captions->inspection, col 130, captions->condition,
   col 145, captions->return_dt_tm, col 164,
   captions->visual, row + 1, col 1,
   "------", col 9, "---------------------",
   col 32, "-------------", col 47,
   "--------", col 57, "----------------",
   col 75, "------------------", col 95,
   "------------------", col 115, "-------------",
   col 130, "-------------", col 145,
   "-----------------", col 164, "-------------",
   row + 1
  HEAD c.container_id
   IF (c.container_id > 0.0)
    container_nbr_display = trim(cnvtstring(c.container_nbr),3), col 1, container_nbr_display,
    col 9, container_type, col 32,
    container_condition, col 47
    IF (c.total_weight > 0)
     c.total_weight"###"
    ENDIF
    col 51
    IF (c.total_weight > 0)
     unit_of_measure
    ENDIF
   ELSE
    col 1, captions->none
   ENDIF
  DETAIL
   product_display = trim(p.product_nbr), col 57, product_display,
   col 75, from_owner_area, col 95,
   from_inventory_area, col 115, visual_inspection,
   col 130, return_condition, col 145
   IF (e.return_dt_tm > null)
    e.return_dt_tm"@DATETIMECONDENSED;;d"
   ENDIF
   return_inspection_display = trim(return_inspection,3), col 164, return_inspection_display,
   row + 1
   IF (row > 44)
    BREAK
   ENDIF
  FOOT  c.container_id
   row + 0
  FOOT  s.shipment_id
   row + 0
  FOOT PAGE
   row 45, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 88, captions->rpt_page, col 94,
   curpage"###", col 149, captions->printed,
   col 159, curdate"@DATECONDENSED;;d", col 169,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 48, col 80, captions->end_of_report
  WITH counter, dontcare = p, outerjoin = d1,
   outerjoin = d3, outerjoin = l, outerjoin = o,
   compress, landscape, maxrow = 49,
   maxcol = 180
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->report_name_list,1)
  SET reply->report_name_list[1].report_name = concat("CER_PRINT:",sfilename,".txt")
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
