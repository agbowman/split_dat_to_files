CREATE PROGRAM bhs_locate_atrmrn_out_of_sync:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp1
 RECORD temp1(
   1 qual[*]
     2 encntrid = f8
     2 val = vc
     2 val2 = vc
     2 personid = f8
     2 name = vc
     2 pamrn = vc
     2 notfound = vc
 )
 FREE RECORD temp2
 RECORD temp2(
   1 qual[*]
     2 encntrid = f8
     2 val = vc
     2 val2 = vc
     2 personid = f8
     2 name = vc
     2 pamrn = vc
 )
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET var_output = "bhsradnonmatchedstudies"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SET count1 = 0
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   person p
  PLAN (ea
   WHERE ea.alias="ATR*"
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   stat = alterlist(temp1->qual,10), count1 = 0
  HEAD ea.alias
   IF (count1 < 200)
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(temp1->qual,(count1+ 9))
    ENDIF
    temp1->qual[count1].encntrid = e.encntr_id, temp1->qual[count1].val = substring(4,7,ea.alias),
    temp1->qual[count1].val2 = ea.alias,
    temp1->qual[count1].personid = p.person_id, temp1->qual[count1].name = p.name_full_formatted
   ENDIF
  FOOT REPORT
   stat = alterlist(temp1->qual,count1)
  WITH nocounter
 ;end select
 CALL echorecord(temp1,"TESTTEMPREC")
 CALL echo(build("recordSize:",size(temp1->qual,5)," curqual: ",curqual))
 IF (size(temp1->qual,5) > 0)
  CALL echo("locating non-matches")
  SELECT INTO "NL:"
   FROM person_alias pa,
    (dummyt d  WITH seq = size(temp1->qual,5))
   PLAN (d)
    JOIN (pa
    WHERE pa.person_id=outerjoin(temp1->qual[d.seq].personid)
     AND pa.person_alias_type_cd=outerjoin(2)
     AND pa.active_ind=outerjoin(1)
     AND pa.alias=outerjoin(temp1->qual[d.seq].val))
   DETAIL
    IF (pa.person_alias_id <= 0)
     temp1->qual[d.seq].notfound = "1"
    ELSE
     temp1->qual[d.seq].notfound = pa.alias
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(temp1,"jrwtemp1lrecord")
 CALL echo(build("TES2:",size(temp1->qual,5)))
 SET cnt = 0
 FOR (x = 1 TO size(temp1->qual,5))
   IF ((temp1->qual[x].notfound="1"))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(temp2->qual,cnt)
    SET temp2->qual[cnt].encntrid = temp1->qual[x].encntrid
    SET temp2->qual[cnt].val = temp1->qual[x].val
    SET temp2->qual[cnt].val2 = temp1->qual[x].val2
    SET temp2->qual[cnt].personid = temp1->qual[x].personid
    SET temp2->qual[cnt].name = temp1->qual[x].name
   ENDIF
 ENDFOR
 CALL echorecord(temp2,"jrwtemp25record")
 CALL echo(size(temp2->qual,3))
 IF (size(temp2->qual,5) > 0)
  SELECT INTO "NL:"
   encntraliasid = temp1->qual[d.seq].encntrid, account_mrn = temp1->qual[d.seq].val, corp_mrn =
   temp1->qual[d.seq].val2,
   person_id = temp1->qual[d.seq].personid, encounter_id = temp1->qual[d.seq].encntrid, name = temp1
   ->qual[d.seq].name,
   pamrn = temp1->qual[d.seq].pamrn
   FROM (dummyt d  WITH seq = size(temp1->qual,5))
   PLAN (d
    WHERE (temp1->qual[d.seq].notfound="1"))
  ;end select
  CALL echorecord(temp2,"jrwtemp24record")
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Now values found out of sync", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1, row + 2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_prg
END GO
