CREATE PROGRAM bbt_rpt_phenotypes:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
   1 as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 time = vc
   1 special_testing = vc
   1 phenotypes = vc
   1 fisher_race = vc
   1 wiener = vc
   1 c = vc
   1 lower_c = vc
   1 e = vc
   1 lower_e = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->special_testing = uar_i18ngetmessage(i18nhandle,"special_testing",
  "SPECIAL TESTING TOOL")
 SET captions->phenotypes = uar_i18ngetmessage(i18nhandle,"phenotypes","PHENOTYPES")
 SET captions->fisher_race = uar_i18ngetmessage(i18nhandle,"fisher_race","Fisher_Race")
 SET captions->wiener = uar_i18ngetmessage(i18nhandle,"wiener","Wiener")
 SET captions->c = uar_i18ngetmessage(i18nhandle,"c","  C   ")
 SET captions->lower_c = uar_i18ngetmessage(i18nhandle,"lower_c","  c   ")
 SET captions->e = uar_i18ngetmessage(i18nhandle,"e","  E   ")
 SET captions->lower_e = uar_i18ngetmessage(i18nhandle,"lower_e","  e   ")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET b_row_inc = "N"
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_phenotypes", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  btype.rh_phenotype_id, btype.fr_nomenclature_id, btype.w_nomenclature_id,
  table_ind = decode(n.seq,"0NOMEN",btest.seq,"1BTEST","XXXXXX"), n.nomenclature_id, n.short_string
  "##########",
  btest.seq, btest.rh_pheno_testing_id, btest.special_testing_cd,
  special_testing_disp = uar_get_code_display(btest.special_testing_cd), btest.sequence
  FROM bb_rh_phenotype btype,
   (dummyt d  WITH seq = 1),
   bb_rh_pheno_testing btest,
   nomenclature n
  PLAN (btype
   WHERE btype.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (((n
   WHERE ((n.nomenclature_id=btype.fr_nomenclature_id) OR (n.nomenclature_id=btype.w_nomenclature_id
   )) )
   ) ORJOIN ((btest
   WHERE btest.rh_phenotype_id=btype.rh_phenotype_id
    AND btest.active_ind=1)
   ))
  ORDER BY btype.rh_phenotype_id, table_ind, btest.sequence
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 50, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 47, captions->special_testing, row + 1,
   col 50, captions->phenotypes, row + 1,
   line = fillstring(95,"-"), line, row + 1,
   col 4, captions->fisher_race, col 25,
   captions->wiener, col 40, captions->c,
   col 55, captions->lower_c, col 70,
   captions->e, col 85, captions->lower_e,
   row + 1, line, b_row_inc = "N"
  DETAIL
   IF (table_ind="0NOMEN")
    IF (b_row_inc="N")
     row + 1, b_row_inc = "Y"
    ENDIF
    IF (n.nomenclature_id=btype.fr_nomenclature_id)
     col 4, n.short_string
    ELSEIF (n.nomenclature_id=btype.w_nomenclature_id)
     col 24, n.short_string
    ENDIF
   ELSEIF (table_ind="1BTEST")
    b_row_inc = "N"
    IF (btest.sequence=1)
     col 42, special_testing_disp
    ELSEIF (btest.sequence=2)
     col 57, special_testing_disp
    ELSEIF (btest.sequence=3)
     col 72, special_testing_disp
    ELSEIF (btest.sequence=4)
     col 87, special_testing_disp
    ENDIF
   ELSE
    b_row_inc = "N"
   ENDIF
   IF (row >= 58)
    BREAK
   ENDIF
  FOOT REPORT
   row + 3, col 40, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape, outerjoin = d
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
