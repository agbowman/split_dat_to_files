CREATE PROGRAM aps_prt_worklist:dba
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
 RECORD tempsrs(
   1 qual[1]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
 )
 RECORD temp1(
   1 ccnt = i4
   1 qual[*]
     2 case_id = f8
     2 patient_alias = c22
     2 encntr_id = f8
     2 person_name = vc
     2 accession_nbr = c21
     2 res_ini = c3
     2 res_person_id = f8
     2 path_ini = c3
     2 path_person_id = f8
     2 prefix_cd = f8
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 tag_qual[2]
       3 tag_type_flag = i2
       3 tag_separator = c1
     2 spec_ctr = i4
     2 spec_qual[*]
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 spec_descr = vc
       3 spec_tag = c7
       3 spec_seq = i4
       3 spec_fixative_cd = f8
       3 spec_fixative_disp = c40
       3 s_t_ctr = i4
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_mnemonic = vc
         4 t_description = vc
         4 t_comment_cnt = i4
         4 t_comments_long_text_id = f8
         4 t_comment[*]
           5 text = vc
         4 t_status_cd = f8
         4 t_status_disp = c40
         4 t_request_dt_tm = dq8
         4 t_create_inv_flag = i2
         4 t_requestor_name = vc
         4 t_worklist_nbr = i4
       3 s_slide_ctr = i4
       3 slide_qual[*]
         4 sl_slide_id = f8
         4 sl_tag_cd = f8
         4 sl_tag = c7
         4 sl_seq = i4
         4 sl_origin_modifier = c7
         4 s_s_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_mnemonic = vc
           5 t_description = vc
           5 t_comments_long_text_id = f8
           5 t_comment_cnt = i4
           5 t_comment[*]
             6 text = vc
           5 t_status_cd = f8
           5 t_status_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
       3 s_c_ctr = i4
       3 cass_qual[*]
         4 cass_id = f8
         4 cass_tag = c7
         4 cass_tag_cd = f8
         4 cass_seq = i4
         4 cass_origin_modifier = c7
         4 cass_pieces = c3
         4 cass_fixative_cd = f8
         4 cass_fixative_disp = c40
         4 s_c_t_ctr = i4
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_mnemonic = vc
           5 t_description = vc
           5 t_comments_long_text_id = f8
           5 t_comment_cnt = i4
           5 t_comment[*]
             6 text = vc
           5 t_status_cd = f8
           5 t_status_disp = c40
           5 t_request_dt_tm = dq8
           5 t_create_inv_flag = i2
           5 t_requestor_name = vc
           5 t_worklist_nbr = i4
         4 s_c_slide_ctr = i4
         4 slide_qual[*]
           5 s_slide_id = f8
           5 s_tag_cd = f8
           5 s_tag = c7
           5 s_seq = i4
           5 s_origin_modifier = c7
           5 s_c_s_t_ctr = i4
           5 t_qual[*]
             6 t_task_assay_cd = f8
             6 t_mnemonic = vc
             6 t_description = vc
             6 t_comments_long_text_id = f8
             6 t_comment_cnt = i4
             6 t_comment[*]
               7 text = vc
             6 t_status_cd = f8
             6 t_status_disp = c40
             6 t_request_dt_tm = dq8
             6 t_create_inv_flag = i2
             6 t_requestor_name = vc
             6 t_worklist_nbr = i4
 )
 RECORD reply(
   1 ops_event = vc
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
 RECORD captions(
   1 rpt = vc
   1 nm = vc
   1 ana = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 title = vc
   1 bye = vc
   1 pg = vc
   1 ser = vc
   1 task = vc
   1 all_task = vc
   1 cse = vc
   1 all_cse = vc
   1 thru = vc
   1 non_spec = vc
   1 task_stat = vc
   1 cas = vc
   1 tsk = vc
   1 id = vc
   1 pic = vc
   1 spec = vc
   1 con = vc
   1 com = vc
   1 cont = vc
   1 bat_no = vc
   1 assign = vc
   1 none = vc
   1 nm_id = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT:")
 SET captions->nm = uar_i18ngetmessage(i18nhandle,"t2","APS_PRT_WORKLIST.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t3","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t4","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t5","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t6","TIME:")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t7","PROCESSING TASK WORKLIST - DETAIL ")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t8","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t9","PAGE:")
 SET captions->ser = uar_i18ngetmessage(i18nhandle,"t10","Service Resource: ")
 SET captions->task = uar_i18ngetmessage(i18nhandle,"t11","            Task: ")
 SET captions->all_task = uar_i18ngetmessage(i18nhandle,"t12","All Tasks")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t13","            Case: ")
 SET captions->thru = uar_i18ngetmessage(i18nhandle,"t14","through")
 SET captions->all_cse = uar_i18ngetmessage(i18nhandle,"t15","All Cases")
 SET captions->bat_no = uar_i18ngetmessage(i18nhandle,"t16","    Batch Number: ")
 SET captions->non_spec = uar_i18ngetmessage(i18nhandle,"t17","None specified")
 SET captions->task_stat = uar_i18ngetmessage(i18nhandle,"t18","     Task Status: ")
 SET captions->cas = uar_i18ngetmessage(i18nhandle,"t19","CASE")
 SET captions->assign = uar_i18ngetmessage(i18nhandle,"t20","ASSIGNED")
 SET captions->tsk = uar_i18ngetmessage(i18nhandle,"t21","TASK")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"t22","ID/MODIFIER")
 SET captions->pic = uar_i18ngetmessage(i18nhandle,"t23","PIECES/FIXATIVE")
 SET captions->spec = uar_i18ngetmessage(i18nhandle,"t24","SPECIMEN")
 SET captions->con = uar_i18ngetmessage(i18nhandle,"t25","(cont.)")
 SET captions->com = uar_i18ngetmessage(i18nhandle,"t26","COMMENTS:")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t27","CONTINUED...")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"t28",
  "No cases found meeting established criteria.")
 SET captions->nm_id = uar_i18ngetmessage(i18nhandle,"t29","NAME/ID")
#script
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
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
 SET current_time = curtime3
 SET spec_ctr = 0
 SET s_slide_ctr = 0
 SET s_c_ctr = 0
 SET s_c_slide_ctr = 0
 SET ccnt = 0
 SET s_t_ctr = 0
 SET s_s_t_ctr = 0
 SET s_c_t_ctr = 0
 SET s_c_s_t_ctr = 0
 SET max_spec_ctr = 0
 SET max_s_slide_ctr = 0
 SET max_s_c_ctr = 0
 SET max_s_c_slide_ctr = 0
 SET max_s_t_ctr = 0
 SET max_s_s_t_ctr = 0
 SET max_s_c_t_ctr = 0
 SET max_s_c_s_t_ctr = 0
 DECLARE mrn_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE current_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE billing_task_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_code = f8 WITH protect, noconstant(0.0)
 DECLARE ordered_code = f8 WITH protect, noconstant(0.0)
 DECLARE verified_code = f8 WITH protect, noconstant(0.0)
 DECLARE nworklistnbrind = i2 WITH protect, noconstant(0)
 DECLARE lorderlistcnt = i4 WITH protect, noconstant(0)
 DECLARE llocvalindex = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 CALL cr_createrequest(0,200455,"REQ200455")
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(213,"PRSNL",1,current_type_cd)
 IF (current_type_cd=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - PRSNL"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,billing_task_cd)
 IF (billing_task_cd=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - APBILLING"
 ENDIF
 SET str_task_assay_where = fillstring(1000," ")
 IF (textlen(trim(request->batch_selection)) > 0)
  DECLARE text = c100
  DECLARE real = f8
  DECLARE six = i2
  DECLARE pos = i2
  DECLARE startpos2 = i2
  DECLARE len = i4
  DECLARE endstring = c2
  SUBROUTINE get_text(startpos,textstring,delimit)
    SET siz = size(trim(textstring),1)
    SET pos = startpos
    SET endstring = "F"
    WHILE (pos <= siz)
     IF (substring(pos,1,trim(textstring))=delimit)
      IF (pos=siz)
       SET endstring = "T"
      ENDIF
      SET len = (pos - startpos)
      SET text = substring(startpos,len,trim(textstring))
      SET real = cnvtreal(trim(text))
      SET startpos = (pos+ 1)
      SET startpos2 = (pos+ 1)
      SET pos = siz
     ENDIF
     SET pos += 1
    ENDWHILE
  END ;Subroutine
  SET raw_service_resource_str = fillstring(100," ")
  SET raw_task_assay_str = fillstring(100," ")
  SET printer = fillstring(100," ")
  SET copies = 0
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Failure - Error with output_dist!"
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|"), raw_service_resource_str = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    raw_task_assay_str = trim(text), request->scuruser = "Operations",
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->nbr_blank_lines = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->beg_acc = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->end_acc = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->worklist_nbr = cnvtint(trim(text)),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->srun_number = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->stask_status = trim(text),
    request->resend_ind = 1,
    CALL get_text(1,trim(request->output_dist),"|"), printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"),
    copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  IF (textlen(trim(raw_service_resource_str)) > 0)
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE 221=cv.code_set
     AND raw_service_resource_str=cv.display
     AND cv.active_ind=1
    DETAIL
     request->service_resource_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->ops_event = "Failure - Error with service_resource id!"
    GO TO exit_program
   ENDIF
  ELSE
   SET request->service_resource_cd = 0
  ENDIF
  IF (textlen(trim(raw_task_assay_str)) > 0)
   SELECT INTO "nl:"
    dta.task_assay_cd
    FROM discrete_task_assay dta
    WHERE raw_task_assay_str=dta.mnemonic
    DETAIL
     request->task_assay_cd = dta.task_assay_cd, request->task_assay_disp = dta.mnemonic
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=1310
       AND raw_task_assay_str=cv.display)
     DETAIL
      request->task_assay_cd = cv.code_value, request->task_assay_disp = cv.display
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = "Failure - Error with task_assay id!"
     GO TO exit_program
    ENDIF
   ENDIF
  ELSE
   SET request->task_assay_cd = 0
  ENDIF
 ENDIF
 IF ((request->task_assay_cd > 0))
  SELECT INTO "nl:"
   FROM ap_processing_grp_r apgr
   WHERE (request->task_assay_cd=apgr.parent_entity_id)
   ORDER BY apgr.task_assay_cd
   HEAD REPORT
    str_task_assay_where = "pt.task_assay_cd in ("
   DETAIL
    str_task_assay_where = concat(trim(str_task_assay_where),cnvtstring(apgr.task_assay_cd,32,2),", "
     )
   FOOT REPORT
    templen = textlen(trim(str_task_assay_where)), str_task_assay_where = concat(substring(1,(templen
       - 1),trim(str_task_assay_where)),") ")
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET str_task_assay_where = "pt.task_assay_cd = request->task_assay_cd"
  ENDIF
 ELSE
  SET str_task_assay_where = "0 = 0"
 ENDIF
 IF ((request->beg_acc > " ")
  AND (request->end_acc > " "))
  SET accession_where = "pc.accession_nbr between request->beg_acc and request->end_acc"
 ELSE
  SET accession_where = "0 = 0"
 ENDIF
 IF ((request->srun_number="R"))
  SET run_number_where = "pt.worklist_nbr = request->worklist_nbr"
  SET nworklistnbrind = 1
 ELSEIF ((request->srun_number="A"))
  SET run_number_where = "0 = 0"
 ELSEIF ((request->srun_number="U"))
  SET run_number_where = "pt.worklist_nbr = request->worklist_nbr"
  SET nworklistnbrind = 1
 ENDIF
 IF (nworklistnbrind=1)
  IF ((request->stask_status="V"))
   SET task_status_where = "pt.status_cd+0 in (verified_code, processing_code)"
   SET task_status = "Verified tasks only"
  ELSEIF ((request->stask_status="U"))
   SET task_status_where = "ordered_code = pt.status_cd+0"
   SET task_status = "Unverified tasks only"
  ELSEIF ((request->stask_status="B"))
   SET task_status_where = "pt.status_cd+0 in (verified_code, ordered_code, processing_code)"
   SET task_status = "Both Verified and Unverified tasks"
  ENDIF
 ELSE
  IF ((request->beg_acc > " ")
   AND (request->end_acc > " "))
   IF ((request->stask_status="V"))
    SET task_status_where = "pt.status_cd+0 in (verified_code, processing_code)"
    SET task_status = "Verified tasks only"
   ELSEIF ((request->stask_status="U"))
    SET task_status_where = "ordered_code = pt.status_cd+0"
    SET task_status = "Unverified tasks only"
   ELSEIF ((request->stask_status="B"))
    SET task_status_where = "pt.status_cd+0 in (verified_code, ordered_code, processing_code)"
    SET task_status = "Both Verified and Unverified tasks"
   ENDIF
  ELSE
   IF ((request->stask_status="V"))
    SET task_status_where = "pt.status_cd in (verified_code, processing_code)"
    SET task_status = "Verified tasks only"
   ELSEIF ((request->stask_status="U"))
    SET task_status_where = "ordered_code = pt.status_cd"
    SET task_status = "Unverified tasks only"
   ELSEIF ((request->stask_status="B"))
    SET task_status_where = "pt.status_cd in (verified_code, ordered_code, processing_code)"
    SET task_status = "Both Verified and Unverified tasks"
   ENDIF
  ENDIF
 ENDIF
 SET cntr = 0
 SELECT INTO "nl:"
  rg.child_service_resource_cd
  FROM resource_group rg
  WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
   AND rg.active_ind=1
   AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
   AND rg.end_effective_dt_tm > cnvtdatetime(sysdate)
  HEAD REPORT
   cntr += 1, tempsrs->qual[cntr].service_resource_cd = request->service_resource_cd, tempsrs->qual[
   cntr].service_resource_disp = uar_get_code_display(request->service_resource_cd)
  DETAIL
   cntr += 1
   IF (cntr > 1)
    stat = alter(tempsrs->qual,cntr)
   ENDIF
   tempsrs->qual[cntr].service_resource_cd = rg.child_service_resource_cd, tempsrs->qual[cntr].
   service_resource_disp = uar_get_code_display(rg.child_service_resource_cd)
  WITH nocounter
 ;end select
 IF (cntr=0)
  SET tempsrs->qual[1].service_resource_cd = request->service_resource_cd
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   WHERE 221=cv.code_set
    AND (tempsrs->qual[1].service_resource_cd=cv.code_value)
    AND cv.active_ind=1
   DETAIL
    tempsrs->qual[1].service_resource_disp = trim(cv.display)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1305,"ORDERED",1,ordered_code)
 SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_code)
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_code)
 IF (ordered_code=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - ORDERED"
  GO TO exit_script
 ENDIF
 IF (processing_code=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - PROCESSING"
  GO TO exit_script
 ENDIF
 IF (verified_code=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - VERIFIED"
  GO TO exit_script
 ENDIF
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt += 1
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_program
 ENDIF
 SELECT
  IF ((request->beg_acc > " ")
   AND (request->end_acc > " "))
   PLAN (pc
    WHERE parser(accession_where))
    JOIN (d)
    JOIN (pt
    WHERE (tempsrs->qual[d.seq].service_resource_cd=pt.service_resource_cd)
     AND pt.case_id=pc.case_id
     AND parser(task_status_where)
     AND parser(str_task_assay_where)
     AND parser(run_number_where))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (dta
    WHERE pt.task_assay_cd=dta.task_assay_cd)
    JOIN (p
    WHERE pt.request_prsnl_id=p.person_id)
  ELSE
   PLAN (d)
    JOIN (pt
    WHERE (tempsrs->qual[d.seq].service_resource_cd=pt.service_resource_cd)
     AND parser(task_status_where)
     AND parser(str_task_assay_where)
     AND parser(run_number_where))
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (dta
    WHERE pt.task_assay_cd=dta.task_assay_cd)
    JOIN (p
    WHERE pt.request_prsnl_id=p.person_id)
    JOIN (pc
    WHERE pt.case_id=pc.case_id)
  ENDIF
  INTO "nl:"
  pt.case_id, pt.case_specimen_id, pt.cassette_id,
  pt.slide_id, ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0), ncreateblock = evaluate(pt
   .create_inventory_flag,1,1,2,0,
   3,1,4,0,0,
   0),
  ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
   3,1,4,0,0,
   0), ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
   tag_id), ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2].
   tag_id),
  ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].tag_id)
  FROM processing_task pt,
   (dummyt d  WITH seq = value(cnvtint(size(tempsrs->qual,5)))),
   discrete_task_assay dta,
   order_catalog oc,
   profile_task_r ptr,
   prsnl p,
   pathology_case pc
  ORDER BY pc.accession_nbr, ap_tag_spec_idx, ncreatespecimen DESC,
   ap_tag_cass_idx, pt.cassette_id, ncreateblock DESC,
   ap_tag_slide_idx, pt.slide_id, ncreateslide DESC,
   pt.request_dt_tm
  HEAD REPORT
   spec_ctr = 0, s_slide_ctr = 0, s_c_ctr = 0,
   s_c_slide_ctr = 0, ccnt = 0, s_t_ctr = 0,
   s_s_t_ctr = 0, s_c_t_ctr = 0, s_c_s_t_ctr = 0,
   max_spec_ctr = 0, max_s_slide_ctr = 0, max_s_c_ctr = 0,
   max_s_c_slide_ctr = 0, max_s_t_ctr = 0, max_s_s_t_ctr = 0,
   max_s_c_t_ctr = 0, max_s_c_s_t_ctr = 0, isslideduplicate = "N"
  HEAD pc.accession_nbr
   ccnt += 1
   IF (ccnt > size(temp1->qual,5))
    stat = alterlist(temp1->qual,(ccnt+ 49))
   ENDIF
   temp1->qual[ccnt].case_id = pt.case_id, temp1->ccnt = ccnt, temp1->qual[ccnt].service_resource_cd
    = pt.service_resource_cd,
   spec_ctr = 0
  HEAD ap_tag_spec_idx
   spec_ctr += 1
   IF (spec_ctr > max_spec_ctr)
    max_spec_ctr = spec_ctr
   ENDIF
   IF (spec_ctr > size(temp1->qual[ccnt].spec_qual,5))
    stat = alterlist(temp1->qual[ccnt].spec_qual,(spec_ctr+ 9))
   ENDIF
   temp1->qual[ccnt].spec_ctr = spec_ctr, temp1->qual[ccnt].spec_qual[spec_ctr].case_specimen_id = pt
   .case_specimen_id, temp1->qual[ccnt].spec_qual[spec_ctr].case_specimen_tag_cd = pt
   .case_specimen_tag_id,
   s_c_ctr = 0, s_slide_ctr = 0, s_t_ctr = 0
  HEAD pt.cassette_id
   IF (pt.cassette_id != 0.0)
    s_c_ctr += 1
    IF (s_c_ctr > max_s_c_ctr)
     max_s_c_ctr = s_c_ctr
    ENDIF
    IF (s_c_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual,5))
     stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual,(s_c_ctr+ 9))
    ENDIF
    temp1->qual[ccnt].spec_qual[spec_ctr].s_c_ctr = s_c_ctr, temp1->qual[ccnt].spec_qual[spec_ctr].
    cass_qual[s_c_ctr].cass_id = pt.cassette_id, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[
    s_c_ctr].cass_tag_cd = pt.cassette_tag_id
   ENDIF
   s_c_slide_ctr = 0, s_c_t_ctr = 0
  HEAD pt.slide_id
   IF (pt.cassette_id != 0.00)
    IF (pt.slide_id != 0.00)
     isslideduplicate = "N"
     IF (s_c_slide_ctr > 0)
      IF ((pt.slide_id=temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].s_slide_id))
       isslideduplicate = "Y"
      ENDIF
     ENDIF
     IF (isslideduplicate="N")
      s_c_slide_ctr += 1
      IF (s_c_slide_ctr > max_s_c_slide_ctr)
       max_s_c_slide_ctr = s_c_slide_ctr
      ENDIF
      temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_slide_ctr = s_c_slide_ctr
      IF (s_c_slide_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,5)
      )
       stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,(
        s_c_slide_ctr+ 9))
      ENDIF
      temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_slide_id
       = pt.slide_id, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].s_tag_cd = pt.slide_tag_id, s_c_s_t_ctr = 0
     ENDIF
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     s_slide_ctr += 1
     IF (s_slide_ctr > max_s_slide_ctr)
      max_s_slide_ctr = s_slide_ctr
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].s_slide_ctr = s_slide_ctr
     IF (s_slide_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual,5))
      stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual,(s_slide_ctr+ 9))
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].sl_slide_id = pt.slide_id, temp1->
     qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].sl_tag_cd = pt.slide_tag_id, s_s_t_ctr =
     0
    ENDIF
   ENDIF
  DETAIL
   IF (pt.cassette_id > 0)
    IF (pt.slide_id > 0)
     s_c_s_t_ctr += 1
     IF (s_c_s_t_ctr > max_s_c_s_t_ctr)
      max_s_c_s_t_ctr = s_c_s_t_ctr
     ENDIF
     IF (s_c_s_t_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual,5))
      stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
       s_c_slide_ctr].t_qual,(s_c_s_t_ctr+ 9))
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_c_s_t_ctr
      = s_c_s_t_ctr, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_task_assay_cd = dta.task_assay_cd, temp1->qual[ccnt].
     spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_mnemonic
      = dta.mnemonic,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_description = dta.description, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[
     s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_comments_long_text_id = pt
     .comments_long_text_id, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_status_cd = pt.status_cd,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, temp1->qual[ccnt].spec_qual[spec_ctr].
     cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_requestor_name = p
     .name_full_formatted, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_create_inv_flag = pt.create_inventory_flag
    ELSE
     s_c_t_ctr += 1
     IF (s_c_t_ctr > max_s_c_t_ctr)
      max_s_c_t_ctr = s_c_t_ctr
     ENDIF
     IF (s_c_t_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,5))
      stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,(s_c_t_ctr+ 9)
       )
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_t_ctr = s_c_t_ctr, temp1->qual[ccnt
     ].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_task_assay_cd = dta.task_assay_cd,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_mnemonic = dta
     .mnemonic,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_description = dta
     .description, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_comments_long_text_id = pt.comments_long_text_id, temp1->qual[ccnt].spec_qual[spec_ctr].
     cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_status_cd = pt.status_cd,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_requestor_name = p
     .name_full_formatted, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr]
     .t_request_dt_tm = pt.request_dt_tm, temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].
     t_qual[s_c_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_create_inv_flag =
     pt.create_inventory_flag
    ENDIF
   ELSE
    IF (pt.slide_id > 0)
     s_s_t_ctr += 1
     IF (s_s_t_ctr > max_s_s_t_ctr)
      max_s_s_t_ctr = s_s_t_ctr
     ENDIF
     IF (s_s_t_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,5))
      stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,(
       s_s_t_ctr+ 9))
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].s_s_t_ctr = s_s_t_ctr, temp1->
     qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_task_assay_cd = dta
     .task_assay_cd, temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_mnemonic = dta.mnemonic,
     temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_description =
     dta.description, temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr]
     .t_comments_long_text_id = pt.comments_long_text_id, temp1->qual[ccnt].spec_qual[spec_ctr].
     slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_status_cd = pt.status_cd,
     temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_requestor_name
      = p.name_full_formatted, temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[
     s_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[
     s_slide_ctr].t_qual[s_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_create_inv_flag = pt.create_inventory_flag
    ELSE
     s_t_ctr += 1
     IF (s_t_ctr > max_s_t_ctr)
      max_s_t_ctr = s_t_ctr
     ENDIF
     IF (s_t_ctr > size(temp1->qual[ccnt].spec_qual[spec_ctr].t_qual,5))
      stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].t_qual,(s_t_ctr+ 9))
     ENDIF
     temp1->qual[ccnt].spec_qual[spec_ctr].s_t_ctr = s_t_ctr, temp1->qual[ccnt].spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_task_assay_cd = dta.task_assay_cd, temp1->qual[ccnt].spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_mnemonic = dta.mnemonic,
     temp1->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_description = dta.description, temp1->
     qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_comments_long_text_id = pt
     .comments_long_text_id, temp1->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_status_cd = pt
     .status_cd,
     temp1->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_requestor_name = p.name_full_formatted,
     temp1->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_request_dt_tm = pt.request_dt_tm, temp1
     ->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     temp1->qual[ccnt].spec_qual[spec_ctr].t_qual[s_t_ctr].t_create_inv_flag = pt
     .create_inventory_flag
    ENDIF
   ENDIF
   IF ((request->resend_ind > 0))
    lindex = locateval(llocvalindex,1,lorderlistcnt,pt.order_id,req200455->order_list[llocvalindex].
     order_id)
    IF (lindex=0)
     lorderlistcnt += 1
     IF (mod(lorderlistcnt,10)=1)
      stat = alterlist(req200455->order_list,(lorderlistcnt+ 9))
     ENDIF
     req200455->order_list[lorderlistcnt].order_id = pt.order_id
    ENDIF
   ENDIF
  FOOT  pt.slide_id
   IF (pt.cassette_id != 0.00)
    IF (pt.slide_id != 0.00)
     stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
      s_c_slide_ctr].t_qual,s_c_s_t_ctr)
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,s_s_t_ctr)
    ENDIF
   ENDIF
  FOOT  pt.cassette_id
   IF (pt.cassette_id != 0.0)
    stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,
     s_c_slide_ctr), stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,
     s_c_t_ctr)
   ENDIF
  FOOT  ap_tag_spec_idx
   stat = alterlist(temp1->qual[ccnt].spec_qual[spec_ctr].cass_qual,s_c_ctr), stat = alterlist(temp1
    ->qual[ccnt].spec_qual[spec_ctr].slide_qual,s_slide_ctr), stat = alterlist(temp1->qual[ccnt].
    spec_qual[spec_ctr].t_qual,s_t_ctr)
  FOOT  pc.accession_nbr
   stat = alterlist(temp1->qual[ccnt].spec_qual,spec_ctr)
  FOOT REPORT
   stat = alterlist(temp1->qual,ccnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  GO TO report_section
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_t_ctr != 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d.seq].spec_qual[d1.seq].s_t_ctr)
     AND (temp1->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comments_long_text_id=lt
    .long_text_id))
   DETAIL
    blob_cntr = 0,
    CALL rtf_to_text(lt.long_text,1,90)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp1->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comment,
       blob_cntr), temp1->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comment_cnt = blob_cntr,
      temp1->qual[d.seq].spec_qual[d1.seq].t_qual[d2.seq].t_comment[blob_cntr].text = trim(tmptext->
       qual[z].text)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_slide_ctr != 0
  AND max_s_s_t_ctr != 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_slide_ctr)),
    (dummyt d3  WITH seq = value(max_s_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d.seq].spec_qual[d1.seq].s_slide_ctr))
    JOIN (d3
    WHERE (d3.seq <= temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].s_s_t_ctr)
     AND (temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    blob_cntr = 0,
    CALL rtf_to_text(lt.long_text,1,90)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].
       t_qual[d3.seq].t_comment,blob_cntr), temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].
      t_qual[d3.seq].t_comment_cnt = blob_cntr,
      temp1->qual[d.seq].spec_qual[d1.seq].slide_qual[d2.seq].t_qual[d3.seq].t_comment[blob_cntr].
      text = trim(tmptext->qual[z].text)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_c_ctr != 0
  AND max_s_c_t_ctr != 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr)),
    (dummyt d3  WITH seq = value(max_s_c_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (d3
    WHERE (d3.seq <= temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].s_c_t_ctr)
     AND (temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    blob_cntr = 0,
    CALL rtf_to_text(lt.long_text,1,90)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[
       d3.seq].t_comment,blob_cntr), temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3
      .seq].t_comment_cnt = blob_cntr,
      temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].t_qual[d3.seq].t_comment[blob_cntr].text
       = trim(tmptext->qual[z].text)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_c_ctr != 0
  AND max_s_c_slide_ctr != 0
  AND max_s_c_s_t_ctr != 0)
  SELECT INTO "nl:"
   lt.long_text_id
   FROM (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr)),
    (dummyt d3  WITH seq = value(max_s_c_slide_ctr)),
    (dummyt d4  WITH seq = value(max_s_c_s_t_ctr)),
    long_text lt
   PLAN (d)
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (d3
    WHERE (d3.seq <= temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].s_c_slide_ctr))
    JOIN (d4
    WHERE (d4.seq <= temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].
    s_c_s_t_ctr)
     AND (temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
    t_comments_long_text_id > 0))
    JOIN (lt
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
    t_comments_long_text_id=lt.long_text_id))
   DETAIL
    blob_cntr = 0,
    CALL rtf_to_text(lt.long_text,1,90)
    FOR (z = 1 TO size(tmptext->qual,5))
      blob_cntr += 1, stat = alterlist(temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].
       slide_qual[d3.seq].t_qual[d4.seq].t_comment,blob_cntr), temp1->qual[d.seq].spec_qual[d1.seq].
      cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].t_comment_cnt = blob_cntr,
      temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].slide_qual[d3.seq].t_qual[d4.seq].
      t_comment[blob_cntr].text = trim(tmptext->qual[z].text)
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_alias_type_cd)
 IF (mrn_alias_type_cd=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - MRN"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.accession_nbr, pc.prefix_id
  FROM pathology_case pc,
   (dummyt d  WITH seq = value(temp1->ccnt)),
   ap_prefix_tag_group_r aptg_r,
   (dummyt d2  WITH seq = 1),
   person pr
  PLAN (d
   WHERE (temp1->qual[d.seq].case_id > 0))
   JOIN (pc
   WHERE (temp1->qual[d.seq].case_id=pc.case_id)
    AND parser(accession_where))
   JOIN (pr
   WHERE pc.person_id=pr.person_id)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (aptg_r
   WHERE pc.prefix_id=aptg_r.prefix_id
    AND aptg_r.tag_type_flag > 1)
  ORDER BY pc.prefix_id, pc.accession_nbr, aptg_r.tag_type_flag
  HEAD REPORT
   tag_ctr = 0
  HEAD pc.prefix_id
   tag_ctr = 0
  DETAIL
   temp1->qual[d.seq].accession_nbr = pc.accession_nbr, temp1->qual[d.seq].res_person_id = pc
   .responsible_resident_id, temp1->qual[d.seq].path_person_id = pc.responsible_pathologist_id,
   temp1->qual[d.seq].encntr_id = pc.encntr_id, temp1->qual[d.seq].prefix_cd = pc.prefix_id, temp1->
   qual[d.seq].person_name = pr.name_full_formatted
   IF (tag_ctr < 2)
    tag_ctr += 1, temp1->qual[d.seq].tag_qual[tag_ctr].tag_type_flag = aptg_r.tag_type_flag, temp1->
    qual[d.seq].tag_qual[tag_ctr].tag_separator = aptg_r.tag_separator
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "prefix_tag_group_r"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(size(temp1->qual,5))),
   (dummyt d2  WITH seq = 1),
   encntr_alias ea
  PLAN (d1
   WHERE (temp1->qual[d1.seq].encntr_id > 0))
   JOIN (d2)
   JOIN (ea
   WHERE (ea.encntr_id=temp1->qual[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF ((ea.encntr_id=temp1->qual[d1.seq].encntr_id))
    temp1->qual[d1.seq].patient_alias = frmt_mrn
   ELSE
    temp1->qual[d1.seq].patient_alias = "Unknown"
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 IF (max_spec_ctr != 0)
  SELECT INTO "nl:"
   cs.specimen_description
   FROM case_specimen cs,
    (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr))
   PLAN (d
    WHERE (temp1->qual[d.seq].accession_nbr > " "))
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (cs
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].case_specimen_id=cs.case_specimen_id)
     AND cs.case_specimen_id > 0)
   DETAIL
    temp1->qual[d.seq].spec_qual[d1.seq].spec_descr = cs.specimen_description, temp1->qual[d.seq].
    spec_qual[d1.seq].spec_fixative_cd = cs.received_fixative_cd, ap_tag_spec_idx = locateval(idx1,1,
     ap_tag_cnt,cs.specimen_tag_id,temp_ap_tag->qual[idx1].tag_id)
    IF (ap_tag_spec_idx > 0)
     temp1->qual[d.seq].spec_qual[d1.seq].spec_tag = temp_ap_tag->qual[ap_tag_spec_idx].tag_disp,
     temp1->qual[d.seq].spec_qual[d1.seq].spec_seq = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (max_spec_ctr != 0)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv,
    (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr))
   PLAN (d
    WHERE (temp1->qual[d.seq].accession_nbr > " "))
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr)
     AND (temp1->qual[d.seq].spec_qual[d1.seq].spec_fixative_cd > 0))
    JOIN (cv
    WHERE cv.code_set=1302
     AND (temp1->qual[d.seq].spec_qual[d1.seq].spec_fixative_cd=cv.code_value))
   DETAIL
    temp1->qual[d.seq].spec_qual[d1.seq].spec_fixative_disp = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_c_ctr != 0)
  SELECT INTO "nl:"
   c.pieces
   FROM cassette c,
    code_value cv,
    (dummyt d  WITH seq = value(temp1->ccnt)),
    (dummyt d1  WITH seq = value(max_spec_ctr)),
    (dummyt d2  WITH seq = value(max_s_c_ctr)),
    dummyt d3
   PLAN (d
    WHERE (temp1->qual[d.seq].accession_nbr > " "))
    JOIN (d1
    WHERE (d1.seq <= temp1->qual[d.seq].spec_ctr))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d.seq].spec_qual[d1.seq].s_c_ctr))
    JOIN (c
    WHERE (temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_id=c.cassette_id))
    JOIN (d3)
    JOIN (cv
    WHERE cv.code_set=1302
     AND c.fixative_cd=cv.code_value)
   DETAIL
    ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,c.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id)
    IF (ap_tag_cass_idx > 0)
     temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_tag = temp_ap_tag->qual[
     ap_tag_cass_idx].tag_disp, temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_seq =
     temp_ap_tag->qual[ap_tag_cass_idx].tag_sequence
    ENDIF
    temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_pieces = c.pieces, temp1->qual[d.seq]
    .spec_qual[d1.seq].cass_qual[d2.seq].cass_origin_modifier = c.origin_modifier, temp1->qual[d.seq]
    .spec_qual[d1.seq].cass_qual[d2.seq].cass_fixative_cd = c.fixative_cd,
    temp1->qual[d.seq].spec_qual[d1.seq].cass_qual[d2.seq].cass_fixative_disp = cv.display
   WITH nocounter, outerjoin = d3
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE TAGS, AP_TAG"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_slide_ctr != 0)
  SELECT INTO "nl:"
   FROM slide s,
    (dummyt d1  WITH seq = value(temp1->ccnt)),
    (dummyt d2  WITH seq = value(max_spec_ctr)),
    (dummyt d3  WITH seq = value(max_s_slide_ctr))
   PLAN (d1
    WHERE (temp1->qual[d1.seq].accession_nbr > " "))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d1.seq].spec_ctr))
    JOIN (d3
    WHERE (d3.seq <= temp1->qual[d1.seq].spec_qual[d2.seq].s_slide_ctr))
    JOIN (s
    WHERE (temp1->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_slide_id=s.slide_id))
   DETAIL
    ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id)
    IF (ap_tag_slide_idx > 0)
     temp1->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_tag = temp_ap_tag->qual[
     ap_tag_slide_idx].tag_disp, temp1->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_seq =
     temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
    ENDIF
    temp1->qual[d1.seq].spec_qual[d2.seq].slide_qual[d3.seq].sl_origin_modifier = s.origin_modifier
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE TAGS, AP_TAG"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (max_spec_ctr != 0
  AND max_s_c_ctr != 0
  AND max_s_c_slide_ctr != 0)
  SELECT INTO "nl:"
   FROM slide s,
    (dummyt d1  WITH seq = value(temp1->ccnt)),
    (dummyt d2  WITH seq = value(max_spec_ctr)),
    (dummyt d3  WITH seq = value(max_s_c_ctr)),
    (dummyt d4  WITH seq = value(max_s_c_slide_ctr))
   PLAN (d1
    WHERE (temp1->qual[d1.seq].accession_nbr > " "))
    JOIN (d2
    WHERE (d2.seq <= temp1->qual[d1.seq].spec_ctr))
    JOIN (d3
    WHERE (d3.seq <= temp1->qual[d1.seq].spec_qual[d2.seq].s_c_ctr))
    JOIN (d4
    WHERE (d4.seq <= temp1->qual[d1.seq].spec_qual[d2.seq].cass_qual[d3.seq].s_c_slide_ctr))
    JOIN (s
    WHERE (temp1->qual[d1.seq].spec_qual[d2.seq].cass_qual[d3.seq].slide_qual[d4.seq].s_slide_id=s
    .slide_id))
   DETAIL
    ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id)
    IF (ap_tag_slide_idx > 0)
     temp1->qual[d1.seq].spec_qual[d2.seq].cass_qual[d3.seq].slide_qual[d4.seq].s_tag = temp_ap_tag->
     qual[ap_tag_slide_idx].tag_disp, temp1->qual[d1.seq].spec_qual[d2.seq].cass_qual[d3.seq].
     slide_qual[d4.seq].s_seq = temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
    ENDIF
    temp1->qual[d1.seq].spec_qual[d2.seq].cass_qual[d3.seq].slide_qual[d4.seq].s_origin_modifier = s
    .origin_modifier
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE TAGS, AP_TAG"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  p1.name_initials, p2.name_initials, join_path = decode(d2.seq,"P1",d3.seq,"P2","")
  FROM person_name p1,
   person_name p2,
   (dummyt d1  WITH seq = value(temp1->ccnt)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d1
   WHERE (temp1->qual[d1.seq].accession_nbr > " "))
   JOIN (((d2
   WHERE 1=d2.seq)
   JOIN (p1
   WHERE (temp1->qual[d1.seq].res_person_id=p1.person_id)
    AND current_type_cd=p1.name_type_cd
    AND p1.active_ind=1
    AND p1.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((p1.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (p1.end_effective_dt_tm=null)) )
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (p2
   WHERE (temp1->qual[d1.seq].path_person_id=p2.person_id)
    AND current_type_cd=p2.name_type_cd
    AND p2.active_ind=1
    AND p2.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ((p2.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (p2.end_effective_dt_tm=null)) )
   ))
  DETAIL
   CASE (join_path)
    OF "P1":
     temp1->qual[d1.seq].res_ini = substring(1,3,p1.name_initials)
    OF "P2":
     temp1->qual[d1.seq].path_ini = substring(1,3,p2.name_initials)
   ENDCASE
  WITH nocounter
 ;end select
 IF ((request->resend_ind > 0)
  AND lorderlistcnt > 0)
  SET stat = alterlist(req200455->order_list,lorderlistcnt)
  SET req200455->resend_ind = request->resend_ind
  EXECUTE aps_send_instrmt_protocol  WITH replace("REQUEST","REQ200455"), replace("REPLY","REP200455"
   )
 ENDIF
#report_section
 EXECUTE cpm_create_file_name_logical "aps_worklist", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 DECLARE uar_fmt_accession(p1,p2) = c25
 SELECT INTO reply->print_status_data.print_filename
  x = 0, raw_accession_nbr = temp1->qual[d.seq].accession_nbr
  FROM (dummyt d  WITH seq = value(size(temp1->qual,5)))
  PLAN (d
   WHERE (temp1->qual[d.seq].accession_nbr > " "))
  ORDER BY raw_accession_nbr
  HEAD REPORT
   line1 = fillstring(125,"-"), blob = fillstring(25," "), shortblob = fillstring(20," "),
   line2 = fillstring(116,"-"), cass_pieces = "   ", found_cases = 0,
   alias_printed = 0, bbreak = 0, scuraccession = fillstring(22," "),
   scurname = fillstring(23," ")
  HEAD PAGE
   row + 1, col 0, captions->rpt,
   col + 1, captions->nm, col 56,
   CALL center(captions->ana,row,132), col 110, captions->dt,
   col 117, curdate"@SHORTDATE;;D", row + 1,
   col 0, captions->dir, col 110,
   captions->tm, col 117, curtime"@TIMENOSECONDS;;M",
   row + 1, col 52,
   CALL center(captions->title,row,132),
   col 112, captions->bye, col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 0, captions->ser,
   num_of_resources = value(size(tempsrs->qual,5)), col 18
   FOR (loop = 1 TO num_of_resources)
    tempsrs->qual[loop].service_resource_disp,
    IF (num_of_resources > 1
     AND loop < num_of_resources)
     ",", col + 1
     IF (col > 91)
      row + 1, col 18
     ENDIF
    ENDIF
   ENDFOR
   row + 1, col 0, captions->task
   IF ((request->task_assay_disp > " "))
    col 18, request->task_assay_disp
   ELSE
    col 18, captions->all_task
   ENDIF
   row + 1, col 0, captions->cse
   IF ((request->beg_acc > " "))
    beg_acc = uar_fmt_accession(request->beg_acc,size(trim(request->beg_acc),1)), end_acc =
    uar_fmt_accession(request->end_acc,size(trim(request->end_acc),1)), col 18,
    beg_acc, col + 1, captions->thru,
    col + 1, end_acc
   ELSE
    col 18, captions->all_cse
   ENDIF
   row + 1, col 0, captions->bat_no
   IF ((request->worklist_nbr > 0))
    col 18, request->worklist_nbr
   ELSE
    col 18, captions->non_spec
   ENDIF
   row + 1, col 0, captions->task_stat,
   col 18, task_status, row + 2,
   col 0, captions->cas, col 20,
   captions->nm_id, col 43, captions->assign,
   col 53, captions->tsk, col 69,
   captions->id, col 90, captions->pic,
   col 109, captions->spec, row + 1,
   col 0, line1, row + 1
   IF (bbreak=1)
    col 0, scuraccession, col 21,
    captions->con, bbreak = 0, name_printed_row = row,
    alias_printed_row = (name_printed_row+ 1)
   ENDIF
  DETAIL
   IF (((row+ 6) > maxrow))
    bbreak = 1, BREAK
   ENDIF
   scuraccession = uar_fmt_accession(temp1->qual[d.seq].accession_nbr,size(temp1->qual[d.seq].
     accession_nbr,1)), col 0, scuraccession,
   scurname = temp1->qual[d.seq].person_name, col 20, scurname"######################",
   col 43, temp1->qual[d.seq].path_ini"###", col 48,
   temp1->qual[d.seq].res_ini"###", name_printed_row = row, alias_printed_row = (name_printed_row+ 1),
   alias_printed = 0
   IF (size(temp1->qual[d.seq].tag_qual,5) > 0)
    IF ((temp1->qual[d.seq].tag_qual[1].tag_type_flag=2))
     sep1 = temp1->qual[d.seq].tag_qual[1].tag_separator, sep2 = temp1->qual[d.seq].tag_qual[2].
     tag_separator
    ELSEIF ((temp1->qual[d.seq].tag_qual[1].tag_type_flag=3))
     sep1 = "", sep2 = temp1->qual[d.seq].tag_qual[1].tag_separator, sep1 = trim(sep1)
    ELSEIF ((temp1->qual[d.seq].tag_qual[2].tag_type_flag=2))
     sep1 = temp1->qual[d.seq].tag_qual[2].tag_separator, sep2 = temp1->qual[d.seq].tag_qual[1].
     tag_separator
    ENDIF
   ENDIF
   FOR (spec = 1 TO cnvtint(temp1->qual[d.seq].spec_ctr))
     found_cases += 1, spec_tag = temp1->qual[d.seq].spec_qual[spec].spec_tag
     IF (substring(17,79,temp1->qual[d.seq].spec_qual[spec].spec_descr) > " ")
      spec_descr = build(substring(1,17,temp1->qual[d.seq].spec_qual[spec].spec_descr),"...")
     ELSE
      spec_descr = temp1->qual[d.seq].spec_qual[spec].spec_descr
     ENDIF
     col 109, spec_descr
     FOR (var1 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].s_t_ctr))
       IF (substring(16,84,temp1->qual[d.seq].spec_qual[spec].t_qual[var1].t_mnemonic) > " ")
        task_desc = build(substring(1,12,temp1->qual[d.seq].spec_qual[spec].t_qual[var1].t_mnemonic),
         "...")
       ELSE
        task_desc = temp1->qual[d.seq].spec_qual[spec].t_qual[var1].t_mnemonic
       ENDIF
       col 53, task_desc, col 69,
       spec_tag, row + 1
       IF (((row+ 6) > maxrow))
        bbreak = 1, BREAK
       ENDIF
       IF (alias_printed=1)
        alias_printed = 1
       ELSE
        col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
       ENDIF
     ENDFOR
     comments_printed = "N"
     FOR (var21 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].s_t_ctr))
       IF (((row+ 6) > maxrow))
        bbreak = 1, BREAK
       ENDIF
       IF (alias_printed=1)
        alias_printed = 1
       ELSE
        col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
       ENDIF
       IF ((temp1->qual[d.seq].spec_qual[spec].t_qual[var21].t_comment_cnt > 0))
        IF (comments_printed="N")
         IF (row=alias_printed_row)
          row + 1, col 20, captions->com
         ELSE
          col 20, captions->com
         ENDIF
        ENDIF
        comments_printed = "Y"
        FOR (com_cnt = 1 TO temp1->qual[d.seq].spec_qual[spec].t_qual[var21].t_comment_cnt)
          col 37, temp1->qual[d.seq].spec_qual[spec].t_qual[var21].t_comment[com_cnt].text
          IF (((row+ 6) > maxrow))
           bbreak = 1, BREAK
          ENDIF
          row + 1
        ENDFOR
        row + 1
       ENDIF
     ENDFOR
     comments_printed = "N"
     FOR (var2 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].s_slide_ctr))
      slide1_mod = temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].sl_origin_modifier,
      FOR (var3 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].s_s_t_ctr))
        IF (substring(16,84,temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[var3].
         t_mnemonic) > " ")
         task_desc = build(substring(1,12,temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[
           var3].t_mnemonic),"...")
        ELSE
         task_desc = temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[var3].t_mnemonic
        ENDIF
        col 53, task_desc, blob = concat(build(spec_tag,sep1)," ",build(sep2,temp1->qual[d.seq].
          spec_qual[spec].slide_qual[var2].sl_tag)),
        blob = concat(build(blob)," ",build(slide1_mod))
        IF (substring(21,5,blob) > " ")
         blob = concat(substring(1,17,blob),"...")
        ENDIF
        shortblob = blob, col 69, shortblob,
        row + 1
        IF (((row+ 6) > maxrow))
         bbreak = 1, BREAK
        ENDIF
        IF (alias_printed=1)
         alias_printed = 1
        ELSE
         col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
        ENDIF
        IF ((temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[var3].t_comment_cnt > 0))
         IF (comments_printed="N")
          IF (row=alias_printed_row)
           row + 1, col 20, captions->com
          ELSE
           col 20, captions->com
          ENDIF
         ENDIF
         comments_printed = "Y"
         FOR (com_cnt = 1 TO temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[var3].
         t_comment_cnt)
           col 37, temp1->qual[d.seq].spec_qual[spec].slide_qual[var2].t_qual[var3].t_comment[com_cnt
           ].text
           IF (((row+ 6) > maxrow))
            bbreak = 1, BREAK
           ENDIF
           row + 1
         ENDFOR
         row + 1
        ENDIF
      ENDFOR
     ENDFOR
     comments_printed = "N"
     FOR (cass1 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].s_c_ctr))
       cass_tag = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].cass_tag, cass_modifier = temp1
       ->qual[d.seq].spec_qual[spec].cass_qual[cass1].cass_origin_modifier, col 90,
       temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].cass_pieces"###", col 94, temp1->qual[d
       .seq].spec_qual[spec].cass_qual[cass1].cass_fixative_disp"##############",
       slide2 = 1, task3 = 1, task3_start = 1
       IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].s_c_slide_ctr > 0))
        IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].s_c_s_t_ctr > 0))
         IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[task3].
         t_create_inv_flag=3))
          task3_start = 2, slide_tag = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].
          slide_qual[slide2].s_tag, slide_modifier = temp1->qual[d.seq].spec_qual[spec].cass_qual[
          cass1].slide_qual[slide2].s_origin_modifier,
          blob = build(spec_tag,sep1,cass_tag,sep2,slide_tag)
          IF (substring(16,84,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].
           t_qual[task3].t_mnemonic) > " ")
           task_desc = build(substring(1,12,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].
             slide_qual[slide2].t_qual[task3].t_mnemonic),"...")
          ELSE
           task_desc = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[
           task3].t_mnemonic
          ENDIF
          col 53, task_desc, blob = concat(build(blob)," ",build(cass_modifier)," ",build(
            slide_modifier))
          IF (substring(21,5,blob) > " ")
           blob = concat(substring(1,17,blob),"...")
          ENDIF
          shortblob = blob, col 69, shortblob,
          row + 1
          IF (((row+ 6) > maxrow))
           bbreak = 1, BREAK
          ENDIF
          IF (alias_printed=1)
           alias_printed = 1
          ELSE
           col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
          ENDIF
          IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[task3].
          t_comment_cnt > 0))
           IF (comments_printed="N")
            IF (row=alias_printed_row)
             row + 1, col 20, captions->com
            ELSE
             col 20, captions->com
            ENDIF
           ENDIF
           comments_printed = "Y"
           FOR (com_cnt = 1 TO temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2]
           .t_qual[task3].t_comment_cnt)
             col 37, temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[
             task3].t_comment[com_cnt].text
             IF (((row+ 6) > maxrow))
              bbreak = 1, BREAK
             ENDIF
             row + 1
           ENDFOR
           row + 1
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       comments_printed = "N"
       FOR (task1 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].s_c_t_ctr))
         IF (substring(16,84,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].t_qual[task1].
          t_mnemonic) > " ")
          task_desc = build(substring(1,12,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].
            t_qual[task1].t_mnemonic),"...")
         ELSE
          task_desc = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].t_qual[task1].t_mnemonic
         ENDIF
         col 53, task_desc, blob = build(spec_tag,sep1,cass_tag),
         blob = concat(build(blob)," ",build(cass_modifier))
         IF (substring(21,5,blob) > " ")
          blob = concat(substring(1,17,blob),"...")
         ENDIF
         shortblob = blob, col 69, shortblob,
         row + 1
         IF (((row+ 6) > maxrow))
          bbreak = 1, BREAK
         ENDIF
         IF (alias_printed=1)
          alias_printed = 1
         ELSE
          col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
         ENDIF
         IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].t_qual[task1].t_comment_cnt > 0))
          IF (comments_printed="N")
           IF (row=alias_printed_row)
            row + 1, col 20, captions->com
           ELSE
            col 20, captions->com
           ENDIF
          ENDIF
          comments_printed = "Y"
          FOR (com_cnt = 1 TO temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].t_qual[task1].
          t_comment_cnt)
            col 37, temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].t_qual[task1].t_comment[
            com_cnt].text
            IF (((row+ 6) > maxrow))
             bbreak = 1, BREAK
            ENDIF
            row + 1
          ENDFOR
          row + 1
         ENDIF
       ENDFOR
       comments_printed = "N"
       FOR (slide2 = 1 TO cnvtint(temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].s_c_slide_ctr))
         slide_tag = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].s_tag,
         slide_modifier = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].
         s_origin_modifier
         FOR (task3 = task3_start TO cnvtint(temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].
          slide_qual[slide2].s_c_s_t_ctr))
           blob = build(spec_tag,sep1,cass_tag,sep2,slide_tag)
           IF (substring(16,84,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2]
            .t_qual[task3].t_mnemonic) > " ")
            task_desc = build(substring(1,12,temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].
              slide_qual[slide2].t_qual[task3].t_mnemonic),"...")
           ELSE
            task_desc = temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].
            t_qual[task3].t_mnemonic
           ENDIF
           col 53, task_desc, blob = concat(build(blob)," ",build(cass_modifier)," ",build(
             slide_modifier))
           IF (substring(21,5,blob) > " ")
            blob = concat(substring(1,17,blob),"...")
           ENDIF
           shortblob = blob, col 69, shortblob,
           row + 1
           IF (((row+ 6) > maxrow))
            bbreak = 1, BREAK
           ENDIF
           IF (alias_printed=1)
            alias_printed = 1
           ELSE
            col 20, temp1->qual[d.seq].patient_alias"######################", alias_printed = 1
           ENDIF
           IF ((temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[task3].
           t_comment_cnt > 0))
            IF (comments_printed="N")
             IF (row=alias_printed_row)
              row + 1, col 20, captions->com
             ELSE
              col 20, captions->com
             ENDIF
            ENDIF
            comments_printed = "Y"
            FOR (com_cnt = 1 TO temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2
            ].t_qual[task3].t_comment_cnt)
              col 37, temp1->qual[d.seq].spec_qual[spec].cass_qual[cass1].slide_qual[slide2].t_qual[
              task3].t_comment[com_cnt].text
              IF (((row+ 6) > maxrow))
               bbreak = 1, BREAK
              ENDIF
              row + 1
            ENDFOR
            row + 1
           ENDIF
         ENDFOR
         task3_start = 1
       ENDFOR
     ENDFOR
   ENDFOR
   IF (alias_printed_row=row)
    row + 1
   ENDIF
   row + request->nbr_blank_lines
  FOOT PAGE
   IF (((found_cases=0) OR ((temp1->ccnt=0))) )
    row + 3, col 20, captions->none
   ENDIF
   row 60, col 0, line1,
   row + 1, col 0, captions->rpt,
   col + 1, captions->title, wk = format(curdate,"@WEEKDAYABBREV;;D"),
   dy = format(curdate,"@MEDIUMDATE4YR;;D"), today = concat(wk," ",dy), col 53,
   today, col 110, captions->pg,
   col 117, curpage"###", row + 1,
   col 55, captions->cont
  FOOT REPORT
   col 55, "##########  "
  WITH nullreport, nocounter, maxcol = 132,
   maxrow = 63, compress
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ARRAY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT MAKER"
  SET reply->status_data.status = "Z"
  SET reply->ops_event = "Failure - SELECT F ARRAY REPORT MAKER"
 ELSE
  SET reply->status_data.status = "S"
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value(
    copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ENDIF
#exit_program
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
END GO
