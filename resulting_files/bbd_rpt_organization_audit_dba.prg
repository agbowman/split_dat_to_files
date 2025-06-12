CREATE PROGRAM bbd_rpt_organization_audit:dba
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
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 mobile_references = vc
   1 all_donor_group = vc
   1 addresses = vc
   1 quota_info = vc
   1 period = vc
   1 actuals = vc
   1 starting = vc
   1 ending = vc
   1 quota = vc
   1 in_house = vc
   1 mobile = vc
   1 total = vc
   1 status = vc
   1 mobile_prefs = vc
   1 month = vc
   1 week = vc
   1 sunday = vc
   1 monday = vc
   1 tuesday = vc
   1 wednesday = vc
   1 thursday = vc
   1 friday = vc
   1 saturday = vc
   1 hours = vc
   1 type = vc
   1 contact_name = vc
   1 phone = vc
   1 active = vc
   1 inactive = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "O R G A N I Z A T I O N   A U D I T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->mobile_references = uar_i18ngetmessage(i18nhandle,"mobile_references",
  "Mobile References for the Month of")
 SET captions->all_donor_group = uar_i18ngetmessage(i18nhandle,"all_donor_group",
  "A L L   D O N O R   G R O U P")
 SET captions->addresses = uar_i18ngetmessage(i18nhandle,"addresses","Addresses")
 SET captions->quota_info = uar_i18ngetmessage(i18nhandle,"quota_info","Quota Information")
 SET captions->period = uar_i18ngetmessage(i18nhandle,"period","Period")
 SET captions->actuals = uar_i18ngetmessage(i18nhandle,"actuals","Actuals")
 SET captions->starting = uar_i18ngetmessage(i18nhandle,"starting","Starting")
 SET captions->ending = uar_i18ngetmessage(i18nhandle,"ending","Ending")
 SET captions->quota = uar_i18ngetmessage(i18nhandle,"quota","Quota")
 SET captions->in_house = uar_i18ngetmessage(i18nhandle,"in_house","In House")
 SET captions->mobile = uar_i18ngetmessage(i18nhandle,"mobile","Mobile")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Total")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET captions->mobile_prefs = uar_i18ngetmessage(i18nhandle,"mobile_prefs","Mobile Preferences")
 SET captions->month = uar_i18ngetmessage(i18nhandle,"month","Month")
 SET captions->week = uar_i18ngetmessage(i18nhandle,"week","Week")
 SET captions->sunday = uar_i18ngetmessage(i18nhandle,"sunday","Sunday")
 SET captions->monday = uar_i18ngetmessage(i18nhandle,"monday","Monday")
 SET captions->tuesday = uar_i18ngetmessage(i18nhandle,"tuesday","Tuesday")
 SET captions->wednesday = uar_i18ngetmessage(i18nhandle,"wednesday","Wednesday")
 SET captions->thursday = uar_i18ngetmessage(i18nhandle,"thursday","Thursday")
 SET captions->friday = uar_i18ngetmessage(i18nhandle,"friday","Friday")
 SET captions->saturday = uar_i18ngetmessage(i18nhandle,"saturday","Saturday")
 SET captions->hours = uar_i18ngetmessage(i18nhandle,"hours","Hours")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type:")
 SET captions->contact_name = uar_i18ngetmessage(i18nhandle,"contact_name","Contact Name:")
 SET captions->phone = uar_i18ngetmessage(i18nhandle,"phone","Phone:")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","Inactive")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_ORGANIZATION_AUDIT")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 RECORD struct(
   1 qual[*]
     2 org_id = f8
 )
 SET line = fillstring(125,"_")
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("bbdorg_",sfiledate,sfiletime)
 SET reply->status_data.status = "F"
 SET struct_counter = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET month = fillstring(12," ")
 SET month_cd = 0.0
 SET actual = 0
 SET org_id = 0.0
 IF ((request->all_organization_ind=1))
  SET donorgroup_cd = 0.0
  SET code_set = 278
  SET cdf_meaning = "DONORGROUP"
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorgroup_cd)
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o,
    org_type_reltn ot
   PLAN (ot
    WHERE ot.org_type_cd=donorgroup_cd
     AND ot.active_ind=1)
    JOIN (o
    WHERE o.organization_id=ot.organization_id
     AND o.active_ind=1)
   DETAIL
    struct_counter = (struct_counter+ 1), stat = alterlist(struct->qual,struct_counter), struct->
    qual[struct_counter].org_id = o.organization_id
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET nbr_struct = size(struct->qual,5)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF ((request->organization_id > 0))
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o
   WHERE (o.organization_id=request->organization_id)
    AND o.active_ind=1
   DETAIL
    struct_counter = (struct_counter+ 1), stat = alterlist(struct->qual,struct_counter), struct->
    qual[struct_counter].org_id = o.organization_id
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
   SET nbr_struct = 1
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET meaning = cnvtstring(request->mobile_pref_month)
  SET month_cd = 0.0
  SET stat = uar_get_meaning_by_codeset(17109,meaning,1,month_cd)
  SET month = uar_get_code_display(month_cd)
  SELECT INTO "nl:"
   m.organization_id
   FROM bbd_mobile_pref m
   PLAN (m
    WHERE m.month_cd=month_cd
     AND m.active_ind=1)
   DETAIL
    struct_counter = (struct_counter+ 1), stat = alterlist(struct->qual,struct_counter), struct->
    qual[struct_counter].org_id = m.organization_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET nbr_struct = size(struct->qual,5)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SELECT INTO concat("CER_TEMP:",sfilename,".txt")
  source = decode(a.seq,1,p.seq,2,q.seq,
   3,m.seq,4,0), o.org_name, a.street_addr,
  a.street_addr2, a.street_addr3, a.street_addr4,
  a.city, a.state, a.zipcode,
  a.country, p.contact, p.phone_num,
  p.extension, q.beg_effective_dt_tm, q.end_effective_dt_tm,
  q.quota, q.inhouse, q.mobile,
  q.active_ind, m.month_cd, m.week,
  m.sunday_ind, m.monday_ind, m.tuesday_ind,
  m.wednesday_ind, m.thursday_ind, m.friday_ind,
  m.saturday_ind, m.length_in_hours
  FROM organization o,
   address a,
   code_value c1,
   code_value c2,
   phone p,
   bbd_org_quota q,
   bbd_mobile_pref m,
   (dummyt d1  WITH seq = value(nbr_struct)),
   (dummyt d_address  WITH seq = 1),
   (dummyt d_phone  WITH seq = 1),
   (dummyt d_quota  WITH seq = 1),
   (dummyt d_mobile  WITH seq = 1)
  PLAN (d1)
   JOIN (o
   WHERE (o.organization_id=struct->qual[d1.seq].org_id)
    AND o.active_ind=1)
   JOIN (((d_address
   WHERE d_address.seq=1)
   JOIN (a
   WHERE a.parent_entity_id=o.organization_id
    AND a.active_ind=1)
   JOIN (c1
   WHERE c1.code_value=a.address_type_cd
    AND c1.code_set=212
    AND c1.active_ind=1)
   ) ORJOIN ((((d_phone
   WHERE d_phone.seq=1)
   JOIN (p
   WHERE p.parent_entity_id=o.organization_id
    AND p.active_ind=1)
   ) ORJOIN ((((d_quota
   WHERE d_quota.seq=1)
   JOIN (q
   WHERE q.organization_id=o.organization_id)
   ) ORJOIN ((d_mobile
   WHERE d_mobile.seq=1)
   JOIN (m
   WHERE m.organization_id=o.organization_id
    AND m.active_ind=1)
   JOIN (c2
   WHERE ((c2.code_value=m.month_cd
    AND (request->mobile_pref_month=0)) OR (c2.code_value=month_cd
    AND (request->mobile_pref_month > 0)
    AND c2.active_ind=1)) )
   )) )) ))
  ORDER BY o.org_name, source, o.organization_id
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1, col 104,
   captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d"
   IF ((request->mobile_pref_month > 0))
    CALL center(captions->mobile_references,1,120), col 78, month"#############",
    row + 1
   ELSEIF ((request->all_organization_ind > 0))
    CALL center(captions->all_donor_group,1,125), row + 1
   ELSEIF ((request->organization_id > 0))
    row + 1
   ENDIF
  HEAD o.organization_id
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
   col 3, o.org_name, row + 1
  HEAD source
   IF (row > 56)
    BREAK
   ENDIF
   IF (source=1)
    IF (a.address_id > 0)
     col 10, captions->addresses, row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ELSEIF (source=2)
    IF (p.phone_id > 0)
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ELSEIF (source=3)
    IF (q.org_quota_id > 0)
     IF (row > 52)
      BREAK
     ENDIF
     col 10, captions->quota_info, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 22, captions->period, col 75,
     captions->actuals, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 14, captions->starting, col 29,
     captions->ending, col 45, captions->quota,
     col 61, captions->in_house, col 77,
     captions->mobile, col 92, captions->total,
     col 110, captions->status, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 14, "--------", col 28,
     "--------", col 43, "----------",
     col 60, "----------", col 75,
     "----------", col 90, "----------",
     col 108, "----------", row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ELSEIF (source=4)
    IF (m.mobile_pref_id > 0)
     IF (row > 53)
      BREAK
     ENDIF
     col 10, captions->mobile_prefs, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 14, captions->month, col 32,
     captions->week, col 39, captions->sunday,
     col 48, captions->monday, col 58,
     captions->tuesday, col 68, captions->wednesday,
     col 80, captions->thursday, col 91,
     captions->friday, col 99, captions->saturday,
     col 110, captions->hours, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 14, "---------------", col 32,
     "----", col 39, "------",
     col 48, "------", col 58,
     "-------", col 68, "---------",
     col 80, "--------", col 91,
     "------", col 99, "--------",
     col 110, "-----", row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (source=1)
    IF (a.address_id > 0)
     IF (row > 56)
      BREAK
     ENDIF
     col 14, captions->type, col 20.,
     c1.cdf_meaning"###################"
     IF (a.street_addr != null)
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 18, a.street_addr"##########################################"
     ELSEIF (a.street_addr2 != null)
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 18, a.street_addr2"##########################################"
     ELSEIF (a.street_addr3 != null)
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 18, a.street_addr3"######################################"
     ELSEIF (a.street_addr4 != null)
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 18, a.street_addr4"####################################"
     ENDIF
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 18, a.city"#########################", col 45,
     a.state"##", col 47, ",",
     col 50, a.zipcode, row + 1
     IF (row > 56)
      BREAK
     ENDIF
     IF (a.country != null)
      col 18, a.country, row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (source=2)
    IF (p.phone_id > 0)
     IF (p.contact != null)
      col 14, captions->contact_name, col 29,
      p.contact"##############################################", row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
     IF (p.phone_num != null
      AND p.phone_num != "(___) ___-____")
      col 14, captions->phone, col 21,
      p.phone_num"##############", col 36, p.extension"##############",
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (source=3)
    IF (q.org_quota_id > 0)
     actual = (q.inhouse+ q.mobile), col 14, q.beg_effective_dt_tm"@DATETIMECONDENSED;;d",
     col 28, q.end_effective_dt_tm"@DATETIMECONDENSED;;d", col 42,
     q.quota, col 59, q.inhouse,
     col 74, q.mobile, col 89,
     actual
     IF (q.active_ind=1)
      col 110, captions->active
     ELSE
      col 110, captions->inactive
     ENDIF
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ELSEIF (source=4)
    IF (m.mobile_pref_id > 0)
     col 14, c2.display"##########", col 32,
     m.week"####"
     IF (m.sunday_ind=1)
      col 42, "X"
     ENDIF
     IF (m.monday_ind=1)
      col 50, "X"
     ENDIF
     IF (m.tuesday_ind=1)
      col 61, "X"
     ENDIF
     IF (m.wednesday_ind=1)
      col 72, "X"
     ENDIF
     IF (m.thursday_ind=1)
      col 84, "X"
     ENDIF
     IF (m.friday_ind=1)
      col 94, "X"
     ENDIF
     IF (m.saturday_ind=1)
      col 104, "X"
     ENDIF
     col 110, m.length_in_hours"####", row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nullreport, counter, compress,
   nolandscape, maxrow = 61, outerjoin(d_address),
   outerjoin(d_phone), outerjoin(d_quota), outerjoin(d_mobile)
 ;end select
 SET reply->status_data.status = "S"
 SET stat = alterlist(reply->report_name_list,1)
 SET reply->report_name_list[1].report_name = concat("CER_TEMP:",sfilename,".txt")
END GO
