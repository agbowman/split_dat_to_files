CREATE PROGRAM aps_prt_db_processing_tasks:dba
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
   1 apsrpt = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbproctasktool = vc
   1 ppage = vc
   1 stained = vc
   1 pathnetap = vc
   1 half = vc
   1 pprint = vc
   1 task = vc
   1 description = vc
   1 inventory = vc
   1 association = vc
   1 slideorigin = vc
   1 slide = vc
   1 label = vc
   1 none = vc
   1 block = vc
   1 slide = vc
   1 slide2 = vc
   1 blockandslide = vc
   1 specimen = vc
   1 yes = vc
   1 autoverify = vc
   1 step = vc
   1 continued = vc
   1 processingtasks = vc
   1 instrumentprotocols = vc
   1 instrumenttype = vc
   1 protocoldescript = vc
   1 active = vc
   1 universal = vc
   1 template = vc
   1 plcrsupplement = vc
   1 srvcinformation = vc
   1 srvcidentifier = vc
   1 assignedipandtype = vc
   1 assignedtasks = vc
   1 noinstrmtprotcldefined = vc
   1 no = vc
   1 endofreport = vc
   1 noinstrmttypedefined = vc
   1 noproctasksdefined = vc
   1 prefixes = vc
   1 siteprefix = vc
   1 processingtask = vc
   1 noprefixesdefined = vc
 )
 SET captions->apsrpt = uar_i18ngetmessage(i18nhandle,"h1","REPORT: APS_PRT_DB_PROCESSING_TASKS.PRG")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h2","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h3","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h4","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h5","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->dbproctasktool = uar_i18ngetmessage(i18nhandle,"h7","DB PROCESSING TASKS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->stained = uar_i18ngetmessage(i18nhandle,"h9","STAINED")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h10","PATHNET ANATOMIC PATHOLOGY")
 SET captions->half = uar_i18ngetmessage(i18nhandle,"h11","HALF")
 SET captions->pprint = uar_i18ngetmessage(i18nhandle,"h12","PRINT")
 SET captions->task = uar_i18ngetmessage(i18nhandle,"h13","TASK")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h14","DESCRIPTION")
 SET captions->inventory = uar_i18ngetmessage(i18nhandle,"h15","INVENTORY")
 SET captions->association = uar_i18ngetmessage(i18nhandle,"h16","ASSOCIATION")
 SET captions->slideorigin = uar_i18ngetmessage(i18nhandle,"h17","ORIGIN")
 SET captions->slide = uar_i18ngetmessage(i18nhandle,"h18","SLIDE")
 SET captions->label = uar_i18ngetmessage(i18nhandle,"h19","LABEL")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"d1","(none)")
 SET captions->block = uar_i18ngetmessage(i18nhandle,"d2","Block")
 SET captions->slide = uar_i18ngetmessage(i18nhandle,"d3","SLIDE")
 SET captions->slide2 = uar_i18ngetmessage(i18nhandle,"d3","Slide")
 SET captions->blockandslide = uar_i18ngetmessage(i18nhandle,"d4","Block and Slide")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"d5","Specimen")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"d6","YES")
 SET captions->autoverify = uar_i18ngetmessage(i18nhandle,"h20","AUTOVERIFY")
 SET captions->step = uar_i18ngetmessage(i18nhandle,"h21","STEP")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->processingtasks = uar_i18ngetmessage(i18nhandle,"h20","PROCESSING TASKS")
 SET captions->instrumentprotocols = uar_i18ngetmessage(i18nhandle,"h21","INSTRUMENT PROTOCOLS")
 SET captions->instrumenttype = uar_i18ngetmessage(i18nhandle,"h22","INSTRUMENT TYPE:")
 SET captions->protocoldescript = uar_i18ngetmessage(i18nhandle,"h23","PROTOCOL DESCRIPTION")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"h24","ACTIVE")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"d7","NO")
 SET captions->universal = uar_i18ngetmessage(i18nhandle,"h25","UNIVERSAL")
 SET captions->template = uar_i18ngetmessage(i18nhandle,"h26","TEMPLATE")
 SET captions->plcrsupplement = uar_i18ngetmessage(i18nhandle,"h27","PLACER SUPPLEMENT")
 SET captions->srvcinformation = uar_i18ngetmessage(i18nhandle,"h28","SERVICE INFORMATION")
 SET captions->srvcidentifier = uar_i18ngetmessage(i18nhandle,"h29","SERVICE IDENTIFIER")
 SET captions->assignedipandtype = uar_i18ngetmessage(i18nhandle,"h30",
  "ASSIGNED INSTRUMENT PROTOCOL (INSTRUMENT TYPE):")
 SET captions->assignedtasks = uar_i18ngetmessage(i18nhandle,"h31","ASSIGNED TASKS:")
 SET captions->noinstrmtprotcldefined = uar_i18ngetmessage(i18nhandle,"d8",
  "***NO INSTRUMENT PROTOCOLS ARE DEFINED FOR THIS INSTRUMENT TYPE***")
 SET captions->endofreport = uar_i18ngetmessage(i18nhandle,"f2","END OF REPORT...")
 SET captions->noinstrmttypedefined = uar_i18ngetmessage(i18nhandle,"d9",
  "***NO INSTRUMENT TYPES ARE DEFINED***")
 SET captions->noproctasksdefined = uar_i18ngetmessage(i18nhandle,"d10",
  "***NO PROCESSING TASKS ARE DEFINED***")
 SET captions->prefixes = uar_i18ngetmessage(i18nhandle,"h32","PREFIXES")
 SET captions->siteprefix = uar_i18ngetmessage(i18nhandle,"h33","Site/Prefix:")
 SET captions->processingtask = uar_i18ngetmessage(i18nhandle,"h34","PROCESSING TASK")
 SET captions->noprefixesdefined = uar_i18ngetmessage(i18nhandle,"d11",
  "***NO PREFIXES ARE DEFINED***")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c14
     2 task_assay_disp_caps = c14
     2 task_assay_desc = c40
     2 create_inventory_flag = i2
     2 task_type_flag = i2
     2 slide_origin_flag = i2
     2 stain_ind = i2
     2 half_slide_ind = i2
     2 print_label_ind = i2
     2 instr_cnt = i4
     2 instr_list[*]
       3 instr_type_disp = c40
       3 protocol_name = c40
     2 autoverify_workflow_cd = f8
     2 autoverify_workflow_disp = c10
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
 RECORD instrument_list(
   1 instrument_type_list[*]
     2 instrument_type_cd = f8
     2 instrument_type_disp = c40
     2 instrument_protocol_list[*]
       3 instrument_protocol_id = f8
       3 instrument_type_cd = f8
       3 protocol_name = vc
       3 universal_service_ident = vc
       3 placer_field_1 = vc
       3 supp_service_info = vc
       3 active_ind = i2
       3 task_cnt = i4
       3 task_list[*]
         4 task_assay_disp = c40
     2 instrmt_prtcl_size = i4
   1 instrmt_type_size = i4
 )
 RECORD prefix_list(
   1 prefix[*]
     2 prefix_id = f8
     2 prefix_name = c2
     2 prefix_desc = c40
     2 site_disp = c40
     2 task_count = i4
     2 task[*]
       3 task_assay_disp = c40
       3 task_assay_desc = c60
   1 prefix_count = i4
 )
 DECLARE ap_process_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE lvindex1 = i4 WITH protect, noconstant(0)
 DECLARE lvindex2 = i4 WITH protect, noconstant(0)
 DECLARE temp_cnt = i4 WITH protect, noconstant(0)
 DECLARE instr_task_cnt = i4 WITH protect, noconstant(0)
 DECLARE instr_type_cnt = i4 WITH protect, noconstant(0)
 DECLARE instr_prtcl_cnt = i4 WITH protect, noconstant(0)
 DECLARE instr_display = vc WITH protect, noconstant(" ")
 DECLARE is_active = vc WITH protect, noconstant(" ")
 DECLARE prtcl_name = vc WITH protect, noconstant(" ")
 DECLARE unvrsl_srvc_ident = vc WITH protect, noconstant(" ")
 DECLARE plcr_fld_1 = vc WITH protect, noconstant(" ")
 DECLARE supp_srvc_info = vc WITH protect, noconstant(" ")
 DECLARE proc_last_row = i2 WITH protect, noconstant(0)
 DECLARE last_row = i2 WITH protect, noconstant(0)
 DECLARE proc_last_page = i2 WITH protect, noconstant(0)
 DECLARE actual_page = i2 WITH protect, noconstant(0)
 DECLARE prev_col = i2 WITH protect, noconstant(0)
 DECLARE breaked = c1 WITH protect, noconstant("N")
 DECLARE instr_sect_contd = c1 WITH protect, noconstant("N")
 DECLARE instr_header_compltd = c1 WITH protect, noconstant("N")
 DECLARE lrep200001count = i4 WITH protect, noconstant(0)
 DECLARE lrep200001index = i4 WITH protect, noconstant(0)
 DECLARE lprefixindex = i4 WITH protect, noconstant(0)
 DECLARE lprefixtaskcount = i4 WITH protect, noconstant(0)
 DECLARE prefix_sect_contd = c1 WITH protect, noconstant("N")
 DECLARE prefix_header_completed = c1 WITH protect, noconstant("N")
 DECLARE ssiteprefixdisp = vc WITH protect, noconstant(" ")
 DECLARE sprefixdescdisp = vc WITH protect, noconstant(" ")
 DECLARE staskdisp = vc WITH protect, noconstant(" ")
 DECLARE staskdesc = vc WITH protect, noconstant(" ")
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 IF ((validate(dq_parser_rec->buffer_count,- (99))=- (99)))
  CALL echo("*****inside pm_dynamic_query include file *****")
  FREE RECORD dq_parser_rec
  RECORD dq_parser_rec(
    1 buffer_count = i2
    1 plan_count = i2
    1 set_count = i2
    1 table_count = i2
    1 with_count = i2
    1 buffer[*]
      2 line = vc
  )
  SET dq_parser_rec->buffer_count = 0
  SET dq_parser_rec->plan_count = 0
  SET dq_parser_rec->set_count = 0
  SET dq_parser_rec->table_count = 0
  SET dq_parser_rec->with_count = 0
  DECLARE dq_add_detail(dqad_dummy) = null
  DECLARE dq_add_footer(dqaf_target) = null
  DECLARE dq_add_header(dqah_target) = null
  DECLARE dq_add_line(dqal_line) = null
  DECLARE dq_get_line(dqgl_idx) = vc
  DECLARE dq_upt_line(dqul_idx,dqul_line) = null
  DECLARE dq_add_planjoin(dqap_range) = null
  DECLARE dq_add_set(dqas_to,dqas_from) = null
  DECLARE dq_add_table(dqat_table_name,dqat_table_alias) = null
  DECLARE dq_add_with(dqaw_control_option) = null
  DECLARE dq_begin_insert(dqbi_dummy) = null
  DECLARE dq_begin_select(dqbs_distinct_ind,dqbs_output_device) = null
  DECLARE dq_begin_update(dqbu_dummy) = null
  DECLARE dq_echo_query(dqeq_level) = null
  DECLARE dq_end_query(dqes_dummy) = null
  DECLARE dq_execute(dqe_reset) = null
  DECLARE dq_reset_query(dqrb_dummy) = null
  SUBROUTINE dq_add_detail(dqad_dummy)
    CALL dq_add_line("detail")
  END ;Subroutine
  SUBROUTINE dq_add_footer(dqaf_target)
    IF (size(trim(dqaf_target),1) > 0)
     CALL dq_add_line(concat("foot ",dqaf_target))
    ELSE
     CALL dq_add_line("foot report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_header(dqah_target)
    IF (size(trim(dqah_target),1) > 0)
     CALL dq_add_line(concat("head ",dqah_target))
    ELSE
     CALL dq_add_line("head report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_line(dqal_line)
    SET dq_parser_rec->buffer_count += 1
    IF (mod(dq_parser_rec->buffer_count,10)=1)
     SET stat = alterlist(dq_parser_rec->buffer,(dq_parser_rec->buffer_count+ 9))
    ENDIF
    SET dq_parser_rec->buffer[dq_parser_rec->buffer_count].line = trim(dqal_line,3)
  END ;Subroutine
  SUBROUTINE dq_get_line(dqgl_idx)
    IF (dqgl_idx > 0
     AND dqgl_idx <= size(dq_parser_rec->buffer,5))
     RETURN(dq_parser_rec->buffer[dqgl_idx].line)
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_upt_line(dqul_idx,dqul_line)
    IF (dqul_idx > 0
     AND dqul_idx <= size(dq_parser_rec->buffer,5))
     SET dq_parser_rec->buffer[dqul_idx].line = dqul_line
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_planjoin(dqap_range)
    DECLARE dqap_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->plan_count > 0))
     SET dqap_str = "join"
    ELSE
     SET dqap_str = "plan"
    ENDIF
    IF (size(trim(dqap_range),1) > 0)
     CALL dq_add_line(concat(dqap_str," ",dqap_range," where"))
     SET dq_parser_rec->plan_count += 1
    ELSE
     CALL dq_add_line("where ")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_set(dqas_to,dqas_from)
   IF ((dq_parser_rec->set_count > 0))
    CALL dq_add_line(concat(",",dqas_to," = ",dqas_from))
   ELSE
    CALL dq_add_line(concat("set ",dqas_to," = ",dqas_from))
   ENDIF
   SET dq_parser_rec->set_count += 1
  END ;Subroutine
  SUBROUTINE dq_add_table(dqat_table_name,dqat_table_alias)
    DECLARE dqat_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->table_count > 0))
     SET dqat_str = concat(" , ",dqat_table_name)
    ELSE
     SET dqat_str = concat(" from ",dqat_table_name)
    ENDIF
    IF (size(trim(dqat_table_alias),1) > 0)
     SET dqat_str = concat(dqat_str," ",dqat_table_alias)
    ENDIF
    SET dq_parser_rec->table_count += 1
    CALL dq_add_line(dqat_str)
  END ;Subroutine
  SUBROUTINE dq_add_with(dqaw_control_option)
   IF ((dq_parser_rec->with_count > 0))
    CALL dq_add_line(concat(",",dqaw_control_option))
   ELSE
    CALL dq_add_line(concat("with ",dqaw_control_option))
   ENDIF
   SET dq_parser_rec->with_count += 1
  END ;Subroutine
  SUBROUTINE dq_begin_insert(dqbi_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("insert")
  END ;Subroutine
  SUBROUTINE dq_begin_select(dqbs_distinct_ind,dqbs_output_device)
    DECLARE dqbs_str = vc WITH noconstant(" ")
    CALL dq_reset_query(1)
    IF (dqbs_distinct_ind=0)
     SET dqbs_str = "select"
    ELSE
     SET dqbs_str = "select distinct"
    ENDIF
    IF (size(trim(dqbs_output_device),1) > 0)
     SET dqbs_str = concat(dqbs_str," into ",dqbs_output_device)
    ENDIF
    CALL dq_add_line(dqbs_str)
  END ;Subroutine
  SUBROUTINE dq_begin_update(dqbu_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("update")
  END ;Subroutine
  SUBROUTINE dq_echo_query(dqeq_level)
    DECLARE dqeq_i = i4 WITH private, noconstant(0)
    DECLARE dqeq_j = i4 WITH private, noconstant(0)
    IF (dqeq_level=1)
     CALL echo("-------------------------------------------------------------------")
     CALL echo("Parser Buffer Echo:")
     CALL echo("-------------------------------------------------------------------")
     FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
       CALL echo(dq_parser_rec->buffer[dqeq_i].line)
     ENDFOR
     CALL echo("-------------------------------------------------------------------")
    ELSEIF (dqeq_level=2)
     IF (validate(reply->debug[1].line,"-9") != "-9")
      SET dqeq_j = size(reply->debug,5)
      SET stat = alterlist(reply->debug,((dqeq_j+ size(dq_parser_rec->buffer,5))+ 4))
      SET reply->debug[(dqeq_j+ 1)].line =
      "-------------------------------------------------------------------"
      SET reply->debug[(dqeq_j+ 2)].line = "Parser Buffer Echo:"
      SET reply->debug[(dqeq_j+ 3)].line =
      "-------------------------------------------------------------------"
      FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
        SET reply->debug[((dqeq_j+ dqeq_i)+ 3)].line = dq_parser_rec->buffer[dqeq_i].line
      ENDFOR
      SET reply->debug[((dqeq_j+ dq_parser_rec->buffer_count)+ 4)].line =
      "-------------------------------------------------------------------"
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_end_query(dqes_dummy)
   CALL dq_add_line(" go")
   SET stat = alterlist(dq_parser_rec->buffer,dq_parser_rec->buffer_count)
  END ;Subroutine
  SUBROUTINE dq_execute(dqe_reset)
    IF (checkprg("PM_DQ_EXECUTE_PARSER") > 0)
     EXECUTE pm_dq_execute_parser  WITH replace("TEMP_DQ_PARSER_REC","DQ_PARSER_REC")
     IF (dqe_reset=1)
      SET stat = initrec(dq_parser_rec)
     ENDIF
    ELSE
     DECLARE dqe_i = i4 WITH private, noconstant(0)
     FOR (dqe_i = 1 TO dq_parser_rec->buffer_count)
       CALL parser(dq_parser_rec->buffer[dqe_i].line,1)
     ENDFOR
     IF (dqe_reset=1)
      CALL dq_reset_query(1)
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_reset_query(dqrb_dummy)
    SET stat = alterlist(dq_parser_rec->buffer,0)
    SET dq_parser_rec->buffer_count = 0
    SET dq_parser_rec->plan_count = 0
    SET dq_parser_rec->set_count = 0
    SET dq_parser_rec->table_count = 0
    SET dq_parser_rec->with_count = 0
  END ;Subroutine
 ENDIF
 IF ((validate(pm_create_req_def,- (9))=- (9)))
  DECLARE pm_create_req_def = i2 WITH constant(0)
  DECLARE cr_hmsg = i4 WITH noconstant(0)
  DECLARE cr_hmsgtype = i4 WITH noconstant(0)
  DECLARE cr_hinst = i4 WITH noconstant(0)
  DECLARE cr_hitem = i4 WITH noconstant(0)
  DECLARE cr_llevel = i4 WITH noconstant(0)
  DECLARE cr_lcnt = i4 WITH noconstant(0)
  DECLARE cr_lcharlen = i4 WITH noconstant(0)
  DECLARE cr_siterator = i4 WITH noconstant(0)
  DECLARE cr_lfieldtype = i4 WITH noconstant(0)
  DECLARE cr_sfieldname = vc WITH noconstant(" ")
  DECLARE cr_blist = i2 WITH noconstant(false)
  DECLARE cr_bfound = i2 WITH noconstant(false)
  DECLARE cr_esrvstring = i4 WITH constant(1)
  DECLARE cr_esrvshort = i4 WITH constant(2)
  DECLARE cr_esrvlong = i4 WITH constant(3)
  DECLARE cr_esrvdouble = i4 WITH constant(6)
  DECLARE cr_esrvasis = i4 WITH constant(7)
  DECLARE cr_esrvlist = i4 WITH constant(8)
  DECLARE cr_esrvstruct = i4 WITH constant(9)
  DECLARE cr_esrvuchar = i4 WITH constant(10)
  DECLARE cr_esrvulong = i4 WITH constant(12)
  DECLARE cr_esrvdate = i4 WITH constant(13)
  FREE RECORD cr_stack
  RECORD cr_stack(
    1 list[10]
      2 hinst = i4
      2 siterator = i4
  )
  SUBROUTINE (cr_createrequest(mode=i2,req_id=i4,req_name=vc) =i2)
    SET cr_llevel = 1
    CALL dq_reset_query(null)
    CALL dq_add_line(concat("free record ",req_name," go"))
    CALL dq_add_line(concat("record ",req_name))
    CALL dq_add_line("(")
    SET cr_hmsg = uar_srvselectmessage(req_id)
    IF (cr_hmsg != 0)
     IF (mode=0)
      SET cr_hinst = uar_srvcreaterequest(cr_hmsg)
     ELSE
      SET cr_hinst = uar_srvcreatereply(cr_hmsg)
     ENDIF
    ELSE
     SET reply->status_data.operationname = "INVALID_hMsg"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
     RETURN(false)
    ENDIF
    IF (cr_hinst > 0)
     SET cr_sfieldname = uar_srvfirstfield(cr_hinst,cr_siterator)
     SET cr_sfieldname = trim(cr_sfieldname,3)
     CALL cr_pushstack(cr_hinst,cr_siterator)
    ELSE
     SET reply->status_data.operationname = "INVALID_hInst"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
     IF (cr_hinst)
      CALL uar_srvdestroyinstance(cr_hinst)
      SET cr_hinst = 0
     ENDIF
     RETURN(false)
    ENDIF
    WHILE (textlen(cr_sfieldname) > 0)
      SET cr_lfieldtype = uar_srvgettype(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
      CASE (cr_lfieldtype)
       OF cr_esrvstruct:
        SET cr_hitem = 0
        SET cr_hitem = uar_srvgetstruct(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_hitem > 0)
         SET cr_siterator = 0
         CALL cr_pushstack(cr_hitem,cr_siterator)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname))
         SET cr_llevel += 1
         SET cr_blist = true
        ELSE
         SET reply->status_data.operationname = "INVALID_hItem"
         SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
         IF (cr_hinst)
          CALL uar_srvdestroyinstance(cr_hinst)
          SET cr_hinst = 0
         ENDIF
         RETURN(false)
        ENDIF
       OF cr_esrvlist:
        SET cr_hitem = 0
        SET cr_hitem = uar_srvadditem(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_hitem > 0)
         SET cr_siterator = 0
         CALL cr_pushstack(cr_hitem,cr_siterator)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname,"[*]"))
         SET cr_llevel += 1
         SET cr_blist = true
        ELSE
         SET reply->status_data.operationname = "INVALID_hInst"
         SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
         IF (cr_hinst)
          CALL uar_srvdestroyinstance(cr_hinst)
          SET cr_hinst = 0
         ENDIF
         RETURN(false)
        ENDIF
       OF cr_esrvstring:
        SET cr_lcharlen = uar_srvgetstringmax(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        IF (cr_lcharlen > 0)
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c",cnvtstring(
            cr_lcharlen)))
        ELSE
         CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = vc"))
        ENDIF
       OF cr_esrvuchar:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c1"))
       OF cr_esrvshort:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i2"))
       OF cr_esrvlong:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i4"))
       OF cr_esrvulong:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = ui4"))
       OF cr_esrvdouble:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = f8"))
       OF cr_esrvdate:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = dq8"))
       OF cr_esrvasis:
        CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = gvc"))
       ELSE
        SET reply->status_data.operationname = "INVALID_SrvType"
        SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
        IF (cr_hinst)
         CALL uar_srvdestroyinstance(cr_hinst)
         SET cr_hinst = 0
        ENDIF
        RETURN(false)
      ENDCASE
      SET cr_sfieldname = ""
      IF (cr_blist)
       SET cr_sfieldname = uar_srvfirstfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
        siterator)
       SET cr_sfieldname = trim(cr_sfieldname,3)
       SET cr_blist = false
      ELSE
       SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
        siterator)
       SET cr_sfieldname = trim(cr_sfieldname,3)
       IF (textlen(cr_sfieldname) <= 0)
        SET cr_bfound = false
        WHILE (cr_bfound != true)
          CALL cr_popstack(null)
          IF ((cr_stack->list[cr_lcnt].hinst > 0)
           AND cr_lcnt > 0)
           SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt]
            .siterator)
           SET cr_sfieldname = trim(cr_sfieldname,3)
          ELSE
           SET cr_bfound = true
          ENDIF
          IF (textlen(cr_sfieldname) > 0)
           SET cr_bfound = true
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
    ENDWHILE
    IF (mode=1)
     CALL dq_add_line("1  status_data")
     CALL dq_add_line("2  status  = c1")
     CALL dq_add_line("2  subeventstatus[1]")
     CALL dq_add_line("3  operationname = c15")
     CALL dq_add_line("3  operationstatus = c1")
     CALL dq_add_line("3  targetobjectname = c15")
     CALL dq_add_line("3  targetobjectvalue = vc")
    ENDIF
    CALL dq_add_line(")  with persistscript")
    CALL dq_end_query(null)
    CALL dq_execute(null)
    IF (cr_hinst)
     CALL uar_srvdestroyinstance(cr_hinst)
     SET cr_hinst = 0
    ENDIF
    RETURN(true)
  END ;Subroutine
  SUBROUTINE (cr_popstack(dummyvar=i2) =null)
   SET cr_lcnt -= 1
   SET cr_llevel -= 1
  END ;Subroutine
  SUBROUTINE (cr_pushstack(hval=i4,lval=i4) =null)
    SET cr_lcnt += 1
    IF (mod(cr_lcnt,10)=1
     AND cr_lcnt != 1)
     SET stat = alterlist(cr_stack->list,(cr_lcnt+ 9))
    ENDIF
    SET cr_stack->list[cr_lcnt].hinst = hval
    SET cr_stack->list[cr_lcnt].siterator = lval
  END ;Subroutine
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET temp_cnt = 0
 IF ((((request->report_type_flag=1)) OR ((request->report_type_flag=3))) )
  SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,ap_process_type_cd)
  IF (ap_process_type_cd <= 0.0)
   SET reply->status_data.status = "F"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   task_descrip = uar_get_code_description(dta.task_assay_cd), task_disp_caps = cnvtupper(
    cnvtalphanum(uar_get_code_display(dta.task_assay_cd)))
   FROM order_catalog oc,
    profile_task_r ptr,
    discrete_task_assay dta,
    ap_task_assay_addl ataa
   PLAN (oc
    WHERE oc.activity_subtype_cd=ap_process_type_cd
     AND oc.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (ataa
    WHERE (ataa.task_assay_cd= Outerjoin(dta.task_assay_cd)) )
   ORDER BY task_disp_caps
   HEAD REPORT
    temp_cnt = 0, stat = alterlist(temp->qual,10)
   DETAIL
    temp_cnt += 1
    IF (temp_cnt > size(temp->qual,5))
     stat = alterlist(temp->qual,(temp_cnt+ 9))
    ENDIF
    temp->qual[temp_cnt].task_assay_cd = dta.task_assay_cd, temp->qual[temp_cnt].
    create_inventory_flag = ataa.create_inventory_flag, temp->qual[temp_cnt].task_type_flag = ataa
    .task_type_flag,
    temp->qual[temp_cnt].slide_origin_flag = ataa.slide_origin_flag, temp->qual[temp_cnt].stain_ind
     = ataa.stain_ind, temp->qual[temp_cnt].half_slide_ind = ataa.half_slide_ind,
    temp->qual[temp_cnt].print_label_ind = ataa.print_label_ind, temp->qual[temp_cnt].task_assay_disp
     = format(uar_get_code_display(dta.task_assay_cd),"##############"), temp->qual[temp_cnt].
    task_assay_disp_caps = format(task_disp_caps,"##############"),
    temp->qual[temp_cnt].task_assay_desc = format(task_descrip,
     "########################################"), temp->qual[temp_cnt].autoverify_workflow_cd = ataa
    .autoverify_workflow_cd
    IF (ataa.autoverify_workflow_cd > 0.0)
     temp->qual[temp_cnt].autoverify_workflow_disp = format(uar_get_code_display(ataa
       .autoverify_workflow_cd),"###########")
    ELSE
     temp->qual[temp_cnt].autoverify_workflow_disp = captions->none
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->qual,temp_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((((request->report_type_flag=2)) OR ((request->report_type_flag=3))) )
  SELECT INTO "nl:"
   cv.code_value, cv.display_key
   FROM code_value cv
   WHERE cv.code_set=2074
   ORDER BY cv.display_key
   HEAD REPORT
    instr_type_cnt = 0
   DETAIL
    instr_type_cnt += 1
    IF (instr_type_cnt > size(instrument_list->instrument_type_list,5))
     stat = alterlist(instrument_list->instrument_type_list,(instr_type_cnt+ 9))
    ENDIF
    instrument_list->instrument_type_list[instr_type_cnt].instrument_type_cd = cv.code_value,
    instrument_list->instrument_type_list[instr_type_cnt].instrument_type_disp = cv.display
   FOOT REPORT
    stat = alterlist(instrument_list->instrument_type_list,instr_type_cnt)
   WITH nocounter
  ;end select
  IF (instr_type_cnt > 0)
   SELECT INTO "nl:"
    ip_prtcl_name_caps = cnvtupper(cnvtalphanum(ip.protocol_name))
    FROM instrument_protocol ip
    PLAN (ip
     WHERE expand(idx,1,instr_type_cnt,ip.instrument_type_cd,instrument_list->instrument_type_list[
      idx].instrument_type_cd))
    ORDER BY ip.instrument_type_cd, ip_prtcl_name_caps
    HEAD ip.instrument_type_cd
     instr_prtcl_cnt = 0, lvindex1 = locateval(idx,1,instr_type_cnt,ip.instrument_type_cd,
      instrument_list->instrument_type_list[idx].instrument_type_cd)
    DETAIL
     instr_prtcl_cnt += 1
     IF (instr_prtcl_cnt > size(instrument_list->instrument_type_list[lvindex1].
      instrument_protocol_list,5))
      stat = alterlist(instrument_list->instrument_type_list[lvindex1].instrument_protocol_list,(
       instr_prtcl_cnt+ 9))
     ENDIF
     instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[instr_prtcl_cnt].
     instrument_protocol_id = ip.instrument_protocol_id, instrument_list->instrument_type_list[
     lvindex1].instrument_protocol_list[instr_prtcl_cnt].instrument_type_cd = ip.instrument_type_cd,
     instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[instr_prtcl_cnt].
     protocol_name = ip.protocol_name,
     instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[instr_prtcl_cnt].
     universal_service_ident = ip.universal_service_ident, instrument_list->instrument_type_list[
     lvindex1].instrument_protocol_list[instr_prtcl_cnt].placer_field_1 = ip.placer_field_1,
     instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[instr_prtcl_cnt].
     supp_service_info = ip.suplmtl_serv_info_txt,
     instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[instr_prtcl_cnt].
     active_ind = ip.active_ind
    FOOT  ip.instrument_type_cd
     stat = alterlist(instrument_list->instrument_type_list[lvindex1].instrument_protocol_list,
      instr_prtcl_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET instr_task_cnt = maxval(1,temp_cnt)
 SET stat = alterlist(temp->qual,instr_task_cnt)
 FOR (idx = 1 TO instr_task_cnt)
  SET stat = alterlist(temp->qual[idx].instr_list,1)
  SET temp->qual[idx].instr_cnt = 0
 ENDFOR
 SET instrument_list->instrmt_type_size = size(instrument_list->instrument_type_list,5)
 SET instr_type_cnt = maxval(1,instrument_list->instrmt_type_size)
 SET stat = alterlist(instrument_list->instrument_type_list,instr_type_cnt)
 FOR (idx = 1 TO instr_type_cnt)
   SET instrument_list->instrument_type_list[idx].instrmt_prtcl_size = size(instrument_list->
    instrument_type_list[idx].instrument_protocol_list,5)
   SET instr_prtcl_cnt = maxval(1,instrument_list->instrument_type_list[idx].instrmt_prtcl_size)
   SET stat = alterlist(instrument_list->instrument_type_list[idx].instrument_protocol_list,
    instr_prtcl_cnt)
   FOR (idx2 = 1 TO instr_prtcl_cnt)
    SET stat = alterlist(instrument_list->instrument_type_list[idx].instrument_protocol_list[idx2].
     task_list,1)
    SET instrument_list->instrument_type_list[idx].instrument_protocol_list[idx2].task_cnt = 0
   ENDFOR
 ENDFOR
 IF (((temp_cnt > 0) OR ((instrument_list->instrmt_type_size > 0))) )
  SELECT INTO "nl:"
   task_disp_caps = cnvtupper(cnvtalphanum(uar_get_code_display(ptr.task_assay_cd))),
   instr_type_disp_caps = cnvtupper(cnvtalphanum(uar_get_code_display(ip.instrument_type_cd))),
   protocol_name_caps = cnvtupper(cnvtalphanum(ip.protocol_name))
   FROM proc_instrmt_protcl_r pipr,
    profile_task_r ptr,
    instrument_protocol ip
   PLAN (pipr)
    JOIN (ptr
    WHERE ptr.catalog_cd=pipr.catalog_cd
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
     AND ptr.active_ind=1)
    JOIN (ip
    WHERE ip.instrument_protocol_id=pipr.instrument_protocol_id)
   ORDER BY task_disp_caps, instr_type_disp_caps, protocol_name_caps
   DETAIL
    IF ((((request->report_type_flag=1)) OR ((request->report_type_flag=3)))
     AND temp_cnt > 0)
     lvindex1 = 0
     WHILE (assign(lvindex1,locateval(idx,(lvindex1+ 1),temp_cnt,ptr.task_assay_cd,temp->qual[idx].
       task_assay_cd)) > 0)
       temp->qual[lvindex1].instr_cnt += 1
       IF ((temp->qual[lvindex1].instr_cnt > size(temp->qual[lvindex1].instr_list,5)))
        stat = alterlist(temp->qual[lvindex1].instr_list,(temp->qual[lvindex1].instr_cnt+ 9))
       ENDIF
       temp->qual[lvindex1].instr_list[temp->qual[lvindex1].instr_cnt].protocol_name = ip
       .protocol_name, temp->qual[lvindex1].instr_list[temp->qual[lvindex1].instr_cnt].
       instr_type_disp = uar_get_code_display(ip.instrument_type_cd)
     ENDWHILE
    ENDIF
    IF ((((request->report_type_flag=2)) OR ((request->report_type_flag=3)))
     AND (instrument_list->instrmt_type_size > 0))
     lvindex1 = 0
     WHILE (assign(lvindex1,locateval(idx,(lvindex1+ 1),instrument_list->instrmt_type_size,ip
       .instrument_type_cd,instrument_list->instrument_type_list[idx].instrument_type_cd)) > 0)
       IF ((instrument_list->instrument_type_list[lvindex1].instrmt_prtcl_size > 0))
        lvindex2 = 0
        WHILE (assign(lvindex2,locateval(idx2,(lvindex2+ 1),instrument_list->instrument_type_list[
          lvindex1].instrmt_prtcl_size,ip.instrument_protocol_id,instrument_list->
          instrument_type_list[lvindex1].instrument_protocol_list[idx2].instrument_protocol_id)) > 0)
          instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[lvindex2].task_cnt
           = assign(instr_task_cnt,(instrument_list->instrument_type_list[lvindex1].
           instrument_protocol_list[lvindex2].task_cnt+ 1))
          IF (instr_task_cnt > size(instrument_list->instrument_type_list[lvindex1].
           instrument_protocol_list[lvindex2].task_list,5))
           stat = alterlist(instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[
            lvindex2].task_list,(instr_task_cnt+ 9))
          ENDIF
          instrument_list->instrument_type_list[lvindex1].instrument_protocol_list[lvindex2].
          task_list[instr_task_cnt].task_assay_disp = uar_get_code_display(ptr.task_assay_cd)
        ENDWHILE
       ENDIF
     ENDWHILE
    ENDIF
   FOOT REPORT
    IF ((((request->report_type_flag=1)) OR ((request->report_type_flag=3))) )
     FOR (idx = 1 TO temp_cnt)
       stat = alterlist(temp->qual[idx].instr_list,maxval(1,temp->qual[idx].instr_cnt))
     ENDFOR
    ENDIF
    IF ((((request->report_type_flag=2)) OR ((request->report_type_flag=3))) )
     FOR (idx = 1 TO instrument_list->instrmt_type_size)
       FOR (idx2 = 1 TO instrument_list->instrument_type_list[idx].instrmt_prtcl_size)
         stat = alterlist(instrument_list->instrument_type_list[idx].instrument_protocol_list[idx2].
          task_list,maxval(1,instrument_list->instrument_type_list[idx].instrument_protocol_list[idx2
           ].task_cnt))
       ENDFOR
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((((request->report_type_flag=4)) OR ((request->report_type_flag=3))) )
  CALL cr_createrequest(0,200001,"REQ200001")
  RECORD rep200001(
    1 prefix_qual[10]
      2 site_cd = f8
      2 unformatted_site_disp = c40
      2 prefix_cd = f8
      2 prefix_desc = c40
      2 prefix_name = c2
      2 case_type_cd = f8
      2 case_type_disp = c40
      2 case_type_desc = c40
      2 case_type_mean = c40
      2 accession_format_cd = f8
      2 active_ind = i4
      2 group_id = f8
      2 site_disp = c40
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET req200001->bshowinactives = 0
  SET req200001->skip_resource_security_ind = 1
  EXECUTE aps_get_all_prefixes  WITH replace("REQUEST","REQ200001"), replace("REPLY","REP200001")
  IF ((rep200001->status_data.status != "S"))
   CALL subevent_add("EXECUTE","F","aps_get_all_prefixes","Execute failed.")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
  SET lrep200001count = size(rep200001->prefix_qual,5)
  SET prefix_list->prefix_count = lrep200001count
  SET stat = alterlist(prefix_list->prefix,maxval(1,prefix_list->prefix_count))
  FOR (lrep200001index = 1 TO lrep200001count)
    SET prefix_list->prefix[lrep200001index].prefix_id = rep200001->prefix_qual[lrep200001index].
    prefix_cd
    SET prefix_list->prefix[lrep200001index].prefix_name = trim(rep200001->prefix_qual[
     lrep200001index].prefix_name,5)
    SET prefix_list->prefix[lrep200001index].prefix_desc = trim(rep200001->prefix_qual[
     lrep200001index].prefix_desc,5)
    SET prefix_list->prefix[lrep200001index].site_disp = trim(rep200001->prefix_qual[lrep200001index]
     .site_disp,5)
  ENDFOR
  FREE SET req200001
  FREE SET rep200001
  IF ((prefix_list->prefix_count > 0))
   IF (ap_process_type_cd <= 0.0)
    SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,ap_process_type_cd)
    IF (ap_process_type_cd <= 0.0)
     SET reply->status_data.status = "F"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    task_disp_caps = cnvtupper(cnvtalphanum(uar_get_code_display(ptr.task_assay_cd)))
    FROM ap_prefix_task_r aptr,
     order_catalog oc,
     profile_task_r ptr
    PLAN (aptr
     WHERE aptr.ap_prefix_task_r_id > 0.0)
     JOIN (oc
     WHERE oc.catalog_cd=aptr.catalog_cd
      AND oc.activity_subtype_cd=ap_process_type_cd
      AND oc.active_ind=1)
     JOIN (ptr
     WHERE ptr.catalog_cd=oc.catalog_cd
      AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
      AND ptr.active_ind=1)
    ORDER BY aptr.prefix_id, task_disp_caps
    HEAD aptr.prefix_id
     lprefixtaskcount = 0, lprefixindex = 0, stat = assign(lprefixindex,locateval(idx,(lprefixindex+
       1),prefix_list->prefix_count,aptr.prefix_id,prefix_list->prefix[idx].prefix_id)),
     lprefixtaskcount = prefix_list->prefix[lprefixindex].task_count
    DETAIL
     lprefixtaskcount += 1
     IF ((lprefixtaskcount > prefix_list->prefix[lprefixindex].task_count))
      stat = alterlist(prefix_list->prefix[lprefixindex].task,(lprefixtaskcount+ 9))
     ENDIF
     prefix_list->prefix[lprefixindex].task_count = lprefixtaskcount, prefix_list->prefix[
     lprefixindex].task[lprefixtaskcount].task_assay_disp = uar_get_code_display(ptr.task_assay_cd),
     prefix_list->prefix[lprefixindex].task[lprefixtaskcount].task_assay_desc =
     uar_get_code_description(ptr.task_assay_cd)
    FOOT  aptr.prefix_id
     prefix_list->prefix[lprefixindex].task_count = lprefixtaskcount, stat = alterlist(prefix_list->
      prefix[lprefixindex].task,maxval(1,lprefixtaskcount))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbProcTask", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF ((((request->report_type_flag=1)) OR ((request->report_type_flag=3))) )
  SET curalias task_qual temp->qual[d1.seq]
  SELECT INTO value(reply->print_status_data.print_filename)
   d1.seq, d2.seq
   FROM (dummyt d1  WITH seq = value(maxval(1,temp_cnt))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,maxval(1,task_qual->instr_cnt)))
    JOIN (d2)
   ORDER BY d1.seq, d2.seq
   HEAD REPORT
    breaked = "N", line1 = fillstring(125,"-"), line2 = fillstring(25,"-")
   HEAD PAGE
    row + 1, col 0, captions->apsrpt,
    CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
    col 117, curdate"@SHORTDATE;;Q", row + 1,
    col 0, captions->directory, col 110,
    captions->ttime, col 117, curtime,
    row + 1,
    CALL center(captions->refdbaudit,0,132), col 112,
    captions->bby, col 117, request->scuruser"##############",
    row + 1,
    CALL center(captions->dbproctasktool,0,132), col 110,
    captions->ppage, col 117, curpage"###"
    IF (d1.seq=1)
     row + 2,
     CALL center(line2,0,maxcol), row + 1,
     CALL center(captions->processingtasks,0,maxcol), row + 1,
     CALL center(line2,0,maxcol)
    ENDIF
    row + 2, col 85, captions->slide,
    col 95, captions->stained, col 104,
    captions->half, col 111, captions->pprint,
    col 117, captions->autoverify, row + 1,
    col 0, captions->task, col 15,
    captions->description, col 55, captions->inventory,
    col 72, captions->association, col 85,
    captions->slideorigin, col 95, captions->slide,
    col 104, captions->slide, col 111,
    captions->label, col 117, captions->step,
    row + 1, col 0, "-------------",
    col 15, "-------------------------------------", col 55,
    "--------------", col 72, "---------",
    col 85, "------------", col 95,
    "------", col 104, "-----",
    col 111, "-----", col 117,
    "----------"
   HEAD d1.seq
    IF (temp_cnt > 0)
     IF (((((row+ 7) > maxrow)) OR ((((row+ 7)+ temp->qual[d1.seq].instr_cnt) > maxrow)
      AND ((20+ temp->qual[d1.seq].instr_cnt) < maxrow))) )
      breaked = "Y", BREAK
     ENDIF
     row + 1, col 0, task_qual->task_assay_disp,
     col 15, task_qual->task_assay_desc, col 55
     IF ((task_qual->create_inventory_flag=0))
      captions->none
     ELSEIF ((task_qual->create_inventory_flag=1))
      captions->block
     ELSEIF ((task_qual->create_inventory_flag=2))
      captions->slide2
     ELSEIF ((task_qual->create_inventory_flag=3))
      captions->blockandslide
     ELSEIF ((task_qual->create_inventory_flag=4))
      captions->specimen
     ENDIF
     col 72
     IF ((task_qual->task_type_flag=0))
      captions->none
     ELSEIF ((task_qual->task_type_flag=1))
      captions->block
     ELSEIF ((task_qual->task_type_flag=2))
      captions->slide2
     ELSEIF ((task_qual->task_type_flag=3))
      captions->blockandslide
     ELSEIF ((task_qual->task_type_flag=4))
      captions->specimen
     ENDIF
     col 85
     IF ((task_qual->slide_origin_flag=0))
      captions->none
     ELSEIF ((task_qual->slide_origin_flag=1))
      captions->block
     ELSEIF ((task_qual->slide_origin_flag=2))
      captions->slide2
     ELSEIF ((task_qual->slide_origin_flag=3))
      captions->blockandslide
     ELSEIF ((task_qual->slide_origin_flag=4))
      captions->specimen
     ENDIF
     col 95
     IF ((task_qual->stain_ind=1))
      captions->yes
     ENDIF
     col 104
     IF ((task_qual->half_slide_ind=1))
      captions->yes
     ENDIF
     col 111
     IF ((task_qual->print_label_ind=1))
      captions->yes
     ENDIF
     col 117, task_qual->autoverify_workflow_disp
    ELSE
     row + 1,
     CALL center(captions->noproctasksdefined,0,maxcol)
    ENDIF
   DETAIL
    IF (((row+ 7) > maxrow))
     breaked = "Y", BREAK
    ENDIF
    IF ((temp->qual[d1.seq].instr_cnt > 0))
     row + 1, col 22, captions->assignedipandtype,
     prev_col = (col+ 2), prtcl_name = trim(temp->qual[d1.seq].instr_list[d2.seq].protocol_name,3),
     instr_display = concat("(",trim(temp->qual[d1.seq].instr_list[d2.seq].instr_type_disp,3),")"),
     col + 2, prtcl_name
     IF ((size(instr_display,1) < ((maxcol - col) - 2)))
      col + 2, instr_display
     ELSE
      row + 1, col prev_col, instr_display
     ENDIF
    ENDIF
   FOOT PAGE
    IF (((breaked="Y") OR (((d1.seq < temp_cnt) OR ((request->report_type_flag=1))) )) )
     row 60, col 0, line1,
     row + 1, col 0, captions->apsrpt,
     today = concat(week," ",day), col 53, today,
     col 110, captions->ppage, col 117,
     curpage"###", row + 1, col 55,
     captions->continued
    ENDIF
    breaked = "N"
   FOOT REPORT
    IF ((request->report_type_flag=1))
     row 62, col 55, "                                         ",
     col 55, captions->endofreport
    ENDIF
    proc_last_row = row, proc_last_page = (curpage - 1)
   WITH nocounter, maxcol = 132, nullreport,
    maxrow = 63, compress
  ;end select
  SET curalias task_qual off
 ENDIF
 IF ((((request->report_type_flag=2)) OR ((request->report_type_flag=3))) )
  SET curalias instr_type instrument_list->instrument_type_list[d1.seq]
  SET curalias instr_prtcl instrument_list->instrument_type_list[d1.seq].instrument_protocol_list[d2
  .seq]
  SET curalias instr_tasks instrument_list->instrument_type_list[d1.seq].instrument_protocol_list[d2
  .seq].task_list[d3.seq]
  SELECT INTO value(reply->print_status_data.print_filename)
   d1.seq, d2.seq, d3.seq
   FROM (dummyt d1  WITH seq = value(maxval(1,instrument_list->instrmt_type_size))),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,maxval(1,instr_type->instrmt_prtcl_size)))
    JOIN (d2
    WHERE maxrec(d3,maxval(1,instr_prtcl->task_cnt)))
    JOIN (d3)
   ORDER BY d1.seq, d2.seq, d3.seq
   HEAD REPORT
    line1 = fillstring(125,"-"), line2 = fillstring(25,"-"), instr_sect_contd = "N",
    instr_header_compltd = "N"
    IF ((request->report_type_flag=3))
     IF (((((proc_last_row+ 20) > maxrow)) OR ((((proc_last_row+ 20)+ instr_prtcl->task_cnt) > maxrow
     )
      AND ((20+ instr_prtcl->task_cnt) < maxrow))) )
      BREAK
     ELSE
      row + 3,
      CALL center(line2,0,maxcol), row + 1,
      CALL center(captions->instrumentprotocols,0,maxcol), row + 1,
      CALL center(line2,0,maxcol),
      instr_sect_contd = "Y", instr_header_compltd = "Y"
     ENDIF
    ENDIF
   HEAD PAGE
    IF (instr_sect_contd="Y")
     instr_sect_contd = "N"
    ELSE
     row + 1, col 0, captions->apsrpt,
     CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
     col 117, curdate"@SHORTDATE;;Q", row + 1,
     col 0, captions->directory, col 110,
     captions->ttime, col 117, curtime,
     row + 1,
     CALL center(captions->refdbaudit,0,132), col 112,
     captions->bby, col 117, request->scuruser"##############",
     row + 1,
     CALL center(captions->dbproctasktool,0,132), col 110,
     captions->ppage, actual_page = (curpage+ proc_last_page), col 117,
     actual_page"###"
     IF (instr_header_compltd="N")
      row + 2,
      CALL center(line2,0,maxcol), row + 1,
      CALL center(captions->instrumentprotocols,0,maxcol), row + 1,
      CALL center(line2,0,maxcol),
      instr_header_compltd = "Y"
     ENDIF
    ENDIF
   HEAD d1.seq
    IF ((instrument_list->instrmt_type_size > 0))
     IF ((((((proc_last_row+ row)+ 15) > maxrow)) OR (((((proc_last_row+ row)+ 15)+ instr_prtcl->
     task_cnt) > maxrow)
      AND ((20+ instr_prtcl->task_cnt) < maxrow))) )
      BREAK, row + 1
     ENDIF
     row + 2, col 0, captions->instrumenttype,
     col + 2, instr_type->instrument_type_disp, row + 1,
     col 53, captions->universal, col 85,
     captions->label, col 107, captions->plcrsupplement,
     row + 1, col 3, captions->protocoldescript,
     col 45, captions->active, col 53,
     captions->srvcidentifier, col 85, captions->template,
     col 107, captions->srvcinformation, row + 1,
     col 3, "----------------------------------------", col 45,
     "------", col 53, "------------------------------",
     col 85, "--------------------", col 107,
     "--------------------"
     IF ((instr_type->instrmt_prtcl_size < 1))
      row + 1,
      CALL center(captions->noinstrmtprotcldefined,0,maxcol)
     ENDIF
    ELSE
     row + 1,
     CALL center(captions->noinstrmttypedefined,0,maxcol)
    ENDIF
   HEAD d2.seq
    IF ((instr_type->instrmt_prtcl_size > 0))
     IF ((((((proc_last_row+ row)+ 10) > maxrow)) OR (((((proc_last_row+ row)+ 10)+ instr_prtcl->
     task_cnt) > maxrow)
      AND ((20+ instr_prtcl->task_cnt) < maxrow))) )
      BREAK, row + 2, col 0,
      captions->instrumenttype, col + 2, instr_type->instrument_type_disp,
      row + 1, col 53, captions->universal,
      col 85, captions->label, col 107,
      captions->plcrsupplement, row + 1, col 3,
      captions->protocoldescript, col 45, captions->active,
      col 53, captions->srvcidentifier, col 85,
      captions->template, col 107, captions->srvcinformation,
      row + 1, col 3, "----------------------------------------",
      col 45, "------", col 53,
      "------------------------------", col 85, "--------------------",
      col 107, "--------------------"
     ENDIF
     is_active = evaluate(instr_prtcl->active_ind,1,captions->yes,captions->no), prtcl_name = format(
      trim(instr_prtcl->protocol_name,3),"########################################"),
     unvrsl_srvc_ident = format(trim(instr_prtcl->universal_service_ident,3),
      "##############################"),
     plcr_fld_1 = format(trim(instr_prtcl->placer_field_1,3),"####################"), supp_srvc_info
      = format(trim(instr_prtcl->supp_service_info,3),"#########################"), row + 1,
     col 3, prtcl_name, col 45,
     is_active, col 53, unvrsl_srvc_ident,
     col 85, plcr_fld_1, col 107,
     supp_srvc_info, row + 1, col 13,
     captions->assignedtasks
    ENDIF
   DETAIL
    IF ((instr_type->instrmt_prtcl_size > 0))
     IF ((instr_prtcl->task_cnt > 0))
      row + 1, col 20, instr_tasks->task_assay_disp
      IF ((((proc_last_row+ row)+ 7) > maxrow)
       AND (d3.seq < instr_prtcl->task_cnt))
       BREAK, row + 2, col 13,
       captions->assignedtasks
      ENDIF
     ELSE
      row + 1, col 20, captions->none
     ENDIF
    ENDIF
   FOOT  d1.seq
    row + 1,
    CALL center("* * * * * * * * * * *",0,maxcol)
   FOOT PAGE
    IF ((((d1.seq < instrument_list->instrmt_type_size)) OR ((request->report_type_flag=2))) )
     last_row = (60 - proc_last_row), proc_last_row = 0, row last_row,
     col 0, line1, row + 1,
     col 0, captions->apsrpt, today = concat(week," ",day),
     col 53, today, col 110,
     captions->ppage, actual_page = (curpage+ proc_last_page), col 117,
     actual_page"###", row + 1, col 55,
     captions->continued
    ENDIF
   FOOT REPORT
    IF ((request->report_type_flag=2))
     row 62, col 55, "                                         ",
     col 55, captions->endofreport
    ENDIF
    proc_last_row = row, proc_last_page = (actual_page - 1)
   WITH nocounter, maxcol = 132, append,
    nullreport, maxrow = 63, compress
  ;end select
  SET curalias instr_type off
  SET curalias instr_prtcl off
  SET curalias instr_tasks off
 ENDIF
 IF ((((request->report_type_flag=4)) OR ((request->report_type_flag=3))) )
  SET curalias cur_prefix prefix_list->prefix[d1.seq]
  SET curalias cur_prefix_task prefix_list->prefix[d1.seq].task[d2.seq]
  SELECT INTO value(reply->print_status_data.print_filename)
   d1.seq, d2.seq, siteprefixcaps = cnvtupper(cnvtalphanum(build(trim(cur_prefix->site_disp,5),trim(
       cur_prefix->prefix_name,5))))
   FROM (dummyt d1  WITH seq = value(maxval(1,prefix_list->prefix_count))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,maxval(1,cur_prefix->task_count)))
    JOIN (d2)
   ORDER BY siteprefixcaps, d2.seq
   HEAD REPORT
    line1 = fillstring(125,"-"), line2 = fillstring(25,"-"), prefix_sect_contd = "N",
    prefix_header_completed = "N"
    IF ((request->report_type_flag=3))
     IF (((((proc_last_row+ 20) > maxrow)) OR ((((proc_last_row+ 20)+ cur_prefix->task_count) >
     maxrow)
      AND ((20+ cur_prefix->task_count) < maxrow))) )
      BREAK
     ELSE
      row + 3,
      CALL center(line2,0,maxcol), row + 1,
      CALL center(captions->prefixes,0,maxcol), row + 1,
      CALL center(line2,0,maxcol),
      prefix_sect_contd = "Y", prefix_header_completed = "Y"
     ENDIF
    ENDIF
   HEAD PAGE
    IF (prefix_sect_contd="Y")
     prefix_sect_contd = "N"
    ELSE
     row + 1, col 0, captions->apsrpt,
     CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
     col 117, curdate"@SHORTDATE;;Q", row + 1,
     col 0, captions->directory, col 110,
     captions->ttime, col 117, curtime,
     row + 1,
     CALL center(captions->refdbaudit,0,132), col 112,
     captions->bby, col 117, request->scuruser"##############",
     row + 1,
     CALL center(captions->dbproctasktool,0,132), col 110,
     captions->ppage, actual_page = (curpage+ proc_last_page), col 117,
     actual_page"###"
     IF (prefix_header_completed="N")
      row + 2,
      CALL center(line2,0,maxcol), row + 1,
      CALL center(captions->prefixes,0,maxcol), row + 1,
      CALL center(line2,0,maxcol),
      prefix_header_completed = "Y"
     ENDIF
    ENDIF
   HEAD d1.seq
    IF ((prefix_list->prefix_count > 0))
     IF ((((((proc_last_row+ row)+ 13) > maxrow)) OR (((((proc_last_row+ row)+ 13)+ cur_prefix->
     task_count) > maxrow)
      AND ((20+ cur_prefix->task_count) < maxrow))) )
      BREAK, row + 1
     ENDIF
     IF (size(trim(cur_prefix->prefix_name)) > 0)
      ssiteprefixdisp = build(trim(cur_prefix->site_disp),trim(cur_prefix->prefix_name,5))
     ELSE
      ssiteprefixdisp = build(trim(cur_prefix->site_disp),trim(cur_prefix->prefix_name))
     ENDIF
     sprefixdescdisp = trim(cur_prefix->prefix_desc), row + 2, col 0,
     captions->siteprefix, col + 2, ssiteprefixdisp,
     col + 10, sprefixdescdisp, row + 2,
     col 10, captions->processingtask, col 33,
     captions->description, row + 1, col 10,
     "--------------------", col 33, "----------------------------------------------"
     IF ((cur_prefix->task_count < 1))
      row + 1, col 10, captions->none
     ENDIF
    ELSE
     row + 1,
     CALL center(captions->noprefixesdefined,0,maxcol)
    ENDIF
   DETAIL
    IF ((cur_prefix->task_count > 0))
     staskdisp = format(cur_prefix_task->task_assay_disp,"####################"), staskdesc = format(
      cur_prefix_task->task_assay_desc,"############################################################"
      ), row + 1,
     col 10, staskdisp, col 33,
     staskdesc
     IF ((((proc_last_row+ row)+ 7) > maxrow)
      AND (d2.seq < cur_prefix->task_count))
      BREAK, row + 2, col 0,
      captions->siteprefix, col + 2, ssiteprefixdisp,
      col + 10, sprefixdescdisp, row + 2,
      col 10, captions->processingtask, col 33,
      captions->description, row + 1, col 10,
      "--------------------", col 33, "----------------------------------------------"
     ENDIF
    ENDIF
   FOOT  d1.seq
    row + 1,
    CALL center("* * * * * * * * * * *",0,maxcol)
   FOOT PAGE
    last_row = (60 - proc_last_row), proc_last_row = 0, row last_row,
    col 0, line1, row + 1,
    col 0, captions->apsrpt, today = concat(week," ",day),
    col 53, today, col 110,
    captions->ppage, actual_page = (curpage+ proc_last_page), col 117,
    actual_page"###", row + 1, col 55,
    captions->continued
   FOOT REPORT
    row 62, col 55, "                                         ",
    col 55, captions->endofreport
   WITH nocounter, maxcol = 132, append,
    nullreport, maxrow = 63, compress
  ;end select
  SET curalias cur_prefix off
  SET curalias cur_prefix_task off
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE SET instrument_list
 FREE SET temp
 FREE SET captions
END GO
