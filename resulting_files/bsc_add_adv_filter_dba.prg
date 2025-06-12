CREATE PROGRAM bsc_add_adv_filter:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE fdcompid = i4 WITH protect, noconstant(0)
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE item_size = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  num = seq(medadmin_seq,nextval)
  FROM dual
  DETAIL
   fdcompid = num
  WITH nocounter
 ;end select
 INSERT  FROM comp_filter_group cfg
  SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = request->person_id, cfg.filter_name =
   request->filter_name,
   cfg.component_cd = request->component_cd, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo
   ->updt_task,
   cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat(
   "Insertion error on comp_filter_group - ",errmsg)
  GO TO exit_script
 ENDIF
 SET item_size = size(request->filter_items,5)
 FOR (item_cnt = 1 TO item_size)
   INSERT  FROM comp_filter_group_item cfgi
    SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
     fdcompid, cfgi.component_filter_type_cd = request->filter_items[item_cnt].
     component_filter_type_cd,
     cfgi.filter_item_value_txt = request->filter_items[item_cnt].filter_item_value, cfgi.updt_id =
     reqinfo->updt_id, cfgi.updt_task = reqinfo->updt_task,
     cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
      curdate,curtime3)
    WITH nocounter
   ;end insert
 ENDFOR
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat(
   "Insertion error on comp_filter_group_item - ",errmsg)
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET last_mod = "002"
 SET mod_date = "10/25/2011"
 SET modify = nopredeclare
END GO
