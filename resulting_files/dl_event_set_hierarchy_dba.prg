CREATE PROGRAM dl_event_set_hierarchy:dba
 PROMPT
  "printer " = "MINE"
 SELECT INTO  $1
  display = uar_get_code_display(ce.event_cd), res_val = cnvtreal(ce.result_val), parent2 =
  IF (ce2.event_cd=11895) ce2.event_title_text
  ELSE uar_get_code_display(ce2.event_cd)
  ENDIF
  ,
  parent3 =
  IF (ce3.event_cd=11895) ce3.event_title_text
  ELSE uar_get_code_display(ce3.event_cd)
  ENDIF
  , parent4 = uar_get_code_display(v4.event_set_cd), parent5 = uar_get_code_display(v4.event_set_cd)
  FROM v500_event_set_canon v2,
   v500_event_set_canon v3,
   v500_event_set_canon v4,
   v500_event_set_canon v5,
   code_value cv2,
   code_value cv93,
   clinical_event ce,
   clinical_event ce2,
   clinical_event ce3
  PLAN (ce
   WHERE ce.encntr_id=1136059
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (ce2
   WHERE ce.parent_event_id=ce2.event_id)
   JOIN (ce3
   WHERE outerjoin(ce2.parent_event_id)=ce3.event_id)
   JOIN (cv2
   WHERE cv2.code_set=outerjoin(72)
    AND outerjoin(ce.event_cd)=cv2.code_value
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv93
   WHERE cv93.code_set=outerjoin(93)
    AND outerjoin(cv2.display_key)=cv93.display_key
    AND cv93.active_ind=outerjoin(1))
   JOIN (v2
   WHERE outerjoin(cv93.code_value)=v2.event_set_cd)
   JOIN (v3
   WHERE outerjoin(v2.parent_event_set_cd)=v3.event_set_cd)
   JOIN (v4
   WHERE outerjoin(v3.parent_event_set_cd)=v4.event_set_cd
    AND v4.event_set_cd=1440113)
   JOIN (v5
   WHERE outerjoin(v4.parent_event_set_cd)=v5.event_set_cd)
  ORDER BY v5.event_set_collating_seq, v4.event_set_collating_seq, v3.event_set_collating_seq,
   ce.parent_event_id, ce2.parent_event_id
  HEAD REPORT
   line2 = fillstring(70,"_"), line1 = fillstring(80,"=")
  HEAD v5.event_set_collating_seq
   col + 0
  HEAD v4.event_set_collating_seq
   v4.event_set_collating_seq, row + 1, col + 0
  HEAD v3.event_set_collating_seq
   col + 0, line1, row + 1,
   col 05, "{b} ", parent3,
   v3.event_set_collating_seq, row + 1, line1,
   row + 1
  HEAD ce.parent_event_id
   col 15, "{b} ", parent2,
   " ", ce.parent_event_id, "{endb}",
   row + 1
  DETAIL
   IF (ce.event_tag != ce.result_val)
    zz = substring(1,100,concat(trim(uar_get_code_display(ce.event_cd)),": ",trim(ce.event_tag)," ",
      trim(ce.result_val),
      "   ",format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")))
   ELSE
    zz = substring(1,100,concat(trim(uar_get_code_display(ce.event_cd))," ",trim(ce.result_val),"   ",
      format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d")))
   ENDIF
   col 20, zz, row + 1
  WITH maxqual(ce.person_id,1), dio = postscript, maxcol = 333
 ;end select
END GO
