CREATE PROGRAM dcp_io_med_detection_run:dba
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
 DECLARE continue_ind = i2 WITH protect, noconstant(1)
 DECLARE spaces = c78 WITH protect, constant(fillstring(78," "))
 SET trace = recpersist
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
 DECLARE startresultid = f8 WITH protect, constant(0.00)
 DECLARE endresultid = f8 WITH protect, constant(999999999999.00)
 DECLARE cdcpgeneric = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",72,"DCPGENERICCODE"))
 DECLARE cmlunit = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"ML"))
 DECLARE cmedadminentry = f8 WITH protect, constant(uar_get_code_by("MEANING",255431,"MEDADMIN"))
 DECLARE canesthesiaentry = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"ANESTHESIA"))
 DECLARE cundefinedentry = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"UNDEFINED"))
 DECLARE cinerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE civparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE num = i4 WITH protect
 DECLARE dstat = i2 WITH protect, noconstant(0)
 FREE SET events
 RECORD events(
   1 event_list[*]
     2 event_cd = f8
   1 event_cnt = i4
 )
 CALL loadiohierarchy(null)
 IF ((fluid_balance_event_sets->accum_intake_event_cd_map_cnt > 0))
  CALL echo("Inserting intake event_cds into event structure...")
  SET events->event_cnt = fluid_balance_event_sets->accum_intake_event_cd_map_cnt
  SET dstat = alterlist(events->event_list,events->event_cnt)
  FOR (cnt = 1 TO fluid_balance_event_sets->accum_intake_event_cd_map_cnt)
    SET events->event_list[cnt].event_cd = fluid_balance_event_sets->accum_intake_event_cd_map[cnt].
    event_cd
  ENDFOR
 ELSE
  CALL echo("No intake event_cds found")
  GO TO exit_program
 ENDIF
#menu
 SET message = window
 SET width = 80
 CALL clear(01,01)
 CALL video(r)
 CALL box(01,01,05,80)
 CALL text(02,02,spaces)
 CALL text(02,30,"IO Volume Correction")
 CALL text(03,02,spaces)
 CALL text(04,02,spaces)
 CALL video(n)
 CALL text(07,05,"Select an option to detect or update the affected IO data")
 CALL text(12,08,"(1) Detect affected IO data charted from Anesthesia")
 CALL text(14,08,"(2) Update affected IO data charted from Anesthesia")
 CALL text(16,08,"(3) Detect affected IO data charted from the")
 CALL text(17,14,"Medication Administration Wizard and CareMobile")
 CALL text(19,08,"(4) Update affected IO data charted from the")
 CALL text(20,14,"Medication Administration Wizard and CareMobile")
 CALL text(22,05,"YOUR CHOICE(0 TO EXIT):")
 CALL accept(22,29,"9;",0
  WHERE curaccept IN (0, 1, 2, 3, 4))
 CASE (curaccept)
  OF 0:
   CALL text(24,02,spaces)
   SET message = nowindow
   GO TO exit_program
  OF 1:
   SET message = nowindow
   GO TO detectscenario1
  OF 2:
   SET message = nowindow
   GO TO updatescenario1
  OF 3:
   SET message = nowindow
   GO TO detectscenario2
  OF 4:
   SET message = nowindow
   GO TO updatescenario2
 ENDCASE
#detectscenario1
 FREE RECORD scenario1
 RECORD scenario1(
   1 req_count = i4
   1 result_list[*]
     2 event_id = f8
 )
 SELECT INTO nl
  cir.event_id
  FROM ce_intake_output_result cir,
   clinical_event ce,
   ce_med_result cm,
   ce_result_set_link cr,
   person p,
   (dummyt d  WITH seq = value(size(events->event_list,5)))
  PLAN (d)
   JOIN (cir
   WHERE cir.ce_io_result_id >= startresultid
    AND cir.ce_io_result_id <= endresultid
    AND cir.reference_event_cd=cdcpgeneric
    AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND cir.io_volume > 0.0)
   JOIN (ce
   WHERE (ce.event_cd=events->event_list[d.seq].event_cd)
    AND ce.parent_event_id=cir.reference_event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.result_status_cd != cinerror)
   JOIN (cm
   WHERE ce.event_id=cm.event_id
    AND cm.dosage_unit_cd=cmlunit
    AND cm.infused_volume_unit_cd=cmlunit
    AND cm.admin_dosage > 0.0
    AND cm.infused_volume > 0.0
    AND (cir.io_volume=(cm.infused_volume+ cm.admin_dosage))
    AND cm.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cr
   WHERE cr.event_id=ce.event_id
    AND cr.entry_type_cd=cmedadminentry
    AND cr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (p
   WHERE p.person_id=cir.person_id)
  HEAD ce.parent_event_id
   io_result_count = 0
  HEAD cir.ce_io_result_id
   io_result_count = (io_result_count+ 1)
  DETAIL
   IF (io_result_count > 1)
    scenario1->result_list[scenario1->req_count].event_id = 0
   ELSE
    scenario1->req_count = (scenario1->req_count+ 1), stat = alterlist(scenario1->result_list,
     scenario1->req_count), scenario1->result_list[scenario1->req_count].event_id = cir.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  cir.event_id, cir.io_start_dt_tm, p.name_full_formatted
  FROM ce_intake_output_result cir,
   person p,
   (dummyt d  WITH seq = value(size(scenario1->result_list,5)))
  PLAN (d)
   JOIN (cir
   WHERE (cir.event_id=scenario1->result_list[d.seq].event_id))
   JOIN (p
   WHERE p.person_id=cir.person_id)
  WITH nocounter
 ;end select
 GO TO menu
#detectscenario2
 FREE RECORD scenario2
 RECORD scenario2(
   1 req_count = i4
   1 result_list[*]
     2 event_id = f8
 )
 SELECT INTO nl
  cir.event_id
  FROM ce_intake_output_result cir,
   clinical_event ce,
   ce_med_result cm,
   ce_result_set_link cr,
   person p,
   orders o
  PLAN (cir
   WHERE cir.ce_io_result_id >= startresultid
    AND cir.ce_io_result_id <= endresultid
    AND cir.reference_event_cd=cdcpgeneric
    AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND cir.io_volume > 0.0)
   JOIN (ce
   WHERE expand(num,1,events->event_cnt,ce.event_cd,events->event_list[num].event_cd)
    AND ce.parent_event_id=cir.reference_event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.result_status_cd != cinerror)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND o.ad_hoc_order_flag > 0)
   JOIN (cm
   WHERE ce.event_id=cm.event_id
    AND cm.dosage_unit_cd=cmlunit
    AND cm.infused_volume_unit_cd=cmlunit
    AND cm.admin_dosage > 0.0
    AND cm.infused_volume > 0.0
    AND (cir.io_volume=(cm.infused_volume+ cm.admin_dosage))
    AND cm.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (cr
   WHERE cr.event_id=ce.event_id
    AND cr.entry_type_cd=cmedadminentry
    AND cr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (p
   WHERE p.person_id=cir.person_id)
  HEAD ce.parent_event_id
   io_result_count2 = 0
  HEAD cir.ce_io_result_id
   io_result_count2 = (io_result_count2+ 1)
  DETAIL
   IF (io_result_count2 > 1)
    stat = alterlist(scenario2->result_list,scenario2->req_count), scenario2->result_list[scenario2->
    req_count].event_id = 0
   ELSE
    scenario2->req_count = (scenario2->req_count+ 1), stat = alterlist(scenario2->result_list,
     scenario2->req_count), scenario2->result_list[scenario2->req_count].event_id = cir.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  cir.event_id, cir.io_start_dt_tm, p.name_full_formatted
  FROM ce_intake_output_result cir,
   person p,
   (dummyt d  WITH seq = value(size(scenario2->result_list,5)))
  PLAN (d)
   JOIN (cir
   WHERE (cir.event_id=scenario2->result_list[d.seq].event_id))
   JOIN (p
   WHERE p.person_id=cir.person_id)
  WITH nocounter
 ;end select
 GO TO menu
#updatescenario1
 SET list_size = size(scenario1->result_list,5)
 IF (list_size <= 0)
  GO TO menu
 ENDIF
 DECLARE result_cnt = i4 WITH protect, noconstant(0)
 FOR (result_cnt = 1 TO list_size)
   IF ((scenario1->result_list[result_cnt].event_id=0))
    CALL echo("Multiple CIR records found for event, no update needed")
   ELSE
    UPDATE  FROM ce_intake_output_result cir
     SET cir.io_volume = (cir.io_volume/ 2), cir.updt_id = reqinfo->updt_id, cir.updt_task = reqinfo
      ->updt_task,
      cir.updt_applctx = reqinfo->updt_applctx, cir.updt_cnt = 0, cir.updt_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WHERE (cir.event_id=scenario1->result_list[result_cnt].event_id)
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 GO TO menu
#updatescenario2
 SET list_size = size(scenario2->result_list,5)
 IF (list_size <= 0)
  GO TO menu
 ENDIF
 DECLARE result_cnt = i4 WITH protect, noconstant(0)
 FOR (result_cnt = 1 TO list_size)
   IF ((scenario2->result_list[result_cnt].event_id=0))
    CALL echo("Multiple CIR records found for event, no update needed")
   ELSE
    UPDATE  FROM ce_intake_output_result cir
     SET cir.io_volume = (cir.io_volume/ 2), cir.updt_id = reqinfo->updt_id, cir.updt_task = reqinfo
      ->updt_task,
      cir.updt_applctx = reqinfo->updt_applctx, cir.updt_cnt = 0, cir.updt_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WHERE (cir.event_id=scenario2->result_list[result_cnt].event_id)
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 GO TO menu
#exit_program
END GO
