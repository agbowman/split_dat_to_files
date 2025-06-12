CREATE PROGRAM bhs_prax_recommendation_list
 SELECT INTO  $1
  hr.recommendation_id, hem.expect_id, hra.recommendation_action_id,
  hra_expect_sat_id = cnvtint(hra.expect_sat_id), hr_expectation =
  IF (hr.expectation_ftdesc=" ") trim(hem.expect_name,3)
  ELSE trim(hr.expectation_ftdesc,3)
  ENDIF
  , free_text_ind =
  IF (hr.expectation_ftdesc=" ") "NO"
  ELSE "YES"
  ENDIF
  ,
  hr_due_dt_tm = format(hr.due_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), hra_action_flag =
  IF (hra.action_flag=0.00) "No value / Null"
  ELSEIF (hra.action_flag=1.00) "Created"
  ELSEIF (hra.action_flag=2.00) "Posponed"
  ELSEIF (hra.action_flag=3.00) "Expired"
  ELSEIF (hra.action_flag=4.00) "Refused"
  ELSEIF (hra.action_flag=5.00) "Cancelled"
  ELSEIF (hra.action_flag=6.00) "Satisfied"
  ELSEIF (hra.action_flag=7.00) "Change Frequency"
  ELSEIF (hra.action_flag=8.00) "Change Due Date"
  ELSEIF (hra.action_flag=9.00) "Change Qualification Interval"
  ELSEIF (hra.action_flag=10.00) "Undo Refusal"
  ELSEIF (hra.action_flag=11.00) "Undo Cancellation"
  ELSEIF (hra.action_flag=12.00) "Undo Satisfaction"
  ELSEIF (hra.action_flag=13.00) "Undo Postpone"
  ELSEIF (hra.action_flag=14.00) "Qualified"
  ELSEIF (hra.action_flag=15.00) "System Cancelled"
  ELSEIF (hra.action_flag=16.00) "Assigned"
  ELSEIF (hra.action_flag=17.00) "xx"
  ELSEIF (hra.action_flag=18.00) "System Change Frequency"
  ELSEIF (hra.action_flag=19.00) "System Change Name"
  ENDIF
  , hra_act_dt_tm = format(hra.action_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  hr_updt_dt_tm = format(hr.updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), hr_first_due_dt_tm = format(hr
   .first_due_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), h_expect_series_id = cnvtint(h.expect_series_id),
  h.priority_meaning, hr.frequency_val, hr_frequency_unit_cd = cnvtint(hr.frequency_unit_cd),
  hr_freq_unit_display = uar_get_code_display(hr.frequency_unit_cd), hr.last_satisfied_by_id, p
  .name_full_formatted,
  hr_last_satisfaction_dt_tm = format(hr.last_satisfaction_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
  hra_satisfaction_dt_tm = format(hra.satisfaction_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), hra_reason_disp
   = uar_get_code_display(hra.reason_cd),
  hr.status_flag, hr_status =
  IF (hr.status_flag=1) "Pending"
  ELSEIF (hr.status_flag=2) "Postponed"
  ELSEIF (hr.status_flag=3) "Refused"
  ELSEIF (hr.status_flag=4) "Expired"
  ELSEIF (hr.status_flag=5) "Cancelled"
  ELSEIF (hr.status_flag=6) "Satisfied"
  ELSEIF (hr.status_flag=7) "System Canceled"
  ELSEIF (hr.status_flag=8) "Satisfied Pending"
  ELSE "Unknown"
  ENDIF
  , l_long_text = trim(replace(replace(replace(replace(replace(substring(1,500,l.long_text),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  hes_entry_type_cd = cnvtint(hes.entry_type_cd), hes_entry_type_disp = uar_get_code_display(hes
   .entry_type_cd), hes.expect_sat_name,
  hes1_entry_type_cd = cnvtint(hes1.entry_type_cd), hes1_entry_type_disp = uar_get_code_display(hes1
   .entry_type_cd), hes1.expect_sat_name
  FROM hm_recommendation hr,
   hm_expect hem,
   hm_expect_series h,
   hm_expect_sched he,
   hm_recommendation_action hra,
   hm_expect_sat hes,
   person p,
   long_text l,
   hm_expect_sat hes1
  PLAN (hr
   WHERE (hr.person_id= $2)
    AND hr.updt_dt_tm BETWEEN cnvtdatetime( $3) AND cnvtdatetime( $4)
    AND  NOT (hr.status_flag IN (5, 6, 7))
    AND (((hr.due_dt_tm <= (sysdate+ 365))) OR (hr.due_dt_tm = null)) )
   JOIN (hem
   WHERE hem.expect_id=outerjoin(hr.expect_id))
   JOIN (h
   WHERE h.expect_series_id=hem.expect_series_id)
   JOIN (he
   WHERE he.expect_sched_id=outerjoin(h.expect_sched_id))
   JOIN (hra
   WHERE hra.recommendation_id=hr.recommendation_id
    AND  NOT (hra.action_flag IN (3, 5, 6, 15, 17,
   18, 19)))
   JOIN (hes
   WHERE hra.expect_sat_id=outerjoin(hes.expect_sat_id))
   JOIN (p
   WHERE p.person_id=outerjoin(hr.last_satisfied_by_id))
   JOIN (l
   WHERE l.long_text_id=outerjoin(hra.long_text_id))
   JOIN (hes1
   WHERE hes1.expect_id=outerjoin(hr.expect_id)
    AND hes1.active_ind=outerjoin(1)
    AND hes1.parent_type_flag=outerjoin(2))
  ORDER BY hr_expectation, hr.expect_id, hes1.seq_nbr
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<Recommendations>",
   row + 1
  HEAD hr.recommendation_id
   col + 1, "<Recommendation>", row + 1,
   v1 = build("<RecommendationId>",cnvtint(hr.recommendation_id),"</RecommendationId>"), col + 1, v1,
   row + 1, v2 = build("<ExpectId>",cnvtint(hem.expect_id),"</ExpectId>"), col + 1,
   v2, row + 1, v3 = build("<ExpectationName>",hr_expectation,"</ExpectationName>"),
   col + 1, v3, row + 1,
   v3a = build("<FreeTextIndicator>",free_text_ind,"</FreeTextIndicator>"), col + 1, v3a,
   row + 1, v4 = build("<DueDate>",hr_due_dt_tm,"</DueDate>"), col + 1,
   v4, row + 1, v42 = build("<UpdatedDate>",hr_updt_dt_tm,"</UpdatedDate>"),
   col + 1, v42, row + 1,
   vh1 = build("<ExpectSeriesId>",h_expect_series_id,"</ExpectSeriesId>"), col + 1, vh1,
   row + 1, v5 = build("<Priority>",h.priority_meaning,"</Priority>"), col + 1,
   v5, row + 1, v6 = build("<FrequencyValue>",hr.frequency_val,"</FrequencyValue>"),
   col + 1, v6, row + 1,
   v7a = build("<FrequencyUnitCD>",hr_frequency_unit_cd,"</FrequencyUnitCD>"), col + 1, v7a,
   row + 1, v7b = build("<FrequencyUnit>",hr_freq_unit_display,"</FrequencyUnit>"), col + 1,
   v7b, row + 1, v8a = build("<StatusFlag>",hr.status_flag,"</StatusFlag>"),
   col + 1, v8a, row + 1,
   v8b = build("<Status>",hr_status,"</Status>"), col + 1, v8b,
   row + 1, v9 = build("<ApproxDueDate>",hr_first_due_dt_tm,"</ApproxDueDate>"), col + 1,
   v9, row + 1
   IF (hr.last_satisfied_by_id != 0)
    v18 = build("<LastSatisfiedById>",cnvtint(hr.last_satisfied_by_id),"</LastSatisfiedById>"), col
     + 1, v18,
    row + 1, v19 = build("<LastSatisfiedByName>",p.name_full_formatted,"</LastSatisfiedByName>"), col
     + 1,
    v19, row + 1, v19a = build("<LastSatisfiedDate>",hr_last_satisfaction_dt_tm,
     "</LastSatisfiedDate>"),
    col + 1, v19a, row + 1
   ENDIF
   v4ab = build("<RecommendationActionId>",cnvtint(hra.recommendation_action_id),
    "</RecommendationActionId>"), col + 1, v4ab,
   row + 1, v4c = build("<Action>",hra_action_flag,"</Action>"), col + 1,
   v4c, row + 1, v41 = build("<ActionDate>",hra_act_dt_tm,"</ActionDate>"),
   col + 1, v41, row + 1,
   v10 = build("<Comments>",l_long_text,"</Comments>"), col + 1, v10,
   row + 1
   IF (hra_expect_sat_id != 0)
    v15 = build("<ExpectSatId>",hra_expect_sat_id,"</ExpectSatId>"), col + 1, v15,
    row + 1, v161 = build("<SatisfyTypeCD>",hes_entry_type_cd,"</SatisfyTypeCD>"), col + 1,
    v161, row + 1, v16 = build("<SatisfyType>",hes_entry_type_disp,"</SatisfyType>"),
    col + 1, v16, row + 1,
    v17 = build("<ExpectSatName>",hes.expect_sat_name,"</ExpectSatName>"), col + 1, v17,
    row + 1, v20 = build("<SatisfyReason>",hra_reason_disp,"</SatisfyReason>"), col + 1,
    v20, row + 1, v21 = build("<SatisfactionDate>",hra_satisfaction_dt_tm,"</SatisfactionDate>"),
    col + 1, v21, row + 1
   ENDIF
   col + 1, "<Expectations>", row + 1
  HEAD hes1.expect_sat_id
   col + 1, "<Expectation>", row + 1,
   v221 = build("<ExpectSatId>",cnvtint(hes1.expect_sat_id),"</ExpectSatId>"), col + 1, v221,
   row + 1, v2211 = build("<SatisfyTypeCD>",hes1_entry_type_cd,"</SatisfyTypeCD>"), col + 1,
   v2211, row + 1, v2212 = build("<SatisfyType>",hes1_entry_type_disp,"</SatisfyType>"),
   col + 1, v2212, row + 1,
   v222 = build("<ExpectSatName>",hes1.expect_sat_name,"</ExpectSatName>"), col + 1, v222,
   row + 1
  FOOT  hes1.expect_sat_id
   col + 1, "</Expectation>", row + 1
  FOOT  hr.recommendation_id
   col + 1, "</Expectations>", row + 1,
   col + 1, "</Recommendation>", row + 1
  FOOT REPORT
   col + 1, "</Recommendations>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
