CREATE PROGRAM bhs_eks_covid_res_chg3:dba
 RECORD m_rec(
   1 ord_qual[*]
     2 f_order_id = f8
   1 ce_qual[*]
     2 f_clinical_event_id = f8
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE mf_person_id = f8 WITH protect, constant(trigger_personid)
 DECLARE ms_module = vc WITH protect, constant(trim(eks_common->cur_module_name,3))
 DECLARE mn_result_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_order_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_covid_unit_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx4 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_lookbackdays = f8 WITH protect, noconstant(0)
 DECLARE mf_order_id = f8 WITH protect, noconstant(0)
 DECLARE mf_result_log_id = f8 WITH protect, noconstant(0)
 DECLARE mf_order_log_id = f8 WITH protect, noconstant(0)
 DECLARE mf_last_result_dt = f8 WITH protect, noconstant(0)
 DECLARE ms_result = vc WITH protect, noconstant("")
 DECLARE ms_mnemonic = vc WITH protect, noconstant("")
 IF (validate(retval)=0)
  DECLARE retval = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(log_message)=0)
  DECLARE log_message = vc WITH public, noconstant("")
 ENDIF
 IF (validate(log_misc1)=0)
  DECLARE log_misc1 = vc WITH public, noconstant("")
 ENDIF
 SET ml_idx = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"COVID19ORD",cnvtupper(trim(
    eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 SET ml_idx2 = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"COVID19RESULT",cnvtupper(
   trim(eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 SET ml_idx3 = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"COVIDUNIT",cnvtupper(trim(
    eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 SET ml_idx4 = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"LOOKBACKDAYS",cnvtupper(
   trim(eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 SET mf_lookbackdays = cnvtreal(eksdata->tqual[tcurindex].qual[ml_idx4].data[1].misc)
 IF ((eksdata->tqual[tcurindex].qual[ml_idx3].logging="*Location Nurse Unit is listed*"))
  SET mn_covid_unit_ind = 1
 ELSE
  SET mn_covid_unit_ind = 0
 ENDIF
 SET log_misc1 = ""
 SET ml_cnt = 0
 IF (ml_idx > 0)
  FOR (ml_loop = 1 TO size(eksdata->tqual[tcurindex].qual[ml_idx].data,5))
    IF (trim(eksdata->tqual[tcurindex].qual[ml_idx].data[ml_loop].misc,3) != "<ORDER_ID>")
     SET ml_cnt += 1
     IF (mod(ml_cnt,10)=1)
      CALL alterlist(m_rec->ord_qual,(ml_cnt+ 9))
     ENDIF
     SET m_rec->ord_qual[ml_cnt].f_order_id = cnvtreal(trim(eksdata->tqual[tcurindex].qual[ml_idx].
       data[ml_loop].misc,3))
    ENDIF
  ENDFOR
 ENDIF
 CALL alterlist(m_rec->ord_qual,ml_cnt)
 SET ml_cnt = 0
 IF (ml_idx2 > 0)
  FOR (ml_loop = 1 TO size(eksdata->tqual[tcurindex].qual[ml_idx2].data,5))
    IF (trim(eksdata->tqual[tcurindex].qual[ml_idx2].data[ml_loop].misc,3) != "<CLINICAL_EVENT_ID>")
     SET ml_cnt += 1
     IF (mod(ml_cnt,10)=1)
      CALL alterlist(m_rec->ce_qual,(ml_cnt+ 9))
     ENDIF
     SET m_rec->ce_qual[ml_cnt].f_clinical_event_id = cnvtreal(trim(eksdata->tqual[tcurindex].qual[
       ml_idx2].data[ml_loop].misc,3))
    ENDIF
  ENDFOR
 ENDIF
 CALL alterlist(m_rec->ce_qual,ml_cnt)
 IF (size(m_rec->ord_qual,5) > 0)
  SELECT INTO "nl:"
   FROM orders o,
    clinical_event ce
   PLAN (o
    WHERE expand(ml_cnt,1,size(m_rec->ord_qual,5),o.order_id,m_rec->ord_qual[ml_cnt].f_order_id)
     AND o.person_id=mf_person_id
     AND o.active_ind=1)
    JOIN (ce
    WHERE (ce.encntr_id= Outerjoin(o.encntr_id))
     AND (ce.person_id= Outerjoin(o.person_id))
     AND (ce.order_id= Outerjoin(o.order_id))
     AND (ce.publish_flag= Outerjoin(1))
     AND (ce.view_level= Outerjoin(1)) )
   ORDER BY o.orig_order_dt_tm DESC, o.order_id, ce.event_end_dt_tm DESC
   HEAD REPORT
    mn_order_ind = 1, mf_order_id = o.order_id, ms_result = cnvtupper(trim(ce.result_val,3)),
    ms_last_result_dt = ce.event_end_dt_tm, log_misc1 = build2(
     "Patient @PATIENT:{LogicTrue}, has a Covid19 order/result.",char(10),
     "MRN: @MEDICALNUMBER:{LogicTrue}",char(10),char(10),
     "Order(s): ",char(10))
   HEAD o.orig_order_dt_tm
    null
   HEAD o.order_id
    ms_mnemonic = cnvtupper(trim(o.order_mnemonic,3)), log_misc1 = build2(log_misc1," ",ms_mnemonic,
     " ordered at ",format(o.orig_order_dt_tm,"mm/dd/yy HH:mm;;D"),
     char(10),"Result(s):")
   HEAD ce.event_end_dt_tm
    null
   DETAIL
    IF (ce.event_id > 0)
     log_misc1 = build2(log_misc1," ",trim(uar_get_code_display(ce.event_cd),3),": ",cnvtupper(trim(
        ce.result_val,3)),
      " resulted at ",trim(format(ce.event_end_dt_tm,"mm/dd/yy HH:mm;;D"),3),char(10))
    ELSE
     log_misc1 = build2(log_misc1," Pending",char(10))
    ENDIF
   FOOT  ce.event_end_dt_tm
    null
   FOOT  o.order_id
    log_misc1 = build2(log_misc1,char(10))
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_rec->ce_qual,5) > 0)
  SELECT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE expand(ml_cnt,1,size(m_rec->ce_qual,5),ce.clinical_event_id,m_rec->ce_qual[ml_cnt].
     f_clinical_event_id)
     AND ce.person_id=mf_person_id
     AND ce.publish_flag=1
     AND ce.view_level=1
     AND ((ms_module="BH_SYN_COVID19_ALERT3"
     AND ce.order_id=0) OR (ms_module="BH_SYN_COVID19_ALERT2"
     AND ce.event_end_dt_tm > cnvtdatetime((curdate - value(mf_lookbackdays)),0))) )
   ORDER BY ce.event_end_dt_tm DESC
   HEAD REPORT
    mn_result_ind = 1
    IF (mf_order_id=0)
     mf_order_id = ce.order_id
    ENDIF
    IF (ce.event_end_dt_tm > mf_last_result_dt)
     ms_result = cnvtupper(trim(ce.result_val,3))
    ENDIF
    IF (textlen(trim(log_misc1,3))=0)
     log_misc1 = build2("Patient @PATIENT:{LogicTrue}, has a Covid19 order/result.",char(10),
      "MRN: @MEDICALNUMBER:{LogicTrue}",char(10),char(10),
      evaluate(ms_module,"BH_SYN_COVID19_ALERT3","Results without orders: ","BH_SYN_COVID19_ALERT2",
       "Results: "))
    ELSE
     log_misc1 = build2(log_misc1,char(10),"Results without orders: ")
    ENDIF
   HEAD ce.event_end_dt_tm
    null
   DETAIL
    log_misc1 = build2(log_misc1," ",trim(uar_get_code_display(ce.event_cd),3),": ",cnvtupper(trim(ce
       .result_val,3)),
     " resulted at ",trim(format(ce.event_end_dt_tm,"mm/dd/yy HH:mm;;D"),3),char(10))
   FOOT  ce.event_end_dt_tm
    null
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0
  AND ms_module="BH_SYN_COVID19_ALERT2")
  SET retval = evaluate(mn_covid_unit_ind,1,100,0,0)
  IF (retval=0)
   SET log_message = build2("unit_ind: ",mn_covid_unit_ind,
    ". No positive Covid19 results in the past ",build(mf_lookbackdays)," days, returning false.")
   GO TO exit_program
  ENDIF
 ELSEIF (mn_order_ind=0
  AND mn_result_ind=0)
  SET log_message = "There are no qualifying orders for this patient, returning false."
  SET retval = 0
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd,
   bhs_log_detail bd2,
   bhs_log_detail bd3
  PLAN (b
   WHERE b.object_name="BHS_EKS_COVID_RES_CHG3"
    AND (b.updt_id=reqinfo->updt_id)
    AND b.updt_dt_tm BETWEEN cnvtdatetime((curdate - 60),curtime) AND cnvtdatetime(curdate,curtime)
    AND b.msg="004"
    AND b.parameters=ms_module)
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id
    AND bd.parent_entity_name="PERSON_ID"
    AND bd.parent_entity_id=mf_person_id)
   JOIN (bd2
   WHERE bd2.bhs_log_id=b.bhs_log_id
    AND bd2.parent_entity_name="ENCNTR_ID")
   JOIN (bd3
   WHERE bd3.bhs_log_id=b.bhs_log_id
    AND bd3.parent_entity_name="ORDER_ID")
  ORDER BY b.updt_dt_tm DESC, bd.updt_dt_tm DESC, bd2.updt_dt_tm DESC,
   bd3.updt_dt_tm DESC
  HEAD bd2.bhs_log_detail_id
   IF (((bd2.parent_entity_id != mf_encntr_id) OR (bd2.msg != ms_result)) )
    mf_result_log_id = bd2.bhs_log_detail_id
   ENDIF
  HEAD bd3.bhs_log_detail_id
   IF (bd3.parent_entity_id != mf_order_id)
    mf_order_log_id = bd3.bhs_log_detail_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 100
  SET log_message = "User has not received an alert for this result, returning true."
  EXECUTE bhs_hlp_ccl
  CALL bhs_sbr_log("start",ms_module,0,"",0.0,
   "","Begin Script","")
  CALL bhs_sbr_log("log","",1,"PERSON_ID",mf_person_id,
   "","","S")
  CALL bhs_sbr_log("log","",1,"ENCNTR_ID",mf_encntr_id,
   "RESULT",ms_result,"S")
  CALL bhs_sbr_log("log","",1,"ORDER_ID",mf_order_id,
   "MNEMONIC",ms_mnemonic,"S")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "","004","S")
 ELSEIF (((mf_result_log_id > 0) OR (mf_order_log_id > 0)) )
  SET retval = 100
  SET log_message =
  "User has not received an alert for this encounter/order/result change, returning true."
  IF (mf_result_log_id > 0)
   UPDATE  FROM bhs_log_detail bd
    SET bd.parent_entity_id = mf_encntr_id, bd.msg = ms_result, bd.updt_dt_tm = sysdate
    WHERE bd.bhs_log_detail_id=mf_result_log_id
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
  IF (mf_order_log_id > 0)
   UPDATE  FROM bhs_log_detail bd
    SET bd.parent_entity_id = mf_order_id, bd.msg = ms_mnemonic, bd.updt_dt_tm = sysdate
    WHERE bd.bhs_log_detail_id=mf_order_log_id
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
 ELSE
  SET retval = 0
  SET log_message =
  "User has already received an alert for this encounter/order/lab result, returning false."
 ENDIF
#exit_program
 CALL echo(build2(";log_misc1: ",log_misc1))
 CALL echorecord(m_rec)
 CALL echorecord(eksdata)
END GO
