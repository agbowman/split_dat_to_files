CREATE PROGRAM bsc_get_vda_info:dba
 SET modify = predeclare
 RECORD reply(
   1 orders[*]
     2 order_id = f8
     2 template_order_id = f8
     2 action_sequence = i4
     2 dosing_method_flag = i2
     2 template_dose_sequence = i4
     2 vda[*]
       3 dose_seq = i4
       3 strength = f8
       3 strength_unit = f8
       3 volume = f8
       3 volume_unit = f8
       3 ordered_dose = f8
       3 ordered_dose_unit = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE initialize(null) = null
 DECLARE loadvdaflags(null) = null
 DECLARE loadvdadetails(null) = null
 DECLARE totaltime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE last_mod = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE template_order_id = f8 WITH protect, noconstant(0)
 DECLARE template_dose_seq = f8 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, constant(50)
 DECLARE iorderincnt = i4 WITH protect, noconstant(size(request->orders,5))
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE iorderidx = i4 WITH protect, noconstant(0)
 DECLARE iorderoutcnt = i4 WITH protect, noconstant(0)
 IF (iorderincnt > 0)
  CALL initialize(null)
  CALL loadvdaflags(null)
  IF (iorderoutcnt > 0
   AND (request->load_vda_details_ind > 0))
   CALL loadvdadetails(null)
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE initialize(null)
  SET reply->status_data.status = "F"
  IF (validate(request->debug_ind))
   SET debug_ind = request->debug_ind
  ELSE
   SET debug_ind = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE loadvdaflags(null)
   IF (debug_ind > 0)
    CALL echo("********LoadVDAFlags********")
   ENDIF
   DECLARE loadvdaflagstime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE i = i4 WITH protect, noconstant(0)
   SET ntotal = (ceil((cnvtreal(iorderincnt)/ nsize)) * nsize)
   SET stat = alterlist(request->orders,ntotal)
   FOR (i = (iorderincnt+ 1) TO ntotal)
     SET request->orders[i].order_id = request->orders[iorderincnt].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(iorderidx,nstart,(nstart+ (nsize - 1)),o.order_id,request->orders[iorderidx].
      order_id)
      AND ((o.dosing_method_flag=1) OR (o.template_dose_sequence > 0)) )
    ORDER BY o.order_id
    HEAD o.order_id
     iorderoutcnt = (iorderoutcnt+ 1)
     IF (mod(iorderoutcnt,10)=1)
      stat = alterlist(reply->orders,(iorderoutcnt+ 9))
     ENDIF
     reply->orders[iorderoutcnt].order_id = o.order_id
     IF (o.template_order_id=0)
      reply->orders[iorderoutcnt].template_order_id = o.order_id, reply->orders[iorderoutcnt].
      action_sequence = o.last_core_action_sequence
     ELSE
      reply->orders[iorderoutcnt].template_order_id = o.template_order_id, reply->orders[iorderoutcnt
      ].action_sequence = o.template_core_action_sequence
     ENDIF
     reply->orders[iorderoutcnt].dosing_method_flag = o.dosing_method_flag, reply->orders[
     iorderoutcnt].template_dose_sequence = o.template_dose_sequence
    FOOT REPORT
     stat = alterlist(reply->orders,iorderoutcnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(request->orders,iorderincnt)
   IF (debug_ind > 0)
    CALL echo(build("********LoadVDAFlags Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       loadvdaflagstime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadvdadetails(null)
   IF (debug_ind > 0)
    CALL echo("********LoadVDADetails********")
   ENDIF
   DECLARE loadvdadetailstime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE max_action_seq = i4 WITH protect, noconstant(0)
   DECLARE vda_cnt = i4 WITH protect, noconstant(0)
   DECLARE add_dose = i2 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reply->orders,5))),
     orders o,
     order_ingredient_dose oid
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=reply->orders[d.seq].order_id))
     JOIN (oid
     WHERE (oid.order_id=reply->orders[d.seq].template_order_id)
      AND (oid.action_sequence=reply->orders[d.seq].action_sequence))
    ORDER BY oid.order_id, oid.action_sequence DESC, oid.comp_sequence,
     oid.dose_sequence
    HEAD oid.order_id
     vda_cnt = 0
     IF ((reply->orders[d.seq].template_order_id=reply->orders[d.seq].order_id))
      max_action_seq = oid.action_sequence
     ELSE
      max_action_seq = reply->orders[d.seq].action_sequence
     ENDIF
     iorderidx = locateval(i,1,iorderoutcnt,o.order_id,reply->orders[i].order_id)
    HEAD oid.action_sequence
     vda_cnt = vda_cnt, max_action_seq = max_action_seq
    HEAD oid.comp_sequence
     vda_cnt = vda_cnt, max_action_seq = max_action_seq
    HEAD oid.dose_sequence
     IF (iorderidx > 0
      AND iorderidx <= iorderoutcnt
      AND max_action_seq=oid.action_sequence)
      add_dose = 1
      IF ((reply->orders[iorderidx].template_dose_sequence > 0)
       AND (reply->orders[iorderidx].template_dose_sequence != oid.dose_sequence))
       add_dose = 0
      ENDIF
      IF (add_dose=1)
       vda_cnt = (vda_cnt+ 1)
       IF (mod(vda_cnt,6)=1)
        stat = alterlist(reply->orders[iorderidx].vda,(vda_cnt+ 5))
       ENDIF
       reply->orders[iorderidx].vda[vda_cnt].dose_seq = oid.dose_sequence, reply->orders[iorderidx].
       vda[vda_cnt].strength = oid.strength_dose_value, reply->orders[iorderidx].vda[vda_cnt].
       strength_unit = oid.strength_dose_unit_cd,
       reply->orders[iorderidx].vda[vda_cnt].volume = oid.volume_dose_value, reply->orders[iorderidx]
       .vda[vda_cnt].volume_unit = oid.volume_dose_unit_cd, reply->orders[iorderidx].vda[vda_cnt].
       ordered_dose = oid.ordered_dose_value,
       reply->orders[iorderidx].vda[vda_cnt].ordered_dose_unit = oid.ordered_dose_unit_cd
      ENDIF
     ENDIF
    FOOT  oid.order_id
     stat = alterlist(reply->orders[iorderidx].vda,vda_cnt)
    WITH nocounter
   ;end select
   IF (debug_ind > 0)
    CALL echo(build("********LoadVDADetails Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       loadvdadetailstime,5)))
   ENDIF
 END ;Subroutine
#exit_script
 IF (size(reply->orders,5) <= 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 IF (debug_ind=1)
  CALL echo("*********************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(curdate,curtime3),totaltime,5)))
  CALL echo("*********************************")
 ENDIF
 SET last_mod = "003 03/24/11"
 SET modify = nopredeclare
END GO
