CREATE PROGRAM aps_prt_db_billing_tasks:dba
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
   1 dbbillingtaskstool = vc
   1 ppage = vc
   1 pathnetap = vc
   1 task = vc
   1 description = vc
   1 dateofservice = vc
   1 notdefined = vc
   1 continued = vc
   1 endofreport = vc
   1 prefixes = vc
   1 siteprefix = vc
   1 billingtask = vc
   1 billingtaskhead = vc
   1 noprefixesdefined = vc
   1 nobilltasksdefined = vc
   1 none = vc
 )
 SET captions->none = uar_i18ngetmessage(i18nhandle,"d4","(none)")
 SET captions->apsrpt = uar_i18ngetmessage(i18nhandle,"h1","REPORT: APS_PRT_DB_BILLING_TASKS.PRG")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h2","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h3","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h4","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h5","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->dbbillingtaskstool = uar_i18ngetmessage(i18nhandle,"h7","DB BILLING TASKS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h10","PATHNET ANATOMIC PATHOLOGY")
 SET captions->task = uar_i18ngetmessage(i18nhandle,"h13","TASK")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h14","DESCRIPTION")
 SET captions->dateofservice = uar_i18ngetmessage(i18nhandle,"h19","DATE OF SERVICE DEFAULT")
 SET captions->notdefined = uar_i18ngetmessage(i18nhandle,"d1","Not Defined")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->endofreport = uar_i18ngetmessage(i18nhandle,"f2","*** END OF REPORT ***")
 SET captions->prefixes = uar_i18ngetmessage(i18nhandle,"h15","PREFIXES")
 SET captions->siteprefix = uar_i18ngetmessage(i18nhandle,"h16","Site/Prefix:")
 SET captions->billingtask = uar_i18ngetmessage(i18nhandle,"h17","BILLING TASK")
 SET captions->noprefixesdefined = uar_i18ngetmessage(i18nhandle,"d2","***NO PREFIXES ARE DEFINED***"
  )
 SET captions->billingtaskhead = uar_i18ngetmessage(i18nhandle,"h18","BILLING TASKS")
 SET captions->nobilltasksdefined = uar_i18ngetmessage(i18nhandle,"d3",
  "***NO BILLING TASKS ARE DEFINED***")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c26
     2 task_assay_disp_caps = c26
     2 task_assay_desc = c60
     2 date_of_service_cd = f8
     2 date_of_service_disp = c40
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
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE proc_last_row = i2 WITH protect, noconstant(0)
 DECLARE proc_last_page = i2 WITH protect, noconstant(0)
 DECLARE actual_page = i2 WITH protect, noconstant(0)
 DECLARE lrep200001count = i4 WITH protect, noconstant(0)
 DECLARE lrep200001index = i4 WITH protect, noconstant(0)
 DECLARE lprefixindex = i4 WITH protect, noconstant(0)
 DECLARE lprefixtaskcount = i4 WITH protect, noconstant(0)
 DECLARE prefix_sect_contd = c1 WITH protect, noconstant("N")
 DECLARE prefix_header_completed = c1 WITH protect, noconstant("N")
 DECLARE billing_header_completed = c1 WITH protect, noconstant("N")
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
 DECLARE ap_billing_type_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,ap_billing_type_cd)
 IF (ap_billing_type_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((((request->report_type_ind=0)) OR ((request->report_type_ind=1))) )
  SELECT INTO "nl:"
   task_descrip = uar_get_code_description(dta.task_assay_cd), task_disp_caps = cnvtupper(
    cnvtalphanum(uar_get_code_display(dta.task_assay_cd)))
   FROM order_catalog oc,
    profile_task_r ptr,
    discrete_task_assay dta,
    (dummyt d1  WITH seq = 1),
    ap_task_assay_addl ataa
   PLAN (oc
    WHERE oc.activity_subtype_cd=ap_billing_type_cd
     AND oc.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (d1)
    JOIN (ataa
    WHERE dta.task_assay_cd=ataa.task_assay_cd)
   ORDER BY oc.primary_mnemonic
   HEAD REPORT
    billing_cnt = 0
   DETAIL
    billing_cnt += 1
    IF (billing_cnt > size(temp->qual,5))
     stat = alterlist(temp->qual,(billing_cnt+ 9))
    ENDIF
    temp->qual[billing_cnt].task_assay_cd = dta.task_assay_cd, temp->qual[billing_cnt].
    date_of_service_cd = ataa.date_of_service_cd, temp->qual[billing_cnt].task_assay_disp =
    uar_get_code_display(dta.task_assay_cd),
    temp->qual[billing_cnt].task_assay_disp_caps = task_disp_caps, temp->qual[billing_cnt].
    task_assay_desc = task_descrip, temp->qual[billing_cnt].date_of_service_disp =
    uar_get_code_display(ataa.date_of_service_cd)
   FOOT REPORT
    stat = alterlist(temp->qual,billing_cnt)
   WITH nocounter, outerjoin = d1
  ;end select
 ENDIF
 IF ((((request->report_type_ind=2)) OR ((request->report_type_ind=0))) )
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
   SELECT INTO "nl:"
    task_disp_caps = cnvtupper(cnvtalphanum(uar_get_code_display(ptr.task_assay_cd)))
    FROM ap_prefix_task_r aptr,
     profile_task_r ptr,
     order_catalog oc
    PLAN (aptr
     WHERE aptr.ap_prefix_task_r_id > 0.0)
     JOIN (oc
     WHERE oc.catalog_cd=aptr.catalog_cd
      AND oc.activity_subtype_cd=ap_billing_type_cd
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
 EXECUTE cpm_create_file_name_logical "apsDbBillingTask", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF ((((request->report_type_ind=1)) OR ((request->report_type_ind=0))) )
  SELECT INTO value(reply->print_status_data.print_filename)
   task_assay_disp = temp->qual[d1.seq].task_assay_disp, task_assay_disp_caps = temp->qual[d1.seq].
   task_assay_disp_caps, task_assay_desc = temp->qual[d1.seq].task_assay_desc,
   date_of_service_cd = temp->qual[d1.seq].date_of_service_cd, date_of_service_disp = temp->qual[d1
   .seq].date_of_service_disp
   FROM (dummyt d1  WITH seq = value(size(temp->qual,5)))
   PLAN (d1)
   ORDER BY task_assay_disp_caps
   HEAD REPORT
    line1 = fillstring(125,"-"), line2 = fillstring(25,"-"), billing_header_completed = "N"
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
    CALL center(captions->dbbillingtaskstool,0,132), col 110,
    captions->ppage, col 117, curpage"###"
    IF (billing_header_completed="N")
     row + 2,
     CALL center(line2,0,maxcol), row + 1,
     CALL center(captions->billingtaskhead,0,maxcol), row + 1,
     CALL center(line2,0,maxcol),
     billing_header_completed = "Y"
    ENDIF
    IF (d1.seq > 0)
     row + 2, col 0, captions->task,
     col 28, captions->description, col 90,
     captions->dateofservice, row + 1, col 0,
     "--------------------------", col 28,
     "------------------------------------------------------------",
     col 90, "----------------------------------------"
    ELSE
     row + 2,
     CALL center(captions->nobilltasksdefined,0,maxcol)
    ENDIF
   DETAIL
    row + 1, col 0, task_assay_disp,
    col 28, task_assay_desc, col 90
    IF (date_of_service_cd=0)
     captions->notdefined
    ELSE
     date_of_service_disp
    ENDIF
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
   FOOT PAGE
    IF (((row+ 10) > maxrow))
     row 60, col 0, line1,
     row + 1, col 0, captions->apsrpt,
     today = concat(week," ",day), col 53, today,
     col 110, captions->ppage, col 117,
     curpage"###", row + 1, col 55,
     captions->continued
    ENDIF
   FOOT REPORT
    IF ((request->report_type_ind=1))
     row 60, col 0, line1,
     row + 1, col 0, captions->apsrpt,
     today = concat(week," ",day), col 53, today,
     col 110, captions->ppage, col 117,
     curpage"###", row + 1, col 55,
     captions->endofreport
    ENDIF
    proc_last_page = curpage, proc_last_row = row
   WITH nocounter, maxcol = 132, nullreport,
    maxrow = 63, compress
  ;end select
 ENDIF
 IF ((((request->report_type_ind=2)) OR ((request->report_type_ind=0))) )
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
    IF ((request->report_type_ind=0))
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
     CALL center(captions->dbbillingtaskstool,0,132), col 110,
     captions->ppage
     IF ((request->report_type_ind=0))
      actual_page = ((curpage+ proc_last_page) - 1)
     ELSE
      actual_page = (curpage+ proc_last_page)
     ENDIF
     col 117, actual_page"###"
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
     col 10, captions->billingtask, col 33,
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
      col 10, captions->billingtask, col 33,
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
    captions->ppage
    IF ((request->report_type_ind=0))
     actual_page = ((curpage+ proc_last_page) - 1)
    ELSE
     actual_page = (curpage+ proc_last_page)
    ENDIF
    col 117, actual_page"###", row + 1,
    col 55, captions->continued
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
 CALL echo(reply)
END GO
