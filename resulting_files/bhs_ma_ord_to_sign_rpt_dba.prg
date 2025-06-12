CREATE PROGRAM bhs_ma_ord_to_sign_rpt:dba
 PROMPT
  "PRINTER " = "MINE"
 RECORD dlrec(
   1 ord_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 account_nbr = c20
     2 encntr_type = c10
     2 mrn = vc
     2 cmrn = vc
     2 name_full_formatted = vc
     2 pt_name = vc
     2 disch_dt_tm = c20
     2 nurse_unit = c6
     2 room_bed = c16
     2 org_name = vc
     2 break_flag = i2
     2 activity_type_disp = vc
     2 catalog_type_sort = i4
     2 catalog_type_disp = vc
     2 order_mnemonic = vc
     2 orig_order_dt_tm = c20
     2 order_status_cd = f8
     2 order_id = f8
     2 order_status_disp = c20
     2 clinical_display_line = vc
     2 order_comment = vc
     2 order_comment_ind = f8
     2 order_person = vc
     2 order_doctor = vc
     2 sign_doctor = vc
     2 misc = vc
 )
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("meaning",6003,"ORDER"))
 DECLARE ord_comment_cd = f8 WITH public, constant(uar_get_code_by("meaning",14,"ORD COMMENT"))
 DECLARE mrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ssn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE account_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"ACCOUNT"))
 DECLARE fin_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE admitdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attenddoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE dischdaystay_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY"))
 DECLARE dischobv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE expireddaystay_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE expiredobv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE expiredip_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE dischip_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE hold_tempstring = vc WITH public, noconstant(" ")
 DECLARE line1 = vc WITH public, constant(fillstring(116,"_"))
 DECLARE equal_line = c116 WITH public, constant(fillstring(116,"_"))
 DECLARE starline = vc WITH public, constant(fillstring(71,"*"))
 DECLARE last_doc = vc WITH public, noconstant(" ")
 DECLARE last_pat = vc WITH public, noconstant(" ")
 SELECT DISTINCT INTO "nl:"
  orv.order_id, o.order_id, oa.order_id,
  comment_flag =
  IF (band(o.comment_type_mask,1)=1) 1
  ELSE 0
  ENDIF
  , action_type = substring(1,30,uar_get_code_display(oa.action_type_cd)), pt_name = substring(1,30,p
   .name_full_formatted),
  sign_doctor = substring(1,30,pl.name_full_formatted), order_person = substring(1,30,pl2
   .name_full_formatted)
  FROM order_review orv,
   orders o,
   encounter e,
   organization org,
   order_action oa,
   order_action oa2,
   person p,
   prsnl pl,
   prsnl pl2
  PLAN (orv
   WHERE orv.review_type_flag=2
    AND orv.reviewed_status_flag=0
    AND orv.provider_id > 0)
   JOIN (pl
   WHERE orv.provider_id=pl.person_id)
   JOIN (o
   WHERE o.order_id=orv.order_id)
   JOIN (e
   WHERE o.encntr_id=e.encntr_id
    AND e.encntr_type_cd IN (dischdaystay_cd, dischobv_cd, expireddaystay_cd, expiredobv_cd,
   expiredip_cd,
   dischip_cd))
   JOIN (org
   WHERE e.organization_id=org.organization_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=orv.action_sequence)
   JOIN (oa2
   WHERE oa2.order_id=o.order_id
    AND oa2.action_type_cd=order_cd)
   JOIN (pl2
   WHERE oa2.action_personnel_id=pl2.person_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY org.org_name, pl.name_full_formatted, p.person_id,
   orv.order_id, orv.action_sequence DESC
  HEAD REPORT
   c = 0
  HEAD pl.name_full_formatted
   col 1, starline, row + 1,
   "The Following to be signed by: ", sign_doctor, col 71,
   " ************", row + 1, col 1,
   starline, row + 1
  HEAD p.person_id
   col + 0
  HEAD orv.order_id
   a = 0
  DETAIL
   a = (a+ 1)
   IF (a=1)
    c = (c+ 1)
    IF (mod(c,10)=1)
     stat = alterlist(dlrec->seq,(c+ 9))
    ENDIF
    dlrec->seq[c].sign_doctor = pl.name_full_formatted, dlrec->seq[c].encntr_id = o.encntr_id, dlrec
    ->seq[c].order_person = order_person,
    dlrec->seq[c].pt_name = pt_name, dlrec->seq[c].order_id = o.order_id, dlrec->seq[c].
    order_mnemonic = substring(1,80,o.order_mnemonic),
    dlrec->seq[c].order_comment_ind = comment_flag, dlrec->seq[c].clinical_display_line = o
    .clinical_display_line, col 5,
    pt_name, row + 1, col 7,
    "ORDER ENTERED BY: ", order_person, row + 1,
    col 7, "ORDER: ", o.order_id"##########",
    " ", o.order_mnemonic, row + 1,
    col 10, o.clinical_display_line, row + 2
   ENDIF
  FOOT  orv.order_id
   col + 0
  FOOT  p.person_id
   dlrec->seq[c].break_flag = 1
  FOOT  pl.name_full_formatted
   col + 0
  FOOT REPORT
   dlrec->ord_total = c, stat = alterlist(dlrec->seq,c)
  WITH maxcol = 999
 ;end select
 SELECT INTO "nl:"
  nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), room_bed = concat(trim(uar_get_code_display
    (e.loc_room_cd)),"-",trim(uar_get_code_display(e.loc_bed_cd)))
  FROM (dummyt d  WITH seq = value(dlrec->ord_total)),
   encounter e,
   encntr_alias ea,
   person p,
   organization org,
   person_alias pa
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=dlrec->seq[d.seq].encntr_id))
   JOIN (ea
   WHERE outerjoin(e.encntr_id)=ea.encntr_id
    AND outerjoin(fin_cd)=ea.encntr_alias_type_cd
    AND ea.active_ind=outerjoin(1)
    AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (org
   WHERE e.organization_id=org.organization_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd IN (mrn_cd, cmrn_cd)
    AND pa.active_ind=1)
  DETAIL
   dlrec->seq[d.seq].account_nbr = ea.alias, dlrec->seq[d.seq].person_id = p.person_id
   IF (pa.person_alias_type_cd=mrn_cd)
    dlrec->seq[d.seq].mrn = pa.alias
   ELSEIF (pa.person_alias_type_cd=cmrn_cd)
    dlrec->seq[d.seq].cmrn = pa.alias
   ENDIF
   dlrec->seq[d.seq].nurse_unit = nurse_unit, dlrec->seq[d.seq].room_bed = room_bed, dlrec->seq[d.seq
   ].disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yy"),
   dlrec->seq[d.seq].org_name = org.org_name, dlrec->seq[d.seq].encntr_type = uar_get_code_display(e
    .encntr_type_cd)
  WITH nocounter
 ;end select
 SELECT INTO  $1
  HEAD REPORT
   "{f/8}{cpi/14}{lpi/8}", row + 1, yrow1 = 5,
   xcolvar = 0, c = 1, xcol1 = 26,
   xcol2 = 38, xcol3 = 94, xcol4 = 158,
   xcol5 = 228, xcol6 = 273, xcol7 = 328,
   xcol8 = 388, xcol9 = 428, xcol10 = 390,
   xcol11 = 440, xcol12 = 486, xcol13 = 530,
   MACRO (rowplusone)
    yrow1 = (yrow1+ 10), row + 1
    IF (yrow1 > 730)
     yrow1 = 5, BREAK
    ENDIF
   ENDMACRO
   ,
   MACRO (rowplusone2)
    yrow1 = (yrow1+ 10), row + 1
   ENDMACRO
   , lastorg = dlrec->seq[c].org_name
  HEAD PAGE
   CALL print(calcpos(xcol5,yrow1)), "{b}", dlrec->seq[c].org_name,
   "{endb}",
   CALL print(calcpos(xcol1,yrow1)), curdate,
   " ", curtime,
   CALL print(calcpos(xcol12,yrow1)),
   "PAGE ", curpage"###;l", rowplusone2,
   CALL print(calcpos(xcol2,yrow1)), "{b}ORDERS TO BE SIGNED {endb}", rowplusone2,
   CALL print(calcpos(xcol1,yrow1)), "{color/12}", equal_line,
   "{color/0}", rowplusone2, yrow1 = (yrow1+ 4),
   CALL print(calcpos(xcol1,yrow1)), "{b/4}Name",
   CALL print(calcpos(xcol6,yrow1)),
   "{b/3}MRN",
   CALL print(calcpos(xcol7,yrow1)), "{b/5}ACCT#",
   CALL print(calcpos(xcol10,yrow1)), "{b/8}Location",
   CALL print(calcpos(xcol11,yrow1)),
   "{b/4}Room",
   CALL print(calcpos(xcol12,yrow1)), "{b/4}Type",
   CALL print(calcpos(xcol13,yrow1)), "{b/10}Discharged", yrow1 = (yrow1+ 4),
   CALL print(calcpos(xcol1,yrow1)), line1, rowplusone2
  DETAIL
   FOR (c = 1 TO dlrec->ord_total)
    IF ((dlrec->seq[c].sign_doctor != last_doc))
     IF (c > 1)
      yrow1 = 5, BREAK
     ENDIF
     CALL print(calcpos(xcol1,yrow1)), "{B}ORDERS TO BE SIGNED BY: ", dlrec->seq[c].sign_doctor,
     "{endb}", rowplusone, rowplusone,
     last_doc = dlrec->seq[c].sign_doctor, last_pat = " "
    ENDIF
    ,
    IF ((dlrec->seq[c].mrn != last_pat))
     CALL print(calcpos(xcol1,yrow1)), " ", dlrec->seq[c].pt_name,
     CALL print(calcpos(xcol6,yrow1)), dlrec->seq[c].mrn,
     CALL print(calcpos(xcol7,yrow1)),
     dlrec->seq[c].account_nbr,
     CALL print(calcpos(xcol10,yrow1)), dlrec->seq[c].nurse_unit,
     CALL print(calcpos(xcol11,yrow1)), dlrec->seq[c].room_bed,
     CALL print(calcpos(xcol12,yrow1)),
     dlrec->seq[c].encntr_type,
     CALL print(calcpos(xcol13,yrow1)), dlrec->seq[c].disch_dt_tm,
     last_pat = dlrec->seq[c].mrn, rowplusone
    ENDIF
   ENDFOR
  FOOT PAGE
   row + 1
   IF ((c < dlrec->ord_total))
    IF ((dlrec->seq[c].break_flag != 1))
     CALL print(calcpos(290,740)), "Continued", row + 1
    ENDIF
   ENDIF
   CALL print(calcpos(xcol1,760)), "Page ", curpage"###",
   row + 1, ycol1 = 5
  FOOT REPORT
   ycol1 = 5
  WITH dio = postscript, maxcol = 600, maxrow = 800
 ;end select
 FREE RECORD dlrec
END GO
