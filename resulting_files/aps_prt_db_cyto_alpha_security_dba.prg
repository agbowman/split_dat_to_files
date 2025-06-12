CREATE PROGRAM aps_prt_db_cyto_alpha_security:dba
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
   1 pathnetap = vc
   1 date = vc
   1 directory = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbcast = vc
   1 ppage = vc
   1 noauditfound = vc
   1 procedure = vc
   1 degrees = vc
   1 requeue = vc
   1 initial = vc
   1 rescreener = vc
   1 ccase = vc
   1 ffrom = vc
   1 service = vc
   1 verify = vc
   1 ttype = vc
   1 alpharesponse = vc
   1 diagnosticcat = vc
   1 normal = vc
   1 flag = vc
   1 resource = vc
   1 ttime = vc
   1 level = vc
   1 none = vc
   1 manual = vc
   1 automatic = vc
   1 continued = vc
   1 svcresource = vc
   1 default = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1",
  "REPORT:  APS_PRT_DB_CYTO_ALPHA_SECURITY.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h5","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->dbcast = uar_i18ngetmessage(i18nhandle,"h7","DB CYTOLOGY ALPHA SECURITY TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->noauditfound = uar_i18ngetmessage(i18nhandle,"h9","No audit data found.")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"h10","PROCEDURE:")
 SET captions->degrees = uar_i18ngetmessage(i18nhandle,"h11","DEGREES")
 SET captions->requeue = uar_i18ngetmessage(i18nhandle,"h12","REQUEUE")
 SET captions->initial = uar_i18ngetmessage(i18nhandle,"h13","INITIAL")
 SET captions->rescreener = uar_i18ngetmessage(i18nhandle,"h14","RESCREENER")
 SET captions->ccase = uar_i18ngetmessage(i18nhandle,"h15","CASE")
 SET captions->ffrom = uar_i18ngetmessage(i18nhandle,"h16","FROM")
 SET captions->service = uar_i18ngetmessage(i18nhandle,"h17","SERVICE")
 SET captions->verify = uar_i18ngetmessage(i18nhandle,"h18","VERIFY")
 SET captions->ttype = uar_i18ngetmessage(i18nhandle,"h19","TYPE")
 SET captions->alpharesponse = uar_i18ngetmessage(i18nhandle,"h20","ALPHA RESPONSE")
 SET captions->diagnosticcat = uar_i18ngetmessage(i18nhandle,"h21","DIAGNOSTIC CATEGORY")
 SET captions->normal = uar_i18ngetmessage(i18nhandle,"h22","NORMAL")
 SET captions->flag = uar_i18ngetmessage(i18nhandle,"h23","FLAG")
 SET captions->resource = uar_i18ngetmessage(i18nhandle,"h24","RESOURCE")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h25","TIME:")
 SET captions->level = uar_i18ngetmessage(i18nhandle,"h26","LEVEL")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"d1","(none)")
 SET captions->manual = uar_i18ngetmessage(i18nhandle,"d2","Manual")
 SET captions->automatic = uar_i18ngetmessage(i18nhandle,"d3","Automatic")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->svcresource = uar_i18ngetmessage(i18nhandle,"h27","SERVICE RESOURCE:")
 SET captions->default = uar_i18ngetmessage(i18nhandle,"h28","(default)")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 catalog_qual[*]
     2 catalog_cd = f8
     2 diagnosis_disp = c40
     2 cap_diagnosis_disp = c40
     2 diagnosis_desc = c60
     2 alpha_qual[*]
       3 sequence = i4
       3 nomenclature_id = f8
       3 nomenclature_disp = c25
       3 diagnostic_category_cd = f8
       3 diagnostic_category_disp = c40
       3 dfn_null_ind = i2
       3 degrees_from_normal = i4
       3 requeue_service_resource_cd = f8
       3 requeue_service_resource_disp = c40
       3 rf_null_ind = i2
       3 requeue_flag = i2
       3 vli_null_ind = i2
       3 verify_level_is = i4
       3 vlr_null_ind = i2
       3 verify_level_rs = i4
       3 qa_flag_type_cd = f8
       3 qa_flag_type_disp = c40
       3 service_resource_cd = f8
       3 service_resource_disp = c40
 )
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
 SET reply->status_data.status = "F"
 SET max_alpha_cntr = 0
 SET no_cases_found = "F"
 SELECT INTO "nl:"
  display_caps = cnvtupper(uar_get_code_display(crc.diagnosis_task_assay_cd)), crc.catalog_cd
  FROM cyto_report_control crc
  PLAN (crc
   WHERE crc.catalog_cd != 0.0)
  ORDER BY display_caps
  HEAD REPORT
   ctlg_cntr = 0
  HEAD display_caps
   ctlg_cntr += 1, stat = alterlist(temp->catalog_qual,ctlg_cntr), temp->catalog_qual[ctlg_cntr].
   catalog_cd = crc.catalog_cd,
   temp->catalog_qual[ctlg_cntr].diagnosis_disp = uar_get_code_display(crc.diagnosis_task_assay_cd),
   temp->catalog_qual[ctlg_cntr].cap_diagnosis_disp = display_caps, temp->catalog_qual[ctlg_cntr].
   diagnosis_desc = uar_get_code_description(crc.diagnosis_task_assay_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET no_cases_found = "T"
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  dta.mnemonic_key_cap, dfn_null_ind = nullind(cas.degrees_from_normal), rf_null_ind = nullind(cas
   .requeue_flag),
  vli_null_ind = nullind(cas.verify_level_is), vlr_null_ind = nullind(cas.verify_level_rs)
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(temp->catalog_qual,5))),
   cyto_alpha_security cas,
   nomenclature n
  PLAN (d2)
   JOIN (dta
   WHERE (dta.mnemonic_key_cap=temp->catalog_qual[d2.seq].cap_diagnosis_disp))
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   JOIN (d1)
   JOIN (cas
   WHERE ar.reference_range_factor_id=cas.reference_range_factor_id
    AND ar.nomenclature_id=cas.nomenclature_id
    AND cas.definition_ind IN (0, 1)
    AND cas.service_resource_cd=0.0)
  ORDER BY dta.mnemonic_key_cap, ar.sequence
  HEAD REPORT
   max_alpha_cntr = 0
  HEAD dta.mnemonic_key_cap
   alpha_cntr = 0
  DETAIL
   alpha_cntr += 1
   IF (alpha_cntr > max_alpha_cntr)
    max_alpha_cntr = alpha_cntr
   ENDIF
   stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,alpha_cntr), temp->catalog_qual[d2.seq].
   alpha_qual[alpha_cntr].sequence = ar.sequence, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   nomenclature_disp = n.mnemonic,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].diagnostic_category_cd = cas
   .diagnostic_category_cd, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   diagnostic_category_disp = uar_get_code_display(cas.diagnostic_category_cd), temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].requeue_service_resource_cd = cas.requeue_service_resource_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].requeue_service_resource_disp =
   uar_get_code_display(cas.requeue_service_resource_cd), temp->catalog_qual[d2.seq].alpha_qual[
   alpha_cntr].degrees_from_normal = cas.degrees_from_normal, temp->catalog_qual[d2.seq].alpha_qual[
   alpha_cntr].requeue_flag = cas.requeue_flag,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].verify_level_is = cas.verify_level_is, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].verify_level_rs = cas.verify_level_rs, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].dfn_null_ind = dfn_null_ind,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].rf_null_ind = rf_null_ind, temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].vli_null_ind = vli_null_ind, temp->catalog_qual[d2.seq].alpha_qual[
   alpha_cntr].vlr_null_ind = vlr_null_ind,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].qa_flag_type_cd = cas.qa_flag_type_cd, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].qa_flag_type_disp = uar_get_code_display(cas
    .qa_flag_type_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].nomenclature_id = ar
   .nomenclature_id
   IF (ar.reference_range_factor_id != cas.reference_range_factor_id
    AND ar.nomenclature_id != cas.nomenclature_id)
    temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].dfn_null_ind = 1, temp->catalog_qual[d2.seq].
    alpha_qual[alpha_cntr].rf_null_ind = 1, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
    vli_null_ind = 1,
    temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].vlr_null_ind = 1
   ENDIF
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].service_resource_cd = cas.service_resource_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].service_resource_disp = captions->default
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  dta.mnemonic_key_cap, dfn_null_ind = nullind(cas.degrees_from_normal), rf_null_ind = nullind(cas
   .requeue_flag),
  vli_null_ind = nullind(cas.verify_level_is), vlr_null_ind = nullind(cas.verify_level_rs),
  srv_rsrce_disp_caps = cnvtupper(uar_get_code_display(cas.service_resource_cd))
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   (dummyt d2  WITH seq = value(size(temp->catalog_qual,5))),
   cyto_alpha_security cas,
   nomenclature n
  PLAN (d2)
   JOIN (dta
   WHERE (dta.mnemonic_key_cap=temp->catalog_qual[d2.seq].cap_diagnosis_disp))
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   JOIN (cas
   WHERE ar.reference_range_factor_id=cas.reference_range_factor_id
    AND ar.nomenclature_id=cas.nomenclature_id
    AND cas.definition_ind IN (0, 1)
    AND cas.service_resource_cd > 0.0)
  ORDER BY dta.mnemonic_key_cap, srv_rsrce_disp_caps, ar.sequence
  HEAD dta.mnemonic_key_cap
   alpha_cntr = size(temp->catalog_qual[d2.seq].alpha_qual,5)
  DETAIL
   alpha_cntr += 1
   IF (alpha_cntr > size(temp->catalog_qual[d2.seq].alpha_qual,5))
    stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,(alpha_cntr+ 9))
   ENDIF
   IF (alpha_cntr > max_alpha_cntr)
    max_alpha_cntr = alpha_cntr
   ENDIF
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].sequence = ar.sequence, temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].nomenclature_disp = n.mnemonic, temp->catalog_qual[d2.seq].
   alpha_qual[alpha_cntr].diagnostic_category_cd = cas.diagnostic_category_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].diagnostic_category_disp = uar_get_code_display(
    cas.diagnostic_category_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   requeue_service_resource_cd = cas.requeue_service_resource_cd, temp->catalog_qual[d2.seq].
   alpha_qual[alpha_cntr].requeue_service_resource_disp = uar_get_code_display(cas
    .requeue_service_resource_cd),
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].degrees_from_normal = cas.degrees_from_normal,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].requeue_flag = cas.requeue_flag, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].verify_level_is = cas.verify_level_is,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].verify_level_rs = cas.verify_level_rs, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].dfn_null_ind = dfn_null_ind, temp->catalog_qual[d2.seq
   ].alpha_qual[alpha_cntr].rf_null_ind = rf_null_ind,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].vli_null_ind = vli_null_ind, temp->catalog_qual[
   d2.seq].alpha_qual[alpha_cntr].vlr_null_ind = vlr_null_ind, temp->catalog_qual[d2.seq].alpha_qual[
   alpha_cntr].qa_flag_type_cd = cas.qa_flag_type_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].qa_flag_type_disp = uar_get_code_display(cas
    .qa_flag_type_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].nomenclature_id = ar
   .nomenclature_id, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].service_resource_cd = cas
   .service_resource_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].service_resource_disp = uar_get_code_display(cas
    .service_resource_cd)
  FOOT  dta.mnemonic_key_cap
   stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,alpha_cntr)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbCytoSec", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  alpha_sequence = temp->catalog_qual[d1.seq].alpha_qual[d2.seq].sequence, diagnsrvrsrcedispcaps =
  build(temp->catalog_qual[d1.seq].cap_diagnosis_disp,cnvtupper(temp->catalog_qual[d1.seq].
    alpha_qual[d2.seq].service_resource_disp))
  FROM (dummyt d1  WITH seq = value(size(temp->catalog_qual,5))),
   (dummyt d2  WITH seq = value(max_alpha_cntr))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->catalog_qual[d1.seq].alpha_qual,5))
  ORDER BY diagnsrvrsrcedispcaps, alpha_sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   col 0,
   CALL center(captions->pathnetap,0,132), col 110,
   captions->date, col 117, curdate"@SHORTDATE;;Q",
   row + 1, col 0, captions->directory,
   col 110, captions->ttime, col 117,
   curtime, row + 1, col 0,
   CALL center(captions->refdbaudit,0,132), col 112, captions->bby,
   col 117, request->scuruser"##############", row + 1,
   col 0,
   CALL center(captions->dbcast,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 1
   IF (no_cases_found="T")
    row + 10, col 0,
    CALL center(captions->noauditfound,0,132)
   ENDIF
  HEAD diagnsrvrsrcedispcaps
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->procedure,
   "  ", col 19, temp->catalog_qual[d1.seq].diagnosis_disp,
   row + 1, col 19, temp->catalog_qual[d1.seq].diagnosis_desc,
   row + 1, col 0, captions->svcresource,
   "  ", col 19, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].service_resource_disp,
   row + 1, col 68, captions->degrees,
   col 86, captions->requeue, col 97,
   captions->initial, col 105, captions->rescreener,
   col 116, captions->ccase, row + 1,
   col 68, captions->ffrom, col 76,
   captions->requeue, col 86, captions->service,
   col 97, captions->verify, col 105,
   captions->verify, col 116, captions->ttype,
   row + 1, col 0, captions->alpharesponse,
   col 27, captions->diagnosticcat, col 68,
   captions->normal, col 76, captions->flag,
   col 86, captions->resource, col 97,
   captions->level, col 105, captions->level,
   col 116, captions->flag, row + 1,
   col 0, "------------------------", col 27,
   "---------------------------------------", col 68, "-------",
   col 76, "---------", col 86,
   "----------", col 97, "-------",
   col 105, "----------", col 116,
   "-------------"
  DETAIL
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].nomenclature_disp
   "#########################",
   col 27, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].diagnostic_category_disp
   "########################################", col 68,
   "       "
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].dfn_null_ind=0))
    col 68, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].degrees_from_normal"##"
   ENDIF
   col 76, "         "
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].rf_null_ind=0))
    IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].requeue_flag=0))
     col 76, captions->none, "   "
    ELSEIF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].requeue_flag=1))
     col 76, captions->manual, "   "
    ELSEIF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].requeue_flag=2))
     col 76, captions->automatic
    ENDIF
   ENDIF
   col 86, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].requeue_service_resource_disp"##########",
   col 97,
   "       "
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].vli_null_ind=0))
    col 100, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].verify_level_is"##"
   ENDIF
   col 105, "          "
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].vlr_null_ind=0))
    col 109, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].verify_level_rs"##"
   ENDIF
   col 116, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].qa_flag_type_disp"##############"
  FOOT  diagnsrvrsrcedispcaps
   row + 1, row + 1, col 50,
   "* * * * * * * * *", row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
