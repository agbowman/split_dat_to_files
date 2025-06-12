CREATE PROGRAM bhs_sogi_daily_updates:dba
 FREE RECORD sogi
 RECORD sogi(
   1 sogi_cnt = i4
   1 list[*]
     2 person_id = f8
     2 hnememberid = vc
     2 cmrn = vc
     2 masshealthid = vc
 )
 DECLARE header_row = i2
 DECLARE rec_pos = i4
 DECLARE ndx = i4
 DECLARE i = i4
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE sogi_start_dt_tm = vc WITH protect, constant(format(cnvtlookbehind("1,D",sysdate),
   "DD-MMM-YYYY 00:00:00;;q"))
 DECLARE sogi_end_dt_tm = vc WITH protect, constant(format(cnvtlookbehind("1,D",sysdate),
   "DD-MMM-YYYY 23:59:59;;q"))
 DECLARE sogi_daily_file = vc WITH protect, constant(concat("cissogi_",format(cnvtlookbehind("1,D",
     sysdate),"YYYYMMDD;;q"),".txt"))
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.event_cd IN (2152008669.00, 2152008701.0, 2152008735.00, 2152008771.0, 2152008807.00,
  2152008841.00)
   AND ce.updt_dt_tm BETWEEN cnvtdatetime(sogi_start_dt_tm) AND cnvtdatetime(sogi_end_dt_tm)
  DETAIL
   rec_pos = 0, rec_pos = locateval(ndx,1,sogi->sogi_cnt,ce.person_id,sogi->list[ndx].person_id)
   IF (rec_pos=0)
    sogi->sogi_cnt += 1, stat = alterlist(sogi->list,sogi->sogi_cnt), sogi->list[sogi->sogi_cnt].
    person_id = ce.person_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM shx_activity s,
   shx_response sr,
   shx_alpha_response sar,
   nomenclature n
  PLAN (s)
   JOIN (sr
   WHERE sr.shx_activity_id=s.shx_activity_id
    AND sr.task_assay_cd IN (567878076.0, 563829548.0, 567878112.0)
    AND sr.updt_dt_tm BETWEEN cnvtdatetime(sogi_start_dt_tm) AND cnvtdatetime(sogi_end_dt_tm))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND n.nomenclature_id > 0)
  DETAIL
   rec_pos = 0, rec_pos = locateval(ndx,1,sogi->sogi_cnt,s.person_id,sogi->list[ndx].person_id)
   IF (rec_pos=0)
    sogi->sogi_cnt += 1, stat = alterlist(sogi->list,sogi->sogi_cnt), sogi->list[sogi->sogi_cnt].
    person_id = s.person_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_info pi
  WHERE pi.info_sub_type_cd=633825796.0
   AND pi.value_dt_tm BETWEEN cnvtdatetime(sogi_start_dt_tm) AND cnvtdatetime(sogi_end_dt_tm)
   AND pi.active_ind=1
   AND pi.end_effective_dt_tm > sysdate
  DETAIL
   rec_pos = 0, rec_pos = locateval(ndx,1,sogi->sogi_cnt,pi.person_id,sogi->list[ndx].person_id)
   IF (rec_pos=0)
    sogi->sogi_cnt += 1, stat = alterlist(sogi->list,sogi->sogi_cnt), sogi->list[sogi->sogi_cnt].
    person_id = pi.person_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  WHERE expand(ndx,1,sogi->sogi_cnt,pa.person_id,sogi->list[ndx].person_id)
   AND pa.person_alias_type_cd=2
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > sysdate
  DETAIL
   rec_pos = 0, rec_pos = locateval(ndx,1,sogi->sogi_cnt,pa.person_id,sogi->list[ndx].person_id)
   IF (rec_pos > 0)
    sogi->list[rec_pos].cmrn = pa.alias
   ENDIF
  WITH nocounter
 ;end select
 DECLARE i = i4
 SELECT INTO value(sogi_daily_file)
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   col 0,
   "HNEMEMBERNBR|MASSHEALTHID|CMRN|RACE1|RACE1_UPDT_DT|RACE2|RACE2_UPDT_DT|RACE3|RACE3_UPDT_DT|RACE4|RACE4_UPDT_DT|",
   col + 1,
   "RACE5|RACE5_UPDT_DT|ETHNICITY|ETHNICITY_UPDT_DT|ETHNICGRP1|ETHNICGRP1_UPDT_DT|ETHNICGRP2|ETHNICGRP2_UPDT_DT|",
   col + 1,
   "LANG_SPOKEN|LANG_SPOKEN_UPDT_DT|LANG_READ|LANG_READ_UPDT_DT|LANG_PROF|LANG_PROF_UPDT_DT|GENDER_IDENT|",
   col + 1,
   "GENDER_IDENT_UPDT_DT|SEXUAL_ORIENT|SEXUAL_ORIENT_UPDT_DT|PRONOUN|PRONOUN_UPDT_DT|DISABILITY1|DISABILITY1_UPDT_DT|",
   col + 1,
   "DISABILITY2|DISABILITY2_UPDT_DT|DISABILITY3|DISABILITY3_UPDT_DT|DISABILITY4|DISABILITY4_UPDT_DT|DISABILITY5|",
   col + 1,
   "DISABILITY5_UPDT_DT|DISABILITY6|DISABILITY6_UPDT_DT|EMAIL_ADDR|EMAIL_ADDR_UPDT_DT|PRIM_PHONE|PRIM_PHONE_UPDT_DT|",
   col + 1, "SEC_PHONE|SEC_PHONE_UPDT_DT|PREF_CONTACT|PREF_CONTACT_UPDT_DT|REG_VER_DT_TM", row + 1,
   row + 1
  WITH nocounter, format = variable, maxcol = 2000
 ;end select
 FOR (i = 1 TO sogi->sogi_cnt)
   EXECUTE bhs_sogi_disab_extract sogi->list[i].cmrn, sogi->list[i].hnememberid, sogi->list[i].
   masshealthid,
   sogi_daily_file
 ENDFOR
 SET ms_dclcom = concat("mv ",trim(cnvtlower(sogi_daily_file),3)," ",build(logical("bhscust"),
   "/ftp/bhs_sogi_daily_updates/"),trim(cnvtlower(sogi_daily_file),3))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
#exit_program
 CALL echo("***")
 CALL echo(sogi->sogi_cnt)
 CALL echo(sogi_daily_file)
 CALL echo("---")
 FREE RECORD sogi
END GO
