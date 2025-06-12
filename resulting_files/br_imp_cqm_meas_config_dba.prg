CREATE PROGRAM br_imp_cqm_meas_config:dba
 FREE SET domain_list
 RECORD domain_list(
   1 domains[*]
     2 action_flag = i2
     2 domain = vc
     2 domain_meaning = vc
     2 domainid = f8
 )
 FREE SET measure_list
 RECORD measure_list(
   1 measures[*]
     2 action_flag = i2
     2 lh_cqm_meas_id = f8
     2 report_mean = vc
     2 measure_short_desc = vc
     2 measure_description = vc
     2 population_category = vc
     2 entity_type = i2
     2 domain_id = f8
     2 high_priority_ind = i2
     2 outcome_ind = i2
     2 active_ind = i2
 )
 FREE SET errorstate
 RECORD errorstate(
   1 errorstate[1]
     2 errormsg = vc
     2 status = i2
 )
 DECLARE getdomains(itemcount=i2,requestin=vc(ref),domain_list=vc(ref),errorstate=vc(ref)) = i4
 DECLARE getdomainstoupdate(domaincount=i2,domain_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE insertdomains(domaincount=i4,domain_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE updatedomains(domaincount=i4,domain_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE getmeasures(itemcount=i2,requestin=vc(ref),measure_list=vc(ref),errorstate=vc(ref)) = i4
 DECLARE getmeasurestoupdate(measurecount=i2,measure_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE insertmeasures(measurecount=i4,measure_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE updatemeasures(measurecount=i4,measure_list=vc(ref),errorstate=vc(ref)) = null
 DECLARE error = i2 WITH protect, constant(- (1))
 DECLARE noerror = i2 WITH protect, constant(0)
 DECLARE itemcount = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE domaincount = i4 WITH protect, noconstant(0)
 DECLARE measurecount = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_imp_cqm_meas_config.prg> script"
 SET errorstate->errorstate[1].status = error
 SET errorstate->errorstate[1].errormsg = ""
 IF (itemcount <= 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = " No rows on inputed csv, failing readme. "
  GO TO exit_script
 ENDIF
 SET domaincount = getdomains(itemcount,requestin,domain_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed getting domains to insert into domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 CALL getdomainstoupdate(domaincount,domain_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed getting domains to update into domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 IF (domaincount <= 0)
  GO TO post_domain_insert_update
 ENDIF
 CALL insertdomains(domaincount,domain_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed inserting domains not in the domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 CALL updatedomains(domaincount,domain_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed updating domains in the domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
#post_domain_insert_update
 SET measurecount = getmeasures(itemcount,requestin,measure_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed getting measures to insert into domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 CALL getmeasurestoupdate(measurecount,measure_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed getting measures to update in domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 IF (measurecount <= 0)
  GO TO post_measure_insert_update
 ENDIF
 CALL insertmeasures(measurecount,measure_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed inserting measures not in the domain: ",errorstate->
   errorstate[1].errormsg)
  GO TO exit_script
 ENDIF
 CALL updatemeasures(measurecount,measure_list,errorstate)
 IF ((errorstate->errorstate[1].status=error))
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(" Failed update measures in the domain: ",errorstate->errorstate[
   1].errormsg)
  GO TO exit_script
 ENDIF
#post_measure_insert_update
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_imp_cqm_meas_config.prg> script"
 COMMIT
#exit_script
 FREE RECORD domain_list
 FREE RECORD measure_list
 FREE RECORD errorstate
 CALL echorecord(readme_data)
 SUBROUTINE getdomains(itemcount,requestin,domain_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   DECLARE domainlistcount = i4 WITH protect, noconstant(0)
   IF (itemcount > 0)
    DECLARE index = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = itemcount)
     PLAN (d)
     ORDER BY d.seq
     HEAD d.seq
      IF (locateval(index,1,domainlistcount,cnvtupper(trim(requestin->list_0[d.seq].domain_meaning)),
       cnvtupper(trim(domain_list->domains[index].domain_meaning)))=0)
       domainlistcount = (domainlistcount+ 1), stat = alterlist(domain_list->domains,domainlistcount),
       domain_list->domains[domainlistcount].action_flag = 1,
       domain_list->domains[domainlistcount].domain = requestin->list_0[d.seq].domain, domain_list->
       domains[domainlistcount].domain_meaning = cnvtupper(requestin->list_0[d.seq].domain_meaning)
      ENDIF
     WITH nocounter
    ;end select
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with getting domains: ",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
    ELSE
     SET errorstate->errorstate[1].status = noerror
    ENDIF
   ENDIF
   RETURN(domainlistcount)
 END ;Subroutine
 SUBROUTINE getdomainstoupdate(domaincount,domain_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (domaincount > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = domaincount),
      lh_cqm_domain cqm
     PLAN (d)
      JOIN (cqm
      WHERE cnvtupper(trim(cqm.domain_meaning))=cnvtupper(trim(domain_list->domains[d.seq].
        domain_meaning)))
     ORDER BY d.seq, cqm.lh_cqm_domain_id
     HEAD cqm.lh_cqm_domain_id
      domain_list->domains[d.seq].action_flag = 2, domain_list->domains[d.seq].domainid = cqm
      .lh_cqm_domain_id
     WITH nocounter
    ;end select
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with getting domains to update: ",
      errorstate->errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
    ELSE
     SET errorstate->errorstate[1].status = noerror
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdomains(domainlistcount,domain_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (domainlistcount > 0)
    INSERT  FROM (dummyt d  WITH seq = domainlistcount),
      lh_cqm_domain cqm
     SET cqm.lh_cqm_domain_name = substring(1,100,domain_list->domains[d.seq].domain), cqm
      .domain_meaning = domain_list->domains[d.seq].domain_meaning, cqm.lh_cqm_domain_id = seq(
       reference_seq,nextval),
      cqm.updt_task = reqinfo->updt_task, cqm.updt_id = reqinfo->updt_id, cqm.updt_applctx = reqinfo
      ->updt_applctx,
      cqm.updt_cnt = 0, cqm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE (domain_list->domains[d.seq].action_flag=1))
      JOIN (cqm)
     WITH nocounter
    ;end insert
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with inserting domain: ",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
     RETURN
    ENDIF
   ENDIF
   SET errorstate->errorstate[1].status = noerror
 END ;Subroutine
 SUBROUTINE updatedomains(domainlistcount,domain_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (domainlistcount > 0)
    UPDATE  FROM (dummyt d  WITH seq = domainlistcount),
      lh_cqm_domain cqm
     SET cqm.lh_cqm_domain_name = substring(1,100,domain_list->domains[d.seq].domain), cqm.updt_task
       = reqinfo->updt_task, cqm.updt_id = reqinfo->updt_id,
      cqm.updt_applctx = reqinfo->updt_applctx, cqm.updt_cnt = (cqm.updt_cnt+ 1), cqm.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE (domain_list->domains[d.seq].action_flag=2))
      JOIN (cqm
      WHERE (cqm.lh_cqm_domain_id=domain_list->domains[d.seq].domainid))
     WITH nocounter
    ;end update
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with updating domain: ",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
     RETURN
    ENDIF
   ENDIF
   SET errorstate->errorstate[1].status = noerror
 END ;Subroutine
 SUBROUTINE getmeasures(itemcount,requestin,measure_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   DECLARE measurecount = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE report_mean_not_found_index = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO itemcount)
    IF (report_mean_not_found_index=0)
     SELECT INTO "nl:"
      FROM br_datamart_report bdr
      PLAN (bdr
       WHERE cnvtupper(trim(bdr.report_mean))=cnvtupper(trim(requestin->list_0[x].report_mean)))
      WITH nocounter
     ;end select
     IF (error(errorstate->errorstate[1].errormsg,0) > 0)
      SET errorstate->errorstate[1].errormsg = concat("Error getting report means: ",errorstate->
       errorstate[1].errormsg)
      SET errorstate->errorstate[1].status = error
      RETURN(0)
     ENDIF
    ENDIF
    IF (curqual=0)
     SET report_mean_not_found_index = x
    ENDIF
   ENDFOR
   IF (report_mean_not_found_index > 0)
    SET errorstate->errorstate[1].errormsg = concat(" Can't find report_mean ",requestin->list_0[
     report_mean_not_found_index].report_mean)
    SET errorstate->errorstate[1].status = error
    RETURN(0)
   ENDIF
   IF (itemcount > 0
    AND report_mean_not_found_index=0)
    DECLARE errorindex = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = itemcount),
      lh_cqm_domain lcd,
      br_datamart_report bdr
     PLAN (d)
      JOIN (lcd
      WHERE (lcd.domain_meaning=requestin->list_0[d.seq].domain_meaning))
      JOIN (bdr
      WHERE cnvtupper(trim(bdr.report_mean))=cnvtupper(trim(requestin->list_0[d.seq].report_mean)))
     ORDER BY d.seq, lcd.lh_cqm_domain_id, bdr.report_mean
     DETAIL
      measurecount = (measurecount+ 1), stat = alterlist(measure_list->measures,measurecount),
      measure_list->measures[measurecount].action_flag = 1,
      measure_list->measures[measurecount].report_mean = cnvtupper(requestin->list_0[d.seq].
       report_mean), measure_list->measures[measurecount].measure_short_desc = requestin->list_0[d
      .seq].measure_short_desc, measure_list->measures[measurecount].measure_description = bdr
      .report_name,
      measure_list->measures[measurecount].population_category = requestin->list_0[d.seq].
      population_category, measure_list->measures[measurecount].domain_id = lcd.lh_cqm_domain_id
      IF (cnvtupper(requestin->list_0[d.seq].entity_type)="EP")
       measure_list->measures[measurecount].entity_type = 1
      ELSEIF (cnvtupper(requestin->list_0[d.seq].entity_type)="CCN")
       measure_list->measures[measurecount].entity_type = 2
      ELSE
       errorindex = measurecount
      ENDIF
      IF (cnvtupper(requestin->list_0[d.seq].active_ind)="Y")
       measure_list->measures[measurecount].active_ind = 1
      ELSEIF (cnvtupper(requestin->list_0[d.seq].active_ind)="N")
       measure_list->measures[measurecount].active_ind = 0
      ELSE
       errorindex = measurecount
      ENDIF
      IF (cnvtupper(requestin->list_0[d.seq].high_priority_ind)="Y")
       measure_list->measures[measurecount].high_priority_ind = 1
      ELSEIF (cnvtupper(requestin->list_0[d.seq].high_priority_ind)="")
       measure_list->measures[measurecount].high_priority_ind = 0
      ELSE
       errorindex = measurecount
      ENDIF
      IF (cnvtupper(requestin->list_0[d.seq].outcome_ind)="Y")
       measure_list->measures[measurecount].outcome_ind = 1
      ELSEIF (cnvtupper(requestin->list_0[d.seq].outcome_ind)="")
       measure_list->measures[measurecount].outcome_ind = 0
      ELSE
       errorindex = measurecount
      ENDIF
     WITH nocounter
    ;end select
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat("Error getting measures to insert:",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
    ELSEIF (errorindex > 0)
     SET errorstate->errorstate[1].errormsg = concat("Error getting measure to insert: ",measure_list
      ->measures[errorindex].measure_short_desc)
     SET errorstate->errorstate[1].status = error
    ELSE
     SET errorstate->errorstate[1].status = noerror
    ENDIF
   ENDIF
   RETURN(measurecount)
 END ;Subroutine
 SUBROUTINE getmeasurestoupdate(measurecount,measure_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (measurecount > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = measurecount),
      lh_cqm_meas lcm
     PLAN (d)
      JOIN (lcm
      WHERE (lcm.meas_ident=measure_list->measures[d.seq].report_mean))
     ORDER BY d.seq, lcm.lh_cqm_meas_id
     DETAIL
      measure_list->measures[d.seq].action_flag = 2, measure_list->measures[d.seq].lh_cqm_meas_id =
      lcm.lh_cqm_meas_id
     WITH nocounter
    ;end select
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat("Error getting measures to update: ",errorstate
      ->errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
    ELSE
     SET errorstate->errorstate[1].status = noerror
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertmeasures(measurecount,measure_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (measurecount > 0)
    INSERT  FROM (dummyt d  WITH seq = measurecount),
      lh_cqm_meas lcm
     SET lcm.meas_ident = measure_list->measures[d.seq].report_mean, lcm.measure_short_desc =
      measure_list->measures[d.seq].measure_short_desc, lcm.meas_desc = measure_list->measures[d.seq]
      .measure_description,
      lcm.population_category_txt = measure_list->measures[d.seq].population_category, lcm.active_ind
       = measure_list->measures[d.seq].active_ind, lcm.high_priority_ind = measure_list->measures[d
      .seq].high_priority_ind,
      lcm.outcome_ind = measure_list->measures[d.seq].outcome_ind, lcm.svc_entity_type_flag =
      measure_list->measures[d.seq].entity_type, lcm.lh_cqm_domain_id = measure_list->measures[d.seq]
      .domain_id,
      lcm.lh_cqm_meas_id = seq(reference_seq,nextval), lcm.updt_task = reqinfo->updt_task, lcm
      .updt_id = reqinfo->updt_id,
      lcm.updt_applctx = reqinfo->updt_applctx, lcm.updt_cnt = 0, lcm.updt_dt_tm = cnvtdatetime(
       curdate,curtime3)
     PLAN (d
      WHERE (measure_list->measures[d.seq].action_flag=1))
      JOIN (lcm)
     WITH nocounter
    ;end insert
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with inserting measure: ",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
     RETURN
    ENDIF
   ENDIF
   SET errorstate->errorstate[1].status = noerror
 END ;Subroutine
 SUBROUTINE updatemeasures(measurecount,measure_list,errorstate)
   SET errorstate->errorstate[1].status = error
   SET errorstate->errorstate[1].errormsg = ""
   IF (measurecount > 0)
    DECLARE item_count = i4 WITH protect, noconstant(0)
    UPDATE  FROM (dummyt d  WITH seq = measurecount),
      lh_cqm_meas lcm
     SET lcm.meas_desc = measure_list->measures[d.seq].measure_description, lcm.measure_short_desc =
      measure_list->measures[d.seq].measure_short_desc, lcm.population_category_txt = measure_list->
      measures[d.seq].population_category,
      lcm.active_ind = measure_list->measures[d.seq].active_ind, lcm.high_priority_ind = measure_list
      ->measures[d.seq].high_priority_ind, lcm.outcome_ind = measure_list->measures[d.seq].
      outcome_ind,
      lcm.svc_entity_type_flag = measure_list->measures[d.seq].entity_type, lcm.lh_cqm_domain_id =
      measure_list->measures[d.seq].domain_id, lcm.updt_task = reqinfo->updt_task,
      lcm.updt_id = reqinfo->updt_id, lcm.updt_applctx = reqinfo->updt_applctx, lcm.updt_cnt = (lcm
      .updt_cnt+ 1),
      lcm.updt_dt_tm = cnvtdatetime(curdate,curtime3), item_count = d.seq
     PLAN (d
      WHERE (measure_list->measures[d.seq].action_flag=2))
      JOIN (lcm
      WHERE (lcm.lh_cqm_meas_id=measure_list->measures[d.seq].lh_cqm_meas_id))
     WITH nocounter
    ;end update
    IF (error(errorstate->errorstate[1].errormsg,0) > 0)
     SET errorstate->errorstate[1].errormsg = concat(" Issue with updating measure: ",errorstate->
      errorstate[1].errormsg)
     SET errorstate->errorstate[1].status = error
     RETURN
    ENDIF
   ENDIF
   SET errorstate->errorstate[1].status = noerror
 END ;Subroutine
END GO
