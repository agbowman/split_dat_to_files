CREATE PROGRAM bhs_athn_notetype_asso_temp_v2
 FREE RECORD note_type_associate_st
 RECORD note_type_associate_st(
   1 qual[*]
     2 note_type_id = vc
     2 note_type_desc = vc
     2 note_type_assoc[*]
       3 template_id = vc
       3 template_name = vc
       3 cki = vc
       3 smart_standard = vc
 )
 DECLARE vcnt = i4
 DECLARE acnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE ntid = f8 WITH protect, constant( $2)
 SELECT INTO  $1
  notetypedesc = trim(replace(replace(replace(replace(replace(replace(n.note_type_description,"–",
         "-",0),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  templatename = trim(replace(replace(replace(replace(replace(replace(c.template_name,"–","-",0),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), notetypeid =
  cnvtstring(n.note_type_id),
  templateid = cnvtstring(c.template_id), templatecki = trim(replace(replace(replace(replace(replace(
        replace(c.cki,"–","-",0),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), smart_standard =
  IF (c.smart_template_ind=1) "SMART"
  ELSE "STANDARD"
  ENDIF
  FROM note_type n,
   note_type_template_reltn nt,
   clinical_note_template c
  PLAN (n
   WHERE n.event_cd=ntid)
   JOIN (nt
   WHERE nt.note_type_id=n.note_type_id
    AND n.note_type_id > 0)
   JOIN (c
   WHERE c.template_id=nt.template_id
    AND c.template_id > 0)
  ORDER BY n.note_type_id
  HEAD n.note_type_id
   vcnt = (vcnt+ 1), stat = alterlist(note_type_associate_st->qual,vcnt), note_type_associate_st->
   qual[vcnt].note_type_id = notetypeid,
   note_type_associate_st->qual[vcnt].note_type_desc = notetypedesc, acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(note_type_associate_st->qual[vcnt].note_type_assoc,acnt),
   note_type_associate_st->qual[vcnt].note_type_assoc[acnt].template_id = templateid,
   note_type_associate_st->qual[vcnt].note_type_assoc[acnt].template_name = templatename,
   note_type_associate_st->qual[vcnt].note_type_assoc[acnt].cki = templatecki, note_type_associate_st
   ->qual[vcnt].note_type_assoc[acnt].smart_standard = smart_standard
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 CALL echorecord(note_type_associate_st)
 CALL echojson(note_type_associate_st, $1)
 FREE RECORD note_type_associate_st
END GO
