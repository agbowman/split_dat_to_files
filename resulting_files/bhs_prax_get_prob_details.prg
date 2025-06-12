CREATE PROGRAM bhs_prax_get_prob_details
 SELECT INTO  $1
  p.problem_id, p_problem_instance_id = cnvtint(p.problem_instance_id), p_onset_dt_tm = format(p
   .onset_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  p_onset_dt_flag =
  IF (p.onset_dt_flag=0) "Day"
  ELSEIF (p.onset_dt_flag=1) "ThisMonth"
  ELSEIF (p.onset_dt_flag=2) "Year"
  ENDIF
  , p_onset_dt_cd = cnvtint(p.onset_dt_cd), p_onset_dt_disp = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(p.onset_dt_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  p_onset_dt_mean = trim(replace(replace(replace(replace(replace(uar_get_code_meaning(p.onset_dt_cd),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_life_cycle_dt_tm = format(p.life_cycle_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), p_life_cycle_dt_flag =
  IF (p.life_cycle_dt_flag=0) "Day"
  ELSEIF (p.life_cycle_dt_flag=1) "ThisMonth"
  ELSEIF (p.life_cycle_dt_flag=2) "Year"
  ENDIF
  ,
  p_life_cycle_dt_cd = cnvtint(p.life_cycle_dt_cd), p_life_cycle_dt_disp = trim(replace(replace(
     replace(replace(replace(uar_get_code_display(p.life_cycle_dt_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_life_cycle_dt_mean = trim(replace(replace(
     replace(replace(replace(uar_get_code_meaning(p.life_cycle_dt_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_qualifier_cd = cnvtint(p.qualifier_cd), p_qualifier_disp = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(p.qualifier_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), p_qualifier_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.qualifier_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
     0),'"',"&quot;",0),3),
  p_severity_cd = cnvtint(p.severity_cd), p_severity_disp = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(p.severity_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), p_severity_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(p.severity_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0
     ),'"',"&quot;",0),3),
  p_severity_class_cd = cnvtint(p.severity_class_cd), p_severity_class_disp = trim(replace(replace(
     replace(replace(replace(uar_get_code_display(p.severity_class_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), p_severity_class_mean = trim(replace(replace(
     replace(replace(replace(uar_get_code_meaning(p.severity_class_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  p_severity_ftdesc = trim(replace(replace(replace(replace(replace(p.severity_ftdesc,"&","&amp;",0),
       "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM problem p
  PLAN (p
   WHERE (p.problem_id= $2)
    AND p.active_ind=1
    AND p.active_status_cd=188
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  HEAD REPORT
   html_tag = build("<?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD p.problem_id
   prob_inst_id = build("<ProblemInstanceId>",p_problem_instance_id,"</ProblemInstanceId>"), col + 1,
   prob_inst_id,
   row + 1, onset_dt = build("<OnsetDateTime>",p_onset_dt_tm,"</OnsetDateTime>"), col + 1,
   onset_dt, row + 1, onset_dt_flg = build("<OnsetDateTimeFlag>",p_onset_dt_flag,
    "</OnsetDateTimeFlag>"),
   col + 1, onset_dt_flg, row + 1,
   pm_his_ind = build("<ShowInPastMedicalHistoryIndicator>",p.show_in_pm_history_ind,
    "</ShowInPastMedicalHistoryIndicator>"), col + 1, pm_his_ind,
   row + 1, col 1, "<OnsetDateCd>",
   row + 1, onset_cd_v = build("<Value>",p_onset_dt_cd,"</Value>"), col + 1,
   onset_cd_v, row + 1, onset_cd_d = build("<Display>",p_onset_dt_disp,"</Display>"),
   col + 1, onset_cd_d, row + 1,
   onset_cd_m = build("<Meaning>",p_onset_dt_mean,"</Meaning>"), col + 1, onset_cd_m,
   row + 1, col 1, "</OnsetDateCd>",
   row + 1, lyfcdt_dt = build("<LifeCycleDateTime>",p_life_cycle_dt_tm,"</LifeCycleDateTime>"), col
    + 1,
   lyfcdt_dt, row + 1, lyfcdt_dt_flg = build("<LifeCycleDateTimeFlag>",p_life_cycle_dt_flag,
    "</LifeCycleDateTimeFlag>"),
   col + 1, lyfcdt_dt_flg, row + 1,
   col 1, "<LifeCycleDateCd>", row + 1,
   lyfcdt_cd_v = build("<Value>",p_life_cycle_dt_cd,"</Value>"), col + 1, lyfcdt_cd_v,
   row + 1, lyfcdt_cd_d = build("<Display>",p_life_cycle_dt_disp,"</Display>"), col + 1,
   lyfcdt_cd_d, row + 1, lyfcdt_cd_m = build("<Meaning>",p_life_cycle_dt_mean,"</Meaning>"),
   col + 1, lyfcdt_cd_m, row + 1,
   col 1, "</LifeCycleDateCd>", row + 1,
   col 1, "<QualifierCd>", row + 1,
   qual_cd_v = build("<Value>",p_qualifier_cd,"</Value>"), col + 1, qual_cd_v,
   row + 1, qual_cd_d = build("<Display>",p_qualifier_disp,"</Display>"), col + 1,
   qual_cd_d, row + 1, qual_cd_m = build("<Meaning>",p_qualifier_mean,"</Meaning>"),
   col + 1, qual_cd_m, row + 1,
   col 1, "</QualifierCd>", row + 1,
   col 1, "<SeverityCd>", row + 1,
   sevr_cd_v = build("<Value>",p_severity_cd,"</Value>"), col + 1, sevr_cd_v,
   row + 1, sevr_cd_d = build("<Display>",p_severity_disp,"</Display>"), col + 1,
   sevr_cd_d, row + 1, sevr_cd_m = build("<Meaning>",p_severity_mean,"</Meaning>"),
   col + 1, sevr_cd_m, row + 1,
   col 1, "</SeverityCd>", row + 1,
   sevr_ft = build("<SeverityFreeText>",p_severity_ftdesc,"</SeverityFreeText>"), col + 1, sevr_ft,
   row + 1, col 1, "<SeverityClassCd>",
   row + 1, sevr_cls_cd_v = build("<Value>",p_severity_class_cd,"</Value>"), col + 1,
   sevr_cls_cd_v, row + 1, sevr_cls_cd_d = build("<Display>",p_severity_class_disp,"</Display>"),
   col + 1, sevr_cls_cd_d, row + 1,
   sevr_cls_cd_m = build("<Meaning>",p_severity_class_mean,"</Meaning>"), col + 1, sevr_cls_cd_m,
   row + 1, col 1, "</SeverityClassCd>",
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 10000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 10
 ;end select
END GO
