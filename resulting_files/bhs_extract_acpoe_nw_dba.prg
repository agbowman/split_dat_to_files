CREATE PROGRAM bhs_extract_acpoe_nw:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, begin_date, end_date
 DECLARE mf_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE mf_future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $BEGIN_DATE)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $END_DATE)," 23:59:59"))
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_file_name = vc WITH protect, noconstant(build(
   "/cerner/d_p627/bhscust/acpoe_orders_extract_nw",curdate,".dat"))
 DECLARE mn_file_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 FREE RECORD request
 RECORD request(
   1 cnt = i4
   1 trigger_personid = f8
   1 trigger_encntrid = f8
   1 trigger_orderid = f8
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 cnt = i4
   1 list[*]
     2 order_id = f8
 ) WITH protect
 SET mn_file_exists_ind = findfile(value(ms_file_name))
 IF (mn_file_exists_ind > 0)
  FREE DEFINE rtl2
  DEFINE rtl2 value(ms_file_name)
  SELECT INTO "nl:"
   FROM rtl2t r
   HEAD REPORT
    pn_header_ind = 1
   DETAIL
    IF (pn_header_ind=0)
     m_rec->cnt = (m_rec->cnt+ 1)
     IF (mod(m_rec->cnt,100)=1)
      stat = alterlist(m_rec->list,(m_rec->cnt+ 99))
     ENDIF
     m_rec->list[m_rec->cnt].order_id = cnvtreal(r.line)
    ENDIF
    pn_header_ind = 0
   FOOT REPORT
    stat = alterlist(m_rec->list,m_rec->cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET request->cnt = 2
 SET stat = alterlist(request->list,request->cnt)
 SET request->list[1].person_id = 1839114.0
 SET request->list[1].encntr_id = 0.0
 SET request->list[1].order_id = 2903137841.0
 SET request->list[2].person_id = 1839114.00
 SET request->list[2].encntr_id = 0.0
 SET request->list[2].order_id = 2903137843.0
 IF ((request->cnt > 0))
  FOR (ml_loop = 1 TO request->cnt)
    CALL echo("***")
    CALL echo(request->list[ml_loop].order_id)
    CALL echo("---")
    IF (mod(ml_loop,100)=1
     AND ml_loop != 1)
     CALL pause(5)
    ENDIF
    SET request->trigger_personid = request->list[ml_loop].person_id
    SET request->trigger_encntrid = request->list[ml_loop].encntr_id
    SET request->trigger_orderid = request->list[ml_loop].order_id
    EXECUTE bhs_extract_acpoe_child_nw
    SELECT INTO value(ms_file_name)
     FROM dual
     HEAD REPORT
      IF (mn_file_exists_ind=0
       AND ml_loop=1)
       col 0, "ORDER_ID", row + 1
      ENDIF
     DETAIL
      col 0, request->trigger_orderid, row + 1
     WITH nocounter, format = variable, maxrow = 1,
      append
    ;end select
  ENDFOR
 ENDIF
#exit_program
 FREE RECORD request
 FREE RECORD m_rec
END GO
