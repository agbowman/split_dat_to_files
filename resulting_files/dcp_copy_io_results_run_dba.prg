CREATE PROGRAM dcp_copy_io_results_run:dba
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 FREE RECORD fluid_balance_event_sets
 RECORD fluid_balance_event_sets(
   1 event_set_list_cnt = i4
   1 event_set_list[*]
     2 event_set_name = vc
     2 event_set_key = vc
     2 event_set_display = vc
     2 accumulation_ind = i2
     2 event_set_cd = f8
     2 intake_ind = i2
     2 output_ind = i2
     2 event_cd_list_cnt = i4
     2 event_cd_list[*]
       3 event_cd = f8
   1 event_cd_map_cnt = i4
   1 event_cd_map[*]
     2 event_cd = f8
     2 event_set_idx = i4
   1 accum_intake_event_cd_map_cnt = i4
   1 accum_intake_event_cd_map[*]
     2 event_cd = f8
     2 event_set_idx = i4
 )
 IF ( NOT (validate(event_sets,0)))
  RECORD event_sets(
    1 sets[4]
      2 event_set_name = vc
      2 event_set_cd = f8
  )
  SET event_sets->sets[1].event_set_name = "Fluid Balance"
  SET event_sets->sets[2].event_set_name = ""
  SET event_sets->sets[3].event_set_name = ""
  SET event_sets->sets[4].event_set_name = ""
 ENDIF
 IF (validate(bglobaldebugflag)=0)
  DECLARE bglobaldebugflag = i2 WITH noconstant(0)
 ENDIF
 IF (validate(request)=1
  AND validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET bglobaldebugflag = 1
  ENDIF
 ENDIF
 DECLARE loadiohierarchy(null) = null WITH public
 DECLARE loadioeventsetnames(null) = null WITH public
 DECLARE loadioeventsetcds(null) = null WITH public
 DECLARE loadiohierarchyeventcodes(null) = null WITH public
 DECLARE loadiohierarchyeventsets(null) = null WITH public
 SUBROUTINE loadiohierarchy(null)
   CALL loadioeventsetnames(null)
   CALL loadioeventsetcds(null)
   IF (bglobaldebugflag=1)
    CALL echorecord(event_sets)
   ENDIF
   CALL loadiohierarchyeventcodes(null)
   CALL loadiohierarchyeventsets(null)
   IF (bglobaldebugflag=2)
    CALL echorecord(fluid_balance_event_sets)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadioeventsetnames(null)
   DECLARE dselecttimer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE intake_found_ind = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    vesc2.event_set_name
    FROM v500_event_set_code vesc1,
     v500_event_set_canon vesca,
     v500_event_set_code vesc2
    PLAN (vesc1
     WHERE vesc1.event_set_name_key=cnvtupper(cnvtalphanum(event_sets->sets[1].event_set_name))
      AND cnvtupper(vesc1.event_set_name)=cnvtupper(event_sets->sets[1].event_set_name))
     JOIN (vesca
     WHERE vesca.parent_event_set_cd=vesc1.event_set_cd)
     JOIN (vesc2
     WHERE vesc2.event_set_cd=vesca.event_set_cd)
    ORDER BY vesca.event_set_collating_seq
    HEAD vesca.event_set_collating_seq
     IF (intake_found_ind=false)
      event_sets->sets[2].event_set_name = vesc2.event_set_name, intake_found_ind = true
     ELSE
      event_sets->sets[3].event_set_name = vesc2.event_set_name
     ENDIF
    WITH nocounter
   ;end select
   IF (bglobaldebugflag=1)
    CALL echo(build("Select Timer:  LoadIOEventSetNames->",datetimediff(cnvtdatetime(curdate,curtime3
        ),dselecttimer,5)))
   ENDIF
   IF (curqual > 2)
    IF (bglobaldebugflag=1)
     CALL echo("There are more than two event-sets present under the 'Fluid Balance' event set!")
    ENDIF
    GO TO exit_report_builder
   ENDIF
 END ;Subroutine
 SUBROUTINE loadioeventsetcds(null)
   DECLARE dselecttimer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SELECT INTO "nl:"
    vesc.event_set_cd, vesc.event_set_name_key
    FROM (dummyt d1  WITH seq = value(4)),
     v500_event_set_code vesc
    PLAN (d1
     WHERE (event_sets->sets[d1.seq].event_set_name > " "))
     JOIN (vesc
     WHERE vesc.event_set_name_key=cnvtupper(cnvtalphanum(event_sets->sets[d1.seq].event_set_name))
      AND cnvtupper(vesc.event_set_name)=cnvtupper(event_sets->sets[d1.seq].event_set_name))
    DETAIL
     event_sets->sets[d1.seq].event_set_cd = vesc.event_set_cd
    WITH nocounter
   ;end select
   IF (bglobaldebugflag=1)
    CALL echo(build("Select Timer:  LoadIOEventSetCds->",datetimediff(cnvtdatetime(curdate,curtime3),
       dselecttimer,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadiohierarchyeventcodes(null)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   DECLARE dselecttimer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   SELECT INTO "nl:"
    FROM v500_event_set_explode vese,
     v500_event_code vec
    PLAN (vese
     WHERE vese.event_set_cd IN (event_sets->sets[2].event_set_cd, event_sets->sets[3].event_set_cd))
     JOIN (vec
     WHERE vec.event_cd=vese.event_cd)
    HEAD vec.event_cd
     lvidx = 0, es_key = cnvtupper(cnvtalphanum(vec.event_set_name))
     IF ((fluid_balance_event_sets->event_set_list_cnt > 0))
      lvidx = locateval(expand_index,1,fluid_balance_event_sets->event_set_list_cnt,es_key,
       fluid_balance_event_sets->event_set_list[expand_index].event_set_key,
       vec.event_set_name,fluid_balance_event_sets->event_set_list[expand_index].event_set_name)
     ENDIF
     IF (lvidx <= 0)
      fluid_balance_event_sets->event_set_list_cnt = (fluid_balance_event_sets->event_set_list_cnt+ 1
      )
      IF (mod(fluid_balance_event_sets->event_set_list_cnt,50)=1)
       stat = alterlist(fluid_balance_event_sets->event_set_list,(fluid_balance_event_sets->
        event_set_list_cnt+ 49))
      ENDIF
      lvidx = fluid_balance_event_sets->event_set_list_cnt, fluid_balance_event_sets->event_set_list[
      lvidx].event_cd_list_cnt = 0
     ENDIF
     IF (lvidx > 0)
      fluid_balance_event_sets->event_set_list[lvidx].event_set_name = vec.event_set_name,
      fluid_balance_event_sets->event_set_list[lvidx].event_set_key = es_key
      IF ((vese.event_set_cd=event_sets->sets[2].event_set_cd))
       fluid_balance_event_sets->event_set_list[lvidx].intake_ind = 1, fluid_balance_event_sets->
       event_set_list[lvidx].output_ind = 0
      ELSEIF ((vese.event_set_cd=event_sets->sets[3].event_set_cd))
       fluid_balance_event_sets->event_set_list[lvidx].output_ind = 1, fluid_balance_event_sets->
       event_set_list[lvidx].intake_ind = 0
      ELSEIF (bglobaldebugflag=1)
       CALL echo(build("Unable to set output or intake indicator for event_set_cd->",vese
        .event_set_cd))
      ENDIF
      event_cd_list_cnt = (fluid_balance_event_sets->event_set_list[lvidx].event_cd_list_cnt+ 1),
      fluid_balance_event_sets->event_set_list[lvidx].event_cd_list_cnt = event_cd_list_cnt, stat =
      alterlist(fluid_balance_event_sets->event_set_list[lvidx].event_cd_list,event_cd_list_cnt),
      fluid_balance_event_sets->event_set_list[lvidx].event_cd_list[event_cd_list_cnt].event_cd = vec
      .event_cd, fluid_balance_event_sets->event_cd_map_cnt = (fluid_balance_event_sets->
      event_cd_map_cnt+ 1)
      IF (mod(fluid_balance_event_sets->event_cd_map_cnt,100)=1)
       stat = alterlist(fluid_balance_event_sets->event_cd_map,(fluid_balance_event_sets->
        event_cd_map_cnt+ 99))
      ENDIF
      fluid_balance_event_sets->event_cd_map[fluid_balance_event_sets->event_cd_map_cnt].event_cd =
      vec.event_cd, fluid_balance_event_sets->event_cd_map[fluid_balance_event_sets->event_cd_map_cnt
      ].event_set_idx = lvidx
     ENDIF
    WITH nocounter
   ;end select
   IF (bglobaldebugflag=1)
    CALL echo(build("Select Timer:  LoadIOHierarchyEventCodes->",datetimediff(cnvtdatetime(curdate,
        curtime3),dselecttimer,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadiohierarchyeventsets(null)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE nexpandsize = i4 WITH protect, noconstant(50)
   DECLARE nexpandtotal = i4 WITH protect, noconstant(0)
   DECLARE bstat = i2 WITH protect, noconstant(0)
   DECLARE dselecttimer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   IF ((fluid_balance_event_sets->event_set_list_cnt > 0))
    SET nexpandsize = 50
    SET nexpandtotal = (ceil((cnvtreal(fluid_balance_event_sets->event_set_list_cnt)/ nexpandsize))
     * nexpandsize)
    SET bstat = alterlist(fluid_balance_event_sets->event_set_list,nexpandtotal)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      v500_event_set_code vesc
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (vesc
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),vesc
       .event_set_name_key,fluid_balance_event_sets->event_set_list[expand_index].event_set_key))
     ORDER BY vesc.event_set_cd
     HEAD vesc.event_set_cd
      FOR (lvidx = 1 TO nexpandtotal)
        IF ((vesc.event_set_name_key=fluid_balance_event_sets->event_set_list[lvidx].event_set_key)
         AND cnvtupper(vesc.event_set_name)=cnvtupper(fluid_balance_event_sets->event_set_list[lvidx]
         .event_set_name))
         fluid_balance_event_sets->event_set_list[lvidx].accumulation_ind = vesc.accumulation_ind,
         fluid_balance_event_sets->event_set_list[lvidx].event_set_cd = vesc.event_set_cd,
         fluid_balance_event_sets->event_set_list[lvidx].event_set_display = trim(vesc
          .event_set_cd_disp,3)
         IF (vesc.accumulation_ind=1
          AND (fluid_balance_event_sets->event_set_list[lvidx].intake_ind=1))
          FOR (leventcdidx = 1 TO fluid_balance_event_sets->event_set_list[lvidx].event_cd_list_cnt)
            fluid_balance_event_sets->accum_intake_event_cd_map_cnt = (fluid_balance_event_sets->
            accum_intake_event_cd_map_cnt+ 1)
            IF (mod(fluid_balance_event_sets->accum_intake_event_cd_map_cnt,50)=1)
             stat = alterlist(fluid_balance_event_sets->accum_intake_event_cd_map,(
              fluid_balance_event_sets->accum_intake_event_cd_map_cnt+ 49))
            ENDIF
            fluid_balance_event_sets->accum_intake_event_cd_map[fluid_balance_event_sets->
            accum_intake_event_cd_map_cnt].event_cd = fluid_balance_event_sets->event_set_list[lvidx]
            .event_cd_list[leventcdidx].event_cd, fluid_balance_event_sets->
            accum_intake_event_cd_map[fluid_balance_event_sets->accum_intake_event_cd_map_cnt].
            event_set_idx = lvidx
          ENDFOR
         ENDIF
         lvidx = nexpandtotal
        ENDIF
      ENDFOR
     FOOT REPORT
      bstat = alterlist(fluid_balance_event_sets->accum_intake_event_cd_map,fluid_balance_event_sets
       ->accum_intake_event_cd_map_cnt)
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     CALL echo(build("Select Timer:  LoadIOHierarchyEventSets->",datetimediff(cnvtdatetime(curdate,
         curtime3),dselecttimer,5)))
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE checksupportedlocale(null) = i2 WITH protect
 SUBROUTINE checksupportedlocale(null)
   DECLARE current_locale = vc WITH protect, noconstant("")
   SET current_locale = cnvtupper(logical("CCL_LANG"))
   IF (current_locale="")
    SET current_locale = cnvtupper(logical("LANG"))
   ENDIF
   IF (current_locale IN ("EN_US", "EN_UK", "EN_AUS", "EN_US.*", "EN_UK.*",
   "EN_AUS.*"))
    RETURN(1)
   ENDIF
   CALL echo(logical("CCL_LANG"))
   CALL echo(logical("LANG"))
   CALL echo(
    "The current back-end configuration is not compatible, please contact your system administrator")
   RETURN(0)
 END ;Subroutine
 FREE RECORD string_struct_p
 RECORD string_struct_p(
   1 ms_err_msg = vc
   1 ms_child1_info_char = vc
   1 ms_child2_info_char = vc
   1 ms_child3_info_char = vc
   1 ms_zero_char = vc
 )
 DECLARE continue_ind = i2 WITH protect, noconstant(1)
 DECLARE spaces = c78 WITH protect, constant(fillstring(78," "))
 DECLARE copy_numeric_ind = i2 WITH protect, noconstant(0)
 DECLARE copy_med_ind = i2 WITH protect, noconstant(0)
 DECLARE copy_iv_ind = i2 WITH protect, noconstant(0)
 DECLARE option_disp = vc WITH protect, noconstant(" ")
 DECLARE mf_count_success = i4 WITH protect, noconstant(0)
 DECLARE mf_count = i4 WITH protect, noconstant(0)
 DECLARE mf_count_row = i4 WITH protect, noconstant(0)
 DECLARE mf_child_size = f8 WITH protect, noconstant(0.0)
 DECLARE mf_min_epr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_epr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child1_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child2_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child3_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child1_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child2_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_child3_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE active = f8 WITH protect, noconstant(0.0)
 DECLARE mn_success = i2 WITH protect, noconstant(0)
 DECLARE gn_child_success = i2 WITH public, noconstant(0)
 DECLARE pn_dummy = i2 WITH protect, noconstant(0)
 DECLARE insert_dm_info(domain=vc,name=vc,char=vc) = i2 WITH protect
 DECLARE update_dm_info(domain=vc,name=vc,char=vc) = i2 WITH protect
 DECLARE check_procedure(name=vc,type=vc) = i2 WITH protect
 DECLARE display_screen(title=vc,x_pos=i2) = i2 WITH protect
 DECLARE write_dm_info(numeric=i2,med=i2,iv=i2) = i2 WITH protect
 DECLARE execute_children_processes(dummy=i2) = i2 WITH protect
 DECLARE loadeventcodes(null) = null WITH protect
 IF (checksupportedlocale(null)=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT*"
  HEAD REPORT
   mf_count_row = 0
  DETAIL
   mf_count_row = (mf_count_row+ 1)
  WITH nocounter
 ;end select
 IF (error(string_struct_p->ms_err_msg,0) != 0)
  CALL echo(concat("Failure selecting from DM_INFO:",string_struct_p->ms_err_msg))
  GO TO exit_program
 ENDIF
 IF (mf_count_row=9)
  CALL loadeventcodes(null)
  CALL execute_children_processes(pn_dummy)
 ELSE
  SET message = window
  SET width = 80
  CALL display_screen(" ",0)
  WHILE (continue_ind)
    CALL display_screen("SETUP MENU",36)
    CALL text(07,05,"PLEASE CHOOSE ONE OF THE FOLLOWING OPTIONS:")
    CALL text(09,08,"(1)  COPY NUMERIC RESULTS ONLY")
    CALL text(11,08,"(2)  COPY NUMERIC AND MEDICATION RESULTS ONLY")
    CALL text(13,08,"(3)  COPY NUMERIC AND IV RESULTS ONLY")
    CALL text(15,08,"(4)  COPY NUMERIC, MEDICATION, AND IV RESULTS")
    CALL text(18,05,"YOUR CHOICE(0 TO EXIT):")
    CALL accept(18,29,"9;",0
     WHERE curaccept IN (0, 1, 2, 3, 4))
    CASE (curaccept)
     OF 0:
      SET continue_ind = 0
      CALL text(24,02,spaces)
      SET message = nowindow
      GO TO exit_program
     OF 1:
      SET copy_numeric_ind = 1
      SET option_disp = " NUMERIC RESULTS ONLY "
     OF 2:
      SET copy_numeric_ind = 1
      SET copy_med_ind = 1
      SET option_disp = " NUMERIC AND MEDICATION RESULTS ONLY "
     OF 3:
      SET copy_numeric_ind = 1
      SET copy_iv_ind = 1
      SET option_disp = " NUMERIC AND IV RESULTS ONLY "
     OF 4:
      SET copy_numeric_ind = 1
      SET copy_med_ind = 1
      SET copy_iv_ind = 1
      SET option_disp = " NUMERIC, MEDICATION, AND IV RESULTS "
    ENDCASE
    CALL display_screen("SETUP MENU",36)
    CALL text(07,05,"WARNING!!! PLEASE VERIFY THAT YOUR SELECTION IS CONSISTENT WITH ALL")
    CALL text(08,05,"SITE POLICIES AND PRACTICES. ONLY HISTORICAL INTAKE AND OUTPUT DATA THAT")
    CALL text(09,05,"MATCHES YOUR SELECTION WILL BE PERMANENTLY COPIED AND BE MADE VIEWABLE")
    CALL text(10,05,"ON THE IO2G FLOWSHEET. YOU WILL NOT BE ALLOWED TO MODIFY YOUR SELECTION")
    CALL text(11,05,"ONCE THE COPY PROCESS HAS BEGUN")
    CALL video(u)
    CALL text(13,05,concat("YOU HAVE CHOSEN TO COPY",option_disp))
    CALL video(n)
    CALL text(14,05,"IS THIS CORRECT(Y OR N)?")
    CALL accept(14,30,"A;CU","N"
     WHERE curaccept IN ("Y", "N"))
    CASE (curaccept)
     OF "Y":
      SET continue_ind = 0
      CALL text(24,02,spaces)
      SET message = nowindow
     OF "N":
      SET copy_numeric_ind = 0
      SET copy_med_ind = 0
      SET copy_iv_ind = 0
    ENDCASE
  ENDWHILE
  CALL loadeventcodes(null)
  CALL write_dm_info(copy_numeric_ind,copy_med_ind,copy_iv_ind)
  CALL execute_children_processes(pn_dummy)
 ENDIF
 SUBROUTINE loadeventcodes(null)
   CALL echo("LOADING THE FLUID BALANCE HIERARCHY...")
   CALL loadiohierarchy(null)
   CALL parser("rdb create global temporary table dcp_copy_medsin_temp")
   CALL parser("(event_cd number")
   CALL parser(") on commit preserve rows go")
   EXECUTE oragen3 value("DCP_COPY_MEDSIN_TEMP")
   IF (error(string_struct_p->ms_err_msg,0) != 0)
    GO TO exit_program
   ENDIF
   IF ((fluid_balance_event_sets->accum_intake_event_cd_map_cnt > 0))
    CALL echo("INSERTING THE ACCUMULATING INTAKE EVENT_CDS INTO TEMP TABLE...")
    INSERT  FROM dcp_copy_medsin_temp dcmit,
      (dummyt d  WITH seq = fluid_balance_event_sets->accum_intake_event_cd_map_cnt)
     SET dcmit.event_cd = fluid_balance_event_sets->accum_intake_event_cd_map[d.seq].event_cd
     PLAN (d)
      JOIN (dcmit)
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE execute_children_processes(dummy)
   FOR (mf_count = 1 TO 3)
     EXECUTE dcp_copy_io_results_child_num
     IF (gn_child_success=0)
      CALL echo("CHILD PROCESS NUMERIC HAS ENCOUNTERED AN ERROR... EXIT: ")
      GO TO exit_program
     ENDIF
     EXECUTE dcp_copy_io_results_child_med
     IF (gn_child_success=0)
      CALL echo("CHILD PROCESS MED HAS ENCOUNTERED AN ERROR... EXIT: ")
      GO TO exit_program
     ENDIF
     EXECUTE dcp_copy_io_results_child_iv
     IF (gn_child_success=0)
      CALL echo("CHILD PROCESS IV HAS ENCOUNTERED AN ERROR... EXIT: ")
      GO TO exit_program
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE write_dm_info(numeric,med,iv)
   SET mf_min_epr_id = 1.0
   CALL echo("DETERMINING THE MAX EVENT_ID TO CONVERT...")
   SELECT INTO "nl:"
    max_id = max(event_id)
    FROM clinical_event
    DETAIL
     mf_max_epr_id = max_id
    WITH nocounter
   ;end select
   IF (error(string_struct_p->ms_err_msg,0) != 0)
    CALL echo(concat("Failure determining the max event_id from the clinical_event table:",
      string_struct_p->ms_err_msg))
    GO TO exit_program
   ENDIF
   SET mf_child_size = round(((mf_max_epr_id - mf_min_epr_id)/ 3),0)
   SET mf_child1_min_id = mf_min_epr_id
   SET mf_child1_max_id = ((mf_min_epr_id+ mf_child_size) - 1)
   SET mf_child2_min_id = (mf_min_epr_id+ mf_child_size)
   SET mf_child2_max_id = ((mf_min_epr_id+ (2 * mf_child_size)) - 1)
   SET mf_child3_min_id = (mf_min_epr_id+ (2 * mf_child_size))
   SET mf_child3_max_id = mf_max_epr_id
   SET string_struct_p->ms_child1_info_char = concat("min:",cnvtstring(mf_child1_min_id),":max:",
    cnvtstring(mf_child1_max_id))
   SET string_struct_p->ms_child2_info_char = concat("min:",cnvtstring(mf_child2_min_id),":max:",
    cnvtstring(mf_child2_max_id))
   SET string_struct_p->ms_child3_info_char = concat("min:",cnvtstring(mf_child3_min_id),":max:",
    cnvtstring(mf_child3_max_id))
   IF (error(string_struct_p->ms_err_msg,0) != 0)
    CALL echo(concat("ERROR WRITING TO THE DM_INFO TABLE:",string_struct_p->ms_err_msg))
    GO TO exit_program
   ENDIF
   IF (numeric=1)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_child1_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_child2_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_child3_info_char)
   ELSE
    SET string_struct_p->ms_zero_char = concat("min:",cnvtstring(0),":max:",cnvtstring(0))
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - NUMERIC",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_zero_char)
   ENDIF
   IF (med=1)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_child1_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_child2_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_child3_info_char)
    CALL parser("rdb create global temporary table dcp_copy_meds_temp")
    CALL parser("(unique_id number,")
    CALL parser("parent_id number,")
    CALL parser("io_volume number")
    CALL parser(") on commit preserve rows go")
    EXECUTE oragen3 value("DCP_COPY_MEDS_TEMP")
    IF (error(string_struct_p->ms_err_msg,0) != 0)
     GO TO exit_program
    ENDIF
   ELSE
    SET string_struct_p->ms_zero_char = concat("min:",cnvtstring(0),":max:",cnvtstring(0))
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - MED",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_zero_char)
   ENDIF
   IF (iv=1)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_child1_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_child2_info_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_child3_info_char)
   ELSE
    SET string_struct_p->ms_zero_char = concat("min:",cnvtstring(0),":max:",cnvtstring(0))
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 1 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 2 EVALUATED",string_struct_p->ms_zero_char)
    CALL insert_dm_info("COPY EXISTING IO RESULTS TO IO2G COMPATIBLE PARENT - IV",
     "EVENT_ID RANGE 3 EVALUATED",string_struct_p->ms_zero_char)
   ENDIF
   EXECUTE dm_readme_include_sql "cer_install:dcp_copy_io_results_procedures.sql"
   EXECUTE dm_readme_include_sql "cer_install:dcp_copy_io_results_functions.sql"
   CALL check_procedure("dcp_parse_numeric_string","function")
   CALL check_procedure("dcp_parse_numeric_string_c","procedure")
   CALL check_procedure("dcp_get_new_dosage","function")
   CALL check_procedure("dcp_get_new_dosage_c","procedure")
   CALL check_procedure("dcp_get_old_dosage","function")
   CALL check_procedure("dcp_get_old_dosage_c","procedure")
 END ;Subroutine
 SUBROUTINE display_screen(title,x_pos)
   CALL clear(01,01)
   CALL video(r)
   CALL box(01,01,05,80)
   CALL text(02,02,spaces)
   CALL text(02,33,"IO2G CONVERSION")
   CALL text(03,02,spaces)
   CALL text(04,02,spaces)
   IF (textlen(trim(title,3)) > 0
    AND x_pos > 0)
    CALL video(u)
    CALL text(04,x_pos,title)
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE check_procedure(name,type)
  EXECUTE dm_readme_include_sql_chk cnvtupper(value(name)), value(type)
  IF ((dm_sql_reply->status="F"))
   CALL echo(concat("FAILED TO CREATE SQL FUNCTION: ",name))
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_dm_info(domain,name,char)
  INSERT  FROM dm_info di
   SET di.info_domain = domain, di.info_name = name, di.info_number = 0,
    di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = char
   WITH nocounter
  ;end insert
  IF (error(string_struct_p->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO INSERT RANGE VALUES INTO DM_INFO TABLE:",string_struct_p->ms_err_msg))
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE update_dm_info(domain,name,char)
  UPDATE  FROM dm_info di
   SET di.info_number = 0, di.info_date = cnvtdatetime(curdate,curtime3), di.info_char = char
   WHERE di.info_domain=domain
    AND di.info_name=name
   WITH nocounter
  ;end update
  IF (error(string_struct_p->ms_err_msg,0) != 0)
   CALL echo(concat("FAILED TO UPDATE RANGE VALUES INTO DM_INFO TABLE:",string_struct_p->ms_err_msg))
   GO TO exit_program
  ENDIF
 END ;Subroutine
 CALL echo("THIS SESSION HAS COMPLETED SUCCESSFULLY")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COPY EXISTING IO RESULTS TO IO2G COMPATIBLE*"
   AND di.info_name="MAX EVENT_ID EVALUATED BY*"
  HEAD REPORT
   mf_count_success = 0
  DETAIL
   IF (di.info_char="SUCCESS")
    mf_count_success = (mf_count_success+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (mf_count_success=9)
  CALL echo("***************************************************************")
  CALL echo("ALL ROWS HAVE BEEN SUCCESSFULLY CONVERTED")
  CALL echo("***************************************************************")
  CALL parser("rdb truncate table dcp_copy_meds_temp go")
  CALL parser("rdb truncate table dcp_copy_medsin_temp go")
  CALL parser("rdb drop function dcp_get_new_dosage go")
  CALL parser("rdb drop function dcp_get_old_dosage go")
  CALL parser("rdb drop procedure dcp_get_new_dosage_c go")
  CALL parser("rdb drop procedure dcp_get_old_dosage_c go")
  CALL parser("rdb drop procedure dcp_parse_numeric_string_c go")
  CALL parser("rdb drop function dcp_parse_numeric_string go")
  IF (copy_med_ind=1)
   CALL parser("rdb drop table dcp_copy_meds_temp go")
  ENDIF
  CALL parser("rdb drop table dcp_copy_medsin_temp go")
 ELSE
  CALL echo("OTHER SESSIONS ARE STILL IN PROCESS")
 ENDIF
 SET mn_success = 1
#exit_program
 FREE RECORD string_struct_p
 IF (mn_success=0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
