CREATE PROGRAM bhs_athn_note_types
 SET file_name = request->output_device
 DECLARE coding_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 SET position_cd = request->person[1].person_id
 SET var_pos_cd = request->prsnl[1].prsnl_id
 IF (position_cd != 1)
  SELECT DISTINCT INTO value(file_name)
   n_event_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(n.event_cd),
          3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n
   .event_cd
   FROM note_type n,
    note_type_list ntl
   WHERE n.note_type_id=ntl.note_type_id
    AND n.data_status_ind=1
    AND ntl.role_type_cd=position_cd
   ORDER BY n.note_type_description
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   DETAIL
    col 1, "<PowerNoteType>", row + 1,
    id = build("<EventCd>",cnvtint(n.event_cd),"</EventCd>"), col + 1, id,
    row + 1, desc = build("<EventDisplay>",n_event_disp,"</EventDisplay>"), col + 1,
    desc, row + 1, col 1,
    "</PowerNoteType>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 1000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ELSE
  SELECT DISTINCT INTO value(file_name)
   n_event_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(n.event_cd),
          3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), n
   .event_cd
   FROM note_type n
   WHERE n.data_status_ind=1
    AND  NOT (n.event_cd IN (
   (SELECT
    ves.event_cd
    FROM priv_loc_reltn p,
     privilege pr,
     privilege_exception pe,
     v500_event_set_explode ves
    WHERE p.position_cd=var_pos_cd
     AND pr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND pr.privilege_cd=2624
     AND pe.privilege_id=pr.privilege_id
     AND pe.exception_id=ves.event_set_cd)))
    AND  NOT (n.event_cd IN (
   (SELECT
    pe.exception_id
    FROM priv_loc_reltn p,
     privilege pr,
     privilege_exception pe
    WHERE p.position_cd=var_pos_cd
     AND pr.priv_loc_reltn_id=p.priv_loc_reltn_id
     AND pr.privilege_cd=2624
     AND pe.privilege_id=pr.privilege_id)))
   ORDER BY n_event_disp
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1
   DETAIL
    col 1, "<PowerNoteType>", row + 1,
    id = build("<EventCd>",cnvtint(n.event_cd),"</EventCd>"), col + 1, id,
    row + 1, desc = build("<EventDisplay>",n_event_disp,"</EventDisplay>"), col + 1,
    desc, row + 1, col 1,
    "</PowerNoteType>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 1000, format = variable, maxrow = 0,
    time = 30
  ;end select
 ENDIF
END GO
