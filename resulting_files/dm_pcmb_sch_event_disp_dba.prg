CREATE PROGRAM dm_pcmb_sch_event_disp:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 candidate_id = f8
     2 updt_cnt = i4
     2 status = i2
 )
 SET count1 = 0
 SET cmb_dummy = 0
 SET loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "SCH_EVENT_DISP"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_SCH_EVENT_DISP"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->xxx_combine[icombine].encntr_id=0))
   WHERE (a.disp_value=request->xxx_combine[icombine].from_xxx_id)
    AND a.disp_field_id IN (2, 8, 12, 18, 19,
   20, 21, 22, 23, 24,
   25, 26)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1
    AND a.sch_event_id > 0
  ELSE
   WHERE (a.disp_value=request->xxx_combine[icombine].from_xxx_id)
    AND a.disp_field_id IN (2, 8, 12, 18, 19,
   20, 21, 22, 23, 24,
   25, 26)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.active_ind=1
    AND a.sch_event_id IN (
   (SELECT
    sep.sch_event_id
    FROM sch_event_patient sep
    WHERE (sep.encntr_id=request->xxx_combine[icombine].encntr_id)
     AND (sep.person_id=request->xxx_combine[icombine].from_xxx_id)
     AND sep.active_ind=1
     AND sep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")))
  ENDIF
  INTO "nl:"
  a.*
  FROM sch_event_disp a
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].candidate_id = a.candidate_id, rreclist->from_rec[count1].updt_cnt = a
   .updt_cnt, icombinedet += 1,
   stat = alterlist(request->xxx_combine_det,icombinedet), request->xxx_combine_det[icombinedet].
   combine_action_cd = upt, request->xxx_combine_det[icombinedet].entity_id = a.candidate_id,
   request->xxx_combine_det[icombinedet].entity_name = "SCH_EVENT_DISP", request->xxx_combine_det[
   icombinedet].attribute_name = "DISP_VALUE"
  WITH forupdatewait(a)
 ;end select
 IF (count1)
  FREE SET tsch_name
  SET tsch_name = fillstring(100," ")
  SELECT INTO "nl:"
   a.name_full_formatted
   FROM person a
   WHERE (a.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    tsch_name = a.name_full_formatted
   WITH nocounter
  ;end select
  UPDATE  FROM sch_event_disp t,
    (dummyt d  WITH seq = value(count1))
   SET t.disp_value = request->xxx_combine[icombine].to_xxx_id, t.disp_display = trim(tsch_name), t
    .updt_dt_tm = cnvtdatetime(sysdate),
    t.updt_applctx = reqinfo->updt_applctx, t.updt_id = reqinfo->updt_id, t.updt_cnt = (t.updt_cnt+ 1
    ),
    t.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (t
    WHERE (t.candidate_id=rreclist->from_rec[d.seq].candidate_id))
   WITH nocounter, status(rreclist->from_rec[d.seq].status)
  ;end update
  FOR (loopcount = 1 TO count1)
    IF ((rreclist->from_rec[loopcount].status != true))
     SET failed = update_error
     SET request->error_message = concat(build("Error updating candidate_id (",rreclist->from_rec[
       loopcount].candidate_id,") to person_id (",request->xxx_combine[icombine].to_xxx_id,
       ")--status(",
       rreclist->from_rec[loopcount].status,")"))
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 IF ( NOT (validate(upd_event_disp_request,0)))
  RECORD upd_event_disp_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 disp_field_id = f8
      2 disp_value = f8
      2 disp_display = vc
      2 version_ind = i2
      2 version_dt_tm = dq8
      2 candidate_id = f8
      2 disp_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(upd_event_disp_reply,0)))
  RECORD upd_event_disp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i2
  )
 ENDIF
 IF ( NOT (validate(add_event_disp_request,0)))
  RECORD add_event_disp_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 sch_event_id = f8
      2 schedule_id = f8
      2 sch_appt_id = f8
      2 seq_nbr = i4
      2 disp_field_id = f8
      2 disp_field_meaning = c12
      2 disp_value = f8
      2 disp_dt_tm = dq8
      2 disp_display = vc
      2 parent_table = c32
      2 parent_id = f8
      2 candidate_id = f8
      2 active_ind = i2
      2 active_status_cd = f8
      2 disp_tz = i4
      2 allow_partial_ind = i2
  )
 ENDIF
 IF ( NOT (validate(add_event_disp_reply,0)))
  RECORD add_event_disp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 candidate_id = f8
      2 status = i4
  )
 ENDIF
 IF ( NOT (validate(del_event_disp_request,0)))
  RECORD del_event_disp_request(
    1 call_echo_ind = i2
    1 qual[*]
      2 sch_event_id = f8
      2 disp_field_id = f8
      2 parent_table = c32
      2 parent_id = f8
      2 updt_cnt = i4
      2 allow_partial_ind = i2
      2 force_updt_ind = i2
  )
 ENDIF
 IF ( NOT (validate(del_event_disp_reply,0)))
  RECORD del_event_disp_reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
  )
 ENDIF
 DECLARE s_log_handle = i4 WITH protect, noconstant(0)
 DECLARE s_log_status = i4 WITH protect, noconstant(0)
 DECLARE s_message = vc WITH protect, noconstant("")
 SUBROUTINE (sch_log_message(l_event=vc,l_script_name=vc,l_message=vc,l_loglevel=i2) =null)
   IF ((l_loglevel > - (1))
    AND textlen(trim(l_message,3)) > 0)
    SET s_message = build("script::",l_script_name,", message::",l_message)
    CALL uar_syscreatehandle(s_log_handle,s_log_status)
    IF (s_log_handle != 0)
     CALL uar_sysevent(s_log_handle,l_loglevel,nullterm(l_event),nullterm(s_message))
     CALL uar_sysdestroyhandle(s_log_handle)
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE script_name = vc WITH protect, constant("sch_load_event_disp_req.inc")
 DECLARE s_disp_value = f8 WITH public, noconstant(0.0)
 DECLARE s_disp_dt_tm = dq8 WITH public, noconstant(0)
 DECLARE s_disp_display = vc WITH public, noconstant("")
 DECLARE dphonehomecd = f8 WITH noconstant(0.0)
 DECLARE dphoneworkcd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(43,"HOME",1,dphonehomecd)
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",1,dphoneworkcd)
 DECLARE s_location_mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE s_ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE s_where_candidate = vc WITH public, noconstant("")
 SUBROUTINE (loadeventdispreq(s_person_id=f8,s_disp_field_id=f8,s_transaction_id=f8,s_entity_id=f8,
  s_finaleventdispupd_ind=i2) =i2)
   SET s_disp_display = ""
   SET s_disp_value = 0.0
   SET s_disp_dt_tm = 0
   SET stat = alterlist(upd_event_disp_request->qual,(upd_event_disp_reply->qual_cnt+ (10 - mod(
     upd_event_disp_reply->qual_cnt,10))))
   IF (s_transaction_id > 0)
    SELECT INTO "nl:"
     pm.transaction_id
     FROM pm_transaction pm
     WHERE pm.transaction_id=s_transaction_id
     DETAIL
      IF (s_disp_field_id=15)
       IF (pm.n_birth_dt_tm=pm.o_birth_dt_tm)
        RETURN(1)
       ELSE
        s_disp_display = format(pm.n_birth_dt_tm,";;q"), s_disp_value = 0.0, s_disp_dt_tm =
        cnvtdatetime(pm.n_birth_dt_tm)
       ENDIF
      ELSEIF (s_disp_field_id=13)
       IF (pm.n_per_home_phone_id=pm.o_per_home_phone_id
        AND pm.n_per_home_ph_number=pm.o_per_home_ph_number
        AND pm.n_per_home_ph_format_cd=pm.o_per_home_ph_format_cd)
        RETURN(1)
       ELSE
        s_disp_display = cnvtphone(cnvtalphanum(pm.n_per_home_ph_number),n_per_home_ph_format_cd),
        s_disp_value = n_per_bus_phone_id, s_disp_dt_tm = 0
       ENDIF
      ELSEIF (s_disp_field_id=14)
       IF (pm.n_per_bus_phone_id=pm.o_per_bus_phone_id
        AND pm.n_per_bus_ph_number=pm.o_per_bus_ph_number
        AND pm.n_per_bus_ph_format_cd=pm.o_per_bus_ph_format_cd)
        RETURN(1)
       ELSE
        s_disp_display = cnvtphone(cnvtalphanum(pm.n_per_bus_ph_number),pm.n_per_bus_ph_format_cd),
        s_disp_value = n_per_bus_phone_id, s_disp_dt_tm = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (s_disp_field_id=15
    AND s_transaction_id=0)
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     WHERE p.person_id=s_person_id
     DETAIL
      IF (p.birth_dt_tm > 0)
       s_disp_display = format(p.birth_dt_tm,";;q"), s_disp_value = 0.0, s_disp_dt_tm = cnvtdatetime(
        p.birth_dt_tm)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (((s_disp_field_id=13) OR (s_disp_field_id=14
    AND s_transaction_id=0)) )
    SELECT INTO "nl:"
     ph.phone_id
     FROM phone ph
     WHERE ph.parent_entity_id=s_person_id
      AND ph.parent_entity_name="PERSON"
      AND ((ph.phone_type_cd=dphonehomecd
      AND s_disp_field_id=13) OR (ph.phone_type_cd=dphoneworkcd
      AND s_disp_field_id=14))
      AND ph.active_ind=1
      AND ph.phone_type_seq IN (0, 1)
      AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ph.end_effective_dt_tm > cnvtdatetime(sysdate)
     DETAIL
      IF (ph.phone_num > " ")
       s_disp_display = cnvtphone(cnvtalphanum(ph.phone_num),ph.phone_format_cd)
      ENDIF
      s_disp_value = ph.phone_id
     WITH nocounter
    ;end select
   ELSEIF (s_disp_field_id=42)
    IF (s_entity_id > 0.0)
     SET s_where_candidate = "sed.candidate_id+0 = s_entity_id"
    ELSE
     SET s_where_candidate = "sed.candidate_id+0 > 0"
    ENDIF
    SELECT INTO "nl:"
     FROM sch_event_disp sed,
      sch_schedule ss,
      location lo,
      org_alias_pool_reltn oapr,
      person_alias pa,
      sch_event_disp sed1,
      sch_event_disp sed2
     PLAN (sed
      WHERE parser(s_where_candidate)
       AND sed.disp_value=s_person_id
       AND sed.disp_field_id=2
       AND ((sed.version_dt_tm+ 0)=cnvtdatetime("31-DEC-2100 00:00:00.00")))
      JOIN (ss
      WHERE ss.sch_event_id=sed.sch_event_id
       AND  NOT (ss.state_meaning IN ("RESCHEDULED, CANCELLED")))
      JOIN (sed1
      WHERE sed1.sch_event_id=ss.sch_event_id
       AND sed1.schedule_id=ss.schedule_id
       AND sed1.active_ind=1
       AND sed1.disp_field_id=1
       AND sed1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND sed1.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (lo
      WHERE lo.location_cd=sed1.disp_value
       AND lo.active_ind=1
       AND lo.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND lo.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (oapr
      WHERE oapr.organization_id=lo.organization_id
       AND oapr.alias_entity_name=trim("PERSON_ALIAS")
       AND ((oapr.alias_entity_alias_type_cd+ 0)=s_location_mrn_cd)
       AND oapr.active_ind=1
       AND oapr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND oapr.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (pa
      WHERE (pa.person_id= Outerjoin(s_person_id))
       AND (pa.alias_pool_cd= Outerjoin(oapr.alias_pool_cd))
       AND ((pa.person_alias_type_cd+ 0)= Outerjoin(s_location_mrn_cd))
       AND (pa.active_ind= Outerjoin(1))
       AND (pa.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (sed2
      WHERE (sed2.sch_event_id= Outerjoin(sed1.sch_event_id))
       AND (sed2.disp_field_id= Outerjoin(42))
       AND (sed2.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (sed2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     ORDER BY sed.sch_event_id
     HEAD sed.sch_event_id
      IF (pa.person_alias_id > 0.0
       AND sed2.candidate_id > 0)
       upd_event_disp_reply->qual_cnt += 1
       IF (mod(upd_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(upd_event_disp_request->qual,(upd_event_disp_reply->qual_cnt+ 9))
       ENDIF
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_field_id = 42,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_value = 0.0,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_display = cnvtalias(pa.alias,
        pa.alias_pool_cd),
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_ind = 0,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_dt_tm = cnvtdatetime(
        sysdate), upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].candidate_id = sed2
       .candidate_id,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_dt_tm = null
      ELSEIF (pa.person_alias_id=0.0
       AND sed2.candidate_id > 0)
       del_event_disp_reply->qual_cnt += 1
       IF (mod(del_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(del_event_disp_request->qual,(del_event_disp_reply->qual_cnt+ 9))
       ENDIF
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].sch_event_id = sed2.sch_event_id,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].disp_field_id = 42,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].parent_table =
       "SCH_EVENT_PATIENT",
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].parent_id = sed2.parent_id,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].updt_cnt = sed2.updt_cnt,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].allow_partial_ind = false,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].force_updt_ind = true
      ELSEIF (pa.person_alias_id > 0
       AND sed2.candidate_id=0.0)
       add_event_disp_reply->qual_cnt += 1
       IF (mod(add_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(add_event_disp_request->qual,(add_event_disp_reply->qual_cnt+ 9))
       ENDIF
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].sch_event_id = sed1.sch_event_id,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].sch_appt_id = 0.0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].seq_nbr = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_field_id = 42,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_field_meaning = "PAT_MRN",
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_value = 0.0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_dt_tm = null,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_display = cnvtalias(pa.alias,
        pa.alias_pool_cd), add_event_disp_request->qual[add_event_disp_reply->qual_cnt].parent_table
        = "SCH_EVENT_PATIENT",
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].parent_id = sed.parent_id,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].candidate_id = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].active_ind = 1,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].active_status_cd = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_tz = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].allow_partial_ind = false
      ENDIF
     WITH nocounter, maxread(pa,1)
    ;end select
   ELSEIF (s_disp_field_id=43)
    IF (s_entity_id > 0.0)
     SET s_where_candidate = "sed.candidate_id+0 = s_entity_id"
    ELSE
     SET s_where_candidate = "sed.candidate_id+0 > 0"
    ENDIF
    SELECT INTO "nl:"
     FROM sch_event_disp sed,
      person_alias pa,
      sch_event_disp sed1
     PLAN (sed
      WHERE parser(s_where_candidate)
       AND sed.disp_value=s_person_id
       AND sed.disp_field_id=2
       AND ((sed.version_dt_tm+ 0)=cnvtdatetime("31-DEC-2100 00:00:00.00")))
      JOIN (pa
      WHERE (pa.person_id= Outerjoin(sed.disp_value))
       AND (pa.person_alias_type_cd= Outerjoin(s_ssn_cd))
       AND (pa.active_ind= Outerjoin(1))
       AND (pa.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (sed1
      WHERE (sed1.sch_event_id= Outerjoin(sed.sch_event_id))
       AND (sed1.disp_field_id= Outerjoin(43))
       AND (sed1.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (sed1.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     ORDER BY sed.sch_event_id
     HEAD sed.sch_event_id
      IF (pa.person_alias_id > 0.0
       AND sed1.candidate_id > 0)
       upd_event_disp_reply->qual_cnt += 1
       IF (mod(upd_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(upd_event_disp_request->qual,(upd_event_disp_reply->qual_cnt+ 9))
       ENDIF
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_field_id = 43,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_value = 0.0,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_display = cnvtalias(pa.alias,
        pa.alias_pool_cd),
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_ind = 0,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_dt_tm = cnvtdatetime(
        sysdate), upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].candidate_id = sed1
       .candidate_id,
       upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_dt_tm = null
      ELSEIF (pa.person_alias_id=0.0
       AND sed1.candidate_id > 0)
       del_event_disp_reply->qual_cnt += 1
       IF (mod(del_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(del_event_disp_request->qual,(del_event_disp_reply->qual_cnt+ 9))
       ENDIF
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].sch_event_id = sed1.sch_event_id,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].disp_field_id = 43,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].parent_table =
       "SCH_EVENT_PATIENT",
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].parent_id = sed1.parent_id,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].updt_cnt = sed1.updt_cnt,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].allow_partial_ind = false,
       del_event_disp_request->qual[del_event_disp_reply->qual_cnt].force_updt_ind = true
      ELSEIF (pa.person_alias_id > 0
       AND sed1.candidate_id=0.0)
       add_event_disp_reply->qual_cnt += 1
       IF (mod(add_event_disp_reply->qual_cnt,10)=1)
        stat = alterlist(add_event_disp_request->qual,(add_event_disp_reply->qual_cnt+ 9))
       ENDIF
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].sch_event_id = sed.sch_event_id,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].sch_appt_id = 0.0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].seq_nbr = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_field_id = 43,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_field_meaning = "SSN",
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_value = 0.0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_dt_tm = null,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_display = cnvtalias(pa.alias,
        pa.alias_pool_cd), add_event_disp_request->qual[add_event_disp_reply->qual_cnt].parent_table
        = "SCH_EVENT_PATIENT",
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].parent_id = sed.parent_id,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].candidate_id = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].active_ind = 1,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].active_status_cd = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].disp_tz = 0,
       add_event_disp_request->qual[add_event_disp_reply->qual_cnt].allow_partial_ind = false
      ENDIF
     WITH nocounter, maxread(pa,1)
    ;end select
   ENDIF
   IF (((s_disp_field_id=13) OR (((s_disp_field_id=14) OR (s_disp_field_id=15)) )) )
    SELECT
     IF (s_entity_id > 0)
      ed.disp_value, ed2.disp_value
      FROM sch_event_disp ed,
       sch_event_disp ed2
      PLAN (ed
       WHERE ed.candidate_id=s_entity_id
        AND ed.disp_value=s_person_id
        AND ((ed.disp_field_id=2) OR (ed.disp_field_id=s_disp_field_id)) )
       JOIN (ed2
       WHERE ed2.sch_event_id=ed.sch_event_id
        AND ed2.disp_field_id=s_disp_field_id
        AND ed2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     ELSE
      ep.person_id, ed2.disp_value
      FROM sch_event_patient ep,
       sch_event_disp ed2
      PLAN (ep
       WHERE ep.person_id=s_person_id
        AND ep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
       JOIN (ed2
       WHERE ed2.sch_event_id=ep.sch_event_id
        AND ed2.parent_table="SCH_EVENT_PATIENT"
        AND ed2.parent_id=ep.candidate_id
        AND ed2.disp_field_id=s_disp_field_id
        AND ed2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     ENDIF
     INTO "nl:"
     DETAIL
      upd_event_disp_reply->qual_cnt += 1
      IF (mod(upd_event_disp_reply->qual_cnt,10)=1)
       stat = alterlist(upd_event_disp_request->qual,(upd_event_disp_reply->qual_cnt+ 9))
      ENDIF
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_field_id = ed2.disp_field_id,
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_value = s_disp_value,
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_display = s_disp_display,
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_ind = 0,
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].version_dt_tm = cnvtdatetime(
       sysdate), upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].candidate_id = ed2
      .candidate_id,
      upd_event_disp_request->qual[upd_event_disp_reply->qual_cnt].disp_dt_tm = cnvtdatetime(
       s_disp_dt_tm)
     WITH nocounter
    ;end select
   ENDIF
   IF (s_finaleventdispupd_ind=1)
    IF (mod(upd_event_disp_reply->qual_cnt,10) != 0)
     SET stat = alterlist(upd_event_disp_request->qual,upd_event_disp_reply->qual_cnt)
    ENDIF
    IF (mod(del_event_disp_reply->qual_cnt,10) != 0)
     SET stat = alterlist(del_event_disp_request->qual,del_event_disp_reply->qual_cnt)
    ENDIF
    IF (mod(add_event_disp_reply->qual_cnt,10) != 0)
     SET stat = alterlist(add_event_disp_request->qual,add_event_disp_reply->qual_cnt)
    ENDIF
   ENDIF
   IF (curqual=0)
    CALL sch_log_message("No rows found to update",script_name,concat(cnvtstring(s_person_id),
      cnvtstring(s_disp_field_id),cnvtstring(s_transaction_id),cnvtstring(s_entity_id)),4)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET upd_event_disp_request->call_echo_ind = 0
 SET upd_event_disp_reply->qual_cnt = 0
 SET add_event_disp_reply->qual_cnt = 0
 SET del_event_disp_reply->qual_cnt = 0
 CALL loadeventdispreq(request->xxx_combine[icombine].to_xxx_id,13.0,0.0,0.0,0)
 CALL loadeventdispreq(request->xxx_combine[icombine].to_xxx_id,14.0,0.0,0.0,0)
 CALL loadeventdispreq(request->xxx_combine[icombine].to_xxx_id,15.0,0.0,0.0,0)
 CALL loadeventdispreq(request->xxx_combine[icombine].to_xxx_id,42.0,0.0,0.0,0)
 CALL loadeventdispreq(request->xxx_combine[icombine].to_xxx_id,43.0,0.0,0.0,1)
 IF ((upd_event_disp_reply->qual_cnt > 0))
  CALL echorecord(upd_event_disp_request)
  EXECUTE sch_upd_event_disp_cmb
  CALL echorecord(upd_event_disp_reply)
 ENDIF
 IF ((add_event_disp_reply->qual_cnt > 0))
  CALL echorecord(add_event_disp_request)
  EXECUTE sch_add_event_disp
  CALL echorecord(add_event_disp_reply)
 ENDIF
 IF ((del_event_disp_reply->qual_cnt > 0))
  CALL echorecord(del_event_disp_request)
  EXECUTE sch_del_event_disp
  CALL echorecord(del_event_disp_reply)
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET request->error_message = emsg
 ENDIF
#exit_script
 FREE SET rreclist
END GO
