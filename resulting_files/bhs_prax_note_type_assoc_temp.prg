CREATE PROGRAM bhs_prax_note_type_assoc_temp
 FREE RECORD note_type_associate_st
 RECORD note_type_associate_st(
   1 qual[*]
     2 note_type_id = f8
     2 note_type_desc = vc
     2 note_type_assoc[*]
       3 template_id = f8
       3 template_name = vc
 )
 DECLARE vcnt = i4
 DECLARE acnt = i4
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE ntid = f8 WITH protect, constant(request->person[1].person_id)
 SELECT INTO "NL:"
  n.note_type_description, c.template_name, n.note_type_id,
  c.template_id
  FROM note_type n,
   note_type_template_reltn nt,
   clinical_note_template c
  PLAN (n
   WHERE n.note_type_id=ntid)
   JOIN (nt
   WHERE nt.note_type_id=n.note_type_id
    AND n.note_type_id > 0)
   JOIN (c
   WHERE c.template_id=nt.template_id
    AND c.template_id > 0)
  ORDER BY n.note_type_id
  HEAD n.note_type_id
   vcnt = (vcnt+ 1), stat = alterlist(note_type_associate_st->qual,vcnt), note_type_associate_st->
   qual[vcnt].note_type_id = n.note_type_id,
   note_type_associate_st->qual[vcnt].note_type_desc = n.note_type_description, acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(note_type_associate_st->qual[vcnt].note_type_assoc,acnt),
   note_type_associate_st->qual[vcnt].note_type_assoc[acnt].template_id = c.template_id,
   note_type_associate_st->qual[vcnt].note_type_assoc[acnt].template_name = c.template_name
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SET json = cnvtrectojson(note_type_associate_st)
 CALL echo(json)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, separator = " "
 ;end select
END GO
