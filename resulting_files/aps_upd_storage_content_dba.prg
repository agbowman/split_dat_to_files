CREATE PROGRAM aps_upd_storage_content:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_message = vc
    1 case_id = f8
    1 content_list[*]
      2 storage_content_id = f8
      2 storage_content_event_id = f8
      2 status_cd = f8
      2 status_disp = c40
      2 status_mean = c12
      2 sc_updt_cnt = i4
      2 action_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE pcs_label_integration_util
 DECLARE scassette_mean = vc WITH protect, constant("CASSETTE")
 DECLARE sslide_mean = vc WITH protect, constant("SLIDE")
 DECLARE scase_specimen_mean = vc WITH protect, constant("CASE_SPECIMEN")
 DECLARE hi18nhandle = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lsubevenstatussize = i4 WITH protect, noconstant(0)
 DECLARE dcontributorsourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE dtrackinglocationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dactionprsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE sgenericerrormessage = vc WITH protect, noconstant("")
 DECLARE saccn = vc WITH protect, noconstant("")
 DECLARE ltask_nbr = i4 WITH protect, constant(200437)
 DECLARE lcontent_status_cs = i4 WITH protect, constant(2061)
 DECLARE dtrackstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE sinvalidcontribalias = vc WITH protect, noconstant("")
 DECLARE sinvalidpersonid = vc WITH protect, noconstant("")
 DECLARE sinvalidstatus = vc WITH protect, noconstant("")
 DECLARE sinvalidstatustype = vc WITH protect, noconstant("")
 DECLARE sinventorynotfound = vc WITH protect, noconstant("")
 DECLARE sinvalidcaseaccn = vc WITH protect, noconstant("")
 DECLARE sinvalidinventorybarcode = vc WITH protect, noconstant("")
 DECLARE scasenotfound = vc WITH protect, noconstant("")
 DECLARE path_case_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "P"
 IF ((request->content_list[1].action_dt_tm=null))
  SET request->content_list[1].action_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 SET nstat = uar_i18nlocalizationinit(hi18nhandle,curprog,"",curcclrev)
 SET sgenericerrormessage = uar_i18ngetmessage(hi18nhandle,"GENERIC_ERROR",
  "Unable to record tracking event.")
 SET sinvalidcontribalias = uar_i18ngetmessage(hi18nhandle,"INVALID_CONTRIB_ALIAS",
  " Invalid contributor alias.")
 SET sinvalidpersonid = uar_i18ngetmessage(hi18nhandle,"INVALID_USERNAME",
  " Invalid personnel username.")
 SET sinvalidstatus = uar_i18ngetmessage(hi18nhandle,"INVALID_STATUS",
  " Invalid tracking status/location alias.")
 SET sinvalidstatustype = uar_i18ngetmessage(hi18nhandle,"INVALID_STATUS_TYPE",
  " Invalid tracking event/status type.")
 SET sinventorynotfound = uar_i18ngetmessage(hi18nhandle,"NO_INVENTORY_FOUND",
  " Could not find inventory in the system.")
 SET sinvalidcaseaccn = uar_i18ngetmessage(hi18nhandle,"INVALID_CASE_ACCN"," Invalid case accession."
  )
 SET sinvalidinventorybarcode = uar_i18ngetmessage(hi18nhandle,"INVALID_INV_IDENT",
  " Invalid inventory barcode.")
 SET scasenotfound = uar_i18ngetmessage(hi18nhandle,"PATH_CASE_NOT_FOUND",
  " Pathology case could not be found.")
 EXECUTE accrtl
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
 CALL cr_createrequest(0,265301,"REQ265301")
 RECORD rep265301(
   1 container_id = f8
   1 case_specimen_id = f8
   1 cassette_id = f8
   1 slide_id = f8
   1 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL cr_createrequest(0,1050007,"REQ1050007")
 RECORD rep1050007(
   1 person_id = f8
   1 username = c50
   1 name_full_formatted = c200
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL cr_createrequest(0,265275,"REQ265275")
 IF (size(request->content_list[1].fmt_accession,1) > 0)
  SET saccn = uar_accunformatformatted(nullterm(request->content_list[1].fmt_accession),0,1)
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE pc.accession_nbr=saccn
   DETAIL
    path_case_id = pc.case_id
   WITH nocounter
  ;end select
  IF (path_case_id=0.0)
   SET reply->status_data.status = "P"
   SET reply->error_message = build(sgenericerrormessage," ",scasenotfound)
   CALL subevent_add("SELECT","F","REQUEST","Unable to find pathology case.")
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidcaseaccn)
  CALL subevent_add("SELECT","F","REQUEST","Case accession in the request is not valid.")
  GO TO exit_script
 ENDIF
 IF (size(trim(request->content_list[1].contributor_alias),1) > 0)
  SET dcontributorsourcecd = uar_get_code_by("DISPLAY",73,trim(request->content_list[1].
    contributor_alias))
 ENDIF
 IF (dcontributorsourcecd <= 0.0)
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidcontribalias)
  CALL subevent_add("SELECT","F","CODE_VALUE","Could not find value for contributor alias.")
  GO TO exit_script
 ENDIF
 IF (size(trim(request->content_list[1].tracking_location_alias),1) > 0)
  SELECT INTO "nl:"
   cva.code_value
   FROM code_value_alias cva
   WHERE cva.alias=trim(request->content_list[1].tracking_location_alias)
    AND cva.code_set=220
    AND cva.contributor_source_cd=dcontributorsourcecd
    AND cva.alias_type_meaning="CSTRACK"
   DETAIL
    dtrackinglocationcd = cva.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (dtrackinglocationcd=0.0)
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidstatus)
  CALL subevent_add("SELECT","F","CODE_VALUE","Could not find value for tracking location alias.")
  GO TO exit_script
 ENDIF
 SET req1050007->username = trim(cnvtupper(request->content_list[1].action_prsnl_username))
 IF (size(req1050007->username,1) > 0)
  EXECUTE pcs_get_user  WITH replace("REQUEST",req1050007), replace("REPLY",rep1050007)
 ENDIF
 IF ((rep1050007->person_id=0.0))
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidpersonid)
  CALL subevent_add("EXECUTE","F","pcs_get_user","Could not find person ID for username.")
  GO TO exit_script
 ENDIF
 SET dactionprsnlid = rep1050007->person_id
 IF (size(request->content_list[1].action_mean,1) > 0)
  SET nstat = uar_get_meaning_by_codeset(lcontent_status_cs,nullterm(request->content_list[1].
    action_mean),1,dtrackstatuscd)
 ENDIF
 IF (dtrackstatuscd=0.0)
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidstatustype)
  CALL subevent_add("EXECUTE","F","CODE_VALUE","Invalid tracking event/status type.")
  GO TO exit_script
 ENDIF
 IF (size(request->content_list[1].fmt_accession,1) > 0
  AND size(request->content_list[1].inventory_identifier,1) > 0)
  SET req265301->accession = saccn
  SET req265301->inventory = getinventorysequence(request->content_list[1].inventory_identifier)
  IF ((req265301->inventory=""))
   SET reply->status_data.status = "P"
   SET reply->error_message = build(sgenericerrormessage," ",sinventorynotfound)
   CALL subevent_add("EXECUTE","F","CODE_VALUE","Inventory sequence could not be found.")
   GO TO exit_script
  ENDIF
  EXECUTE scs_get_inventory  WITH replace("REQUEST",req265301), replace("REPLY",rep265301)
  IF ((rep265301->status_data.status="F"))
   SET reply->error_message = build(sgenericerrormessage," ",sinventorynotfound)
   SET lsubevenstatussize = size(rep265301->status_data.subeventstatus,5)
   SET lstat = alter2(reply->status_data.subeventstatus,lsubevenstatussize)
   SET lstat = moverec(rep265301->status_data,reply->status_data)
   SET reply->status_data.status = "P"
   GO TO exit_script
  ENDIF
  SET lstat = alterlist(req265275->content_list,1)
  IF ((rep265301->slide_id > 0.0))
   SET req265275->content_list[1].content_table_id = rep265301->slide_id
   SET req265275->content_list[1].content_table_name = sslide_mean
  ELSEIF ((rep265301->cassette_id > 0.0))
   SET req265275->content_list[1].content_table_id = rep265301->cassette_id
   SET req265275->content_list[1].content_table_name = scassette_mean
  ELSEIF ((rep265301->case_specimen_id > 0.0))
   SET req265275->content_list[1].content_table_id = rep265301->case_specimen_id
   SET req265275->content_list[1].content_table_name = scase_specimen_mean
  ELSE
   SET reply->status_data.status = "P"
   SET reply->error_message = build(sgenericerrormessage," ",sinventorynotfound)
   CALL subevent_add("EXECUTE","F","CONTENT_TABLE_ID","Could not find value for content table ID.")
   GO TO exit_script
  ENDIF
  SET req265275->content_list[1].action_mean = request->content_list[1].action_mean
  SET req265275->content_list[1].action_prsnl_id = dactionprsnlid
  SET req265275->content_list[1].action_dt_tm = request->content_list[1].action_dt_tm
  SET req265275->content_list[1].source_location_cd = dtrackinglocationcd
  SET req265275->content_list[1].comment_text = request->content_list[1].comment_text
  SET req265275->station_type_mean = "INTERFACED"
  EXECUTE scs_upd_storage_content  WITH replace("REQUEST",req265275), reply
  IF (cnvtupper(reply->status_data.status) != "S")
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "P"
  SET reply->error_message = build(sgenericerrormessage," ",sinvalidinventorybarcode)
  CALL subevent_add("SELECT","F","REQUEST","Inventory barcode is not valid")
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->case_id = path_case_id
 FREE RECORD req265301
 FREE RECORD rep265301
 FREE RECORD req1050007
 FREE RECORD rep1050007
 FREE RECORD req265275
END GO
