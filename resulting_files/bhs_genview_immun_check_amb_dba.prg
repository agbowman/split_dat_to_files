CREATE PROGRAM bhs_genview_immun_check_amb:dba
 PROMPT
  "Person ID" = - (1)
  WITH person_id
 CALL echo("HITTING AMB PROGRAM")
 DECLARE var_person_id2 = f8 WITH protect
 IF (validate(request->person[1].person_id,0.00) <= 0.00)
  IF (cnvtreal( $1) <= 0.00)
   CALL echo("No PERSON_ID found. Exiting Script")
   GO TO exit_script
  ELSE
   SET var_person_id2 = cnvtreal( $1)
   RECORD reply(
     1 text = vc
   )
  ENDIF
 ELSE
  SET var_person_id2 = request->person[1].person_id
 ENDIF
 DECLARE active_cd = f8
 DECLARE modified_cd = f8
 DECLARE altered_cd = f8
 DECLARE auth_cd = f8
 DECLARE med_class_cd = f8
 DECLARE reply_ind = i2
 DECLARE immunizations_cd = f8
 DECLARE code_display = vc
 SET active_cd = uar_get_code_by("MEANING",8,"ACTIVE")
 SET modified_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET altered_cd = uar_get_code_by("MEANING",8,"ALTERED")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET med_class_cd = uar_get_code_by("MEANING",53,"MED")
 SET immunizations_cd = uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS")
 SET reply_ind = 0
 SET reply->text = "{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}"
 SET reply->text = build2(reply->text,"\pard\tx5040\tx7200\tx9360\f0\fs20 ",char(10),char(13))
 SET reply->text = build2(reply->text,"\b\ul Immunization View \b0\ul0\tab")
 SET reply->text = build2(reply->text,"\b\ul Admin Date \b0\ul0\tab\b\ul Patient Age \b0\ul0\par",
  char(10),char(13))
 FREE RECORD immunlist
 RECORD immunlist(
   1 dob = vc
   1 cnt_vax = i4
   1 vaccinations[*]
     2 group = vc
     2 display = vc
     2 sequence = i4
     2 datechart = dq8
 )
 CALL echo("start select")
 SELECT INTO "nl:"
  FROM v500_event_set_explode vese,
   clinical_event ce,
   code_value_group cvg,
   dummyt d1,
   code_value cv,
   person p
  PLAN (p
   WHERE p.person_id=var_person_id2)
   JOIN (ce
   WHERE ce.person_id=p.person_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
    AND ce.view_level=1)
   JOIN (vese
   WHERE vese.event_set_cd=immunizations_cd
    AND vese.event_cd=ce.event_cd)
   JOIN (d1)
   JOIN (cvg
   WHERE cvg.child_code_value=vese.event_cd
    AND cvg.parent_code_value IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=104501
     AND cv.active_ind=1
     AND cv.cdf_meaning="IMMUNEHIST")))
   JOIN (cv
   WHERE cv.code_set=104501
    AND cv.active_ind=1
    AND cv.cdf_meaning="IMMUNEHIST"
    AND cv.code_value=cvg.parent_code_value)
  ORDER BY cv.collation_seq
  HEAD REPORT
   stat = alterlist(immunlist->vaccinations,10), immunlist->dob = trim(datebirthformat(p.birth_dt_tm,
     p.birth_tz,p.birth_prec_flag,"@SHORTDATE4YR"),3)
  DETAIL
   immunlist->cnt_vax += 1
   IF (mod(immunlist->cnt_vax,10)=1
    AND (immunlist->cnt_vax > 1))
    stat = alterlist(immunlist->vaccinations,(immunlist->cnt_vax+ 9))
   ENDIF
   IF (cvg.child_code_value=0)
    immunlist->vaccinations[immunlist->cnt_vax].display = build2("{ }",trim(uar_get_code_display(ce
       .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"mm/dd/yyyy;;d"),"\tab ",
     trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ","\par",char(10),char(13)), immunlist
    ->vaccinations[immunlist->cnt_vax].group = "MISCELLANEOUS VACCINATION", immunlist->vaccinations[
    immunlist->cnt_vax].sequence = 72,
    immunlist->vaccinations[immunlist->cnt_vax].datechart = ce.event_end_dt_tm
   ELSE
    immunlist->vaccinations[immunlist->cnt_vax].display = build2("{ }",trim(uar_get_code_display(ce
       .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"mm/dd/yyyy;;d"),"\tab ",
     trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ","\par",char(10),char(13)), immunlist
    ->vaccinations[immunlist->cnt_vax].group = trim(cv.description,3), immunlist->vaccinations[
    immunlist->cnt_vax].sequence = cv.collation_seq,
    immunlist->vaccinations[immunlist->cnt_vax].datechart = ce.event_end_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(immunlist->vaccinations,immunlist->cnt_vax)
  WITH nocounter, outerjoin = d1
 ;end select
 SET reply->text = build2(reply->text,"\b\ul Date of Birth: ",immunlist->dob,"\par",char(10),
  char(13),"\b0\ul0\par")
 IF (size(immunlist->vaccinations,5) > 0)
  SELECT INTO "nl:"
   vaccinations_sequence = immunlist->vaccinations[d1.seq].sequence, chartdates = immunlist->
   vaccinations[d1.seq].datechart, vaccinations_group = substring(1,30,immunlist->vaccinations[d1.seq
    ].group)
   FROM (dummyt d1  WITH seq = size(immunlist->vaccinations,5))
   PLAN (d1)
   ORDER BY vaccinations_sequence, chartdates
   HEAD vaccinations_sequence
    reply->text = build2(reply->text,"\b\ul ",immunlist->vaccinations[d1.seq].group,"\par",char(10),
     char(13),"\b0\ul0")
   DETAIL
    reply->text = build2(reply->text,immunlist->vaccinations[d1.seq].display)
   WITH nocounter
  ;end select
  SET reply->text = build2(reply->text,"}")
 ELSE
  SET reply->text = build2(reply->text," \tab\b no immunizations found\b0}")
 ENDIF
#exit_script
 SET last_mod = "Joe Fenton Converted to custom code set"
END GO
