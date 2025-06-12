CREATE PROGRAM bed_aud_mic_report_ana_loinc:dba
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
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD serv_res_hier_req(
   1 activity_type_cd = f8
 )
 RECORD serv_res_hier_rep(
   1 institutions[*]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 service_resource_mean = c12
     2 departments[*]
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 service_resource_mean = c12
       3 sections[*]
         4 service_resource_cd = f8
         4 service_resource_disp = vc
         4 service_resource_mean = c12
         4 subsections[*]
           5 service_resource_cd = f8
           5 service_resource_disp = vc
           5 service_resource_mean = c12
           5 instr_benchs[*]
             6 service_resource_cd = f8
             6 service_resource_disp = vc
             6 service_resource_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD serv_res(
   1 list[*]
     2 service_resource_cd = f8
 )
 DECLARE add_service_resource_item(service_resource_cd=f8) = null
 DECLARE sub_piece(string=vc,delim=vc,num=i4,default=vc) = vc
 DECLARE inst_cnt = i4 WITH private, noconstant(0)
 DECLARE dept_cnt = i4 WITH private, noconstant(0)
 DECLARE sec_cnt = i4 WITH private, noconstant(0)
 DECLARE subsec_cnt = i4 WITH private, noconstant(0)
 DECLARE instr_bench_cnt = i4 WITH private, noconstant(0)
 DECLARE sr_cnt = i4 WITH protect, noconstant(0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE i18n_handle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH private, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH private, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   row_cnt = count(cimr.concept_ident_mic_rpt_id)
   FROM concept_ident_mic_rpt cimr
   WHERE cimr.concept_ident_mic_rpt_id > 0.0
    AND cimr.concept_type_flag=1
    AND cimr.active_ind=1
    AND cimr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cimr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   HEAD PAGE
    high_volume_cnt = row_cnt
   FOOT PAGE
    row + 0
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,23)
 SET reply->collist[1].header_text = uar_i18ngetmessage(i18n_handle,"ServiceResource",
  "Service Resource")
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = uar_i18ngetmessage(i18n_handle,"OrderCatalogItem",
  "Order Catalog Item")
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = uar_i18ngetmessage(i18n_handle,"ReportName","Report Name")
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = uar_i18ngetmessage(i18n_handle,"OrganismType","Organism Type")
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = uar_i18ngetmessage(i18n_handle,"Source","Source")
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = uar_i18ngetmessage(i18n_handle,"IgnoreAnalyte",
  "Ignore Analyte Code")
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteCode","Analyte Code")
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteComponent",
  "Analyte Component")
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteMethod","Analyte Method")
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteSystem","Analyte System"
  )
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteShortName",
  "Analyte Short Name")
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteProperty",
  "Analyte Property")
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteScale","Analyte Scale")
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteTime","Analyte Time")
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteClass","Analyte Class")
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteConceptCKI",
  "Analyte Concept CKI")
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteAssignUser",
  "Analyte Assign User")
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteAssignDateTime",
  "Analyte Assign Date/Time")
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = uar_i18ngetmessage(i18n_handle,"ServiceResourceCode",
  "Service Resource Code")
 SET reply->collist[19].data_type = 2
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = uar_i18ngetmessage(i18n_handle,"OrderCatalogItemCode",
  "Order Catalog Item Code")
 SET reply->collist[20].data_type = 2
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = uar_i18ngetmessage(i18n_handle,"ReportNameCode",
  "Report Name Code")
 SET reply->collist[21].data_type = 2
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = uar_i18ngetmessage(i18n_handle,"OrganismTypeValue",
  "Organism Type Value")
 SET reply->collist[22].data_type = 3
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = uar_i18ngetmessage(i18n_handle,"SourceCode","Source Code")
 SET reply->collist[23].data_type = 2
 SET reply->collist[23].hide_ind = 0
 SET serv_res_hier_req->activity_type_cd = uar_get_code_by("MEANING",106,"MICROBIOLOGY")
 EXECUTE bed_get_serv_res_hier  WITH replace("REQUEST","SERV_RES_HIER_REQ"), replace("REPLY",
  "SERV_RES_HIER_REP")
 CALL add_service_resource_item(0.0)
 FOR (inst_cnt = 1 TO size(serv_res_hier_rep->institutions,5))
  CALL add_service_resource_item(serv_res_hier_rep->institutions[inst_cnt].service_resource_cd)
  FOR (dept_cnt = 1 TO size(serv_res_hier_rep->institutions[inst_cnt].departments,5))
   CALL add_service_resource_item(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt].
    service_resource_cd)
   FOR (sec_cnt = 1 TO size(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt].sections,
    5))
    CALL add_service_resource_item(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt].
     sections[sec_cnt].service_resource_cd)
    FOR (subsec_cnt = 1 TO size(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt].
     sections[sec_cnt].subsections,5))
     CALL add_service_resource_item(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt].
      sections[sec_cnt].subsections[subsec_cnt].service_resource_cd)
     FOR (instr_bench_cnt = 1 TO size(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt]
      .sections[sec_cnt].subsections[subsec_cnt].instr_benchs,5))
       CALL add_service_resource_item(serv_res_hier_rep->institutions[inst_cnt].departments[dept_cnt]
        .sections[sec_cnt].subsections[subsec_cnt].instr_benchs[instr_bench_cnt].service_resource_cd)
     ENDFOR
    ENDFOR
   ENDFOR
  ENDFOR
 ENDFOR
 SET cur_size = size(serv_res->list,5)
 IF (cur_size < 100)
  SET batch_size = cur_size
 ELSE
  SET batch_size = 100
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET start = 1
 SET stat = alterlist(serv_res->list,new_size)
 FOR (idx = (cur_size+ 1) TO new_size)
   SET serv_res->list[idx].service_resource_cd = serv_res->list[cur_size].service_resource_cd
 ENDFOR
 SELECT INTO "nl:"
  pos = locateval(idx,1,size(serv_res->list,5),cimr.service_resource_cd,serv_res->list[idx].
   service_resource_cd)
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   concept_ident_mic_rpt cimr,
   nomenclature n,
   prsnl p
  PLAN (d
   WHERE initarray(start,evaluate(d.seq,1,1,(start+ batch_size))))
   JOIN (cimr
   WHERE expand(idx,start,((start+ batch_size) - 1),cimr.service_resource_cd,serv_res->list[idx].
    service_resource_cd)
    AND cimr.concept_type_flag=1
    AND cimr.active_ind=1
    AND cimr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cimr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE ((n.concept_cki=cimr.concept_cki
    AND n.concept_cki != " "
    AND n.primary_vterm_ind=1
    AND n.disallowed_ind=0
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.nomenclature_id=0.0)) )
   JOIN (p
   WHERE p.person_id=cimr.updt_id)
  ORDER BY pos, build(cnvtupper(uar_get_code_display(cimr.catalog_cd)),cimr.catalog_cd), build(
    uar_get_code_display(cimr.task_cd),cimr.task_cd),
   cimr.org_class_flag, build(cnvtupper(uar_get_code_display(cimr.source_cd)),cimr.source_cd)
  HEAD REPORT
   row_nbr = 0
  DETAIL
   IF (((n.nomenclature_id > 0) OR (cimr.ignore_ind=1)) )
    row_nbr = (row_nbr+ 1)
    IF (mod(row_nbr,500)=1)
     stat = alterlist(reply->rowlist,(row_nbr+ 499))
    ENDIF
    stat = alterlist(reply->rowlist[row_nbr].celllist,23)
    IF (cimr.service_resource_cd=0)
     reply->rowlist[row_nbr].celllist[1].string_value = uar_i18ngetmessage(i18n_handle,"All","All")
    ELSE
     reply->rowlist[row_nbr].celllist[1].string_value = uar_get_code_display(cimr.service_resource_cd
      )
    ENDIF
    reply->rowlist[row_nbr].celllist[2].string_value = uar_get_code_display(cimr.catalog_cd)
    IF (cimr.task_cd > 0.0)
     reply->rowlist[row_nbr].celllist[3].string_value = uar_get_code_display(cimr.task_cd)
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = uar_i18ngetmessage(i18n_handle,"NonStain",
      "Non-stain")
    ENDIF
    CASE (cimr.org_class_flag)
     OF 1:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,"Bacteria",
       "Bacteria")
     OF 2:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,
       "Mycobacteria","Mycobacteria")
     OF 3:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,"Fungus",
       "Fungus")
     OF 4:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,"Parasite",
       "Parasite")
     OF 5:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,"Virus",
       "Virus")
     OF 6:
      reply->rowlist[row_nbr].celllist[4].string_value = uar_i18ngetmessage(i18n_handle,"Yeast",
       "Yeast")
     ELSE
      reply->rowlist[row_nbr].celllist[4].string_value = ""
    ENDCASE
    reply->rowlist[row_nbr].celllist[5].string_value = uar_get_code_display(cimr.source_cd)
    IF (cimr.ignore_ind=1)
     reply->rowlist[row_nbr].celllist[6].string_value = uar_i18ngetmessage(i18n_handle,"Yes","Yes")
    ENDIF
    IF (n.nomenclature_id > 0.0)
     reply->rowlist[row_nbr].celllist[7].string_value = n.source_identifier, reply->rowlist[row_nbr].
     celllist[8].string_value = sub_piece(n.source_string,":",1,""), reply->rowlist[row_nbr].
     celllist[9].string_value = sub_piece(n.source_string,":",6,""),
     reply->rowlist[row_nbr].celllist[10].string_value = sub_piece(n.source_string,":",4,""), reply->
     rowlist[row_nbr].celllist[11].string_value = n.short_string, reply->rowlist[row_nbr].celllist[12
     ].string_value = sub_piece(n.source_string,":",2,""),
     reply->rowlist[row_nbr].celllist[13].string_value = sub_piece(n.source_string,":",5,""), reply->
     rowlist[row_nbr].celllist[14].string_value = sub_piece(n.source_string,":",3,""), reply->
     rowlist[row_nbr].celllist[15].string_value = uar_get_code_display(n.vocab_axis_cd),
     reply->rowlist[row_nbr].celllist[16].string_value = n.concept_cki
    ENDIF
    reply->rowlist[row_nbr].celllist[17].string_value = p.name_full_formatted, reply->rowlist[row_nbr
    ].celllist[18].string_value = format(cnvtdatetime(cimr.updt_dt_tm),"@SHORTDATETIME"), reply->
    rowlist[row_nbr].celllist[19].double_value = cimr.service_resource_cd,
    reply->rowlist[row_nbr].celllist[20].double_value = cimr.catalog_cd, reply->rowlist[row_nbr].
    celllist[21].double_value = cimr.task_cd, reply->rowlist[row_nbr].celllist[22].nbr_value = cimr
    .org_class_flag,
    reply->rowlist[row_nbr].celllist[23].double_value = cimr.source_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,row_nbr)
  WITH nocounter
 ;end select
 SUBROUTINE add_service_resource_item(service_resource_cd)
   SET sr_cnt = (sr_cnt+ 1)
   IF (mod(sr_cnt,25)=1)
    SET stat = alterlist(serv_res->list,(sr_cnt+ 24))
   ENDIF
   SET serv_res->list[sr_cnt].service_resource_cd = service_resource_cd
 END ;Subroutine
 SUBROUTINE sub_piece(string,delim,num,default)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE beginning = i4 WITH protect, noconstant(0)
   DECLARE ending = i4 WITH protect, noconstant(0)
   IF (num <= 0)
    RETURN("")
   ENDIF
   FOR (cnt = 1 TO num)
     SET beginning = (ending+ 1)
     SET ending = findstring(delim,string,beginning)
     IF (ending=0)
      IF (cnt < num)
       RETURN(default)
      ENDIF
      SET ending = (size(trim(string))+ beginning)
     ENDIF
   ENDFOR
   RETURN(substring(beginning,(ending - beginning),string))
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = "mic_report_ana_loinc_assoc.csv"
 ENDIF
 IF (size(trim(request->output_filename)) > 0)
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
