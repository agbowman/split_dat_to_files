CREATE PROGRAM bhs_ma_disch_signed_ords_ftp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a Facility:" = 673936.00
  WITH outdev, facility
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ftp
 SET cnt = 0
 FREE RECORD data
 RECORD data(
   1 order_cnt = i4
   1 person_cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 pt_name = vc
     2 birth_dt_tm = dq8
     2 fmrn = vc
     2 cmrn = vc
     2 acct_nbr = vc
     2 disch_dt_tm = dq8
     2 encntr_type = vc
     2 days_since_disch = i4
     2 location = vc
     2 orders[*]
       3 order_id = f8
       3 comm_type = vc
       3 order_mnem = vc
       3 clin_display = vc
       3 orig_ord_dt_tm = dq8
       3 ord_status = vc
       3 ord_phys = vc
       3 cosign_phys = vc
       3 cosign_dt_tm = dq8
       3 comment_cnt = i4
       3 comments[*]
         4 comment = vc
 )
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant("")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE mn_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE md_start_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE md_end_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_facility = vc WITH protect, noconstant("")
 DECLARE ms_rem_dir = vc WITH protect, noconstant("")
 DECLARE ms_dcl = vc WITH protect, noconstant("")
 SET v_fmrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET v_cmrn_cd = uar_get_code_by("MEANING",4,"CMRN")
 SET v_acct_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET v_oa_order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET rpt_name = "SIGNED ORDERS AFTER DISCHARGE"
 SET inpat_cd = uar_get_code_by("meaning",69,"INPATIENT")
 SET obs_cd = uar_get_code_by("meaning",69,"OBSERVATION")
 SET day_cd = uar_get_code_by("meaning",69,"RESEARCH")
 SET inpt_cd = uar_get_code_by("displaykey",71,"INPATIENT")
 SET daystay_cd = uar_get_code_by("displaykey",71,"DAYSTAY")
 SET disch_inp = uar_get_code_by("displaykey",71,"DISCHIP")
 SET emergency = uar_get_code_by("displaykey",71,"EMERGENCY")
 SET observation = uar_get_code_by("displaykey",71,"OBSERVATION")
 SET readmitip = uar_get_code_by("displaykey",71,"PREADMITIP")
 SET expiredip = uar_get_code_by("displaykey",71,"EXPIREDIP")
 SET discharges = uar_get_code_by("displaykey",71,"DISCHES")
 SET dischobv = uar_get_code_by("displaykey",71,"DISCHOBV")
 SET preadmitdaystay = uar_get_code_by("displaykey",71,"PREADMITDAYSTAY")
 SET reactivate = uar_get_code_by("displaykey",71,"REACTIVATE")
 SET dischdaystay = uar_get_code_by("displaykey",71,"DISCHDAYSTAY")
 SET expiredes = uar_get_code_by("displaykey",71,"EXPIREDES")
 SET expiredobv = uar_get_code_by("displaykey",71,"EXPIREDOBV")
 SET expireddaystay = uar_get_code_by("displaykey",71,"EXPIREDDAYSTAY")
 DECLARE mf_bmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_fmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_mlh_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MARY LANE HOSPITAL"))
 DECLARE mf_bnh_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE mf_bnh_rehab_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE REHABILITATION"))
 DECLARE mf_bnh_psych_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL INPATIENT PSYCHIATRY"))
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_password = vc WITH protect, constant("gJeZD64")
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 SET beg_dt_tm = cnvtdatetime((curdate - 1),0)
 SET end_dt_tm = cnvtdatetime((curdate - 1),235959)
 IF (( $FACILITY=mf_bnh_cd))
  SET ms_facility_p = build2("e.loc_facility_cd in(",mf_bnh_cd,",",mf_bnh_rehab_cd,",",
   mf_bnh_psych_cd,")")
 ELSE
  SET ms_facility_p = build2("e.loc_facility_cd = ", $FACILITY)
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value= $FACILITY)
   AND cv.code_set=220
  DETAIL
   ms_facility = cnvtlower(cv.display_key)
  WITH nocounter
 ;end select
 CASE ( $FACILITY)
  OF mf_bmc_cd:
   SET ms_rem_dir = '"CCLFTP/BMC Orders"'
  OF mf_fmc_cd:
   SET ms_rem_dir = '"CCLFTP/BFMC Orders"'
  OF mf_mlh_cd:
   SET ms_rem_dir = '"CCLFTP/MLH Orders"'
  OF mf_bnh_cd:
   SET ms_rem_dir = '"CCLFTP/NOBLE Orders"'
 ENDCASE
 FOR (mn_loop_cnt = 1 TO 3)
   CASE (mn_loop_cnt)
    OF 1:
     SET md_start_dt_tm = beg_dt_tm
     SET md_end_dt_tm = cnvtdatetime(concat(format(end_dt_tm,"dd-mmm-yyyy;;d")," 07:59:59"))
    OF 2:
     SET md_start_dt_tm = cnvtdatetime(concat(format(beg_dt_tm,"dd-mmm-yyyy;;d")," 08:00:00"))
     SET md_end_dt_tm = cnvtdatetime(concat(format(end_dt_tm,"dd-mmm-yyyy;;d")," 15:59:59"))
    OF 3:
     SET md_start_dt_tm = cnvtdatetime(concat(format(beg_dt_tm,"dd-mmm-yyyy;;d")," 16:00:00"))
     SET md_end_dt_tm = end_dt_tm
   ENDCASE
   CALL echo(concat("start: ",format(md_start_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")))
   CALL echo(concat("end:   ",format(md_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")))
   SELECT INTO "nl:"
    orv.order_id, mrn_sort = cnvtint(substring((textlen(ea2.alias) - 1),2,ea2.alias)), order_status
     = uar_get_code_display(o.order_status_cd),
    encntr_type = uar_get_code_display(e.encntr_type_cd), encntr_sort =
    IF (e.encntr_type_cd=inpt_cd) 1
    ELSEIF (e.encntr_type_cd=daystay_cd) 3
    ELSEIF (e.encntr_type_cd=disch_inp) 4
    ELSEIF (e.encntr_type_cd=dischobv) 5
    ELSEIF (e.encntr_type_cd=dischdaystay) 6
    ELSEIF (e.encntr_type_cd=discharges) 7
    ELSEIF (e.encntr_type_cd=expiredip) 8
    ELSEIF (e.encntr_type_cd=expiredobv) 9
    ELSEIF (e.encntr_type_cd=expireddaystay) 10
    ELSEIF (e.encntr_type_cd=expiredes) 11
    ELSEIF (e.encntr_type_cd=emergency) 12
    ELSEIF (e.encntr_type_cd=observation) 13
    ELSEIF (e.encntr_type_cd=reactivate) 15
    ELSE 16
    ENDIF
    , days_since_disch = datetimecmp(cnvtdatetime(sysdate),e.disch_dt_tm),
    last_loc = uar_get_code_display(e.loc_nurse_unit_cd), disch_date2 = e.disch_dt_tm
    FROM order_review orv,
     orders o,
     encounter e,
     person p,
     prsnl pr,
     encntr_alias ea1,
     encntr_alias ea2,
     person_alias pa
    PLAN (orv
     WHERE orv.updt_dt_tm BETWEEN cnvtdatetime(md_start_dt_tm) AND cnvtdatetime(md_end_dt_tm)
      AND ((orv.review_type_flag+ 0)=2)
      AND ((orv.reviewed_status_flag+ 0) != 0)
      AND ((orv.provider_id+ 0) > 0))
     JOIN (o
     WHERE o.order_id=orv.order_id
      AND o.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id
      AND e.active_ind=1
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND e.disch_dt_tm < orv.updt_dt_tm
      AND e.disch_dt_tm != null
      AND e.encntr_type_class_cd IN (inpat_cd, obs_cd, day_cd)
      AND parser(ms_facility_p))
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (pr
     WHERE pr.person_id=orv.provider_id
      AND pr.active_ind=1
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ea1
     WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
      AND ea1.encntr_alias_type_cd IN (v_acct_cd)
      AND ea1.active_ind=1
      AND ea1.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ea2
     WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
      AND ea2.encntr_alias_type_cd=v_fmrn_cd
      AND ea2.active_ind=1
      AND ea2.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND pa.person_alias_type_cd=v_cmrn_cd
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ORDER BY encntr_sort, e.disch_dt_tm, mrn_sort,
     p.person_id
    HEAD REPORT
     cnt = 0, stat = alterlist(data->qual,10), cnt2 = 0
    HEAD p.person_id
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(data->qual,(cnt+ 10))
     ENDIF
     data->qual[cnt].person_id = o.person_id, data->qual[cnt].encntr_id = o.encntr_id, data->qual[cnt
     ].pt_name = substring(1,30,p.name_full_formatted),
     data->qual[cnt].birth_dt_tm = p.birth_dt_tm, data->qual[cnt].acct_nbr = substring(1,15,trim(ea1
       .alias,3)), data->qual[cnt].fmrn = substring(1,15,trim(ea2.alias,3)),
     data->qual[cnt].cmrn = substring(1,15,trim(pa.alias,3)), data->qual[cnt].disch_dt_tm = e
     .disch_dt_tm, data->qual[cnt].encntr_type = encntr_type,
     data->qual[cnt].days_since_disch = days_since_disch, data->qual[cnt].location = last_loc, cnt2
      = 0,
     stat = alterlist(data->qual[cnt].orders,10)
    DETAIL
     cnt2 += 1
     IF (mod(cnt2,10)=1)
      stat = alterlist(data->qual[cnt].orders,(cnt2+ 10))
     ENDIF
     data->qual[cnt].orders[cnt2].order_id = o.order_id, data->qual[cnt].orders[cnt2].order_mnem =
     substring(1,40,o.order_mnemonic), data->qual[cnt].orders[cnt2].clin_display = trim(o
      .clinical_display_line,3),
     data->qual[cnt].orders[cnt2].orig_ord_dt_tm = o.orig_order_dt_tm, data->qual[cnt].orders[cnt2].
     ord_status = order_status, data->qual[cnt].orders[cnt2].cosign_phys = substring(1,30,pr
      .name_full_formatted),
     data->qual[cnt].orders[cnt2].cosign_dt_tm = orv.review_dt_tm
    FOOT  p.person_id
     stat = alterlist(data->qual[cnt].orders,cnt2)
    FOOT REPORT
     IF (cnt > 0)
      stat = alterlist(data->qual,cnt), data->order_cnt = cnt
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET pt_cnt = 0
 SET pt_cnt = size(data->qual,5)
 FOR (xx = 1 TO pt_cnt)
  SET ord_cnt = size(data->qual[xx].orders,5)
  SELECT INTO "nl:"
   oa.order_id, oa.action_sequence, comm_type = uar_get_code_display(oa.communication_type_cd)
   FROM (dummyt d1  WITH seq = value(ord_cnt)),
    order_action oa,
    prsnl pr
   PLAN (d1)
    JOIN (oa
    WHERE (oa.order_id=data->qual[xx].orders[d1.seq].order_id)
     AND oa.action_type_cd=v_oa_order_cd)
    JOIN (pr
    WHERE (pr.person_id= Outerjoin(oa.order_provider_id))
     AND pr.active_ind=1
     AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   HEAD oa.order_id
    data->qual[xx].orders[d1.seq].comm_type = comm_type, data->qual[xx].orders[d1.seq].ord_phys =
    substring(1,30,trim(pr.name_full_formatted,3))
   WITH nocounter
  ;end select
 ENDFOR
 FOR (xx = 1 TO pt_cnt)
   SELECT INTO "nl:"
    oc.order_id, lt.long_text_id
    FROM (dummyt d1  WITH seq = value(size(data->qual[xx].orders,5))),
     order_comment oc,
     long_text lt
    PLAN (d1)
     JOIN (oc
     WHERE (oc.order_id=data->qual[xx].orders[d1.seq].order_id))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    HEAD REPORT
     pg_width = 150, cr = char(13), lf = char(10),
     end_line = concat(char(13),char(10))
    HEAD lt.long_text_id
     cnt_comment = 0
    DETAIL
     IF (lt.long_text_id > 0)
      comment_string = concat("COMMENT: ",trim(check(lt.long_text),3)), eol1 = findstring(end_line,
       comment_string,1), comment_len = (textlen(trim(lt.long_text,3))+ 9)
      IF (comment_len <= pg_width
       AND eol1=0)
       cnt_comment += 1, stat = alterlist(data->qual[xx].orders[d1.seq].comments,cnt_comment), data->
       qual[xx].orders[d1.seq].comments[cnt_comment].comment = comment_string,
       data->qual[xx].orders[d1.seq].comment_cnt = cnt_comment
      ENDIF
      IF (comment_len > pg_width
       AND eol1=0)
       temp_pos = 1
       WHILE (temp_pos <= comment_len)
         cnt_comment += 1, stat = alterlist(data->qual[xx].orders[d1.seq].comments,cnt_comment), data
         ->qual[xx].orders[d1.seq].comments[cnt_comment].comment = substring(temp_pos,pg_width,
          comment_string),
         data->qual[xx].orders[d1.seq].comment_cnt = cnt_comment, temp_pos += pg_width
       ENDWHILE
      ENDIF
      IF (eol1 > 0)
       temp_pos = 1
       WHILE (temp_pos <= comment_len)
         cnt_comment += 1, stat = alterlist(data->qual[xx].orders[d1.seq].comments,cnt_comment), data
         ->qual[xx].orders[d1.seq].comments[cnt_comment].comment = trim(substring(temp_pos,(eol1 -
           temp_pos),comment_string),3),
         data->qual[xx].orders[d1.seq].comment_cnt = cnt_comment, temp_pos = (eol1+ 1), eol1 =
         findstring(end_line,comment_string,temp_pos)
         IF (eol1=0)
          eol1 = comment_len
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (xx = 1 TO pt_cnt)
   CALL pause(2)
   SET ord_cnt = size(data->qual[xx].orders,5)
   IF (ord_cnt > 0)
    SET ms_file_name = build(logical("bhscust"),"/ftp/bhs_ma_disch_signed_ords_ftp/",ms_facility,
     "_discharged_orders_",trim(format(sysdate,"mm_dd_yy_hh_mm_ss ;;d"),3),
     ".pdf")
    SELECT INTO value(ms_file_name)
     FROM (dummyt d1  WITH seq = 1)
     HEAD REPORT
      o_cnt = 0, o_cnt = size(data->qual[xx].orders,5), yrow = 15,
      linestr = fillstring(120,"_"), linestr2 = fillstring(155,"_"), xcol1 = 45,
      xcol2 = 38, xcol3 = 94, xcol4 = 158,
      xcol5 = 228, xcol6 = 235, xcol7 = 268,
      xcol8 = 303, xcol9 = 353, xcol10 = 410,
      xcol11 = 482, x_col1 = 45, x_col2 = 30,
      x_col3 = 280, x_col4 = 332, x_col5 = 421,
      x_col6 = 476,
      MACRO (rowplusone)
       yrow += 10, row + 1
       IF (yrow > 650)
        yrow = 15, BREAK
       ENDIF
      ENDMACRO
      ,
      MACRO (rowplusone2)
       yrow += 10, row + 1
      ENDMACRO
     HEAD PAGE
      yrow = 15, "{f/8}{cpi/14}{lpi/8}", row + 1,
      signing_date = format(beg_dt_tm,"mm/dd/yyyy;;d"),
      CALL print(calcpos(xcol2,yrow)), "{b}ORDERS SIGNED ON {endb}",
      signing_date, rowplusone2, rowplusone2,
      CALL print(calcpos(20,yrow)), linestr, rowplusone2,
      CALL print(calcpos(xcol1,yrow)), "{b/4}Name",
      CALL print(calcpos(xcol5,yrow)),
      "{b/3}MRN",
      CALL print(calcpos(xcol7,yrow)), "{b/4}CMRN",
      CALL print(calcpos(xcol8,yrow)), "{b/5}ACCT#",
      CALL print(calcpos(xcol9,yrow)),
      "{b/11}Encntr Type",
      CALL print(calcpos(xcol10,yrow)), "{b/15}Discharge Dt/Tm",
      CALL print(calcpos(xcol11,yrow)), "{b/20}Days Since Discharge", rowplusone2,
      CALL print(calcpos(x_col1,yrow)), "{b/5}Order",
      CALL print(calcpos(x_col3,yrow)),
      "{b/8}Order ID",
      CALL print(calcpos(x_col4,yrow)), "{b/12}Order Status",
      CALL print(calcpos(x_col5,yrow)), "{b/10}Order Type",
      CALL print(calcpos(x_col6,yrow)),
      "{b/10}Ordered By", rowplusone2,
      CALL print(calcpos(x_col1,yrow)),
      "{b/12}Order Detail",
      CALL print(calcpos(20,yrow)), linestr,
      rowplusone2,
      CALL print(calcpos(xcol1,yrow)), data->qual[xx].pt_name,
      CALL print(calcpos(xcol5,yrow)), data->qual[xx].fmrn,
      CALL print(calcpos(xcol7,yrow)),
      data->qual[xx].cmrn,
      CALL print(calcpos(xcol8,yrow)), data->qual[xx].acct_nbr,
      CALL print(calcpos(xcol9,yrow)), data->qual[xx].encntr_type, disch_dt_tm = format(data->qual[xx
       ].disch_dt_tm,"mm/dd/yyyy hh:mm;;q"),
      CALL print(calcpos(xcol10,yrow)), disch_dt_tm
      IF ((data->qual[xx].disch_dt_tm != null))
       days_since_disch = cnvtstring(data->qual[xx].days_since_disch),
       CALL print(calcpos(xcol11,yrow)), days_since_disch
      ENDIF
      yrow += 10, row + 1
     DETAIL
      "{f/8}{cpi/18}{lpi/8}", row + 1
      FOR (zz = 1 TO ord_cnt)
        IF (yrow > 650)
         BREAK
        ENDIF
        cosign_date_time = format(data->qual[xx].orders[zz].cosign_dt_tm,"mm/dd/yyyy hh:mm;;q"),
        CALL print(calcpos(x_col1,yrow)), "Cosigned by: ",
        data->qual[xx].orders[zz].cosign_phys, " on ", cosign_date_time,
        rowplusone,
        CALL print(calcpos(x_col1,yrow)), data->qual[xx].orders[zz].order_mnem,
        oid = cnvtstring(data->qual[xx].orders[zz].order_id),
        CALL print(calcpos(x_col3,yrow)), oid,
        CALL print(calcpos(x_col4,yrow)), data->qual[xx].orders[zz].ord_status
        IF ((data->qual[xx].orders[zz].comm_type="Written"))
         CALL print(calcpos(x_col5,yrow)), "{b/7}Written", row + 1
        ELSE
         CALL print(calcpos(x_col5,yrow)), data->qual[xx].orders[zz].comm_type
        ENDIF
        CALL print(calcpos(x_col6,yrow)), data->qual[xx].orders[zz].ord_phys, rowplusone,
        full_string = trim(data->qual[xx].orders[zz].clin_display,3), temp_len = textlen(trim(data->
          qual[xx].orders[zz].clin_display,3)), sub_len = 150,
        temp_pos = 1
        IF (temp_len <= sub_len)
         CALL print(calcpos(x_col1,yrow)), data->qual[xx].orders[zz].clin_display
        ELSE
         WHILE (temp_pos <= temp_len)
           temp_string = substring(temp_pos,sub_len,full_string)
           IF (temp_pos=1)
            CALL print(calcpos(x_col1,yrow)), temp_string
           ELSE
            CALL print(calcpos((x_col1+ 10),yrow)), temp_string
           ENDIF
           temp_pos += sub_len, rowplusone
         ENDWHILE
        ENDIF
        IF ((data->qual[xx].orders[zz].comment_cnt > 0))
         rowplusone
         FOR (x2 = 1 TO data->qual[xx].orders[zz].comment_cnt)
           IF (yrow > 650)
            BREAK
           ENDIF
           IF (x2=1)
            CALL print(calcpos(x_col1,yrow)), data->qual[xx].orders[zz].comments[x2].comment
           ELSE
            CALL print(calcpos((x_col1+ 38),yrow)), data->qual[xx].orders[zz].comments[x2].comment
           ENDIF
           rowplusone
         ENDFOR
        ENDIF
        rowplusone, rowplusone,
        CALL print(calcpos(20,yrow)),
        "{f/8}{cpi/18}{lpi/8}", linestr2, rowplusone
      ENDFOR
     FOOT PAGE
      "{f/4}{cpi/12}", xcol_1 = 20, xcol_2 = 250,
      xcol_3 = 350, xcol_4 = 440, ycol = 660,
      y_jump = 12,
      CALL print(calcpos(xcol_1,ycol)), linestr,
      row + 1, "{f/4}{cpi/12}", ycol += y_jump,
      CALL print(calcpos(xcol_1,ycol)), "{b}Report Name: {endb}", rpt_name,
      row + 1, ycol += y_jump,
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
       report_date = format(beg_dt_tm,"mm/dd/yyyy;;d"),
       CALL print(calcpos(50,yrow)), "{f/8}{cpi/8}{lpi/8}",
       "* * * * * No orders signed on discharged encounters for ", report_date, " * * * * *"
      ELSE
       CALL print(calcpos(200,yrow)), "{f/8}{cpi/8}{lpi/8}", "* * * * * End Report * * * * *"
      ENDIF
     WITH dio = pdf, maxrow = 1000, maxcol = 300,
      landscape, nullreport
    ;end select
   ENDIF
 ENDFOR
#exit_script
END GO
