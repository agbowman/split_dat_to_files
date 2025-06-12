CREATE PROGRAM bed_ens_order_appt:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET oadata
 RECORD oadata(
   1 list_0[*]
     2 order_cd = f8
     2 appt_cd = f8
     2 sch_flex_id = f8
     2 error_string = vc
     2 error_flag = i4
     2 locnum = i4
     2 llist[*]
       3 location_cd = f8
       3 location_disp = vc
       3 error_string = vc
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE proc_spec_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23000,"OPTIONAL"))
 DECLARE not_delete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23013,"NOTDELETE"))
 DECLARE minutes_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"MINUTES"))
 DECLARE slot_flex_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16162,"OAPPTTYPE"))
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 DECLARE numrows = i4 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect, noconstant("")
 SET str_qual = ","
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(oadata->list_0,numrows)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"Order Appointment Type Log")
 SET name = validate(log_name_set,"bed_order_appt.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = numrows),
   code_value c,
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE cnvtupper(oc.description)=cnvtupper(requestin->list_0[d.seq].order_mnemonic)
    AND oc.active_ind=1)
   JOIN (c
   WHERE c.code_value=oc.catalog_cd)
  DETAIL
   oadata->list_0[d.seq].order_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO numrows)
   IF ((oadata->list_0[i].order_cd=0.0))
    SET oadata->list_0[i].error_string = "Invalid Order"
    SET oadata->list_0[i].error_flag = 1
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = numrows),
   code_value c
  PLAN (c
   WHERE c.code_set=14230
    AND c.active_ind=1)
   JOIN (d
   WHERE c.display_key=trim(cnvtupper(cnvtalphanum(requestin->list_0[d.seq].appointment_type))))
  DETAIL
   oadata->list_0[d.seq].appt_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO numrows)
   IF ((oadata->list_0[i].appt_cd=0.0))
    SET oadata->list_0[i].error_string = "Invalid Appt Type"
    SET oadata->list_0[i].error_flag = 1
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = numrows),
   sch_order_appt soa
  PLAN (d
   WHERE (oadata->list_0[d.seq].error_flag != 1))
   JOIN (soa
   WHERE (soa.catalog_cd=oadata->list_0[d.seq].order_cd)
    AND (soa.appt_type_cd=oadata->list_0[d.seq].appt_cd)
    AND soa.active_ind=1)
  DETAIL
   oadata->list_0[d.seq].error_string = "Order - Appt Already Exists"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = numrows),
   sch_order_duration sod
  PLAN (d
   WHERE (oadata->list_0[d.seq].error_flag != 1))
   JOIN (sod
   WHERE (sod.catalog_cd=oadata->list_0[d.seq].order_cd)
    AND sod.location_cd=0.0
    AND sod.active_ind=1)
  DETAIL
   oadata->list_0[d.seq].error_flag = 2
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = numrows),
   sch_appt_loc sal,
   code_value c
  PLAN (d
   WHERE (oadata->list_0[d.seq].error_flag != 1))
   JOIN (sal
   WHERE (sal.appt_type_cd=oadata->list_0[d.seq].appt_cd)
    AND sal.active_ind=1)
   JOIN (c
   WHERE c.code_value=sal.location_cd)
  HEAD REPORT
   oadata->list_0[d.seq].locnum = 0
  DETAIL
   oadata->list_0[d.seq].locnum = (oadata->list_0[d.seq].locnum+ 1), state = alterlist(oadata->
    list_0[d.seq].llist,oadata->list_0[d.seq].locnum), oadata->list_0[d.seq].llist[oadata->list_0[d
   .seq].locnum].location_cd = c.code_value,
   oadata->list_0[d.seq].llist[oadata->list_0[d.seq].locnum].location_disp = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = numrows),
   (dummyt d2  WITH seq = 1),
   sch_order_loc soc
  PLAN (d1
   WHERE maxrec(d2,size(oadata->list_0[d1.seq].locnum,5))
    AND (oadata->list_0[d1.seq].error_flag != 1))
   JOIN (d2)
   JOIN (soc
   WHERE (soc.catalog_cd=oadata->list_0[d1.seq].order_cd)
    AND (soc.location_cd=oadata->list_0[d1.seq].llist[d2.seq].location_cd))
  DETAIL
   oadata->list_0[d1.seq].llist[d2.seq].error_string = "Duplicate Location"
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = numrows),
   sch_flex_string sfs
  PLAN (d
   WHERE (oadata->list_0[d.seq].error_flag != 1))
   JOIN (sfs
   WHERE sfs.mnemonic_key=cnvtupper(requestin->list_0[d.seq].flex_rule)
    AND sfs.active_ind=1
    AND sfs.flex_type_cd=slot_flex_cd)
  DETAIL
   oadata->list_0[d.seq].sch_flex_id = sfs.sch_flex_id
  WITH nocounter
 ;end select
 IF ((tempreq->insert_ind="Y"))
  INSERT  FROM sch_order_appt soa,
    (dummyt d  WITH seq = numrows)
   SET soa.seq = 1, soa.catalog_cd = oadata->list_0[d.seq].order_cd, soa.appt_type_cd = oadata->
    list_0[d.seq].appt_cd,
    soa.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), soa.seq_nbr = 0, soa.sch_flex_id =
    oadata->list_0[d.seq].sch_flex_id,
    soa.proc_spec_cd = proc_spec_cd, soa.proc_spec_meaning = "OPTIONAL", soa.null_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00"),
    soa.candidate_id = seq(sch_candidate_seq,nextval), soa.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), soa.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    soa.active_ind = 1, soa.active_status_cd = active_cd, soa.active_status_prsnl_id = reqinfo->
    updt_id,
    soa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), soa.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), soa.updt_id = reqinfo->updt_id,
    soa.updt_task = reqinfo->updt_task, soa.updt_applctx = reqinfo->updt_applctx, soa.updt_cnt = 0,
    soa.del_appt_cd = not_delete_cd, soa.del_appt_meaning = "NOTDELETE", soa.display_seq_nbr = 1
   PLAN (d
    WHERE (oadata->list_0[d.seq].error_string=" "))
    JOIN (soa)
   WITH nocounter
  ;end insert
  UPDATE  FROM sch_order_appt soa,
    (dummyt d  WITH seq = numrows)
   SET soa.seq = 1, soa.sch_flex_id = oadata->list_0[d.seq].sch_flex_id, soa.proc_spec_cd =
    proc_spec_cd,
    soa.proc_spec_meaning = "OPTIONAL", soa.del_appt_cd = not_delete_cd, soa.del_appt_meaning =
    "NOTDELETE",
    soa.updt_dt_tm = cnvtdatetime(curdate,curtime3), soa.updt_id = reqinfo->updt_id, soa.updt_task =
    reqinfo->updt_task,
    soa.updt_applctx = reqinfo->updt_applctx, soa.updt_cnt = (soa.updt_cnt+ 1)
   PLAN (d
    WHERE (oadata->list_0[d.seq].error_string="Order - Appt Already Exists"))
    JOIN (soa
    WHERE (soa.catalog_cd=oadata->list_0[d.seq].order_cd)
     AND (soa.appt_type_cd=oadata->list_0[d.seq].appt_cd))
   WITH nocounter
  ;end update
  INSERT  FROM sch_order_duration sod,
    (dummyt d  WITH seq = numrows)
   SET sod.seq = 1, sod.catalog_cd = oadata->list_0[d.seq].order_cd, sod.location_cd = 0.0,
    sod.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sod.setup_units = 10, sod
    .setup_units_cd = minutes_cd,
    sod.setup_units_meaning = "MINUTES", sod.duration_units = 60, sod.duration_units_cd = minutes_cd,
    sod.duration_units_meaning = "MINUTES", sod.cleanup_units = 10, sod.cleanup_units_cd = minutes_cd,
    sod.cleanup_units_meaning = "MINUTES", sod.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sod
    .candidate_id = seq(sch_candidate_seq,nextval),
    sod.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sod.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sod.active_ind = 1,
    sod.active_status_cd = active_cd, sod.active_status_prsnl_id = reqinfo->updt_id, sod
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    sod.updt_dt_tm = cnvtdatetime(curdate,curtime3), sod.updt_id = reqinfo->updt_id, sod.updt_task =
    reqinfo->updt_task,
    sod.updt_applctx = reqinfo->updt_applctx, sod.updt_cnt = 0, sod.arrival_units_cd = minutes_cd,
    sod.arrival_units_meaning = "MINUTES", sod.recovery_units_cd = minutes_cd, sod
    .recovery_units_meaning = "MINUTES"
   PLAN (d
    WHERE  NOT ((oadata->list_0[d.seq].error_flag IN (1, 2)))
     AND (oadata->list_0[d.seq].error_string != "Order - Appt Already Exists"))
    JOIN (sod)
   WITH nocounter
  ;end insert
  FOR (i = 1 TO numrows)
    INSERT  FROM sch_order_loc sol,
      (dummyt d  WITH seq = oadata->list_0[i].locnum)
     SET sol.seq = 1, sol.catalog_cd = oadata->list_0[i].order_cd, sol.location_cd = oadata->list_0[i
      ].llist[d.seq].location_cd,
      sol.version_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), sol.null_dt_tm = cnvtdatetime(
       "31-dec-2100 00:00:00"), sol.candidate_id = seq(sch_candidate_seq,nextval),
      sol.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sol.end_effective_dt_tm =
      cnvtdatetime("31-dec-2100 00:00:00"), sol.active_ind = 1,
      sol.active_status_cd = active_cd, sol.active_status_prsnl_id = reqinfo->updt_id, sol
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      sol.updt_dt_tm = cnvtdatetime(curdate,curtime3), sol.updt_id = reqinfo->updt_id, sol.updt_task
       = reqinfo->updt_task,
      sol.updt_applctx = reqinfo->updt_applctx, sol.updt_cnt = 0
     PLAN (d
      WHERE (oadata->list_0[i].error_flag != 1)
       AND (oadata->list_0[i].llist[d.seq].error_string=" "))
      JOIN (sol)
     WITH nocounter
    ;end insert
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = numrows)
  DETAIL
   col 8, d.seq"#####", col 20,
   requestin->list_0[d.seq].order_mnemonic, row + 1, col 50,
   requestin->list_0[d.seq].appointment_type
   IF ((oadata->list_0[d.seq].error_string=" "))
    IF ((tempreq->insert_ind="Y"))
     col 100, "Added"
    ELSE
     col 100, "Verified"
    ENDIF
   ELSE
    col 100, oadata->list_0[d.seq].error_string
   ENDIF
   FOR (j = 1 TO oadata->list_0[d.seq].locnum)
     row + 1, col 80, oadata->list_0[d.seq].llist[j].location_disp
     IF ((oadata->list_0[d.seq].llist[j].error_string=" "))
      IF ((tempreq->insert_ind="Y"))
       col 100, "Added"
      ELSE
       col 100, "Verified"
      ENDIF
     ELSE
      col 100, oadata->list_0[d.seq].llist[j].error_string
     ENDIF
   ENDFOR
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 10, "ROW",
     col 20, "ORDER NAME", col 50,
     "APPOINTMENT TYPE", col 80, "LOCATION",
     col 100, "STATUS"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
END GO
