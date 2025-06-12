CREATE PROGRAM bhs_genview_immun_check_tracy
 DECLARE var_person_id = f8
 IF (validate(request->person[1].person_id,0.00) <= 0.00)
  IF (cnvtreal( $1) <= 0.00)
   CALL echo("No PERSON_ID found. Exitting Script")
   GO TO exit_script
  ELSE
   SET var_person_id = cnvtreal( $1)
   RECORD reply(
     1 text = vc
   )
  ENDIF
 ELSE
  SET var_person_id = request->person[1].person_id
 ENDIF
 DECLARE active_cd = f8
 DECLARE modified_cd = f8
 DECLARE altered_cd = f8
 DECLARE auth_cd = f8
 DECLARE med_class_cd = f8
 DECLARE reply_ind = i2
 DECLARE immunizations_cd = f8
 DECLARE code_display = vc
 DECLARE vfc_status = vc
 DECLARE vis_provided_dt_tm = vc
 DECLARE vis_dt_tm = vc
 DECLARE nativeamericanalaskan_var = f8 WITH constant(uar_get_code_by("DESCRIPTION",30741,
   "Native American/Alaskan"))
 SET active_cd = uar_get_code_by("MEANING",8,"ACTIVE")
 SET modified_cd = uar_get_code_by("MEANING",8,"MODIFIED")
 SET altered_cd = uar_get_code_by("MEANING",8,"ALTERED")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET med_class_cd = uar_get_code_by("MEANING",53,"MED")
 SET immunizations_cd = uar_get_code_by("DISPLAYKEY",93,"IMMUNIZATIONS")
 SET reply_ind = 0
 SET reply->text = "{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Tahoma;}}"
 SET reply->text = build2(reply->text,"\pard\tx5040\tx7200\tx9360\f0\fs20 ",char(10),char(13))
 SET reply->text = build2(reply->text,"\b\ul Immunization \b0\ul0\tab")
 SET reply->text = build2(reply->text,"\b\ul Admin Dt \b0\ul0\tab")
 SET reply->text = build2(reply->text,"\b\ul PT Age  \b0\ul0\tab")
 SET reply->text = build2(reply->text,"\b\ul VFC Stat \b0\ul0\tab\tab")
 SET reply->text = build2(reply->text,"\b\ul VIS DT \b0\ul0\tab\tab")
 SET reply->text = build2(reply->text,"\b\ul VIS Prov DT \b0\ul0\tab\par",char(10),char(13))
 FREE RECORD immun
 RECORD immun(
   1 dob = vc
   1 anthrax_vaccination[*]
     2 display = vc
   1 bcg_vaccination[*]
     2 display = vc
   1 botulinum_toxin_type_a_vac[*]
     2 display = vc
   1 cholera_vaccination[*]
     2 display = vc
   1 dtap[*]
     2 display = vc
   1 dtp_vaccination[*]
     2 display = vc
   1 haemophilus_b_conjugate_vac[*]
     2 display = vc
   1 hepatitis_a_vaccination[*]
     2 display = vc
   1 hepatitis_b_vaccination[*]
     2 display = vc
   1 hepatitis_b_immune_glob_vaccine[*]
     2 display = vc
   1 human_papillomavirus_vaccination[*]
     2 display = vc
   1 influenza_virus_vaccination[*]
     2 display = vc
   1 japanese_encephalitis_vaccine[*]
     2 display = vc
   1 lyme_disease_vaccination[*]
     2 display = vc
   1 mmr_vaccinations[*]
     2 display = vc
   1 meningococcal_vaccination[*]
     2 display = vc
   1 miscellaneous_vaccination[*]
     2 display = vc
   1 mixed_respiratory_vaccination[*]
     2 display = vc
   1 plague_vaccination[*]
     2 display = vc
   1 pneumococcal_vaccinations[*]
     2 display = vc
   1 poliovirus_vaccination[*]
     2 display = vc
   1 rotavirus_vaccination[*]
     2 display = vc
   1 rabies_immune_globulin_vaccination[*]
     2 display = vc
   1 rabies_vaccination[*]
     2 display = vc
   1 smallpox_vaccination[*]
     2 display = vc
   1 tetanus_and_diphtheria_vaccinations[*]
     2 display = vc
   1 tetanus_toxoid_immune_glob_vaccination[*]
     2 display = vc
   1 tetanus_toxoid_vaccination[*]
     2 display = vc
   1 tdap[*]
     2 display = vc
   1 typhoid_vaccination[*]
     2 display = vc
   1 varicella_virus_vaccination[*]
     2 display = vc
   1 yellow_fever_vaccination[*]
     2 display = vc
   1 zoster_vaccination[*]
     2 display = vc
 )
 CALL echo("start select")
 SELECT DISTINCT INTO "nl:"
  p.birth_dt_tm, ce.event_cd, ce.event_end_dt_tm,
  im.vfc_status_cd, im.vis_dt_tm, im.vis_provided_on_dt_tm
  FROM person p,
   clinical_event ce,
   dummyt d,
   immunization_modifier im
  PLAN (p
   WHERE p.person_id=var_person_id)
   JOIN (ce
   WHERE p.person_id=ce.person_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (active_cd, modified_cd, altered_cd, auth_cd)
    AND  EXISTS (
   (SELECT
    vese.event_cd
    FROM v500_event_set_explode vese
    WHERE vese.event_set_cd=immunizations_cd
     AND vese.event_cd=ce.event_cd)))
   JOIN (d)
   JOIN (im
   WHERE im.person_id=ce.person_id
    AND im.vfc_status_cd > 0.0)
  ORDER BY p.birth_dt_tm, ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   cnt = 0, immun->dob = format(p.birth_dt_tm,"mm/dd/yyyy;;d")
  DETAIL
   code_display = " ", reply_ind = 1, code_display = uar_get_code_display(ce.event_cd),
   CALL echo(build2("event cd: ",code_display,";;"))
   CASE (code_display)
    OF "Biothrax (oldterm)":
     cnt = (size(immun->anthrax_vaccination,5)+ 1),stat = alterlist(immun->anthrax_vaccination,cnt),
     immun->anthrax_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      "\tab ",trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im
        .vis_provided_on_dt_tm,"mm/dd/yyyy;;d"),3),"\par",
      char(10),char(13))
    OF "diphtheria/tetanus/pertussis, acel(DTaP) ":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      "\tab ",trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im
        .vis_provided_on_dt_tm,"mm/dd/yyyy;;d"),3),"\par",
      char(10),char(13))
    OF "Diphtheria/Tet/Pertussis, Acel (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Anthrax Vaccine Adsorbed":
     cnt = (size(immun->anthrax_vaccination,5)+ 1),stat = alterlist(immun->anthrax_vaccination,cnt),
     immun->anthrax_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "TheraCys (oldterm)":
     cnt = (size(immun->bcg_vaccination,5)+ 1),stat = alterlist(immun->bcg_vaccination,cnt),immun->
     bcg_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tice BCG Vaccine (oldterm)":
     cnt = (size(immun->bcg_vaccination,5)+ 1),stat = alterlist(immun->bcg_vaccination,cnt),immun->
     bcg_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "BCG vaccine":
     cnt = (size(immun->bcg_vaccination,5)+ 1),stat = alterlist(immun->bcg_vaccination,cnt),immun->
     bcg_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Botulinum Toxin Type A Vaccine":
     cnt = (size(immun->botulinum_toxin_type_a_vac,5)+ 1),stat = alterlist(immun->
      botulinum_toxin_type_a_vac,cnt),immun->botulinum_toxin_type_a_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Botulinum Toxin Type A":
     cnt = (size(immun->botulinum_toxin_type_a_vac,5)+ 1),stat = alterlist(immun->
      botulinum_toxin_type_a_vac,cnt),immun->botulinum_toxin_type_a_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Cholera Vaccine":
     cnt = (size(immun->cholera_vaccination,5)+ 1),stat = alterlist(immun->cholera_vaccination,cnt),
     immun->cholera_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Daptacel (Dtap) (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/haemophilus/pertussis/tet/polio":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/HepB/Pertussis,Acel/Polio/Tet":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/pertussis,acel/tetanus/polio":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/Tetanus/Pertussis, Acel (Dtap)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphtheria/Haemophilus/Pertussis,Acel/Te":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/Tet/Pertussis, Acel (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth/Pertussis,Acel/Tetanus (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphtheria/Tet/Pertussis, Acel(oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Infanrix (DTaP) (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Infanrix (DTaP) Preserve Free (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Kinrix (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pediarix (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pentacel (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tripedia (DTaP) (oldterm)":
     cnt = (size(immun->dtap,5)+ 1),stat = alterlist(immun->dtap,cnt),immun->dtap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphtheria/Haemophilus/Pertussis,Whl/Tet":
     cnt = (size(immun->dtp_vaccination,5)+ 1),stat = alterlist(immun->dtp_vaccination,cnt),immun->
     dtp_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphtheria/Pertussis, Whole Cell/Tetanus":
     cnt = (size(immun->dtp_vaccination,5)+ 1),stat = alterlist(immun->dtp_vaccination,cnt),immun->
     dtp_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "ActHIB (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Comvax (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Haemophilus B conjugate (HbOC) vaccine":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Haemophilus B Conjugate Vac (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Haemophilus B Conj Vaccine (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "haemophilus b conjugate (PRP-OMP)vaccine":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "haemophilus b conjugate (PRP-T) vaccine":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Haemophilus B-Hepatitis B Vaccine":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "HibTITER (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Liquid PedvaxHIB (oldterm)":
     cnt = (size(immun->haemophilus_b_conjugate_vac,5)+ 1),stat = alterlist(immun->
      haemophilus_b_conjugate_vac,cnt),immun->haemophilus_b_conjugate_vac[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Havrix (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Havrix Pediatric (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis A Vaccine (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis A Adult Vaccine":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis A Pediatric Vaccine":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis A-Hepatitis B Vaccine":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Twinrix (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Twinrix Preservative-Free (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Vaqta (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Vaqta Pediatric (oldterm)":
     cnt = (size(immun->hepatitis_a_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_a_vaccination,cnt),immun->hepatitis_a_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Engerix-B (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Engerix-B Pediatric (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis B Vaccine (old term)":
     CALL echo("Hepatitis B Vaccine (oldterm)")cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat
      = alterlist(immun->hepatitis_b_vaccination,cnt),
     immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),
       3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "hepatitis B pediatric vaccine":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "hepatitis B adult vaccine":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis B Vaccine (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis B Vaccine":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Recombivax HB Adult (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Recomb HB Dialysis Formulation (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Recomb HB Pediatric/Adolescent (oldterm)":
     cnt = (size(immun->hepatitis_b_vaccination,5)+ 1),stat = alterlist(immun->
      hepatitis_b_vaccination,cnt),immun->hepatitis_b_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis B Immune Globulin (oldterm)":
     cnt = (size(immun->hepatitis_b_immune_glob_vaccine,5)+ 1),stat = alterlist(immun->
      hepatitis_b_immune_glob_vaccine,cnt),immun->hepatitis_b_immune_glob_vaccine[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Hepatitis B Immune Globulin":
     cnt = (size(immun->hepatitis_b_immune_glob_vaccine,5)+ 1),stat = alterlist(immun->
      hepatitis_b_immune_glob_vaccine,cnt),immun->hepatitis_b_immune_glob_vaccine[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Gardasil (oldterm)":
     cnt = (size(immun->human_papillomavirus_vaccination,5)+ 1),stat = alterlist(immun->
      human_papillomavirus_vaccination,cnt),immun->human_papillomavirus_vaccination[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Human Papillomavirus Vaccine":
     cnt = (size(immun->human_papillomavirus_vaccination,5)+ 1),stat = alterlist(immun->
      human_papillomavirus_vaccination,cnt),immun->human_papillomavirus_vaccination[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Afluria (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "influ virus vac, H1N1, inactive(oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "influ virus vac, H1N1, live(oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluvirin (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluvirin Preservative-Free (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluzone (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluzone Preservative-Free (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluzone Preservative-Free Pedi (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Influenza Vaccine (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Influenza Inactive (IM) (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Influenza Live (intranasal) (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Influenza virus vaccine, live, trivalent":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "FluMist (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Influenza Virus Vaccine (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "influenza virus vaccine, inactivated":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Fluarix (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "FluLaval (oldterm)":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "influenza virus vaccine, H1N1, inactive":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "influenza virus vaccine, H1N1, live":
     cnt = (size(immun->influenza_virus_vaccination,5)+ 1),stat = alterlist(immun->
      influenza_virus_vaccination,cnt),immun->influenza_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Japanese Encephalitis Virus Vaccine":
     cnt = (size(immun->japanese_encephalitis_vaccine,5)+ 1),stat = alterlist(immun->
      japanese_encephalitis_vaccine,cnt),immun->japanese_encephalitis_vaccine[cnt].display = build2(
      " ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"
       ),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Je-Vax (oldterm)":
     cnt = (size(immun->japanese_encephalitis_vaccine,5)+ 1),stat = alterlist(immun->
      japanese_encephalitis_vaccine,cnt),immun->japanese_encephalitis_vaccine[cnt].display = build2(
      " ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"
       ),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Lyme Disease Vaccine":
     cnt = (size(immun->lyme_disease_vaccination,5)+ 1),stat = alterlist(immun->
      lyme_disease_vaccination,cnt),immun->lyme_disease_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Attenuvax (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measles Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measle/Mump/Rubella/Varicella (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->varicella_virus_vaccination,5)+ 1),stat = alterlist(immun->
      varicella_virus_vaccination,cnt),immun->varicella_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measles/Mumps/Rubella VirusVac (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measles/Mumps/Rubella Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measles/Mumps/Rubella/VaricellaVirusVac":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->varicella_virus_vaccination,5)+ 1),stat = alterlist(immun->
      varicella_virus_vaccination,cnt),immun->varicella_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Measles-Rubella Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rubella Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Meruvax II (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "M-M-R II (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Mumps Virus Vacc (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Mumps Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Mumps-Rubella Virus Vaccine":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Mumpsvax (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "ProQuad (oldterm)":
     cnt = (size(immun->mmr_vaccinations,5)+ 1),stat = alterlist(immun->mmr_vaccinations,cnt),immun->
     mmr_vaccinations[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",
      format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13)),
     cnt = (size(immun->varicella_virus_vaccination,5)+ 1),stat = alterlist(immun->
      varicella_virus_vaccination,cnt),immun->varicella_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Menactra (oldterm)":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Meningococcal Conjugate Vaccine":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Meningococcal Poly Vacc (oldterm)":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Meningococcal Polysaccharide Vaccine":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Menomune A/C/Y/W-135 (oldterm)":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Meningitis C Vaccine":
     cnt = (size(immun->meningococcal_vaccination,5)+ 1),stat = alterlist(immun->
      meningococcal_vaccination,cnt),immun->meningococcal_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Miscellaneous Vaccine":
     cnt = (size(immun->miscellaneous_vaccination,5)+ 1),stat = alterlist(immun->
      miscellaneous_vaccination,cnt),immun->miscellaneous_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Mixed Respiratory Vaccine":
     cnt = (size(immun->mixed_respiratory_vaccination,5)+ 1),stat = alterlist(immun->
      mixed_respiratory_vaccination,cnt),immun->mixed_respiratory_vaccination[cnt].display = build2(
      " ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"
       ),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Plague Vaccine":
     cnt = (size(immun->plague_vaccination,5)+ 1),stat = alterlist(immun->plague_vaccination,cnt),
     immun->plague_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "pneumococcal 23-valent vaccine":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "pneumococcal 13-valent vaccine":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "pneumococcal 7-valent vaccine":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pneumococcal Conjugate (PCV7) (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pneumococcal Poly (PPV23) (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pneumococcal Vacc (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pneumococcal Vaccine (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Pneumovax 23 (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Prevnar (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Prevnar Inj (oldterm)":
     cnt = (size(immun->pneumococcal_vaccinations,5)+ 1),stat = alterlist(immun->
      pneumococcal_vaccinations,cnt),immun->pneumococcal_vaccinations[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Ipol (oldterm)":
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Poliovirus Vaccine, Inactivated":
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Polio Vaccine, Live":
     cnt = (size(immun->poliovirus_vaccination,5)+ 1),stat = alterlist(immun->poliovirus_vaccination,
      cnt),immun->poliovirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rotarix (oldterm)":
     cnt = (size(immun->rotavirus_vaccination,5)+ 1),stat = alterlist(immun->rotavirus_vaccination,
      cnt),immun->rotavirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "RotaTeq (oldterm)":
     cnt = (size(immun->rotavirus_vaccination,5)+ 1),stat = alterlist(immun->rotavirus_vaccination,
      cnt),immun->rotavirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rotavirus Vaccine":
     cnt = (size(immun->rotavirus_vaccination,5)+ 1),stat = alterlist(immun->rotavirus_vaccination,
      cnt),immun->rotavirus_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce
        .event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rabies Immune Globulin, Human":
     cnt = (size(immun->rabies_immune_globulin_vaccination,5)+ 1),stat = alterlist(immun->
      rabies_immune_globulin_vaccination,cnt),immun->rabies_immune_globulin_vaccination[cnt].display
      = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rabies Immune Globulin, Human (oldterm)":
     cnt = (size(immun->rabies_immune_globulin_vaccination,5)+ 1),stat = alterlist(immun->
      rabies_immune_globulin_vaccination,cnt),immun->rabies_immune_globulin_vaccination[cnt].display
      = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Imovax Rabies (oldterm)":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "RabAvert (oldterm)":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rabies Vacc (oldterm)":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rabies Vaccine (oldterm)":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "rabies vaccine, human diploid cell":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Rabies vaccine,purified chick embryo":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "rabies,purified chick embryo (oldterm)":
     cnt = (size(immun->rabies_vaccination,5)+ 1),stat = alterlist(immun->rabies_vaccination,cnt),
     immun->rabies_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Dryvax (oldterm)":
     cnt = (size(immun->smallpox_vaccination,5)+ 1),stat = alterlist(immun->smallpox_vaccination,cnt),
     immun->smallpox_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Smallpox Vaccine":
     cnt = (size(immun->smallpox_vaccination,5)+ 1),stat = alterlist(immun->smallpox_vaccination,cnt),
     immun->smallpox_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "tetanus-diphtheria toxoids (Td)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus-Diphth Toxoids, Adult (oldterm)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Decavac (oldterm)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth-Tetanus Toxoids, Pedi (oldterm)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "diphtheria-tetanus toxoids (DT)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth-Tetanus Toxoids Adsorbed(oldterm)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Diphth-Tetanus Toxoids (Pedi) (oldterm)":
     cnt = (size(immun->tetanus_and_diphtheria_vaccinations,5)+ 1),stat = alterlist(immun->
      tetanus_and_diphtheria_vaccinations,cnt),immun->tetanus_and_diphtheria_vaccinations[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus Immune Globulin (oldterm)":
     cnt = (size(immun->tetanus_toxoid_immune_glob_vaccination,5)+ 1),stat = alterlist(immun->
      tetanus_toxoid_immune_glob_vaccination,cnt),immun->tetanus_toxoid_immune_glob_vaccination[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus Immune Globulin":
     cnt = (size(immun->tetanus_toxoid_immune_glob_vaccination,5)+ 1),stat = alterlist(immun->
      tetanus_toxoid_immune_glob_vaccination,cnt),immun->tetanus_toxoid_immune_glob_vaccination[cnt].
     display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus Toxoid":
     cnt = (size(immun->tetanus_toxoid_vaccination,5)+ 1),stat = alterlist(immun->
      tetanus_toxoid_vaccination,cnt),immun->tetanus_toxoid_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus Toxoid Adsorbed (oldterm)":
     cnt = (size(immun->tetanus_toxoid_vaccination,5)+ 1),stat = alterlist(immun->
      tetanus_toxoid_vaccination,cnt),immun->tetanus_toxoid_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tetanus Toxoid Vaccine (oldterm)":
     cnt = (size(immun->tetanus_toxoid_vaccination,5)+ 1),stat = alterlist(immun->
      tetanus_toxoid_vaccination,cnt),immun->tetanus_toxoid_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Adacel (Tdap) (oldterm)":
     cnt = (size(immun->tdap,5)+ 1),stat = alterlist(immun->tdap,cnt),immun->tdap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Boostrix (Tdap) (oldterm)":
     cnt = (size(immun->tdap,5)+ 1),stat = alterlist(immun->tdap,cnt),immun->tdap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "tetanus/diphtheria/pertussis, acel(Tdap)":
     cnt = (size(immun->tdap,5)+ 1),stat = alterlist(immun->tdap,cnt),immun->tdap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tet/Diphth/Acel, Pertussis (oldterm)":
     cnt = (size(immun->tdap,5)+ 1),stat = alterlist(immun->tdap,cnt),immun->tdap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Tet/diphth/pertussis, acel (oldterm)":
     cnt = (size(immun->tdap,5)+ 1),stat = alterlist(immun->tdap,cnt),immun->tdap[cnt].display =
     build2(" ",trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,
       "MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Typhim VI (oldterm)":
     cnt = (size(immun->typhoid_vaccination,5)+ 1),stat = alterlist(immun->typhoid_vaccination,cnt),
     immun->typhoid_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Typhoid Vaccine, Live":
     cnt = (size(immun->typhoid_vaccination,5)+ 1),stat = alterlist(immun->typhoid_vaccination,cnt),
     immun->typhoid_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Typhoid Vaccine, Inactivated":
     cnt = (size(immun->typhoid_vaccination,5)+ 1),stat = alterlist(immun->typhoid_vaccination,cnt),
     immun->typhoid_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Vivotif Berna (oldterm)":
     cnt = (size(immun->typhoid_vaccination,5)+ 1),stat = alterlist(immun->typhoid_vaccination,cnt),
     immun->typhoid_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Varicella Virus Vaccine":
     cnt = (size(immun->varicella_virus_vaccination,5)+ 1),stat = alterlist(immun->
      varicella_virus_vaccination,cnt),immun->varicella_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Varivax (oldterm)":
     cnt = (size(immun->varicella_virus_vaccination,5)+ 1),stat = alterlist(immun->
      varicella_virus_vaccination,cnt),immun->varicella_virus_vaccination[cnt].display = build2(" ",
      trim(uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Yellow Fever Vaccine":
     cnt = (size(immun->yellow_fever_vaccination,5)+ 1),stat = alterlist(immun->
      yellow_fever_vaccination,cnt),immun->yellow_fever_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Yf-Vax (oldterm)":
     cnt = (size(immun->yellow_fever_vaccination,5)+ 1),stat = alterlist(immun->
      yellow_fever_vaccination,cnt),immun->yellow_fever_vaccination[cnt].display = build2(" ",trim(
       uar_get_code_display(ce.event_cd),3),"\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),
      "\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Zostavax (oldterm)":
     cnt = (size(immun->zoster_vaccination,5)+ 1),stat = alterlist(immun->zoster_vaccination,cnt),
     immun->zoster_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
    OF "Zoster Vaccine Live":
     cnt = (size(immun->zoster_vaccination,5)+ 1),stat = alterlist(immun->zoster_vaccination,cnt),
     immun->zoster_vaccination[cnt].display = build2(" ",trim(uar_get_code_display(ce.event_cd),3),
      "\tab ",format(ce.event_end_dt_tm,"MM/DD/YYYY;;D"),"\tab ",
      trim(cnvtage(p.birth_dt_tm,ce.event_end_dt_tm,0),3),"\tab ",trim(uar_get_code_display(im
        .vfc_status_cd),3),"\tab ","\tab ",
      trim(format(im.vis_dt_tm,"mm/dd/yyyy;;d"),3),"\tab ",trim(format(im.vis_provided_on_dt_tm,
        "mm/dd/yyyy;;d"),3),"\par",char(10),
      char(13))
   ENDCASE
  WITH nocounter, outerjoin = d
 ;end select
 CALL echorecord(immun)
 SET code_display = " "
 SET code_display = build2(immun->dob,"\par",char(10),char(13))
 SET reply->text = build2(reply->text,"\b\ul Date of Birth: ",code_display,"\b0\ul0\par")
 IF (size(immun->anthrax_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("ANTHRAX VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->anthrax_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->anthrax_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->bcg_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("BCG VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->bcg_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->bcg_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->botulinum_toxin_type_a_vac,5) > 0)
  SET code_display = " "
  SET code_display = build2("BOTULINUM TOXIN TYPE A VAC","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->botulinum_toxin_type_a_vac,5))
    SET reply->text = build2(reply->text," ",immun->botulinum_toxin_type_a_vac[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->cholera_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("CHOLERA VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->cholera_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->cholera_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->dtap,5) > 0)
  SET code_display = " "
  SET code_display = build2("DTAP","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->dtap,5))
    SET reply->text = build2(reply->text," ",immun->dtap[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->dtp_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("DTP_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->dtp_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->dtp_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->haemophilus_b_conjugate_vac,5) > 0)
  SET code_display = " "
  SET code_display = build2("HAEMOPHILUS_B_CONJUGATE_VAC","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->haemophilus_b_conjugate_vac,5))
    SET reply->text = build2(reply->text," ",immun->haemophilus_b_conjugate_vac[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->hepatitis_a_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("HEPATITIS_A_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->hepatitis_a_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->hepatitis_a_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->hepatitis_b_immune_glob_vaccine,5) > 0)
  SET code_display = " "
  SET code_display = build2("HEPATITIS_B_IMMUNE_GLOB_VACCINE ","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->hepatitis_b_immune_glob_vaccine,5))
    SET reply->text = build2(reply->text," ",immun->hepatitis_b_immune_glob_vaccine[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->hepatitis_b_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("HEPATITIS_B_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->hepatitis_b_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->hepatitis_b_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->human_papillomavirus_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("HUMAN_PAPILLOMAVIRUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->human_papillomavirus_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->human_papillomavirus_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->influenza_virus_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("INFLUENZA_VIRUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->influenza_virus_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->influenza_virus_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->japanese_encephalitis_vaccine,5) > 0)
  SET code_display = " "
  SET code_display = build2("JAPANESE_ENCEPHALITIS_VACCINE","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->japanese_encephalitis_vaccine,5))
    SET reply->text = build2(reply->text," ",immun->japanese_encephalitis_vaccine[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->lyme_disease_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("LYME_DISEASE_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->lyme_disease_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->lyme_disease_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->mmr_vaccinations,5) > 0)
  SET code_display = " "
  SET code_display = build2("MMR_VACCINATIONS","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->mmr_vaccinations,5))
    SET reply->text = build2(reply->text," ",immun->mmr_vaccinations[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->meningococcal_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("MENINGOCOCCAL_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->meningococcal_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->meningococcal_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->miscellaneous_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("MISCELLANEOUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->miscellaneous_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->miscellaneous_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->mixed_respiratory_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("MIXED_RESPIRATORY_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->mixed_respiratory_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->mixed_respiratory_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->plague_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("PLAGUE_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->plague_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->plague_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->pneumococcal_vaccinations,5) > 0)
  SET code_display = " "
  SET code_display = build2("PNEUMOCOCCAL_VACCINATIONS","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->pneumococcal_vaccinations,5))
    SET reply->text = build2(reply->text," ",immun->pneumococcal_vaccinations[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->poliovirus_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("POLIOVIRUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->poliovirus_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->poliovirus_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->rotavirus_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("ROTAVIRUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->rotavirus_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->rotavirus_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->rabies_immune_globulin_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("RABIES_IMMUNE_GLOBULIN_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->rabies_immune_globulin_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->rabies_immune_globulin_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->rabies_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("RABIES_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->rabies_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->rabies_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->smallpox_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("SMALLPOX_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->smallpox_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->smallpox_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->tetanus_and_diphtheria_vaccinations,5) > 0)
  SET code_display = " "
  SET code_display = build2("TETANUS_AND_DIPHTHERIA_VACCINATIONS","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->tetanus_and_diphtheria_vaccinations,5))
    SET reply->text = build2(reply->text," ",immun->tetanus_and_diphtheria_vaccinations[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->tetanus_toxoid_immune_glob_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("TETANUS_TOXOID_IMMUNE_GLOB_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->tetanus_toxoid_immune_glob_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->tetanus_toxoid_immune_glob_vaccination[x].display
     )
  ENDFOR
 ENDIF
 IF (size(immun->tetanus_toxoid_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("TETANUS_TOXOID_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->tetanus_toxoid_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->tetanus_toxoid_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->tdap,5) > 0)
  SET code_display = " "
  SET code_display = build2("TDAP","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->tdap,5))
    SET reply->text = build2(reply->text," ",immun->tdap[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->typhoid_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("TYPHOID_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->typhoid_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->typhoid_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->varicella_virus_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("VARICELLA_VIRUS_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->varicella_virus_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->varicella_virus_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->yellow_fever_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("YELLOW_FEVER_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->yellow_fever_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->yellow_fever_vaccination[x].display)
  ENDFOR
 ENDIF
 IF (size(immun->zoster_vaccination,5) > 0)
  SET code_display = " "
  SET code_display = build2("ZOSTER_VACCINATION","\par",char(10),char(13))
  SET reply->text = build2(reply->text,"\b\ul ",code_display,"\b0\ul0")
  FOR (x = 1 TO size(immun->zoster_vaccination,5))
    SET reply->text = build2(reply->text," ",immun->zoster_vaccination[x].display)
  ENDFOR
 ENDIF
 CALL echorecord(reply)
 IF (reply_ind=0)
  SET reply->text = build2(reply->text," \tab\b No immunizations found\b0}")
 ELSE
  SET reply->text = build2(reply->text,"}")
 ENDIF
 CALL echo(reply->text)
#exit_script
END GO
