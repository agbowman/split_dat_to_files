CREATE PROGRAM bb_rpt_qc_reasons:dba
 RECORD reply(
   1 file_name = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD params(
   1 qual[*]
     2 display = c40
     2 description = vc
     2 reason_type = vc
     2 active_ind = i2
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
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
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nfirsttime = i2 WITH protect, noconstant(1)
 DECLARE li18nhandle = i4 WITH protect, noconstant(0)
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE lcodeset = i4 WITH protect, constant(325576)
 DECLARE nbreak = i2 WITH protect, noconstant(0)
 DECLARE nsegcount = i2 WITH protect, noconstant(0)
 DECLARE nlinesperpage = i2 WITH protect, constant(57)
 DECLARE nlinelength = i2 WITH protect, constant(70)
 DECLARE scurstring = vc WITH protect, noconstant("")
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE nval = i2 WITH protect, noconstant(0)
 DECLARE ssixline = vc WITH protect, noconstant("")
 DECLARE stwentytwoline = vc WITH protect, noconstant("")
 DECLARE stwentythreeline = vc WITH protect, noconstant("")
 DECLARE sdashstringline = vc WITH protect, noconstant("")
 DECLARE sdashlinestring = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET nstatus = uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 stitle = vc
   1 susername = vc
   1 sdomain = vc
   1 sdate = vc
   1 stime = vc
   1 spage = vc
   1 sactive = vc
   1 sdisplay = vc
   1 sdescription = vc
   1 sreasontype = vc
   1 sbegineffective = vc
   1 sendeffective = vc
   1 sendofreport = vc
   1 syes = vc
   1 sno = vc
 )
 SET captions->stitle = uar_i18ngetmessage(li18nhandle,"TITLE",
  "PathNet Blood Bank: QC Reasons Report")
 SET captions->susername = uar_i18ngetmessage(li18nhandle,"NAME","Name:")
 SET captions->sdomain = uar_i18ngetmessage(li18nhandle,"DOMAIN","Domain:")
 SET captions->sdate = uar_i18ngetmessage(li18nhandle,"DATE","Date:")
 SET captions->stime = uar_i18ngetmessage(li18nhandle,"TIME","Time:")
 SET captions->spage = uar_i18ngetmessage(li18nhandle,"PAGE","Page:")
 SET captions->sactive = uar_i18ngetmessage(li18nhandle,"ACTIVE","Active")
 SET captions->sdisplay = uar_i18ngetmessage(li18nhandle,"DISPLAY","Display")
 SET captions->sdescription = uar_i18ngetmessage(li18nhandle,"DESCRIPTION","Description")
 SET captions->sreasontype = uar_i18ngetmessage(li18nhandle,"REASON_TYPE","Reason Type")
 SET captions->sbegineffective = uar_i18ngetmessage(li18nhandle,"BEGIN","Begin Effective")
 SET captions->sendeffective = uar_i18ngetmessage(li18nhandle,"END","End Effective")
 SET captions->sendofreport = uar_i18ngetmessage(li18nhandle,"ENDOFREPORT",
  "* * * End of Report * * *")
 SET captions->syes = uar_i18ngetmessage(li18nhandle,"YES","Yes")
 SET captions->sno = uar_i18ngetmessage(li18nhandle,"NO","No")
 SET nval = size(nullterm(request->reason_type),1)
 SELECT INTO "nl:"
  FROM code_value cv,
   common_data_foundation cdf
  PLAN (cv
   WHERE cv.code_set=lcodeset
    AND (((request->active_ind=0)) OR ((request->active_ind=cv.active_ind)))
    AND ((nval=0) OR ((request->reason_type=cv.cdf_meaning))) )
   JOIN (cdf
   WHERE cdf.code_set=lcodeset
    AND cdf.cdf_meaning=cv.cdf_meaning)
  ORDER BY cdf.display, cv.display
  HEAD REPORT
   ncount = 0
  DETAIL
   ncount = (ncount+ 1)
   IF (ncount > size(params->qual,5))
    nstatus = alterlist(params->qual,(ncount+ 9))
   ENDIF
   params->qual[ncount].display = cv.display, params->qual[ncount].description = cv.description,
   params->qual[ncount].reason_type = cdf.display,
   params->qual[ncount].active_ind = cv.active_ind, params->qual[ncount].begin_effective_dt_tm = cv
   .begin_effective_dt_tm, params->qual[ncount].end_effective_dt_tm = cv.end_effective_dt_tm
  FOOT REPORT
   nstatus = alterlist(params->qual,ncount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_reasons",serror)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name "bb_qcr", "txt"
 IF ((cpm_cfn_info->status_data.status != "S"))
  CALL subevent_add("SELECT","F","bb_rpt_qc_reasons","Failed to create a file name")
  GO TO exit_script
 ENDIF
 IF (size(params->qual,5)=0)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    stwentytwoline = fillstring(22,"-"), stwentythreeline = fillstring(23,"-"), ssixline = fillstring
    (6,"-"),
    sdashlinestring = fillstring(128,"-")
   DETAIL
    CALL center(captions->stitle,1,128), row + 1, col 1,
    captions->susername, col 9, request->username,
    col 115, captions->sdate, col 121,
    curdate"@SHORTDATE", row + 1, col 1,
    captions->sdomain, col 9, request->domain,
    col 115, captions->stime, col 121,
    curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
    col 1, captions->sdisplay, col 25,
    captions->sdescription, col 49, captions->sreasontype,
    col 73, captions->sactive, col 81,
    captions->sbegineffective, col 106, captions->sendeffective,
    row + 1, col 1, stwentytwoline,
    col 25, stwentytwoline, col 49,
    stwentytwoline, col 73, ssixline,
    col 81, stwentythreeline, col 106,
    stwentythreeline, row + 1
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashlinestring, row + 1, col 59,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = value(size(params->qual,5)))
   PLAN (d)
   HEAD REPORT
    stwentytwoline = fillstring(22,"-"), stwentythreeline = fillstring(23,"-"), ssixline = fillstring
    (6,"-"),
    sdashlinestring = fillstring(128,"-")
   HEAD PAGE
    IF (((d.seq < value(size(params->qual,5))) OR (((nbreak=1) OR (value(size(params->qual,5))=1))
    )) )
     IF (((value(size(params->qual,5))=1
      AND ((nbreak=1) OR (nfirsttime=1)) ) OR (value(size(params->qual,5)) > 1)) )
      CALL center(captions->stitle,1,128), row + 1, col 1,
      captions->susername, col 9, request->username,
      col 115, captions->sdate, col 121,
      curdate"@SHORTDATE", row + 1, col 1,
      captions->sdomain, col 9, request->domain,
      col 115, captions->stime, col 121,
      curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
      col 1, captions->sdisplay, col 25,
      captions->sdescription, col 49, captions->sreasontype,
      col 73, captions->sactive, col 81,
      captions->sbegineffective, col 106, captions->sendeffective,
      row + 1, col 1, stwentytwoline,
      col 25, stwentytwoline, col 49,
      stwentytwoline, col 73, ssixline,
      col 81, stwentythreeline, col 106,
      stwentythreeline, row + 1, nfirsttime = 0
     ENDIF
    ENDIF
   DETAIL
    IF ((row >= (nlinesperpage+ 1)))
     nbreak = 1, BREAK
    ELSE
     nbreak = 0
    ENDIF
    col 1, params->qual[d.seq].display, col 25,
    params->qual[d.seq].description, col 49, params->qual[d.seq].reason_type
    IF ((params->qual[d.seq].active_ind=1))
     col 73, captions->syes
    ELSE
     col 73, captions->sno
    ENDIF
    col 81, params->qual[d.seq].begin_effective_dt_tm"@MEDIUMDATETIME", col 106,
    params->qual[d.seq].end_effective_dt_tm"@MEDIUMDATETIME", row + 1
    IF (d.seq=value(size(params->qual,5)))
     col 51, captions->sendofreport
    ENDIF
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashlinestring, row + 1, col 59,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_reasons",serror)
  GO TO exit_script
 ENDIF
 SET reply->file_name = cpm_cfn_info->file_name_path
 SET reply->node = curnode
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD params
 FREE RECORD captions
END GO
