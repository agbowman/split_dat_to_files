CREATE PROGRAM edw_encntr_followup:dba
 DECLARE inst_where_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE encntr_nk_logic = vc WITH constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE lkp_time_zone = f8 WITH protect, noconstant(0.0)
 DECLARE enc_followup_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 IF (debug="Y")
  CALL echo(build("Begin Pat_Ed_Doc_Followup driver table:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D"))
   )
 ENDIF
 SELECT INTO "nl:"
  pedf.pat_ed_doc_followup_id
  FROM pat_ed_doc_followup pedf
  PLAN (pedf
   WHERE pedf.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
  DETAIL
   enc_followup_cnt = (enc_followup_cnt+ 1)
   IF (mod(enc_followup_cnt,100)=1)
    stat = alterlist(enc_followup_keys->qual,(enc_followup_cnt+ 99))
   ENDIF
   enc_followup_keys->qual[enc_followup_cnt].pat_ed_doc_followup_id = pedf.pat_ed_doc_followup_id
  WITH nocounter
 ;end select
 IF (debug="Y")
  CALL echo(build("Finish Pat_Ed_Doc_Followup driver table:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")
    ))
  CALL echo(build("Current number of distinct records:",enc_followup_cnt))
 ENDIF
 IF (ed_pat_ed_document="Y")
  IF (debug="Y")
   CALL echo(build("Begin Pat_Ed_Document driver table:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
  ENDIF
  SELECT INTO "nl:"
   pedf.pat_ed_doc_followup_id
   FROM pat_ed_document ped,
    pat_ed_doc_followup pedf
   PLAN (ped
    WHERE ped.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    JOIN (pedf
    WHERE pedf.pat_ed_doc_id=ped.pat_ed_document_id)
   DETAIL
    enc_followup_cnt = (enc_followup_cnt+ 1)
    IF (mod(enc_followup_cnt,100)=1)
     stat = alterlist(enc_followup_keys->qual,(enc_followup_cnt+ 99))
    ENDIF
    enc_followup_keys->qual[enc_followup_cnt].pat_ed_doc_followup_id = pedf.pat_ed_doc_followup_id
   WITH nocounter
  ;end select
  IF (debug="Y")
   CALL echo(build("Finish Pat_Ed_Document driver table:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
   CALL echo(build("Current number of distinct records:",enc_followup_cnt))
  ENDIF
 ENDIF
 IF (debug="Y")
  CALL echo(build("Begin deduplication logic:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  encounter.encntr_id, encntr_nk = parser(encntr_nk_logic), encounter.loc_facility_cd,
  pedf.pat_ed_doc_followup_id
  FROM (dummyt d  WITH seq = value(enc_followup_cnt)),
   pat_ed_doc_followup pedf,
   pat_ed_document ped,
   encounter
  PLAN (d
   WHERE enc_followup_cnt > 0)
   JOIN (pedf
   WHERE (pedf.pat_ed_doc_followup_id=enc_followup_keys->qual[d.seq].pat_ed_doc_followup_id))
   JOIN (ped
   WHERE ped.pat_ed_document_id=pedf.pat_ed_doc_id)
   JOIN (encounter
   WHERE encounter.encntr_id=ped.encntr_id
    AND parser(inst_filter)
    AND parser(org_filter))
  ORDER BY encounter.encntr_id, encntr_nk, encounter.loc_facility_cd,
   pedf.pat_ed_doc_followup_id
  HEAD REPORT
   cnt = 0, enc_cnt = 0
  HEAD encounter.encntr_id
   enc_cnt = (enc_cnt+ 1)
   IF (mod(enc_cnt,100)=1)
    stat = alterlist(enc_followup_parent_keys->qual,(enc_cnt+ 99))
   ENDIF
   enc_followup_parent_keys->qual[enc_cnt].encntr_id = encounter.encntr_id
  DETAIL
   cnt = (cnt+ 1), enc_followup_keys->qual[cnt].pat_ed_doc_followup_id = pedf.pat_ed_doc_followup_id,
   enc_followup_keys->qual[cnt].encntr_id = encounter.encntr_id,
   enc_followup_keys->qual[cnt].loc_facility_cd = encounter.loc_facility_cd, enc_followup_keys->qual[
   cnt].encntr_nk = encntr_nk
  FOOT  encounter.encntr_id
   row + 0
  FOOT REPORT
   enc_followup_cnt = cnt, stat = alterlist(enc_followup_keys->qual,cnt), stat = alterlist(
    enc_followup_parent_keys->qual,enc_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET enc_followup_cnt = curqual
  SET stat = alterlist(enc_followup_keys->qual,curqual)
  SET stat = alterlist(enc_followup_parent_keys->qual,curqual)
 ENDIF
 IF (debug="Y")
  CALL echo(build("Finish Deduplication logic:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
  CALL echo(build("Current number of distinct records:",enc_followup_cnt))
  CALL echo(build("Current number of distinct parent keys:",size(enc_followup_parent_keys->qual,5)))
  CALL echo(build("Begin writing file:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 ENDIF
 FOR (i = 1 TO enc_followup_cnt)
   SET lkp_time_zone = gettimezone(enc_followup_keys->qual[i].loc_facility_cd,enc_followup_keys->
    qual[i].encntr_id)
   SET enc_followup_keys->qual[i].time_zone = cnvtint(lkp_time_zone)
   IF (encounter_nk != default_encounter_nk)
    SET enc_followup_keys->qual[i].encntr_nk = get_encounter_nk(enc_followup_keys->qual[i].encntr_id)
   ENDIF
 ENDFOR
 SELECT INTO value(enc_follow_extractfile)
  FROM (dummyt d  WITH seq = value(enc_followup_cnt)),
   pat_ed_doc_followup pedf,
   pat_ed_document ped
  PLAN (d
   WHERE enc_followup_cnt > 0)
   JOIN (pedf
   WHERE (pedf.pat_ed_doc_followup_id=enc_followup_keys->qual[d.seq].pat_ed_doc_followup_id))
   JOIN (ped
   WHERE ped.pat_ed_document_id=pedf.pat_ed_doc_id)
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(enc_followup_keys->qual[d.seq].encntr_nk,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(ped.encntr_id,16))), v_bar,
   CALL print(trim(cnvtstring(ped.person_id,16))), v_bar,
   CALL print(trim(cnvtstring(pedf.pat_ed_doc_followup_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(pedf.pat_ed_doc_id,16))), v_bar,
   CALL print(trim(cnvtstring(ped.event_id,16))), v_bar,
   CALL print(trim(cnvtstring(ped.pat_ed_domain_cd,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ped.create_dt_tm,0,cnvtdatetimeutc(ped
       .create_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(enc_followup_keys->qual[d.seq].time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(ped.create_dt_tm,cnvtint(enc_followup_keys->qual[d.seq].
      time_zone),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,ped.signed_dt_tm,0,cnvtdatetimeutc(ped
       .signed_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(enc_followup_keys->qual[d.seq].time_zone,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(ped.signed_dt_tm,cnvtint(enc_followup_keys->qual[d.seq].
      time_zone),"HHmmsscc"),"00000000","0","        ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(ped.status_cd,16))), v_bar,
   CALL print(trim(cnvtstring(ped.create_id,16))), v_bar,
   CALL print(trim(cnvtstring(ped.signed_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(pedf.provider_id,16))), v_bar,
   CALL print(trim(replace(pedf.provider_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(pedf.fol_within_days,16))),
   v_bar,
   CALL print(trim(cnvtstring(pedf.days_or_weeks,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,pedf.fol_within_dt_tm,0,cnvtdatetimeutc(pedf
       .fol_within_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(enc_followup_keys->qual[d.seq].time_zone,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(pedf.fol_within_dt_tm,cnvtint(enc_followup_keys->qual[d.seq
      ].time_zone),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(replace(pedf.fol_within_range,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(validate(pedf.location_cd,0),16))),
   v_bar,
   CALL print(trim(cnvtstring(pedf.organization_id,16))), v_bar,
   CALL print(trim(cnvtstring(pedf.address_type_cd,16))), v_bar, "3",
   v_bar,
   CALL print(trim(extract_dt_tm_fmt)), v_bar,
   "1", v_bar,
   CALL print(trim(cnvtstring(pedf.add_long_text_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(pedf.cmt_long_text_id,16))), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 IF (debug="Y")
  CALL echo(build("Finish writing file:",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 ENDIF
 FREE RECORD enc_followup_keys
 CALL echo(build("FOLLOWUP Count = ",curqual))
 CALL edwupdatescriptstatus("FOLLOWUP",curqual,"6","6")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "006 01/06/08 PS017661"
END GO
