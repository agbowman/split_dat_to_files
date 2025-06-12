CREATE PROGRAM dcp_pcla_io_summary:dba
 DECLARE bglobaldebugflag = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET bglobaldebugflag = 1
  ENDIF
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 patient[*]
      2 io_cnt = i2
      2 io[*]
        3 io_dt_tm = dq8
        3 intake = f8
        3 output = f8
        3 balance = f8
        3 io_dt_disp = vc
        3 contain_unconfirmed_io_ind = i2
      2 encounter_preference = vc
      2 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(event_sets,0)))
  RECORD event_sets(
    1 sets[4]
      2 event_set_name = vc
      2 event_set_cd = f8
  )
 ENDIF
 FREE RECORD day
 RECORD day(
   1 days[5]
     2 weekday = i2
     2 daycnt = i2
 )
 SET reply->status_data.status = "F"
 DECLARE retrieveio_data(null) = null WITH public
 DECLARE retrieveio2g_data(null) = null WITH public
 DECLARE intake = i2 WITH public, constant(1)
 DECLARE output = i2 WITH public, constant(2)
 DECLARE patients = i4 WITH public, constant(size(request->patient,5))
 DECLARE inerror = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE bolus = f8 WITH public, constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE infuse = f8 WITH public, constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE med = f8 WITH public, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE num = f8 WITH public, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE ml = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3780"))
 DECLARE ivparent = f8 WITH public, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE dcpgeneric = f8 WITH public, noconstant(0.0)
 DECLARE pwrchart = f8 WITH public, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE confirmed = f8 WITH public, constant(uar_get_code_by("MEANING",4000160,"CONFIRMED"))
 DECLARE med_order_iv_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"IV"))
 IF ((pwrchart > - (1.0)))
  SELECT INTO "nl:"
   cva.code_value
   FROM code_value_alias cva
   WHERE cva.alias="DCPGENERIC"
    AND cva.code_set=72.0
    AND cva.contributor_source_cd=pwrchart
   DETAIL
    dcpgeneric = cva.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF ((((inerror=- (1.0))) OR ((((bolus=- (1.0))) OR ((((infuse=- (1.0))) OR ((((med=- (1.0))) OR ((((
 num=- (1.0))) OR ((((ml=- (1.0))) OR ((((ivparent=- (1.0))) OR ((((pwrchart=- (1.0))) OR (((
 dcpgeneric=0.0) OR ((confirmed=- (1.0)))) )) )) )) )) )) )) )) )) )
  CALL echo("CODE VALUE MISSING")
  GO TO exit_program
 ENDIF
 DECLARE first_ind = i2 WITH public, noconstant(false)
 DECLARE daycnt = i4 WITH public, noconstant(0)
 DECLARE cnt1 = i4 WITH public, noconstant(0)
 DECLARE pval = i2 WITH public, noconstant(0)
 DECLARE beg_dt_tm = dq8 WITH public, noconstant(datetimeadd(cnvtdatetime(curdate,0),- (4)))
 DECLARE end_dt_tm = dq8 WITH public, noconstant(cnvtdatetime(curdate,235959))
 DECLARE wherestr = vc WITH public, noconstant("1 = 1")
 DECLARE dselecttimer = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE bstat = i2 WITH protect, noconstant(0)
 DECLARE replyidx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE nexpandsize = i4 WITH protect, noconstant(50)
 DECLARE nexpandtotal = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->patient,patients)
 FOR (cnt1 = 1 TO patients)
  SET stat = alterlist(reply->patient[cnt1].io,5)
  SET reply->patient[cnt1].io_cnt = 5
 ENDFOR
 SET day->days[1].weekday = weekday(end_dt_tm)
 SET day->days[1].daycnt = 1
 SET day->days[2].weekday = weekday(datetimeadd(cnvtdatetime(curdate,0),- (1)))
 SET day->days[2].daycnt = 2
 SET day->days[3].weekday = weekday(datetimeadd(cnvtdatetime(curdate,0),- (2)))
 SET day->days[3].daycnt = 3
 SET day->days[4].weekday = weekday(datetimeadd(cnvtdatetime(curdate,0),- (3)))
 SET day->days[4].daycnt = 4
 SET day->days[5].weekday = weekday(beg_dt_tm)
 SET day->days[5].daycnt = 5
 IF ( NOT (validate(io2g_exists,0)))
  RECORD io2g_exists(
    1 table_exists = i2
    1 data_exists = i2
    1 data_conversion = i2
    1 force_old = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE usingio2g(null) = i2 WITH public
 SUBROUTINE usingio2g(null)
   EXECUTE dcp_does_io_2g_exist  WITH replace("REPLY","IO2G_EXISTS")
   DECLARE io_flag = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    c.config_name
    FROM config_prefs c
    WHERE c.config_name="IONEWTEST"
    DETAIL
     io_flag = 1
    WITH nocounter, maxrec = 1
   ;end select
   IF (io_flag=1)
    CALL echo("Old IO debug parameter set")
    RETURN(false)
   ELSEIF ( NOT (io2g_exists->data_exists))
    CALL echo("IO2G does not exist")
    RETURN(false)
   ELSE
    CALL echo("IO2G does exist")
    RETURN(true)
   ENDIF
 END ;Subroutine
 IF (usingio2g(null)=false)
  CALL retrieveio_data(null)
 ELSE
  CALL retrieveio2g_data(null)
 ENDIF
 SUBROUTINE retrieveio_data(null)
   SET event_sets->sets[1].event_set_name = "Fluid Balance"
   SET event_sets->sets[2].event_set_name = ""
   SET event_sets->sets[3].event_set_name = ""
   SET event_sets->sets[4].event_set_name = ""
   DECLARE med_integ_ind = i2 WITH protect, noconstant(false)
   DECLARE filter_by_encntr_ind = i2 WITH protect, noconstant(false)
   DECLARE day_start_tm = i4 WITH protect, noconstant(7)
   DECLARE loadio_prefs(null) = null WITH public
   SUBROUTINE loadio_prefs(null)
     IF (bglobaldebugflag=1)
      CALL echo("----------------------")
      CALL echo("Loading preferences...")
     ENDIF
     DECLARE suserval = vc WITH protect, noconstant("")
     DECLARE spositionval = vc WITH protect, noconstant("")
     DECLARE sappval = vc WITH protect, noconstant("")
     DECLARE sprefvalue = vc WITH protect, noconstant("")
     DECLARE val = vc WITH protect, noconstant(" ")
     SET filter_by_encntr_ind = false
     SET med_integ_ind = false
     SET dselecttimer = cnvtdatetime(curdate,curtime3)
     SELECT INTO "nl:"
      nvp.pvc_name, nvp.pvc_value, dp.prsnl_id,
      dp.position_cd, dp.application_number
      FROM name_value_prefs nvp,
       detail_prefs dp
      PLAN (dp
       WHERE dp.application_number=600005
        AND dp.comp_name="I&O"
        AND dp.position_cd IN (reqinfo->position_cd, 0.0)
        AND dp.prsnl_id IN (reqinfo->updt_id, 0.0)
        AND dp.active_ind=1)
       JOIN (nvp
       WHERE nvp.parent_entity_id=dp.detail_prefs_id
        AND trim(nvp.parent_entity_name)=trim("DETAIL_PREFS")
        AND nvp.active_ind=1
        AND nvp.pvc_name IN ("I_EVENT_SET_NAME", "MED_EVENTSET_NAME", "MED_INTEGRATION_IND",
       "FILTER_BY_SELECTED_ENCOUNTER"))
      ORDER BY nvp.pvc_name
      HEAD nvp.pvc_name
       suserval = "", spositionval = "", sappval = ""
      DETAIL
       IF (dp.prsnl_id > 0.0)
        suserval = nvp.pvc_value
       ELSEIF (dp.position_cd > 0.0)
        spositionval = nvp.pvc_value
       ELSE
        sappval = nvp.pvc_value
       ENDIF
      FOOT  nvp.pvc_name
       IF (suserval != "")
        sprefvalue = suserval
        IF (bglobaldebugflag=1)
         CALL echo(build("Preference->",nvp.pvc_name,", was found at the user level (",dp.prsnl_id,
          ") with a value of ->",
          sprefvalue))
        ENDIF
       ELSEIF (spositionval != "")
        sprefvalue = spositionval
        IF (bglobaldebugflag=1)
         CALL echo(build("Preference->",nvp.pvc_name,", was found at the position level (",dp
          .position_cd,") with a value of ->",
          sprefvalue))
        ENDIF
       ELSE
        sprefvalue = sappval
        IF (bglobaldebugflag=1)
         CALL echo(build("Preference->",nvp.pvc_name,", was found at the application level (",dp
          .application_number,") with a value of ->",
          sprefvalue))
        ENDIF
       ENDIF
       IF (sprefvalue != "")
        CASE (nvp.pvc_name)
         OF "I_EVENT_SET_NAME":
          event_sets->sets[1].event_set_name = trim(sprefvalue,3)
         OF "MED_EVENTSET_NAME":
          event_sets->sets[4].event_set_name = trim(sprefvalue,3)
         OF "MED_INTEGRATION_IND":
          val = substring(1,1,trim(sprefvalue,3)),
          IF (((val="1") OR (val="2")) )
           med_integ_ind = true
          ENDIF
         OF "FILTER_BY_SELECTED_ENCOUNTER":
          val = substring(1,1,trim(sprefvalue,3)),
          IF (val="1")
           filter_by_encntr_ind = true
          ENDIF
        ENDCASE
       ENDIF
      WITH nocounter
     ;end select
     IF (bglobaldebugflag=1)
      CALL echo(build("Select Timer:  Preferences->",datetimediff(cnvtdatetime(curdate,curtime3),
         dselecttimer,5)))
      CALL echo(build("med_integ_ind->",med_integ_ind))
      CALL echo(build("filter_by_encntr_ind->",filter_by_encntr_ind))
      CALL echo(build("I_EVENT_SET_NAME->",event_sets->sets[1].event_set_name))
      CALL echo(build("MED_EVENTSET_NAME->",event_sets->sets[4].event_set_name))
      CALL echo(build("day_start_tm->",day_start_tm))
      CALL echo("----------------------")
     ENDIF
   END ;Subroutine
   CALL loadio_prefs(null)
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
      CALL echo(build("Select Timer:  LoadIOEventSetNames->",datetimediff(cnvtdatetime(curdate,
          curtime3),dselecttimer,5)))
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
      CALL echo(build("Select Timer:  LoadIOEventSetCds->",datetimediff(cnvtdatetime(curdate,curtime3
          ),dselecttimer,5)))
     ENDIF
   END ;Subroutine
   SUBROUTINE loadiohierarchyeventcodes(null)
     DECLARE expand_index = i4 WITH protect, noconstant(0)
     DECLARE dselecttimer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
     SELECT INTO "nl:"
      FROM v500_event_set_explode vese,
       v500_event_code vec
      PLAN (vese
       WHERE vese.event_set_cd IN (event_sets->sets[2].event_set_cd, event_sets->sets[3].event_set_cd
       ))
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
        fluid_balance_event_sets->event_set_list_cnt = (fluid_balance_event_sets->event_set_list_cnt
        + 1)
        IF (mod(fluid_balance_event_sets->event_set_list_cnt,50)=1)
         stat = alterlist(fluid_balance_event_sets->event_set_list,(fluid_balance_event_sets->
          event_set_list_cnt+ 49))
        ENDIF
        lvidx = fluid_balance_event_sets->event_set_list_cnt, fluid_balance_event_sets->
        event_set_list[lvidx].event_cd_list_cnt = 0
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
        fluid_balance_event_sets->event_set_list[lvidx].event_cd_list_cnt = event_cd_list_cnt, stat
         = alterlist(fluid_balance_event_sets->event_set_list[lvidx].event_cd_list,event_cd_list_cnt),
        fluid_balance_event_sets->event_set_list[lvidx].event_cd_list[event_cd_list_cnt].event_cd =
        vec.event_cd, fluid_balance_event_sets->event_cd_map_cnt = (fluid_balance_event_sets->
        event_cd_map_cnt+ 1)
        IF (mod(fluid_balance_event_sets->event_cd_map_cnt,100)=1)
         stat = alterlist(fluid_balance_event_sets->event_cd_map,(fluid_balance_event_sets->
          event_cd_map_cnt+ 99))
        ENDIF
        fluid_balance_event_sets->event_cd_map[fluid_balance_event_sets->event_cd_map_cnt].event_cd
         = vec.event_cd, fluid_balance_event_sets->event_cd_map[fluid_balance_event_sets->
        event_cd_map_cnt].event_set_idx = lvidx
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
           AND cnvtupper(vesc.event_set_name)=cnvtupper(fluid_balance_event_sets->event_set_list[
           lvidx].event_set_name))
           fluid_balance_event_sets->event_set_list[lvidx].accumulation_ind = vesc.accumulation_ind,
           fluid_balance_event_sets->event_set_list[lvidx].event_set_cd = vesc.event_set_cd,
           fluid_balance_event_sets->event_set_list[lvidx].event_set_display = trim(vesc
            .event_set_cd_disp,3)
           IF (vesc.accumulation_ind=1
            AND (fluid_balance_event_sets->event_set_list[lvidx].intake_ind=1))
            FOR (leventcdidx = 1 TO fluid_balance_event_sets->event_set_list[lvidx].event_cd_list_cnt
             )
              fluid_balance_event_sets->accum_intake_event_cd_map_cnt = (fluid_balance_event_sets->
              accum_intake_event_cd_map_cnt+ 1)
              IF (mod(fluid_balance_event_sets->accum_intake_event_cd_map_cnt,50)=1)
               stat = alterlist(fluid_balance_event_sets->accum_intake_event_cd_map,(
                fluid_balance_event_sets->accum_intake_event_cd_map_cnt+ 49))
              ENDIF
              fluid_balance_event_sets->accum_intake_event_cd_map[fluid_balance_event_sets->
              accum_intake_event_cd_map_cnt].event_cd = fluid_balance_event_sets->event_set_list[
              lvidx].event_cd_list[leventcdidx].event_cd, fluid_balance_event_sets->
              accum_intake_event_cd_map[fluid_balance_event_sets->accum_intake_event_cd_map_cnt].
              event_set_idx = lvidx
            ENDFOR
           ENDIF
           lvidx = nexpandtotal
          ENDIF
        ENDFOR
       FOOT REPORT
        bstat = alterlist(fluid_balance_event_sets->accum_intake_event_cd_map,
         fluid_balance_event_sets->accum_intake_event_cd_map_cnt)
       WITH nocounter
      ;end select
      IF (bglobaldebugflag=1)
       CALL echo(build("Select Timer:  LoadIOHierarchyEventSets->",datetimediff(cnvtdatetime(curdate,
           curtime3),dselecttimer,5)))
      ENDIF
     ENDIF
   END ;Subroutine
   CALL loadiohierarchy(null)
   SET nexpandtotal = (ceil((cnvtreal(patients)/ nexpandsize)) * nexpandsize)
   SET bstat = alterlist(reply->patient,nexpandtotal)
   FOR (cnt1 = 1 TO nexpandtotal)
    IF (cnt1 > patients)
     SET reply->patient[cnt1].person_id = request->patient[patients].person_id
    ELSE
     SET reply->patient[cnt1].person_id = request->patient[cnt1].person_id
    ENDIF
    IF (filter_by_encntr_ind=true)
     SET reply->patient[cnt1].encounter_preference = "TRUE"
    ENDIF
   ENDFOR
   IF (med_integ_ind=false)
    IF (bglobaldebugflag)
     CALL echo("The medication integration preference is off - there are no IV results.")
    ENDIF
   ELSE
    IF (nexpandtotal > 0)
     SET expand_start = 1
     SET dselecttimer = cnvtdatetime(curdate,curtime3)
     SELECT INTO "nl:"
      weekday = weekday(ce.event_end_dt_tm), o.order_id, ce.event_id,
      cmr.admin_dosage
      FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
       orders o,
       clinical_event ce,
       ce_med_result cmr
      PLAN (d1
       WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
       JOIN (o
       WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),o.person_id,reply->
        patient[expand_index].person_id)
        AND o.orderable_type_flag IN (0, 1, 8, 10, 11)
        AND ((o.orig_ord_as_flag+ 0)=0)
        AND ((o.med_order_type_cd+ 0)=med_order_iv_type_cd)
        AND ((o.template_order_id+ 0)=0)
        AND o.active_ind=1)
       JOIN (ce
       WHERE ce.order_id=o.order_id
        AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
        AND ce.event_end_dt_tm < cnvtdatetime(end_dt_tm)
        AND ce.event_cd=ivparent
        AND ce.result_status_cd != inerror
        AND ce.view_level=1)
       JOIN (cmr
       WHERE cmr.event_id=ce.event_id
        AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND cmr.iv_event_cd IN (bolus, infuse)
        AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
      ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC, o.order_id, ce.event_id
      HEAD REPORT
       wherestr = "ce.order_id not in (", first_ind = true, daycnt = 0
      HEAD weekday
       FOR (i = 1 TO size(day->days,5))
         IF ((weekday=day->days[i].weekday))
          daycnt = day->days[i].daycnt
         ENDIF
       ENDFOR
      HEAD o.order_id
       IF (first_ind)
        first_ind = false, wherestr = concat(wherestr,trim(cnvtstring(o.order_id)))
       ELSE
        wherestr = concat(wherestr,",",trim(cnvtstring(o.order_id)))
       ENDIF
      HEAD ce.event_id
       replyidx = locateval(expand_index,1,patients,ce.person_id,reply->patient[expand_index].
        person_id)
       IF (replyidx > 0
        AND daycnt > 0)
        IF (cmr.admin_dosage >= 0.0
         AND cmr.dosage_unit_cd=ml)
         reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
         cmr.admin_dosage)
        ELSEIF (cmr.infused_volume >= 0.0
         AND cmr.infused_volume_unit_cd=ml)
         reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
         cmr.infused_volume)
        ENDIF
        reply->patient[replyidx].io[daycnt].io_dt_tm = ce.event_end_dt_tm, reply->patient[replyidx].
        io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake - reply->patient[replyidx].
        io[daycnt].output), reply->patient[replyidx].io[daycnt].io_dt_disp = format(ce
         .event_end_dt_tm,"@SHORTDATE;;Q")
       ENDIF
      FOOT REPORT
       wherestr = concat(wherestr,")")
      WITH nocounter
     ;end select
     IF (bglobaldebugflag=1)
      IF (curqual <= 0)
       CALL echo("There were no IV results.")
      ENDIF
      CALL echo(build("Select Timer:  Detail Load for IV results->",datetimediff(cnvtdatetime(curdate,
          curtime3),dselecttimer,5)))
      CALL echo("-----------------")
     ENDIF
    ENDIF
   ENDIF
   IF (nexpandtotal > 0)
    SET expand_start = 1
    DECLARE eventsetidx = i4
    DECLARE eventcdidx = i4
    SET dselecttimer = cnvtdatetime(curdate,curtime3)
    SELECT INTO "nl:"
     weekday = weekday(ce.event_end_dt_tm)
     FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      clinical_event ce,
      v500_event_set_explode vese
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (ce
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),ce.person_id,reply->
       patient[expand_index].person_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
       AND ce.event_end_dt_tm < cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd=num
       AND ce.result_status_cd != inerror
       AND ce.view_level=1
       AND parser(wherestr))
      JOIN (vese
      WHERE vese.event_cd=ce.event_cd
       AND vese.event_set_cd IN (event_sets->sets[2].event_set_cd, event_sets->sets[3].event_set_cd))
     ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC, vese.event_set_cd, ce.event_cd,
      ce.event_id
     HEAD REPORT
      daycnt = 0
     HEAD weekday
      FOR (i = 1 TO size(day->days,5))
        IF ((weekday=day->days[i].weekday))
         daycnt = day->days[i].daycnt
        ENDIF
      ENDFOR
     HEAD ce.event_cd
      eventcdidx = locateval(expand_index,1,fluid_balance_event_sets->event_cd_map_cnt,ce.event_cd,
       fluid_balance_event_sets->event_cd_map[expand_index].event_cd), eventsetidx = 0
      IF (eventcdidx > 0)
       eventsetidx = fluid_balance_event_sets->event_cd_map[eventcdidx].event_set_idx
      ENDIF
     HEAD ce.event_id
      replyidx = locateval(expand_index,1,patients,ce.person_id,reply->patient[expand_index].
       person_id)
      IF (eventsetidx > 0
       AND daycnt > 0
       AND replyidx > 0)
       IF ((fluid_balance_event_sets->event_set_list[eventsetidx].accumulation_ind=1))
        IF (isnumeric(ce.result_val) > 0)
         IF ((fluid_balance_event_sets->event_set_list[eventsetidx].intake_ind=true))
          reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
          cnvtreal(ce.result_val)), reply->patient[replyidx].io[daycnt].io_dt_tm = ce.event_end_dt_tm,
          reply->patient[replyidx].io[daycnt].io_dt_disp = format(ce.event_end_dt_tm,"@SHORTDATE;;Q")
         ELSEIF ((fluid_balance_event_sets->event_set_list[eventsetidx].output_ind=true))
          reply->patient[replyidx].io[daycnt].output = (reply->patient[replyidx].io[daycnt].output+
          cnvtreal(ce.result_val)), reply->patient[replyidx].io[daycnt].io_dt_tm = ce.event_end_dt_tm,
          reply->patient[replyidx].io[daycnt].io_dt_disp = format(ce.event_end_dt_tm,"@SHORTDATE;;Q")
         ENDIF
        ENDIF
        reply->patient[replyidx].io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake -
        reply->patient[replyidx].io[daycnt].output)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     IF (curqual <= 0)
      CALL echo("There were no numeric results.")
     ENDIF
     CALL echo(build("Select Timer:  Detail Load for numeric results->",datetimediff(cnvtdatetime(
         curdate,curtime3),dselecttimer,5)))
     CALL echo("-----------------")
    ENDIF
   ENDIF
   IF ((event_sets->sets[4].event_set_cd > 0)
    AND nexpandtotal > 0)
    SET expand_start = 1
    SET dselecttimer = cnvtdatetime(curdate,curtime3)
    SELECT INTO "nl:"
     weekday = weekday(ce.event_end_dt_tm), ce.event_id, cmr.admin_dosage
     FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      clinical_event ce,
      v500_event_set_explode vese,
      ce_med_result cmr
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (ce
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),ce.person_id,reply->
       patient[expand_index].person_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ce.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
       AND ce.event_end_dt_tm < cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd=med
       AND ce.result_status_cd != inerror
       AND ce.view_level=1
       AND parser(wherestr))
      JOIN (vese
      WHERE vese.event_cd=ce.event_cd
       AND (vese.event_set_cd=event_sets->sets[2].event_set_cd))
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND cmr.iv_event_cd IN (0.0, null)
       AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
     ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC, ce.event_cd, ce.event_id
     HEAD REPORT
      daycnt = 0
     HEAD weekday
      FOR (i = 1 TO size(day->days,5))
        IF ((weekday=day->days[i].weekday))
         daycnt = day->days[i].daycnt
        ENDIF
      ENDFOR
     HEAD ce.event_cd
      eventcdidx = locateval(expand_index,1,fluid_balance_event_sets->event_cd_map_cnt,ce.event_cd,
       fluid_balance_event_sets->event_cd_map[expand_index].event_cd), eventsetidx = 0
      IF (eventcdidx > 0)
       eventsetidx = fluid_balance_event_sets->event_cd_map[eventcdidx].event_set_idx
      ENDIF
     HEAD ce.event_id
      replyidx = locateval(expand_index,1,patients,ce.person_id,reply->patient[expand_index].
       person_id)
      IF (eventsetidx > 0
       AND daycnt > 0
       AND replyidx > 0)
       IF ((fluid_balance_event_sets->event_set_list[eventsetidx].accumulation_ind=1))
        IF (cmr.admin_dosage >= 0.0
         AND cmr.dosage_unit_cd=ml)
         reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
         cmr.admin_dosage), reply->patient[replyidx].io[daycnt].io_dt_tm = ce.event_end_dt_tm, reply
         ->patient[replyidx].io[daycnt].io_dt_disp = format(ce.event_end_dt_tm,"@SHORTDATE;;Q")
        ELSEIF (cmr.infused_volume >= 0.0
         AND cmr.infused_volume_unit_cd=ml)
         reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
         cmr.infused_volume), reply->patient[replyidx].io[daycnt].io_dt_tm = ce.event_end_dt_tm,
         reply->patient[replyidx].io[daycnt].io_dt_disp = format(ce.event_end_dt_tm,"@SHORTDATE;;Q")
        ENDIF
        reply->patient[replyidx].io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake -
        reply->patient[replyidx].io[daycnt].output)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     IF (curqual <= 0)
      CALL echo("There were no med results.")
     ENDIF
     CALL echo(build("Select Timer:  Detail Load for Med results->",datetimediff(cnvtdatetime(curdate,
         curtime3),dselecttimer,5)))
     CALL echo("-----------------")
    ENDIF
   ENDIF
   SET bstat = alterlist(reply->patient,patients)
 END ;Subroutine
 SUBROUTINE retrieveio2g_data(null)
   IF ( NOT (validate(io2g_pref_req,0)))
    RECORD io2g_pref_req(
      1 context = vc
      1 context_id = vc
      1 section = vc
      1 section_id = vc
      1 cnt = i4
      1 groups[*]
        2 name = vc
      1 debug = vc
    )
   ENDIF
   IF ( NOT (validate(io2g_pref_rep,0)))
    RECORD io2g_pref_rep(
      1 cnt = i4
      1 entries[*]
        2 name = vc
        2 cnt = i4
        2 values[*]
          3 value = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   DECLARE filter_by_encntr_ind = i2 WITH protect, noconstant(false)
   DECLARE day_start_tm = i4 WITH protect, noconstant(7)
   DECLARE loadio2g_prefs(null) = null WITH public
   SUBROUTINE loadio2g_prefs(null)
     DECLARE cnt1 = i2 WITH protect, noconstant(0)
     DECLARE pval = i4 WITH protect, noconstant(0)
     SET io2g_pref_req->context = "default"
     SET io2g_pref_req->context_id = "system"
     SET io2g_pref_req->section = "config"
     SET io2g_pref_req->section_id = "intake and output"
     SET modify = nopredeclare
     EXECUTE fn_get_prefs  WITH replace("REQUEST","IO2G_PREF_REQ"), replace("REPLY","IO2G_PREF_REP")
     SET modify = predeclare
     FOR (cnt1 = 1 TO size(io2g_pref_rep->entries,5))
       IF (cnvtupper(trim(io2g_pref_rep->entries[cnt1].name,3))="ENCNTR_FILTER")
        IF (size(io2g_pref_rep->entries[cnt1].values,5)=1)
         SET pval = cnvtint(io2g_pref_rep->entries[cnt1].values[1].value)
         IF (pval=1)
          SET filter_by_encntr_ind = true
         ENDIF
        ENDIF
       ELSEIF (cnvtupper(trim(io2g_pref_rep->entries[cnt1].name,3))="DAY_START_TIME")
        IF (size(io2g_pref_rep->entries[cnt1].values,5)=1)
         SET pval = cnvtint(io2g_pref_rep->entries[cnt1].values[1].value)
         IF (pval >= 0
          AND pval < 24)
          SET day_start_tm = pval
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (bglobaldebugflag=1)
      CALL echo(build("filter_by_encntr_ind=",filter_by_encntr_ind))
      CALL echo(build("day_start_tm=",day_start_tm))
     ENDIF
   END ;Subroutine
   CALL loadio2g_prefs(null)
   SET nexpandtotal = (ceil((cnvtreal(patients)/ nexpandsize)) * nexpandsize)
   SET bstat = alterlist(reply->patient,nexpandtotal)
   FOR (cnt1 = 1 TO nexpandtotal)
    IF (cnt1 > patients)
     SET reply->patient[cnt1].person_id = request->patient[patients].person_id
    ELSE
     SET reply->patient[cnt1].person_id = request->patient[cnt1].person_id
    ENDIF
    IF (filter_by_encntr_ind=true)
     SET reply->patient[cnt1].encounter_preference = "TRUE"
    ENDIF
   ENDFOR
   IF (nexpandtotal > 0)
    SET expand_start = 1
    SET dselecttimer = cnvtdatetime(curdate,curtime3)
    SELECT INTO "nl:"
     weekday = weekday(cir.io_end_dt_tm), o.order_id, ce.event_id
     FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      ce_intake_output_result cir,
      clinical_event ce,
      ce_med_result cmr,
      orders o
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (cir
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),cir.person_id,reply->
       patient[expand_index].person_id)
       AND cir.io_end_dt_tm >= cnvtdatetime(beg_dt_tm)
       AND cir.io_end_dt_tm < cnvtdatetime(end_dt_tm)
       AND cir.reference_event_id > 0.0
       AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND cir.io_type_flag=intake
       AND cir.io_volume > 0.0)
      JOIN (ce
      WHERE ce.event_id=cir.reference_event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ((ce.person_id+ 0)=cir.person_id)
       AND ce.event_cd=ivparent
       AND ce.result_status_cd != inerror
       AND ce.view_level=1)
      JOIN (cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND cmr.iv_event_cd IN (bolus, infuse)
       AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
      JOIN (o
      WHERE o.order_id=ce.order_id
       AND o.orderable_type_flag IN (0, 1, 8, 10, 11)
       AND ((o.orig_ord_as_flag+ 0)=0)
       AND ((o.med_order_type_cd+ 0)=med_order_iv_type_cd)
       AND ((o.template_order_id+ 0)=0)
       AND o.active_ind=1)
     ORDER BY cnvtdatetime(cir.io_end_dt_tm) DESC, o.order_id, ce.event_id
     HEAD REPORT
      daycnt = 0
     HEAD weekday
      FOR (i = 1 TO size(day->days,5))
        IF ((weekday=day->days[i].weekday))
         daycnt = day->days[i].daycnt
        ENDIF
      ENDFOR
     HEAD cir.event_id
      replyidx = locateval(expand_index,1,patients,cir.person_id,reply->patient[expand_index].
       person_id)
      IF (replyidx > 0)
       IF (cir.io_status_cd=confirmed)
        reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+ cir
        .io_volume), reply->patient[replyidx].io[daycnt].io_dt_tm = cir.io_start_dt_tm, reply->
        patient[replyidx].io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake - reply->
        patient[replyidx].io[daycnt].output),
        reply->patient[replyidx].io[daycnt].io_dt_disp = format(cir.io_end_dt_tm,"@SHORTDATE;;Q")
       ELSE
        reply->patient[replyidx].io[daycnt].contain_unconfirmed_io_ind = true
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     IF (curqual <= 0)
      CALL echo("There were no IV results.")
     ENDIF
     CALL echo(build("Select Timer:  Detail Load for IV results->",datetimediff(cnvtdatetime(curdate,
         curtime3),dselecttimer,5)))
     CALL echo("-----------------")
    ENDIF
   ENDIF
   IF (nexpandtotal > 0)
    SET expand_start = 1
    SET dselecttimer = cnvtdatetime(curdate,curtime3)
    SELECT INTO "nl:"
     weekday = weekday(cir.io_start_dt_tm)
     FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      ce_intake_output_result cir,
      clinical_event ce
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (cir
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),cir.person_id,reply->
       patient[expand_index].person_id)
       AND cir.io_start_dt_tm >= cnvtdatetime(beg_dt_tm)
       AND cir.io_start_dt_tm < cnvtdatetime(end_dt_tm)
       AND cir.reference_event_id > 0.0
       AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND cir.io_type_flag IN (intake, output))
      JOIN (ce
      WHERE ce.event_id=cir.reference_event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ((ce.person_id+ 0)=cir.person_id)
       AND ce.event_class_cd=num
       AND ce.result_status_cd != inerror
       AND ce.view_level=1)
     ORDER BY cnvtdatetime(cir.io_start_dt_tm) DESC, ce.event_id
     HEAD REPORT
      daycnt = 0
     HEAD weekday
      FOR (i = 1 TO size(day->days,5))
        IF ((weekday=day->days[i].weekday))
         daycnt = day->days[i].daycnt
        ENDIF
      ENDFOR
     HEAD cir.event_id
      replyidx = locateval(expand_index,1,patients,cir.person_id,reply->patient[expand_index].
       person_id)
      IF (replyidx > 0)
       IF (cir.io_type_flag=intake)
        IF (cir.io_status_cd=confirmed)
         reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+
         cir.io_volume), reply->patient[replyidx].io[daycnt].io_dt_tm = cir.io_start_dt_tm, reply->
         patient[replyidx].io[daycnt].io_dt_disp = format(cir.io_start_dt_tm,"@SHORTDATE;;Q")
        ELSE
         reply->patient[replyidx].io[daycnt].contain_unconfirmed_io_ind = true
        ENDIF
       ENDIF
       IF (cir.io_type_flag=output)
        IF (cir.io_status_cd=confirmed)
         reply->patient[replyidx].io[daycnt].output = (reply->patient[replyidx].io[daycnt].output+
         cir.io_volume), reply->patient[replyidx].io[daycnt].io_dt_tm = cir.io_start_dt_tm, reply->
         patient[replyidx].io[daycnt].io_dt_disp = format(cir.io_start_dt_tm,"@SHORTDATE;;Q")
        ELSE
         reply->patient[replyidx].io[daycnt].contain_unconfirmed_io_ind = true
        ENDIF
       ENDIF
       reply->patient[replyidx].io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake -
       reply->patient[replyidx].io[daycnt].output)
      ENDIF
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     IF (curqual <= 0)
      CALL echo("There were no numeric results.")
     ENDIF
     CALL echo(build("Select Timer:  Detail Load for numeric results->",datetimediff(cnvtdatetime(
         curdate,curtime3),dselecttimer,5)))
     CALL echo("-----------------")
    ENDIF
   ENDIF
   IF (nexpandtotal > 0)
    SET expand_start = 1
    SET dselecttimer = cnvtdatetime(curdate,curtime3)
    SELECT INTO "nl:"
     weekday = weekday(cir.io_start_dt_tm)
     FROM (dummyt d1  WITH seq = value((1+ ((nexpandtotal - 1)/ nexpandsize)))),
      ce_intake_output_result cir,
      clinical_event ce
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ nexpandsize))))
      JOIN (cir
      WHERE expand(expand_index,expand_start,(expand_start+ (nexpandsize - 1)),cir.person_id,reply->
       patient[expand_index].person_id)
       AND cir.io_start_dt_tm >= cnvtdatetime(beg_dt_tm)
       AND cir.io_start_dt_tm < cnvtdatetime(end_dt_tm)
       AND cir.reference_event_id > 0.0
       AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND cir.io_type_flag=intake)
      JOIN (ce
      WHERE ce.event_id=cir.reference_event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ((ce.person_id+ 0)=cir.person_id)
       AND ce.event_cd=dcpgeneric
       AND ce.result_status_cd != inerror
       AND ce.view_level=0)
     ORDER BY cnvtdatetime(cir.io_start_dt_tm) DESC, ce.event_id
     HEAD REPORT
      daycnt = 0
     HEAD weekday
      FOR (i = 1 TO size(day->days,5))
        IF ((weekday=day->days[i].weekday))
         daycnt = day->days[i].daycnt
        ENDIF
      ENDFOR
     HEAD cir.event_id
      replyidx = locateval(expand_index,1,patients,cir.person_id,reply->patient[expand_index].
       person_id)
      IF (replyidx > 0)
       IF (cir.io_status_cd=confirmed)
        reply->patient[replyidx].io[daycnt].intake = (reply->patient[replyidx].io[daycnt].intake+ cir
        .io_volume), reply->patient[replyidx].io[daycnt].io_dt_tm = cir.io_start_dt_tm, reply->
        patient[replyidx].io[daycnt].io_dt_disp = format(cir.io_start_dt_tm,"@SHORTDATE;;Q")
       ELSE
        reply->patient[replyidx].io[daycnt].contain_unconfirmed_io_ind = true
       ENDIF
       reply->patient[replyidx].io[daycnt].balance = (reply->patient[replyidx].io[daycnt].intake -
       reply->patient[replyidx].io[daycnt].output)
      ENDIF
     WITH nocounter
    ;end select
    IF (bglobaldebugflag=1)
     IF (curqual <= 0)
      CALL echo("There were no med results.")
     ENDIF
     CALL echo(build("Select Timer:  Detail Load for med results->",datetimediff(cnvtdatetime(curdate,
         curtime3),dselecttimer,5)))
     CALL echo("-----------------")
    ENDIF
   ENDIF
   SET bstat = alterlist(reply->patient,patients)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_program
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
