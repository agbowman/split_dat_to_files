CREATE PROGRAM bbd_chg_donation_procs:dba
 RECORD internal(
   1 qual[1]
     2 field_name = c32
     2 field_type = i4
 )
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display_key = c40
     2 procedure_id = f8
     2 collation_seq = i4
     2 cv_updt_cnt = i4
     2 dp_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET count1 = 0
 SET y = 0
 SET next_code = 0.0
 SET donation_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET authentic_cd = 0.00
 SET unauthentic_cd = 0.00
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
  ORDER BY c.cdf_meaning
  DETAIL
   IF (c.cdf_meaning="AUTH")
    authentic_cd = c.code_value
   ELSE
    unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 FOR (y = 1 TO request->donation_count)
   IF ((request->qual[y].add_row=1))
    EXECUTE cpm_next_code
    INSERT  FROM code_value c
     SET c.code_value = next_code, c.code_set = request->code_set, c.cdf_meaning = request->qual[y].
      cdf_meaning,
      c.display = request->qual[y].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
         qual[y].display))), c.description = request->qual[y].description,
      c.definition = request->qual[y].definition, c.collation_seq = request->qual[y].collation_seq, c
      .active_ind = request->qual[y].active_ind,
      c.active_type_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , c.data_status_cd =
      IF ((request->qual[y].authentic_ind=1)) authentic_cd
      ELSE unauthentic_cd
      ENDIF
      , c.active_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      ,
      c.inactive_dt_tm =
      IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , c.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      , c.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      c.data_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      , c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
      c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx,
      c.begin_effective_dt_tm = cnvtdatetime(request->qual[y].begin_effective_dt_tm), c
      .end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "code value update"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].code_value = next_code
     SET reply->qual[y].display_key = trim(cnvtupper(cnvtalphanum(request->qual[y].display)))
     SET reply->qual[y].collation_seq = request->qual[y].collation_seq
     SET reply->qual[y].cv_updt_cnt = 0
    ENDIF
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtint(seqn)
     WITH format, nocounter
    ;end select
    SET donation_id = new_pathnet_seq
    INSERT  FROM donation_procedure d
     SET d.procedure_id = donation_id, d.procedure_cd = next_code, d.deferrals_allowed_cd = request->
      qual[y].deferrals_allowed_cd,
      d.nbr_per_volume_level = request->qual[y].nbr_per_volume_level, d.schedule_ind = request->qual[
      y].schedule_ind, d.default_bag_type_cd = request->qual[y].default_bag_type_cd,
      d.start_stop_ind = request->qual[y].start_stop_ind, d.collation_seq = request->qual[y].
      collation_seq, d.active_ind = request->qual[y].active_ind,
      d.active_type_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , d.active_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , d.inactive_dt_tm =
      IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      ,
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_cnt = 0,
      d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d
      .begin_effective_dt_tm = cnvtdatetime(request->qual[y].begin_effective_dt_tm),
      d.end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "donation_procedure"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "donation procedure"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET reply->qual[y].procedure_id = donation_id
     SET reply->qual[y].dp_updt_cnt = 0
    ENDIF
   ELSE
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].cv_updt_cnt = request->qual[y].code_value_updt_cnt
    SET reply->qual[y].dp_updt_cnt = request->qual[y].don_proc_updt_cnt
    IF ((request->qual[y].mod_code_set=1))
     SELECT INTO "nl:"
      c.*
      FROM code_value c
      WHERE (c.code_set=request->code_set)
       AND (c.code_value=request->qual[y].code_value)
       AND (c.updt_cnt=request->qual[y].code_value_updt_cnt)
      WITH counter, forupdate(c)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
      SET reply->status_data.subeventstatus[1].operationname = "lock"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "code value lock"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
     UPDATE  FROM code_value c
      SET c.code_value = request->qual[y].code_value, c.code_set = request->code_set, c.cdf_meaning
        = request->qual[y].cdf_meaning,
       c.display = request->qual[y].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
          qual[y].display))), c.description = request->qual[y].description,
       c.definition = request->qual[y].definition, c.collation_seq = request->qual[y].collation_seq,
       c.active_ind = request->qual[y].active_ind,
       c.active_type_cd =
       IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->inactive_status_cd
       ENDIF
       , c.data_status_cd =
       IF ((request->qual[y].authentic_ind=1)) authentic_cd
       ELSE unauthentic_cd
       ENDIF
       , c.active_dt_tm =
       IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       ,
       c.inactive_dt_tm =
       IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       , c.active_status_prsnl_id =
       IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
       ELSE 0
       ENDIF
       , c.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       c.data_status_prsnl_id =
       IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
       ELSE 0
       ENDIF
       , c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
       c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
       updt_applctx,
       c.begin_effective_dt_tm = cnvtdatetime(request->qual[y].begin_effective_dt_tm), c
       .end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm)
      WHERE (c.code_set=request->code_set)
       AND (c.code_value=request->qual[y].code_value)
       AND (c.updt_cnt=request->qual[y].code_value_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
      SET reply->status_data.subeventstatus[1].operationname = "update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "code value table"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ELSE
      SET reply->qual[y].code_value = request->qual[y].code_value
      SET reply->qual[y].procedure_id = request->qual[y].procedure_id
      SET reply->qual[y].display_key = trim(cnvtupper(cnvtalphanum(request->qual[y].display)))
      SET reply->qual[y].collation_seq = request->qual[y].collation_seq
      SET reply->qual[y].cv_updt_cnt = (request->qual[y].code_value_updt_cnt+ 1)
     ENDIF
    ENDIF
    IF ((request->qual[y].mod_don_proc=1))
     SELECT INTO "nl:"
      d.*
      FROM donation_procedure d
      WHERE (d.procedure_id=request->qual[y].procedure_id)
       AND (d.updt_cnt=request->qual[y].don_proc_updt_cnt)
      WITH counter, forupdate(d)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
      SET reply->status_data.subeventstatus[1].operationname = "lock"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "donation_procedure"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "donation procedure"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
     UPDATE  FROM donation_procedure d
      SET d.procedure_id = request->qual[y].procedure_id, d.procedure_cd = request->qual[y].
       code_value, d.deferrals_allowed_cd = request->qual[y].deferrals_allowed_cd,
       d.nbr_per_volume_level = request->qual[y].nbr_per_volume_level, d.schedule_ind = request->
       qual[y].schedule_ind, d.default_bag_type_cd = request->qual[y].default_bag_type_cd,
       d.start_stop_ind = request->qual[y].start_stop_ind, d.collation_seq = request->qual[y].
       collation_seq, d.active_ind = request->qual[y].active_ind,
       d.active_type_cd =
       IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->inactive_status_cd
       ENDIF
       , d.active_dt_tm =
       IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       , d.inactive_dt_tm =
       IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
       ELSE null
       ENDIF
       ,
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_cnt = (
       request->qual[y].don_proc_updt_cnt+ 1),
       d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d
       .begin_effective_dt_tm = cnvtdatetime(request->qual[y].begin_effective_dt_tm),
       d.end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm)
      WHERE (d.procedure_id=request->qual[y].procedure_id)
       AND (d.updt_cnt=request->qual[y].don_proc_updt_cnt)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donation_procedure"
      SET reply->status_data.subeventstatus[1].operationname = "update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "donation_procedure"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "donation procedure"
      SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ELSE
      SET reply->qual[y].code_value = request->qual[y].code_value
      SET reply->qual[y].procedure_id = request->qual[y].procedure_id
      SET reply->qual[y].collation_seq = request->qual[y].collation_seq
      SET reply->qual[y].dp_updt_cnt = (request->qual[y].don_proc_updt_cnt+ 1)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
