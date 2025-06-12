CREATE PROGRAM br_ord_appt_types_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ord_appt_types_config.prg> script"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE hold_appt_type = vc
 DECLARE max_cnt = i4 WITH public, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "No records in Requestin structure."
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 aqual[*]
     2 appointment_type = vc
     2 appt_type_id = f8
     2 catalog_type = vc
     2 catalog_type_cd = f8
     2 dept_type_id = f8
     2 match_appt_type_cd = f8
     2 oqual[*]
       3 appt_type_id = f8
       3 duration = i4
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
       3 catalog_type = vc
       3 catalog_type_cd = f8
       3 activity_type = vc
       3 activity_type_cd = f8
       3 activity_subtype = vc
       3 activity_subtype_cd = f8
 )
 SET hold_appt_type = " "
 SET acnt = 0
 FOR (x = 1 TO cnt)
   IF ((hold_appt_type != requestin->list_0[x].appointment_type))
    SET hold_appt_type = requestin->list_0[x].appointment_type
    SET acnt = (acnt+ 1)
    SET stat = alterlist(temp->aqual,acnt)
    SET temp->aqual[acnt].appointment_type = requestin->list_0[x].appointment_type
    SET temp->aqual[acnt].catalog_type = cnvtupper(requestin->list_0[x].catalog_type)
    SET appt_type_id = 0.0
    SELECT INTO "nl:"
     appt = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      appt_type_id = cnvtreal(appt)
     WITH format, counter
    ;end select
    SET temp->aqual[acnt].appt_type_id = appt_type_id
    SET temp->aqual[acnt].dept_type_id = 0
    SET temp->aqual[acnt].match_appt_type_cd = 0
    SET ocnt = 0
   ENDIF
   SET ocnt = (ocnt+ 1)
   IF (ocnt > max_cnt)
    SET max_cnt = ocnt
   ENDIF
   SET stat = alterlist(temp->aqual[acnt].oqual,ocnt)
   SET temp->aqual[acnt].oqual[ocnt].appt_type_id = appt_type_id
   SET temp->aqual[acnt].oqual[ocnt].duration = cnvtint(requestin->list_0[x].duration)
   SET temp->aqual[acnt].oqual[ocnt].mnemonic = requestin->list_0[x].mnemonic
   SET temp->aqual[acnt].oqual[ocnt].description = requestin->list_0[x].description
   SET temp->aqual[acnt].oqual[ocnt].concept_cki = requestin->list_0[x].concept_cki
   SET temp->aqual[acnt].oqual[ocnt].catalog_type = cnvtupper(requestin->list_0[x].catalog_type)
   SET temp->aqual[acnt].oqual[ocnt].activity_type = cnvtupper(requestin->list_0[x].activity_type)
   SET temp->aqual[acnt].oqual[ocnt].activity_subtype = cnvtupper(requestin->list_0[x].
    activity_subtype)
 ENDFOR
 IF (acnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "No records loaded into TEMP structure."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(temp->aqual,5))),
   (dummyt d2  WITH seq = 1),
   order_catalog oc
  PLAN (d1
   WHERE maxrec(d2,size(temp->aqual[d1.seq].oqual,5)))
   JOIN (d2
   WHERE (temp->aqual[d1.seq].oqual[d2.seq].catalog_type > " "))
   JOIN (oc
   WHERE (oc.concept_cki=temp->aqual[d1.seq].oqual[d2.seq].concept_cki))
  DETAIL
   temp->aqual[d1.seq].catalog_type_cd = oc.catalog_type_cd, temp->aqual[d1.seq].oqual[d2.seq].
   catalog_type_cd = oc.catalog_type_cd, temp->aqual[d1.seq].oqual[d2.seq].activity_type_cd = oc
   .activity_type_cd,
   temp->aqual[d1.seq].oqual[d2.seq].activity_subtype_cd = oc.activity_subtype_cd
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM br_sched_appt_type b,
   (dummyt d  WITH seq = value(acnt))
  SET b.appt_type_id = temp->aqual[d.seq].appt_type_id, b.appt_type_display = temp->aqual[d.seq].
   appointment_type, b.match_appt_type_cd = temp->aqual[d.seq].match_appt_type_cd,
   b.catalog_type_cd = temp->aqual[d.seq].catalog_type_cd, b.orders_based_ind = 1, b.dept_type_id =
   temp->aqual[d.seq].dept_type_id,
   b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(serrmsg,"; Failed on br_sched_appt_type insert.")
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM br_sched_appt_type_ord b,
   (dummyt d1  WITH seq = value(size(temp->aqual,5))),
   (dummyt d2  WITH seq = value(max_cnt))
  SET b.appt_type_id = temp->aqual[d1.seq].oqual[d2.seq].appt_type_id, b.primary_mnemonic = temp->
   aqual[d1.seq].oqual[d2.seq].mnemonic, b.duration = temp->aqual[d1.seq].oqual[d2.seq].duration,
   b.concept_cki = temp->aqual[d1.seq].oqual[d2.seq].concept_cki, b.catalog_type_cd = temp->aqual[d1
   .seq].oqual[d2.seq].catalog_type_cd, b.activity_type_cd = temp->aqual[d1.seq].oqual[d2.seq].
   activity_type_cd,
   b.activity_subtype_cd = temp->aqual[d1.seq].oqual[d2.seq].activity_subtype_cd, b.updt_id = reqinfo
   ->updt_id, b.updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx =
   reqinfo->updt_applctx
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->aqual[d1.seq].oqual,5)
    AND (temp->aqual[d1.seq].oqual[d2.seq].appt_type_id > 0))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(serrmsg,"; Failed on br_sched_appt_type_ord insert.")
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ord_appt_types_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
