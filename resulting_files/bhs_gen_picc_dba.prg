CREATE PROGRAM bhs_gen_picc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encntr_id" = 0
  WITH outdev, encntr_id
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE onholdmedstudent = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")),
 protect
 DECLARE pendingreview = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW")),
 protect
 DECLARE pendingcomplete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE")),
 protect
 DECLARE unscheduled = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"UNSCHEDULED")), protect
 DECLARE ivcentralline = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4001,"IVCENTRALLINE")),
 protect
 DECLARE picc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100198,"PICC")), protect
 DECLARE umbilicalvein = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100198,"UMBILICALVEIN")),
 protect
 DECLARE umbilicalartery = f8 WITH constant(uar_get_code_by("DISPLAYKEY",100199,"UMBILICALARTERY")),
 protect
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SET beg_rtf = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}} \f0\fs20 "
 SET end_rtf = "} "
 SET beg_bold = "\b "
 SET end_bold = "\b0 "
 SET beg_uline = "\ul "
 SET end_uline = "\ulnone "
 SET beg_ital = "\i "
 SET end_ital = "\i0 "
 SET new_line = concat(char(10),char(13))
 SET end_line = " \par "
 FREE RECORD work
 RECORD work(
   1 encntr_id = f8
   1 orders[*]
     2 ordered_as = vc
     2 order_detail = vc
 )
 IF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
  SET output = "nl:"
 ELSEIF (( $ENCNTR_ID > 0.00))
  SET work->encntr_id =  $ENCNTR_ID
  SET ouput =  $OUTDEV
  RECORD reply(
    1 text = vc
  )
 ELSE
  CALL echo("No valid encntr_id given. Exiting Script")
  GO TO exit_script
 ENDIF
 CALL echo(build2("work->ENCNTR_ID:",work->encntr_id))
 SELECT DISTINCT INTO output
  o.ordered_as_mnemonic, order_status = uar_get_code_display(o.order_status_cd), o
  .order_detail_display_line
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.active_ind=1
    AND o.cs_flag IN (0, 2)
    AND o.order_status_cd IN (unscheduled, pendingcomplete, pendingreview, onholdmedstudent,
   inprocess,
   ordered)
    AND (o.encntr_id=work->encntr_id))
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_value IN (umbilicalartery, umbilicalvein, picc, ivcentralline))
  ORDER BY o.ordered_as_mnemonic
  HEAD REPORT
   ml_cnt = 0
  HEAD o.ordered_as_mnemonic
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(work->orders,5))
    stat = alterlist(work->orders,(ml_cnt+ 10))
   ENDIF
   work->orders[ml_cnt].ordered_as = o.ordered_as_mnemonic, work->orders[ml_cnt].order_detail = o
   .order_detail_display_line
  FOOT  o.ordered_as_mnemonic
   row + 0
  FOOT REPORT
   stat = alterlist(work->orders,ml_cnt)
  WITH nocounter
 ;end select
 SET reply->text = concat(beg_rtf,beg_bold,beg_uline,"Central IV Orders",end_bold,
  end_uline,end_line)
 IF (size(work->orders,5)=0)
  SET reply->text = concat(reply->text,new_line,"  No Orders Found",end_line)
 ELSE
  FOR (ml_cnt = 1 TO size(work->orders,5))
    SET reply->text = concat(reply->text,new_line,new_line,work->orders[ml_cnt].ordered_as,"  --   ",
     work->orders[ml_cnt].order_detail,end_line,new_line,end_line)
  ENDFOR
 ENDIF
 CALL echorecord(work)
 CALL echorecord(reply)
#exit_script
 FREE RECORD work
END GO
