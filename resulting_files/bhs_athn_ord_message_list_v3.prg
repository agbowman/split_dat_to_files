CREATE PROGRAM bhs_athn_ord_message_list_v3
 RECORD orequest(
   1 anchor_dt_tm = dq8
   1 prsnl_knt = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 flag_knt = i4
     2 flag[*]
       3 flag_type = i4
 )
 RECORD prequest(
   1 receiver
     2 provider_id = f8
     2 pool_id = f8
   1 patient_id = f8
   1 status_codes[*]
     2 status_cd = f8
   1 date_range
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
   1 configuration
     2 msg_category_config_id = f8
     2 msg_subcategory_config_id = f8
     2 application_number = i4
     2 config_id = f8
   1 load
     2 names_ind = i2
     2 only_unassigned_pool_items_ind = i2
     2 filter_out_pool_items = i2
     2 location_information = i2
   1 action_prsnl_id = f8
 )
 RECORD out_rec(
   1 orders[*]
     2 prsnl_id = vc
     2 order_id = vc
     2 ord_notification_id = vc
     2 templateorderid = vc
     2 person_id = vc
     2 encounter_id = vc
     2 patientname = vc
     2 orderdescription = vc
     2 orderdetail = vc
     2 originatorid = vc
     2 originatorname = vc
     2 createddate = vc
     2 updatedate = vc
     2 orderstatus = vc
     2 stopdate = vc
     2 stopreason = vc
     2 actiontype = vc
     2 summarytype = vc
     2 prsnl_group_id = vc
     2 prsnl_group_name = vc
     2 proxy_prsnl_id = vc
     2 proxy_prsnl_name = vc
     2 catalogtypecode = vc
     2 actionsequence = vc
     2 notificationtype = vc
 )
 DECLARE orders_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",3404,"ORDERS"))
 DECLARE p_cnt = i4
 DECLARE n_cnt = i4
 DECLARE date_line = vc
 DECLARE time_line = vc
 DECLARE pg_name = vc
 IF (( $3=1))
  GO TO pools
 ENDIF
 IF (( $3=2))
  SELECT INTO "nl:"
   FROM proxy p
   PLAN (p
    WHERE (p.person_id= $2)
     AND p.msg_category_id=orders_cd)
   ORDER BY p.proxy_person_id
   HEAD p.proxy_person_id
    p_cnt += 1, stat = alterlist(orequest->prsnl,p_cnt), orequest->prsnl[p_cnt].prsnl_id = p
    .proxy_person_id,
    orequest->prsnl[p_cnt].flag_knt = 5, stat = alterlist(orequest->prsnl[1].flag,5), orequest->
    prsnl[p_cnt].flag[1].flag_type = 1,
    orequest->prsnl[p_cnt].flag[2].flag_type = 2, orequest->prsnl[p_cnt].flag[3].flag_type = 3,
    orequest->prsnl[p_cnt].flag[4].flag_type = 4,
    orequest->prsnl[p_cnt].flag[5].flag_type = 5
   WITH nocounter, time = 30
  ;end select
 ENDIF
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET orequest->anchor_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 IF (( $3=3))
  GO TO pools
 ENDIF
 SET stat = tdbexecute(600005,3202004,967300,"REC",orequest,
  "REC",oreply)
 FOR (i = 1 TO oreply->prsnl_knt)
   FOR (j = 1 TO oreply->prsnl[i].notification_knt)
     SET n_cnt += 1
     SET stat = alterlist(out_rec->orders,n_cnt)
     IF (( $3=2))
      SET out_rec->orders[n_cnt].proxy_prsnl_id = cnvtstring(oreply->prsnl[i].prsnl_id)
      SELECT INTO "nl:"
       FROM prsnl pr
       PLAN (pr
        WHERE (pr.person_id=oreply->prsnl[i].prsnl_id))
       HEAD REPORT
        out_rec->orders[n_cnt].proxy_prsnl_name = pr.name_full_formatted
       WITH nocounter, time = 30
      ;end select
     ENDIF
     SET out_rec->orders[n_cnt].order_id = cnvtstring(oreply->prsnl[i].notification[j].order_id)
     SET out_rec->orders[n_cnt].ord_notification_id = cnvtstring(oreply->prsnl[i].notification[j].
      order_notification_id)
     SET out_rec->orders[n_cnt].person_id = cnvtstring(oreply->prsnl[i].notification[j].person_id)
     SET out_rec->orders[n_cnt].encounter_id = cnvtstring(oreply->prsnl[i].notification[j].encntr_id)
     SET out_rec->orders[n_cnt].patientname = oreply->prsnl[i].notification[j].person_name
     SET out_rec->orders[n_cnt].orderdescription = oreply->prsnl[i].notification[j].
     hna_order_mnemonic
     SET out_rec->orders[n_cnt].orderdetail = oreply->prsnl[i].notification[j].clinical_display_line
     SET out_rec->orders[n_cnt].originatorid = cnvtstring(oreply->prsnl[i].notification[j].
      originator_id)
     SET out_rec->orders[n_cnt].originatorname = oreply->prsnl[i].notification[j].originator_name
     SET out_rec->orders[n_cnt].createddate = format(oreply->prsnl[i].notification[j].
      notification_dt_tm,"mm/dd/yyyy hh:mm;;q")
     SET out_rec->orders[n_cnt].orderstatus = uar_get_code_display(oreply->prsnl[i].notification[j].
      order_status_cd)
     SET out_rec->orders[n_cnt].stopdate = format(oreply->prsnl[i].notification[j].
      projected_stop_dt_tm,"mm/dd/yyyy hh:mm;;q")
     SET out_rec->orders[n_cnt].stopreason = uar_get_code_display(oreply->prsnl[i].notification[j].
      stop_type_cd)
     IF (( $3=1))
      SET out_rec->orders[n_cnt].summarytype = "InBox"
     ELSEIF (( $3=2))
      SET out_rec->orders[n_cnt].summarytype = "Proxy"
     ENDIF
     SET out_rec->orders[n_cnt].catalogtypecode = cnvtstring(oreply->prsnl[i].notification[j].
      catalog_type_cd)
     SET out_rec->orders[n_cnt].actionsequence = cnvtstring(oreply->prsnl[i].notification[j].
      action_sequence)
     SET out_rec->orders[n_cnt].notificationtype = cnvtstring(oreply->prsnl[i].notification[j].
      notification_type_flag)
     SELECT INTO "nl:"
      FROM order_notification onot,
       orders o
      PLAN (onot
       WHERE (onot.order_notification_id=oreply->prsnl[i].notification[j].order_notification_id))
       JOIN (o
       WHERE o.order_id=onot.order_id)
      HEAD REPORT
       out_rec->orders[n_cnt].prsnl_id = cnvtstring(onot.to_prsnl_id), out_rec->orders[n_cnt].
       prsnl_group_id = cnvtstring(onot.to_prsnl_group_id), out_rec->orders[n_cnt].templateorderid =
       cnvtstring(o.template_order_id),
       out_rec->orders[n_cnt].updatedate = format(onot.updt_dt_tm,"mm/dd/yyyy hh:mm;;q")
       IF (onot.notification_type_flag=1)
        out_rec->orders[n_cnt].actiontype = "Renew"
       ELSEIF (onot.notification_type_flag=2)
        out_rec->orders[n_cnt].actiontype = "Cosign"
       ELSEIF (onot.notification_type_flag=3)
        out_rec->orders[n_cnt].actiontype = "Med student"
       ELSEIF (onot.notification_type_flag=4)
        out_rec->orders[n_cnt].actiontype = "Incomplete Order"
       ELSEIF (onot.notification_type_flag=5)
        out_rec->orders[n_cnt].actiontype = "Refusal"
       ENDIF
      WITH nocounter, time = 30
     ;end select
   ENDFOR
 ENDFOR
 GO TO end_script
#pools
 IF (( $3=3))
  SET prequest->receiver[1].pool_id =  $2
  SELECT INTO "nl:"
   FROM msg_config mc
   PLAN (mc
    WHERE (mc.prsnl_group_id= $2))
   HEAD mc.msg_config_id
    prequest->configuration[1].config_id = mc.msg_config_id
   WITH nocounter, time = 30
  ;end select
  SET prequest->configuration[1].msg_category_config_id =  $6
  SET prequest->configuration[1].msg_subcategory_config_id =  $7
 ELSE
  SET prequest->receiver[1].provider_id =  $2
  SELECT INTO "nl:"
   FROM msg_config mc
   PLAN (mc
    WHERE (((mc.prsnl_id= $2)) OR ((mc.position_cd=
    (SELECT
     pr.position_cd
     FROM prsnl pr
     WHERE (pr.person_id= $2))))) )
   HEAD mc.msg_config_id
    prequest->configuration[1].config_id = mc.msg_config_id
   WITH nocounter, time = 30
  ;end select
  SET prequest->configuration[1].msg_category_config_id =  $6
  SET prequest->configuration[1].msg_subcategory_config_id =  $7
 ENDIF
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET prequest->date_range[1].begin_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,
  "HH;mm;ss",0)
 SET stat = tdbexecute(600005,3202004,967706,"REC",prequest,
  "REC",preply)
 IF (( $3=2))
  SELECT INTO "nl:"
   FROM prsnl_group pg
   PLAN (pg
    WHERE (pg.prsnl_group_id= $2)
     AND pg.active_ind=1)
   HEAD REPORT
    pg_name = pg.prsnl_group_name
   WITH nocounter, time = 30
  ;end select
 ENDIF
 FOR (i = 1 TO size(preply->orders,5))
   SET n_cnt += 1
   SET stat = alterlist(out_rec->orders,n_cnt)
   IF (( $3=1))
    SET out_rec->orders[n_cnt].prsnl_id = cnvtstring( $2)
   ELSE
    SET out_rec->orders[n_cnt].prsnl_group_id = cnvtstring( $2)
    SET out_rec->orders[n_cnt].prsnl_group_name = pg_name
   ENDIF
   SET out_rec->orders[n_cnt].order_id = cnvtstring(preply->orders[i].order_id)
   SET out_rec->orders[n_cnt].ord_notification_id = cnvtstring(preply->orders[i].
    order_notification_id)
   SET out_rec->orders[n_cnt].person_id = cnvtstring(preply->orders[i].person_id)
   SET out_rec->orders[n_cnt].encounter_id = cnvtstring(preply->orders[i].encounter_id)
   SET out_rec->orders[n_cnt].orderdescription = preply->orders[i].hna_order_mnemonic
   SET out_rec->orders[n_cnt].orderdetail = preply->orders[i].detail_display
   SET out_rec->orders[n_cnt].originatorid = cnvtstring(preply->orders[i].originator_id)
   SET out_rec->orders[n_cnt].createddate = format(preply->orders[i].creation_dt_tm,
    "mm/dd/yyyy hh:mm;;q")
   SET out_rec->orders[n_cnt].orderstatus = uar_get_code_display(preply->orders[i].task_status_cd)
   SET out_rec->orders[n_cnt].stopdate = format(preply->orders[i].stop_dt_tm,"mm/dd/yyyy hh:mm;;q")
   SET out_rec->orders[n_cnt].stopreason = uar_get_code_display(preply->orders[i].stop_type_cd)
   IF (( $3=1))
    SET out_rec->orders[n_cnt].summarytype = "InBox"
   ELSE
    SET out_rec->orders[n_cnt].summarytype = "Pools"
   ENDIF
   SET out_rec->orders[n_cnt].updatedate = format(preply->orders[i].updated_dt_tm,
    "mm/dd/yyyy hh:mm;;q")
   SELECT INTO "nl:"
    FROM order_notification onot,
     orders o,
     person p
    PLAN (onot
     WHERE (onot.order_notification_id=preply->orders[i].order_notification_id))
     JOIN (o
     WHERE o.order_id=onot.order_id)
     JOIN (p
     WHERE p.person_id=o.person_id)
    HEAD REPORT
     out_rec->orders[n_cnt].patientname = p.name_full_formatted, out_rec->orders[n_cnt].
     templateorderid = cnvtstring(o.template_order_id), out_rec->orders[n_cnt].catalogtypecode =
     cnvtstring(o.catalog_type_cd),
     out_rec->orders[n_cnt].actionsequence = cnvtstring(o.last_action_sequence), out_rec->orders[
     n_cnt].notificationtype = cnvtstring(onot.notification_type_flag)
     IF (onot.notification_type_flag=1)
      out_rec->orders[n_cnt].actiontype = "Renew"
     ELSEIF (onot.notification_type_flag=2)
      out_rec->orders[n_cnt].actiontype = "Cosign"
     ELSEIF (onot.notification_type_flag=3)
      out_rec->orders[n_cnt].actiontype = "Med student"
     ELSEIF (onot.notification_type_flag=4)
      out_rec->orders[n_cnt].actiontype = "Incomplete Order"
     ELSEIF (onot.notification_type_flag=5)
      out_rec->orders[n_cnt].actiontype = "Refusal"
     ENDIF
    WITH nocounter, time = 30
   ;end select
   SELECT INTO "nl:"
    FROM prsnl pr
    PLAN (pr
     WHERE (pr.person_id=preply->orders[i].originator_id))
    HEAD REPORT
     out_rec->orders[n_cnt].originatorname = pr.name_full_formatted
    WITH nocounter, time = 30
   ;end select
 ENDFOR
#end_script
 SET _memory_reply_string = cnvtrectojson(out_rec)
 FREE RECORD out_rec
END GO
