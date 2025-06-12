CREATE PROGRAM dcp_upd_temp_loc:dba
 EXECUTE cclseclogin
 SET message = nowindow
 EXECUTE si_srvrtl
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
 CALL echo("*****pm_create_hist_id.inc - 477739****")
 CALL echo("*****pm_create_hist_id.inc - 581128****")
 IF ((validate(bpm_create_hist_id,- (9))=- (9)))
  DECLARE bpm_create_hist_id = i2 WITH constant(true)
  DECLARE bhistoryoption = i2 WITH noconstant(false)
  DECLARE dhistid = f8 WITH noconstant(0.0)
  DECLARE history_cd = f8 WITH noconstant(0.0)
  DECLARE bcheckedhist = i2 WITH noconstant(false)
  SUBROUTINE (pm_checkhistory(itemp=i2) =null)
    IF (bhistoryoption != true
     AND bcheckedhist != true)
     SET bhistoryoption = true
     SET bcheckedhist = true
    ENDIF
  END ;Subroutine
  SUBROUTINE (pm_createid(hist_script=vc,hist_action=vc) =i2)
    FREE RECORD hist_tracking_req
    RECORD hist_tracking_req(
      1 action_flag = i2
      1 conv_task_number = i4
      1 transaction_dt_tm = dq8
      1 pm_hist_tracking_id = f8
      1 person_id = f8
      1 encntr_id = f8
      1 contributor_system_cd = f8
      1 transaction_reason_cd = f8
      1 transaction_reason_txt = c100
      1 transaction_type_txt = c4
      1 hl7_event = c10
      1 facility_org_id = f8
    )
    SET hist_tracking_req->action_flag = 3
    SET hist_tracking_req->pm_hist_tracking_id = 0.0
    SET hist_tracking_req->conv_task_number = 0
    SET hist_tracking_req->contributor_system_cd = 0.0
    SET hist_tracking_req->transaction_dt_tm = cnvtdatetime(sysdate)
    SET hist_tracking_req->transaction_reason_cd = 0.0
    SET hist_tracking_req->transaction_reason_txt = trim(hist_script,3)
    SET hist_tracking_req->transaction_type_txt = trim(hist_action,3)
    IF ((validate(hist_tracking_reply->pm_hist_tracking_id,- (99))=- (99)))
     RECORD hist_tracking_reply(
       1 pm_hist_tracking_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
    ENDIF
    EXECUTE pm_ens_hist_tracking  WITH replace("REQUEST","HIST_TRACKING_REQ"), replace("REPLY",
     "HIST_TRACKING_REPLY")
    IF ((hist_tracking_reply->status_data.status != "S"))
     RETURN(false)
    ELSE
     SET dhistid = hist_tracking_reply->pm_hist_tracking_id
     RETURN(true)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ((validate(bcreatereq,- (9))=- (9)))
  DECLARE bcreatereq = i2 WITH noconstant(false)
 ENDIF
 IF ((validate(bcreateid,- (9))=- (9)))
  DECLARE bcreateid = i2 WITH noconstant(false)
 ENDIF
 CALL pm_checkhistory(null)
 RECORD temp(
   1 temp
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
   1 location
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
   1 prior_location
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
   1 person_id = f8
   1 loc_type_cd = f8
   1 prior_loc_type_cd = f8
   1 temp_meaning = c12
 )
 SET temp->temp.loc_facility_cd = 0
 SET temp->temp.loc_building_cd = 0
 SET temp->temp.loc_unit_cd = 0
 SET temp->temp.loc_room_cd = 0
 SET temp->temp.loc_bed_cd = 0
 SET temp->location.loc_facility_cd = 0
 SET temp->location.loc_building_cd = 0
 SET temp->location.loc_unit_cd = 0
 SET temp->location.loc_room_cd = 0
 SET temp->location.loc_bed_cd = 0
 SET temp->prior_location.loc_facility_cd = 0
 SET temp->prior_location.loc_building_cd = 0
 SET temp->prior_location.loc_unit_cd = 0
 SET temp->prior_location.loc_room_cd = 0
 SET temp->prior_location.loc_bed_cd = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12,"")
 SET code_set = 0
 SET fac_cd = 0
 SET bldg_cd = 0
 SET nu_cd = 0
 SET contrib_temp = fillstring(255,"")
 SET sub_t = fillstring(3,"")
 SET reply->status_data.status = "F"
 IF ((request->encntr_id=0))
  GO TO exit_script
 ENDIF
 SET temp->prior_location.loc_unit_cd = 0
 SELECT INTO "nl:"
  FROM encounter en
  WHERE (en.encntr_id=request->encntr_id)
   AND ((en.active_ind+ 0)=1)
  DETAIL
   temp->prior_location.loc_unit_cd = en.loc_temp_cd, temp->person_id = en.person_id
  WITH nocounter
 ;end select
 IF ((request->pt_loc_cd_present_ind > 0))
  SET temp->prior_location.loc_unit_cd = request->prior_temp_loc_cd
 ENDIF
 CALL echo(build("Prior temp loc cd = ",temp->prior_location.loc_unit_cd))
 CALL echo(build("person_id = ",temp->person_id))
 IF ((request->loc_temp_cd < 0))
  SET temp->location.loc_unit_cd = 0
 ELSE
  SET temp->location.loc_unit_cd = request->loc_temp_cd
 ENDIF
 CALL echo(build("Temp Loc Cd In = ",request->loc_temp_cd))
 IF (dhistid <= 0)
  SET bcreateid = pm_createid("DCP_UPD_TEMP_LOC","UPT")
  IF (bcreateid != true)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcreatereq = cr_createrequest(0,101301,"encntr_req")
 IF (bcreatereq != true)
  CALL echo("Unable to create request 101301.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(encntr_req->encounter,1)
 SET encntr_req->encounter_qual = 1
 SET encntr_req->encounter[1].encntr_id = request->encntr_id
 SET encntr_req->encounter[1].loc_temp_cd = request->loc_temp_cd
 SET encntr_req->encounter[1].info_given_by = " "
 SET encntr_req->encounter[1].preadmit_nbr = " "
 SET encntr_req->encounter[1].reason_for_visit = " "
 SET encntr_req->encounter[1].referring_comment = " "
 IF ((validate(encntr_req->encounter[1].pm_hist_tracking_id,- (99)) != - (99)))
  SET encntr_req->encounter[1].pm_hist_tracking_id = dhistid
  SET encntr_req->encounter[1].transaction_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 FREE RECORD encntr_reply
 RECORD encntr_reply(
   1 encounter_qual = i2
   1 encounter[*]
     2 encntr_id = f8
     2 pm_hist_tracking_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE pm_upt_encounter  WITH replace("REQUEST","ENCNTR_REQ"), replace("REPLY","ENCNTR_REPLY")
 SET reqinfo->commit_ind = 0
 IF ((encntr_reply->status_data.status != "S"))
  CALL echo("Unable to update encounter table.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((validate(eso_trigger_track->a09_ind,- (1))=- (1)))
  SET track_cd = 0.0
  SET code_value = 0.0
  SET cdf_meaning = fillstring(12," ")
  SET cdf_meaning = "ADT_TRACK"
  SET code_set = 19169
  EXECUTE cpm_get_cd_for_cdf
  SET track_cd = code_value
  SET trace = recpersist
  CALL echo(build("Track cd = ",track_cd))
  FREE SET eso_trigger_track
  RECORD eso_trigger_track(
    1 a09_ind = i2
    1 a10_ind = i2
  )
  SET eso_trigger_track->a09_ind = 0
  SET eso_trigger_track->a10_ind = 0
  SELECT INTO "nl:"
   FROM eso_trigger e
   WHERE e.interface_type_cd=track_cd
    AND e.class="TRACK_TRANS"
    AND e.active_ind=1
   DETAIL
    CALL echo(build("Subtype = ",e.subtype))
    IF (e.subtype="A09")
     eso_trigger_track->a09_ind = 1
    ENDIF
    IF (e.subtype="A10")
     eso_trigger_track->a10_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET trace = norecpersist
 ENDIF
 CALL echo(build("A09 ind = ",eso_trigger_track->a09_ind))
 CALL echo(build("A10 ind = ",eso_trigger_track->a10_ind))
 IF ((((eso_trigger_track->a09_ind=1)) OR ((eso_trigger_track->a10_ind=1))) )
  SET temp->temp_meaning = fillstring(12," ")
  SET temp->loc_type_cd = 0
  SET temp->prior_loc_type_cd = 0
  IF ((request->loc_temp_cd > 0))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=220
     AND (cv.code_value=request->loc_temp_cd)
     AND cv.active_ind=1
    DETAIL
     temp->temp_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET code_set = 222
   SET cdf_meaning = trim(temp->temp_meaning)
   EXECUTE cpm_get_cd_for_cdf
   SET temp->loc_type_cd = code_value
   CALL echo(build("Temp Loc Type Cd = ",temp->loc_type_cd))
  ENDIF
  IF ((temp->prior_location.loc_unit_cd > 0))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=220
     AND (cv.code_value=temp->prior_location.loc_unit_cd)
     AND cv.active_ind=1
    DETAIL
     temp->temp_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET code_set = 222
   SET cdf_meaning = trim(temp->temp_meaning)
   EXECUTE cpm_get_cd_for_cdf
   SET temp->prior_loc_type_cd = code_value
   CALL echo(build("Prior Temp Loc Type Cd = ",temp->prior_loc_type_cd))
  ENDIF
  SET code_set = 222
  SET cdf_meaning = "FACILITY"
  EXECUTE cpm_get_cd_for_cdf
  SET fac_cd = code_value
  SET code_set = 222
  SET cdf_meaning = "BUILDING"
  EXECUTE cpm_get_cd_for_cdf
  SET bldg_cd = code_value
  SET code_set = 222
  SET cdf_meaning = "NURSEUNIT"
  EXECUTE cpm_get_cd_for_cdf
  SET nu_cd = code_value
  IF ((temp->prior_location.loc_unit_cd > 0))
   CALL get_loc_heir(temp->prior_location.loc_unit_cd)
   SET temp->prior_location.loc_facility_cd = temp->temp.loc_facility_cd
   SET temp->prior_location.loc_building_cd = temp->temp.loc_building_cd
  ELSE
   SET temp->prior_location.loc_facility_cd = 0
   SET temp->prior_location.loc_building_cd = 0
  ENDIF
  CALL echo(build("Prior Loc Unit Cd = ",temp->prior_location.loc_unit_cd))
  CALL echo(build("Prior Loc Fac Cd = ",temp->prior_location.loc_facility_cd))
  CALL echo(build("Prior Loc Bld Cd = ",temp->prior_location.loc_building_cd))
  IF ((temp->location.loc_unit_cd > 0))
   CALL get_loc_heir(temp->location.loc_unit_cd)
   SET temp->location.loc_facility_cd = temp->temp.loc_facility_cd
   SET temp->location.loc_building_cd = temp->temp.loc_building_cd
  ELSE
   SET temp->location.loc_facility_cd = 0
   SET temp->location.loc_building_cd = 0
  ENDIF
  CALL echo(build("Loc Unit Cd = ",temp->location.loc_unit_cd))
  CALL echo(build("Loc Fac Cd = ",temp->location.loc_facility_cd))
  CALL echo(build("Loc Bld Cd = ",temp->location.loc_building_cd))
 ELSE
  GO TO exit_script
 ENDIF
 SET a09 = 0
 SET a10 = 0
 SET flag = 0
 IF ((temp->prior_location.loc_unit_cd >= 0)
  AND (request->loc_temp_cd > 0))
  SET a09 = 9
  SET flag = 1
 ENDIF
 IF ((temp->prior_location.loc_unit_cd > 0)
  AND (((request->loc_temp_cd=0)) OR ((request->loc_temp_cd=- (1)))) )
  SET a10 = 10
  SET flag = 1
 ENDIF
 IF (flag=1)
  FREE RECORD srvrec
  RECORD srvrec(
    1 qual[*]
      2 msg_id = i4
      2 hmsg = i4
      2 hreq = i4
      2 hrep = i4
      2 status = i4
  )
  DECLARE init_srv_stuff(messageid,get_hreq,get_hrep) = i2
  DECLARE cleanup_srv_stuff(dummy1) = i2
  DECLARE hmsgtype = i4
  DECLARE hmsgstruct = i4
  DECLARE hcqmstruct = i4
  DECLARE htrigitem = i4
  DECLARE hallergyitem = i4
  DECLARE hreactionitem = i4
  DECLARE hallergy_commentitem = i4
  DECLARE cqmmessageid = i4
  DECLARE trigmessageid = i4
  SET cqmmessageid = 1215001
  SET trigmessageid = 1215029
 ENDIF
 IF ((eso_trigger_track->a09_ind=1)
  AND a09=9)
  CALL send_trigger(a09)
 ENDIF
 IF ((eso_trigger_track->a10_ind=1)
  AND a10=10)
  CALL send_trigger(a10)
 ENDIF
 GO TO exit_script
 SUBROUTINE get_loc_heir(loc_unit_cd_in)
   SET doneflag = 0
   SET rec_qual = 0
   SET temp->temp.loc_facility_cd = 0
   SET temp->temp.loc_building_cd = 0
   CALL echo(build("In GetLocHeir: loc_unit_cd_in = ",loc_unit_cd_in))
   WHILE ((temp->temp.loc_facility_cd=0)
    AND doneflag=0)
    SELECT INTO "nl:"
     lg.parent_loc_cd, lg.child_loc_cd, lg.location_group_type_cd,
     lg.root_loc_cd, cv.code_value, cv.cdf_meaning
     FROM location_group lg,
      code_value cv
     PLAN (lg
      WHERE lg.child_loc_cd=loc_unit_cd_in
       AND ((lg.root_loc_cd+ 0)=0)
       AND lg.active_ind=1
       AND lg.location_group_type_cd IN (fac_cd, bldg_cd))
      JOIN (cv
      WHERE cv.code_value=lg.parent_loc_cd
       AND cv.active_ind=1)
     HEAD REPORT
      rec_qual = 0, loc_unit_cd_in = 0
     DETAIL
      CASE (cv.cdf_meaning)
       OF "FACILITY":
        temp->temp.loc_facility_cd = lg.parent_loc_cd,temp->temp.loc_building_cd = lg.child_loc_cd,
        CALL echo(build("In Facility: loc_unit_cd_in = ",loc_unit_cd_in))
       OF "BUILDING":
        temp->temp.loc_building_cd = lg.parent_loc_cd,temp->temp.loc_unit_cd = lg.child_loc_cd,
        CALL echo(build("In Building: loc_unit_cd_in = ",loc_unit_cd_in))
      ENDCASE
      loc_unit_cd_in = lg.parent_loc_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET doneflag = 1
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE init_srv_stuff(messageid,get_hreq,get_hrep)
   CALL echo("In Init_Srv_Stuff() routine...")
   SET m_idx = size(srvrec->qual,5)
   SET m_idx += 1
   SET stat = alterlist(srvrec->qual,m_idx)
   SET srvrec->qual[m_idx].msg_id = messageid
   CALL echo(build("srvrec->qual[m_idx]->msg_id = ",srvrec->qual[m_idx].msg_id))
   SET srvrec->qual[m_idx].hmsg = uar_srvselectmessage(srvrec->qual[m_idx].msg_id)
   CALL echo(build("SrvSelectMessage returns: ",srvrec->qual[m_idx].hmsg))
   IF (srvrec->qual[m_idx].hmsg)
    IF (get_hreq)
     SET srvrec->qual[m_idx].hreq = uar_srvcreaterequest(srvrec->qual[m_idx].hmsg)
     IF ( NOT (srvrec->qual[m_idx].hreq))
      CALL echo("The uar_SrvCreateRequest() FAILED!!")
      RETURN(0)
     ENDIF
    ENDIF
    IF (get_hrep)
     SET srvrec->qual[m_idx].hrep = uar_srvcreatereply(srvrec->qual[m_idx].hmsg)
     IF ( NOT (srvrec->qual[m_idx].hrep))
      CALL echo("The uar_SrvCreateReply() FAILED!!")
      IF (srvrec->qual[m_idx].hreq)
       CALL uar_srvdestroyinstance(srvrec->qual[m_idx].hreq)
       SET srvrec->qual[m_idx].hreq = 0
      ENDIF
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    CALL echo("The uar_SrvSelectMessage() FAILED!!")
    RETURN(0)
   ENDIF
   CALL echo("Exiting Init_Srv_Stuff() routine... ")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE cleanup_srv_stuff(dummy1)
   CALL echo("In CleanUp_Srv_Stuff() routine...")
   FOR (i = 1 TO size(srvrec->qual,5))
     CALL echo(build("i = ",i))
     IF ((srvrec->qual[i].hreq > 0))
      CALL uar_srvdestroyinstance(srvrec->qual[i].hreq)
     ENDIF
     IF ((srvrec->qual[i].hrep > 0))
      CALL uar_srvdestroyinstance(srvrec->qual[i].hrep)
     ENDIF
   ENDFOR
   IF (size(srvrec->qual,5))
    SET stat = alterlist(srvrec->qual,0)
   ENDIF
   CALL echo("Exiting CleanUp_Srv_Stuff() routine...")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE send_trigger(sub_type)
   IF (sub_type=9)
    SET sub_t = "A09"
   ENDIF
   IF (sub_type=10)
    SET sub_t = "A10"
   ENDIF
   SET hmsgtype = 0
   SET hmsgstruct = 0
   SET hcqmstruct = 0
   SET htrigitem = 0
   SET htemplocitem = 0
   SET hpriortemplocitem = 0
   SET cqmmessageid = 1215001
   SET trigmessageid = 1215029
   CALL init_srv_stuff(cqmmessageid,1,1)
   CALL init_srv_stuff(trigmessageid,1,1)
   CALL echo("***   calling uar_SrvCreateRequestType( srvrec->qual[2]->hMsg )")
   SET hmsgtype = uar_srvcreaterequesttype(srvrec->qual[2].hmsg)
   CALL echo(build("hMsgType = ",hmsgtype))
   CALL echo("***   calling uar_SrvReCreateInstance( srvrec->qual[1]->hReq, hMsgType )")
   SET stat = uar_srvrecreateinstance(srvrec->qual[1].hreq,hmsgtype)
   CALL echo(build("Stat from SrvReCreateInstance = ",stat))
   CALL echo("***   calling uar_SrvGetStruct( srvrec->qual[1]->hReq ,message )")
   SET hmsgstruct = uar_srvgetstruct(srvrec->qual[1].hreq,"message")
   IF (hmsgstruct)
    CALL echo("***   made it into hMsgStruct")
    CALL echo("***   calling uar_SrvGetStruct( hMsgStruct ,cqminfo )")
    SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
    IF (hcqmstruct)
     CALL echo("***   made it into hCqmStruct")
     SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
     SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias","DCP_UPD_TEMP_LOC")
     SET contrib_temp = concat("TRACK",cnvtstring(request->encntr_id))
     CALL echo(build("ContribRefNum =  ",nullterm(trim(contrib_temp))))
     SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(trim(contrib_temp)))
     SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
     SET stat = uar_srvsetstring(hcqmstruct,"Class","TRACK_TRANS")
     SET stat = uar_srvsetstring(hcqmstruct,"Type","ADT")
     CALL echo(build("SubType = ",nullterm(trim(sub_t))))
     SET stat = uar_srvsetstring(hcqmstruct,"Subtype",nullterm(trim(sub_t)))
     SET stat = uar_srvsetstring(hcqmstruct,"Subtype_detail",nullterm(trim(cnvtstring(temp->person_id
         ))))
     SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
     SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
     CALL echo("***   calling uar_SrvAddItem( hMsgStruct, TRIGInfo )")
     SET htrigitem = uar_srvadditem(hmsgstruct,"TRIGInfo")
     IF (htrigitem)
      CALL echo("***   made it into hTrigItem")
      SET stat = uar_srvsetdouble(htrigitem,"person_id",temp->person_id)
      SET stat = uar_srvsetdouble(htrigitem,"encntr_id",request->encntr_id)
      CALL echo("***   calling uar_SrvAddItem( hTrigItem, temp_loc )")
      SET htemplocitem = uar_srvadditem(htrigitem,"temp_loc")
      IF (htemplocitem)
       CALL echo("***   made it into htemplocItem")
       SET stat = uar_srvsetdouble(htemplocitem,"root_loc_cd",request->root_loc_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"loc_type_cd",temp->loc_type_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"facility_cd",temp->location.loc_facility_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"building_cd",temp->location.loc_building_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"nurse_unit_cd",temp->location.loc_unit_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"room_cd",temp->location.loc_room_cd)
       SET stat = uar_srvsetdouble(htemplocitem,"bed_cd",temp->location.loc_bed_cd)
       CALL echo(build("Root Loc Cd = ",request->root_loc_cd))
       CALL echo(build("Loc Type Cd = ",temp->loc_type_cd))
       CALL echo(build("Nurse Unit Cd = ",temp->location.loc_unit_cd))
       CALL echo(build("Facility Cd = ",temp->location.loc_facility_cd))
       CALL echo(build("Building Cd = ",temp->location.loc_building_cd))
      ELSE
       CALL echo("*** failed htemplocItem**")
      ENDIF
      CALL echo("***   calling uar_SrvAddItem( hTrigItem, prior_temp_loc )")
      SET hpriortemplocitem = uar_srvadditem(htrigitem,"prior_temp_loc")
      IF (hpriortemplocitem)
       CALL echo("***   made it into hpriortemplocItem")
       SET stat = uar_srvsetdouble(hpriortemplocitem,"root_loc_cd",request->prior_root_loc_cd)
       SET stat = uar_srvsetdouble(hpriortemplocitem,"loc_type_cd",temp->prior_loc_type_cd)
       SET stat = uar_srvsetdouble(hpriortemplocitem,"facility_cd",temp->prior_location.
        loc_facility_cd)
       SET stat = uar_srvsetdouble(hpriortemplocitem,"building_cd",temp->prior_location.
        loc_building_cd)
       SET stat = uar_srvsetdouble(hpriortemplocitem,"nurse_unit_cd",temp->prior_location.loc_unit_cd
        )
       SET stat = uar_srvsetdouble(hpriortemplocitem,"room_cd",temp->prior_location.loc_room_cd)
       SET stat = uar_srvsetdouble(hpriortemplocitem,"bed_cd",temp->prior_location.loc_bed_cd)
       CALL echo(build("Prior Root Loc Cd = ",request->prior_root_loc_cd))
       CALL echo(build("Prior Loc Type Cd = ",temp->prior_loc_type_cd))
       CALL echo(build("Prior Nurse Unit Cd = ",temp->prior_location.loc_unit_cd))
       CALL echo(build("Prior Facility Cd = ",temp->prior_location.loc_facility_cd))
       CALL echo(build("Prior Building Cd = ",temp->prior_location.loc_building_cd))
      ELSE
       CALL echo("*** failed hpriortemplocItem**")
      ENDIF
     ELSE
      CALL echo("*** failed hTrigItem**")
     ENDIF
    ELSE
     CALL echo("*** failed hCqmStruct**")
    ENDIF
   ELSE
    CALL echo("*** failed hMsgStruct**")
   ENDIF
   CALL echo(build("***   calling uar_SrvExecute: hMsg:",srvrec->qual[1].hmsg))
   CALL echo(build("***   calling uar_SrvExecute: hReq:",srvrec->qual[1].hreq))
   CALL echo(build("***   calling uar_SrvExecute: hRep:",srvrec->qual[1].hrep))
   SET iret = uar_srvexecute(srvrec->qual[1].hmsg,srvrec->qual[1].hreq,srvrec->qual[1].hrep)
   CALL echo(build("Return from srv_execute = ",iret))
   CASE (iret)
    OF 0:
     CALL echo("Successful Srv Execute ")
    OF 1:
     CALL echo("Srv Execute failed - Communication Error - FSI Hold Release Server may be down")
    OF 2:
     IF (messageid=0)
      CALL echo("TDB Message Id is zero...")
     ELSE
      CALL echo("SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
     ENDIF
    OF 3:
     CALL echo("Failed to allocate either the Request or Reply Handle")
   ENDCASE
   IF (hmsgtype)
    CALL uar_srvdestroytype(hmsgtype)
    SET hmsgtype = 0
   ENDIF
   CALL cleanup_srv_stuff(1)
   IF (iret > 0)
    RECORD eso_request(
      1 message
        2 cqminfo
          3 appname = vc
          3 contribalias = vc
          3 contribrefnum = vc
          3 contribdttm = dq8
          3 priority = i4
          3 class = vc
          3 type = vc
          3 subtype = vc
          3 subtype_detail = vc
          3 debug_ind = i4
          3 verbosity_flag = i4
        2 esoinfo
          3 scriptcontrolval = i4
          3 scriptcontrolargs = vc
          3 dbnullprefix = vc
          3 aliasprefix = vc
          3 codeprefix = vc
          3 personprefix = vc
          3 eprsnlprefix = vc
          3 prsnlprefix = vc
          3 orderprefix = vc
          3 orgprefix = vc
          3 hlthplanprefix = vc
          3 nomenprefix = vc
          3 itemprefix = vc
          3 longlist[*]
            4 lval = i4
            4 strmeaning = vc
          3 stringlist[*]
            4 strval = vc
            4 strmeaning = vc
          3 doublelist[*]
            4 dval = f8
            4 strmeaning = vc
          3 sendobjectind = c1
        2 triginfo[1]
          3 person_id = f8
          3 encntr_id = f8
          3 temp_loc[1]
            4 root_loc_cd = f8
            4 loc_type_cd = f8
            4 facility_cd = f8
            4 building_cd = f8
            4 nurse_unit_cd = f8
            4 room_cd = f8
            4 bed_cd = f8
          3 prior_temp_loc[1]
            4 root_loc_cd = f8
            4 loc_type_cd = f8
            4 facility_cd = f8
            4 building_cd = f8
            4 nurse_unit_cd = f8
            4 room_cd = f8
            4 bed_cd = f8
      1 params[*]
    )
    SET eso_request->message.cqminfo.appname = "FSIESO"
    SET eso_request->message.cqminfo.contribalias = "DCP_UPD_TEMP_LOC"
    SET eso_request->message.cqminfo.contribrefnum = trim(contrib_temp)
    SET eso_request->message.cqminfo.priority = 99
    SET eso_request->message.cqminfo.class = "TRACK_TRANS"
    SET eso_request->message.cqminfo.type = "ADT"
    SET eso_request->message.cqminfo.subtype = trim(sub_t)
    SET eso_request->message.cqminfo.subtype_detail = trim(cnvtstring(temp->person_id))
    SET eso_request->message.cqminfo.debug_ind = 0
    SET eso_request->message.cqminfo.verbosity_flag = 0
    SET eso_request->message.triginfo[1].person_id = temp->person_id
    SET eso_request->message.triginfo[1].encntr_id = request->encntr_id
    SET eso_request->message.triginfo[1].temp_loc[1].root_loc_cd = request->root_loc_cd
    SET eso_request->message.triginfo[1].temp_loc[1].loc_type_cd = temp->loc_type_cd
    SET eso_request->message.triginfo[1].temp_loc[1].facility_cd = temp->location.loc_facility_cd
    SET eso_request->message.triginfo[1].temp_loc[1].building_cd = temp->location.loc_building_cd
    SET eso_request->message.triginfo[1].temp_loc[1].nurse_unit_cd = temp->location.loc_unit_cd
    SET eso_request->message.triginfo[1].temp_loc[1].room_cd = temp->location.loc_room_cd
    SET eso_request->message.triginfo[1].temp_loc[1].bed_cd = temp->location.loc_bed_cd
    CALL echo(build("eso_request->message->TRIGInfo[1]->person_id = ",eso_request->triginfo.person_id
      ))
    CALL echo(build("eso_request->message->TRIGInfo[1]->encntr_id = ",eso_request->triginfo.encntr_id
      ))
    SET eso_request->message.triginfo[1].prior_temp_loc[1].root_loc_cd = request->prior_root_loc_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].loc_type_cd = temp->prior_loc_type_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].facility_cd = temp->prior_location.
    loc_facility_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].building_cd = temp->prior_location.
    loc_building_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].nurse_unit_cd = temp->prior_location.
    loc_unit_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].room_cd = temp->prior_location.loc_room_cd
    SET eso_request->message.triginfo[1].prior_temp_loc[1].bed_cd = temp->prior_location.loc_bed_cd
    EXECUTE eso_pm_tracking_downtime  WITH replace("REQUEST","ESO_REQUEST")
   ENDIF
 END ;Subroutine
#exit_script
END GO
