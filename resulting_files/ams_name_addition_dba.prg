CREATE PROGRAM ams_name_addition:dba
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_NAME_ADDITION")
 FREE RECORD name
 RECORD name(
   1 list[*]
     2 fname = vc
     2 lname = vc
     2 pid = f8
 )
 SELECT DISTINCT INTO "nl:"
  p.person_id, p.username, p.name_last,
  p.name_first, pn.name_title
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.name_last != "*(AMS)")
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner AMS")
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pn.active_ind=1)
  HEAD REPORT
   cnt = 0, stat = alterlist(name->list,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(name->list,(cnt+ 9))
   ENDIF
   name->list[cnt].fname = p.name_first, name->list[cnt].lname = p.name_last, name->list[cnt].pid = p
   .person_id
  FOOT REPORT
   stat = alterlist(name->list,cnt)
  WITH nocounter
 ;end select
 SET rec_size = size(name->list,5)
 FOR (x = 1 TO value(rec_size))
   UPDATE  FROM prsnl p
    SET p.name_last = concat(trim(name->list[x].lname)," (AMS)"), p.name_last_key = cnvtupper(concat(
       trim(name->list[x].lname),"AMS")), p.name_full_formatted = concat(trim(name->list[x].lname),
      " (AMS), ",trim(name->list[x].fname))
    WHERE (p.person_id=name->list[x].pid)
   ;end update
   UPDATE  FROM person pr
    SET pr.name_last = concat(trim(name->list[x].lname)," (AMS)"), pr.name_last_key = cnvtupper(
      concat(trim(name->list[x].lname),"AMS")), pr.name_full_formatted = concat(trim(name->list[x].
       lname)," (AMS), ",trim(name->list[x].fname))
    WHERE (pr.person_id=name->list[x].pid)
   ;end update
   IF (mod(x,100)=0)
    COMMIT
   ENDIF
 ENDFOR
 SET total_cnt = size(name->list,5)
 CALL updtdminfo(script_name,cnvtreal(total_cnt))
 COMMIT
END GO
