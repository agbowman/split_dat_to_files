CREATE PROGRAM afc_srv_add_charge_mod:dba
 RECORD reply(
   1 error_qual = i2
   1 error_information[*]
     2 error_code = i2
     2 error_msg = c132
   1 mod_id = f8
 )
 SET error_code = 1
 SET error_msg = fillstring(132," ")
 SET error_count = 0
 SET error_clear = 0
 SET msg_clear = fillstring(132," ")
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  y = seq(charge_event_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(y)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET reply->mod_id = - (2)
  GO TO end_program
 ELSE
  SET reply->mod_id = new_nbr
 ENDIF
 SET error_clear = error(msg_clear,1)
 INSERT  FROM charge_mod c
  SET c.charge_mod_id = new_nbr, c.charge_item_id = request->charge_item_id, c.charge_mod_type_cd =
   request->charge_mod_type_cd,
   c.field1 = substring(1,200,trim(request->field1)), c.field2 = substring(1,200,trim(request->field2
     )), c.field3 = substring(1,200,trim(request->field3)),
   c.field4 = substring(1,200,trim(request->field4)), c.field5 = substring(1,200,trim(request->field5
     )), c.field6 = substring(1,200,trim(request->field6)),
   c.field7 = substring(1,200,trim(request->field7)), c.field8 = substring(1,200,trim(request->field8
     )), c.field9 = substring(1,200,trim(request->field9)),
   c.field10 = substring(1,200,trim(request->field10)), c.beg_effective_dt_tm =
   IF ((request->beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
   ELSE cnvtdatetime(request->beg_effective_dt_tm)
   ENDIF
   , c.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   c.active_ind = request->active_ind, c.active_status_cd = request->active_status_cd, c
   .active_status_prsnl_id = request->active_status_prsnl_id,
   c.active_status_dt_tm = cnvtdatetime(curdate,curtime), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime
   (curdate,curtime),
   c.updt_id = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task,
   c.field1_id = request->field1_id, c.field2_id = request->field2_id, c.field3_id = request->
   field3_id,
   c.field4_id = request->field4_id, c.field5_id = request->field5_id, c.nomen_id = request->nomen_id
  WITH nocounter
 ;end insert
 SET error_code = error(error_msg,0)
 WHILE (error_code != 0)
   SET error_count += 1
   SET reply->error_qual = error_count
   SET stat = alterlist(reply->error_information,error_count)
   SET reply->error_information[error_count].error_code = error_code
   SET reply->error_information[error_count].error_msg = error_msg
   SET error_code = error(error_msg,0)
 ENDWHILE
 IF (curqual=0)
  SET reply->mod_id = - (3)
 ENDIF
#end_program
END GO
