CREATE PROGRAM bhs_rpt_rad_tat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Totals Only" = 1,
  "Position" = 0,
  "Date From" = curdate,
  "Date To" = curdate,
  "ED locations" = 0,
  "Section" = 0
  WITH outdev, totalsonly, position,
  fromdate, todate, edlocation,
  section
 SET beg_date_qual = cnvtdatetime(cnvtdate( $FROMDATE),0)
 SET end_date_qual = cnvtdatetime(cnvtdate( $TODATE),235959)
 IF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 DECLARE poslogic = vc
 DECLARE seclogic = vc
 DECLARE edlogic = vc
 DECLARE totalrptcfcnt = f8
 DECLARE totalrptordcnt = f8
 DECLARE totalradiologisttat = f8
 DECLARE totalresidenttat = f8
 DECLARE comptotranstat = f8
 DECLARE transtofinaltat = f8
 DECLARE ordtat = f8
 DECLARE avetat = f8
 DECLARE sectat = f8
 DECLARE totalord = i4
 DECLARE cntsection = i4
 DECLARE cntorders = i4
 DECLARE cntresidentorders = i4
 DECLARE cntradiologistorders = i4
 SET radposition =  $POSITION
 SET radmd = uar_get_code_by("displaykey",88,"BHSRADIOLOGYMD")
 SET resident = uar_get_code_by("displaykey",88,"BHSRADRESIDENT")
 IF (( $TOTALSONLY=1))
  IF (radposition=1)
   SET poslogic = "per.position_cd = radmd"
  ELSEIF (radposition=2)
   SET poslogic = "per.position_cd = resident"
  ELSEIF (radposition=3)
   SET poslogic = "per.position_cd in ( resident,radmd)"
  ENDIF
 ELSE
  SET poslogic = "per.position_cd in ( resident,radmd)"
 ENDIF
 SET radsection =  $SECTION
 SET bmcmri = uar_get_code_by("displaykey",221,"BMCMRI")
 SET bmcct = uar_get_code_by("displaykey",221,"BMCCT")
 SET bmcdiagrad = uar_get_code_by("displaykey",221,"BMCDIAGRAD")
 SET bmcerdiag = uar_get_code_by("displaykey",221,"BMCERDIAG")
 SET bmcnm = uar_get_code_by("displaykey",221,"BMCNM")
 SET bmcvl = uar_get_code_by("displaykey",221,"BMCVL")
 SET bmcus = uar_get_code_by("displaykey",221,"BMCUS")
 SET 3300ct = uar_get_code_by("displaykey",221,"3300CT")
 SET 3300diagrad = uar_get_code_by("displaykey",221,"3300DIAGRAD")
 SET 3300nc = uar_get_code_by("displaykey",221,"3300NC")
 SET 3300us = uar_get_code_by("displaykey",221,"3300US")
 IF (radsection=1)
  SET seclogic = "oros.section_cd = BmcMRI"
 ELSEIF (radsection=2)
  SET seclogic = "oros.section_cd = BmcCT"
 ELSEIF (radsection=3)
  SET seclogic = "oros.section_cd = BmcDIAGRAD"
 ELSEIF (radsection=4)
  SET seclogic = "oros.section_cd = BmcERDIAG"
 ELSEIF (radsection=5)
  SET seclogic = "oros.section_cd = BmcNM"
 ELSEIF (radsection=6)
  SET seclogic = "oros.section_cd = BmcVL"
 ELSEIF (radsection=7)
  SET seclogic = "oros.section_cd = 3300CT"
 ELSEIF (radsection=8)
  SET seclogic = "oros.section_cd = 3300DIAGRAD"
 ELSEIF (radsection=9)
  SET seclogic = "oros.section_cd = 3300NC"
 ELSEIF (radsection=10)
  SET seclogic = "oros.section_cd = 3300US"
 ELSEIF (radsection=11)
  SET seclogic =
  "oros.section_cd IN (BmcMRI,BmcCT,BmcDIAGRAD,BmcERDIAG,BmcNM,BmcVL,BMCUS,3300CT,3300DIAGRAD,3300NC,3300US)"
 ELSEIF (radsection=12)
  SET seclogic = "oros.section_cd = BmcUS"
 ENDIF
 SET edlocation =  $EDLOCATION
 IF (edlocation=2)
  SET edlogic = "elh.loc_nurse_unit_cd  NOT IN (Eda, Edpedi, Edgta, Edmain, Edx)"
 ELSE
  SET edlogic = "elh.loc_nurse_unit_cd > 0"
 ENDIF
 SET eda = 0
 SET edpedi = 0
 SET edgta = 0
 SET edmain = 0
 SET edx = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="AMBULATORY"
   AND cv.display_key IN ("EDA", "EDPEDI", "EDGTA", "EDMAIN", "EDX")
   AND cv.active_ind=1
  DETAIL
   IF (cv.display_key="EDA")
    eda = cv.code_value
   ELSEIF (cv.display_key="EDPEDI")
    edpedi = cv.code_value
   ELSEIF (cv.display_key="EDGTA")
    edgta = cv.code_value
   ELSEIF (cv.display_key="EDMAIN")
    edmain = cv.code_value
   ELSEIF (cv.display_key="EDX")
    edx = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 FREE RECORD event
 RECORD event(
   1 sectionlist[*]
     2 section_name = vc
     2 totalorders = i4
     2 totaltatdf = f8
     2 totaltatcf = f8
     2 totaltatcd = f8
     2 totalrestatcf = f8
     2 totalradtatcf = f8
     2 countresorders = f8
     2 countradorders = f8
     2 avetatdf = f8
     2 avetatcf = f8
     2 avetatcd = f8
     2 averestatcf = f8
     2 averadtatcf = f8
     2 orderlist[*]
       3 catalog_name = vc
       3 patient_location = vc
       3 accession_nbr = c500
       3 exam_complete_dt_tm = dq8
       3 dictated_by = f8
       3 dictated_position = vc
       3 dictate_dt_tm = dq8
       3 transcribe_dt_tm = dq8
       3 position_cd = f8
       3 radiologist_id = f8
       3 radiologist_name = vc
       3 final_dt_tm = dq8
       3 trans_to_final = f8
       3 complete_to_trans = f8
       3 complete_to_final = f8
       3 person_id = f8
       3 name_full_formatted = vc
 )
 CALL echo(concat("Edlogic:",edlogic))
 CALL echo(concat("SecLogic;:",seclogic))
 CALL echo(concat("Poslogic:",poslogic))
 SELECT INTO  $OUTDEV
  section = uar_get_code_display(oros.section_cd), complete_to_final = datetimediff(oros.final_dt_tm,
   oros.exam_complete_dt_tm,3), complete_to_trans = datetimediff(oros.transcribe_dt_tm,oros
   .exam_complete_dt_tm,3),
  trans_to_final = datetimediff(oros.final_dt_tm,oros.transcribe_dt_tm,3), orders =
  uar_get_code_display(oros.catalog_cd)
  FROM omf_radmgmt_order_st oros,
   prsnl per,
   prsnl per2,
   encntr_loc_hist elh,
   rad_report rr
  PLAN (oros
   WHERE oros.final_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND parser(seclogic))
   JOIN (elh
   WHERE elh.encntr_id=oros.encntr_id
    AND oros.order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND parser(edlogic))
   JOIN (rr
   WHERE rr.order_id=oros.order_id)
   JOIN (per
   WHERE per.person_id=rr.dictated_by_id
    AND parser(poslogic))
   JOIN (per2
   WHERE per2.person_id=oros.radiologist_id)
  ORDER BY section
  HEAD REPORT
   cntsection = 0, totalord = 0, sectat = 0,
   avetat = 0, ordtat = 0, transtofinaltat = 0,
   comptotranstat = 0, totalresidenttat = 0, totalradiologisttat = 0,
   totalrptordcnt = 0, totalrptcfcnt = 0
  HEAD section
   cntsection = (cntsection+ 1), stat = alterlist(event->sectionlist,cntsection), event->sectionlist[
   cntsection].section_name = section,
   cntorders = 0, cntresidentorders = 0, cntradiologistorders = 0
  HEAD orders
   stat = 0, ordtat = 0, transtofinaltat = 0,
   comptotranstat = 0, totalresidenttat = 0, totalradiologisttat = 0
  DETAIL
   IF (complete_to_final >= 0
    AND complete_to_trans >= 0
    AND trans_to_final >= 0)
    ordtat = (ordtat+ complete_to_final), transtofinaltat = (transtofinaltat+ trans_to_final),
    comptotranstat = (comptotranstat+ complete_to_trans),
    cntorders = (cntorders+ 1)
    IF (cntorders > size(event->sectionlist[cntsection].orderlist,5))
     stat = alterlist(event->sectionlist[cntsection].orderlist,(cntorders+ 1000))
    ENDIF
    event->sectionlist[cntsection].orderlist[cntorders].catalog_name = orders, event->sectionlist[
    cntsection].orderlist[cntorders].patient_location = uar_get_code_display(elh.loc_nurse_unit_cd),
    event->sectionlist[cntsection].orderlist[cntorders].accession_nbr = oros.accession_nbr,
    event->sectionlist[cntsection].orderlist[cntorders].exam_complete_dt_tm = oros
    .exam_complete_dt_tm, event->sectionlist[cntsection].orderlist[cntorders].dictated_by = rr
    .dictated_by_id, event->sectionlist[cntsection].orderlist[cntorders].dictated_position =
    uar_get_code_display(per.position_cd),
    event->sectionlist[cntsection].orderlist[cntorders].dictate_dt_tm = oros.dictate_dt_tm, event->
    sectionlist[cntsection].orderlist[cntorders].transcribe_dt_tm = oros.transcribe_dt_tm, event->
    sectionlist[cntsection].orderlist[cntorders].position_cd = per.position_cd,
    event->sectionlist[cntsection].orderlist[cntorders].name_full_formatted = per.name_full_formatted,
    event->sectionlist[cntsection].orderlist[cntorders].radiologist_id = oros.radiologist_id, event->
    sectionlist[cntsection].orderlist[cntorders].radiologist_name = per2.name_full_formatted,
    event->sectionlist[cntsection].orderlist[cntorders].final_dt_tm = oros.final_dt_tm, event->
    sectionlist[cntsection].orderlist[cntorders].complete_to_trans = complete_to_trans, event->
    sectionlist[cntsection].orderlist[cntorders].trans_to_final = trans_to_final,
    event->sectionlist[cntsection].orderlist[cntorders].complete_to_final = complete_to_final, stat
     = alterlist(event->sectionlist[cntsection].orderlist,cntorders), totalrptordcnt = (
    totalrptordcnt+ 1),
    totalrptcfcnt = (totalrptcfcnt+ complete_to_final)
    IF ((event->sectionlist[cntsection].orderlist[cntorders].position_cd=227480046))
     totalresidenttat = (totalresidenttat+ complete_to_final), cntresidentorders = (cntresidentorders
     + 1)
    ENDIF
    IF ((event->sectionlist[cntsection].orderlist[cntorders].position_cd=228838033))
     totalradiologisttat = (totalradiologisttat+ complete_to_final), cntradiologistorders = (
     cntradiologistorders+ 1)
    ENDIF
   ENDIF
  FOOT  orders
   event->sectionlist[cntsection].totaltatcf = (event->sectionlist[cntsection].totaltatcf+ ordtat),
   event->sectionlist[cntsection].totaltatdf = (event->sectionlist[cntsection].totaltatdf+
   transtofinaltat), event->sectionlist[cntsection].totaltatcd = (event->sectionlist[cntsection].
   totaltatcd+ comptotranstat),
   event->sectionlist[cntsection].totalrestatcf = (event->sectionlist[cntsection].totalrestatcf+
   totalresidenttat), event->sectionlist[cntsection].totalradtatcf = (event->sectionlist[cntsection].
   totalradtatcf+ totalradiologisttat)
  FOOT  section
   stat = alterlist(event->sectionlist,cntsection), event->sectionlist[cntsection].totalorders =
   cntorders, event->sectionlist[cntsection].avetatdf = (event->sectionlist[cntsection].totaltatdf/
   event->sectionlist[cntsection].totalorders),
   event->sectionlist[cntsection].avetatcf = (event->sectionlist[cntsection].totaltatcf/ event->
   sectionlist[cntsection].totalorders), event->sectionlist[cntsection].avetatcd = (event->
   sectionlist[cntsection].totaltatcd/ event->sectionlist[cntsection].totalorders), event->
   sectionlist[cntsection].countresorders = cntresidentorders,
   event->sectionlist[cntsection].averestatcf = (event->sectionlist[cntsection].totalrestatcf/ event
   ->sectionlist[cntsection].countresorders), event->sectionlist[cntsection].countradorders =
   cntradiologistorders, event->sectionlist[cntsection].averadtatcf = (event->sectionlist[cntsection]
   .totalradtatcf/ event->sectionlist[cntsection].countradorders)
  FOOT REPORT
   stat = alterlist(event->sectionlist[cntsection].orderlist,cntorders)
   IF (( $TOTALSONLY=1))
    stat = alterlist(event->sectionlist,(cntsection+ 2)), event->sectionlist[(cntsection+ 2)].
    section_name = "TOTALS", event->sectionlist[(cntsection+ 2)].totalorders = totalrptordcnt,
    event->sectionlist[(cntsection+ 2)].avetatcf = (totalrptcfcnt/ totalrptordcnt)
   ENDIF
  WITH nocounter, format
 ;end select
 IF (size(event->sectionlist,5) > 0)
  IF (( $TOTALSONLY=0))
   SELECT INTO  $OUTDEV
    section = substring(1,20,event->sectionlist[d.seq].section_name), orders = substring(1,50,event->
     sectionlist[d.seq].orderlist[d1.seq].catalog_name), patient_location = substring(1,40,event->
     sectionlist[d.seq].orderlist[d1.seq].patient_location),
    accession_nbr = event->sectionlist[d.seq].orderlist[d1.seq].accession_nbr, exam_complete_date =
    format(event->sectionlist[d.seq].orderlist[d1.seq].exam_complete_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
    dictated_by = event->sectionlist[d.seq].orderlist[d1.seq].name_full_formatted,
    dictated_position = event->sectionlist[d.seq].orderlist[d1.seq].dictated_position, dictate_date
     = format(event->sectionlist[d.seq].orderlist[d1.seq].dictate_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
    transcribe_date = format(event->sectionlist[d.seq].orderlist[d1.seq].transcribe_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),
    final_by_name = event->sectionlist[d.seq].orderlist[d1.seq].radiologist_name, final_date = format
    (event->sectionlist[d.seq].orderlist[d1.seq].final_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"), total_orders
     = event->sectionlist[d.seq].totalorders,
    countresorders = event->sectionlist[d.seq].countresorders, countradorders = event->sectionlist[d
    .seq].countradorders, tat_avg_cd = event->sectionlist[d.seq].avetatcd,
    tat_avg_df = event->sectionlist[d.seq].avetatdf, tat_avg_cf = event->sectionlist[d.seq].avetatcf
    FROM (dummyt d  WITH seq = value(size(event->sectionlist,5))),
     dummyt d1
    PLAN (d
     WHERE maxrec(d1,size(event->sectionlist[d.seq].orderlist,5)))
     JOIN (d1)
    WITH nocounter, format, separator = " "
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    section = substring(1,20,event->sectionlist[d.seq].section_name), total_orders =
    IF ((event->sectionlist[d.seq].section_name IN ("", null))) ""
    ELSE format(event->sectionlist[d.seq].totalorders,"#######.##")
    ENDIF
    , tat_avg_cd =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].avetatcd,"#######.##")
    ENDIF
    ,
    tat_avg_df =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].avetatdf,"#######.##")
    ENDIF
    , tat_avg_cf =
    IF ((event->sectionlist[d.seq].section_name IN ("", null))) ""
    ELSE format(event->sectionlist[d.seq].avetatcf,"#######.##")
    ENDIF
    , total_res_tat =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].totalrestatcf,"#######.##")
    ENDIF
    ,
    total_rad_tat =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].totalradtatcf,"#######.##")
    ENDIF
    , avg_res_tat =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].averestatcf,"#######.##")
    ENDIF
    , avg_rad_tat =
    IF ((event->sectionlist[d.seq].section_name IN ("TOTALS", "", null))) ""
    ELSE format(event->sectionlist[d.seq].averadtatcf,"#######.##")
    ENDIF
    FROM (dummyt d  WITH seq = value(size(event->sectionlist,5)))
    PLAN (d
     WHERE d.seq > 0)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ENDIF
 CALL echorecord(event)
#exit_program
END GO
