CREATE PROGRAM bhs_sogi_input_csv:dba
 FREE RECORD sogi
 RECORD sogi(
   1 sogi_cnt = i4
   1 list[*]
     2 hnememberid = vc
     2 cmrn = vc
     2 masshealthid = vc
 )
 FREE RECORD processed
 RECORD processed(
   1 list[*]
     2 cmrn = vc
 )
 DECLARE header_row = i2
 DECLARE pos1 = i4
 DECLARE pos2 = i4
 DECLARE pos3 = i4
 DECLARE pos4 = i4
 DECLARE i = i4
 FREE DEFINE rtl2
 DEFINE rtl2 "/cerner/d_p627/bhscust/sogi_input.csv"
 SELECT INTO "nl:"
  textlen_t_line = textlen(t.line)
  FROM rtl2t t
  DETAIL
   IF (header_row > 0)
    sogi->sogi_cnt += 1, stat = alterlist(sogi->list,sogi->sogi_cnt), pos1 = findstring(char(9),t
     .line),
    sogi->list[sogi->sogi_cnt].hnememberid = substring(1,(pos1 - 1),t.line), sogi->list[sogi->
    sogi_cnt].cmrn = substring((pos1+ 1),textlen_t_line,t.line)
   ENDIF
   header_row = 1
  WITH nocounter
 ;end select
 SELECT INTO "bhs_sogi_test.csv"
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
 DECLARE i = i4
 DECLARE ndx = i4
 SET stat = alterlist(processed->list,sogi->sogi_cnt)
 FOR (i = 1 TO sogi->sogi_cnt)
  IF (locateval(ndx,1,sogi->sogi_cnt,sogi->list[i].cmrn,processed->list[ndx].cmrn)=0)
   EXECUTE bhs_sogi_disab_extract sogi->list[i].cmrn, sogi->list[i].hnememberid, sogi->list[i].
   masshealthid,
   "bhs_sogi_test.csv"
  ENDIF
  SET processed->list[i].cmrn = sogi->list[i].cmrn
 ENDFOR
#exit_program
 FREE RECORD sogi
END GO
