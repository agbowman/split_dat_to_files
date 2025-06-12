CREATE PROGRAM bsc_load_adv_filters:dba
 SET modify = predeclare
 RECORD reply(
   1 filter_qual[*]
     2 filter_name = vc
     2 filter_person_id = f8
     2 filter_items[*]
       3 component_filter_type_cd = f8
       3 filter_item_value = vc
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
 DECLARE groupcnt = i4 WITH protect, noconstant(0)
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE dstatus = i2 WITH private, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ELSE
  SET debug_ind = 0
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg,
   comp_filter_group_item cfgi
  PLAN (cfg
   WHERE (cfg.component_cd=request->component_cd)
    AND cfg.person_id IN (request->person_id, 0))
   JOIN (cfgi
   WHERE cfgi.comp_filter_group_id=cfg.comp_filter_group_id)
  ORDER BY cfg.comp_filter_group_id, cfgi.comp_filter_group_item_id
  HEAD cfg.comp_filter_group_id
   groupcnt = (groupcnt+ 1), itemcnt = 0, dstat = alterlist(reply->filter_qual,groupcnt),
   reply->filter_qual[groupcnt].filter_name = cfg.filter_name, reply->filter_qual[groupcnt].
   filter_person_id = cfg.person_id
   IF (debug_ind > 0)
    CALL echo(build("cfg.filter_name: ",cfg.filter_name))
   ENDIF
  HEAD cfgi.comp_filter_group_item_id
   itemcnt = (itemcnt+ 1), dstat = alterlist(reply->filter_qual[groupcnt].filter_items,itemcnt),
   reply->filter_qual[groupcnt].filter_items[itemcnt].component_filter_type_cd = cfgi
   .component_filter_type_cd,
   reply->filter_qual[groupcnt].filter_items[itemcnt].filter_item_value = cfgi.filter_item_value_txt
   IF (debug_ind > 0)
    CALL echo(build("cfgi.component_filter_type_cd: ",cfgi.component_filter_type_cd)),
    CALL echo(build("cfgi.filter_item_value_txt: ",cfgi.filter_item_value_txt))
   ENDIF
  WITH nocounter
 ;end select
 IF (debug_ind > 0)
  CALL echorecord(reply)
 ENDIF
#exit_script
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->filter_qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "08/08/2007"
 SET modify = nopredeclare
END GO
