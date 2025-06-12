CREATE PROGRAM aps_prt_db_cyto_report_params:dba
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
 DECLARE dgyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"GYN"))
 DECLARE dngyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"NGYN"))
 DECLARE ddefaultresulttype = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"2"))
 DECLARE ncatcntr = i4
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET a = "WHICH REPORT COMPONENT STORES THE CLINICAL INFORMATION SUBMITTED FOR THE PERSON/CASE:"
 SET b = "WHICH REPORT COMPONENT OFFERS CODED RESPONSE OPTIONS FOR THE DIAGNOSIS"
 SET c = "WHICH REPORT COMPONENT OFFERS CODED RESPONSE OPTIONS FOR SAMPLE QUALITY"
 SET d = "WHICH REPORT COMPONENT OFFERS CODED RESPONSE OPTIONS FOR SAMPLE QUALITY DEFICIENCIES"
 SET e = "WHICH REPORT COMPONENT OFFERS CODED RESPONSE OPTIONS FOR THE ENDOCERVICAL COMPONENT"
 SET i = "WHICH REPORT COMPONENT OFFERS CODED RESPONSE OPTIONS FOR FURTHER ACTION"
 SET f = "UNSATISFACTORY COLECTION TECHNIQUE PARAMETERS (ENDOCERVICAL CELLS):"
 SET g = "UNSATISFACTORY COLLECTION TECHNIQUE PARAMETERS (MICROSCOPIC EVAULATION):"
 RECORD captions(
   1 rptaps = vc
   1 pathnetap = vc
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbcytorptparam = vc
   1 ppage = vc
   1 procedure = vc
   1 reporttype = vc
   1 gyn = vc
   1 nongyn = vc
   1 rptaps4 = vc
   1 none = vc
   1 rptaps6 = vc
   1 rptaps7 = vc
   1 rptaps8 = vc
   1 rptaps9 = vc
   1 rptaps10 = vc
   1 pathnetap0 = vc
   1 alpharesponse = vc
   1 unsat = vc
   1 yes = vc
   1 no = vc
   1 pathnetap5 = vc
   1 samplequality = vc
   1 reasonrequired = vc
   1 sat = vc
   1 satlimited = vc
   1 na = vc
   1 continued = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1",
  "REPORT:  APS_PRT_DB_CYTO_REPORT_PARAMS.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbcytorptparam = uar_i18ngetmessage(i18nhandle,"h8",
  "DB CYTOLOGY REPORT PARAMETERS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"h10","PROCEDURE:")
 SET captions->reporttype = uar_i18ngetmessage(i18nhandle,"h11","REPORT TYPE:")
 SET captions->gyn = uar_i18ngetmessage(i18nhandle,"h12","GYN")
 SET captions->nongyn = uar_i18ngetmessage(i18nhandle,"h13","NON-GYN")
 SET captions->rptaps4 = uar_i18ngetmessage(i18nhandle,"h14",a)
 SET captions->none = uar_i18ngetmessage(i18nhandle,"h15","(none)")
 SET captions->rptaps6 = uar_i18ngetmessage(i18nhandle,"h16",b)
 SET captions->rptaps7 = uar_i18ngetmessage(i18nhandle,"h17",c)
 SET captions->rptaps8 = uar_i18ngetmessage(i18nhandle,"h18",d)
 SET captions->rptaps9 = uar_i18ngetmessage(i18nhandle,"h19",e)
 SET captions->pathnetap0 = uar_i18ngetmessage(i18nhandle,"h20",f)
 SET captions->alpharesponse = uar_i18ngetmessage(i18nhandle,"h21","ALPHA RESPONSE")
 SET captions->unsat = uar_i18ngetmessage(i18nhandle,"h22","UNSATISFACTORY?")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"h23","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"h24","NO")
 SET captions->pathnetap5 = uar_i18ngetmessage(i18nhandle,"h25",g)
 SET captions->samplequality = uar_i18ngetmessage(i18nhandle,"h26","SAMPLE QUALITY?")
 SET captions->reasonrequired = uar_i18ngetmessage(i18nhandle,"h27","REASON REQUIRED?")
 SET captions->sat = uar_i18ngetmessage(i18nhandle,"h28","SATISFACTORY")
 SET captions->satlimited = uar_i18ngetmessage(i18nhandle,"h29","SATISFACTORY, LIMITED")
 SET captions->na = uar_i18ngetmessage(i18nhandle,"h31","N/A")
 SET captions->rptaps10 = uar_i18ngetmessage(i18nhandle,"h32",i)
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 max_endo_cntr = i4
   1 max_adeq_cntr = i4
   1 qual[*]
     2 print_on_report = c1
     2 catalog_cd = f8
     2 primary_mnemonic = c100
     2 report_desc = c100
     2 report_type = i2
     2 clin_info_task_assay_cd = f8
     2 clin_info_task_assay_desc = c100
     2 diagnosis_cd = f8
     2 diagnosis_desc = c100
     2 adequacy_cd = f8
     2 adequacy_desc = c100
     2 endocerv_cd = f8
     2 endocerv_desc = c100
     2 endo_cntr = i4
     2 action_task_assay_cd = f8
     2 action_task_assay_desc = c100
     2 e_alpha_qual[*]
       3 nomenclature_id = f8
       3 nomenclature_mnemonic = c25
       3 endocerv_ind = i2
     2 adeq_reason_task_assay_cd = f8
     2 adeq_reason_task_assay_desc = c100
     2 adeq_cntr = i4
     2 a_alpha_qual[*]
       3 nomenclature_id = f8
       3 nomenclature_mnemonic = c25
       3 reason_required_ind = i2
       3 adequacy_flag = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
 SET reply->status_data.status = "F"
 SET ncatcntr = 0
 SELECT DISTINCT INTO "nl:"
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o.primary_mnemonic, o.description
  FROM prefix_report_r p,
   ap_prefix a,
   order_catalog o,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (a
   WHERE a.case_type_cd IN (dgyn, dngyn)
    AND a.active_ind=1)
   JOIN (p
   WHERE a.prefix_id=p.prefix_id)
   JOIN (o
   WHERE o.catalog_cd=p.catalog_cd
    AND o.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ptr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1
    AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND dta.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND dta.default_result_type_cd=ddefaultresulttype)
  DETAIL
   ncatcntr = (ncatcntr+ 1)
   IF (ncatcntr > size(temp->qual,5))
    stat = alterlist(temp->qual,(ncatcntr+ 9))
   ENDIF
   temp->qual[ncatcntr].catalog_cd = o.catalog_cd, temp->qual[ncatcntr].primary_mnemonic = o
   .primary_mnemonic, temp->qual[ncatcntr].report_desc = o.description
  FOOT REPORT
   stat = alterlist(temp->qual,ncatcntr)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  catalog_cd = temp->qual[d1.seq].catalog_cd, join_path = decode(cear.seq,"A",caar.seq,"B"," "),
  mnemonic = decode(cear.seq,n2.mnemonic,caar.seq,n1.mnemonic," "),
  cear.nomenclature_id, caar.nomenclature_id
  FROM cyto_report_control crc,
   (dummyt d3  WITH seq = 1),
   cyto_endocerv_alpha_r cear,
   (dummyt d4  WITH seq = 1),
   cyto_adequacy_alpha_r caar,
   (dummyt d1  WITH seq = value(size(temp->qual,5))),
   nomenclature n1,
   nomenclature n2
  PLAN (d1)
   JOIN (crc
   WHERE (crc.catalog_cd=temp->qual[d1.seq].catalog_cd))
   JOIN (((d3
   WHERE 1=d3.seq)
   JOIN (cear
   WHERE crc.catalog_cd=cear.catalog_cd
    AND crc.endocerv_task_assay_cd=cear.task_assay_cd)
   JOIN (n2
   WHERE cear.nomenclature_id=n2.nomenclature_id)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (caar
   WHERE crc.catalog_cd=caar.catalog_cd
    AND crc.adequacy_task_assay_cd=caar.task_assay_cd)
   JOIN (n1
   WHERE caar.nomenclature_id=n1.nomenclature_id)
   ))
  ORDER BY catalog_cd, mnemonic
  HEAD REPORT
   endo_cntr = 0, alpha_cntr = 0
  HEAD catalog_cd
   temp->qual[d1.seq].print_on_report = "Y", temp->qual[d1.seq].report_type = crc.report_type_flag,
   temp->qual[d1.seq].endocerv_cd = crc.endocerv_task_assay_cd,
   temp->qual[d1.seq].action_task_assay_cd = crc.action_task_assay_cd, temp->qual[d1.seq].
   diagnosis_cd = crc.diagnosis_task_assay_cd, temp->qual[d1.seq].adequacy_cd = crc
   .adequacy_task_assay_cd,
   temp->qual[d1.seq].adeq_reason_task_assay_cd = crc.adeq_reason_task_assay_cd, temp->qual[d1.seq].
   clin_info_task_assay_cd = crc.clin_info_task_assay_cd, endo_cntr = 0,
   adeq_cntr = 0
  DETAIL
   CASE (join_path)
    OF "A":
     endo_cntr = (endo_cntr+ 1),stat = alterlist(temp->qual[d1.seq].e_alpha_qual,endo_cntr),
     IF ((endo_cntr > temp->max_endo_cntr))
      temp->max_endo_cntr = endo_cntr
     ENDIF
     ,temp->qual[d1.seq].endo_cntr = endo_cntr,temp->qual[d1.seq].e_alpha_qual[endo_cntr].
     nomenclature_id = cear.nomenclature_id,temp->qual[d1.seq].e_alpha_qual[endo_cntr].endocerv_ind
      = cear.endocerv_ind,
     temp->qual[d1.seq].e_alpha_qual[endo_cntr].nomenclature_mnemonic = n2.mnemonic
    OF "B":
     adeq_cntr = (adeq_cntr+ 1),stat = alterlist(temp->qual[d1.seq].a_alpha_qual,adeq_cntr),
     IF ((adeq_cntr > temp->max_adeq_cntr))
      temp->max_adeq_cntr = adeq_cntr
     ENDIF
     ,temp->qual[d1.seq].adeq_cntr = adeq_cntr,temp->qual[d1.seq].a_alpha_qual[adeq_cntr].
     nomenclature_id = caar.nomenclature_id,temp->qual[d1.seq].a_alpha_qual[adeq_cntr].adequacy_flag
      = caar.adequacy_flag,
     temp->qual[d1.seq].a_alpha_qual[adeq_cntr].reason_required_ind = caar.reason_required_ind,temp->
     qual[d1.seq].a_alpha_qual[adeq_cntr].nomenclature_mnemonic = n1.mnemonic
   ENDCASE
  WITH outerjoin = d3, outerjoin = d4, nocounter
 ;end select
 SELECT INTO "nl:"
  dta.description, endocerv = temp->qual[d1.seq].endocerv_cd, diagnosis = temp->qual[d1.seq].
  diagnosis_cd,
  adequacy = temp->qual[d1.seq].adequacy_cd, adeq_reason = temp->qual[d1.seq].
  adeq_reason_task_assay_cd, clin_info = temp->qual[d1.seq].clin_info_task_assay_cd,
  action = temp->qual[d1.seq].action_task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1)
   JOIN (dta
   WHERE dta.task_assay_cd IN (temp->qual[d1.seq].endocerv_cd, temp->qual[d1.seq].diagnosis_cd, temp
   ->qual[d1.seq].adequacy_cd, temp->qual[d1.seq].adeq_reason_task_assay_cd, temp->qual[d1.seq].
   clin_info_task_assay_cd,
   temp->qual[d1.seq].action_task_assay_cd)
    AND dta.task_assay_cd != 0.0)
  DETAIL
   IF ((dta.task_assay_cd=temp->qual[d1.seq].endocerv_cd))
    temp->qual[d1.seq].endocerv_desc = dta.description
   ENDIF
   IF ((dta.task_assay_cd=temp->qual[d1.seq].action_task_assay_cd))
    temp->qual[d1.seq].action_task_assay_desc = dta.description
   ENDIF
   IF ((dta.task_assay_cd=temp->qual[d1.seq].diagnosis_cd))
    temp->qual[d1.seq].diagnosis_desc = dta.description
   ENDIF
   IF ((dta.task_assay_cd=temp->qual[d1.seq].adequacy_cd))
    temp->qual[d1.seq].adequacy_desc = dta.description
   ENDIF
   IF ((dta.task_assay_cd=temp->qual[d1.seq].adeq_reason_task_assay_cd))
    temp->qual[d1.seq].adeq_reason_task_assay_desc = dta.description
   ENDIF
   IF ((dta.task_assay_cd=temp->qual[d1.seq].clin_info_task_assay_cd))
    temp->qual[d1.seq].clin_info_task_assay_desc = dta.description
   ENDIF
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbCytoRptParm", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  report_short_desc = temp->qual[d1.seq].primary_mnemonic, report_long_desc = temp->qual[d1.seq].
  report_desc
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1
   WHERE (temp->qual[d1.seq].print_on_report="Y"))
  ORDER BY report_short_desc
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathnetap,0,132), col 110, captions->date,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbcytorptparam,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
  HEAD report_short_desc
   row + 1, col 0, captions->procedure,
   col 12, report_short_desc, row + 1,
   col 12, report_long_desc, row + 2,
   col 12, captions->reporttype
   IF ((temp->qual[d1.seq].report_type=1))
    col 26, captions->gyn
   ENDIF
   IF ((temp->qual[d1.seq].report_type=2))
    col 26, captions->nongyn
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 12, captions->rptaps4,
   "  "
   IF (textlen(trim(temp->qual[d1.seq].clin_info_task_assay_desc)) > 0)
    col 99, temp->qual[d1.seq].clin_info_task_assay_desc"##############################"
   ELSE
    col 99, captions->none
   ENDIF
   row + 2, col 12, captions->rptaps6,
   "  "
   IF (textlen(trim(temp->qual[d1.seq].diagnosis_desc)) > 0)
    col 84, temp->qual[d1.seq].diagnosis_desc"##########################################"
   ELSE
    col 84, captions->none
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 12, captions->rptaps7,
   "  "
   IF (textlen(trim(temp->qual[d1.seq].adequacy_desc)) > 0)
    col 85, temp->qual[d1.seq].adequacy_desc"##############################################"
   ELSE
    col 85, captions->none
   ENDIF
   row + 2, col 12, captions->rptaps8,
   "  "
   IF (textlen(trim(temp->qual[d1.seq].adeq_reason_task_assay_desc)) > 0)
    col 99, temp->qual[d1.seq].adeq_reason_task_assay_desc"################################"
   ELSE
    col 99, captions->none
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   IF ((temp->qual[d1.seq].report_type=1))
    row + 2, col 12, captions->rptaps9,
    "  "
    IF (textlen(trim(temp->qual[d1.seq].endocerv_desc)) > 0)
     col 98, temp->qual[d1.seq].endocerv_desc"#################################"
    ELSE
     col 98, captions->none
    ENDIF
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 12, captions->rptaps10,
   "  "
   IF (textlen(trim(temp->qual[d1.seq].action_task_assay_desc)) > 0)
    col 98, temp->qual[d1.seq].action_task_assay_desc"#############################"
   ELSE
    col 98, captions->none
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   IF ((temp->qual[d1.seq].report_type=1))
    row + 2, col 12, captions->pathnetap0,
    row + 2, col 14, captions->alpharesponse,
    col 42, captions->unsat, row + 1,
    col 14, "--------------------------", col 42,
    "---------------"
    FOR (loop1 = 1 TO size(temp->qual[d1.seq].e_alpha_qual,5))
      row + 1, col 14, temp->qual[d1.seq].e_alpha_qual[loop1].nomenclature_mnemonic,
      col 42
      IF ((temp->qual[d1.seq].e_alpha_qual[loop1].endocerv_ind=1))
       captions->yes
      ELSE
       captions->no
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 12, captions->pathnetap5,
   row + 2, col 14, captions->alpharesponse,
   col 42, captions->samplequality, "      ",
   col 65, captions->reasonrequired, row + 1,
   col 14, "--------------------------", col 42,
   "---------------------", col 65, "----------------"
   FOR (loop1 = 1 TO size(temp->qual[d1.seq].a_alpha_qual,5))
     row + 1, col 14, temp->qual[d1.seq].a_alpha_qual[loop1].nomenclature_mnemonic,
     col 42
     IF ((temp->qual[d1.seq].a_alpha_qual[loop1].adequacy_flag=0))
      captions->sat
     ENDIF
     IF ((temp->qual[d1.seq].a_alpha_qual[loop1].adequacy_flag=1))
      captions->satlimited
     ENDIF
     IF ((temp->qual[d1.seq].a_alpha_qual[loop1].adequacy_flag=2))
      captions->unsat
     ENDIF
     IF (textlen(trim(temp->qual[d1.seq].adeq_reason_task_assay_desc)) > 0)
      col 65
      IF ((temp->qual[d1.seq].a_alpha_qual[loop1].reason_required_ind=1))
       captions->yes
      ELSE
       captions->no
      ENDIF
     ELSE
      col 65, captions->na
     ENDIF
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
   ENDFOR
   row + 1,
   CALL center("* * * * * * * * * *",0,132), row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
