CREATE PROGRAM bhs_rad_rpt_incomplete_exam:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 batch_selection = c100
    1 output_dist = c100
  )
 ENDIF
 SET request->batch_selection = trim("BMC NC||01-JUN-2007||")
 SET request->output_dist = " "
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE h = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD text(
   1 title = vc
   1 print_date = vc
   1 time = vc
   1 department = vc
   1 section = vc
   1 patient_name = vc
   1 type = vc
   1 procedure_name = vc
   1 accession = vc
   1 requested_dt_tm = vc
   1 status = vc
   1 folder_num = vc
   1 folder_loc = vc
   1 order_phy = vc
   1 tech_initials = vc
   1 section_total = vc
   1 report_name = vc
   1 page_ = vc
   1 continued = vc
   1 end_of_report = vc
   1 date_range = vc
   1 filtered_by = vc
   1 request_of = vc
   1 through = vc
   1 request_before = vc
   1 patient_mrn = vc
   1 pacs_id = vc
 )
 SET text->title = uar_i18ngetmessage(i18nhandle,"title","I N C O M P L E T E  E X A M  R E P O R T")
 SET text->print_date = uar_i18ngetmessage(i18nhandle,"print_date","PRINT DATE:")
 SET text->time = uar_i18ngetmessage(i18nhandle,"time","TIME:")
 SET text->department = uar_i18ngetmessage(i18nhandle,"department","DEPARTMENT:")
 SET text->section = uar_i18ngetmessage(i18nhandle,"section","SECTION:")
 SET text->patient_name = uar_i18ngetmessage(i18nhandle,"patient_name","Patient Name")
 SET text->type = uar_i18ngetmessage(i18nhandle,"type","Type")
 SET text->procedure_name = uar_i18ngetmessage(i18nhandle,"procedure_name","Procedure Name")
 SET text->accession = uar_i18ngetmessage(i18nhandle,"accession","Accession")
 SET text->requested_dt_tm = uar_i18ngetmessage(i18nhandle,"requested_dt_tm","Requested Date/Time")
 SET text->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET text->folder_num = uar_i18ngetmessage(i18nhandle,"folder_num","Folder #:")
 SET text->folder_loc = uar_i18ngetmessage(i18nhandle,"folder_loc","Folder Loc:")
 SET text->order_phy = uar_i18ngetmessage(i18nhandle,"order_phy","Order Physician:")
 SET text->tech_initials = uar_i18ngetmessage(i18nhandle,"tech_initials","Tech Initials:")
 SET text->section_total = uar_i18ngetmessage(i18nhandle,"section_total","SECTION TOTAL:")
 SET text->report_name = uar_i18ngetmessage(i18nhandle,"report_name","REPORT: INCOMPLETE EXAMS")
 SET text->page_ = uar_i18ngetmessage(i18nhandle,"page_","PAGE:")
 SET text->continued = uar_i18ngetmessage(i18nhandle,"continued","CONTINUED...")
 SET text->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","### END OF REPORT ###")
 SET text->filtered_by = uar_i18ngetmessage(i18nhandle,"FILTERED_BY","FILTERED BY")
 SET text->request_before = uar_i18ngetmessage(i18nhandle,"REQUEST_BEFORE",
  "REQUEST DATE OF OR BEFORE")
 SET text->through = uar_i18ngetmessage(i18nhandle,"THROUGH","THROUGH")
 SET text->request_of = uar_i18ngetmessage(i18nhandle,"REQUEST_DATES_OF","REQUEST DATE OF")
 SET text->patient_mrn = uar_i18ngetmessage(i18nhandle,"patient_mrn","MRN:")
 SET text->pacs_id = uar_i18ngetmessage(i18nhandle,"pacs_id","PACS ID:")
 DECLARE displayreport(sdummyvar=vc(value)) = null
 DECLARE processbatchselection(sbatchselection=vc(value)) = null
 DECLARE builddtstrings(sdaterange=vc(ref),sdateline=vc(ref)) = null
 DECLARE sql_get_name_display(personid=f8,nametypecd=f8,date=q8) = c100
 DECLARE prsnl_name_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE g_output_dist = vc WITH protect
 DECLARE g_status_inprocess_cd = f8 WITH protect
 DECLARE g_status_ordered_cd = f8 WITH protect
 DECLARE g_status_started_cd = f8 WITH protect
 DECLARE g_dept_cd = f8 WITH protect
 DECLARE g_begin_dt = q8 WITH protect
 DECLARE g_end_dt = q8 WITH protect
 DECLARE g_encntr_alias_mrn_cd = f8 WITH protect
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET subsection_cd = 0.0
 SET section_cd = 0.0
 SET department_cd = 0.0
 SET primary_cd = 0.0
 SET sect_cd = 0.0
 SET g_dept_cd = 0.0
 SET action_start_cd = 0.0
 SET code_set = 223
 SET cdf_meaning = "SUBSECTION"
 EXECUTE cpm_get_cd_for_cdf
 SET subsection_cd = code_value
 SET code_set = 223
 SET cdf_meaning = "SECTION"
 EXECUTE cpm_get_cd_for_cdf
 SET section_cd = code_value
 SET code_set = 223
 SET cdf_meaning = "DEPARTMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET department_cd = code_value
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET primary_cd = code_value
 SET code_set = 14123
 SET cdf_meaning = "START"
 EXECUTE cpm_get_cd_for_cdf
 SET action_start_cd = code_value
 SET g_status_inprocess_cd = uar_get_code_by("MEANING",14192,"RADINPROCESS")
 SET g_status_ordered_cd = uar_get_code_by("MEANING",14192,"RADORDERED")
 SET g_status_started_cd = uar_get_code_by("MEANING",14192,"RADSTARTED")
 SET g_encntr_alias_mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 IF (trim(request->batch_selection) != "")
  CALL processbatchselection(trim(request->batch_selection))
 ENDIF
 SET g_output_dist = request->output_dist
 IF (g_output_dist="")
  EXECUTE cclseclogin
  SET width = 132
  SET modify = system
 ENDIF
 CALL displayreport("REPORT")
 GO TO error_check
 SUBROUTINE displayreport(indummy)
   DECLARE sdaterange = vc WITH protect
   DECLARE sfiltersline = vc WITH protect
   DECLARE sdateline = vc WITH protect
   DECLARE sdeptdisp = vc WITH protect
   DECLARE ssectdisp = vc WITH protect
   CALL builddtstrings(sdaterange,sdateline)
   IF (sect_cd > 0)
    SET ssectdisp = uar_get_code_display(sect_cd)
    SET sfiltersline = text->filtered_by
    SET sfiltersline = concat(sfiltersline," ",text->section," ",ssectdisp)
   ENDIF
   IF (g_dept_cd > 0)
    SET sdeptdisp = uar_get_code_display(g_dept_cd)
    SET sfiltersline = text->filtered_by
    SET sfiltersline = concat(sfiltersline," ",text->department," ",sdeptdisp)
   ENDIF
   SELECT
    IF (g_output_dist != "")DISTINCT INTO value(g_output_dist)
    ELSE DISTINCT INTO mine
    ENDIF
    accession_number = uar_fmt_accession(o.accession,size(o.accession)), status =
    uar_get_code_display(o.exam_status_cd), o.catalog_cd,
    o.request_dt_tm";;q", o.order_id, re.order_id,
    re.rad_exam_id, re.task_assay_cd, subsection = uar_get_code_display(rg.parent_service_resource_cd
     ),
    section = uar_get_code_display(rg2.parent_service_resource_cd), department = uar_get_code_display
    (rg3.parent_service_resource_cd), s.mnemonic,
    patient_type = uar_get_code_display(e.encntr_type_cd), p.name_full_formatted, icpr.seq_object_id,
    er.lib_group_cd, lib_group = uar_get_code_display(ef.lib_group_cd), ic.volume,
    image_class_type = uar_get_code_display(ic.image_class_type_cd), t.tracking_point_cd, bl
    .borrower_lender_id,
    p2.person_id, c.code_value, rp.rad_exam_id,
    rp.exam_prsnl_id, rp.action_type_cd, pn.person_id,
    pn.name_initials, ea.encntr_alias_type_cd, ea.alias,
    sorderphysfullname = sql_get_name_display(o.order_physician_id,prsnl_name_type_cd,o.request_dt_tm
     ), sphysfullname = sql_get_name_display(t.tracking_point_cd,prsnl_name_type_cd,t
     .trk_pt_arrive_dt_tm)
    FROM order_radiology o,
     rad_exam re,
     resource_group rg,
     resource_group rg2,
     resource_group rg3,
     order_catalog_synonym s,
     encounter e,
     person p,
     iclass_person_reltn icpr,
     exam_room_lib_grp_reltn er,
     exam_folder ef,
     image_class ic,
     trackable_object t,
     (dummyt d1  WITH seq = 1),
     borrower_lender bl,
     person p2,
     code_value c,
     dummyt d2,
     rad_exam_prsnl rp,
     person_name pn,
     encntr_alias ea,
     dummyt d3,
     dummyt d4,
     dummyt d5,
     dummyt d6
    PLAN (o
     WHERE parser(sdaterange))
     JOIN (re
     WHERE re.order_id=o.order_id
      AND re.exam_sequence=1)
     JOIN (rg
     WHERE rg.child_service_resource_cd=re.service_resource_cd
      AND ((rg.resource_group_type_cd+ 0)=subsection_cd))
     JOIN (rg2
     WHERE ((rg2.child_service_resource_cd=rg.parent_service_resource_cd
      AND rg2.parent_service_resource_cd=sect_cd
      AND rg2.resource_group_type_cd=section_cd
      AND sect_cd != 0.0) OR (rg2.child_service_resource_cd=rg.parent_service_resource_cd
      AND ((rg2.resource_group_type_cd+ 0)=section_cd)
      AND sect_cd=0.0)) )
     JOIN (rg3
     WHERE ((g_dept_cd != 0.0
      AND rg3.child_service_resource_cd=rg2.parent_service_resource_cd
      AND rg3.parent_service_resource_cd=g_dept_cd
      AND rg3.resource_group_type_cd=department_cd) OR (g_dept_cd=0.0
      AND rg3.child_service_resource_cd=rg2.parent_service_resource_cd
      AND ((rg3.resource_group_type_cd+ 0)=department_cd))) )
     JOIN (s
     WHERE s.catalog_cd=o.catalog_cd
      AND s.mnemonic_type_cd=primary_cd)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
     JOIN (d3)
     JOIN (ea
     WHERE o.encntr_id=ea.encntr_id
      AND ea.active_ind=1
      AND ea.encntr_alias_type_cd=g_encntr_alias_mrn_cd
      AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (d1
     WHERE d1.seq=1)
     JOIN (icpr
     WHERE icpr.person_id=o.person_id)
     JOIN (er
     WHERE er.service_resource_cd=re.service_resource_cd)
     JOIN (ef
     WHERE ef.catalog_cd=o.catalog_cd
      AND ef.lib_group_cd=er.lib_group_cd)
     JOIN (ic
     WHERE ic.seq_object_id=icpr.seq_object_id
      AND ic.image_class_type_cd=ef.image_class_type_cd)
     JOIN (t
     WHERE t.seq_object_id=ic.seq_object_id
      AND t.active_ind=1)
     JOIN (((d4)
     JOIN (bl
     WHERE bl.borrower_lender_id=t.tracking_point_cd
      AND t.loan_type_flag=2)
     ) ORJOIN ((((d5)
     JOIN (p2
     WHERE p2.person_id=t.tracking_point_cd
      AND t.loan_type_flag=3)
     ) ORJOIN ((d6)
     JOIN (c
     WHERE t.loan_type_flag=0
      AND c.code_value=t.tracking_point_cd)
     JOIN (d2)
     JOIN (rp
     WHERE rp.rad_exam_id=re.rad_exam_id
      AND rp.action_type_cd=action_start_cd)
     JOIN (pn
     WHERE pn.person_id=rp.exam_prsnl_id)
     )) ))
    ORDER BY rg2.parent_service_resource_cd, substring(1,15,p.name_full_formatted), o.accession_id,
     o.order_id, o.catalog_cd
    HEAD REPORT
     line1 = fillstring(130,"-"), last_pat = 0, sect = 0
    HEAD PAGE
     CALL center(text->title,0,132), row + 1, col 1,
     text->print_date, col + 2, curdate"@SHORTDATE;;Q",
     col 105, text->time, col + 6,
     curtime, row + 1
     IF (sfiltersline != "")
      CALL center(sfiltersline,0,132), row + 1
     ENDIF
     IF (sdateline != "")
      CALL center(sdateline,0,132)
     ENDIF
     row + 1, col 01, text->department,
     col 25, department, row + 1,
     col 01, text->section, col 25,
     section, row + 3, col 1,
     text->patient_name, col 35, text->type,
     col 50, text->procedure_name, col 74,
     text->accession, col 95, text->requested_dt_tm,
     col 120, text->status, row + 1,
     line1, row + 1
    HEAD section
     IF (sect > 0)
      BREAK
     ENDIF
    DETAIL
     col 1,
     CALL print(substring(1,30,p.name_full_formatted)), col 35,
     CALL print(substring(1,10,patient_type)), col 50,
     CALL print(substring(1,20,s.mnemonic)),
     col 74, accession_number, col 95,
     o.request_dt_tm"@SHORTDATE;;Q", col + 1, o.request_dt_tm"hh:mm;;m",
     col 120,
     CALL print(substring(1,10,status)), row + 1,
     col 10, text->folder_num, col + 2,
     ic.filing_number"###############;p0", "-",
     CALL print(substring(1,02,lib_group)),
     "-",
     CALL print(substring(1,2,image_class_type)), "-",
     ic.volume"###;p0", col 70, text->folder_loc,
     col + 2
     IF (t.loan_type_flag=0)
      CALL print(substring(1,20,c.display))
     ELSEIF (t.loan_type_flag=1)
      CALL print(substring(1,20,sphysfullname))
     ELSEIF (t.loan_type_flag=2)
      CALL print(substring(1,20,bl.name))
     ELSEIF (t.loan_type_flag=3)
      CALL print(substring(1,20,p2.name_full_formatted))
     ENDIF
     row + 1, col 10, text->order_phy,
     " ",
     CALL print(substring(1,20,sorderphysfullname)), col 70,
     text->tech_initials, " ",
     CALL print(substring(1,3,pn.name_initials)),
     row + 1, col 10, text->patient_mrn,
     " ",
     CALL print(substring(1,20,ea.alias)), col 70,
     text->pacs_id, " ",
     CALL print(format(o.rad_pacs_id,"####################;L")),
     last_pat = 1, row + 2
     IF (last_pat=1
      AND ((row+ 2) > 55))
      BREAK
     ENDIF
     last_pat = 0
    FOOT  section
     row + 3, col 01, text->section,
     col 30, section, row + 1,
     col 01, text->section_total, col 30,
     count(o.catalog_cd)"#####;p0", sect = (sect+ 1), row + 1
    FOOT PAGE
     row 57, col 0, line1,
     row + 1, col 0, text->report_name,
     today = concat(format(curdate,"@WEEKDAYABBREV")," ",format(curdate,"@SHORTDATE;;Q")), col 53,
     today,
     col 110, text->page_, col 117,
     curpage"###", row + 1, col 53,
     text->continued
    FOOT REPORT
     col 53, text->end_of_report
    WITH outerjoin = d1, outerjoin = d2, dontcare = ea,
     nocounter, compress
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE processbatchselection(sbatchselection)
   DECLARE nsizeofstr = i4 WITH private
   DECLARE nindex = i4 WITH private
   DECLARE nsavedndx = i4 WITH private
   DECLARE ncount = i4 WITH private
   DECLARE sparameters = vc WITH private
   DECLARE sdate = vc WITH protect
   DECLARE sdeptdisp = vc WITH protect
   DECLARE ssectdisp = vc WITH protect
   SET nindex = 1
   SET nsavedndx = 1
   SET ncount = 0
   SET sdate = ""
   SET sparameters = build(sbatchselection,"|")
   SET nsizeofstr = size(trim(sparameters),1)
   CALL echo(build("BATCH SELECTION = ",sparameters))
   CALL echo(build("NSIZEOFSTR:",nsizeofstr))
   WHILE ((nindex < (nsizeofstr+ 1)))
    IF (substring(nindex,1,sparameters)="|")
     SET ncount = (ncount+ 1)
     CALL echo(build("NCOUNT:",ncount))
     IF (nindex != nsavedndx)
      CALL echo(build("NINDEX:",nindex))
      CALL echo(build("NSAVEDNDX:",nsavedndx))
      CALL echo(build("case ncount:",ncount))
      CASE (ncount)
       OF 1:
        SET ssectdisp = substring(nsavedndx,(nindex - nsavedndx),sparameters)
        CALL echo(build("SECTION DISPLAY = ",ssectdisp))
        IF (ssectdisp != "")
         SELECT INTO "nl:"
          c.code_value
          FROM code_value c
          WHERE c.code_set=221
           AND c.cdf_meaning="SECTION"
           AND c.active_ind=1
           AND c.display=ssectdisp
          DETAIL
           sect_cd = c.code_value
          WITH nocounter
         ;end select
        ENDIF
       OF 2:
        IF (sect_cd=0)
         SET sdeptdisp = substring(nsavedndx,(nindex - nsavedndx),sparameters)
         CALL echo(build("DEPARTMENT DISPLAY = ",ssectdisp))
         IF (sdeptdisp != "")
          SELECT INTO "nl:"
           c.code_value
           FROM code_value c
           WHERE c.code_set=221
            AND c.cdf_meaning="DEPARTMENT"
            AND c.active_ind=1
            AND c.display=sdeptdisp
           DETAIL
            g_dept_cd = c.code_value
           WITH nocounter
          ;end select
         ENDIF
        ENDIF
       OF 3:
        SET sdate = substring(nsavedndx,(nindex - nsavedndx),sparameters)
        SET g_begin_dt = cnvtdatetime(cnvtdate2(sdate,"DD-MMM-YYYY"),000000)
        CALL echo(build("BEGIN DATE = ",g_begin_dt))
       OF 4:
        SET sdate = substring(nsavedndx,(nindex - nsavedndx),sparameters)
        SET g_end_dt = cnvtdatetime(cnvtdate2(sdate,"DD-MMM-YYYY"),235959)
        CALL echo(build("END DATE = ",g_begin_dt))
       OF 5:
        SET g_end_dt = cnvtdatetime(curdate,curtime)
        SET sdate = substring(nsavedndx,(nindex - nsavedndx),sparameters)
        SET g_begin_dt = cnvtdatetime(datetimeadd(cnvtdatetime(curdate,0),- (cnvtint(sdate))))
      ENDCASE
     ENDIF
     SET nsavedndx = (nindex+ 1)
    ENDIF
    SET nindex = (nindex+ 1)
   ENDWHILE
   CALL echo(build("SECTION CD: ",sect_cd))
   CALL echo(build("DEPT CD   : ",g_dept_cd))
   CALL echo(build("BEGIN DT  : ",format(g_begin_dt,"@MEDIUMDATETIME")))
   CALL echo(build("END DT    : ",format(g_end_dt,"@MEDIUMDATETIME")))
   RETURN
 END ;Subroutine
 SUBROUTINE builddtstrings(sdaterange,sdateline)
   DECLARE sbegindate = vc WITH protect
   DECLARE senddate = vc WITH protect
   SET sdaterange = "0=0"
   SET sdateline = ""
   IF (g_begin_dt != null)
    IF (g_end_dt=null)
     SET g_end_dt = cnvtdatetime(curdate,curtime3)
    ENDIF
    SET sdaterange = concat(" o.exam_status_cd + 0 in (g_status_inprocess_cd ",
     ",g_status_ordered_cd, g_status_started_cd)","AND o.order_id + 0 > 0.0 ")
    SET sdaterange = concat(trim(sdaterange,3)," and o.request_dt_tm >= cnvtdatetime(g_begin_dt)")
    SET sdaterange = concat(trim(sdaterange,3)," AND o.request_dt_tm<=cnvtdatetime(g_end_dt)")
    SET sbegindate = format(g_begin_dt,"mm/dd/yyyy;;d")
    SET senddate = format(g_end_dt,"mm/dd/yyyy;;d")
    SET sdateline = text->request_of
    SET sdateline = concat(sdateline," ",sbegindate)
    IF (sbegindate != senddate)
     SET sdateline = concat(sdateline," ",text->through," ",senddate)
    ENDIF
   ELSEIF (g_end_dt != null)
    SET sdaterange = concat(" o.exam_status_cd + 0 in (g_status_inprocess_cd ",
     ", g_status_ordered_cd, g_status_started_cd)",
     "AND o.order_id + 0 > 0.0 and o.request_dt_tm <= cnvtdatetime(g_end_dt)")
    SET sdateline = text->request_before
    SET sdateline = concat(sdateline," ",format(g_end_dt,"mm/dd/yyyy;;d"))
   ELSE
    SET sdaterange = concat(" o.exam_status_cd in (g_status_inprocess_cd ",
     ", g_status_ordered_cd, g_status_started_cd)",
     "AND o.order_id +0 > 0.0 and o.request_dt_tm + 0 <= CNVTDATETIME(curdate,curtime3)")
   ENDIF
   RETURN
 END ;Subroutine
#error_check
 IF (curqual < 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
