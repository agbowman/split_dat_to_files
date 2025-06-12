CREATE PROGRAM afc_reprocess_missing_orders:dba
 SET afc_reprocess_missing_orders_vrsn = "42414.006"
 EXECUTE crmrtl
 EXECUTE srvrtl
 EXECUTE cs_srv_declare_951060
 FREE SET reply
 RECORD reply(
   1 t01_qual = i2
   1 t01_recs[*]
     2 t01_id = f8
     2 t01_charge_item_id = f8
     2 t01_interfaced = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET nbr_back = cnvtint( $1)
 SET in_parm = cnvtreal( $2)
 CALL echo(build("days back: ",nbr_back," order_id: ",in_parm))
 IF (validate(reply->ops_event,"NOREPLY")="NOREPLY")
  FREE SET reply
  RECORD reply(
    1 t01_qual = i2
    1 t01_recs[*]
      2 t01_id = f8
      2 t01_charge_item_id = f8
      2 t01_interfaced = c1
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 ops_event = c100
  )
  RECORD request(
    1 ops_date = dq8
  )
  SET request->ops_date = cnvtdatetime(curdate,curtime)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE evnt_cnt = i4
 DECLARE chrg_cnt = i4
 DECLARE ret_msg = c100
 DECLARE the_dt = c11
 DECLARE appid = i4
 DECLARE taskid = i4
 DECLARE reqid = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hstep = i4
 DECLARE iret = i4
 DECLARE hevent = i4
 DECLARE srvstat = i4
 DECLARE hact = i4
 DECLARE hrcharges = i4
 DECLARE no_charges = i4
 DECLARE log_event = c25
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE ce_ordered = f8
 DECLARE ce_collected = f8
 DECLARE ce_complete = f8
 DECLARE ce_ord_cont = f8
 DECLARE ce_ord_cat_cont = f8
 DECLARE ce_inlab = f8
 SET codeset = 13029
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_ordered)
 CALL echo(build("the ORDERED code value is: ",ce_ordered))
 SET codeset = 13029
 SET cdf_meaning = "COLLECTED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_collected)
 CALL echo(build("the COLLECTED code value is: ",ce_collected))
 SET codeset = 13029
 SET cdf_meaning = "COMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_complete)
 CALL echo(build("the COMPLETE code value is: ",ce_complete))
 SET code_set = 13029
 SET cdf_meaning = "IN LAB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_inlab)
 CALL echo(build("the COMPLETE code value is: ",ce_inlab))
 SET o_id = 0.0
 SET test_mode = 0
 IF (in_parm != 0)
  SET test_mode = 1
  CALL log_message("test mode")
  SET o_id = in_parm
  CALL echo(o_id)
 ENDIF
 SET the_dt = format(datetimeadd(cnvtdatetime(request->ops_date),- ((1 * nbr_back))),"dd-mmm-yyyy;;d"
  )
 SET begdate = concat(the_dt," 00:00:00")
 SET enddate = concat(the_dt," 23:59:59")
 SET appid = 951020
 SET taskid = 951020
 SET stepid = 951060
 SET log_handle = 0
 SET log_status = 0
 SET log_level = 0
 SET log_event = "AFC_REPROCESS_MISSING_ORDERS"
 SET log_level = 2
 CALL log_createhandle(0)
 CALL log_message(concat("BEGIN RECOVERING MISSING ORDERS CHARGE EVENTS FOR ",the_dt))
 SET reply->ops_event = concat(begdate," TO ",enddate)
 RECORD orders(
   1 order_qual = i4
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 m_cs_order_id = f8
     2 cs_order_id = f8
     2 cs_catalog_cd = f8
     2 order_mnemonic = c25
     2 orig_order_dt_tm = dq8
     2 person_id = f8
     2 person_name = c25
     2 encntr_id = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c20
     2 accession = c18
     2 order_status_cd = f8
     2 ordered_flag = i2
     2 inlab_flag = i2
     2 collected_flag = i2
     2 completed_flag = i2
     2 charge_event_id = f8
     2 ce_ordered_flag = i2
     2 ce_collected_flag = i2
     2 ce_completed_flag = i2
     2 ce_inlab_flag = i2
     2 quantity = i4
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 service_resource_cd = f8
 )
 EXECUTE afc_get_missing_orders
 SET codeset = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_ord_cont)
 CALL echo(build("the order contributor code value is: ",ce_ord_cont))
 SET codeset = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_ord_cat_cont)
 CALL echo(build("the order cat contributor code value is: ",ce_ord_cat_cont))
 SET count = 0
 SET order_cnt = size(orders->orders,5)
 SET order_cnt_string = trim(cnvtstring(order_cnt),3)
 SET none_processed = 1
 SET num_orders = 0
 SET xord = 1
 CALL echorecord(orders,"ccluserdir:afc_rep_orders.dat")
 CALL call_server(0)
 IF (none_processed=1)
  SET reply->status_data.status = "Z"
 ENDIF
 SET ret_msg = concat("Orders: ",order_cnt_string," Charge Events: ",build(evnt_cnt)," Charges: ",
  build(chrg_cnt))
 FREE SET orders
 CALL call_server(1)
 CALL log_destroyhandle(0)
#endprog
 IF (happ != 0)
  IF (hstep != 0)
   CALL uar_crmendreq(hstep)
  ENDIF
  IF (htask != 0)
   CALL uar_crmendtask(htask)
  ENDIF
  CALL uar_crmendapp(happ)
 ENDIF
 SET reply->ops_event = ret_msg
 CALL log_message(ret_msg)
 CALL log_message(concat("FINISHED RECOVERING MISSING ORDERS CHARGE EVENTS FOR ",the_dt))
 SUBROUTINE call_server(isdone)
   IF (isdone=1)
    GO TO endprog
   ELSE
    IF (happ=0)
     SET iret = uar_crmbeginapp(appid,happ)
     IF (iret != 0)
      SET ret_msg = concat("Failure on uar_crmbeginapp: ",cnvtstring(iret))
      SET reply->status_data.status = "F"
      GO TO endprog
     ELSE
      CALL echo("uar_beginapp successful")
      SET iret = uar_crmbegintask(happ,taskid,htask)
      IF (iret != 0)
       SET ret_msg = concat("Failure on begin task: ",cnvtstring(iret))
       SET reply->status_data.status = "F"
       CALL uar_crmendapp(happ)
       GO TO endprog
      ELSE
       CALL echo("uar_crmbegintask successful")
      ENDIF
     ENDIF
    ENDIF
    IF (htask != 0)
     CALL echo("start while")
     CALL echo(build("value of order_cnt: ",order_cnt))
     WHILE (xord <= order_cnt)
       CALL echo(build("xOrd = ",xord))
       SET num_orders = 1
       IF (mod(xord,100)=0)
        CALL log_message(concat("checking order ",trim(cnvtstring(xord),3)," of ",order_cnt_string))
       ENDIF
       WHILE (num_orders <= 10)
         CALL echo(build("value of num_orders = ",num_orders))
         IF ((((orders->orders[xord].ce_completed_flag=0)
          AND (orders->orders[xord].completed_flag=1)) OR ((((orders->orders[xord].ce_ordered_flag=0)
          AND (orders->orders[xord].ordered_flag=1)) OR ((((orders->orders[xord].ce_collected_flag=0)
          AND (orders->orders[xord].collected_flag=1)) OR ((orders->orders[xord].ce_inlab_flag=0)
          AND (orders->orders[xord].inlab_flag=1))) )) )) )
          SET evnt_cnt = (evnt_cnt+ 1)
          SET count2 = 0
          CALL echo("calling uar_crmbeginreq")
          SET iret = uar_crmbeginreq(htask,"",stepid,hstep)
          IF (iret != 0)
           SET ret_msg = concat("Error on begin req: ",cnvtstring(iret))
           SET reply->status_data.status = "F"
           CALL uar_crmendtask(htask)
           CALL uar_crmendapp(happ)
           GO TO endprog
          ENDIF
          SET hreq = uar_crmgetrequest(hstep)
          SET srvstat = uar_srvsetshort(hreq,"charge_event_qual",num_orders)
          SET hevent = uar_srvadditem(hreq,"charge_event")
          CALL echo("inside MASTER")
          IF ((orders->orders[xord].cs_order_id != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_master_event_id",orders->orders[xord].
            cs_order_id)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_master_event_id",orders->orders[xord].order_id)
          ENDIF
          CALL echo("after ext_master_event_id")
          SET srvstat = uar_srvsetdouble(hevent,"ext_master_event_cont_cd",ce_ord_cont)
          CALL echo("after ext_master_event_cont_cd")
          IF ((orders->orders[xord].cs_catalog_cd != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_master_reference_id",orders->orders[xord].
            cs_catalog_cd)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_master_reference_id",orders->orders[xord].
            catalog_cd)
          ENDIF
          CALL echo("after ext_master_reference_id")
          SET srvstat = uar_srvsetdouble(hevent,"ext_master_reference_cont_cd",ce_ord_cat_cont)
          CALL echo("after ext_master_reference_cont_cd")
          CALL echo("inside PARENT")
          IF ((orders->orders[xord].cs_order_id != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_event_id",orders->orders[xord].
            cs_order_id)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_event_id",0.0)
          ENDIF
          IF ((orders->orders[xord].cs_order_id != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_event_cont_cd",ce_ord_cont)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_event_cont_cd",0.0)
          ENDIF
          IF ((orders->orders[xord].cs_order_id != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_reference_id",orders->orders[xord].
            cs_catalog_cd)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_reference_id",0.0)
          ENDIF
          IF ((orders->orders[xord].cs_order_id != 0))
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_reference_cont_cd",ce_ord_cat_cont)
          ELSE
           SET srvstat = uar_srvsetdouble(hevent,"ext_parent_reference_cont_cd",0.0)
          ENDIF
          CALL echo("inside ITEM")
          SET srvstat = uar_srvsetdouble(hevent,"ext_item_event_id",orders->orders[xord].order_id)
          SET order_id = orders->orders[xord].order_id
          SET srvstat = uar_srvsetdouble(hevent,"ext_item_event_cont_cd",ce_ord_cont)
          SET srvstat = uar_srvsetdouble(hevent,"ext_item_reference_id",orders->orders[xord].
           catalog_cd)
          SET srvstat = uar_srvsetdouble(hevent,"ext_item_reference_cont_cd",ce_ord_cat_cont)
          SET srvstat = uar_srvsetdouble(hevent,"order_id",orders->orders[xord].order_id)
          SET srvstat = uar_srvsetdouble(hevent,"person_id",orders->orders[xord].person_id)
          SET srvstat = uar_srvsetdouble(hevent,"encntr_id",orders->orders[xord].encntr_id)
          SET srvstat = uar_srvsetdouble(hevent,"accession",orders->orders[xord].accession)
          CALL echo("after accession")
          SET srvstat = uar_srvsetdouble(hevent,"reference_nbr",concat("OPSCHARGERECOVERY Date: ",
            format(request->ops_date,"dd-mmm-yyyy hh:mm:ss;;d")))
          CALL echo("after reference_nbr")
          IF ((orders->orders[xord].ce_ordered_flag=0)
           AND (orders->orders[xord].ordered_flag=1))
           SET count2 = (count2+ 1)
           SET hact = uar_srvadditem(hevent,"charge_event_act")
           SET srvstat = uar_srvsetdouble(hact,"charge_type_cd",0.0)
           SET srvstat = uar_srvsetdouble(hact,"cea_type_cd",ce_ordered)
           SET srvstat = uar_srvsetdouble(hact,"service_resource_cd",orders->orders[xord].
            service_resource_cd)
           SET srvstat = uar_srvsetdate(hact,"service_dt_tm",orders->orders[xord].orig_order_dt_tm)
          ENDIF
          CALL echo("first If inside ITEM")
          IF ((orders->orders[xord].ce_collected_flag=0)
           AND (orders->orders[xord].collected_flag=1))
           SET count2 = (count2+ 1)
           SET hact = uar_srvadditem(hevent,"charge_event_act")
           SET srvstat = uar_srvsetdouble(hact,"charge_type_cd",0.0)
           SET srvstat = uar_srvsetdouble(hact,"cea_type_cd",ce_collected)
           SET srvstat = uar_srvsetdouble(hact,"service_resource_cd",orders->orders[xord].
            service_resource_cd)
           SET srvstat = uar_srvsetdate(hact,"service_dt_tm",orders->orders[xord].orig_order_dt_tm)
          ENDIF
          CALL echo("second IF inside ITEM")
          IF ((orders->orders[xord].ce_completed_flag=0)
           AND (orders->orders[xord].completed_flag=1))
           SET count2 = (count2+ 1)
           SET hact = uar_srvadditem(hevent,"charge_event_act")
           SET srvstat = uar_srvsetdouble(hact,"charge_type_cd",0.0)
           SET srvstat = uar_srvsetdouble(hact,"cea_type_cd",ce_complete)
           SET srvstat = uar_srvsetdouble(hact,"service_resource_cd",orders->orders[xord].
            service_resource_cd)
           SET srvstat = uar_srvsetdate(hact,"service_dt_tm",orders->orders[xord].orig_order_dt_tm)
          ENDIF
          CALL echo("third IF inside ITEM")
          IF ((orders->orders[xord].ce_inlab_flag=0)
           AND (orders->orders[xord].inlab_flag=1))
           SET count2 = (count2+ 1)
           SET hact = uar_srvadditem(hevent,"charge_event_act")
           SET srvstat = uar_srvsetdouble(hact,"charge_type_cd",0.0)
           SET srvstat = uar_srvsetdouble(hact,"cea_type_cd",ce_inlab)
           SET srvstat = uar_srvsetdouble(hact,"service_resource_cd",orders->orders[xord].
            service_resource_cd)
           SET srvstat = uar_srvsetdate(hact,"service_dt_tm",orders->orders[xord].orig_order_dt_tm)
          ENDIF
          CALL echo("fourth IF inside ITEM")
          SET iret = uar_crmperform(hstep)
          IF (iret=0)
           CALL echo("Success, check reply")
           SET hrcharges = uar_crmgetreply(hstep)
           IF (hrcharges > 0)
            CALL echo("Reply Success")
            SET reply->status_data.status = "S"
           ELSE
            CALL echo("Reply Failure")
            SET reply->status_data.status = "F"
           ENDIF
           CALL echo(build("no_charges",no_charges))
           SET chrg_cnt = (chrg_cnt+ no_charges)
           CALL echo(build("charge_qual: ",no_charges," total: ",chrg_cnt))
           CALL uar_crmendreq(hreq)
           SET hreq = 0
           IF (hstep != 0)
            CALL uar_crmendreq(hstep)
           ENDIF
          ELSE
           CALL log_message("hReq is 0, ending program")
           GO TO endprog
          ENDIF
         ENDIF
         SET num_orders = (num_orders+ 1)
         SET xord = (xord+ 1)
         CALL echo("incrementing num_orders")
         IF ((xord=(order_cnt+ 1)))
          SET xord = (xord+ 1)
          SET num_orders = 11
         ENDIF
         CALL echo("doing xOrd = xOrd +1")
       ENDWHILE
       SET non_processed = 0
     ENDWHILE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE log_createhandle(dummy)
   CALL uar_syscreatehandle(log_handle,log_status)
 END ;Subroutine
 SUBROUTINE log_message(log_message_message)
  CALL echo(log_message_message)
  IF (log_handle != 0)
   CALL uar_sysevent(log_handle,log_level,log_event,nullterm(log_message_message))
  ENDIF
 END ;Subroutine
 SUBROUTINE log_destroyhandle(dummy)
   CALL uar_sysdestroyhandle(log_handle)
 END ;Subroutine
END GO
