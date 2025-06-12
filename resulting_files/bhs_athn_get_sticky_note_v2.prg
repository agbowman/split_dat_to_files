CREATE PROGRAM bhs_athn_get_sticky_note_v2
 DECLARE per_id = f8 WITH protect, constant( $2)
 DECLARE enc_id = f8 WITH protect, constant( $3)
 DECLARE where_params_from_dt = vc WITH protect, noconstant("1=1")
 DECLARE where_params_to_dt = vc WITH protect, noconstant("1=1")
 IF (( $4 > " ")
  AND ( $5 > " "))
  SET date_line = substring(1,10, $4)
  SET time_line = substring(12,8, $4)
  SET where_params_from_dt = build("S.updt_dt_tm >= cnvtdatetime(",cnvtdatetimeutc2(date_line,
    "yyyy-MM-dd",time_line,"HH:mm:ss",4),")")
  SET date_line = substring(1,10, $5)
  SET time_line = substring(12,8, $5)
  SET where_params_to_dt = build("S.updt_dt_tm <= cnvtdatetime(",cnvtdatetimeutc2(date_line,
    "yyyy-MM-dd",time_line,"HH:mm:ss",4),")")
 ENDIF
 DECLARE s_note_type_cd = f8 WITH protect, constant(cnvtint( $6))
 DECLARE per_name = vc WITH noconstant(" ")
 DECLARE where_params = vc WITH noconstant(" ")
 DECLARE where_params_note_tpye = vc WITH noconstant("1=1")
 IF (s_note_type_cd > 0)
  SET where_params_note_tpye = build("S.STICKY_NOTE_TYPE_CD = ",s_note_type_cd)
 ENDIF
 DECLARE cnt = i2 WITH noconstant(0)
 SET where_params = build(" (S.PARENT_ENTITY_NAME = 'PERSON' AND S.PARENT_ENTITY_ID = ",per_id,")")
 IF (enc_id != 0)
  SET where_params = build(" (S.PARENT_ENTITY_NAME = 'ENCOUNTER' AND S.PARENT_ENTITY_ID = ",enc_id,
   ") OR ",where_params)
 ENDIF
 FREE RECORD out_rec
 RECORD out_rec(
   1 person_id = vc
   1 person_name = vc
   1 encounter_id = vc
   1 sticky_notes[*]
     2 sticky_note_id = vc
     2 long_text_id = vc
     2 text = vc
     2 public_note_ind = vc
     2 type = vc
     2 status = vc
     2 updt_by_prsnl_id = vc
     2 updt_by_prsnl_name = vc
     2 updt_dt_tm = vc
 )
 SELECT INTO "NL:"
  p.name_full_formatted
  FROM person p
  WHERE p.person_id=per_id
  HEAD p.person_id
   out_rec->person_id = cnvtstring(p.person_id), out_rec->encounter_id = cnvtstring(enc_id), out_rec
   ->person_name = p.name_full_formatted
  WITH maxrec = 1, time = 5
 ;end select
 SELECT INTO "NL:"
  s.sticky_note_id, s.long_text_id, s.parent_entity_id,
  s.parent_entity_name, s_sticky_note_text = trim(replace(replace(replace(replace(replace(s
        .sticky_note_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
   3), l.long_text_id,
  l_long_text = substring(1,2000,trim(replace(replace(replace(replace(replace(l.long_text,"&","&amp;",
         0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)), s_public_ind =
  IF (s.public_ind=1) "true"
  ELSE "false"
  ENDIF
  , s_sticky_note_type_disp = uar_get_code_display(s.sticky_note_type_cd),
  s_sticky_note_status_disp = uar_get_code_display(s.sticky_note_status_cd), s.updt_id, prsnl_name =
  trim(replace(replace(replace(replace(replace(p.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  s_updt_dt_tm = format(s.updt_dt_tm,"MM/dd/yyyy HH:mm:ss;;D"), s.updt_task, s.updt_applctx,
  s.end_effective_dt_tm
  FROM sticky_note s,
   long_text l,
   prsnl p
  PLAN (s
   WHERE parser(where_params)
    AND parser(where_params_note_tpye)
    AND parser(where_params_from_dt)
    AND parser(where_params_to_dt))
   JOIN (l
   WHERE l.long_text_id=s.long_text_id)
   JOIN (p
   WHERE p.person_id=s.updt_id)
  ORDER BY s.updt_dt_tm DESC
  HEAD s.sticky_note_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->sticky_notes,cnt), out_rec->sticky_notes[cnt].
   sticky_note_id = cnvtstring(s.sticky_note_id),
   out_rec->sticky_notes[cnt].long_text_id = cnvtstring(l.long_text_id)
   IF (l.long_text_id=0)
    out_rec->sticky_notes[cnt].text = s_sticky_note_text
   ELSE
    out_rec->sticky_notes[cnt].text = l_long_text
   ENDIF
   out_rec->sticky_notes[cnt].public_note_ind = s_public_ind, out_rec->sticky_notes[cnt].type =
   s_sticky_note_type_disp, out_rec->sticky_notes[cnt].status = s_sticky_note_status_disp,
   out_rec->sticky_notes[cnt].updt_by_prsnl_id = cnvtstring(s.updt_id), out_rec->sticky_notes[cnt].
   updt_by_prsnl_name = prsnl_name, out_rec->sticky_notes[cnt].updt_dt_tm = s_updt_dt_tm
  WITH nocounter, formfeed = none, format = variable,
   nullreport, maxcol = 32000, maxrow = 0,
   time = 60
 ;end select
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO
