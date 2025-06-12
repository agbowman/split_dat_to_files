CREATE PROGRAM bed_ens_sch_defsched_temp:dba
 FREE SET reply
 RECORD reply(
   1 bypass_ind = i2
   1 error_list[*]
     2 resource_name = vc
   1 error_msg = vc
   1 frequency_list[*]
     2 frequency_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET overlapsched
 RECORD overlapsched(
   1 qual[*]
     2 resource_cd = f8
     2 resource_name = vc
     2 frequency_id = f8
     2 def_apply_id = f8
 )
 FREE SET bookingerror
 RECORD bookingerror(
   1 qual[*]
     2 resource_name = vc
 )
 FREE SET overlapapplyed
 RECORD overlapapplyed(
   1 applied[*]
     2 apply_list_id = f8
 )
 FREE SET slotinfo
 RECORD slotinfo(
   1 slist[*]
     2 def_slot_id = f8
     2 slot_type_id = f8
     2 slot_description = vc
     2 mnemonic = vc
     2 beg_offset = f8
     2 duration = f8
     2 end_offset = f8
     2 slot_beg_offset = f8
     2 slot_duration = f8
     2 slot_end_offset = f8
     2 sch_flex_id = f8
     2 contiguous_ind = i2
     2 slot_scheme_id = f8
     2 border_style = f8
     2 border_size = f8
     2 border_color = f8
     2 shape = f8
     2 pen_shape = f8
     2 interval = f8
     2 vis_beg_offset = f8
     2 vis_beg_units = i4
     2 vis_beg_units_cd = f8
     2 vis_beg_units_meaning = vc
     2 vis_end_offset = f8
     2 vis_end_units = i4
     2 vis_end_units_cd = f8
     2 vis_end_units_meaning = vc
     2 seq_nbr = i4
 )
 FREE SET idnumbers
 RECORD idnumbers(
   1 idlist[*]
     2 frequency_id = f8
     2 def_apply_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 SET reply->bypass_ind = 0
 SET slotrows = 0
 DECLARE dayofweekstring = c10
 DECLARE weeknumberstring = c6
 SET daystring = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 SET monthstring = "XXXXXXXXXXXX"
 SET active_cd = get_code_value(48,"ACTIVE")
 SET active_state_cd = get_code_value(14490,"ACTIVE")
 SET removed_state_cd = get_code_value(14490,"REMOVED")
 SET modified_state_cd = get_code_value(14490,"MODIFIED")
 SET complete_state_cd = get_code_value(14490,"COMPLETE")
 SET active_freq_state_cd = get_code_value(23003,"ACTIVE")
 SET monthly_cd = get_code_value(23004,"MONTHLY")
 SET weekly_cd = get_code_value(23004,"WEEKLY")
 SET default_type_cd = get_code_value(23007,"DEFSCHED")
 SET default_freq_type_cd = get_code_value(23002,"DEFSCHED")
 SET date_type_cd = get_code_value(23005,"DATE")
 SET none_type_cd = get_code_value(23005,"NONE")
 SET occurance_type_cd = get_code_value(23005,"OCCURANCE")
 SET resourcerows = size(request->rlist,5)
 SET stat = alterlist(idnumbers->idlist,resourcerows)
 SET stat = alterlist(reply->frequency_list,resourcerows)
 SET apply_template = 1
 IF ((request->range_beg=null)
  AND (request->range_end=null))
  SET apply_template = 0
 ENDIF
 CALL echo(apply_template)
 SET blockrows = size(request->blist,5)
 IF (blockrows=0)
  SET error_msg = "No blocks to process"
  GO TO exit_script
 ENDIF
 SET dayofweekrows = size(request->wlist,5)
 IF (dayofweekrows != 7)
  SET error_msg = concat("Incorrect days of the week rows - ",dayofweekrows)
  GO TO exit_script
 ENDIF
 SET weeknumberrows = size(request->mlist,5)
 IF (weeknumberrows != 5
  AND weeknumberrows != 0)
  SET error_msg = concat("Incorrect week number rows - ",weeknumberrows)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM sch_def_sched sds
  WHERE sds.mnemonic_key=cnvtupper(request->mnemonic)
   AND sds.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET error_flag = "N"
  SET error_msg = "The template name already exists."
  GO TO exit_script
 ENDIF
 IF (resourcerows > 0
  AND apply_template=1)
  SET bcount = 0
  SELECT DISTINCT INTO "nl:"
   sr.mnemonic
   FROM (dummyt d  WITH seq = resourcerows),
    sch_resource sr
   PLAN (d)
    JOIN (sr
    WHERE (sr.resource_cd=request->rlist[d.seq].resource_cd)
     AND sr.active_ind=1
     AND sr.quota > 0)
   DETAIL
    bcount = (bcount+ 1), stat = alterlist(bookingerror->qual,bcount), bookingerror->qual[bcount].
    resource_name = sr.mnemonic
   WITH nocounter
  ;end select
  IF (bcount > 0)
   SET stat = alterlist(reply->error_list,bcount)
   SET error_flag = "N"
   SET error_msg = "The resources below have booking limits, so they can not use templates."
   SET reply->bypass_ind = 0
   FOR (i = 1 TO bcount)
     SET reply->error_list[i].resource_name = bookingerror->qual[i].resource_name
   ENDFOR
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO dayofweekrows)
   IF ((request->wlist[i].active_flag=1))
    SET dayofweekstring = build(dayofweekstring,"X")
   ELSE
    SET dayofweekstring = build(dayofweekstring,"Y")
   ENDIF
 ENDFOR
 SET dayofweekstring = replace(dayofweekstring,"Y"," ",0)
 IF (trim(dayofweekstring)=" ")
  SET error_flag = "Y"
  SET error_msg = "No Valid Days of Week Defined"
  SET reply->bypass_ind = 0
  GO TO exit_script
 ENDIF
 IF ((request->repeatweeks > 0))
  SET weeknumberstring = "XXXXXX"
 ELSE
  FOR (i = 1 TO weeknumberrows)
    IF ((request->mlist[i].active_flag=1))
     SET weeknumberstring = build(weeknumberstring,"X")
    ELSE
     SET weeknumberstring = build(weeknumberstring,"Y")
    ENDIF
  ENDFOR
  SET weeknumberstring = replace(weeknumberstring,"Y"," ",0)
  IF (trim(weeknumberstring)=" ")
   SET error_flag = "Y"
   SET error_msg = "No Valid Days of the Month Defined"
   SET reply->bypass_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 IF (resourcerows > 0
  AND apply_template=1)
  IF ((request->repeatweeks > 0))
   SET ocount = 0
   SELECT DISTINCT INTO "nl:"
    sda.resource_cd, sf.frequency_id, sda.def_apply_id,
    sds.def_sched_id
    FROM (dummyt d  WITH seq = resourcerows),
     (dummyt d2  WITH seq = dayofweekrows),
     (dummyt d3  WITH seq = weeknumberrows),
     sch_def_apply sda,
     sch_freq sf,
     sch_def_sched sds
    PLAN (d)
     JOIN (sda
     WHERE (sda.resource_cd=request->rlist[d.seq].resource_cd)
      AND sda.def_state_cd IN (active_state_cd, modified_state_cd))
     JOIN (sf
     WHERE sda.frequency_id=sf.frequency_id
      AND sf.freq_state_cd=active_freq_state_cd
      AND sf.month_string=monthstring
      AND sf.freq_pattern_meaning="MONTHLY")
     JOIN (d2
     WHERE (request->wlist[d2.seq].active_flag=1)
      AND substring(d2.seq,1,sf.days_of_week)="X")
     JOIN (d3
     WHERE (request->mlist[d3.seq].active_flag=1)
      AND substring(d3.seq,1,sf.week_string)="X")
     JOIN (sds
     WHERE sda.def_sched_id=sds.def_sched_id
      AND (((sds.beg_tm < request->day_end)) OR ((sds.end_tm > request->day_begin))) )
    ORDER BY sda.def_apply_id
    HEAD REPORT
     ocount = 0
    DETAIL
     ocount = (ocount+ 1), stat = alterlist(overlapsched->qual,ocount), overlapsched->qual[ocount].
     resource_cd = sda.resource_cd,
     overlapsched->qual[ocount].resource_name = concat(trim(request->rlist[d.seq].resource_name),
      " - ",sds.mnemonic), overlapsched->qual[ocount].frequency_id = sf.frequency_id, overlapsched->
     qual[ocount].def_apply_id = sda.def_apply_id,
     overlapsched->qual[ocount]
    WITH nocounter
   ;end select
  ELSE
   SET ocount = 0
   SELECT DISTINCT INTO "nl:"
    sda.resource_cd, sf.frequency_id, sda.def_apply_id,
    sds.def_sched_id
    FROM (dummyt d  WITH seq = resourcerows),
     (dummyt d2  WITH seq = dayofweekrows),
     (dummyt d3  WITH seq = weeknumberrows),
     sch_def_apply sda,
     sch_freq sf,
     sch_def_sched sds
    PLAN (d)
     JOIN (sda
     WHERE (sda.resource_cd=request->rlist[d.seq].resource_cd)
      AND sda.def_state_cd IN (active_state_cd, modified_state_cd))
     JOIN (sf
     WHERE sda.frequency_id=sf.frequency_id
      AND sf.freq_state_cd=active_freq_state_cd
      AND sf.month_string=monthstring)
     JOIN (d2
     WHERE (request->wlist[d2.seq].active_flag=1)
      AND substring(d2.seq,1,sf.days_of_week)="X")
     JOIN (d3
     WHERE (request->mlist[d3.seq].active_flag=1)
      AND substring(d3.seq,1,sf.week_string)="X")
     JOIN (sds
     WHERE sda.def_sched_id=sds.def_sched_id
      AND (((sds.beg_tm < request->day_end)) OR ((sds.end_tm > request->day_begin))) )
    ORDER BY sda.def_apply_id
    HEAD REPORT
     ocount = 0
    DETAIL
     ocount = (ocount+ 1), stat = alterlist(overlapsched->qual,ocount), overlapsched->qual[ocount].
     resource_cd = sda.resource_cd,
     overlapsched->qual[ocount].resource_name = concat(trim(request->rlist[d.seq].resource_name),
      " - ",sds.mnemonic), overlapsched->qual[ocount].frequency_id = sf.frequency_id, overlapsched->
     qual[ocount].def_apply_id = sda.def_apply_id
    WITH nocounter
   ;end select
  ENDIF
  IF (ocount > 0)
   IF ((request->action_flag != 5))
    SET stat = alterlist(reply->error_list,ocount)
    SET error_flag = "N"
    SET error_msg = "The templates applied conflict with the templates already applied."
    SET reply->bypass_ind = 1
    FOR (i = 1 TO ocount)
      SET reply->error_list[i].resource_name = overlapsched->qual[i].resource_name
    ENDFOR
    GO TO exit_script
   ENDIF
   SET alcount = 0
   IF (ocount > 0)
    SELECT INTO "NL:"
     FROM sch_apply_list sal,
      (dummyt d  WITH seq = ocount)
     PLAN (d)
      JOIN (sal
      WHERE (sal.def_apply_id=overlapsched->qual[d.seq].def_apply_id))
     HEAD REPORT
      alcount = 0
     DETAIL
      alcount = (alcount+ 1), stat = alterlist(overlapapplyed->applied,alcount), overlapapplyed->
      applied[alcount].apply_list_id = sal.apply_list_id
     WITH nocounter
    ;end select
   ENDIF
   IF (ocount > 0)
    UPDATE  FROM sch_freq sf,
      (dummyt d  WITH seq = ocount)
     SET sf.seq = 1, sf.freq_state_cd = complete_state_cd, sf.freq_state_meaning = "COMPLETE",
      sf.end_dt_tm = cnvtdatetime(curdate,curtime3), sf.end_type_cd = date_type_cd, sf
      .end_type_meaning = "DATE",
      sf.updt_dt_tm = cnvtdatetime(curdate,curtime3), sf.updt_id = reqinfo->updt_id, sf.updt_task =
      reqinfo->updt_task,
      sf.updt_applctx = reqinfo->updt_applctx, sf.updt_cnt = (sf.updt_cnt+ 1)
     PLAN (d)
      JOIN (sf
      WHERE (sf.frequency_id=overlapsched->qual[d.seq].frequency_id))
     WITH nocounter
    ;end update
    UPDATE  FROM sch_def_apply sda,
      (dummyt d  WITH seq = ocount)
     SET sda.seq = 1, sda.def_state_cd = complete_state_cd, sda.def_state_meaning = "COMPLETE",
      sda.updt_dt_tm = cnvtdatetime(curdate,curtime3), sda.end_dt_tm = cnvtdatetime(curdate,curtime3),
      sda.updt_id = reqinfo->updt_id,
      sda.updt_task = reqinfo->updt_task, sda.updt_applctx = reqinfo->updt_applctx, sda.updt_cnt = (
      sda.updt_cnt+ 1)
     PLAN (d)
      JOIN (sda
      WHERE (sda.def_apply_id=overlapsched->qual[d.seq].def_apply_id))
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 IF ((request->max_occurance > 0))
  SET end_cd = occurance_type_cd
  SET end_meaning = "OCCURANCE"
 ELSEIF ((request->range_end > 0))
  SET end_cd = date_type_cd
  SET end_meaning = "DATE"
 ELSE
  SET end_cd = none_type_cd
  SET end_meaning = "NONE"
  SET request->range_end = cnvtdatetime("31-dec-2100 00:00:00")
 ENDIF
 IF ((request->range_beg <= 0))
  SET request->range_beg = cnvtdatetime(curdate,curtime3)
 ENDIF
 FOR (i = 1 TO blockrows)
   SET def_slot_id = 0
   SELECT INTO "NL:"
    nextseqnum = seq(sch_default_seq,nextval)"##################;RP0"
    FROM dual
    DETAIL
     def_slot_id = cnvtreal(nextseqnum)
    WITH nocounter, format
   ;end select
   SET rellooprows = size(request->blist[i].slist,5)
   SET block_seq = 0
   FOR (ii = 1 TO rellooprows)
     IF ((request->blist[i].slist[ii].slot_type_id > 0))
      SET slotrows = (slotrows+ 1)
      SET stat = alterlist(slotinfo->slist,slotrows)
      SET slotinfo->slist[slotrows].def_slot_id = def_slot_id
      SET slotinfo->slist[slotrows].seq_nbr = block_seq
      SET slotinfo->slist[slotrows].vis_beg_offset = - (1)
      SET slotinfo->slist[slotrows].vis_beg_units = - (1)
      SET slotinfo->slist[slotrows].slot_type_id = request->blist[i].slist[ii].slot_type_id
      SET slotinfo->slist[slotrows].beg_offset = (get_minutes(request->blist[i].start_time) -
      get_minutes(request->day_begin))
      SET slotinfo->slist[slotrows].duration = (get_minutes(request->blist[i].end_time) - get_minutes
      (request->blist[i].start_time))
      SET slotinfo->slist[slotrows].end_offset = (get_minutes(request->blist[i].end_time) -
      get_minutes(request->day_begin))
      SET slotinfo->slist[slotrows].slot_beg_offset = (get_minutes(request->blist[i].slist[ii].
       start_time) - get_minutes(request->blist[i].start_time))
      SET slotinfo->slist[slotrows].slot_duration = (get_minutes(request->blist[i].slist[ii].end_time
       ) - get_minutes(request->blist[i].slist[ii].start_time))
      SET slotinfo->slist[slotrows].slot_end_offset = (get_minutes(request->blist[i].slist[ii].
       end_time) - get_minutes(request->blist[i].start_time))
      SET slotinfo->slist[slotrows].interval = request->blist[i].slist[ii].interval
      IF ((request->blist[i].slist[1].release_slot_id > 0))
       CASE (request->blist[i].slist[1].release_time_mean)
        OF "MINUTES":
         SET offset = request->blist[i].slist[1].release_time
        OF "HOURS":
         SET offset = (request->blist[i].slist[1].release_time * 60)
        OF "DAYS":
         SET offset = ((request->blist[i].slist[1].release_time * 60) * 24)
        OF "WEEKS":
         SET offset = (((request->blist[i].slist[1].release_time * 60) * 24) * 7)
       ENDCASE
       SET slotinfo->slist[slotrows].vis_end_offset = offset
       SET slotinfo->slist[slotrows].vis_end_units = request->blist[i].slist[1].release_time
       SET slotinfo->slist[slotrows].vis_end_units_cd = get_code_value(54,request->blist[i].slist[1].
        release_time_mean)
       SET slotinfo->slist[slotrows].vis_end_units_meaning = request->blist[i].slist[1].
       release_time_mean
       IF (ii=rellooprows)
        SET slotrows = (slotrows+ 1)
        SET stat = alterlist(slotinfo->slist,slotrows)
        SET block_seq = (block_seq+ 1)
        SET slotinfo->slist[slotrows].def_slot_id = def_slot_id
        SET slotinfo->slist[slotrows].beg_offset = slotinfo->slist[(slotrows - 1)].beg_offset
        SET slotinfo->slist[slotrows].duration = slotinfo->slist[(slotrows - 1)].duration
        SET slotinfo->slist[slotrows].end_offset = slotinfo->slist[(slotrows - 1)].end_offset
        SET slotinfo->slist[slotrows].slot_beg_offset = 0
        SET slotinfo->slist[slotrows].slot_duration = (get_minutes(request->blist[i].end_time) -
        get_minutes(request->blist[i].start_time))
        SET slotinfo->slist[slotrows].slot_end_offset = (get_minutes(request->blist[i].slist[1].
         end_time) - get_minutes(request->blist[i].slist[1].start_time))
        SET slotinfo->slist[slotrows].slot_type_id = request->blist[i].slist[1].release_slot_id
        SET slotinfo->slist[slotrows].vis_beg_offset = offset
        SET slotinfo->slist[slotrows].vis_beg_units = request->blist[i].slist[1].release_time
        SET slotinfo->slist[slotrows].vis_beg_units_cd = get_code_value(54,request->blist[i].slist[1]
         .release_time_mean)
        SET slotinfo->slist[slotrows].vis_beg_units_meaning = request->blist[i].slist[1].
        release_time_mean
        SET slotinfo->slist[slotrows].vis_end_offset = - (1)
        SET slotinfo->slist[slotrows].vis_end_units = - (1)
        SET slotinfo->slist[slotrows].seq_nbr = block_seq
       ENDIF
      ELSE
       SET slotinfo->slist[slotrows].vis_end_offset = - (1)
       SET slotinfo->slist[slotrows].vis_end_units = - (1)
      ENDIF
      SET block_seq = (block_seq+ 1)
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = slotrows),
   sch_slot_type sst,
   sch_disp_scheme sds
  PLAN (d)
   JOIN (sst
   WHERE (sst.slot_type_id=slotinfo->slist[d.seq].slot_type_id))
   JOIN (sds
   WHERE sds.disp_scheme_id=outerjoin(sst.disp_scheme_id))
  DETAIL
   slotinfo->slist[d.seq].contiguous_ind = sst.contiguous_ind, slotinfo->slist[d.seq].
   slot_description = sst.description, slotinfo->slist[d.seq].mnemonic = sst.mnemonic,
   slotinfo->slist[d.seq].sch_flex_id = sst.sch_flex_id, slotinfo->slist[d.seq].slot_scheme_id = sds
   .disp_scheme_id, slotinfo->slist[d.seq].border_style = sds.border_style,
   slotinfo->slist[d.seq].border_color = sds.border_color, slotinfo->slist[d.seq].border_size = sds
   .border_size, slotinfo->slist[d.seq].shape = sds.shape,
   slotinfo->slist[d.seq].pen_shape = sds.pen_shape
  WITH nocounter
 ;end select
 FOR (i = 1 TO slotrows)
   IF ((slotinfo->slist[i].contiguous_ind=1))
    IF ((slotinfo->slist[i].interval < 5))
     SET slotinfo->slist[i].interval = 0
    ENDIF
   ELSE
    SET slotinfo->slist[i].interval = - (1)
   ENDIF
 ENDFOR
 FOR (i = 1 TO resourcerows)
  SELECT INTO "NL:"
   nextseqnum = seq(sch_default_seq,nextval)"##################;RP0"
   FROM dual
   DETAIL
    idnumbers->idlist[i].frequency_id = cnvtreal(nextseqnum), reply->frequency_list[i].frequency_id
     = idnumbers->idlist[i].frequency_id
   WITH nocounter, format
  ;end select
  SELECT INTO "NL:"
   nextseqnum = seq(sch_def_apply_seq,nextval)"##################;RP0"
   FROM dual
   DETAIL
    idnumbers->idlist[i].def_apply_id = cnvtreal(nextseqnum)
   WITH nocounter, format
  ;end select
 ENDFOR
 SET def_sched_id = 0.0
 SELECT INTO "NL:"
  nextseqnum = seq(sch_default_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   def_sched_id = cnvtreal(nextseqnum)
  WITH nocounter, format
 ;end select
 SET duration = (get_minutes(request->day_end) - get_minutes(request->day_begin))
 IF ((request->day_end=2400))
  SET request->day_end = 0000
 ENDIF
 INSERT  FROM sch_def_sched sds
  SET sds.def_sched_id = def_sched_id, sds.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sds
   .mnemonic = request->mnemonic,
   sds.mnemonic_key = cnvtupper(request->mnemonic), sds.description = request->mnemonic, sds.beg_tm
    = request->day_begin,
   sds.end_tm = request->day_end, sds.interval = request->interval, sds.null_dt_tm = cnvtdatetime(
    "31-dec-2100 00:00:00"),
   sds.candidate_id = seq(sch_candidate_seq,nextval), sds.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), sds.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
   sds.active_ind = 1, sds.active_status_cd = active_cd, sds.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   sds.active_status_prsnl_id = reqinfo->updt_id, sds.default_type_cd = default_type_cd, sds
   .default_type_meaning = "DEFSCHED",
   sds.duration = duration, sds.apply_range = request->apply_range, sds.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   sds.updt_id = reqinfo->updt_id, sds.updt_task = reqinfo->updt_task, sds.updt_applctx = reqinfo->
   updt_applctx,
   sds.updt_cnt = 0
  WITH nocounter
 ;end insert
 INSERT  FROM sch_def_slot sds,
   (dummyt d  WITH seq = slotrows)
  SET sds.seq = 1, sds.def_slot_id = slotinfo->slist[d.seq].def_slot_id, sds.version_dt_tm =
   cnvtdatetime("31-dec-2100 00:00:00"),
   sds.beg_offset = slotinfo->slist[d.seq].beg_offset, sds.end_offset = slotinfo->slist[d.seq].
   end_offset, sds.slot_type_id = slotinfo->slist[d.seq].slot_type_id,
   sds.slot_mnemonic = slotinfo->slist[d.seq].mnemonic, sds.description = slotinfo->slist[d.seq].
   slot_description, sds.slot_scheme_id = slotinfo->slist[d.seq].slot_scheme_id,
   sds.contiguous_ind = slotinfo->slist[d.seq].contiguous_ind, sds.duration = slotinfo->slist[d.seq].
   duration, sds.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
   sds.candidate_id = seq(sch_candidate_seq,nextval), sds.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), sds.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
   sds.active_ind = 1, sds.active_status_cd = active_cd, sds.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   sds.active_status_prsnl_id = reqinfo->updt_id, sds.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   sds.updt_id = reqinfo->updt_id,
   sds.updt_task = reqinfo->updt_task, sds.updt_applctx = reqinfo->updt_applctx, sds.updt_cnt = 0,
   sds.holiday_weekend_flag = 0, sds.def_sched_id = def_sched_id, sds.sch_flex_id = slotinfo->slist[d
   .seq].sch_flex_id,
   sds.seq_nbr = slotinfo->slist[d.seq].seq_nbr, sds.slot_beg_offset = slotinfo->slist[d.seq].
   slot_beg_offset, sds.slot_duration = slotinfo->slist[d.seq].slot_duration,
   sds.slot_end_offset = slotinfo->slist[d.seq].slot_end_offset, sds.border_style = slotinfo->slist[d
   .seq].border_style, sds.vis_beg_offset = slotinfo->slist[d.seq].vis_beg_offset,
   sds.vis_beg_units = slotinfo->slist[d.seq].vis_beg_units, sds.vis_beg_units_cd = slotinfo->slist[d
   .seq].vis_beg_units_cd, sds.vis_beg_units_meaning = slotinfo->slist[d.seq].vis_beg_units_meaning,
   sds.vis_end_offset = slotinfo->slist[d.seq].vis_end_offset, sds.vis_end_units = slotinfo->slist[d
   .seq].vis_end_units, sds.vis_end_units_cd = slotinfo->slist[d.seq].vis_end_units_cd,
   sds.vis_end_units_meaning = slotinfo->slist[d.seq].vis_end_units_meaning, sds.border_size =
   slotinfo->slist[d.seq].border_size, sds.border_color = slotinfo->slist[d.seq].border_color,
   sds.shape = slotinfo->slist[d.seq].shape, sds.pen_shape = slotinfo->slist[d.seq].pen_shape, sds
   .interval = slotinfo->slist[d.seq].interval
  PLAN (d)
   JOIN (sds)
  WITH nocounter
 ;end insert
 IF (resourcerows > 0)
  INSERT  FROM sch_def_res sdr,
    (dummyt d  WITH seq = resourcerows)
   SET sdr.seq = 1, sdr.def_sched_id = def_sched_id, sdr.resource_cd = request->rlist[d.seq].
    resource_cd,
    sdr.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sdr.null_dt_tm = cnvtdatetime(curdate,
     curtime3), sdr.candidate_id = seq(sch_candidate_seq,nextval),
    sdr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sdr.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sdr.active_ind = 1,
    sdr.active_status_cd = active_cd, sdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sdr
    .active_status_prsnl_id = reqinfo->updt_id,
    sdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), sdr.updt_id = reqinfo->updt_id, sdr.updt_task =
    reqinfo->updt_task,
    sdr.updt_applctx = reqinfo->updt_applctx, sdr.updt_cnt = 0
   PLAN (d)
    JOIN (sdr)
   WITH nocounter
  ;end insert
 ENDIF
 IF (resourcerows > 0
  AND apply_template=1)
  INSERT  FROM sch_def_apply sda,
    (dummyt d  WITH seq = resourcerows)
   SET sda.seq = 1, sda.def_apply_id = idnumbers->idlist[d.seq].def_apply_id, sda.version_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00"),
    sda.def_sched_id = def_sched_id, sda.resource_cd = request->rlist[d.seq].resource_cd, sda
    .beg_dt_tm = cnvtdatetime(request->range_beg),
    sda.end_dt_tm = cnvtdatetime(request->range_end), sda.days_of_week = dayofweekstring, sda
    .apply_prsnl_id = reqinfo->updt_id,
    sda.apply_dt_tm = cnvtdatetime(curdate,curtime3), sda.null_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sda.candidate_id = seq(sch_candidate_seq,nextval),
    sda.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sda.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sda.active_ind = 1,
    sda.active_status_cd = active_cd, sda.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sda
    .active_status_prsnl_id = reqinfo->updt_id,
    sda.updt_dt_tm = cnvtdatetime(curdate,curtime3), sda.updt_id = reqinfo->updt_id, sda.updt_task =
    reqinfo->updt_task,
    sda.updt_applctx = reqinfo->updt_applctx, sda.updt_cnt = 0, sda.def_state_cd = active_state_cd,
    sda.def_state_meaning = "ACTIVE", sda.frequency_id = idnumbers->idlist[d.seq].frequency_id
   PLAN (d)
    JOIN (sda)
   WITH nocounter
  ;end insert
  INSERT  FROM sch_freq sf,
    (dummyt d  WITH seq = resourcerows)
   SET sf.seq = 1, sf.frequency_id = idnumbers->idlist[d.seq].frequency_id, sf.version_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00"),
    sf.freq_type_cd = default_freq_type_cd, sf.freq_type_meaning = "DEFSCHED", sf.freq_state_cd =
    active_freq_state_cd,
    sf.freq_state_meaning = "ACTIVE", sf.beg_dt_tm = cnvtdatetime(request->range_beg), sf.end_dt_tm
     = cnvtdatetime(request->range_end),
    sf.next_dt_tm = cnvtdatetime(request->range_beg), sf.end_type_cd = end_cd, sf.end_type_meaning =
    end_meaning,
    sf.occurance = 0, sf.max_occurance = request->max_occurance, sf.interval =
    IF ((request->repeatweeks > 0)) request->repeatweeks
    ELSE 1
    ENDIF
    ,
    sf.counter = 0, sf.days_of_week = dayofweekstring, sf.day_string = daystring,
    sf.week_string = weeknumberstring, sf.month_string = monthstring, sf.freq_pattern_cd =
    IF ((request->repeatweeks > 0)) monthly_cd
    ELSE weekly_cd
    ENDIF
    ,
    sf.freq_pattern_meaning =
    IF ((request->repeatweeks > 0)) "WEEKLY"
    ELSE "MONTHLY"
    ENDIF
    , sf.pattern_option =
    IF ((request->repeatweeks > 0)) 2
    ELSE 3
    ENDIF
    , sf.parent_table = "SCH_DEF_APPLY",
    sf.parent_id = idnumbers->idlist[d.seq].def_apply_id, sf.candidate_id = seq(sch_candidate_seq,
     nextval), sf.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    sf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sf.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sf.active_ind = 1,
    sf.active_status_cd = active_cd, sf.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sf
    .active_status_prsnl_id = reqinfo->updt_id,
    sf.updt_dt_tm = cnvtdatetime(curdate,curtime3), sf.updt_id = reqinfo->updt_id, sf.updt_task =
    reqinfo->updt_task,
    sf.updt_applctx = reqinfo->updt_applctx, sf.updt_cnt = 0, sf.apply_range = request->apply_range
   PLAN (d)
    JOIN (sf)
   WITH nocounter
  ;end insert
 ENDIF
 UPDATE  FROM br_sch_template bst
  SET bst.template_status_flag = 1
  WHERE (bst.br_sch_template_id=request->br_sch_template_id)
  WITH nocounter
 ;end update
 SET error_flag = "N"
#exit_script
 SET reply->error_msg = error_msg
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->error_msg > " "))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_minutes(xtime)
   SET hours = floor((xtime/ 100))
   SET minutes = mod(xtime,100)
   RETURN(((hours * 60)+ minutes))
 END ;Subroutine
END GO
