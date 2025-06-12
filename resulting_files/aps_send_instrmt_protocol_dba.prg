CREATE PROGRAM aps_send_instrmt_protocol:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sendinstrtemp(
   1 qual[*]
     2 accession_nbr = vc
     2 block_path = vc
     2 block_tag = vc
     2 formatted_accession_nbr = vc
     2 label_template = vc
     2 observation_dt_tm = vc
     2 order_control = c2
     2 order_id = vc
     2 order_status = c2
     2 service_resource_cd = f8
     2 slide_path = vc
     2 slide_tag = vc
     2 specimen_source = vc
     2 specimen_tag = vc
     2 supplemental_service_info = vc
     2 universal_service_identifier = vc
     2 task_instrmt_protocol_r_id = f8
     2 frmt_med_nbr = vc
     2 patient_name = vc
     2 patient_last_name = vc
     2 patient_first_name = vc
     2 patient_middle_name = vc
     2 frmt_birthday = vc
     2 age_in_years = vc
     2 sex_cd = f8
     2 patient_race_cd = f8
     2 species_cd = f8
     2 patient_class_cd = f8
     2 nurse_station_cd = f8
     2 room_cd = f8
     2 bed_cd = f8
     2 patient_encounter_nbr = f8
     2 resp_pathologist_id = f8
     2 resp_pathologist_name = vc
     2 resp_pathologist_last_name = vc
     2 resp_pathologist_first_name = vc
     2 resp_pathologist_mid_name = vc
     2 admitting_doctor_id = f8
     2 admitting_doctor_name = vc
     2 admitting_doctor_last_name = vc
     2 admitting_doctor_first_name = vc
     2 admitting_doctor_mid_name = vc
     2 patient_type_cd = f8
     2 fin_class_cd = f8
     2 frmt_admit_date = vc
     2 frmt_disc_date = vc
     2 facility_cd_str = vc
     2 facility_name = vc
     2 specimen_tag_seq = i4
     2 block_tag_seq = i4
     2 slide_tag_seq = i4
     2 slide_barcode = vc
 )
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
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 EXECUTE prefrtl
 RECORD preferences(
   1 hprefdir = h
   1 hprefsection = h
   1 hprefsectionid = h
   1 hprefgroup = h
   1 hprefentry = h
   1 hprefattr = h
   1 entry_qual[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 lprefstat = h
   1 npreferr = i2
   1 spreferrmsg = c255
 ) WITH protect
 SUBROUTINE (findpreference(sentryname=vc) =i2)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE iprefentry = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   FOR (iprefentry = 1 TO nprefentrycnt)
     IF (cnvtlower(preferences->entry_qual[iprefentry].name)=trim(cnvtlower(sentryname)))
      RETURN(iprefentry)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (addpreference(sentryname=vc) =i2)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefindex = i2 WITH private, noconstant(0)
   SET nprefindex = findpreference(sentryname)
   IF (nprefindex=0)
    SET nprefentrycnt = size(preferences->entry_qual,5)
    SET nprefindex = (nprefentrycnt+ 1)
    SET stat = alterlist(preferences->entry_qual,nprefindex)
    SET preferences->entry_qual[nprefindex].name = trim(sentryname)
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,0)
   ENDIF
   RETURN(nprefindex)
 END ;Subroutine
 SUBROUTINE (getpreferencevalue(nprefindex=i2) =vc)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
    IF (nprefvaluecnt > 0)
     SET sprefvalue = preferences->entry_qual[nprefindex].values[1].value
     FOR (iprefvalue = 2 TO nprefvaluecnt)
       SET sprefvalue = concat(sprefvalue,"|",preferences->entry_qual[nprefindex].values[iprefvalue].
        value)
     ENDFOR
    ENDIF
   ENDIF
   RETURN(sprefvalue)
 END ;Subroutine
 SUBROUTINE (setfirstpreferencevalue(nprefindex=i2,sprefvalue=vc) =i2)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET iprefvalue = 1
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,iprefvalue)
    SET preferences->entry_qual[nprefindex].values[iprefvalue].value = trim(sprefvalue)
   ENDIF
   RETURN(iprefvalue)
 END ;Subroutine
 SUBROUTINE (setnextpreferencevalue(nprefindex=i2,sprefvalue=vc) =i2)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
    SET iprefvalue = (nprefvaluecnt+ 1)
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,iprefvalue)
    SET preferences->entry_qual[nprefindex].values[iprefvalue].value = trim(sprefvalue)
   ENDIF
   RETURN(iprefvalue)
 END ;Subroutine
 SUBROUTINE (getpreferenceerrmsg(dummy=i2) =vc)
   RETURN(trim(preferences->spreferrmsg))
 END ;Subroutine
 SUBROUTINE (clearpreferences(dummy=i2) =null)
  SET stat = alterlist(preferences->entry_qual,0)
  CALL checkprefstatus(1)
 END ;Subroutine
 SUBROUTINE (clearpreferenceerr(dummy=i2) =null)
   SET preferences->lprefstat = 0
   SET preferences->npreferr = 0
   SET preferences->spreferrmsg = ""
 END ;Subroutine
 SUBROUTINE (unloadpreferences(dummy=i2) =null)
  CALL checkprefstatus(1)
  FREE RECORD preferences
 END ;Subroutine
 SUBROUTINE (loadpreferences(ssystemctx=vc,sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssectionname=
  vc,ssectionid=vc) =i2)
   DECLARE nsubgroupcnt = i4 WITH private, noconstant(0)
   DECLARE isubgroup = i4 WITH private, noconstant(0)
   IF (validate(cursysbit,32)=32)
    DECLARE nsubgroupcntw = i4 WITH private, noconstant(0)
    DECLARE isubgroupw = i4 WITH private, noconstant(0)
   ELSE
    DECLARE nsubgroupcntw = h WITH private, noconstant(0)
    DECLARE isubgroupw = h WITH private, noconstant(0)
   ENDIF
   CALL clearpreferences(0)
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(0)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(ssystemctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("default"),
     nullterm(ssystemctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(sfacilityctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("facility"),
     nullterm(sfacilityctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(spositionctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("position"),
     nullterm(spositionctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(suserctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("user"),nullterm(
      suserctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF ((preferences->hprefsectionid > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsectionid)
    SET preferences->hprefsectionid = 0
   ENDIF
   SET preferences->hprefsection = uar_prefgetsectionbyname(preferences->hprefdir,nullterm(
     ssectionname))
   IF ((preferences->hprefsection=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefgetgroupbyname(preferences->hprefsection,nullterm(
     ssectionid))
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefgroup = preferences->hprefsectionid
   IF (readpreferences(preferences->hprefsectionid)=0)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefgetsubgroupcount(preferences->hprefsectionid,nsubgroupcntw)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET nsubgroupcnt = nsubgroupcntw
   FOR (isubgroup = 1 TO nsubgroupcnt)
     SET isubgroupw = isubgroup
     SET preferences->hprefgroup = uar_prefgetsubgroup(preferences->hprefsectionid,(isubgroupw - 1))
     IF ((preferences->hprefgroup=0))
      RETURN(checkprefstatus(0))
     ENDIF
     IF (readpreferences(preferences->hprefgroup)=0)
      RETURN(checkprefstatus(0))
     ELSE
      CALL uar_prefdestroygroup(preferences->hprefgroup)
      SET preferences->hprefgroup = 0
     ENDIF
   ENDFOR
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE (checkprefstatus(nsuccessind=i2) =i2)
   IF (nsuccessind != 1)
    IF (textlen(trim(preferences->spreferrmsg))=0)
     SET preferences->npreferr = uar_prefgetlasterror()
     SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    ENDIF
   ENDIF
   IF ((preferences->hprefdir > 0))
    CALL uar_prefdestroyinstance(preferences->hprefdir)
    SET preferences->hprefdir = 0
   ENDIF
   IF ((preferences->hprefgroup > 0))
    IF ((preferences->hprefgroup != preferences->hprefsectionid))
     CALL uar_prefdestroygroup(preferences->hprefgroup)
    ENDIF
    SET preferences->hprefgroup = 0
   ENDIF
   IF ((preferences->hprefsection > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsection)
    SET preferences->hprefsection = 0
   ENDIF
   IF ((preferences->hprefsectionid > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsectionid)
    SET preferences->hprefsectionid = 0
   ENDIF
   IF ((preferences->hprefentry > 0))
    CALL uar_prefdestroyentry(preferences->hprefentry)
    SET preferences->hprefentry = 0
   ENDIF
   IF ((preferences->hprefattr > 0))
    CALL uar_prefdestroyinstance(preferences->hprefattr)
    SET preferences->hprefattr = 0
   ENDIF
   RETURN(nsuccessind)
 END ;Subroutine
 SUBROUTINE (readpreferences(hprefgroup=h) =i2)
   DECLARE npref_len = i2 WITH private, constant(255)
   DECLARE lentry = i4 WITH private, noconstant(0)
   DECLARE sprefstring = c255 WITH private, noconstant("")
   DECLARE sattrnamestring = c255 WITH private, noconstant("")
   DECLARE sattrvalstring = c255 WITH private, noconstant(" ")
   DECLARE lentrynamelen = i4 WITH private, noconstant(npref_len)
   DECLARE lgroupentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattrvalcnt = i4 WITH private, noconstant(0)
   DECLARE lentryattr = i4 WITH private, noconstant(0)
   DECLARE lattrval = i4 WITH private, noconstant(0)
   DECLARE nprefindex = i2 WITH private, noconstant(0)
   IF (validate(cursysbit,32)=32)
    DECLARE lattrnamelen = i4 WITH private, noconstant(npref_len)
    DECLARE lattrvallen = i4 WITH private, noconstant(npref_len)
    DECLARE lgroupentrycntw = i4 WITH private, noconstant(0)
    DECLARE lentryw = i4 WITH private, noconstant(0)
    DECLARE lattrvalcntw = i4 WITH private, noconstant(0)
    DECLARE lattrvalw = i4 WITH private, noconstant(0)
   ELSE
    DECLARE lattrnamelen = h WITH private, noconstant(npref_len)
    DECLARE lattrvallen = h WITH private, noconstant(npref_len)
    DECLARE lgroupentrycntw = h WITH private, noconstant(0)
    DECLARE lentryw = h WITH private, noconstant(0)
    DECLARE lattrvalcntw = h WITH private, noconstant(0)
    DECLARE lattrvalw = h WITH private, noconstant(0)
   ENDIF
   SET preferences->lprefstat = uar_prefgetgroupentrycount(hprefgroup,lgroupentrycntw)
   IF ((preferences->lprefstat != 1))
    RETURN(0)
   ENDIF
   SET lgroupentrycnt = lgroupentrycntw
   FOR (lentry = 1 TO lgroupentrycnt)
     SET lentryw = lentry
     SET preferences->hprefentry = uar_prefgetgroupentry(hprefgroup,(lentryw - 1))
     IF ((preferences->hprefentry=0))
      RETURN(0)
     ENDIF
     SET sprefstring = ""
     SET lentrynamelen = npref_len
     SET preferences->lprefstat = uar_prefgetentryname(preferences->hprefentry,sprefstring,
      lentrynamelen)
     IF ((preferences->lprefstat != 1))
      RETURN(0)
     ENDIF
     SET nprefindex = addpreference(sprefstring)
     IF (nprefindex=0)
      SET preferences->spreferrmsg = "Error adding preference to record."
      RETURN(0)
     ENDIF
     SET preferences->lprefstat = uar_prefgetentryattrcount(preferences->hprefentry,lentryattrcnt)
     IF ((preferences->lprefstat != 1))
      RETURN(0)
     ENDIF
     FOR (lentryattr = 1 TO lentryattrcnt)
       SET preferences->hprefattr = uar_prefgetentryattr(preferences->hprefentry,(lentryattr - 1))
       IF ((preferences->hprefattr=0))
        RETURN(0)
       ENDIF
       SET sattrnamestring = ""
       SET preferences->lprefstat = uar_prefgetattrname(preferences->hprefattr,sattrnamestring,
        lattrnamelen)
       IF ((preferences->lprefstat != 1))
        RETURN(0)
       ENDIF
       IF (sattrnamestring="prefvalue")
        SET preferences->lprefstat = uar_prefgetattrvalcount(preferences->hprefattr,lattrvalcntw)
        IF ((preferences->lprefstat != 1))
         RETURN(0)
        ENDIF
        SET lattrvalcnt = lattrvalcntw
        FOR (lattrval = 1 TO lattrvalcnt)
          SET sattrvalstring = ""
          SET lattrvallen = npref_len
          SET lattrvalw = lattrval
          SET preferences->lprefstat = uar_prefgetattrval(preferences->hprefattr,sattrvalstring,
           lattrvallen,(lattrvalw - 1))
          IF ((preferences->lprefstat != 1))
           RETURN(0)
          ENDIF
          IF (lattrval=1)
           CALL setfirstpreferencevalue(nprefindex,nullterm(sattrvalstring))
          ELSE
           CALL setnextpreferencevalue(nprefindex,nullterm(sattrvalstring))
          ENDIF
        ENDFOR
       ENDIF
       CALL uar_prefdestroyinstance(preferences->hprefattr)
       SET preferences->hprefattr = 0
     ENDFOR
     CALL uar_prefdestroyinstance(preferences->hprefentry)
     SET preferences->hprefentry = 0
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (updatepreferences(scontextname=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname
  =vc,nprefindex=i2) =i2)
   DECLARE nattrvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iattrvalue = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(1)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm(scontextname),
    nullterm(scontextid))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(sgroupname)) > 0)
    SET preferences->hprefgroup = uar_prefaddsubgroup(preferences->hprefsectionid,nullterm(sgroupname
      ))
    IF ((preferences->hprefgroup=0))
     RETURN(checkprefstatus(0))
    ENDIF
   ELSE
    SET preferences->hprefgroup = preferences->hprefsectionid
   ENDIF
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (((nprefindex > nprefentrycnt) OR (nprefindex <= 0)) )
    SET preferences->spreferrmsg = "Invalid preference index passed to UpdatePreferences."
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefentry = uar_prefaddentrytogroup(preferences->hprefgroup,nullterm(preferences
     ->entry_qual[nprefindex].name))
   IF ((preferences->hprefentry=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefattr = uar_prefaddattrtoentry(preferences->hprefentry,nullterm("prefvalue"))
   IF ((preferences->hprefattr=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
   FOR (iprefvalue = 1 TO nprefvaluecnt)
     SET sprefvalue = preferences->entry_qual[nprefindex].values[iprefvalue].value
     SET preferences->lprefstat = uar_prefaddattrval(preferences->hprefattr,nullterm(sprefvalue))
     IF ((preferences->lprefstat != 1))
      RETURN(checkprefstatus(0))
     ENDIF
   ENDFOR
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE (deletepreferences(scontextname=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname
  =vc,nprefindex=i2) =i2)
   DECLARE nattrvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iattrvalue = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(2)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm(scontextname),
    nullterm(scontextid))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(sgroupname)) > 0)
    SET preferences->hprefgroup = uar_prefaddsubgroup(preferences->hprefsectionid,nullterm(sgroupname
      ))
    IF ((preferences->hprefgroup=0))
     RETURN(checkprefstatus(0))
    ENDIF
   ELSE
    SET preferences->hprefgroup = preferences->hprefsectionid
   ENDIF
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (((nprefindex > nprefentrycnt) OR (nprefindex <= 0)) )
    SET preferences->spreferrmsg = "Invalid preference index passed to UpdatePreferences."
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefentry = uar_prefaddentrytogroup(preferences->hprefgroup,nullterm(preferences
     ->entry_qual[nprefindex].name))
   IF ((preferences->hprefentry=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE (testpreferences(dummy=i2) =null)
   DECLARE nprefidx = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL echo("beginning preferences test...")
   CALL loadpreferences("system","","","","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   CALL echorecord(preferences)
   SET nprefidx = findpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("system preference value is: ",sprefvalue))
   SET nprefidx = addpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   IF (setfirstpreferencevalue(nprefidx,"All")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   CALL updatepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("UpdatePreferences: Error")
   ELSE
    CALL echo("user preference value updated to: all")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   CALL echorecord(preferences)
   CALL loadpreferences("","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   CALL echorecord(preferences)
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   CALL deletepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("DeletePreferences: Error")
   ELSE
    CALL echo("user preference value deleted")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("Current preference value is: ",sprefvalue))
   CALL loadpreferences("","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   IF (setfirstpreferencevalue(nprefidx,"Registry")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   IF (setnextpreferencevalue(nprefidx,"User")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   CALL updatepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("UpdatePreferences: Error")
   ELSE
    CALL echo("user preference value updated to: registry, user")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   CALL deletepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("DeletePreferences: Error")
   ELSE
    CALL echo("user preference value deleted")
   ENDIF
   CALL unloadpreferences(0)
   CALL echo("testing complete.")
 END ;Subroutine
 SUBROUTINE (clearpreferencerecord(dummy=i2) =null)
   CALL checkprefstatus(1)
   SET preferences->hprefdir = 0
   SET preferences->hprefsection = 0
   SET preferences->hprefsectionid = 0
   SET preferences->hprefgroup = 0
   SET preferences->hprefentry = 0
   SET preferences->hprefattr = 0
   SET stat = alterlist(preferences->entry_qual,0)
   SET preferences->lprefstat = 0
   SET preferences->npreferr = 0
   SET preferences->spreferrmsg = ""
 END ;Subroutine
 RECORD birthsexprefrec(
   1 orders[*]
     2 accession = vc
     2 person_id = f8
     2 service_resource_cd = f8
     2 preferred_sex_cd = f8
     2 birth_sex_pref_ind = i2
 )
 RECORD sexcodevalues(
   1 gender[*]
     2 cdf_mean = vc
     2 code_val = f8
 )
 SUBROUTINE (loadsexcodevalues(dummy=i2) =null)
   DECLARE gender_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=57
     AND cv.active_ind=1
    DETAIL
     gender_cnt += 1, stat = alterlist(sexcodevalues->gender,(gender_cnt+ 1)), sexcodevalues->gender[
     gender_cnt].cdf_mean = cv.cdf_meaning,
     sexcodevalues->gender[gender_cnt].code_val = cv.code_value
    WITH nocounter
   ;end select
   SET stat = alterlist(sexcodevalues->gender,gender_cnt)
 END ;Subroutine
 SUBROUTINE (loadbirthsexpref(dummy=i2) =null)
  DECLARE serv_res_facility_cd = f8 WITH private, noconstant(0.0)
  FOR (idx = 1 TO size(birthsexprefrec->orders,5))
    SET serv_res_facility_cd = getservresfacilitycd(birthsexprefrec->orders[idx].service_resource_cd)
    SET birthsexprefrec->orders[idx].birth_sex_pref_ind = loadbirthsexpreference(serv_res_facility_cd
     )
    CALL updatepreferredsexcdtobirthsex(birthsexprefrec->orders[idx].person_id,idx)
  ENDFOR
 END ;Subroutine
 SUBROUTINE (getservresfacilitycd(service_resource_cd=f8) =f8)
   DECLARE facility_type_cd = f8 WITH noconstant(0.0)
   DECLARE serv_res_facility_cd = f8 WITH private, noconstant(0.0)
   SET facility_type_cd = uar_get_code_by("MEANING",222,"FACILITY")
   CALL echo(build("service_resource",service_resource_cd))
   CALL echo(build("facility_type_cd",facility_type_cd))
   SELECT INTO "nl:"
    FROM service_resource sr,
     location l
    WHERE sr.service_resource_cd=service_resource_cd
     AND sr.organization_id=l.organization_id
     AND l.location_type_cd=facility_type_cd
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     serv_res_facility_cd = l.location_cd
    WITH nocounter
   ;end select
   RETURN(serv_res_facility_cd)
 END ;Subroutine
 SUBROUTINE (loadbirthsexpreference(facilitycd=f8) =i2)
   DECLARE pref_val = i2 WITH private, noconstant(0)
   DECLARE val = i4 WITH noconstant(0)
   SET val = loadpreferences("system",trim(cnvtstring(facilitycd,32,2)),"","","module",
    "general lab")
   IF (val=1)
    SET lindex = findpreference("use birth sex for reference ranges")
    IF (getpreferencevalue(lindex)="Yes")
     SET pref_val = 1
    ENDIF
   ENDIF
   RETURN(pref_val)
 END ;Subroutine
 SUBROUTINE (updatepreferredsexcdtobirthsex(person_id=f8,idx=i4) =null)
   DECLARE birth_sex_cdf = vc WITH noconstant("")
   DECLARE val = i4 WITH noconstant(0)
   DECLARE x = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM person p
    WHERE p.person_id=person_id
    DETAIL
     birthsexprefrec->orders[idx].preferred_sex_cd = p.sex_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM person_patient pp
    WHERE pp.person_id=person_id
     AND pp.active_ind=1
     AND pp.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pp.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     IF ((birthsexprefrec->orders[idx].birth_sex_pref_ind=1)
      AND pp.birth_sex_cd > 0)
      birth_sex_cdf = uar_get_code_meaning(pp.birth_sex_cd), val = locateval(x,1,size(sexcodevalues->
        gender,5),birth_sex_cdf,sexcodevalues->gender[x].cdf_mean)
      IF (val > 0)
       birthsexprefrec->orders[idx].preferred_sex_cd = sexcodevalues->gender[val].code_val
      ELSE
       birthsexprefrec->orders[idx].preferred_sex_cd = 0.0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL cr_createrequest(0,200456,"REQ200456")
 CALL cr_createrequest(1,200456,"REP200456")
 DECLARE lstart = i4 WITH protect, constant(1)
 DECLARE smdi_app_name = c8 WITH protect, constant("GNLBDNLD")
 DECLARE smdi_active_stat = i2 WITH protect, constant(10)
 DECLARE sformataccession = c21 WITH protect, noconstant("")
 DECLARE sfulllabeldisp = c17 WITH protect, noconstant("")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE sfailed = c1 WITH protect, noconstant("F")
 DECLARE lindex1 = i4 WITH protect, noconstant(0)
 DECLARE lindex2 = i4 WITH protect, noconstant(0)
 DECLARE lindex3 = i4 WITH protect, noconstant(0)
 DECLARE lsub = i4 WITH protect, noconstant(0)
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 DECLARE sspecdisp = vc WITH protect, noconstant("")
 DECLARE sblockdisp = vc WITH protect, noconstant("")
 DECLARE sslidedisp = vc WITH protect, noconstant("")
 DECLARE lsendinstrtempsub = i4 WITH protect, noconstant(0)
 DECLARE ncrmok = i2 WITH protect, constant(0)
 DECLARE ncrmstat = i2 WITH protect, noconstant(0)
 DECLARE nsrvstat = i2 WITH protect, noconstant(0)
 DECLARE sstatus = c1 WITH protect, noconstant("")
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hqual = i4 WITH protect, noconstant(0)
 DECLARE hgeninfoitem = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE hstatusdata = i4 WITH protect, noconstant(0)
 DECLARE lactualsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandsize = i4 WITH protect, noconstant(0)
 DECLARE lexpandtotal = i4 WITH protect, noconstant(0)
 DECLARE lexpandstart = i4 WITH protect, noconstant(1)
 DECLARE llocvalindex = i4 WITH protect, noconstant(0)
 DECLARE lcuritemindex = i4 WITH protect, noconstant(0)
 DECLARE dmednbrcd = f8 WITH protect, noconstant(0.0)
 DECLARE dadmitcd = f8 WITH protect, noconstant(0.0)
 DECLARE ninventoryidind = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE uar_fmt_accession(p1,p2) = c25
 IF (checkprg("PCS_LABEL_INTEGRATION_UTIL") > 0)
  EXECUTE pcs_label_integration_util
  SET ninventoryidind = 1
 ENDIF
 SET lstat = alterlist(req200456->qual,size(request->order_list,5))
 FOR (lsub = 1 TO size(request->order_list,5))
   SET req200456->qual[lsub].order_id = request->order_list[lsub].order_id
 ENDFOR
 SET req200456->sending_instr_ind = 1
 EXECUTE aps_get_task_instr_protocols  WITH replace("REQUEST","REQ200456"), replace("REPLY",
  "REP200456")
 IF ((rep200456->status_data.status="Z"))
  GO TO exit_script
 ELSEIF ((rep200456->status_data.status != "S"))
  CALL subevent_add("EXECUTE","F","aps_get_task_instr_protocols","Execute failed.")
  SET sfailed = "T"
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
 IF ((request->resend_ind=2))
  SET lactualsize = size(rep200456->qual,5)
  SELECT INTO "nl:"
   FROM processing_task pt,
    cqm_contributor_config ccc,
    cqm_gnlbdnld_tr_1 cgt1,
    cqm_gnlbdnld_que cgq
   PLAN (pt
    WHERE expand(lsub,lstart,lactualsize,pt.processing_task_id,rep200456->qual[lsub].
     processing_task_id,
     1,rep200456->qual[lsub].status_flag))
    JOIN (ccc
    WHERE ccc.application_name=smdi_app_name
     AND ccc.contributor_alias=trim(cnvtstring(pt.service_resource_cd,19,0)))
    JOIN (cgq
    WHERE cgq.contributor_id=ccc.contributor_id
     AND cgq.contributor_refnum=trim(cnvtstring(pt.order_id,19,0)))
    JOIN (cgt1
    WHERE cgt1.queue_id=cgq.queue_id
     AND ((cgt1.process_status_flag+ 0)=smdi_active_stat))
   DETAIL
    lcuritemindex = locateval(llocvalindex,lstart,lactualsize,pt.processing_task_id,rep200456->qual[
     llocvalindex].processing_task_id)
    IF (lcuritemindex > 0)
     lactualsize -= 1, lstat = alterlist(rep200456->qual,lactualsize,(lcuritemindex - 1))
    ENDIF
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","REP200456")=0)
   GO TO exit_script
  ENDIF
  IF (size(rep200456->qual,5) <= 0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET lexpandstart = 1
 SET lactualsize = size(rep200456->qual,5)
 SET lexpandsize = determineexpandsize(lactualsize,100)
 SET lexpandtotal = determineexpandtotal(lactualsize,lexpandsize)
 SET lstat = alterlist(rep200456->qual,lexpandtotal)
 FOR (lsub = (lactualsize+ 1) TO lexpandtotal)
  SET rep200456->qual[lsub].status_flag = rep200456->qual[lactualsize].status_flag
  SET rep200456->qual[lsub].processing_task_id = rep200456->qual[lactualsize].processing_task_id
 ENDFOR
 SELECT
  IF ((request->resend_ind=2))
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (pt
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),pt.processing_task_id,rep200456
     ->qual[lsub].processing_task_id))
    JOIN (pc
    WHERE pc.case_id=pt.case_id)
    JOIN (cs
    WHERE cs.case_specimen_id=pt.case_specimen_id)
    JOIN (tipr
    WHERE tipr.processing_task_id=pt.processing_task_id)
    JOIN (ip
    WHERE ip.instrument_protocol_id=tipr.instrument_protocol_id)
    JOIN (aptgr
    WHERE aptgr.prefix_id=pc.prefix_id)
  ELSE
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (pt
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),pt.processing_task_id,rep200456
     ->qual[lsub].processing_task_id,
     0,rep200456->qual[lsub].status_flag))
    JOIN (pc
    WHERE pc.case_id=pt.case_id)
    JOIN (cs
    WHERE cs.case_specimen_id=pt.case_specimen_id)
    JOIN (tipr
    WHERE tipr.processing_task_id=pt.processing_task_id)
    JOIN (ip
    WHERE ip.instrument_protocol_id=tipr.instrument_protocol_id)
    JOIN (aptgr
    WHERE aptgr.prefix_id=pc.prefix_id)
  ENDIF
  INTO "nl:"
  naptagspecidx = locateval(lindex1,lstart,ap_tag_cnt,cs.specimen_tag_id,temp_ap_tag->qual[lindex1].
   tag_id), naptagcassidx = locateval(lindex2,lstart,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[
   lindex2].tag_id), naptagslideidx = locateval(lindex3,lstart,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag
   ->qual[lindex3].tag_id),
  dorderid = pt.order_id, llocatestart = lexpandstart
  FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
   processing_task pt,
   pathology_case pc,
   case_specimen cs,
   task_instrmt_protcl_r tipr,
   instrument_protocol ip,
   ap_prefix_tag_group_r aptgr
  ORDER BY pt.processing_task_id
  HEAD pt.processing_task_id
   sblockseparator = "", sslideseparator = "", lcuritemindex = locateval(llocvalindex,llocatestart,((
    llocatestart+ lexpandsize) - 1),pt.processing_task_id,rep200456->qual[llocvalindex].
    processing_task_id)
  DETAIL
   CASE (aptgr.tag_type_flag)
    OF 2:
     sblockseparator = aptgr.tag_separator
    OF 3:
     sslideseparator = aptgr.tag_separator
   ENDCASE
  FOOT  pt.processing_task_id
   sformataccession = uar_fmt_accession(pc.accession_nbr,size(trim(pc.accession_nbr),1))
   IF (naptagspecidx > 0)
    sspecdisp = trim(temp_ap_tag->qual[naptagspecidx].tag_disp)
   ELSE
    sspecdisp = ""
   ENDIF
   IF (naptagcassidx > 0)
    sblockdisp = trim(temp_ap_tag->qual[naptagcassidx].tag_disp)
   ELSE
    sblockdisp = ""
   ENDIF
   IF (naptagslideidx > 0)
    sslidedisp = trim(temp_ap_tag->qual[naptagslideidx].tag_disp)
   ELSE
    sslidedisp = ""
   ENDIF
   sfulllabeldisp = concat(trim(sspecdisp),sblockseparator,trim(sblockdisp),sslideseparator,trim(
     sslidedisp)), lsendinstrtempsub += 1
   IF (mod(lsendinstrtempsub,10)=1)
    lstat = alterlist(sendinstrtemp->qual,(lsendinstrtempsub+ 9))
   ENDIF
   sendinstrtemp->qual[lsendinstrtempsub].accession_nbr = trim(pc.accession_nbr)
   IF (pt.cassette_id > 0.0)
    sendinstrtemp->qual[lsendinstrtempsub].block_path = concat(sspecdisp,sblockseparator,sblockdisp)
   ENDIF
   sendinstrtemp->qual[lsendinstrtempsub].block_tag = sblockdisp, sendinstrtemp->qual[
   lsendinstrtempsub].formatted_accession_nbr = trim(sformataccession)
   IF (size(trim(ip.placer_field_1,3),1) > 0)
    sendinstrtemp->qual[lsendinstrtempsub].label_template = ip.placer_field_1
   ELSE
    sendinstrtemp->qual[lsendinstrtempsub].label_template = "NULL"
   ENDIF
   sendinstrtemp->qual[lsendinstrtempsub].observation_dt_tm = format(cs.collect_dt_tm,
    "YYYYMMDDHHMM;;D"), sendinstrtemp->qual[lsendinstrtempsub].order_control = "NW", sendinstrtemp->
   qual[lsendinstrtempsub].order_id = trim(cnvtstring(dorderid,19,0)),
   sendinstrtemp->qual[lsendinstrtempsub].order_status = "IP", sendinstrtemp->qual[lsendinstrtempsub]
   .service_resource_cd = pt.service_resource_cd, sendinstrtemp->qual[lsendinstrtempsub].slide_path
    = trim(sfulllabeldisp),
   sendinstrtemp->qual[lsendinstrtempsub].slide_tag = sslidedisp, sendinstrtemp->qual[
   lsendinstrtempsub].specimen_source = uar_get_code_display(cs.specimen_cd)
   IF (naptagspecidx > 0)
    sendinstrtemp->qual[lsendinstrtempsub].specimen_tag = trim(temp_ap_tag->qual[naptagspecidx].
     tag_disp), sendinstrtemp->qual[lsendinstrtempsub].specimen_tag_seq = temp_ap_tag->qual[
    naptagspecidx].tag_sequence
   ENDIF
   IF (naptagcassidx > 0)
    sendinstrtemp->qual[lsendinstrtempsub].block_tag_seq = temp_ap_tag->qual[naptagcassidx].
    tag_sequence
   ENDIF
   IF (naptagslideidx > 0)
    sendinstrtemp->qual[lsendinstrtempsub].slide_tag_seq = temp_ap_tag->qual[naptagslideidx].
    tag_sequence
   ENDIF
   sendinstrtemp->qual[lsendinstrtempsub].supplemental_service_info = ip.suplmtl_serv_info_txt,
   sendinstrtemp->qual[lsendinstrtempsub].universal_service_identifier = ip.universal_service_ident,
   sendinstrtemp->qual[lsendinstrtempsub].task_instrmt_protocol_r_id = rep200456->qual[lcuritemindex]
   .task_instrmt_protocol_r_id,
   sendinstrtemp->qual[lsendinstrtempsub].patient_encounter_nbr = pc.encntr_id, sendinstrtemp->qual[
   lsendinstrtempsub].resp_pathologist_id = pc.responsible_pathologist_id
  WITH nocounter
 ;end select
 IF (logcclerror("SELECT","TEMP_REC")=0)
  GO TO exit_script
 ENDIF
 SET lstat = alterlist(rep200456->qual,lactualsize)
 SET lstat = alterlist(sendinstrtemp->qual,lsendinstrtempsub)
 IF (lsendinstrtempsub > 0)
  SET lstat = alterlist(birthsexprefrec->orders,lsendinstrtempsub)
  SET lstat = uar_get_meaning_by_codeset(319,"MRN",1,dmednbrcd)
  IF (dmednbrcd <= 0.0)
   CALL subevent_add("SELECT","F","TABLE","CODE_VALUE - MRN")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
  SET lstat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,dadmitcd)
  IF (dadmitcd <= 0.0)
   CALL subevent_add("SELECT","F","TABLE","CODE_VALUE - ADMITDOC")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
  SET lexpandstart = 1
  SET lactualsize = lsendinstrtempsub
  SET lexpandsize = determineexpandsize(lactualsize,100)
  SET lexpandtotal = determineexpandtotal(lactualsize,lexpandsize)
  SET lstat = alterlist(sendinstrtemp->qual,lexpandtotal)
  FOR (lsub = (lactualsize+ 1) TO lexpandtotal)
   SET sendinstrtemp->qual[lsub].resp_pathologist_id = sendinstrtemp->qual[lactualsize].
   resp_pathologist_id
   SET sendinstrtemp->qual[lsub].patient_encounter_nbr = sendinstrtemp->qual[lactualsize].
   patient_encounter_nbr
  ENDFOR
  SELECT INTO "nl:"
   e.encntr_id, p.person_id
   FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
    encounter e,
    person p
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (e
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),e.encntr_id,sendinstrtemp->qual[
     lsub].patient_encounter_nbr))
    JOIN (p
    WHERE p.person_id=e.person_id)
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    lcuritemindex = 0
    WHILE (assign(lcuritemindex,locateval(lsub,(lcuritemindex+ 1),lactualsize,e.encntr_id,
      sendinstrtemp->qual[lsub].patient_encounter_nbr)) > 0)
      sendinstrtemp->qual[lcuritemindex].patient_name = p.name_full_formatted, sendinstrtemp->qual[
      lcuritemindex].patient_last_name = p.name_last, sendinstrtemp->qual[lcuritemindex].
      patient_first_name = p.name_first,
      sendinstrtemp->qual[lcuritemindex].patient_middle_name = p.name_middle
      IF (curutc=1)
       sendinstrtemp->qual[lcuritemindex].frmt_birthday = format(cnvtdatetimeutc(datetimezone(p
          .birth_dt_tm,p.birth_tz),1),"DDMMMYY;;D"), sendinstrtemp->qual[lcuritemindex].age_in_years
        = cnvtage(cnvtdate2(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),
          "MM/DD/YYYY;;D"),"MM/DD/YYYY"),cnvtint(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
            .birth_tz),1),"HHMM;;M")))
      ELSE
       sendinstrtemp->qual[lcuritemindex].frmt_birthday = format(p.birth_dt_tm,"DDMMMYY;;D"),
       sendinstrtemp->qual[lcuritemindex].age_in_years = cnvtage(cnvtdate2(format(p.birth_dt_tm,
          "MM/DD/YYYY;;D"),"MM/DD/YYYY"),cnvtint(format(p.birth_dt_tm,"HHMM;;M")))
      ENDIF
      sendinstrtemp->qual[lcuritemindex].sex_cd = p.sex_cd, sendinstrtemp->qual[lcuritemindex].
      patient_race_cd = p.race_cd, sendinstrtemp->qual[lcuritemindex].species_cd = p.species_cd,
      sendinstrtemp->qual[lcuritemindex].patient_class_cd = e.encntr_class_cd, sendinstrtemp->qual[
      lcuritemindex].nurse_station_cd = e.loc_nurse_unit_cd, sendinstrtemp->qual[lcuritemindex].
      room_cd = e.loc_room_cd,
      sendinstrtemp->qual[lcuritemindex].bed_cd = e.loc_bed_cd, sendinstrtemp->qual[lcuritemindex].
      facility_cd_str = trim(cnvtstring(e.loc_facility_cd,19,0)), sendinstrtemp->qual[lcuritemindex].
      facility_name = uar_get_code_display(e.loc_facility_cd),
      sendinstrtemp->qual[lcuritemindex].patient_type_cd = e.encntr_type_cd, sendinstrtemp->qual[
      lcuritemindex].fin_class_cd = e.financial_class_cd, sendinstrtemp->qual[lcuritemindex].
      frmt_admit_date = format(e.reg_dt_tm,"DDMMMYY;;D"),
      sendinstrtemp->qual[lcuritemindex].frmt_disc_date = format(e.disch_dt_tm,"DDMMMYY;;D"),
      birthsexprefrec->orders[lcuritemindex].person_id = p.person_id, birthsexprefrec->orders[
      lcuritemindex].accession = sendinstrtemp->qual[lcuritemindex].order_id,
      birthsexprefrec->orders[lcuritemindex].service_resource_cd = sendinstrtemp->qual[lcuritemindex]
      .service_resource_cd
    ENDWHILE
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","TEMP_REC")=0)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(birthsexprefrec->orders,size(sendinstrtemp->qual,5))
  CALL loadsexcodevalues(0)
  CALL loadbirthsexpref(0)
  CALL echorecord(birthsexprefrec)
  FOR (idx = 1 TO size(sendinstrtemp->qual,5))
   SET val = locateval(i,1,size(birthsexprefrec->orders),sendinstrtemp->qual[idx].order_id,
    birthsexprefrec->orders[i].accession)
   IF (val > 0)
    SET sendinstrtemp->qual[idx].sex_cd = birthsexprefrec->orders[val].preferred_sex_cd
   ENDIF
  ENDFOR
  CALL echorecord(sendinstrtemp)
  SELECT INTO "nl:"
   ea.encntr_id
   FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
    encntr_alias ea
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (ea
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),ea.encntr_id,sendinstrtemp->
     qual[lsub].patient_encounter_nbr)
     AND ea.encntr_alias_type_cd=dmednbrcd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ORDER BY ea.encntr_id
   HEAD ea.encntr_id
    lcuritemindex = 0
    WHILE (assign(lcuritemindex,locateval(lsub,(lcuritemindex+ 1),lactualsize,ea.encntr_id,
      sendinstrtemp->qual[lsub].patient_encounter_nbr)) > 0)
      sendinstrtemp->qual[lcuritemindex].frmt_med_nbr = ea.alias
    ENDWHILE
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","TEMP_REC")=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   epr.encntr_id
   FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
    encntr_prsnl_reltn epr,
    person p
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (epr
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),epr.encntr_id,sendinstrtemp->
     qual[lsub].patient_encounter_nbr)
     AND epr.encntr_prsnl_r_cd=dadmitcd
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   ORDER BY epr.encntr_id
   HEAD epr.encntr_id
    lcuritemindex = 0
    WHILE (assign(lcuritemindex,locateval(lsub,(lcuritemindex+ 1),lactualsize,epr.encntr_id,
      sendinstrtemp->qual[lsub].patient_encounter_nbr)) > 0)
      sendinstrtemp->qual[lcuritemindex].admitting_doctor_id = epr.prsnl_person_id, sendinstrtemp->
      qual[lcuritemindex].admitting_doctor_name = p.name_full_formatted, sendinstrtemp->qual[
      lcuritemindex].admitting_doctor_last_name = p.name_last,
      sendinstrtemp->qual[lcuritemindex].admitting_doctor_first_name = p.name_first, sendinstrtemp->
      qual[lcuritemindex].admitting_doctor_mid_name = p.name_middle
    ENDWHILE
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","TEMP_REC")=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   p.person_id
   FROM (dummyt d  WITH seq = value((lexpandtotal/ lexpandsize))),
    person p
   PLAN (d
    WHERE assign(lexpandstart,evaluate(d.seq,1,1,(lexpandstart+ lexpandsize))))
    JOIN (p
    WHERE expand(lsub,lexpandstart,((lexpandstart+ lexpandsize) - 1),p.person_id,sendinstrtemp->qual[
     lsub].resp_pathologist_id))
   ORDER BY p.person_id
   HEAD p.person_id
    lcuritemindex = 0
    WHILE (assign(lcuritemindex,locateval(lsub,(lcuritemindex+ 1),lactualsize,p.person_id,
      sendinstrtemp->qual[lsub].resp_pathologist_id)) > 0)
      sendinstrtemp->qual[lcuritemindex].resp_pathologist_name = p.name_full_formatted, sendinstrtemp
      ->qual[lcuritemindex].resp_pathologist_last_name = p.name_last, sendinstrtemp->qual[
      lcuritemindex].resp_pathologist_first_name = p.name_first,
      sendinstrtemp->qual[lcuritemindex].resp_pathologist_mid_name = p.name_middle
    ENDWHILE
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","TEMP_REC")=0)
   GO TO exit_script
  ENDIF
  SET lstat = alterlist(sendinstrtemp->qual,lsendinstrtempsub)
 ENDIF
 IF (lsendinstrtempsub > 0)
  SET ncrmstat = uar_crmbeginapp(1259900,happ)
  IF (((ncrmstat != ncrmok) OR (happ=0)) )
   CALL subevent_add("GET","F","Application Handle","Failure - Error getting app handle for 1259900."
    )
   GO TO exit_script
  ENDIF
  SET ncrmstat = uar_crmbegintask(happ,1259900,htask)
  IF (((ncrmstat != ncrmok) OR (htask=0)) )
   CALL subevent_add("GET","F","Task Handle","Failure - Error getting task handle for 1259900.")
   GO TO exit_script
  ENDIF
  SET ncrmstat = uar_crmbeginreq(htask,"",1259988,hstep)
  IF (ncrmstat != ncrmok)
   CALL subevent_add("GET","F","Request Handle","Failure - Error getting request handle for 1259988."
    )
   GO TO exit_script
  ENDIF
  SET hreq = uar_crmgetrequest(hstep)
  IF (hreq=0)
   CALL subevent_add("GET","F","Request Handle",
    "Failure - Error getting request structure for 1259988.")
   GO TO exit_script
  ENDIF
  FOR (lsub = 1 TO size(sendinstrtemp->qual,5))
    SET hqual = uar_srvadditem(hreq,"INLAB_ORDERS")
    SET nsrvstat = uar_srvsetstring(hqual,"accession",nullterm(sendinstrtemp->qual[lsub].order_id))
    SET nsrvstat = uar_srvsetshort(hqual,"source_ind",4)
    SET nsrvstat = uar_srvsetdouble(hqual,"service_resource_cd",sendinstrtemp->qual[lsub].
     service_resource_cd)
    SET nsrvstat = uar_srvsetstring(hqual,"name",nullterm(sendinstrtemp->qual[lsub].patient_name))
    SET nsrvstat = uar_srvsetstring(hqual,"frmt_med_nbr",nullterm(sendinstrtemp->qual[lsub].
      frmt_med_nbr))
    SET nsrvstat = uar_srvsetstring(hqual,"age_in_years",nullterm(sendinstrtemp->qual[lsub].
      age_in_years))
    SET nsrvstat = uar_srvsetdouble(hqual,"sex_cd",sendinstrtemp->qual[lsub].sex_cd)
    SET nsrvstat = uar_srvsetstring(hqual,"doctor",nullterm(trim(cnvtstring(sendinstrtemp->qual[lsub]
        .resp_pathologist_id,19,0))))
    SET nsrvstat = uar_srvsetdouble(hqual,"nurse_station_cd",sendinstrtemp->qual[lsub].
     nurse_station_cd)
    SET nsrvstat = uar_srvsetdouble(hqual,"room_cd",sendinstrtemp->qual[lsub].room_cd)
    SET nsrvstat = uar_srvsetdouble(hqual,"bed_cd",sendinstrtemp->qual[lsub].bed_cd)
    SET nsrvstat = uar_srvsetstring(hqual,"patient_encounter_nbr",nullterm(trim(cnvtstring(
        sendinstrtemp->qual[lsub].patient_encounter_nbr,19,0))))
    SET nsrvstat = uar_srvsetstring(hqual,"patient_name",nullterm(sendinstrtemp->qual[lsub].
      patient_name))
    SET nsrvstat = uar_srvsetstring(hqual,"frmt_med_nbr2",nullterm(sendinstrtemp->qual[lsub].
      frmt_med_nbr))
    SET nsrvstat = uar_srvsetstring(hqual,"fin_nbr",nullterm(trim(cnvtstring(sendinstrtemp->qual[lsub
        ].fin_class_cd,19,0))))
    SET nsrvstat = uar_srvsetstring(hqual,"doctor_name",nullterm(sendinstrtemp->qual[lsub].
      resp_pathologist_name))
    SET nsrvstat = uar_srvsetstring(hqual,"admit_doctor_nbr",nullterm(trim(cnvtstring(sendinstrtemp->
        qual[lsub].admitting_doctor_id,19,0))))
    SET nsrvstat = uar_srvsetstring(hqual,"admit_doctor_name",nullterm(sendinstrtemp->qual[lsub].
      admitting_doctor_name))
    SET nsrvstat = uar_srvsetstring(hqual,"frmt_birthday",nullterm(sendinstrtemp->qual[lsub].
      frmt_birthday))
    SET nsrvstat = uar_srvsetstring(hqual,"frmt_admit_date",nullterm(sendinstrtemp->qual[lsub].
      frmt_admit_date))
    SET nsrvstat = uar_srvsetstring(hqual,"frmt_disc_date",nullterm(sendinstrtemp->qual[lsub].
      frmt_disc_date))
    SET nsrvstat = uar_srvsetdouble(hqual,"patient_type_cd",sendinstrtemp->qual[lsub].patient_type_cd
     )
    SET nsrvstat = uar_srvsetdouble(hqual,"patient_class_cd",sendinstrtemp->qual[lsub].
     patient_class_cd)
    SET nsrvstat = uar_srvsetdouble(hqual,"patient_race_cd",sendinstrtemp->qual[lsub].patient_race_cd
     )
    SET nsrvstat = uar_srvsetdouble(hqual,"species_cd",sendinstrtemp->qual[lsub].species_cd)
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("accession_nbr"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      accession_nbr))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("block_path"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      block_path))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("block_tag"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      block_tag))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("formatted_accession_nbr"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      formatted_accession_nbr))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("label_template"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      label_template))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("observation_dt_tm"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      observation_dt_tm))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("order_control"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      order_control))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("order_id"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      order_id))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("order_status"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      order_status))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("slide_path"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      slide_path))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("slide_tag"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      slide_tag))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("specimen_source"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      specimen_source))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("specimen_tag"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      specimen_tag))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("supplemental_service_info"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      supplemental_service_info))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("universal_service_identifier"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      universal_service_identifier))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("patient_last_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      patient_last_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("patient_first_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      patient_first_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("patient_middle_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      patient_middle_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("attending_dr_last_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      resp_pathologist_last_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("attending_dr_first_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      resp_pathologist_first_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("attending_dr_middle_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      resp_pathologist_mid_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("admitting_dr_last_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      admitting_doctor_last_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("admitting_dr_first_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      admitting_doctor_first_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("admitting_dr_middle_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      admitting_doctor_mid_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("facility_code"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      facility_cd_str))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("facility_name"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
      facility_name))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("attending_dr_id"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(trim(cnvtstring(sendinstrtemp->
        qual[lsub].resp_pathologist_id,19,0))))
    SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("admitting_dr_id"))
    SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(trim(cnvtstring(sendinstrtemp->
        qual[lsub].admitting_doctor_id,19,0))))
    IF (ninventoryidind=1)
     IF ((sendinstrtemp->qual[lsub].slide_tag_seq > 0))
      SET sendinstrtemp->qual[lsub].slide_barcode = getinventorybarcode(sendinstrtemp->qual[lsub].
       accession_nbr,sendinstrtemp->qual[lsub].specimen_tag_seq,sendinstrtemp->qual[lsub].
       block_tag_seq,sendinstrtemp->qual[lsub].slide_tag_seq,0)
      SET hgeninfoitem = uar_srvadditem(hqual,"generic_info")
      SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_name",nullterm("slide_barcode"))
      SET nsrvstat = uar_srvsetstring(hgeninfoitem,"g_value",nullterm(sendinstrtemp->qual[lsub].
        slide_barcode))
     ENDIF
    ENDIF
  ENDFOR
  SET ncrmstat = uar_crmperform(hstep)
  IF (ncrmstat=ncrmok)
   SET hrep = uar_crmgetreply(hstep)
   SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
   CALL uar_srvgetstringfixed(hstatusdata,"status",sstatus,1)
   IF (sstatus != "S")
    CALL subevent_add("GET","F","Perform","Failure - Error returned from server step 1259988.")
    SET sfailed = "T"
    GO TO exit_script
   ENDIF
  ELSE
   CALL subevent_add("GET","F","Perform","Failure - Error performing server step 1259988.")
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   tipr.task_instrmt_protcl_r_id
   FROM task_instrmt_protcl_r tipr
   WHERE expand(lindex1,lstart,size(sendinstrtemp->qual,5),tipr.task_instrmt_protcl_r_id,
    sendinstrtemp->qual[lindex1].task_instrmt_protocol_r_id)
   WITH nocounter, forupdate(tipr)
  ;end select
  IF (logcclerror("LOCK","task_instrmt_protcl_r")=0)
   GO TO exit_script
  ENDIF
  UPDATE  FROM task_instrmt_protcl_r tipr
   SET tipr.status_flag = 1, tipr.updt_cnt = (tipr.updt_cnt+ 1), tipr.updt_id = reqinfo->updt_id,
    tipr.updt_task = reqinfo->updt_task, tipr.updt_applctx = reqinfo->updt_applctx, tipr.updt_dt_tm
     = cnvtdatetime(curdate,curtime)
   WHERE expand(lindex1,lstart,size(sendinstrtemp->qual,5),tipr.task_instrmt_protcl_r_id,
    sendinstrtemp->qual[lindex1].task_instrmt_protocol_r_id)
   WITH nocounter
  ;end update
  IF (logcclerror("UPDATE","task_instrmt_protcl_r")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(scclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),scclerror)
   SET sfailed = "T"
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 IF (hstep != 0)
  SET ncrmstat = uar_crmendreq(hstep)
 ENDIF
 IF (htask != 0)
  SET ncrmstat = uar_crmendtask(htask)
 ENDIF
 IF (happ != 0)
  SET ncrmstat = uar_crmendapp(happ)
 ENDIF
 IF (sfailed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
 FREE SET req200456
 FREE SET rep200456
 FREE SET sendinstrtemp
END GO
