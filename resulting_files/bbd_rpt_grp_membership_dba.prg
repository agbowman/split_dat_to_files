CREATE PROGRAM bbd_rpt_grp_membership:dba
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
   1 donor_name = vc
   1 donor_number = vc
   1 last_donation = vc
   1 successful = vc
   1 yes = vc
   1 no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "O R G A N I Z A T I O N   M E M B E R S H I P S   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->donor_name = uar_i18ngetmessage(i18nhandle,"donor_name","Donor Name")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->last_donation = uar_i18ngetmessage(i18nhandle,"last_donation","Last Donation")
 SET captions->successful = uar_i18ngetmessage(i18nhandle,"successful","Successful")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_GROUP_MEMBERSHIPS"
  )
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SET reply->status_data.status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET contact_type_cd = 0.0
 SET donor_org_cd = 0.0
 SET donor_nbr_cd = 0.0
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 SET sfilename = build("bbd_gm_",sfiledate,sfiletime)
 SET code_set = 338
 SET cdf_meaning = "DONOR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_org_cd)
 SET code_set = 14220
 SET cdf_meaning = "DONATE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,contact_type_cd)
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_nbr_cd)
 SELECT INTO concat("CER_TEMP:",sfilename,".txt")
  org_name = o.org_name, donor_name = substring(1,60,p.name_full_formatted), dc.contact_dt_tm
  "MM/DD/YYYY;;D",
  donor_number = substring(1,20,pa.alias), outcome_type = uar_get_code_meaning(dr.outcome_cd), dr
  .outcome_cd,
  dc.person_id, p.name_full_formatted
  FROM organization o,
   person_org_reltn po,
   bbd_donor_contact dc,
   person p,
   person_alias pa,
   bbd_donation_results dr
  PLAN (o
   WHERE (o.organization_id=request->organization_id))
   JOIN (po
   WHERE po.organization_id=o.organization_id
    AND po.person_org_reltn_cd=donor_org_cd
    AND po.active_ind=1)
   JOIN (dc
   WHERE dc.organization_id=po.organization_id
    AND dc.person_id=po.person_id
    AND dc.contact_type_cd=contact_type_cd
    AND dc.active_ind=1)
   JOIN (p
   WHERE p.person_id=dc.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=donor_nbr_cd
    AND pa.active_ind=1)
   JOIN (dr
   WHERE dr.person_id=pa.person_id
    AND dr.active_ind=1)
  ORDER BY p.name_full_formatted, dc.person_id, dc.contact_dt_tm DESC
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1,
   CALL center(trim(org_name),0,125),
   col 104, captions->rpt_as_of_date, col 119,
   curdate"@DATECONDENSED;;d", row + 2, col 34,
   captions->donor_name, col 75, captions->donor_number,
   col 93, captions->last_donation, col 108,
   captions->successful, row + 1, col 9,
   "------------------------------------------------------------", col + 2, "--------------------",
   col + 2, "-------------", col + 2,
   "----------", row + 1
  HEAD dc.person_id
   col 9, donor_name, col + 2,
   donor_number, col + 2, dc.contact_dt_tm
   IF (outcome_type="SUCCESS")
    col + 8, captions->yes
   ELSE
    col + 8, captions->no
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  DETAIL
   row + 0
  FOOT  dc.person_id
   row + 0
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 119, curdate"@DATECONDENSED;;d"
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nullreport, counter, compress,
   nolandscape, maxrow = 61
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
