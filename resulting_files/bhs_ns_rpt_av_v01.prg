CREATE PROGRAM bhs_ns_rpt_av_v01
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = curdate,
  "End date" = curdate,
  "Facility" = "BMC",
  "Unit:" = 0
  WITH outdev, prompt2, prompt3,
  prompt4, prompt5
 IF (findstring("@", $1,1,0) > 0)
  SET email_ind = 1
  SET email_list =  $1
  DECLARE dclcom = vc
 ELSE
  SET email_ind = 0
 ENDIF
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE displine = vc
 FREE RECORD ords
 RECORD ords(
   1 mon
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 tue
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 wed
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 thu
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 fri
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 sat
     2 cnt = i2
     2 av = i4
     2 tot = i4
   1 sun
     2 cnt = i2
     2 av = i4
     2 tot = i4
 )
 FREE RECORD avbyunittime
 RECORD avbyunittime(
   1 ord[*]
     2 oid = f8
     2 updt = dq8
     2 av = i2
     2 fac = f8
     2 unit = f8
     2 day = c3
     2 time
       3 t1 = i2
       3 t2 = i2
       3 t3 = i2
       3 t4 = i2
       3 t5 = i2
       3 t6 = i2
       3 t7 = i2
       3 t8 = i2
       3 t9 = i2
       3 t10 = i2
       3 t11 = i2
       3 t12 = i2
       3 t13 = i2
       3 t14 = i2
       3 t15 = i2
       3 t16 = i2
       3 t17 = i2
       3 t18 = i2
       3 t19 = i2
       3 t20 = i2
       3 t21 = i2
       3 t22 = i2
       3 t23 = i2
       3 t24 = i2
 )
 SELECT INTO "nl:"
  dayofweek = format(av.updt_dt_tm,"www;;d"), t = cnvttime(av.updt_dt_tm), avind =
  IF (av.auto_verify_fail_reason_cd=0) 1
  ELSE 0
  ENDIF
  FROM rx_auto_verify_audit av,
   order_action oa
  PLAN (av
   WHERE av.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $PROMPT2),0) AND cnvtdatetime(cnvtdate(
      $PROMPT3),235959))
   JOIN (oa
   WHERE oa.order_id=av.order_id
    AND (oa.order_locn_cd= $PROMPT5))
  HEAD REPORT
   stat = alterlist(avbyunittime->ord,100), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,99)=1)
    stat = alterlist(avbyunittime->ord,(cnt+ 99))
   ENDIF
   avbyunittime->ord[cnt].oid = av.order_id, avbyunittime->ord[cnt].av = avind, avbyunittime->ord[cnt
   ].unit = oa.order_locn_cd,
   avbyunittime->ord[cnt].day = dayofweek, avbyunittime->ord[cnt].updt = av.updt_dt_tm
   IF (t >= 0
    AND t < 100)
    avbyunittime->ord[cnt].time.t1 = 1
   ELSEIF (t >= 100
    AND t < 200)
    avbyunittime->ord[cnt].time.t2 = 1
   ELSEIF (t >= 200
    AND t < 300)
    avbyunittime->ord[cnt].time.t3 = 1
   ELSEIF (t >= 300
    AND t < 400)
    avbyunittime->ord[cnt].time.t4 = 1
   ELSEIF (t >= 400
    AND t < 500)
    avbyunittime->ord[cnt].time.t5 = 1
   ELSEIF (t >= 500
    AND t < 600)
    avbyunittime->ord[cnt].time.t6 = 1
   ELSEIF (t >= 600
    AND t < 700)
    avbyunittime->ord[cnt].time.t7 = 1
   ELSEIF (t >= 700
    AND t < 800)
    avbyunittime->ord[cnt].time.t8 = 1
   ELSEIF (t >= 800
    AND t < 900)
    avbyunittime->ord[cnt].time.t9 = 1
   ELSEIF (t >= 900
    AND t < 1000)
    avbyunittime->ord[cnt].time.t10 = 1
   ELSEIF (t >= 1000
    AND t < 1100)
    avbyunittime->ord[cnt].time.t11 = 1
   ELSEIF (t >= 1100
    AND t < 1200)
    avbyunittime->ord[cnt].time.t12 = 1
   ELSEIF (t >= 1200
    AND t < 1300)
    avbyunittime->ord[cnt].time.t13 = 1
   ELSEIF (t >= 1300
    AND t < 1400)
    avbyunittime->ord[cnt].time.t14 = 1
   ELSEIF (t >= 1400
    AND t < 1500)
    avbyunittime->ord[cnt].time.t15 = 1
   ELSEIF (t >= 1500
    AND t < 1600)
    avbyunittime->ord[cnt].time.t16 = 1
   ELSEIF (t >= 1600
    AND t < 1700)
    avbyunittime->ord[cnt].time.t17 = 1
   ELSEIF (t >= 1700
    AND t < 1800)
    avbyunittime->ord[cnt].time.t18 = 1
   ELSEIF (t >= 1800
    AND t < 1900)
    avbyunittime->ord[cnt].time.t19 = 1
   ELSEIF (t >= 1900
    AND t < 2000)
    avbyunittime->ord[cnt].time.t22 = 1
   ELSEIF (t >= 2000
    AND t < 2100)
    avbyunittime->ord[cnt].time.t21 = 1
   ELSEIF (t >= 2100
    AND t < 2200)
    avbyunittime->ord[cnt].time.t22 = 1
   ELSEIF (t >= 2200
    AND t < 2300)
    avbyunittime->ord[cnt].time.t23 = 1
   ELSEIF (t >= 2300
    AND t < 2400)
    avbyunittime->ord[cnt].time.t24 = 1
   ENDIF
   CASE (dayofweek)
    OF "MON":
     ords->mon.tot = (ords->mon.tot+ 1),
     IF (avind=1)
      ords->mon.av = (ords->mon.av+ 1)
     ENDIF
    OF "TUE":
     ords->tue.tot = (ords->tue.tot+ 1),
     IF (avind=1)
      ords->tue.av = (ords->tue.av+ 1)
     ENDIF
    OF "WED":
     ords->wed.tot = (ords->wed.tot+ 1),
     IF (avind=1)
      ords->wed.av = (ords->wed.av+ 1)
     ENDIF
    OF "THU":
     ords->thu.tot = (ords->thu.tot+ 1),
     IF (avind=1)
      ords->thu.av = (ords->thu.av+ 1)
     ENDIF
    OF "FRI":
     ords->fri.tot = (ords->fri.tot+ 1),
     IF (avind=1)
      ords->fri.av = (ords->fri.av+ 1)
     ENDIF
    OF "SAT":
     ords->sat.tot = (ords->sat.tot+ 1),
     IF (avind=1)
      ords->sat.av = (ords->sat.av+ 1)
     ENDIF
    OF "SUN":
     ords->sun.tot = (ords->sun.tot+ 1),
     IF (avind=1)
      ords->sun.av = (ords->sun.av+ 1)
     ENDIF
   ENDCASE
  FOOT REPORT
   stat = alterlist(avbyunittime->ord,cnt)
  WITH nocounter
 ;end select
 IF (email_ind=0)
  SELECT INTO  $1
   unit = uar_get_code_display(avbyunittime->ord[d.seq].unit), dayofweek =
   IF ((avbyunittime->ord[d.seq].day="MON")) 1
   ELSEIF ((avbyunittime->ord[d.seq].day="TUE")) 2
   ELSEIF ((avbyunittime->ord[d.seq].day="WED")) 3
   ELSEIF ((avbyunittime->ord[d.seq].day="THU")) 4
   ELSEIF ((avbyunittime->ord[d.seq].day="FRI")) 5
   ELSEIF ((avbyunittime->ord[d.seq].day="SAT")) 6
   ELSEIF ((avbyunittime->ord[d.seq].day="SUN")) 7
   ENDIF
   , dayofweekdisp = avbyunittime->ord[d.seq].day,
   monthdisp = cnvtstring(month(avbyunittime->ord[d.seq].updt)), dayofmonth = day(avbyunittime->ord[d
    .seq].updt), oid = avbyunittime->ord[d.seq].oid,
   avind = avbyunittime->ord[d.seq].av, idx = d.seq
   FROM (dummyt d  WITH seq = value(size(avbyunittime->ord,5)))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY unit, dayofweek, dayofmonth,
    0
   HEAD REPORT
    startdate = format(cnvtdatetime(cnvtdate( $PROMPT2),0),"mm/dd/yy hh:mm;;q"), enddate = format(
     cnvtdatetime(cnvtdate( $PROMPT3),235959),"mm/dd/yy hh:mm;;q"), daycnt = 0,
    t1 = 0, t2 = 0, t3 = 0,
    t4 = 0, t5 = 0, t6 = 0,
    t7 = 0, t8 = 0, t9 = 0,
    t10 = 0, t11 = 0, t12 = 0,
    t13 = 0, t14 = 0, t15 = 0,
    t16 = 0, t17 = 0, t18 = 0,
    t19 = 0, t20 = 0, t21 = 0,
    t22 = 0, t23 = 0, t24 = 0,
    tav1 = 0, tav2 = 0, tav3 = 0,
    tav4 = 0, tav5 = 0, tav6 = 0,
    tav7 = 0, tav8 = 0, tav9 = 0,
    tav10 = 0, tav11 = 0, tav12 = 0,
    tav13 = 0, tav14 = 0, tav15 = 0,
    tav16 = 0, tav17 = 0, tav18 = 0,
    tav19 = 0, tav20 = 0, tav21 = 0,
    tav22 = 0, tav23 = 0, tav24 = 0,
    tt1 = 0, tt2 = 0, tt3 = 0,
    tt4 = 0, tt5 = 0, tt6 = 0,
    tt7 = 0, tt8 = 0, tt9 = 0,
    tt10 = 0, tt11 = 0, tt12 = 0,
    tt13 = 0, tt14 = 0, tt15 = 0,
    tt16 = 0, tt17 = 0, tt18 = 0,
    tt19 = 0, tt20 = 0, tt21 = 0,
    tt22 = 0, tt23 = 0, tt24 = 0,
    ttav1 = 0, ttav2 = 0, ttav3 = 0,
    ttav4 = 0, ttav5 = 0, ttav6 = 0,
    ttav7 = 0, ttav8 = 0, ttav9 = 0,
    ttav10 = 0, ttav11 = 0, ttav12 = 0,
    ttav13 = 0, ttav14 = 0, ttav15 = 0,
    ttav16 = 0, ttav17 = 0, ttav18 = 0,
    ttav19 = 0, ttav20 = 0, ttav21 = 0,
    ttav22 = 0, ttav23 = 0, ttav24 = 0,
    dayofmonthdisp = fillstring(5," ")
   HEAD unit
    col 0, "unit:", unit,
    row + 1
   HEAD dayofweek
    col 0, "Day:", dayofweekdisp,
    row + 1
   HEAD dayofmonth
    daycnt = (daycnt+ 1)
   DETAIL
    t1 = (t1+ avbyunittime->ord[idx].time.t1), t2 = (t2+ avbyunittime->ord[idx].time.t2), t3 = (t3+
    avbyunittime->ord[idx].time.t3),
    t4 = (t4+ avbyunittime->ord[idx].time.t4), t5 = (t5+ avbyunittime->ord[idx].time.t5), t6 = (t6+
    avbyunittime->ord[idx].time.t6),
    t7 = (t7+ avbyunittime->ord[idx].time.t7), t8 = (t8+ avbyunittime->ord[idx].time.t8), t9 = (t9+
    avbyunittime->ord[idx].time.t9),
    t10 = (t10+ avbyunittime->ord[idx].time.t10), t11 = (t11+ avbyunittime->ord[idx].time.t11), t12
     = (t12+ avbyunittime->ord[idx].time.t12),
    t13 = (t13+ avbyunittime->ord[idx].time.t13), t14 = (t14+ avbyunittime->ord[idx].time.t14), t15
     = (t15+ avbyunittime->ord[idx].time.t15),
    t16 = (t16+ avbyunittime->ord[idx].time.t16), t17 = (t17+ avbyunittime->ord[idx].time.t17), t18
     = (t18+ avbyunittime->ord[idx].time.t18),
    t19 = (t19+ avbyunittime->ord[idx].time.t19), t20 = (t20+ avbyunittime->ord[idx].time.t20), t21
     = (t21+ avbyunittime->ord[idx].time.t21),
    t22 = (t22+ avbyunittime->ord[idx].time.t22), t23 = (t23+ avbyunittime->ord[idx].time.t23), t24
     = (t24+ avbyunittime->ord[idx].time.t24),
    tt1 = (tt1+ avbyunittime->ord[idx].time.t1), tt2 = (tt2+ avbyunittime->ord[idx].time.t2), tt3 = (
    tt3+ avbyunittime->ord[idx].time.t3),
    tt4 = (tt4+ avbyunittime->ord[idx].time.t4), tt5 = (tt5+ avbyunittime->ord[idx].time.t5), tt6 = (
    tt6+ avbyunittime->ord[idx].time.t6),
    tt7 = (tt7+ avbyunittime->ord[idx].time.t7), tt8 = (tt8+ avbyunittime->ord[idx].time.t8), tt9 = (
    tt9+ avbyunittime->ord[idx].time.t9),
    tt10 = (tt10+ avbyunittime->ord[idx].time.t10), tt11 = (tt11+ avbyunittime->ord[idx].time.t11),
    tt12 = (tt12+ avbyunittime->ord[idx].time.t12),
    tt13 = (tt13+ avbyunittime->ord[idx].time.t13), tt14 = (tt14+ avbyunittime->ord[idx].time.t14),
    tt15 = (tt15+ avbyunittime->ord[idx].time.t15),
    tt16 = (tt16+ avbyunittime->ord[idx].time.t16), tt17 = (tt17+ avbyunittime->ord[idx].time.t17),
    tt18 = (tt18+ avbyunittime->ord[idx].time.t18),
    tt19 = (tt19+ avbyunittime->ord[idx].time.t19), tt20 = (tt20+ avbyunittime->ord[idx].time.t20),
    tt21 = (tt21+ avbyunittime->ord[idx].time.t21),
    tt22 = (tt22+ avbyunittime->ord[idx].time.t22), tt23 = (tt23+ avbyunittime->ord[idx].time.t23),
    tt24 = (tt24+ avbyunittime->ord[idx].time.t24)
    IF (avind=1)
     tav1 = (tav1+ avbyunittime->ord[idx].time.t1), tav2 = (tav2+ avbyunittime->ord[idx].time.t2),
     tav3 = (tav3+ avbyunittime->ord[idx].time.t3),
     tav4 = (tav4+ avbyunittime->ord[idx].time.t4), tav5 = (tav5+ avbyunittime->ord[idx].time.t5),
     tav6 = (tav6+ avbyunittime->ord[idx].time.t6),
     tav7 = (tav7+ avbyunittime->ord[idx].time.t7), tav8 = (tav8+ avbyunittime->ord[idx].time.t8),
     tav9 = (tav9+ avbyunittime->ord[idx].time.t9),
     tav10 = (tav10+ avbyunittime->ord[idx].time.t10), tav11 = (tav11+ avbyunittime->ord[idx].time.
     t11), tav12 = (tav12+ avbyunittime->ord[idx].time.t12),
     tav13 = (tav13+ avbyunittime->ord[idx].time.t13), tav14 = (tav14+ avbyunittime->ord[idx].time.
     t14), tav15 = (tav15+ avbyunittime->ord[idx].time.t15),
     tav16 = (tav16+ avbyunittime->ord[idx].time.t16), tav17 = (tav17+ avbyunittime->ord[idx].time.
     t17), tav18 = (tav18+ avbyunittime->ord[idx].time.t18),
     tav19 = (tav19+ avbyunittime->ord[idx].time.t19), tav20 = (tav20+ avbyunittime->ord[idx].time.
     t20), tav21 = (tav21+ avbyunittime->ord[idx].time.t21),
     tav22 = (tav22+ avbyunittime->ord[idx].time.t22), tav23 = (tav23+ avbyunittime->ord[idx].time.
     t23), tav24 = (tav24+ avbyunittime->ord[idx].time.t24),
     ttav1 = (ttav1+ avbyunittime->ord[idx].time.t1), ttav2 = (ttav2+ avbyunittime->ord[idx].time.t2),
     ttav3 = (ttav3+ avbyunittime->ord[idx].time.t3),
     ttav4 = (ttav4+ avbyunittime->ord[idx].time.t4), ttav5 = (ttav5+ avbyunittime->ord[idx].time.t5),
     ttav6 = (ttav6+ avbyunittime->ord[idx].time.t6),
     ttav7 = (ttav7+ avbyunittime->ord[idx].time.t7), ttav8 = (ttav8+ avbyunittime->ord[idx].time.t8),
     ttav9 = (ttav9+ avbyunittime->ord[idx].time.t9),
     ttav10 = (ttav10+ avbyunittime->ord[idx].time.t10), ttav11 = (ttav11+ avbyunittime->ord[idx].
     time.t11), ttav12 = (ttav12+ avbyunittime->ord[idx].time.t12),
     ttav13 = (ttav13+ avbyunittime->ord[idx].time.t13), ttav14 = (ttav14+ avbyunittime->ord[idx].
     time.t14), ttav15 = (ttav15+ avbyunittime->ord[idx].time.t15),
     ttav16 = (ttav16+ avbyunittime->ord[idx].time.t16), ttav17 = (ttav17+ avbyunittime->ord[idx].
     time.t17), ttav18 = (ttav18+ avbyunittime->ord[idx].time.t18),
     ttav19 = (ttav19+ avbyunittime->ord[idx].time.t19), ttav20 = (ttav20+ avbyunittime->ord[idx].
     time.t20), ttav21 = (ttav21+ avbyunittime->ord[idx].time.t21),
     ttav22 = (ttav22+ avbyunittime->ord[idx].time.t22), ttav23 = (ttav23+ avbyunittime->ord[idx].
     time.t23), ttav24 = (ttav24+ avbyunittime->ord[idx].time.t24)
    ENDIF
   FOOT  dayofmonth
    dayofmonthdisp = build(monthdisp,"/",cnvtstring(dayofmonth)), col 6, dayofmonthdisp,
    row + 0, col 15, "T1",
    row + 0, col 20, "T2",
    row + 0, col 25, "T3",
    row + 0, col 30, "T4",
    row + 0, col 35, "T5",
    row + 0, col 40, "T6",
    row + 0, col 45, "T7",
    row + 0, col 50, "T8",
    row + 0, col 55, "T9",
    row + 0, col 60, "T10",
    row + 0, col 65, "T11",
    row + 0, col 70, "T12",
    row + 0, col 75, "T13",
    row + 0, col 80, "T14",
    row + 0, col 85, "T15",
    row + 0, col 90, "T16",
    row + 0, col 95, "T17",
    row + 0, col 100, "T18",
    row + 0, col 105, "T19",
    row + 0, col 110, "T20",
    row + 0, col 115, "T21",
    row + 0, col 120, "T22",
    row + 0, col 125, "T23",
    row + 0, col 130, "T24",
    row + 1, col 10, "AV",
    row + 0, col 15, tav1"#####;l",
    row + 0, col 20, tav2"#####;l",
    row + 0, col 25, tav3"#####;l",
    row + 0, col 30, tav4"#####;l",
    row + 0, col 35, tav5"#####;l",
    row + 0, col 40, tav6"#####;l",
    row + 0, col 45, tav7"#####;l",
    row + 0, col 50, tav8"#####;l",
    row + 0, col 55, tav9"#####;l",
    row + 0, col 60, tav10"#####;l",
    row + 0, col 65, tav11"#####;l",
    row + 0, col 70, tav12"#####;l",
    row + 0, col 75, tav13"#####;l",
    row + 0, col 80, tav14"#####;l",
    row + 0, col 85, tav15"#####;l",
    row + 0, col 90, tav16"#####;l",
    row + 0, col 95, tav17"#####;l",
    row + 0, col 100, tav18"#####;l",
    row + 0, col 105, tav19"#####;l",
    row + 0, col 110, tav20"#####;l",
    row + 0, col 115, tav21"#####;l",
    row + 0, col 120, tav22"#####;l",
    row + 0, col 125, tav23"#####;l",
    row + 0, col 130, tav24"#####;l",
    row + 1, col 10, "T",
    col 15, t1"#####;l", row + 0,
    col 20, t2"#####;l", row + 0,
    col 25, t3"#####;l", row + 0,
    col 30, t4"#####;l", row + 0,
    col 35, t5"#####;l", row + 0,
    col 40, t6"#####;l", row + 0,
    col 45, t7"#####;l", row + 0,
    col 50, t8"#####;l", row + 0,
    col 55, t9"#####;l", row + 0,
    col 60, t10"#####;l", row + 0,
    col 65, t11"#####;l", row + 0,
    col 70, t12"#####;l", row + 0,
    col 75, t13"#####;l", row + 0,
    col 80, t14"#####;l", row + 0,
    col 85, t15"#####;l", row + 0,
    col 90, t16"#####;l", row + 0,
    col 95, t17"#####;l", row + 0,
    col 100, t18"#####;l", row + 0,
    col 105, t19"#####;l", row + 0,
    col 110, t20"#####;l", row + 0,
    col 115, t21"#####;l", row + 0,
    col 120, t22"#####;l", row + 0,
    col 125, t23"#####;l", row + 0,
    col 130, t24"#####;l", row + 1,
    t1 = 0, t2 = 0, t3 = 0,
    t4 = 0, t5 = 0, t6 = 0,
    t7 = 0, t8 = 0, t9 = 0,
    t10 = 0, t11 = 0, t12 = 0,
    t13 = 0, t14 = 0, t15 = 0,
    t16 = 0, t17 = 0, t18 = 0,
    t19 = 0, t20 = 0, t21 = 0,
    t22 = 0, t23 = 0, t24 = 0,
    tav1 = 0, tav2 = 0, tav3 = 0,
    tav4 = 0, tav5 = 0, tav6 = 0,
    tav7 = 0, tav8 = 0, tav9 = 0,
    tav10 = 0, tav11 = 0, tav12 = 0,
    tav13 = 0, tav14 = 0, tav15 = 0,
    tav16 = 0, tav17 = 0, tav18 = 0,
    tav19 = 0, tav20 = 0, tav21 = 0,
    tav22 = 0, tav23 = 0, tav24 = 0
   FOOT  dayofweek
    col 0, "Totals", row + 1,
    col 10, "AV", row + 0,
    col 15, ttav1"#####;l", row + 0,
    col 20, ttav2"#####;l", row + 0,
    col 25, ttav3"#####;l", row + 0,
    col 30, ttav4"#####;l", row + 0,
    col 35, ttav5"#####;l", row + 0,
    col 40, ttav6"#####;l", row + 0,
    col 45, ttav7"#####;l", row + 0,
    col 50, ttav8"#####;l", row + 0,
    col 55, ttav9"#####;l", row + 0,
    col 60, ttav10"#####;l", row + 0,
    col 65, ttav11"#####;l", row + 0,
    col 70, ttav12"#####;l", row + 0,
    col 75, ttav13"#####;l", row + 0,
    col 80, ttav14"#####;l", row + 0,
    col 85, ttav15"#####;l", row + 0,
    col 90, ttav16"#####;l", row + 0,
    col 95, ttav17"#####;l", row + 0,
    col 100, ttav18"#####;l", row + 0,
    col 105, ttav19"#####;l", row + 0,
    col 110, ttav20"#####;l", row + 0,
    col 115, ttav21"#####;l", row + 0,
    col 120, ttav22"#####;l", row + 0,
    col 125, ttav23"#####;l", row + 0,
    col 130, ttav24"#####;l", row + 1,
    col 10, "T", row + 0,
    col 15, tt1"#####;l", row + 0,
    col 20, tt2"#####;l", row + 0,
    col 25, tt3"#####;l", row + 0,
    col 30, tt4"#####;l", row + 0,
    col 35, tt5"#####;l", row + 0,
    col 40, tt6"#####;l", row + 0,
    col 45, tt7"#####;l", row + 0,
    col 50, tt8"#####;l", row + 0,
    col 55, tt9"#####;l", row + 0,
    col 60, tt10"#####;l", row + 0,
    col 65, tt11"#####;l", row + 0,
    col 70, tt12"#####;l", row + 0,
    col 75, tt13"#####;l", row + 0,
    col 80, tt14"#####;l", row + 0,
    col 85, tt15"#####;l", row + 0,
    col 90, tt16"#####;l", row + 0,
    col 95, tt17"#####;l", row + 0,
    col 100, tt18"#####;l", row + 0,
    col 105, tt19"#####;l", row + 0,
    col 110, tt20"#####;l", row + 0,
    col 115, tt21"#####;l", row + 0,
    col 120, tt22"#####;l", row + 0,
    col 125, tt23"#####;l", row + 0,
    col 130, tt24"#####;l", row + 1,
    tt1 = 0, tt2 = 0, tt3 = 0,
    tt4 = 0, tt5 = 0, tt6 = 0,
    tt7 = 0, tt8 = 0, tt9 = 0,
    tt10 = 0, tt11 = 0, tt12 = 0,
    tt13 = 0, tt14 = 0, tt15 = 0,
    tt16 = 0, tt17 = 0, tt18 = 0,
    tt19 = 0, tt20 = 0, tt21 = 0,
    tt22 = 0, tt23 = 0, tt24 = 0,
    ttav1 = 0, ttav2 = 0, ttav3 = 0,
    ttav4 = 0, ttav5 = 0, ttav6 = 0,
    ttav7 = 0, ttav8 = 0, ttav9 = 0,
    ttav10 = 0, ttav11 = 0, ttav12 = 0,
    ttav13 = 0, ttav14 = 0, ttav15 = 0,
    ttav16 = 0, ttav17 = 0, ttav18 = 0,
    ttav19 = 0, ttav20 = 0, ttav21 = 0,
    ttav22 = 0, ttav23 = 0, ttav24 = 0
   FOOT REPORT
    col 0, "Totals for ", startdate,
    " to ", enddate, row + 1,
    col 20, "Mon", col 30,
    "Tue", col 40, "Wed",
    col 50, "Thu", col 60,
    "Fri", col 70, "Sat",
    col 80, "Sun", row + 1,
    col 10, "AV", row + 0,
    col 20, ords->mon.av"#####;l", col 30,
    ords->tue.av"#####;l", col 40, ords->wed.av"#####;l",
    col 50, ords->thu.av"#####;l", col 60,
    ords->fri.av"#####;l", col 70, ords->sat.av"#####;l",
    col 80, ords->sun.av"#####;l", row + 1,
    col 10, "T", row + 0,
    col 20, ords->mon.tot"#####;l", col 30,
    ords->tue.tot"#####;l", col 40, ords->wed.tot"#####;l",
    col 50, ords->thu.tot"#####;l", col 60,
    ords->fri.tot"#####;l", col 70, ords->sat.tot"#####;l",
    col 80, ords->sun.tot"#####;l", row + 1
   WITH nocounter, maxcol = 500, time = 500
  ;end select
 ELSE
  SELECT INTO "phaavstats.xls"
   unit = uar_get_code_display(avbyunittime->ord[d.seq].unit), dayofweek =
   IF ((avbyunittime->ord[d.seq].day="MON")) 1
   ELSEIF ((avbyunittime->ord[d.seq].day="TUE")) 2
   ELSEIF ((avbyunittime->ord[d.seq].day="WED")) 3
   ELSEIF ((avbyunittime->ord[d.seq].day="THU")) 4
   ELSEIF ((avbyunittime->ord[d.seq].day="FRI")) 5
   ELSEIF ((avbyunittime->ord[d.seq].day="SAT")) 6
   ELSEIF ((avbyunittime->ord[d.seq].day="SUN")) 7
   ENDIF
   , dayofweekdisp = avbyunittime->ord[d.seq].day,
   monthdisp = cnvtstring(month(avbyunittime->ord[d.seq].updt)), dayofmonth = day(avbyunittime->ord[d
    .seq].updt), oid = avbyunittime->ord[d.seq].oid,
   avind = avbyunittime->ord[d.seq].av, idx = d.seq
   FROM (dummyt d  WITH seq = value(size(avbyunittime->ord,5)))
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY unit, dayofweek, dayofmonth,
    0
   HEAD REPORT
    startdate = format(cnvtdatetime(cnvtdate( $PROMPT2),0),"mm/dd/yy hh:mm;;q"), enddate = format(
     cnvtdatetime(cnvtdate( $PROMPT3),235959),"mm/dd/yy hh:mm;;q"), displine = concat(
     "Auto Verified Stats for ",startdate," to ",enddate),
    col 0, displine, row + 1,
    displine = build("Executive Summary AV Stats for ",startdate," to ",enddate), col 0, displine,
    row + 1, displine = build(char(9),"Mon",char(9),"Tue",char(9),
     "Wed",char(9),"Thu",char(9),"Fri",
     char(9),"Sat",char(9),"Sun"), col 0,
    displine, row + 1, displine = build("A",char(9),ords->mon.av,char(9),ords->tue.av,
     char(9),ords->wed.av,char(9),ords->thu.av,char(9),
     ords->fri.av,char(9),ords->sat.av,char(9),ords->sun.av,
     char(9)),
    col 0, displine, row + 1,
    displine = build("O",char(9),ords->mon.tot,char(9),ords->tue.tot,
     char(9),ords->wed.tot,char(9),ords->thu.tot,char(9),
     ords->fri.tot,char(9),ords->sat.tot,char(9),ords->sun.tot), col 0, displine,
    row + 1, displine = build("% Av",char(9),build(((cnvtreal(ords->mon.av)/ ords->mon.tot) * 100),
      "%"),char(9),build(((cnvtreal(ords->tue.av)/ ords->tue.tot) * 100),"%"),
     char(9),build(((cnvtreal(ords->wed.av)/ ords->wed.tot) * 100),"%"),char(9),build(((cnvtreal(
       ords->thu.av)/ ords->thu.tot) * 100),"%"),char(9),
     build(((cnvtreal(ords->fri.av)/ ords->fri.tot) * 100),"%"),char(9),build(((cnvtreal(ords->sat.
       av)/ ords->sat.tot) * 100),"%"),char(9),build(((cnvtreal(ords->sun.av)/ ords->sun.tot) * 100),
      "%"),
     char(9)), col 0,
    displine, row + 1, displine = " ",
    col 0, displine, row + 1,
    daycnt = 0, t1 = 0, t2 = 0,
    t3 = 0, t4 = 0, t5 = 0,
    t6 = 0, t7 = 0, t8 = 0,
    t9 = 0, t10 = 0, t11 = 0,
    t12 = 0, t13 = 0, t14 = 0,
    t15 = 0, t16 = 0, t17 = 0,
    t18 = 0, t19 = 0, t20 = 0,
    t21 = 0, t22 = 0, t23 = 0,
    t24 = 0, tav1 = 0, tav2 = 0,
    tav3 = 0, tav4 = 0, tav5 = 0,
    tav6 = 0, tav7 = 0, tav8 = 0,
    tav9 = 0, tav10 = 0, tav11 = 0,
    tav12 = 0, tav13 = 0, tav14 = 0,
    tav15 = 0, tav16 = 0, tav17 = 0,
    tav18 = 0, tav19 = 0, tav20 = 0,
    tav21 = 0, tav22 = 0, tav23 = 0,
    tav24 = 0, tt1 = 0, tt2 = 0,
    tt3 = 0, tt4 = 0, tt5 = 0,
    tt6 = 0, tt7 = 0, tt8 = 0,
    tt9 = 0, tt10 = 0, tt11 = 0,
    tt12 = 0, tt13 = 0, tt14 = 0,
    tt15 = 0, tt16 = 0, tt17 = 0,
    tt18 = 0, tt19 = 0, tt20 = 0,
    tt21 = 0, tt22 = 0, tt23 = 0,
    tt24 = 0, ttav1 = 0, ttav2 = 0,
    ttav3 = 0, ttav4 = 0, ttav5 = 0,
    ttav6 = 0, ttav7 = 0, ttav8 = 0,
    ttav9 = 0, ttav10 = 0, ttav11 = 0,
    ttav12 = 0, ttav13 = 0, ttav14 = 0,
    ttav15 = 0, ttav16 = 0, ttav17 = 0,
    ttav18 = 0, ttav19 = 0, ttav20 = 0,
    ttav21 = 0, ttav22 = 0, ttav23 = 0,
    ttav24 = 0, dayofmonthdisp = fillstring(5," ")
   HEAD unit
    displine = build("unit:",char(9),unit), col 0, displine,
    row + 1
   HEAD dayofweek
    displine = build("Day:",char(9),dayofweekdisp), col 0, displine,
    row + 1
   HEAD dayofmonth
    daycnt = (daycnt+ 1)
   DETAIL
    t1 = (t1+ avbyunittime->ord[idx].time.t1), t2 = (t2+ avbyunittime->ord[idx].time.t2), t3 = (t3+
    avbyunittime->ord[idx].time.t3),
    t4 = (t4+ avbyunittime->ord[idx].time.t4), t5 = (t5+ avbyunittime->ord[idx].time.t5), t6 = (t6+
    avbyunittime->ord[idx].time.t6),
    t7 = (t7+ avbyunittime->ord[idx].time.t7), t8 = (t8+ avbyunittime->ord[idx].time.t8), t9 = (t9+
    avbyunittime->ord[idx].time.t9),
    t10 = (t10+ avbyunittime->ord[idx].time.t10), t11 = (t11+ avbyunittime->ord[idx].time.t11), t12
     = (t12+ avbyunittime->ord[idx].time.t12),
    t13 = (t13+ avbyunittime->ord[idx].time.t13), t14 = (t14+ avbyunittime->ord[idx].time.t14), t15
     = (t15+ avbyunittime->ord[idx].time.t15),
    t16 = (t16+ avbyunittime->ord[idx].time.t16), t17 = (t17+ avbyunittime->ord[idx].time.t17), t18
     = (t18+ avbyunittime->ord[idx].time.t18),
    t19 = (t19+ avbyunittime->ord[idx].time.t19), t20 = (t20+ avbyunittime->ord[idx].time.t20), t21
     = (t21+ avbyunittime->ord[idx].time.t21),
    t22 = (t22+ avbyunittime->ord[idx].time.t22), t23 = (t23+ avbyunittime->ord[idx].time.t23), t24
     = (t24+ avbyunittime->ord[idx].time.t24),
    tt1 = (tt1+ avbyunittime->ord[idx].time.t1), tt2 = (tt2+ avbyunittime->ord[idx].time.t2), tt3 = (
    tt3+ avbyunittime->ord[idx].time.t3),
    tt4 = (tt4+ avbyunittime->ord[idx].time.t4), tt5 = (tt5+ avbyunittime->ord[idx].time.t5), tt6 = (
    tt6+ avbyunittime->ord[idx].time.t6),
    tt7 = (tt7+ avbyunittime->ord[idx].time.t7), tt8 = (tt8+ avbyunittime->ord[idx].time.t8), tt9 = (
    tt9+ avbyunittime->ord[idx].time.t9),
    tt10 = (tt10+ avbyunittime->ord[idx].time.t10), tt11 = (tt11+ avbyunittime->ord[idx].time.t11),
    tt12 = (tt12+ avbyunittime->ord[idx].time.t12),
    tt13 = (tt13+ avbyunittime->ord[idx].time.t13), tt14 = (tt14+ avbyunittime->ord[idx].time.t14),
    tt15 = (tt15+ avbyunittime->ord[idx].time.t15),
    tt16 = (tt16+ avbyunittime->ord[idx].time.t16), tt17 = (tt17+ avbyunittime->ord[idx].time.t17),
    tt18 = (tt18+ avbyunittime->ord[idx].time.t18),
    tt19 = (tt19+ avbyunittime->ord[idx].time.t19), tt20 = (tt20+ avbyunittime->ord[idx].time.t20),
    tt21 = (tt21+ avbyunittime->ord[idx].time.t21),
    tt22 = (tt22+ avbyunittime->ord[idx].time.t22), tt23 = (tt23+ avbyunittime->ord[idx].time.t23),
    tt24 = (tt24+ avbyunittime->ord[idx].time.t24)
    IF (avind=1)
     tav1 = (tav1+ avbyunittime->ord[idx].time.t1), tav2 = (tav2+ avbyunittime->ord[idx].time.t2),
     tav3 = (tav3+ avbyunittime->ord[idx].time.t3),
     tav4 = (tav4+ avbyunittime->ord[idx].time.t4), tav5 = (tav5+ avbyunittime->ord[idx].time.t5),
     tav6 = (tav6+ avbyunittime->ord[idx].time.t6),
     tav7 = (tav7+ avbyunittime->ord[idx].time.t7), tav8 = (tav8+ avbyunittime->ord[idx].time.t8),
     tav9 = (tav9+ avbyunittime->ord[idx].time.t9),
     tav10 = (tav10+ avbyunittime->ord[idx].time.t10), tav11 = (tav11+ avbyunittime->ord[idx].time.
     t11), tav12 = (tav12+ avbyunittime->ord[idx].time.t12),
     tav13 = (tav13+ avbyunittime->ord[idx].time.t13), tav14 = (tav14+ avbyunittime->ord[idx].time.
     t14), tav15 = (tav15+ avbyunittime->ord[idx].time.t15),
     tav16 = (tav16+ avbyunittime->ord[idx].time.t16), tav17 = (tav17+ avbyunittime->ord[idx].time.
     t17), tav18 = (tav18+ avbyunittime->ord[idx].time.t18),
     tav19 = (tav19+ avbyunittime->ord[idx].time.t19), tav20 = (tav20+ avbyunittime->ord[idx].time.
     t20), tav21 = (tav21+ avbyunittime->ord[idx].time.t21),
     tav22 = (tav22+ avbyunittime->ord[idx].time.t22), tav23 = (tav23+ avbyunittime->ord[idx].time.
     t23), tav24 = (tav24+ avbyunittime->ord[idx].time.t24),
     ttav1 = (ttav1+ avbyunittime->ord[idx].time.t1), ttav2 = (ttav2+ avbyunittime->ord[idx].time.t2),
     ttav3 = (ttav3+ avbyunittime->ord[idx].time.t3),
     ttav4 = (ttav4+ avbyunittime->ord[idx].time.t4), ttav5 = (ttav5+ avbyunittime->ord[idx].time.t5),
     ttav6 = (ttav6+ avbyunittime->ord[idx].time.t6),
     ttav7 = (ttav7+ avbyunittime->ord[idx].time.t7), ttav8 = (ttav8+ avbyunittime->ord[idx].time.t8),
     ttav9 = (ttav9+ avbyunittime->ord[idx].time.t9),
     ttav10 = (ttav10+ avbyunittime->ord[idx].time.t10), ttav11 = (ttav11+ avbyunittime->ord[idx].
     time.t11), ttav12 = (ttav12+ avbyunittime->ord[idx].time.t12),
     ttav13 = (ttav13+ avbyunittime->ord[idx].time.t13), ttav14 = (ttav14+ avbyunittime->ord[idx].
     time.t14), ttav15 = (ttav15+ avbyunittime->ord[idx].time.t15),
     ttav16 = (ttav16+ avbyunittime->ord[idx].time.t16), ttav17 = (ttav17+ avbyunittime->ord[idx].
     time.t17), ttav18 = (ttav18+ avbyunittime->ord[idx].time.t18),
     ttav19 = (ttav19+ avbyunittime->ord[idx].time.t19), ttav20 = (ttav20+ avbyunittime->ord[idx].
     time.t20), ttav21 = (ttav21+ avbyunittime->ord[idx].time.t21),
     ttav22 = (ttav22+ avbyunittime->ord[idx].time.t22), ttav23 = (ttav23+ avbyunittime->ord[idx].
     time.t23), ttav24 = (ttav24+ avbyunittime->ord[idx].time.t24)
    ENDIF
   FOOT  dayofmonth
    dayofmonthdisp = build(monthdisp,"/",cnvtstring(dayofmonth)), displine = build(dayofmonthdisp,
     char(9),"T1",char(9),"T2",
     char(9),"T3",char(9),"T4",char(9),
     "T5",char(9),"T6",char(9),"T7",
     char(9),"T8",char(9),"T9",char(9),
     "T10",char(9),"T11",char(9),"T12",
     char(9),"T13",char(9),"T14",char(9),
     "T15",char(9),"T16",char(9),"T17",
     char(9),"T18",char(9),"T19",char(9),
     "T20",char(9),"T21",char(9),"T22",
     char(9),"T23",char(9),"T24"), col 0,
    displine, row + 1, displine = build("A",char(9),tav1,char(9),tav2,
     char(9),tav3,char(9),tav4,char(9),
     tav5,char(9),tav6,char(9),tav7,
     char(9),tav8,char(9),tav9,char(9),
     tav10,char(9),tav11,char(9),tav12,
     char(9),tav13,char(9),tav14,char(9),
     tav15,char(9),tav16,char(9),tav17,
     char(9),tav18,char(9),tav19,char(9),
     tav20,char(9),tav21,char(9),tav22,
     char(9),tav23,char(9),tav24),
    col 0, displine, row + 1,
    displine = build("O",char(9),t1,char(9),t2,
     char(9),t3,char(9),t4,char(9),
     t5,char(9),t6,char(9),t7,
     char(9),t8,char(9),t9,char(9),
     t10,char(9),t11,char(9),t12,
     char(9),t13,char(9),t14,char(9),
     t15,char(9),t16,char(9),t17,
     char(9),t18,char(9),t19,char(9),
     t20,char(9),t21,char(9),t22,
     char(9),t23,char(9),t24), col 0, displine,
    row + 1, t1 = 0, t2 = 0,
    t3 = 0, t4 = 0, t5 = 0,
    t6 = 0, t7 = 0, t8 = 0,
    t9 = 0, t10 = 0, t11 = 0,
    t12 = 0, t13 = 0, t14 = 0,
    t15 = 0, t16 = 0, t17 = 0,
    t18 = 0, t19 = 0, t20 = 0,
    t21 = 0, t22 = 0, t23 = 0,
    t24 = 0, tav1 = 0, tav2 = 0,
    tav3 = 0, tav4 = 0, tav5 = 0,
    tav6 = 0, tav7 = 0, tav8 = 0,
    tav9 = 0, tav10 = 0, tav11 = 0,
    tav12 = 0, tav13 = 0, tav14 = 0,
    tav15 = 0, tav16 = 0, tav17 = 0,
    tav18 = 0, tav19 = 0, tav20 = 0,
    tav21 = 0, tav22 = 0, tav23 = 0,
    tav24 = 0
   FOOT  dayofweek
    displine = " ", col 0, displine,
    row + 1, displine = build("Auto Verified",char(9),ttav1,char(9),ttav2,
     char(9),ttav3,char(9),ttav4,char(9),
     ttav5,char(9),ttav6,char(9),ttav7,
     char(9),ttav8,char(9),ttav9,char(9),
     ttav10,char(9),ttav11,char(9),ttav12,
     char(9),ttav13,char(9),ttav14,char(9),
     ttav15,char(9),ttav16,char(9),ttav17,
     char(9),ttav18,char(9),ttav19,char(9),
     ttav20,char(9),ttav21,char(9),ttav22,
     char(9),ttav23,char(9),ttav24), col 0,
    displine, row + 1, displine = build("Total Orders",char(9),tt1,char(9),tt2,
     char(9),tt3,char(9),tt4,char(9),
     tt5,char(9),tt6,char(9),tt7,
     char(9),tt8,char(9),tt9,char(9),
     tt10,char(9),tt11,char(9),tt12,
     char(9),tt13,char(9),tt14,char(9),
     tt15,char(9),tt16,char(9),tt17,
     char(9),tt18,char(9),tt19,char(9),
     tt20,char(9),tt21,char(9),tt22,
     char(9),tt23,char(9),tt24),
    col 0, displine, row + 1,
    displine = build("% Av",char(9),build(((cnvtreal(ttav1)/ tt1) * 100),"%"),char(9),build(((
      cnvtreal(ttav2)/ tt2) * 100),"%"),
     char(9),build(((cnvtreal(ttav3)/ tt3) * 100),"%"),char(9),build(((cnvtreal(ttav4)/ tt4) * 100),
      "%"),char(9),
     build(((cnvtreal(ttav5)/ tt5) * 100),"%"),char(9),build(((cnvtreal(ttav6)/ tt6) * 100),"%"),
     char(9),build(((cnvtreal(ttav7)/ tt7) * 100),"%"),
     char(9),build(((cnvtreal(ttav8)/ tt8) * 100),"%"),char(9),build(((cnvtreal(ttav9)/ tt9) * 100),
      "%"),char(9),
     build(((cnvtreal(ttav10)/ tt10) * 100),"%"),char(9),build(((cnvtreal(ttav11)/ tt11) * 100),"%"
      ),char(9),build(((cnvtreal(ttav12)/ tt12) * 100),"%"),
     char(9),build(((cnvtreal(ttav13)/ tt13) * 100),"%"),char(9),build(((cnvtreal(ttav14)/ tt14) *
      100),"%"),char(9),
     build(((cnvtreal(ttav15)/ tt15) * 100),"%"),char(9),build(((cnvtreal(ttav16)/ tt16) * 100),"%"
      ),char(9),build(((cnvtreal(ttav17)/ tt17) * 100),"%"),
     char(9),build(((cnvtreal(ttav18)/ tt18) * 100),"%"),char(9),build(((cnvtreal(ttav19)/ tt19) *
      100),"%"),char(9),
     build(((cnvtreal(ttav20)/ tt20) * 100),"%"),char(9),build(((cnvtreal(ttav21)/ tt21) * 100),"%"
      ),char(9),build(((cnvtreal(ttav22)/ tt22) * 100),"%"),
     char(9),build(((cnvtreal(ttav23)/ tt23) * 100),"%"),char(9),build(((cnvtreal(ttav24)/ tt24) *
      100),"%"),char(9)), col 0, displine,
    row + 1, displine = " ", col 0,
    displine, row + 1, tt1 = 0,
    tt2 = 0, tt3 = 0, tt4 = 0,
    tt5 = 0, tt6 = 0, tt7 = 0,
    tt8 = 0, tt9 = 0, tt10 = 0,
    tt11 = 0, tt12 = 0, tt13 = 0,
    tt14 = 0, tt15 = 0, tt16 = 0,
    tt17 = 0, tt18 = 0, tt19 = 0,
    tt20 = 0, tt21 = 0, tt22 = 0,
    tt23 = 0, tt24 = 0, ttav1 = 0,
    ttav2 = 0, ttav3 = 0, ttav4 = 0,
    ttav5 = 0, ttav6 = 0, ttav7 = 0,
    ttav8 = 0, ttav9 = 0, ttav10 = 0,
    ttav11 = 0, ttav12 = 0, ttav13 = 0,
    ttav14 = 0, ttav15 = 0, ttav16 = 0,
    ttav17 = 0, ttav18 = 0, ttav19 = 0,
    ttav20 = 0, ttav21 = 0, ttav22 = 0,
    ttav23 = 0, ttav24 = 0
   FOOT  unit
    displine = " ", col 0, displine,
    row + 1
   FOOT REPORT
    displine = " ", col 0, displine,
    row + 1
   WITH maxcol = 10000, formfeed = none, maxrow = 1,
    format = variable
  ;end select
  CALL echo("start of email routine")
  SET dclcom = "gzip phaavstats.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET subject_line = concat("Pha Auto Verify Stats ")
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "phaavstats.xls.gz" ',
   '-a "phaavstats.xls" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL echo(dclcom)
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("phaavstats.xls.gz")
  SET stat = remove("phaavstats.xls")
 ENDIF
END GO
