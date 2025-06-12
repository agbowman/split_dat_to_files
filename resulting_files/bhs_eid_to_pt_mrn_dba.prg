CREATE PROGRAM bhs_eid_to_pt_mrn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "ENTER ENCOUNTER ID" = 0
  WITH outdev, eid
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  patient_name = p.name_full_formatted, mrn = pa.alias
  FROM encounter e,
   person p,
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id= $EID))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=10
    AND pa.active_ind=1)
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
