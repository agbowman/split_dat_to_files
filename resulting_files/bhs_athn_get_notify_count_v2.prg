CREATE PROGRAM bhs_athn_get_notify_count_v2
 DECLARE consults_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"CONSULTS"))
 DECLARE documents_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"DOCUMENTS"))
 DECLARE messages_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"MESSAGES"))
 DECLARE notifies_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"NOTIFIES"))
 DECLARE orders_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"ORDERS"))
 DECLARE reminders_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"REMINDERS"))
 DECLARE results_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"RESULTS"))
 DECLARE saved_docs_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",3404,"SAVED_DOCS"))
 FREE RECORD result
 RECORD result(
   1 priority_items
     2 p_consults
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
       3 sub_categories[*]
         4 category_cd = f8
         4 category_disp = vc
         4 category_count = i4
         4 category_id = f8
         4 total_count = i4
     2 p_reminders
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
       3 sub_categories[*]
         4 category_cd = f8
         4 category_disp = vc
         4 category_count = i4
         4 category_id = f8
         4 total_count = i4
     2 p_messages
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
       3 sub_categories[*]
         4 category_cd = f8
         4 category_disp = vc
         4 category_count = i4
         4 category_id = f8
         4 total_count = i4
   1 consults
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 documents
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 messages
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 notifies
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 orders
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 reminders
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 results
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 saved_docs
     2 category_cd = f8
     2 category_disp = vc
     2 category_count = i4
     2 category_id = f8
     2 total_count = i4
     2 sub_categories[*]
       3 category_cd = f8
       3 category_disp = vc
       3 category_count = i4
       3 category_id = f8
       3 total_count = i4
   1 total
     2 category_count = i4
     2 total_count = i4
   1 status = c1
 ) WITH protect
 FREE RECORD req967510
 RECORD req967510(
   1 pool_id = f8
   1 provider_id = f8
   1 proxy_grantor_id = f8
   1 patient_id = f8
   1 event_set_exclude_cd_list[*]
   1 event_class_cd_list[*]
   1 encounter_type_cd_list[*]
   1 begin_date = dq8
   1 end_date = dq8
   1 category_list[*]
   1 normal_cd_list[*]
   1 abnormal_cd_list[*]
   1 critical_cd_list[*]
   1 status_cd_list[*]
     2 status_cd = f8
   1 retrieve_all_docs_and_msgs = i2
   1 suppress_unauth_docs = i2
   1 get_only_key_notifications = i2
   1 get_proxies = i2
   1 get_pools = i2
   1 application_number = i4
   1 event_set_include_cd_list[*]
   1 unassign_flag = i2
   1 filter_out_pool_items = i2
   1 load_patient_counts = i2
   1 suppress_saved_rte = i2
 ) WITH protect
 FREE RECORD rep967510
 RECORD rep967510(
   1 category_list[*]
     2 category
       3 notify_type_cd = f8
       3 category_cd = f8
       3 category_count = i4
       3 sub_category[*]
         4 category_cd = f8
         4 category_count = i4
         4 type_list[*]
           5 notification_type_cd = f8
           5 notification_type_count = i4
           5 total_count = i4
         4 category_id = f8
         4 category_name = vc
         4 normalcy_list[*]
           5 normalcy_cd = f8
         4 total_count = i4
       3 category_id = f8
       3 category_name = vc
       3 support_all_filters_ind = i2
       3 total_count = i4
   1 proxy_list[*]
   1 pool_list[*]
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 msg_config_id = f8
   1 begin_date = dq8
   1 end_date = dq8
   1 msg_config_updt_cnt = i4
   1 patient_list[*]
 ) WITH protect
 DECLARE callgetnotificationcount(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status = "F"
 IF (( $2 <= 0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetnotificationcount(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status = "S"
#exit_script
 CALL echorecord(result)
 SET _memory_reply_string = cnvtrectojson(result)
 FREE RECORD result
 FREE RECORD req967510
 FREE RECORD rep967510
 SUBROUTINE callgetnotificationcount(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967510)
   DECLARE c_onhold_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"ONHOLD"))
   DECLARE c_opened_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OPENED"))
   DECLARE c_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE catcnt = i4 WITH protect, noconstant(0)
   DECLARE scatcnt = i4 WITH protect, noconstant(0)
   IF (( $5 > 0))
    SET req967510->pool_id =  $5
   ELSE
    SET req967510->provider_id =  $2
   ENDIF
   IF (( $3 > " "))
    SET req967510->begin_date = cnvtdatetime( $3)
    SET req967510->end_date = cnvtdatetime( $4)
   ENDIF
   SET stat = alterlist(req967510->status_cd_list,3)
   SET req967510->status_cd_list[1].status_cd = c_onhold_cd
   SET req967510->status_cd_list[2].status_cd = c_opened_cd
   SET req967510->status_cd_list[3].status_cd = c_pending_cd
   SET req967510->suppress_unauth_docs = 0
   SET req967510->application_number = 600005
   SET req967510->load_patient_counts = 1
   CALL echorecord(req967510)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967510,
    "REC",rep967510,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967510)
   IF ((rep967510->status_data.status != "F"))
    FOR (idx = 1 TO size(rep967510->category_list,5))
      IF ((rep967510->category_list[idx].category.category_count >= 0)
       AND (rep967510->category_list[idx].category.notify_type_cd=0))
       SET catcnt += 1
       SET result->total.total_count += rep967510->category_list[idx].category.total_count
       SET result->total.category_count += rep967510->category_list[idx].category.category_count
       IF ((rep967510->category_list[idx].category.category_cd=consults_cd))
        SET result->consults.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->consults.category_disp = uar_get_code_display(result->consults.category_cd)
        SET result->consults.category_count = rep967510->category_list[idx].category.category_count
        SET result->consults.category_id = rep967510->category_list[idx].category.category_id
        SET result->consults.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->consults.sub_categories,scatcnt)
           SET result->consults.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->consults.sub_categories[scatcnt].category_disp = uar_get_code_display(result->
            consults.sub_categories[scatcnt].category_cd)
           SET result->consults.sub_categories[scatcnt].category_count = rep967510->category_list[idx
           ].category.sub_category[jdx].category_count
           SET result->consults.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->consults.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=documents_cd))
        SET result->documents.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->documents.category_disp = uar_get_code_display(result->documents.category_cd)
        SET result->documents.category_count = rep967510->category_list[idx].category.category_count
        SET result->documents.category_id = rep967510->category_list[idx].category.category_id
        SET result->documents.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->documents.sub_categories,scatcnt)
           SET result->documents.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->documents.sub_categories[scatcnt].category_disp = uar_get_code_display(result
            ->documents.sub_categories[scatcnt].category_cd)
           SET result->documents.sub_categories[scatcnt].category_count = rep967510->category_list[
           idx].category.sub_category[jdx].category_count
           SET result->documents.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->documents.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=messages_cd))
        SET result->messages.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->messages.category_disp = uar_get_code_display(result->messages.category_cd)
        SET result->messages.category_count = rep967510->category_list[idx].category.category_count
        SET result->messages.category_id = rep967510->category_list[idx].category.category_id
        SET result->messages.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->messages.sub_categories,scatcnt)
           SET result->messages.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->messages.sub_categories[scatcnt].category_disp = uar_get_code_display(result->
            messages.sub_categories[scatcnt].category_cd)
           SET result->messages.sub_categories[scatcnt].category_count = rep967510->category_list[idx
           ].category.sub_category[jdx].category_count
           SET result->messages.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->messages.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=notifies_cd))
        SET result->notifies.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->notifies.category_disp = uar_get_code_display(result->notifies.category_cd)
        SET result->notifies.category_count = rep967510->category_list[idx].category.category_count
        SET result->notifies.category_id = rep967510->category_list[idx].category.category_id
        SET result->notifies.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->notifies.sub_categories,scatcnt)
           SET result->notifies.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->notifies.sub_categories[scatcnt].category_disp = uar_get_code_display(result->
            notifies.sub_categories[scatcnt].category_cd)
           SET result->notifies.sub_categories[scatcnt].category_count = rep967510->category_list[idx
           ].category.sub_category[jdx].category_count
           SET result->notifies.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->notifies.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=orders_cd))
        SET result->orders.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->orders.category_disp = uar_get_code_display(result->orders.category_cd)
        SET result->orders.category_count = rep967510->category_list[idx].category.category_count
        SET result->orders.category_id = rep967510->category_list[idx].category.category_id
        SET result->orders.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->orders.sub_categories,scatcnt)
           SET result->orders.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->orders.sub_categories[scatcnt].category_disp = uar_get_code_display(result->
            orders.sub_categories[scatcnt].category_cd)
           SET result->orders.sub_categories[scatcnt].category_count = rep967510->category_list[idx].
           category.sub_category[jdx].category_count
           SET result->orders.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->orders.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=reminders_cd))
        SET result->reminders.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->reminders.category_disp = uar_get_code_display(result->reminders.category_cd)
        SET result->reminders.category_count = rep967510->category_list[idx].category.category_count
        SET result->reminders.category_id = rep967510->category_list[idx].category.category_id
        SET result->reminders.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->reminders.sub_categories,scatcnt)
           SET result->reminders.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->reminders.sub_categories[scatcnt].category_disp = uar_get_code_display(result
            ->reminders.sub_categories[scatcnt].category_cd)
           SET result->reminders.sub_categories[scatcnt].category_count = rep967510->category_list[
           idx].category.sub_category[jdx].category_count
           SET result->reminders.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->reminders.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=results_cd))
        SET result->results.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->results.category_disp = uar_get_code_display(result->results.category_cd)
        SET result->results.category_count = rep967510->category_list[idx].category.category_count
        SET result->results.category_id = rep967510->category_list[idx].category.category_id
        SET result->results.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->results.sub_categories,scatcnt)
           SET result->results.sub_categories[scatcnt].category_cd = rep967510->category_list[idx].
           category.sub_category[jdx].category_cd
           SET result->results.sub_categories[scatcnt].category_disp = uar_get_code_display(result->
            results.sub_categories[scatcnt].category_cd)
           SET result->results.sub_categories[scatcnt].category_count = rep967510->category_list[idx]
           .category.sub_category[jdx].category_count
           SET result->results.sub_categories[scatcnt].category_id = rep967510->category_list[idx].
           category.sub_category[jdx].category_id
           SET result->results.sub_categories[scatcnt].total_count = rep967510->category_list[idx].
           category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=saved_docs_cd))
        SET result->saved_docs.category_cd = rep967510->category_list[idx].category.category_cd
        SET result->saved_docs.category_disp = uar_get_code_display(result->saved_docs.category_cd)
        SET result->saved_docs.category_count = rep967510->category_list[idx].category.category_count
        SET result->saved_docs.category_id = rep967510->category_list[idx].category.category_id
        SET result->saved_docs.total_count = rep967510->category_list[idx].category.total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->saved_docs.sub_categories,scatcnt)
           SET result->saved_docs.sub_categories[scatcnt].category_cd = rep967510->category_list[idx]
           .category.sub_category[jdx].category_cd
           SET result->saved_docs.sub_categories[scatcnt].category_disp = uar_get_code_display(result
            ->saved_docs.sub_categories[scatcnt].category_cd)
           SET result->saved_docs.sub_categories[scatcnt].category_count = rep967510->category_list[
           idx].category.sub_category[jdx].category_count
           SET result->saved_docs.sub_categories[scatcnt].category_id = rep967510->category_list[idx]
           .category.sub_category[jdx].category_id
           SET result->saved_docs.sub_categories[scatcnt].total_count = rep967510->category_list[idx]
           .category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
      ELSEIF ((rep967510->category_list[idx].category.category_count >= 0)
       AND (rep967510->category_list[idx].category.notify_type_cd=180235390))
       SET result->total.total_count += rep967510->category_list[idx].category.total_count
       SET result->total.category_count += rep967510->category_list[idx].category.category_count
       IF ((rep967510->category_list[idx].category.category_cd=messages_cd))
        SET result->priority_items.p_messages.category_cd = rep967510->category_list[idx].category.
        category_cd
        SET result->priority_items.p_messages.category_disp = uar_get_code_display(result->
         priority_items.p_messages.category_cd)
        SET result->priority_items.p_messages.category_count = rep967510->category_list[idx].category
        .category_count
        SET result->priority_items.p_messages.category_id = rep967510->category_list[idx].category.
        category_id
        SET result->priority_items.p_messages.total_count = rep967510->category_list[idx].category.
        total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->priority_items.p_messages.sub_categories,scatcnt)
           SET result->priority_items.p_messages.sub_categories[scatcnt].category_cd = rep967510->
           category_list[idx].category.sub_category[jdx].category_cd
           SET result->priority_items.p_messages.sub_categories[scatcnt].category_disp =
           uar_get_code_display(result->priority_items.p_messages.sub_categories[scatcnt].category_cd
            )
           SET result->priority_items.p_messages.sub_categories[scatcnt].category_count = rep967510->
           category_list[idx].category.sub_category[jdx].category_count
           SET result->priority_items.p_messages.sub_categories[scatcnt].category_id = rep967510->
           category_list[idx].category.sub_category[jdx].category_id
           SET result->priority_items.p_messages.sub_categories[scatcnt].total_count = rep967510->
           category_list[idx].category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=consults_cd))
        SET result->priority_items.p_consults.category_cd = rep967510->category_list[idx].category.
        category_cd
        SET result->priority_items.p_consults.category_disp = uar_get_code_display(result->
         priority_items.p_consults.category_cd)
        SET result->priority_items.p_consults.category_count = rep967510->category_list[idx].category
        .category_count
        SET result->priority_items.p_consults.category_id = rep967510->category_list[idx].category.
        category_id
        SET result->priority_items.p_consults.total_count = rep967510->category_list[idx].category.
        total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->priority_items.p_consults.sub_categories,scatcnt)
           SET result->priority_items.p_consults.sub_categories[scatcnt].category_cd = rep967510->
           category_list[idx].category.sub_category[jdx].category_cd
           SET result->priority_items.p_consults.sub_categories[scatcnt].category_disp =
           uar_get_code_display(result->priority_items.p_consults.sub_categories[scatcnt].category_cd
            )
           SET result->priority_items.p_consults.sub_categories[scatcnt].category_count = rep967510->
           category_list[idx].category.sub_category[jdx].category_count
           SET result->priority_items.p_consults.sub_categories[scatcnt].category_id = rep967510->
           category_list[idx].category.sub_category[jdx].category_id
           SET result->priority_items.p_consults.sub_categories[scatcnt].total_count = rep967510->
           category_list[idx].category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
       IF ((rep967510->category_list[idx].category.category_cd=reminders_cd))
        SET result->priority_items.p_reminders.category_cd = rep967510->category_list[idx].category.
        category_cd
        SET result->priority_items.p_reminders.category_disp = uar_get_code_display(result->
         priority_items.p_reminders.category_cd)
        SET result->priority_items.p_reminders.category_count = rep967510->category_list[idx].
        category.category_count
        SET result->priority_items.p_reminders.category_id = rep967510->category_list[idx].category.
        category_id
        SET result->priority_items.p_reminders.total_count = rep967510->category_list[idx].category.
        total_count
        SET scatcnt = 0
        FOR (jdx = 1 TO size(rep967510->category_list[idx].category.sub_category,5))
          IF ((rep967510->category_list[idx].category.sub_category[jdx].category_count >= 0))
           SET scatcnt += 1
           SET stat = alterlist(result->priority_items.p_reminders.sub_categories,scatcnt)
           SET result->priority_items.p_reminders.sub_categories[scatcnt].category_cd = rep967510->
           category_list[idx].category.sub_category[jdx].category_cd
           SET result->priority_items.p_reminders.sub_categories[scatcnt].category_disp =
           uar_get_code_display(result->priority_items.p_reminders.sub_categories[scatcnt].
            category_cd)
           SET result->priority_items.p_reminders.sub_categories[scatcnt].category_count = rep967510
           ->category_list[idx].category.sub_category[jdx].category_count
           SET result->priority_items.p_reminders.sub_categories[scatcnt].category_id = rep967510->
           category_list[idx].category.sub_category[jdx].category_id
           SET result->priority_items.p_reminders.sub_categories[scatcnt].total_count = rep967510->
           category_list[idx].category.sub_category[jdx].total_count
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
