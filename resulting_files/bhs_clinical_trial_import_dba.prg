CREATE PROGRAM bhs_clinical_trial_import:dba
 RECORD requestin(
   1 list_0[*]
     2 irb_number = vc
     2 title = vc
     2 pi = vc
     2 short_title = vc
     2 pager_number = vc
     2 phone_number = vc
     2 email_address = vc
     2 pharm_notify = vc
     2 instructions = vc
 )
 CALL echo("Entering bhs_clinical_trial_import")
 SET filename = concat("bhsclintrialimport",format(cnvtdatetime(curdate,curtime3),"MMDDYYYYHHMM;;d"))
 SET prsnlid = 0
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=trim(curuser,3)
  DETAIL
   prsnlid = p.person_id
  WITH nocounter
 ;end select
 CALL echo(prsnlid)
 IF (curqual=0
  AND validate(reqinfo->updt_id,0) > 0)
  SET prsnlid = reqinfo->updt_id
 ENDIF
 CALL echo(prsnlid)
 SELECT INTO "bhsclinitrailfile"
  substring(1,12,requestin->list_0[d.seq].irb_number), substring(1,300,requestin->list_0[d.seq].title
   ), substring(1,40,requestin->list_0[d.seq].pi),
  substring(1,40,requestin->list_0[d.seq].short_title), substring(1,12,requestin->list_0[d.seq].
   pager_number), substring(1,100,requestin->list_0[d.seq].phone_number),
  substring(1,300,requestin->list_0[d.seq].email_address), substring(1,2,requestin->list_0[d.seq].
   pharm_notify), substring(1,1000,requestin->list_0[d.seq].instructions)
  FROM (dummyt d  WITH seq = size(requestin->list_0,5))
  PLAN (d)
  WITH nocounter, pcformat('"',",")
 ;end select
 SET newtrialid = 0
 SELECT INTO "NL:"
  b.clinical_trial_id
  FROM bhs_clinical_trial b
  WHERE b.clinical_trial_id > 0
  ORDER BY b.clinical_trial_id DESC
  DETAIL
   newtrialid = b.clinical_trial_id
  WITH maxrec = 1
 ;end select
 CALL echo(textlen(trim(check(requestin->list_0[1].pharm_notify),3)))
 CALL echo(concat("@",requestin->list_0[1].pharm_notify,"@"))
 IF (curqual=0)
  SET usermsg = "0Failed to create new row Index"
  GO TO exit_script
 ENDIF
 CALL echorecord(requestin)
 CALL echo("inserting")
 INSERT  FROM bhs_clinical_trial b,
   (dummyt d  WITH seq = size(requestin->list_0,5))
  SET b.active_ind = 1, b.clinical_trial_id = (newtrialid+ d.seq), b.irb_number = substring(1,9,
    cnvtupper(trim(requestin->list_0[d.seq].irb_number,3))),
   b.title = substring(1,300,trim(requestin->list_0[d.seq].title,3)), b.pi_id = 111.0, b.short_title
    = substring(1,40,trim(requestin->list_0[d.seq].short_title,3)),
   b.pager_number = substring(1,20,trim(requestin->list_0[d.seq].pager_number,3)), b.phone_number =
   substring(1,300,trim(requestin->list_0[d.seq].phone_number,3)), b.email_address = substring(1,300,
    trim(requestin->list_0[d.seq].email_address,3)),
   b.pharmacy_notify_ind =
   IF (trim(requestin->list_0[d.seq].pharm_notify,3)="1") 1
   ELSE 0
   ENDIF
   , b.instructions = trim(requestin->list_0[d.seq].instructions,3), b.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   b.updt_id = prsnlid
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 COMMIT
END GO
