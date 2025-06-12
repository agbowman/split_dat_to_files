CREATE PROGRAM dcp_upd_omf_outcomes:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD outcomes(
   1 qual[*]
     2 outcome_activity_id = f8
     2 outcome_catalog_id = f8
     2 description = vc
     2 expectation = vc
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 outcome_type_cd = f8
     2 outcome_class_cd = f8
     2 outcome_status_cd = f8
     2 outcome_status_dt_tm = dq8
     2 outcome_status_dt_nbr = i4
     2 outcome_status_min_nbr = i4
     2 outcome_status_prsnl_id = f8
     2 planned_dt_tm = dq8
     2 planned_dt_nbr = i4
     2 planned_min_nbr = i4
     2 planned_prsnl_id = f8
     2 activated_ind = i2
     2 activated_dt_tm = dq8
     2 activated_dt_nbr = i4
     2 activated_min_nbr = i4
     2 activated_prsnl_id = f8
     2 stopped_ind = i2
     2 stopped_dt_tm = dq8
     2 stopped_dt_nbr = i4
     2 stopped_min_nbr = i4
     2 stopped_prsnl_id = f8
     2 start_dt_tm = dq8
     2 start_dt_nbr = i4
     2 start_min_nbr = i4
     2 end_dt_tm = dq8
     2 end_dt_nbr = i4
     2 end_min_nbr = i4
     2 result_search_end_dt_tm = dq8
     2 target_type_cd = f8
     2 target_duration_qty = i4
     2 target_duration_unit_cd = f8
     2 target_duration_min_nbr = i4
     2 actual_duration_min_nbr = i4
 )
 DECLARE zero_dt_tm = q8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE zero_dt_nbr = i4 WITH constant(cnvtdate(zero_dt_tm)), protect
 DECLARE zero_min_nbr = i4 WITH constant(cnvtmin(zero_dt_tm,5)), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE prev_status_cd = f8 WITH noconstant(0.0), protect
 DECLARE status_changed = c1 WITH noconstant("N"), protect
 DECLARE days = i4 WITH noconstant(0), protect
 DECLARE mins = i4 WITH noconstant(0), protect
 DECLARE mins2 = i4 WITH noconstant(0), protect
 DECLARE failed = c1 WITH noconstant("F"), protect
 DECLARE days_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"DAYS")), protect
 DECLARE hours_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE minutes_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"MINUTES")), protect
 DECLARE planned_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"PLANNED")), protect
 DECLARE activated_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"ACTIVATED")), protect
 DECLARE dcd_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"DISCONTINUED")), protect
 DECLARE void_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"VOID")), protect
 DECLARE outcome_cnt = i4 WITH constant(value(size(request->outcomes,5))), protect
 DECLARE load_outcome_data(idx=i4) = null
 DECLARE write_outcome_data(high=i4) = null
 DECLARE insert_outcome(idx=i4) = null
 DECLARE update_outcome(idx=i4) = null
 IF ((((days_cd=- (1))) OR ((((hours_cd=- (1))) OR ((((minutes_cd=- (1))) OR ((((planned_cd=- (1)))
  OR ((((activated_cd=- (1))) OR ((((dcd_cd=- (1))) OR ((void_cd=- (1)))) )) )) )) )) )) )
  CALL echo("Unable to load code values!  Exit.")
  SET failed = "T"
  GO TO end_program
 ENDIF
 IF (outcome_cnt > 0)
  CALL load_outcome_data(outcome_cnt)
 ENDIF
 IF (value(size(outcomes->qual,5)) > 0)
  CALL write_outcome_data(value(size(outcomes->qual,5)))
 ENDIF
 SUBROUTINE load_outcome_data(idx)
   SELECT INTO "nl:"
    FROM outcome_activity oa,
     outcome_action ot
    PLAN (oa
     WHERE expand(num,1,outcome_cnt,oa.outcome_activity_id,request->outcomes[num].outcomeactid))
     JOIN (ot
     WHERE ot.outcome_activity_id=oa.outcome_activity_id)
    ORDER BY oa.outcome_activity_id, ot.action_seq
    HEAD REPORT
     cnt = 0
    HEAD oa.outcome_activity_id
     cnt = (cnt+ 1)
     IF (cnt > value(size(outcomes->qual,5)))
      stat = alterlist(outcomes->qual,(cnt+ 10))
     ENDIF
     outcomes->qual[cnt].outcome_activity_id = oa.outcome_activity_id, outcomes->qual[cnt].
     outcome_catalog_id = oa.outcome_catalog_id, outcomes->qual[cnt].description = trim(oa
      .description),
     outcomes->qual[cnt].expectation = trim(oa.expectation), outcomes->qual[cnt].person_id = oa
     .person_id, outcomes->qual[cnt].encntr_id = oa.encntr_id,
     outcomes->qual[cnt].event_cd = oa.event_cd, outcomes->qual[cnt].outcome_type_cd = oa
     .outcome_type_cd, outcomes->qual[cnt].outcome_class_cd = oa.outcome_class_cd,
     outcomes->qual[cnt].outcome_status_cd = oa.outcome_status_cd, outcomes->qual[cnt].
     outcome_status_dt_tm = cnvtdatetime(oa.outcome_status_dt_tm), outcomes->qual[cnt].
     outcome_status_dt_nbr = cnvtdate(cnvtdatetimeutc(oa.outcome_status_dt_tm,2)),
     outcomes->qual[cnt].outcome_status_min_nbr = (cnvtmin(cnvtdatetimeutc(oa.outcome_status_dt_tm,2),
      5)+ 1), outcomes->qual[cnt].start_dt_tm = cnvtdatetime(oa.start_dt_tm), outcomes->qual[cnt].
     start_dt_nbr = cnvtdate(cnvtdatetimeutc(oa.start_dt_tm,2)),
     outcomes->qual[cnt].start_min_nbr = (cnvtmin(cnvtdatetimeutc(oa.start_dt_tm,2),5)+ 1), outcomes
     ->qual[cnt].end_dt_tm = cnvtdatetime(oa.end_dt_tm), outcomes->qual[cnt].end_dt_nbr = cnvtdate(
      cnvtdatetimeutc(oa.end_dt_tm,2)),
     outcomes->qual[cnt].end_min_nbr = (cnvtmin(cnvtdatetimeutc(oa.end_dt_tm,2),5)+ 1), outcomes->
     qual[cnt].target_type_cd = oa.target_type_cd, outcomes->qual[cnt].target_duration_qty = oa
     .target_duration_qty,
     outcomes->qual[cnt].target_duration_unit_cd = oa.target_duration_unit_cd
     IF ((outcomes->qual[cnt].outcome_status_cd != planned_cd))
      outcomes->qual[cnt].actual_duration_min_nbr = datetimediff(oa.end_dt_tm,oa.start_dt_tm,4)
     ELSE
      outcomes->qual[cnt].actual_duration_min_nbr = 0
     ENDIF
     IF ((outcomes->qual[cnt].outcome_status_cd != planned_cd))
      IF (oa.expand_qty > 0
       AND oa.expand_unit_cd > 0)
       IF (oa.expand_unit_cd=days_cd)
        outcomes->qual[cnt].result_search_end_dt_tm = datetimeadd(oa.end_dt_tm,oa.expand_qty)
       ELSE
        days = 0, mins = 0, mins2 = 0
        IF (oa.expand_unit_cd=hours_cd)
         mins = (cnvtmin(oa.end_dt_tm,5)+ (oa.expand_qty * 60))
        ELSEIF (oa.expand_unit_cd=minutes_cd)
         mins = (cnvtmin(oa.end_dt_tm,5)+ oa.expand_qty)
        ENDIF
        days = cnvtint((mins/ 1440)), mins2 = mod(mins,1440), outcomes->qual[cnt].
        result_search_end_dt_tm = cnvtdatetime((cnvtdate(oa.end_dt_tm)+ days),cnvttime(mins2))
       ENDIF
      ELSE
       outcomes->qual[cnt].result_search_end_dt_tm = cnvtdatetime(oa.end_dt_tm)
      ENDIF
     ENDIF
     prev_status_cd = 0
    DETAIL
     IF (ot.outcome_status_cd != prev_status_cd)
      status_changed = "Y"
     ENDIF
     IF (status_changed="Y"
      AND (outcomes->qual[cnt].outcome_status_cd=ot.outcome_status_cd))
      outcomes->qual[cnt].outcome_status_prsnl_id = ot.updt_id
     ENDIF
     IF (status_changed="Y"
      AND ot.outcome_status_cd=activated_cd)
      IF (ot.action_seq=1)
       outcomes->qual[cnt].planned_dt_tm = cnvtdatetime(ot.outcome_status_dt_tm), outcomes->qual[cnt]
       .planned_dt_nbr = cnvtdate(cnvtdatetimeutc(ot.outcome_status_dt_tm,2)), outcomes->qual[cnt].
       planned_min_nbr = (cnvtmin(cnvtdatetimeutc(ot.outcome_status_dt_tm,2),5)+ 1),
       outcomes->qual[cnt].planned_prsnl_id = ot.updt_id
      ENDIF
      outcomes->qual[cnt].activated_ind = 1, outcomes->qual[cnt].activated_dt_tm = cnvtdatetime(ot
       .outcome_status_dt_tm), outcomes->qual[cnt].activated_dt_nbr = cnvtdate(cnvtdatetimeutc(ot
        .outcome_status_dt_tm,2)),
      outcomes->qual[cnt].activated_min_nbr = (cnvtmin(cnvtdatetimeutc(ot.outcome_status_dt_tm,2),5)
      + 1), outcomes->qual[cnt].activated_prsnl_id = ot.updt_id
     ELSEIF (status_changed="Y"
      AND ot.outcome_status_cd=planned_cd)
      outcomes->qual[cnt].planned_dt_tm = cnvtdatetime(ot.outcome_status_dt_tm), outcomes->qual[cnt].
      planned_dt_nbr = cnvtdate(cnvtdatetimeutc(ot.outcome_status_dt_tm,2)), outcomes->qual[cnt].
      planned_min_nbr = (cnvtmin(cnvtdatetimeutc(ot.outcome_status_dt_tm,2),5)+ 1),
      outcomes->qual[cnt].planned_prsnl_id = ot.updt_id
     ELSEIF (status_changed="Y"
      AND ((ot.outcome_status_cd=void_cd) OR (ot.outcome_status_cd=dcd_cd)) )
      outcomes->qual[cnt].stopped_ind = 1, outcomes->qual[cnt].stopped_dt_tm = cnvtdatetime(ot
       .outcome_status_dt_tm), outcomes->qual[cnt].stopped_dt_nbr = cnvtdate(cnvtdatetimeutc(ot
        .outcome_status_dt_tm,2)),
      outcomes->qual[cnt].stopped_min_nbr = (cnvtmin(cnvtdatetimeutc(ot.outcome_status_dt_tm,2),5)+ 1
      ), outcomes->qual[cnt].stopped_prsnl_id = ot.updt_id
     ENDIF
     prev_status_cd = ot.outcome_status_cd, status_changed = "N"
    FOOT  oa.outcome_activity_id
     cnt = cnt
    FOOT REPORT
     stat = alterlist(outcomes->qual,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE write_outcome_data(high)
   FOR (i = 1 TO high)
    SELECT INTO "nl:"
     FROM cn_outcome_st cou
     WHERE (cou.outcome_activity_id=outcomes->qual[i].outcome_activity_id)
     WITH nocounter, forupdate(cou)
    ;end select
    IF (curqual=0)
     CALL insert_outcome(i)
    ELSE
     CALL update_outcome(i)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE insert_outcome(idx)
   INSERT  FROM cn_outcome_st cou
    SET cou.outcome_activity_id = outcomes->qual[idx].outcome_activity_id, cou.outcome_catalog_id =
     outcomes->qual[idx].outcome_catalog_id, cou.outcome_ind = 1,
     cou.description = concat(trim(outcomes->qual[idx].description)," - ",trim(outcomes->qual[idx].
       expectation)), cou.person_id = outcomes->qual[idx].person_id, cou.encntr_id = outcomes->qual[
     idx].encntr_id,
     cou.event_cd = outcomes->qual[idx].event_cd, cou.outcome_type_cd = outcomes->qual[idx].
     outcome_type_cd, cou.outcome_class_cd = outcomes->qual[idx].outcome_class_cd,
     cou.outcome_status_cd = outcomes->qual[idx].outcome_status_cd, cou.outcome_status_dt_tm =
     cnvtdatetime(outcomes->qual[idx].outcome_status_dt_tm), cou.outcome_status_dt_nbr = outcomes->
     qual[idx].outcome_status_dt_nbr,
     cou.outcome_status_min_nbr = outcomes->qual[idx].outcome_status_min_nbr, cou
     .outcome_status_prsnl_id = outcomes->qual[idx].outcome_status_prsnl_id, cou.planned_ind = 1,
     cou.planned_dt_tm = cnvtdatetime(outcomes->qual[idx].planned_dt_tm), cou.planned_dt_nbr =
     outcomes->qual[idx].planned_dt_nbr, cou.planned_min_nbr = outcomes->qual[idx].planned_min_nbr,
     cou.planned_prsnl_id = outcomes->qual[idx].planned_prsnl_id, cou.activated_ind = outcomes->qual[
     idx].activated_ind, cou.activated_dt_tm = cnvtdatetime(outcomes->qual[idx].activated_dt_tm),
     cou.activated_dt_nbr = outcomes->qual[idx].activated_dt_nbr, cou.activated_min_nbr = outcomes->
     qual[idx].activated_min_nbr, cou.activated_prsnl_id = outcomes->qual[idx].activated_prsnl_id,
     cou.stopped_ind = outcomes->qual[idx].stopped_ind, cou.stopped_dt_tm = cnvtdatetime(outcomes->
      qual[idx].stopped_dt_tm), cou.stopped_dt_nbr = outcomes->qual[idx].stopped_dt_nbr,
     cou.stopped_min_nbr = outcomes->qual[idx].stopped_min_nbr, cou.stopped_prsnl_id = outcomes->
     qual[idx].stopped_prsnl_id, cou.start_dt_tm = cnvtdatetime(outcomes->qual[idx].start_dt_tm),
     cou.start_dt_nbr = outcomes->qual[idx].start_dt_nbr, cou.start_min_nbr = outcomes->qual[idx].
     start_min_nbr, cou.end_dt_tm = cnvtdatetime(outcomes->qual[idx].end_dt_tm),
     cou.end_dt_nbr = outcomes->qual[idx].end_dt_nbr, cou.end_min_nbr = outcomes->qual[idx].
     end_min_nbr, cou.result_search_end_dt_tm = cnvtdatetime(outcomes->qual[idx].
      result_search_end_dt_tm),
     cou.target_type_cd = outcomes->qual[idx].target_type_cd, cou.target_duration_qty = outcomes->
     qual[idx].target_duration_qty, cou.target_duration_unit_cd = outcomes->qual[idx].
     target_duration_unit_cd,
     cou.target_duration_min_nbr = 0, cou.actual_duration_min_nbr = outcomes->qual[idx].
     actual_duration_min_nbr, cou.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cou.updt_cnt = 0, cou.updt_id = reqinfo->updt_id, cou.updt_task = reqinfo->updt_task,
     cou.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE update_outcome(idx)
   UPDATE  FROM cn_outcome_st cou
    SET cou.description = concat(trim(outcomes->qual[idx].description)," - ",trim(outcomes->qual[idx]
       .expectation)), cou.encntr_id =
     IF ((outcomes->qual[idx].encntr_id != 0)) outcomes->qual[idx].encntr_id
     ELSE cou.encntr_id
     ENDIF
     , cou.outcome_status_cd = outcomes->qual[idx].outcome_status_cd,
     cou.outcome_status_dt_tm = cnvtdatetime(outcomes->qual[idx].outcome_status_dt_tm), cou
     .outcome_status_dt_nbr = outcomes->qual[idx].outcome_status_dt_nbr, cou.outcome_status_min_nbr
      = outcomes->qual[idx].outcome_status_min_nbr,
     cou.outcome_status_prsnl_id = outcomes->qual[idx].outcome_status_prsnl_id, cou.activated_ind =
     outcomes->qual[idx].activated_ind, cou.activated_dt_tm =
     IF ((outcomes->qual[idx].activated_ind=1)) cnvtdatetime(outcomes->qual[idx].activated_dt_tm)
     ELSE cou.activated_dt_tm
     ENDIF
     ,
     cou.activated_dt_nbr =
     IF ((outcomes->qual[idx].activated_ind=1)) outcomes->qual[idx].activated_dt_nbr
     ELSE cou.activated_dt_nbr
     ENDIF
     , cou.activated_min_nbr =
     IF ((outcomes->qual[idx].activated_ind=1)) outcomes->qual[idx].activated_min_nbr
     ELSE cou.activated_min_nbr
     ENDIF
     , cou.activated_prsnl_id =
     IF ((outcomes->qual[idx].activated_ind=1)) outcomes->qual[idx].activated_prsnl_id
     ELSE cou.activated_prsnl_id
     ENDIF
     ,
     cou.stopped_ind = outcomes->qual[idx].stopped_ind, cou.stopped_dt_tm =
     IF ((outcomes->qual[idx].stopped_ind=1)) cnvtdatetime(outcomes->qual[idx].stopped_dt_tm)
     ELSE cou.stopped_dt_tm
     ENDIF
     , cou.stopped_dt_nbr =
     IF ((outcomes->qual[idx].stopped_ind=1)) outcomes->qual[idx].stopped_dt_nbr
     ELSE cou.stopped_dt_nbr
     ENDIF
     ,
     cou.stopped_min_nbr =
     IF ((outcomes->qual[idx].stopped_ind=1)) outcomes->qual[idx].stopped_min_nbr
     ELSE cou.stopped_min_nbr
     ENDIF
     , cou.stopped_prsnl_id =
     IF ((outcomes->qual[idx].stopped_ind=1)) outcomes->qual[idx].stopped_prsnl_id
     ELSE cou.stopped_prsnl_id
     ENDIF
     , cou.start_dt_tm = cnvtdatetime(outcomes->qual[idx].start_dt_tm),
     cou.start_dt_nbr = outcomes->qual[idx].start_dt_nbr, cou.start_min_nbr = outcomes->qual[idx].
     start_min_nbr, cou.end_dt_tm = cnvtdatetime(outcomes->qual[idx].end_dt_tm),
     cou.end_dt_nbr = outcomes->qual[idx].end_dt_nbr, cou.end_min_nbr = outcomes->qual[idx].
     end_min_nbr, cou.result_search_end_dt_tm = cnvtdatetime(outcomes->qual[idx].
      result_search_end_dt_tm),
     cou.target_type_cd = outcomes->qual[idx].target_type_cd, cou.target_duration_qty = outcomes->
     qual[idx].target_duration_qty, cou.target_duration_unit_cd = outcomes->qual[idx].
     target_duration_unit_cd,
     cou.actual_duration_min_nbr = outcomes->qual[idx].actual_duration_min_nbr, cou.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), cou.updt_cnt = 0,
     cou.updt_id = reqinfo->updt_id, cou.updt_task = reqinfo->updt_task, cou.updt_applctx = reqinfo->
     updt_applctx
    WHERE (cou.outcome_activity_id=outcomes->qual[idx].outcome_activity_id)
    WITH nocounter
   ;end update
 END ;Subroutine
#end_program
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD outcomes
END GO
