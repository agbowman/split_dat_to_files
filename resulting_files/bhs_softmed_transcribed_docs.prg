CREATE PROGRAM bhs_softmed_transcribed_docs
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beginning Date" = "CURDATE",
  "Ending Date" = "CURDATE",
  "Physician" = value()
  WITH outdev, beg_date_qual, end_date_qual,
  physician
 DECLARE phys_any_type = c1 WITH constant(substring(1,1,reflect(parameter(4,0)))), public
 IF (phys_any_type="C")
  SET my_ora_hint = 'ORAHINT("index(ce XIE15CLINICAL_EVENT)")'
 ELSE
  SET my_ora_hint = 'ORAHINT("INDEXJOIN(ce XIE15CLINICAL_EVENT XIE16CLINICAL_EVENT)")'
 ENDIF
 DECLARE softmed_cd = f8
 DECLARE physician_notes_event_set_cd = f8
 DECLARE resident_position_cd = f8
 DECLARE fin_alias_type_cd = f8
 DECLARE mrn_alias_type_cd = f8
 SET softmed_cd = uar_get_code_by("DISPLAYKEY",73,"SOFTMED")
 SET physician_notes_event_set_cd = uar_get_code_by("DISPLAYKEY",93,"PHYSICIANNOTES")
 SET resident_position_cd = uar_get_code_by("DISPLAY",88,"BHS Resident")
 SET fin_alias_type_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET mrn_alias_type_cd = uar_get_code_by("MEANING",319,"MRN")
 FREE RECORD docs
 RECORD docs(
   1 list[*]
     2 event_cd = f8
 )
 SELECT INTO "nl:"
  FROM v500_event_set_explode vese
  PLAN (vese
   WHERE vese.event_set_cd=physician_notes_event_set_cd
    AND  EXISTS (
   (SELECT
    cva.alias
    FROM code_value_alias cva
    WHERE cva.code_value=vese.event_cd
     AND cva.contributor_source_cd=softmed_cd)))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(docs->list,(cnt+ 9))
   ENDIF
   docs->list[cnt].event_cd = vese.event_cd
  FOOT REPORT
   stat = alterlist(docs->list,cnt)
  WITH nocounter
 ;end select
 DECLARE idx = i4
 SELECT
  IF (phys_any_type="C")
   PLAN (ce
    WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate(cnvtalphanum( $BEG_DATE_QUAL)),0) AND
    cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE_QUAL)),235959)
     AND expand(idx,1,size(docs->list,5),ce.event_cd,docs->list[idx].event_cd)
     AND ce.view_level=1
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pr
    WHERE pr.person_id=ce.performed_prsnl_id
     AND pr.position_cd != resident_position_cd)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id)
    JOIN (fin
    WHERE fin.encntr_id=ce.encntr_id
     AND fin.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm
     AND fin.encntr_alias_type_cd=fin_alias_type_cd)
    JOIN (mrn
    WHERE mrn.encntr_id=ce.encntr_id
     AND mrn.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm
     AND mrn.encntr_alias_type_cd=mrn_alias_type_cd)
    JOIN (p
    WHERE p.person_id=ce.person_id)
  ELSE
   PLAN (ce
    WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate(cnvtalphanum( $BEG_DATE_QUAL)),0) AND
    cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE_QUAL)),235959)
     AND expand(idx,1,size(docs->list,5),ce.event_cd,docs->list[idx].event_cd)
     AND (ce.performed_prsnl_id= $PHYSICIAN)
     AND ce.view_level=1
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pr
    WHERE pr.person_id=ce.performed_prsnl_id
     AND pr.position_cd != resident_position_cd)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id)
    JOIN (fin
    WHERE fin.encntr_id=ce.encntr_id
     AND fin.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm
     AND fin.encntr_alias_type_cd=fin_alias_type_cd)
    JOIN (mrn
    WHERE mrn.encntr_id=ce.encntr_id
     AND mrn.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm
     AND mrn.encntr_alias_type_cd=mrn_alias_type_cd)
    JOIN (p
    WHERE p.person_id=ce.person_id)
  ENDIF
  INTO  $OUTDEV
  mrn_alias = substring(1,10,mrn.alias), fin_alias = substring(1,15,fin.alias), e.disch_dt_tm,
  patient_name = substring(1,30,p.name_full_formatted), document_name = substring(1,30,
   uar_get_code_display(ce.event_cd)), ce.clinsig_updt_dt_tm,
  physician_name = substring(1,30,pr.name_full_formatted), facility_disp = substring(1,20,
   uar_get_code_description(e.loc_facility_cd))
  FROM clinical_event ce,
   prsnl pr,
   encntr_alias fin,
   encntr_alias mrn,
   encounter e,
   person p
  ORDER BY facility_disp, physician_name, patient_name,
   document_name, ce.clinsig_updt_dt_tm
  HEAD PAGE
   CALL center(trim(uar_get_code_description(e.loc_facility_cd)),1,132), row + 1
   IF (phys_any_type="C")
    CALL center("ESA Report (Cumulation)",1,132)
   ELSE
    CALL center("ESA Report (By Physician)",1,132)
   ENDIF
   row + 1,
   CALL center(concat( $BEG_DATE_QUAL," to ", $END_DATE_QUAL),1,132), row + 2
  HEAD facility_disp
   row + 0
  HEAD physician_name
   col 1, physician_name, row + 1
  DETAIL
   col 1, mrn_alias, col 15,
   fin_alias, col 30, e.disch_dt_tm,
   col 45, patient_name, col 77,
   document_name, sign_dt_disp = format(ce.clinsig_updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), col 112,
   sign_dt_disp, row + 1
  FOOT  physician_name
   row + 1
  FOOT  facility_disp
   BREAK
  WITH format, value(my_ora_hint)
 ;end select
END GO
