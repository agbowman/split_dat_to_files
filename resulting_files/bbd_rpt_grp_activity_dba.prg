CREATE PROGRAM bbd_rpt_grp_activity:dba
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
   1 addresses = vc
   1 begin_dt = vc
   1 end_dt = vc
   1 last_donated = vc
   1 donation = vc
   1 eligibility = vc
   1 donor_info = vc
   1 as_member = vc
   1 outcome = vc
   1 last_donation = vc
   1 level = vc
   1 status = vc
   1 type = vc
   1 contact_name = vc
   1 phone = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "O R G A N I Z A T I O N   A C T I V I T Y   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->addresses = uar_i18ngetmessage(i18nhandle,"addresses","Addresses")
 SET captions->begin_dt = uar_i18ngetmessage(i18nhandle,"begin_dt","Beginning Date:")
 SET captions->end_dt = uar_i18ngetmessage(i18nhandle,"end_dt","Ending Date:")
 SET captions->last_donated = uar_i18ngetmessage(i18nhandle,"last_donated","Last Donated")
 SET captions->donation = uar_i18ngetmessage(i18nhandle,"donation","Donation")
 SET captions->eligibility = uar_i18ngetmessage(i18nhandle,"eligibility","Eligibility")
 SET captions->donor_info = uar_i18ngetmessage(i18nhandle,"donor_info","Donor Information")
 SET captions->as_member = uar_i18ngetmessage(i18nhandle,"as_member","As Member")
 SET captions->outcome = uar_i18ngetmessage(i18nhandle,"outcome","Outcome")
 SET captions->last_donation = uar_i18ngetmessage(i18nhandle,"last_donation","Last Donation")
 SET captions->level = uar_i18ngetmessage(i18nhandle,"level","Level")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type:")
 SET captions->contact_name = uar_i18ngetmessage(i18nhandle,"contact_name","Contact Name:")
 SET captions->phone = uar_i18ngetmessage(i18nhandle,"phone","Phone:")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_GROUP_ACTIVITY")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SET reply->status_data.status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 1
 SET contact_type_cd = 0.0
 SET donor_org_cd = 0.0
 SET home_address_cd = 0.0
 SET street_string = fillstring(40," ")
 SET city_string = fillstring(80," ")
 SET address_string = fillstring(50," ")
 SET don_grand_total = 0.00
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("bbdact",sfiledate,sfiletime)
 SET code_set = 338
 SET cdf_meaning = "DONOR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_org_cd)
 SET code_set = 14220
 SET cdf_meaning = "DONATE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,contact_type_cd)
 SET code_set = 212
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,home_address_cd)
 SELECT INTO concat("CER_TEMP:",sfilename,".txt")
  source = decode(a.seq,1,p.seq,2,po.seq,
   3,0), a.street_addr, a.street_addr2,
  a.street_addr3, a.street_addr4, a.city,
  a.state, a.zipcode, a.country,
  p.contact, p.phone_num, p.extension,
  org_name = o.org_name, donor_name = substring(1,60,pr.name_full_formatted), dc.contact_dt_tm
  "@DATECONDENSED;;d",
  outcome_type = uar_get_code_meaning(dr.outcome_cd), dr.outcome_cd, pr.name_full_formatted,
  pd.donation_level, pd.donation_level_trans, pd.last_donation_dt_tm"@DATECONDENSED;;d",
  pd.eligibility_type_cd, eligibility_type = uar_get_code_meaning(pd.eligibility_type_cd)
  FROM organization o,
   address a,
   address a1,
   code_value c1,
   phone p,
   person_org_reltn po,
   bbd_donor_contact dc,
   person pr,
   bbd_donation_results dr,
   person_donor pd,
   (dummyt d_address  WITH seq = 1),
   (dummyt d_phone  WITH seq = 1),
   (dummyt d_po  WITH seq = 1),
   (dummyt d_person_adr  WITH seq = 1)
  PLAN (o
   WHERE (o.organization_id=request->organization_id))
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
   ) ORJOIN ((d_po
   WHERE d_po.seq=1)
   JOIN (po
   WHERE po.organization_id=o.organization_id
    AND po.person_org_reltn_cd=donor_org_cd
    AND po.active_ind=1)
   JOIN (dc
   WHERE dc.organization_id=po.organization_id
    AND dc.person_id=po.person_id
    AND dc.contact_type_cd=contact_type_cd
    AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND dc.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=dc.person_id
    AND pr.active_ind=1)
   JOIN (dr
   WHERE dr.person_id=pr.person_id
    AND dr.active_ind=1)
   JOIN (pd
   WHERE pd.person_id=dr.person_id
    AND pd.active_ind=1)
   JOIN (d_person_adr
   WHERE d_person_adr.seq=1)
   JOIN (a1
   WHERE a1.parent_entity_id=dr.person_id
    AND a1.parent_entity_name="PERSON"
    AND a1.address_type_cd=home_address_cd
    AND a1.active_ind=1)
   )) ))
  ORDER BY source, pr.name_full_formatted, dc.person_id,
   dc.contact_dt_tm DESC
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,0,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(trim(org_name),0,125),
   col 104, captions->rpt_as_of_date, col 118,
   curdate"@DATECONDENSED;;d", row + 2
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
    dt_tm = cnvtdatetime(request->begin_dt_tm), row + 1, col 35,
    captions->begin_dt, col 52, dt_tm"@DATECONDENSED;;d",
    dt_tm = cnvtdatetime(request->end_dt_tm), col 66, captions->end_dt,
    col 82, dt_tm"@DATECONDENSED;;d", row + 2,
    col 64, captions->last_donated, col 105,
    captions->donation, col 116, captions->eligibility,
    row + 1, col 23, captions->donor_info,
    col 64, captions->as_member, col 80,
    captions->outcome, col 90, captions->last_donation,
    col 107, captions->level, col 119,
    captions->status, row + 1, col 2,
    "------------------------------------------------------------", col + 2, "-------------",
    col + 2, "---------", col + 2,
    "-------------", col + 2, "---------",
    col + 2, "-----------", row + 1
   ENDIF
  HEAD dc.person_id
   IF (dc.person_id > 0)
    don_grand_total = (pd.donation_level_trans+ pd.donation_level), col 2, donor_name,
    col + 2, dc.contact_dt_tm, col + 8,
    outcome_type, col 90, pd.last_donation_dt_tm,
    col 105, don_grand_total"####.####", col 117,
    eligibility_type, don_grand_total = 0.0, row + 1
    IF (row > 56)
     BREAK
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
    street_string = concat(trim(a1.street_addr),trim(a1.street_addr2),trim(a1.street_addr3),trim(a1
      .street_addr4)), city_string = concat(trim(a1.city)," ",trim(a1.state)," ",trim(a1.zipcode)),
    address_string = concat(trim(street_string)," ",trim(city_string))
    IF (row > 56)
     BREAK
    ENDIF
    IF (address_string != fillstring(50," "))
     col 9, address_string, row + 1
    ELSE
     row + 0
    ENDIF
   ELSEIF (source=0)
    row + 0
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
   nolandscape, maxrow = 61, outerjoin(d_person_adr)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->report_name_list,1)
 SET reply->report_name_list[1].report_name = concat("CER_TEMP:",sfilename,".txt")
#exitscript
END GO
