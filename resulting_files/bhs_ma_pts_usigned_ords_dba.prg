CREATE PROGRAM bhs_ma_pts_usigned_ords:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a Corporate Medical Number #:" = ""
  WITH outdev, s_cmrn
 FREE RECORD data
 RECORD data(
   1 order_cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 pt_name = vc
     2 fmrn = vc
     2 cmrn = vc
     2 acct_nbr = vc
     2 disch_dt_tm = dq8
     2 encntr_type = vc
     2 days_since_disch = i4
     2 order_id = f8
     2 comm_type = vc
     2 order_mnem = vc
     2 clin_display = vc
     2 orig_ord_dt_tm = dq8
     2 ord_status = vc
     2 ord_phys = vc
     2 comment_cnt = i4
     2 comments[*]
       3 comment = vc
 )
 DECLARE mf_fmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_oa_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE mf_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"
   ))
 DECLARE ms_rpt_name = vc WITH protect, constant("UNSIGNED ORDERS BY PATIENT")
 DECLARE ms_output = vc WITH protect, noconstant(cnvtupper( $OUTDEV))
 DECLARE mf_cmrn = vc WITH protect, noconstant(trim(cnvtupper( $S_CMRN),3))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  orv.order_id, order_status = uar_get_code_display(o.order_status_cd), encntr_type =
  uar_get_code_display(e.encntr_type_cd),
  days_since_disch = datetimecmp(cnvtdatetime(curdate,curtime3),e.disch_dt_tm)
  FROM order_review orv,
   encounter e,
   person p,
   orders o,
   dummyt d1,
   dummyt d3,
   encntr_alias ea1,
   encntr_alias ea2,
   person_alias pa
  PLAN (pa
   WHERE pa.alias=value(mf_cmrn)
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=pa.person_id)
   JOIN (o
   WHERE o.person_id=p.person_id
    AND o.active_ind=1
    AND  NOT (o.order_status_cd IN (mf_canceled_cd, mf_deleted_cd, mf_discontinued_cd))
    AND o.orig_ord_as_flag=0
    AND o.need_doctor_cosign_ind=1)
   JOIN (orv
   WHERE orv.order_id=o.order_id
    AND orv.review_type_flag=2
    AND orv.reviewed_status_flag=0)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=mf_fin_cd
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_fmrn_cd
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY orv.order_id
  HEAD REPORT
   ml_cnt = 0, stat = alterlist(data->qual,10)
  HEAD orv.order_id
   ml_cnt = (ml_cnt+ 1)
   IF (mod(ml_cnt,10)=1)
    stat = alterlist(data->qual,(ml_cnt+ 10))
   ENDIF
   data->qual[ml_cnt].order_id = orv.order_id, data->qual[ml_cnt].encntr_id = o.encntr_id, data->
   qual[ml_cnt].person_id = o.person_id,
   data->qual[ml_cnt].ord_status = order_status, data->qual[ml_cnt].order_mnem = substring(1,40,o
    .order_mnemonic), data->qual[ml_cnt].orig_ord_dt_tm = o.orig_order_dt_tm,
   data->qual[ml_cnt].disch_dt_tm = e.disch_dt_tm, data->qual[ml_cnt].encntr_type = encntr_type, data
   ->qual[ml_cnt].pt_name = substring(1,30,p.name_full_formatted),
   data->qual[ml_cnt].acct_nbr = substring(1,15,trim(ea1.alias,3)), data->qual[ml_cnt].fmrn =
   substring(1,15,trim(ea2.alias,3)), data->qual[ml_cnt].cmrn = substring(1,15,trim(pa.alias,3)),
   data->qual[ml_cnt].clin_display = substring(1,40,trim(o.clinical_display_line,3)), data->qual[
   ml_cnt].days_since_disch = days_since_disch
  FOOT REPORT
   IF (ml_cnt > 0)
    stat = alterlist(data->qual,ml_cnt), data->order_cnt = ml_cnt
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d3
 ;end select
 SELECT INTO "nl:"
  oa.order_id, oa.action_sequence, comm_type = uar_get_code_display(oa.communication_type_cd)
  FROM (dummyt d1  WITH seq = data->order_cnt),
   order_action oa,
   dummyt d2,
   prsnl pr
  PLAN (d1)
   JOIN (oa
   WHERE (oa.order_id=data->qual[d1.seq].order_id)
    AND oa.action_type_cd=mf_oa_order_cd)
   JOIN (d2)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY oa.order_id, oa.action_sequence
  HEAD oa.order_id
   data->qual[d1.seq].comm_type = comm_type, data->qual[d1.seq].ord_phys = substring(1,30,trim(pr
     .name_full_formatted,3))
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  oc.order_id, lt.long_text_id
  FROM (dummyt d1  WITH seq = data->order_cnt),
   order_comment oc,
   long_text lt
  PLAN (d1)
   JOIN (oc
   WHERE (oc.order_id=data->qual[d1.seq].order_id))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  ORDER BY oc.order_id
  HEAD REPORT
   pg_width = 150, cr = char(13), lf = char(10),
   end_line = concat(char(13),char(10))
  HEAD lt.long_text_id
   cnt_comment = 0
  DETAIL
   IF (lt.long_text_id > 0)
    comment_string = concat("COMMENT: ",trim(lt.long_text,3)), eol1 = findstring(end_line,
     comment_string,1), comment_len = (textlen(trim(lt.long_text,3))+ 9)
    IF (comment_len <= pg_width
     AND eol1=0)
     cnt_comment = (cnt_comment+ 1), stat = alterlist(data->qual[d1.seq].comments,cnt_comment), data
     ->qual[d1.seq].comments[cnt_comment].comment = comment_string,
     data->qual[d1.seq].comment_cnt = cnt_comment
    ENDIF
    IF (comment_len > pg_width
     AND eol1=0)
     temp_pos = 1
     WHILE (temp_pos <= comment_len)
       cnt_comment = (cnt_comment+ 1), stat = alterlist(data->qual[d1.seq].comments,cnt_comment),
       data->qual[d1.seq].comments[cnt_comment].comment = substring(temp_pos,pg_width,comment_string),
       data->qual[d1.seq].comment_cnt = cnt_comment, temp_pos = (temp_pos+ pg_width)
     ENDWHILE
    ENDIF
    IF (eol1 > 0)
     temp_pos = 1
     WHILE (temp_pos <= comment_len)
       cnt_comment = (cnt_comment+ 1), stat = alterlist(data->qual[d1.seq].comments,cnt_comment),
       data->qual[d1.seq].comments[cnt_comment].comment = trim(substring(temp_pos,(eol1 - temp_pos),
         comment_string),3),
       data->qual[d1.seq].comment_cnt = cnt_comment, temp_pos = (eol1+ 1), eol1 = findstring(end_line,
        comment_string,temp_pos)
       IF (eol1=0)
        eol1 = comment_len
       ENDIF
     ENDWHILE
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(ms_output)
  mrn = data->qual[d1.seq].cmrn, disch_dt_tm = format(data->qual[d1.seq].disch_dt_tm,
   "mm/dd/yyyy hh:mm;;q"), days_since_disch = cnvtstring(data->qual[d1.seq].days_since_disch),
  order_id = data->qual[d1.seq].order_id
  FROM (dummyt d1  WITH seq = data->order_cnt)
  ORDER BY mrn
  HEAD REPORT
   yrow = 15, linestr = fillstring(120,"_"), xcol1 = 40,
   xcol2 = 38, xcol3 = 94, xcol4 = 158,
   xcol5 = 228, xcol6 = 235, xcol7 = 268,
   xcol8 = 303, xcol9 = 353, xcol10 = 410,
   xcol11 = 482, x_col1 = 40, x_col2 = 30,
   x_col3 = 280, x_col4 = 332, x_col5 = 421,
   x_col6 = 476,
   MACRO (rowplusone)
    yrow = (yrow+ 10), row + 1
    IF (yrow > 600)
     yrow = 15, BREAK
    ENDIF
   ENDMACRO
   ,
   MACRO (rowplusone2)
    yrow = (yrow+ 10), row + 1
   ENDMACRO
  HEAD PAGE
   yrow = 15, "{f/8}{cpi/14}{lpi/8}", row + 1,
   CALL print(calcpos(xcol2,yrow)), "{b}UNSIGNED ORDERS FOR {endb}", data->qual[d1.seq].pt_name,
   rowplusone2, rowplusone2,
   CALL print(calcpos(xcol1,yrow)),
   linestr, rowplusone2,
   CALL print(calcpos(xcol1,yrow)),
   "{b/4}Name",
   CALL print(calcpos(xcol6,yrow)), "{b/3}MRN",
   CALL print(calcpos(xcol7,yrow)), "{b/4}CMRN",
   CALL print(calcpos(xcol8,yrow)),
   "{b/5}ACCT#",
   CALL print(calcpos(xcol9,yrow)), "{b/11}Encntr Type",
   CALL print(calcpos(xcol10,yrow)), "{b/15}Discharge Dt/Tm",
   CALL print(calcpos(xcol11,yrow)),
   "{b/20}Days Since Discharge", rowplusone2,
   CALL print(calcpos(x_col1,yrow)),
   "{b/5}Order",
   CALL print(calcpos(x_col3,yrow)), "{b/8}Order ID",
   CALL print(calcpos(x_col4,yrow)), "{b/12}Order Status",
   CALL print(calcpos(x_col5,yrow)),
   "{b/13}Order Type", row + 1,
   CALL print(calcpos(x_col6,yrow)),
   "{b/28}Ordering Physician", rowplusone2,
   CALL print(calcpos(x_col1,yrow)),
   "{b/12}Order Detail",
   CALL print(calcpos(xcol1,yrow)), linestr,
   rowplusone2,
   CALL print(calcpos(xcol1,yrow)), "{f/8}{cpi/18}{lpi/8}",
   row + 1
  HEAD mrn
   IF ((data->order_cnt > 0))
    CALL print(calcpos(xcol1,yrow)), "{f/8}{cpi/18}{lpi/8}", row + 1,
    CALL print(calcpos(xcol1,yrow)), data->qual[d1.seq].pt_name,
    CALL print(calcpos(xcol6,yrow)),
    data->qual[d1.seq].fmrn,
    CALL print(calcpos(xcol7,yrow)), data->qual[d1.seq].cmrn,
    CALL print(calcpos(xcol8,yrow)), data->qual[d1.seq].acct_nbr,
    CALL print(calcpos(xcol9,yrow)),
    data->qual[d1.seq].encntr_type,
    CALL print(calcpos(xcol10,yrow)), disch_dt_tm
    IF ((data->qual[d1.seq].disch_dt_tm != null))
     CALL print(calcpos(xcol11,yrow)), days_since_disch
    ENDIF
    rowplusone
   ENDIF
  DETAIL
   IF ((data->order_cnt > 0))
    CALL print(calcpos(x_col1,yrow)), data->qual[d1.seq].order_mnem,
    CALL print(calcpos(x_col3,yrow)),
    data->qual[d1.seq].order_id,
    CALL print(calcpos(x_col4,yrow)), data->qual[d1.seq].ord_status
    IF ((data->qual[d1.seq].comm_type="Written"))
     CALL print(calcpos(x_col5,yrow)), "{b}", data->qual[d1.seq].comm_type,
     "{endb}"
    ELSE
     CALL print(calcpos(x_col5,yrow)), data->qual[d1.seq].comm_type
    ENDIF
    CALL print(calcpos(x_col6,yrow)), data->qual[d1.seq].ord_phys, rowplusone2,
    full_string = trim(data->qual[d1.seq].clin_display,3), temp_len = textlen(trim(data->qual[d1.seq]
      .clin_display,3)), sub_len = 150,
    temp_pos = 1
    IF (temp_len <= sub_len)
     CALL print(calcpos(x_col1,yrow)), data->qual[d1.seq].clin_display
    ELSE
     WHILE (temp_pos <= temp_len)
       temp_string = substring(temp_pos,sub_len,full_string)
       IF (temp_pos=1)
        CALL print(calcpos(x_col1,yrow)), temp_string
       ELSE
        CALL print(calcpos((x_col1+ 10),yrow)), temp_string
       ENDIF
       temp_pos = (temp_pos+ sub_len), rowplusone2
     ENDWHILE
    ENDIF
    IF ((data->qual[d1.seq].comment_cnt > 0))
     rowplusone2
     FOR (x = 1 TO data->qual[d1.seq].comment_cnt)
      IF (x=1)
       CALL print(calcpos(x_col1,yrow)), data->qual[d1.seq].comments[x].comment
      ELSE
       CALL print(calcpos((x_col1+ 38),yrow)), data->qual[d1.seq].comments[x].comment
      ENDIF
      ,rowplusone2
     ENDFOR
    ENDIF
    rowplusone, rowplusone
   ENDIF
  FOOT  mrn
   CALL print(calcpos(xcol1,yrow)), "{f/8}{cpi/14}{lpi/8}", linestr,
   rowplusone
  FOOT PAGE
   "{f/4}{cpi/12}", xcol_1 = 40, xcol_2 = 250,
   xcol_3 = 350, xcol_4 = 440, ycol = 660,
   y_jump = 12,
   CALL print(calcpos(xcol_1,ycol)), linestr,
   row + 1, "{f/4}{cpi/12}", ycol = (ycol+ y_jump),
   CALL print(calcpos(xcol_1,ycol)), "{b}Report Name: {endb}", ms_rpt_name,
   row + 1, ycol = (ycol+ y_jump),
   CALL print(calcpos(xcol_1,ycol)),
   "{b}Program Name: {endb}", prg_name = cnvtlower(curprog), prg_name,
   row + 1, ycol = ((ycol+ y_jump)+ y_jump),
   CALL print(calcpos(xcol_1,ycol)),
   "Page: ", row + 1, len = cnvtint((size("Page: ") * 4.5)),
   xcol = (xcol_1+ len),
   CALL print(calcpos(xcol,ycol)), curpage"###",
   row + 1
  FOOT REPORT
   rowplusone, rowplusone, rowplusone,
   rowplusone, rowplusone
   IF ((data->order_cnt=0))
    CALL print(calcpos(50,yrow)), "{f/8}{cpi/8}{lpi/8}",
    "* * * * * No unsigned orders for patient with CMRN# ",
    mf_cmrn, "* * * * *"
   ELSE
    CALL print(calcpos(200,yrow)), "{f/8}{cpi/8}{lpi/8}", "* * * * * End Report * * * * *"
   ENDIF
  WITH dio = postscript, maxrow = 1000, maxcol = 300,
   landscape, nullreport
 ;end select
#exit_script
 FREE RECORD data
END GO
