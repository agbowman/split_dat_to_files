CREATE PROGRAM bhs_eks_covid19_retest:dba
 RECORD m_rec(
   1 ord_qual[*]
     2 f_order_id = f8
 ) WITH protect
 IF (validate(trigger_encntrid)=0)
  DECLARE trigger_encntrid = f8 WITH public, noconstant(0)
 ENDIF
 IF (validate(retval)=0)
  DECLARE retval = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(log_message)=0)
  DECLARE log_message = vc WITH public, noconstant("")
 ENDIF
 IF (validate(log_misc1)=0)
  DECLARE log_misc1 = vc WITH public, noconstant("")
 ENDIF
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 SET ml_idx = locateval(ml_cnt,1,size(eksdata->tqual[tcurindex].qual,5),"COVID19ORD",cnvtupper(trim(
    eksdata->tqual[tcurindex].qual[ml_cnt].template_alias,3)))
 IF (ml_idx > 0)
  IF (size(eksdata->tqual[tcurindex].qual[ml_idx].data,5)=0)
   SET retval = - (1)
   SET log_message = "Error - No orders were passed to program from COVID19ORD template."
   GO TO exit_program
  ENDIF
  SET ml_cnt = 0
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
  CALL alterlist(m_rec->ord_qual,ml_cnt)
  SET ml_cnt = 0
 ELSE
  SET retval = - (1)
  SET log_message =
  'Error - Orders rule template not found, template alias should be named "COVID19ORD".'
  GO TO exit_program
 ENDIF
 IF (size(m_rec->ord_qual,5) > 0)
  SELECT INTO "nl:"
   FROM orders o,
    clinical_event ce
   PLAN (o
    WHERE expand(ml_cnt,1,size(m_rec->ord_qual,5),o.order_id,m_rec->ord_qual[ml_cnt].f_order_id)
     AND o.encntr_id=mf_encntr_id
     AND o.active_ind=1)
    JOIN (ce
    WHERE (ce.encntr_id= Outerjoin(o.encntr_id))
     AND (ce.order_id= Outerjoin(o.order_id))
     AND (ce.person_id= Outerjoin(o.person_id))
     AND (ce.publish_flag= Outerjoin(1))
     AND (ce.view_level= Outerjoin(1)) )
   ORDER BY o.orig_order_dt_tm DESC, o.order_id, ce.event_end_dt_tm DESC
   HEAD REPORT
    log_misc1 = build2(
     "Patient @PATIENT:{LogicTrue}, has already had a Covid19 test performed this admission.",char(10
      ),char(10),"It is recommended that an ID consult be called before ordering a subsequent test. ",
     char(10),
     char(10))
   HEAD o.orig_order_dt_tm
    null
   HEAD o.order_id
    log_misc1 = build2(log_misc1,"Order: ",cnvtupper(trim(o.order_mnemonic,3))," ordered at ",format(
      o.orig_order_dt_tm,"mm/dd/yy HH:mm;;D"),
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
   FOOT  o.orig_order_dt_tm
    null
   WITH nocounter
  ;end select
 ENDIF
 SET retval = 100
#exit_program
 CALL echo(build2(";log_misc1: ",log_misc1))
 CALL echorecord(m_rec)
 CALL echorecord(eksdata)
END GO
