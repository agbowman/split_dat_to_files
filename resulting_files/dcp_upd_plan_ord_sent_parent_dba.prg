CREATE PROGRAM dcp_upd_plan_ord_sent_parent:dba
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
 SET readme_data->message = "FAIL: dcp_upd_plan_ord_sent_parent failed"
 DECLARE curminid = f8 WITH protect, noconstant(0.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE batchsize = i4 WITH protect, noconstant(250000)
 DECLARE errormessage = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  minid = min(os.order_sentence_id)
  FROM order_sentence os
  WHERE os.order_sentence_id > 0
  DETAIL
   curminid = maxval(1.0,minid)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tablemaxid = max(os.order_sentence_id)
  FROM order_sentence os
  DETAIL
   maxid = tablemaxid
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ batchsize)
 WHILE (curminid <= maxid)
   UPDATE  FROM order_sentence o
    SET o.parent_entity2_name = "ORDER_CATALOG_SYNONYM", o.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ), o.updt_id = 0,
     o.updt_task = reqinfo->updt_task, o.updt_cnt = (o.updt_cnt+ 1), o.updt_applctx = 0
    WHERE o.order_sentence_id BETWEEN curminid AND curmaxid
     AND o.parent_entity_name="PATHWAY_COMP"
     AND o.parent_entity2_name IN ("CS_COMP", "CS_COMPONENT", "ORDER_CATALOGY_SYNONYM")
    WITH nocounter
   ;end update
   IF (error(errormessage,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "FAIL: dcp_upd_plan_ord_sent_parent failed update. Error Message: ",errormessage)
    ROLLBACK
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET curminid = (curmaxid+ 1)
   SET curmaxid = (curminid+ batchsize)
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Readme 3603 completed successfully"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
