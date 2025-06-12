CREATE PROGRAM aps_chg_accession_order_r:dba
 DECLARE activity_type_cd = f8 WITH noconstant(0.0)
 DECLARE julian_accession_id = f8 WITH noconstant(0.0)
 IF ((((accession_order->order_id <= 0.0)) OR ((((accession_order->accession_id <= 0.0)) OR (textlen(
  trim(accession_order->accession)) < 18)) )) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  a.accession_id
  FROM accession_order_r a
  WHERE (accession_order->order_id=a.order_id)
   AND a.primary_flag=0
  DETAIL
   julian_accession_id = a.accession_id, activity_type_cd = a.activity_type_cd
  WITH nocounter
 ;end select
 IF (julian_accession_id != 0.0)
  UPDATE  FROM accession_order_r a
   SET a.primary_flag = 1, a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx
   WHERE (accession_order->order_id=a.order_id)
    AND julian_accession_id=a.accession_id
   WITH nocounter
  ;end update
  IF (curqual != 0)
   INSERT  FROM accession_order_r a
    SET a.order_id = accession_order->order_id, a.accession_id = accession_order->accession_id, a
     .accession = accession_order->accession,
     a.primary_flag = 0, a.activity_type_cd = activity_type_cd, a.primary_ind = 0,
     a.restrict_av_ind = 0, a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 ENDIF
#exit_script
END GO
