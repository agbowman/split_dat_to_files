CREATE PROGRAM bhs_sys_concert_mrn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 mrn = vc
     2 patientid = vc
     2 cohort = vc
 )
 FREE DEFINE rtl
 DEFINE rtl "bhscust:b1_l2chartreview.txt"
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].line = r
   .line
  WITH nocounter
 ;end select
 DECLARE str = vc WITH noconstant("")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 FOR (x = 1 TO temp->cnt)
   SET data = temp->qual[x].line
   SET str = " "
   SET num = 0
   CALL echo(data)
   WHILE (str != notfnd)
     SET num = (num+ 1)
     SET str = piece(data,"&",num,notfnd)
     CALL echo(build("piece",num,"=",str))
     IF (str != "<not_found>")
      CASE (num)
       OF 1:
        SET temp->qual[x].patientid = trim(str,3)
       OF 2:
        SET temp->qual[x].cohort = trim(str,3)
       OF 3:
        SET temp->qual[x].mrn = trim(str,3)
      ENDCASE
     ENDIF
   ENDWHILE
 ENDFOR
 SELECT INTO  $1
  patientid = substring(1,20,temp->qual[d.seq].patientid), cohortid = substring(1,20,temp->qual[d.seq
   ].cohort), ea.alias,
  mrn = substring(1,60,p.name_full_formatted), phone = substring(1,20,ph.phone_num), street =
  substring(1,50,ad.street_addr),
  city = substring(1,20,ad.city), zipcode = ad.zipcode, dob = format(p.birth_dt_tm,"mm/dd/yyyy;;q")
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   encntr_alias ea,
   encounter e,
   person p,
   phone ph,
   address ad
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=temp->qual[d.seq].mrn)
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1079)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate
    AND ph.phone_type_cd=170)
   JOIN (ad
   WHERE ad.parent_entity_id=p.person_id
    AND ad.parent_entity_name="PERSON"
    AND ad.active_ind=1
    AND ad.end_effective_dt_tm > sysdate
    AND ad.address_type_cd=756)
  WITH nocounter, maxqual(ea,1), time = 120,
   format, separator = " "
 ;end select
#end_script
END GO
