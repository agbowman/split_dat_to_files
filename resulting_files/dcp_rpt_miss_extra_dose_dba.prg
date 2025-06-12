CREATE PROGRAM dcp_rpt_miss_extra_dose:dba
 RECORD rxmed_request(
   1 encntr_id = f8
   1 reason_cd = f8
   1 text = vc
   1 ord[*]
     2 order_id = f8
 )
 RECORD rxmed_reply(
   1 encntr_id = f8
   1 reason_cd = f8
   1 text = vc
   1 ord[*]
     2 order_id = f8
     2 error_flag = i2
     2 error_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET rxmed_request->encntr_id = request->encntr_id
 SET rxmed_request->reason_cd = request->reason_cd
 SET rxmed_request->text = request->text
 IF (size(request->ord,5) > 0)
  FOR (x = 1 TO size(request->ord,5))
   SET stat = alterlist(rxmed_request->ord,x)
   SET rxmed_request->ord[x].order_id = request->ord[x].order_id
  ENDFOR
  EXECUTE rx_run_med_request  WITH replace("REQUEST","RXMED_REQUEST"), replace("REPLY","RXMED_REPLY")
  IF (size(rxmed_reply->ord,5)=0)
   GO TO exit_script
  ENDIF
 ELSE
  SET rxmed_reply->encntr_id = request->encntr_id
  SET rxmed_reply->reason_cd = request->reason_cd
  SET rxmed_reply->text = request->text
  GO TO exit_script
 ENDIF
 SET ord_cnt = value(size(rxmed_reply->ord,5))
 CALL echorecord(rxmed_request)
 CALL echorecord(rxmed_reply)
 RECORD temp(
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 RECORD temp2(
   1 text = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD ord(
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 iv_ind = i2
     2 date = dq8
     2 hna_mnemonic = vc
     2 order_mnemonic = vc
     2 disp_mnem = vc
     2 m_cnt = i2
     2 m_qual[*]
       3 m_line = vc
     2 disp_line = vc
     2 d_cnt = i2
     2 d_qual[*]
       3 d_line = vc
     2 disp_err = vc
     2 e_cnt = i2
     2 e_qual[*]
       3 e_line = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET reqprov = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET unit = fillstring(50," ")
 SET room = fillstring(50," ")
 SET bed = fillstring(50," ")
 SET loc = fillstring(50," ")
 SET printer = fillstring(20," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   reqprov = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   (dummyt d1  WITH seq = 1),
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), mrn = substring(1,20,pa.alias), unit = substring(1,
    20,uar_get_code_display(e.loc_nurse_unit_cd)),
   room = substring(1,10,uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,
    uar_get_code_display(e.loc_bed_cd)), loc = concat(trim(unit),"/",trim(room),"/",trim(bed))
  WITH nocounter, outerjoin = d1, dontcare = pa
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ord_cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=rxmed_reply->ord[d.seq].order_id))
  HEAD REPORT
   ord->cnt = 0
  DETAIL
   ord->cnt = (ord->cnt+ 1), stat = alterlist(ord->qual,ord->cnt), ord->qual[ord->cnt].order_id = o
   .order_id,
   ord->qual[ord->cnt].order_mnemonic = o.order_mnemonic, ord->qual[ord->cnt].hna_mnemonic = o
   .hna_order_mnemonic
   IF ((ord->qual[ord->cnt].order_mnemonic > " ")
    AND (ord->qual[ord->cnt].order_mnemonic != ord->qual[ord->cnt].hna_mnemonic))
    ord->qual[ord->cnt].disp_mnem = concat(trim(ord->qual[ord->cnt].hna_mnemonic),"(",trim(ord->qual[
      ord->cnt].order_mnemonic),")")
   ELSE
    ord->qual[ord->cnt].disp_mnem = trim(ord->qual[ord->cnt].hna_mnemonic)
   ENDIF
   IF (o.clinical_display_line > " ")
    ord->qual[ord->cnt].disp_line = o.clinical_display_line
   ELSE
    ord->qual[ord->cnt].disp_line = o.order_detail_display_line
   ENDIF
   ord->qual[ord->cnt].disp_err = rxmed_reply->ord[d.seq].error_text, ord->qual[ord->cnt].date =
   cnvtdatetime(o.orig_order_dt_tm), ord->qual[ord->cnt].iv_ind = o.iv_ind
  WITH nocounter
 ;end select
 FOR (x = 1 TO ord->cnt)
   IF ((ord->qual[x].iv_ind=1))
    SELECT INTO "nl:"
     FROM order_ingredient oi
     PLAN (oi
      WHERE (oi.order_id=ord->qual[x].order_id))
     ORDER BY oi.action_sequence, oi.comp_sequence
     HEAD oi.action_sequence
      mnemonic_line = fillstring(500," "), first_time = "Y"
     DETAIL
      IF (first_time="Y")
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
       ENDIF
       first_time = "N"
      ELSE
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ENDIF
      ENDIF
     FOOT REPORT
      ord->qual[x].disp_mnem = mnemonic_line
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF ((request->text > " "))
  SET pt->line_cnt = 0
  SET max_length = 75
  EXECUTE dcp_parse_text value(request->text), value(max_length)
  SET stat = alterlist(temp->qual,pt->line_cnt)
  SET temp->cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET temp->qual[x].line = pt->lns[x].line
  ENDFOR
 ELSE
  SET temp->cnt = 0
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE (cv.code_value=request->reason_cd)
    AND cv.active_ind=1)
  DETAIL
   temp2->text = cv.display
  WITH nocounter
 ;end select
 IF ((temp2->text > " "))
  SET pt->line_cnt = 0
  SET max_length = 65
  EXECUTE dcp_parse_text value(temp2->text), value(max_length)
  SET stat = alterlist(temp2->qual,pt->line_cnt)
  SET temp2->cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET temp2->qual[x].line = pt->lns[x].line
  ENDFOR
 ELSE
  SET temp2->cnt = 0
 ENDIF
 FOR (x = 1 TO ord->cnt)
   SET pt->line_cnt = 0
   SET x20 = fillstring(20," ")
   SET max_length = 85
   EXECUTE dcp_parse_text value(ord->qual[x].disp_mnem), value(max_length)
   SET stat = alterlist(ord->qual[x].m_qual,pt->line_cnt)
   SET ord->qual[x].m_cnt = pt->line_cnt
   FOR (y = 1 TO pt->line_cnt)
    IF (y=1)
     SET pt->lns[y].line = concat("Orderable: ",trim(pt->lns[y].line))
    ELSE
     SET pt->lns[y].line = concat(x20,trim(pt->lns[y].line))
    ENDIF
    SET ord->qual[x].m_qual[y].m_line = pt->lns[y].line
   ENDFOR
   SET pt->line_cnt = 0
   SET x28 = fillstring(28," ")
   SET max_length = 85
   EXECUTE dcp_parse_text value(ord->qual[x].disp_line), value(max_length)
   SET stat = alterlist(ord->qual[x].d_qual,pt->line_cnt)
   SET ord->qual[x].d_cnt = pt->line_cnt
   FOR (y = 1 TO pt->line_cnt)
    IF (y=1)
     SET pt->lns[y].line = concat("Order Details: ",trim(pt->lns[y].line))
    ELSE
     SET pt->lns[y].line = concat(x28,trim(pt->lns[y].line))
    ENDIF
    SET ord->qual[x].d_qual[y].d_line = pt->lns[y].line
   ENDFOR
   SET pt->line_cnt = 0
   SET x36 = fillstring(36," ")
   SET max_length = 85
   EXECUTE dcp_parse_text value(ord->qual[x].disp_err), value(max_length)
   SET stat = alterlist(ord->qual[x].e_qual,pt->line_cnt)
   SET ord->qual[x].e_cnt = pt->line_cnt
   FOR (y = 1 TO pt->line_cnt)
    IF (y=1)
     SET pt->lns[y].line = concat("Error text: ",trim(pt->lns[y].line))
    ELSE
     SET pt->lns[y].line = concat(x36,trim(pt->lns[y].line))
    ENDIF
    SET ord->qual[x].e_qual[y].e_line = pt->lns[y].line
   ENDFOR
 ENDFOR
 CALL echorecord(ord)
 SELECT INTO "XICY62"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   xcol = 0, ycol = 0
  DETAIL
   "{f/12}{cpi/12}", row + 1, xcol = 40,
   ycol = 50,
   CALL print(calcpos(xcol,ycol)), "{b}Print Date/Time: {endb}",
   curdate, " ", curtime,
   row + 1, ycol = (ycol+ 24),
   CALL print(calcpos(xcol,ycol)),
   "{b}From Unit: {endb}", unit, row + 1,
   ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)), "{b}To: {endb}Pharmacy",
   row + 1, ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)),
   "{b}Sent By: {endb}", reqprov, row + 1,
   ycol = (ycol+ 40),
   CALL print(calcpos(xcol,ycol)), "{b}{u}PHARMACY MEDICATION REORDER / IV SCHEDULE",
   row + 1, ycol = (ycol+ 30)
   FOR (x = 1 TO ord_cnt)
     FOR (y = 1 TO ord->qual[x].m_cnt)
       xcol = 40,
       CALL print(calcpos(xcol,ycol)), "{b/10}",
       ord->qual[x].m_qual[y].m_line, row + 1, ycol = (ycol+ 12)
     ENDFOR
     FOR (y = 1 TO ord->qual[x].d_cnt)
       xcol = 40,
       CALL print(calcpos(xcol,ycol)), "{b/14}",
       ord->qual[x].d_qual[y].d_line, row + 1, ycol = (ycol+ 12)
     ENDFOR
     FOR (y = 1 TO ord->qual[x].e_cnt)
       xcol = 40,
       CALL print(calcpos(xcol,ycol)), "{b/11}",
       ord->qual[x].e_qual[y].e_line, row + 1, ycol = (ycol+ 12)
     ENDFOR
     ycol = (ycol+ 12)
   ENDFOR
   xcol = 40, ycol = (ycol+ 24),
   CALL print(calcpos(xcol,ycol)),
   "{b}Patient Name: {endb}", name, row + 1,
   ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{b}Medical Record #: {endb}",
   mrn, row + 1, ycol = (ycol+ 12),
   CALL print(calcpos(xcol,ycol)), "{b}Location: {endb}", loc,
   row + 1, ycol = (ycol+ 30),
   CALL print(calcpos(xcol,ycol)),
   "{b}Reason: ", row + 1
   FOR (x = 1 TO temp2->cnt)
     xcol = 90,
     CALL print(calcpos(xcol,ycol)), temp2->qual[x].line,
     row + 1, ycol = (ycol+ 12)
   ENDFOR
   ycol = (ycol+ 5), xcol = 40,
   CALL print(calcpos(xcol,ycol)),
   "{b}Comments: ", row + 1
   FOR (x = 1 TO temp2->cnt)
     xcol = 100,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].line,
     row + 1, ycol = (ycol+ 12)
   ENDFOR
  WITH nocounter, dio = postscript, maxcol = 500,
   maxrow = 500
 ;end select
#exit_script
END GO
