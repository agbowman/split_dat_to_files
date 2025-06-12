CREATE PROGRAM bhs_athn_get_order_actions
 RECORD t_record(
   1 order_cnt = i4
   1 order_qual[*]
     2 encntr_type_cd = f8
     2 order_id = f8
     2 protocol_order_id = f8
     2 rx_flag = i2
     2 activity_type = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 dept_status_cd = f8
     2 dept_status_disp = vc
     2 freq_flag = i2
     2 constant_ind = i2
     2 stop_type_cd = f8
     2 proj_stop_dt_tm = dq8
     2 can_view_ind = i2
     2 can_order_ind = i2
     2 action_cnt = i4
     2 action_qual[*]
       3 order_action_cd = f8
       3 order_action_disp = vc
       3 priv_ind = i2
   1 priv_cnt = i4
   1 priv_qual[*]
     2 priv = vc
     2 priv_value_mean = vc
     2 exception_cnt = i4
     2 exception_qual[*]
       3 exception_type_cd = f8
       3 exception_type_disp = vc
       3 exception_cd = f8
       3 exception_disp = vc
 )
 RECORD orequest(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 RECORD out_rec(
   1 order_qual[*]
     2 order_id = vc
     2 can_view_ind = vc
     2 action_qual[*]
       3 order_action_cd = vc
       3 order_action_disp = vc
 )
 DECLARE renew_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"RENEW"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"MODIFY"))
 DECLARE cancelreorder_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"CANCELREORDER"))
 DECLARE suspend_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"SUSPEND"))
 DECLARE activate_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ACTIVATE"))
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE"))
 DECLARE canceldc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"CANCELDC"))
 DECLARE void_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"VOID"))
 DECLARE resume_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"RESUME"))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE future_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE onholdmedstudent_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE pendingcomplete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pendingreview_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"SUSPENDED"))
 DECLARE transfercanceled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"TRANSFERCANCELED")
  )
 DECLARE unscheduled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"UNSCHEDULED"))
 DECLARE voidedwithresults_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,
   "VOIDEDWITHRESULTS"))
 DECLARE softstop_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4009,"SOFTSTOP"))
 DECLARE dept_ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"ORDERED"))
 DECLARE dept_canceled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"CANCELED"))
 DECLARE preadmitip_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE preofficevisit_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREOFFICEVISIT"))
 DECLARE preadmitdaystay_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE preoutpt_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE consults_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 DECLARE t_line = vc
 DECLARE t_val = f8
 DECLARE p_cnt = i4
 DECLARE a_cnt = i4
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $2))
  HEAD REPORT
   orequest->position_cd = p.position_cd
  WITH nocounter, time = 30
 ;end select
 SET orequest->chk_psn_ind = 1
 FOR (i = 1 TO 10000)
  SET t_line = piece( $3,";",i,"not found")
  IF (t_line="not found")
   SET i = 10001
  ELSE
   SET t_val = cnvtreal(piece(t_line,";",1,"not found"))
   SET t_record->order_cnt += 1
   IF (mod(t_record->order_cnt,100)=1)
    SET stat = alterlist(t_record->order_qual,(t_record->order_cnt+ 99))
   ENDIF
   SET t_record->order_qual[t_record->order_cnt].order_id = t_val
  ENDIF
 ENDFOR
 SET stat = alterlist(t_record->order_qual,t_record->order_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->order_cnt),
   orders o,
   encounter e
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=t_record->order_qual[d.seq].order_id))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  HEAD o.order_id
   IF (o.orig_ord_as_flag=1)
    t_record->order_qual[d.seq].rx_flag = 1
   ENDIF
   t_record->order_qual[d.seq].protocol_order_id = o.protocol_order_id, t_record->order_qual[d.seq].
   encntr_type_cd = e.encntr_type_cd, t_record->order_qual[d.seq].activity_type = o.activity_type_cd,
   t_record->order_qual[d.seq].catalog_type_cd = o.catalog_type_cd, t_record->order_qual[d.seq].
   catalog_cd = o.catalog_cd, t_record->order_qual[d.seq].order_status_cd = o.order_status_cd,
   t_record->order_qual[d.seq].order_status_disp = uar_get_code_display(o.order_status_cd), t_record
   ->order_qual[d.seq].dept_status_cd = o.dept_status_cd, t_record->order_qual[d.seq].
   dept_status_disp = uar_get_code_display(o.dept_status_cd),
   t_record->order_qual[d.seq].freq_flag = o.freq_type_flag, t_record->order_qual[d.seq].
   proj_stop_dt_tm = o.projected_stop_dt_tm, t_record->order_qual[d.seq].stop_type_cd = o
   .stop_type_cd,
   t_record->order_qual[d.seq].constant_ind = o.constant_ind
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.cdf_meaning IN ("VIEWORDER", "COMPLETEORDR", "CANCELORDER", "MODIFYORDER", "SUSPENDORDER",
   "VOIDORDER", "RESCHEDORDER", "REFILLRENEW", "VIEWONLYORD", "ORDER",
   "SUSPENDRX", "REFILRENEWRX", "MODIFYONHOLD", "COMPINFORD")
    AND cv.code_set=6016
    AND cv.active_ind=1)
  HEAD cv.code_value
   p_cnt += 1, stat = alterlist(orequest->plist,p_cnt), orequest->plist[p_cnt].privilege_mean = cv
   .cdf_meaning,
   orequest->plist[p_cnt].privilege_cd = cv.code_value
  WITH nocounter, time = 30
 ;end select
 SET stat = tdbexecute(4250111,500286,500286,"REC",orequest,
  "REC",oreply)
 FOR (i = 1 TO size(oreply->qual,5))
   IF ((oreply->qual[i].priv_status IN ("S", "Z")))
    SET t_record->priv_cnt += 1
    SET stat = alterlist(t_record->priv_qual,t_record->priv_cnt)
    SET p_cnt = t_record->priv_cnt
    SET t_record->priv_qual[p_cnt].priv = oreply->qual[i].privilege_mean
    SET t_record->priv_qual[p_cnt].priv_value_mean = oreply->qual[i].priv_value_mean
    SET t_record->priv_qual[p_cnt].exception_cnt = oreply->qual[i].except_cnt
    SET stat = alterlist(t_record->priv_qual[p_cnt].exception_qual,t_record->priv_qual[p_cnt].
     exception_cnt)
    FOR (j = 1 TO oreply->qual[i].except_cnt)
      SET t_record->priv_qual[p_cnt].exception_qual[j].exception_type_cd = oreply->qual[i].excepts[j]
      .exception_type_cd
      SET t_record->priv_qual[p_cnt].exception_qual[j].exception_type_disp = uar_get_code_display(
       oreply->qual[i].excepts[j].exception_type_cd)
      SET t_record->priv_qual[p_cnt].exception_qual[j].exception_cd = oreply->qual[i].excepts[j].
      exception_id
      SET t_record->priv_qual[p_cnt].exception_qual[j].exception_disp = uar_get_code_display(oreply->
       qual[i].excepts[j].exception_id)
    ENDFOR
   ENDIF
 ENDFOR
 FOR (i = 1 TO t_record->order_cnt)
  IF ((t_record->order_qual[i].order_status_cd=ordered_cd))
   SET t_record->order_qual[i].action_cnt = 7
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = renew_cd
   SET t_record->order_qual[i].action_qual[2].order_action_cd = modify_cd
   SET t_record->order_qual[i].action_qual[3].order_action_cd = canceldc_cd
   SET t_record->order_qual[i].action_qual[4].order_action_cd = suspend_cd
   SET t_record->order_qual[i].action_qual[5].order_action_cd = void_cd
   SET t_record->order_qual[i].action_qual[6].order_action_cd = complete_cd
   SET t_record->order_qual[i].action_qual[7].order_action_cd = cancelreorder_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=future_cd))
   SET t_record->order_qual[i].action_cnt = 5
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = activate_cd
   SET t_record->order_qual[i].action_qual[2].order_action_cd = modify_cd
   SET t_record->order_qual[i].action_qual[3].order_action_cd = cancelreorder_cd
   SET t_record->order_qual[i].action_qual[4].order_action_cd = canceldc_cd
   SET t_record->order_qual[i].action_qual[5].order_action_cd = void_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=onholdmedstudent_cd))
   SET t_record->order_qual[i].action_cnt = 2
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = void_cd
   SET t_record->order_qual[i].action_qual[2].order_action_cd = modify_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=incomplete_cd))
   SET t_record->order_qual[i].action_cnt = 4
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = modify_cd
   SET t_record->order_qual[i].action_qual[2].order_action_cd = canceldc_cd
   SET t_record->order_qual[i].action_qual[3].order_action_cd = void_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=pendingcomplete_cd))
   SET t_record->order_qual[i].action_cnt = 1
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = void_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=suspended_cd))
   SET t_record->order_qual[i].action_cnt = 4
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = resume_cd
   SET t_record->order_qual[i].action_qual[2].order_action_cd = canceldc_cd
   SET t_record->order_qual[i].action_qual[3].order_action_cd = void_cd
   SET t_record->order_qual[i].action_qual[4].order_action_cd = cancelreorder_cd
  ELSEIF ((t_record->order_qual[i].order_status_cd=canceled_cd))
   SET t_record->order_qual[i].action_cnt = 1
   SET stat = alterlist(t_record->order_qual[i].action_qual,t_record->order_qual[i].action_cnt)
   SET t_record->order_qual[i].action_qual[1].order_action_cd = void_cd
  ENDIF
  FOR (j = 1 TO t_record->order_qual[i].action_cnt)
    SET t_record->order_qual[i].action_qual[j].order_action_disp = uar_get_code_display(t_record->
     order_qual[i].action_qual[j].order_action_cd)
  ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->order_cnt)
  FOR (k = 1 TO t_record->priv_cnt)
    IF ((t_record->priv_qual[k].priv="VIEWORDER"))
     IF ((t_record->priv_qual[k].priv_value_mean="YES"))
      SET t_record->order_qual[i].can_view_ind = 1
     ELSEIF ((t_record->priv_qual[k].priv_value_mean="EXCLUDE"))
      SET t_record->order_qual[i].can_view_ind = 1
      FOR (l = 1 TO t_record->priv_qual[k].exception_cnt)
        IF ((t_record->priv_qual[k].exception_qual[l].exception_cd IN (t_record->order_qual[i].
        activity_type, t_record->order_qual[i].catalog_cd, t_record->order_qual[i].catalog_type_cd)))
         SET t_record->order_qual[i].can_view_ind = 0
        ENDIF
      ENDFOR
     ELSEIF ((t_record->priv_qual[k].priv_value_mean="NO"))
      SET t_record->order_qual[i].can_view_ind = 0
     ELSEIF ((t_record->priv_qual[k].priv_value_mean="INCLUDE"))
      FOR (l = 1 TO t_record->priv_qual[k].exception_cnt)
        IF ((t_record->priv_qual[k].exception_qual[l].exception_cd IN (t_record->order_qual[i].
        activity_type, t_record->order_qual[i].catalog_cd, t_record->order_qual[i].catalog_type_cd)))
         SET t_record->order_qual[i].can_view_ind = 1
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
  FOR (j = 1 TO t_record->order_qual[i].action_cnt)
    FOR (k = 1 TO t_record->priv_cnt)
      IF ((((t_record->order_qual[i].action_qual[j].order_action_disp="Cancel/DC")
       AND (t_record->priv_qual[k].priv="CANCELORDER")) OR ((((t_record->order_qual[i].action_qual[j]
      .order_action_disp="Cancel/Reorder")
       AND (t_record->priv_qual[k].priv="CANCELORDER")) OR ((((t_record->order_qual[i].action_qual[j]
      .order_action_disp="Modify")
       AND (t_record->priv_qual[k].priv="MODIFYORDER")) OR ((((t_record->order_qual[i].action_qual[j]
      .order_action_disp="Modify")
       AND (t_record->priv_qual[k].priv="MODIFYONHOLD")
       AND (t_record->order_qual[i].order_status_cd=onholdmedstudent_cd)) OR ((((t_record->
      order_qual[i].action_qual[j].order_action_disp="Modify")
       AND (t_record->priv_qual[k].priv="MODIFYONHOLD")
       AND (t_record->order_qual[i].dept_status_disp="On Hold")) OR ((((t_record->order_qual[i].
      action_qual[j].order_action_disp="Modify")
       AND (t_record->order_qual[i].order_status_cd=future_cd)) OR ((((t_record->order_qual[i].
      action_qual[j].order_action_disp="Complete")
       AND (t_record->priv_qual[k].priv="COMPLETEORDR")
       AND (t_record->order_qual[i].freq_flag=0)) OR ((((t_record->order_qual[i].rx_flag=0)
       AND (t_record->order_qual[i].action_qual[j].order_action_disp="Suspend")
       AND (t_record->priv_qual[k].priv="SUSPENDORDER")) OR ((((t_record->order_qual[i].rx_flag=1)
       AND (t_record->order_qual[i].action_qual[j].order_action_disp="Suspend")
       AND (t_record->priv_qual[k].priv="SUSPENDRX")) OR ((((t_record->order_qual[i].action_qual[j].
      order_action_disp="Void")
       AND (t_record->priv_qual[k].priv="VOIDORDER")
       AND (t_record->order_qual[i].order_status_cd != canceled_cd)) OR ((((t_record->order_qual[i].
      action_qual[j].order_action_disp="Void")
       AND (t_record->priv_qual[k].priv="VOIDORDER")
       AND (t_record->order_qual[i].order_status_cd=canceled_cd)
       AND (t_record->order_qual[i].dept_status_cd != dept_canceled_cd)) OR ((((t_record->order_qual[
      i].rx_flag=0)
       AND (t_record->order_qual[i].action_qual[j].order_action_disp="Renew")
       AND (t_record->priv_qual[k].priv="REFILLRENEW")
       AND (t_record->order_qual[i].dept_status_cd=dept_ordered_cd)
       AND (((t_record->order_qual[i].proj_stop_dt_tm > sysdate)) OR ((t_record->order_qual[i].
      stop_type_cd=softstop_cd))) ) OR ((t_record->order_qual[i].rx_flag=1)
       AND (t_record->order_qual[i].action_qual[j].order_action_disp="Renew")
       AND (t_record->priv_qual[k].priv="REFILRENEWRX")
       AND (t_record->order_qual[i].dept_status_cd=dept_ordered_cd)
       AND (((t_record->order_qual[i].proj_stop_dt_tm > sysdate)) OR ((t_record->order_qual[i].
      stop_type_cd=softstop_cd))) )) )) )) )) )) )) )) )) )) )) )) )) )
       IF ((t_record->priv_qual[k].priv_value_mean IN ("YES", "NOTDEFINED")))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 1
       ELSEIF ((t_record->priv_qual[k].priv_value_mean="EXCLUDE"))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 1
        FOR (l = 1 TO t_record->priv_qual[k].exception_cnt)
          IF ((t_record->priv_qual[k].exception_qual[l].exception_cd IN (t_record->order_qual[i].
          activity_type, t_record->order_qual[i].catalog_cd, t_record->order_qual[i].catalog_type_cd)
          ))
           SET t_record->order_qual[i].action_qual[j].priv_ind = 0
          ENDIF
        ENDFOR
       ELSEIF ((t_record->priv_qual[k].priv_value_mean="NO"))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 0
       ELSEIF ((t_record->priv_qual[k].priv_value_mean="INCLUDE"))
        FOR (l = 1 TO t_record->priv_qual[k].exception_cnt)
          IF ((t_record->priv_qual[k].exception_qual[l].exception_cd IN (t_record->order_qual[i].
          activity_type, t_record->order_qual[i].catalog_cd, t_record->order_qual[i].catalog_type_cd)
          ))
           SET t_record->order_qual[i].action_qual[j].priv_ind = 0
          ENDIF
        ENDFOR
       ENDIF
       IF ((t_record->order_qual[i].protocol_order_id > 0))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 0
        IF ((t_record->order_qual[i].action_qual[j].order_action_disp="Cancel/DC"))
         SET t_record->order_qual[i].action_qual[j].priv_ind = 1
        ENDIF
       ENDIF
      ENDIF
      IF ((t_record->order_qual[i].action_qual[j].order_action_disp="Activate"))
       SET t_record->order_qual[i].action_qual[j].priv_ind = 1
       IF ((t_record->order_qual[i].order_status_disp="Future")
        AND (t_record->order_qual[i].dept_status_cd=0))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 0
       ENDIF
       IF ((t_record->priv_qual[k].priv="VIEWONLYORD")
        AND (t_record->priv_qual[k].priv_value_mean="YES"))
        SET t_record->order_qual[i].action_qual[j].priv_ind = 0
       ENDIF
      ENDIF
      IF ((t_record->order_qual[i].encntr_type_cd IN (preadmitip_cd, preofficevisit_cd,
      preadmitdaystay_cd, preoutpt_cd))
       AND (t_record->order_qual[i].action_qual[j].order_action_disp="Cancel/Reorder")
       AND (t_record->order_qual[i].order_status_cd != ordered_cd))
       SET t_record->order_qual[i].action_qual[j].priv_ind = 0
      ENDIF
      IF ((t_record->order_qual[i].action_qual[j].order_action_disp="Complete")
       AND (t_record->order_qual[i].activity_type=consults_cd)
       AND (t_record->order_qual[i].constant_ind=1))
       SET t_record->order_qual[i].action_qual[j].priv_ind = 0
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
 SET stat = alterlist(out_rec->order_qual,t_record->order_cnt)
 FOR (i = 1 TO t_record->order_cnt)
   SET a_cnt = 0
   SET out_rec->order_qual[i].order_id = trim(cnvtstring(t_record->order_qual[i].order_id))
   SET out_rec->order_qual[i].can_view_ind = trim(cnvtstring(t_record->order_qual[i].can_view_ind))
   FOR (j = 1 TO t_record->order_qual[i].action_cnt)
     IF ((t_record->order_qual[i].action_qual[j].priv_ind=1))
      SET a_cnt += 1
      SET stat = alterlist(out_rec->order_qual[i].action_qual,a_cnt)
      SET out_rec->order_qual[i].action_qual[a_cnt].order_action_cd = trim(cnvtstring(t_record->
        order_qual[i].action_qual[j].order_action_cd))
      SET out_rec->order_qual[i].action_qual[a_cnt].order_action_disp = t_record->order_qual[i].
      action_qual[j].order_action_disp
     ENDIF
   ENDFOR
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
