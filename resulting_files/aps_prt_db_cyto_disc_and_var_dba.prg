CREATE PROGRAM aps_prt_db_cyto_disc_and_var:dba
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
   1 rptaps = vc
   1 pathap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbcdandvt = vc
   1 ppage = vc
   1 procedure = vc
   1 aresp = vc
   1 compto = vc
   1 flagas = vc
   1 na = vc
   1 none = vc
   1 vvar = vc
   1 disc = vc
   1 cont = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_CYTO_DISC_AND_VAR.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"refdbaudit","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbcdandvt = uar_i18ngetmessage(i18nhandle,"dbcdandvt",
  "DB CYTOLOGY DISCREPANCIES AND VARIANCES TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","PROCEDURE")
 SET captions->aresp = uar_i18ngetmessage(i18nhandle,"aresp","ALPHA RESPONSE")
 SET captions->compto = uar_i18ngetmessage(i18nhandle,"compto","COMPARED TO")
 SET captions->flagas = uar_i18ngetmessage(i18nhandle,"flagas","FLAGGED AS")
 SET captions->na = uar_i18ngetmessage(i18nhandle,"na","N/A")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET captions->vvar = uar_i18ngetmessage(i18nhandle,"vvar","VARIANCE")
 SET captions->disc = uar_i18ngetmessage(i18nhandle,"disc","DISCREPANCY")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUING")
 RECORD reply(
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 max_alpha_qual = i4
   1 diagnostic_qual[*]
     2 reference_range_factor_id = f8
     2 diagnosis_task_assay_cd = f8
     2 diagnosis_task_assay_disp = c40
     2 diagnosis_task_assay_desc = c60
     2 alpha_qual[*]
       3 base_nomenclature_id = f8
       3 base_nomenclature_disp = c40
       3 base_alpha_sequence = i4
       3 comp_nomenclature_id = f8
       3 comp_nomenclature_disp = c40
       3 comp_alpha_sequence = i4
       3 internal_flag = i4
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
#script
 SELECT INTO "nl:"
  n1.mnemonic, n2.mnemonic, ar1.reference_range_factor_id,
  ar1.nomenclature_id, crc.diagnosis_task_assay_cd
  FROM alpha_responses ar1,
   alpha_responses ar2,
   reference_range_factor rrf,
   cyto_report_control crc,
   nomenclature n1,
   nomenclature n2
  PLAN (crc
   WHERE crc.report_type_flag=1)
   JOIN (rrf
   WHERE crc.diagnosis_task_assay_cd=rrf.task_assay_cd
    AND 1=rrf.active_ind)
   JOIN (ar1
   WHERE rrf.reference_range_factor_id=ar1.reference_range_factor_id
    AND ar1.active_ind=1)
   JOIN (ar2
   WHERE rrf.reference_range_factor_id=ar2.reference_range_factor_id
    AND ar2.active_ind=1)
   JOIN (n1
   WHERE ar1.nomenclature_id=n1.nomenclature_id)
   JOIN (n2
   WHERE ar2.nomenclature_id=n2.nomenclature_id)
  ORDER BY crc.diagnosis_task_assay_cd, ar1.sequence, ar2.sequence
  HEAD REPORT
   diag_cnt = 0
  HEAD crc.diagnosis_task_assay_cd
   diag_cnt = (diag_cnt+ 1), stat = alterlist(temp->diagnostic_qual,diag_cnt), temp->diagnostic_qual[
   diag_cnt].diagnosis_task_assay_cd = crc.diagnosis_task_assay_cd,
   temp->diagnostic_qual[diag_cnt].reference_range_factor_id = rrf.reference_range_factor_id, cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF ((cnt > temp->max_alpha_qual))
    temp->max_alpha_qual = cnt
   ENDIF
   stat = alterlist(temp->diagnostic_qual[diag_cnt].alpha_qual,cnt), temp->diagnostic_qual[diag_cnt].
   alpha_qual[cnt].base_nomenclature_disp = n1.mnemonic, temp->diagnostic_qual[diag_cnt].alpha_qual[
   cnt].base_nomenclature_id = ar1.nomenclature_id,
   temp->diagnostic_qual[diag_cnt].alpha_qual[cnt].base_alpha_sequence = ar1.sequence, temp->
   diagnostic_qual[diag_cnt].alpha_qual[cnt].comp_nomenclature_disp = n2.mnemonic, temp->
   diagnostic_qual[diag_cnt].alpha_qual[cnt].comp_nomenclature_id = ar2.nomenclature_id,
   temp->diagnostic_qual[diag_cnt].alpha_qual[cnt].comp_alpha_sequence = ar2.sequence, temp->
   diagnostic_qual[diag_cnt].alpha_qual[cnt].internal_flag = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "ALPHA RESPONSES"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DB_CYTO_DISCREP"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  cv.display
  FROM (dummyt d  WITH seq = value(size(temp->diagnostic_qual,5))),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE (temp->diagnostic_qual[d.seq].diagnosis_task_assay_cd=cv.code_value))
  DETAIL
   temp->diagnostic_qual[d.seq].diagnosis_task_assay_disp = cv.display, temp->diagnostic_qual[d.seq].
   diagnosis_task_assay_desc = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cdd.nomenclature_x_id, cdd.nomenclature_y_id
  FROM cyto_diag_discrepancy cdd,
   (dummyt d1  WITH seq = value(size(temp->diagnostic_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_alpha_qual))
  PLAN (d1)
   JOIN (cdd
   WHERE (temp->diagnostic_qual[d1.seq].reference_range_factor_id=cdd.reference_range_factor_id))
   JOIN (d2
   WHERE d2.seq <= size(temp->diagnostic_qual[d1.seq].alpha_qual,5)
    AND (cdd.nomenclature_x_id=temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].base_nomenclature_id)
    AND (cdd.nomenclature_y_id=temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].comp_nomenclature_id)
   )
  ORDER BY temp->diagnostic_qual[d1.seq].diagnosis_task_assay_cd, temp->diagnostic_qual[d1.seq].
   alpha_qual[d2.seq].base_alpha_sequence
  DETAIL
   temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].internal_flag = cdd.internal_flag
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbCytoDiscVar", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  diagnosis_cd = temp->diagnostic_qual[d1.seq].diagnosis_task_assay_cd, diagnosis_disp = temp->
  diagnostic_qual[d1.seq].diagnosis_task_assay_disp, max_alpha_qual = temp->max_alpha_qual,
  base_nomenclature_id = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].base_nomenclature_id,
  base_nomenclature_disp = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].base_nomenclature_disp,
  base_alpha_seq = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].base_alpha_sequence,
  comp_nomenclature_id = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].comp_nomenclature_id,
  comp_nomenclature_disp = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].comp_nomenclature_disp,
  comp_alpha_seq = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].comp_alpha_sequence,
  internal_flag = temp->diagnostic_qual[d1.seq].alpha_qual[d2.seq].internal_flag
  FROM (dummyt d1  WITH seq = value(size(temp->diagnostic_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_alpha_qual))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->diagnostic_qual[d1.seq].alpha_qual,5))
  ORDER BY diagnosis_disp, base_alpha_seq, comp_alpha_seq
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   col 0,
   CALL center(captions->pathap,0,132), col 110,
   captions->ddate, ":", cdate = format(curdate,"@SHORTDATE;;d"),
   col 117, cdate, row + 1,
   col 0, captions->dir, ":",
   col 110, captions->ttime, ":",
   col 117, curtime, row + 1,
   col 0,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, ":", col 117,
   request->scuruser"##############", row + 1, col 0,
   CALL center(captions->dbcdandvt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 1
  HEAD diagnosis_disp
   IF (((row+ 1) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->procedure,
   ":", col 12, temp->diagnostic_qual[d1.seq].diagnosis_task_assay_disp,
   row + 1, col 12, temp->diagnostic_qual[d1.seq].diagnosis_task_assay_desc,
   row + 2, col 12, captions->aresp,
   col 39, captions->compto, col 66,
   captions->flagas, row + 1, col 12,
   "-------------------------", col 39, "-------------------------",
   col 66, "-----------"
  DETAIL
   row + 1, col 12, base_nomenclature_disp,
   col 39, comp_nomenclature_disp, col 66
   IF (base_nomenclature_id=comp_nomenclature_id)
    captions->na, "   "
   ELSE
    IF (internal_flag=0)
     captions->none
    ELSEIF (internal_flag=1)
     captions->vvar
    ELSEIF (internal_flag=2)
     captions->disc
    ENDIF
   ENDIF
   IF (((row+ 6) > maxrow))
    BREAK
   ENDIF
  FOOT  diagnosis_disp
   row + 1, row + 1, col 50,
   "* * * * * * * * *", row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;d")), col
   53, today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 43, captions->cont, ": ",
   col 55, diagnosis_disp
  FOOT REPORT
   col 43, "                                        ", col 55,
   "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
