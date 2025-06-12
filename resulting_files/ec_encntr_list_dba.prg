CREATE PROGRAM ec_encntr_list:dba
 PROMPT
  "Enter Output Directory                         : " = "",
  "Enter min lookback days                        : " = 5,
  "Enter max lookback days                        : " = 30,
  "Filter patients by location (1=ED, 2=Inpatient): " = 2
  WITH outdev, minlookbackdays, maxlookbackdays,
  locationfilter
 DECLARE minlookbackdays = i2 WITH noconstant( $MINLOOKBACKDAYS), protect
 DECLARE maxlookbackdays = i2 WITH noconstant( $MAXLOOKBACKDAYS), protect
 DECLARE locationfilter = i2 WITH noconstant( $LOCATIONFILTER), protect
 DECLARE ordwt = f8 WITH constant(1.0), protect
 DECLARE cewt = f8 WITH constant(0.5), protect
 DECLARE loswt = f8 WITH constant(2.0), protect
 DECLARE score = f8 WITH noconstant(0.0), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 FREE RECORD patients
 RECORD patients(
   1 patient[*]
     2 person_id = f8
     2 encntr_id = f8
     2 fin_nbr = vc
     2 los = f8
     2 ord_last_24_cnt = i4
     2 ce_last_24_cnt = i4
     2 ord_total_cnt = i4
     2 ce_total_cnt = i4
     2 score = f8
     2 qualifies = i2
 )
 IF ( NOT (validate(recreply,0)))
  RECORD recreply(
    1 patient[*]
      2 person_id = f8
      2 encntr_id = f8
      2 fin_nbr = vc
      2 los = f8
      2 ord_last_24_cnt = i4
      2 ce_last_24_cnt = i4
      2 score = f8
  )
 ENDIF
 SELECT INTO "nl:"
  o.encntr_id, ordcnt = count(oa.order_action_id)
  FROM order_action oa,
   orders o
  PLAN (oa
   WHERE oa.action_dt_tm >= cnvtdatetime((curdate - 1),curtime3)
    AND ((oa.action_sequence+ 0)=1))
   JOIN (o
   WHERE o.order_id=oa.order_id)
  GROUP BY o.encntr_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(patients->patient,cnt), patients->patient[cnt].encntr_id = o
   .encntr_id,
   patients->patient[cnt].ord_last_24_cnt = ordcnt, patients->patient[cnt].score = (ordcnt * ordwt)
  WITH nocounter
 ;end select
 IF (locationfilter=1)
  CALL echo("ED")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(patients->patient,5)),
    code_value cv,
    track_group tg,
    tracking_checkin tc,
    tracking_item ti
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=16370
     AND cv.cdf_meaning="ER")
    JOIN (tg
    WHERE tg.child_value=0
     AND tg.tracking_group_cd=cv.code_value)
    JOIN (tc
    WHERE tc.tracking_group_cd=tg.tracking_group_cd
     AND tc.checkout_dt_tm > cnvtdatetime(curdate,curtime3)
     AND tc.active_ind=1
     AND tc.checkin_dt_tm BETWEEN cnvtdatetime((curdate - maxlookbackdays),curtime3) AND cnvtdatetime
    ((curdate - minlookbackdays),curtime3))
    JOIN (ti
    WHERE ti.tracking_id=tc.tracking_id
     AND (ti.encntr_id=patients->patient[d.seq].encntr_id))
   DETAIL
    patients->patient[d.seq].qualifies = 1
   WITH nocounter
  ;end select
 ELSE
  CALL echo("Inpatients")
  SELECT INTO "nl:"
   FROM code_value_group cvg,
    code_value cv
   PLAN (cvg
    WHERE cvg.parent_code_value=dipencclass)
    JOIN (cv
    WHERE cv.code_value=cvg.child_code_value
     AND cv.code_set=71
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(ipenctypes->qual,(cnt+ 9))
    ENDIF
    ipenctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
   FOOT REPORT
    stat = alterlist(ipenctypes->qual,cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(patients->patient,5))),
    encounter e
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=patients->patient[d.seq].encntr_id)
     AND expand(idx,1,size(ipenctypes->qual,5),e.encntr_type_cd,ipenctypes->qual[idx].encntr_type_cd)
    )
   DETAIL
    patients->patient[d.seq].qualifies = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(patients->patient,5)),
   encntr_domain ed,
   encntr_alias ea
  PLAN (d
   WHERE (patients->patient[d.seq].qualifies=1))
   JOIN (ed
   WHERE (ed.encntr_id=patients->patient[d.seq].encntr_id)
    AND ed.beg_effective_dt_tm BETWEEN cnvtdatetime((curdate - maxlookbackdays),curtime3) AND
   cnvtdatetime((curdate - minlookbackdays),curtime3))
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=finnbr)
  DETAIL
   patients->patient[d.seq].person_id = ed.person_id, patients->patient[d.seq].los = datetimediff(
    cnvtdatetime(curdate,curtime3),ed.beg_effective_dt_tm), patients->patient[d.seq].score = (
   patients->patient[d.seq].score+ (patients->patient[d.seq].los * loswt)),
   patients->patient[d.seq].fin_nbr = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ce.encntr_id, cecnt = count(ce.clinical_event_id)
  FROM (dummyt d  WITH seq = size(patients->patient,5)),
   clinical_event ce
  PLAN (d
   WHERE (patients->patient[d.seq].qualifies=1)
    AND (patients->patient[d.seq].los > 0))
   JOIN (ce
   WHERE (ce.person_id=patients->patient[d.seq].person_id)
    AND (ce.encntr_id=patients->patient[d.seq].encntr_id)
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
  GROUP BY ce.encntr_id
  DETAIL
   patients->patient[d.seq].ce_last_24_cnt = cecnt, patients->patient[d.seq].score = (patients->
   patient[d.seq].score+ (cecnt * cewt))
  WITH nocounter
 ;end select
 DECLARE outfile = vc WITH noconstant(""), protect
 IF (cnvtupper( $OUTDEV)="MINE")
  SET outfile = "MINE"
 ELSE
  SET outfile = concat( $OUTDEV,"ec_encntr_list.csv")
 ENDIF
 SELECT INTO value(outfile)
  person = patients->patient[d.seq].person_id, encntr = patients->patient[d.seq].encntr_id,
  fin_number = patients->patient[d.seq].fin_nbr,
  los = patients->patient[d.seq].los, ordlast24 = patients->patient[d.seq].ord_last_24_cnt, celast24
   = patients->patient[d.seq].ce_last_24_cnt,
  score = patients->patient[d.seq].score
  FROM (dummyt d  WITH seq = size(patients->patient,5))
  PLAN (d
   WHERE (patients->patient[d.seq].qualifies=1)
    AND (patients->patient[d.seq].los > 0))
  ORDER BY score DESC
  WITH nocounter, pcformat('"',",",1), format = stream
 ;end select
 SELECT INTO "nl:"
  person = patients->patient[d.seq].person_id, encntr = patients->patient[d.seq].encntr_id,
  fin_number = patients->patient[d.seq].fin_nbr,
  los = patients->patient[d.seq].los, ordlast24 = patients->patient[d.seq].ord_last_24_cnt, celast24
   = patients->patient[d.seq].ce_last_24_cnt,
  score = patients->patient[d.seq].score
  FROM (dummyt d  WITH seq = size(patients->patient,5))
  PLAN (d
   WHERE (patients->patient[d.seq].qualifies=1)
    AND (patients->patient[d.seq].los > 0))
  ORDER BY score DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(recreply->patient,cnt), recreply->patient[cnt].encntr_id =
   patients->patient[d.seq].encntr_id
  WITH nocounter
 ;end select
END GO
