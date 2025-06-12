CREATE PROGRAM ams_accts_ending
 PROMPT
  "Title of users to set end date on" = "",
  "Date to expire accts" = ((12/ 31)/ 2100)
  WITH title, edate
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_ACCTS_ENDING")
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 detail1 = f8
     2 detail2 = f8
 )
 SELECT DISTINCT INTO "nl:"
  p.name_full_formatted, p.person_id, p.username,
  pn.name_title, p.active_ind, p.physician_ind,
  p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm, p.end_effective_dt_tm
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pn.active_ind=1
    AND (pn.name_title= $TITLE))
  ORDER BY p.name_full_formatted
  HEAD REPORT
   cnt = 0, stat = alterlist(temp->list,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(temp->list,(cnt+ 9))
   ENDIF
   temp->list[cnt].detail1 = p.person_id
  FOOT REPORT
   stat = alterlist(temp->list,cnt)
  WITH nocounter
 ;end select
 SET rec_size = size(temp->list,5)
 FOR (x = 1 TO value(rec_size))
  UPDATE  FROM prsnl p
   SET p.end_effective_dt_tm = cnvtdatetime(cnvtdate2( $EDATE,"mm-dd-yyyy"),235959)
   WHERE (p.person_id=temp->list[x].detail1)
  ;end update
  IF (mod(x,100)=0)
   COMMIT
  ENDIF
 ENDFOR
 CALL updtdminfo(script_name)
 COMMIT
END GO
