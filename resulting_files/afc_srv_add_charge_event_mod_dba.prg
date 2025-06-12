CREATE PROGRAM afc_srv_add_charge_event_mod:dba
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  y = seq(charge_event_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(y)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET request->mod_id = - (2)
  GO TO end_program
 ELSE
  SET request->mod_id = new_nbr
 ENDIF
 CALL echo(concat("field1 = '",trim(request->field1),"'"))
 INSERT  FROM charge_event_mod c
  SET c.charge_event_mod_id = new_nbr, c.charge_event_id = request->charge_event_id, c
   .charge_event_mod_type_cd = request->charge_event_mod_type_cd,
   c.field1 = trim(request->field1), c.field2 = trim(request->field2), c.field3 = trim(request->
    field3),
   c.field4 = trim(request->field4), c.field5 = trim(request->field5), c.field6 = trim(request->
    field6),
   c.field7 = trim(request->field7), c.field8 = trim(request->field8), c.field9 = trim(request->
    field9),
   c.field10 = trim(request->field10), c.beg_effective_dt_tm =
   IF ((request->beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
   ELSE cnvtdatetime(request->beg_effective_dt_tm)
   ENDIF
   , c.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   c.active_ind = request->active_ind, c.active_status_cd = request->active_status_cd, c
   .active_status_prsnl_id = request->active_status_prsnl_id,
   c.active_status_dt_tm = cnvtdatetime(curdate,curtime), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime
   (curdate,curtime),
   c.updt_id = 0, c.updt_applctx = 0, c.updt_task = 0,
   c.field1_id = request->field1_id, c.field2_id = request->field2_id, c.field3_id = request->
   field3_id,
   c.field4_id = request->field4_id, c.field5_id = request->field5_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET request->mod_id = - (3)
 ENDIF
#end_program
END GO
