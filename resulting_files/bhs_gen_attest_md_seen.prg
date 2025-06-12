CREATE PROGRAM bhs_gen_attest_md_seen
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
  )
 ENDIF
 DECLARE var_template_name = vc WITH constant("Attending attestation - Patient seen")
 DECLARE cs120_nocomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 SELECT INTO "nl:"
  FROM clinical_note_template cnt,
   long_blob lb
  PLAN (cnt
   WHERE cnt.template_name=var_template_name)
   JOIN (lb
   WHERE cnt.template_id=lb.parent_entity_id
    AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE")
  HEAD REPORT
   blob_in = fillstring(64000," "), blob_out1 = fillstring(64000," "), blob_out2 = fillstring(64000,
    " "),
   blob_len = size(blob_out1), blob_in = lb.long_blob
   IF (lb.compression_cd IN (cs120_nocomp_cd, 0.00))
    blob_out1 = blob_in
   ELSE
    CALL uar_ocf_uncompress(blob_in,size(blob_in),blob_out1,size(blob_out1),blob_len)
   ENDIF
   CALL uar_rtf2(blob_out1,size(blob_out1),blob_out2,size(blob_out2),0), blob_out2 = trim(replace(
     blob_out2,char(13)," ",0),3), blob_out2 = trim(replace(blob_out2,char(10)," ",0),3),
   blob_out2 = trim(replace(blob_out2,"  "," ",0),3), reply->text = trim(blob_out2,3)
  WITH nocounter
 ;end select
 CALL echo(reply->text)
END GO
