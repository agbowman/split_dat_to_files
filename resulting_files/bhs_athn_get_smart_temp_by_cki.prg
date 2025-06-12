CREATE PROGRAM bhs_athn_get_smart_temp_by_cki
 RECORD orequest(
   1 patient_id = f8
   1 encntr_id = f8
   1 template_cki = vc
   1 format_cd = f8
 )
 RECORD out_rec(
   1 template_text = vc
 )
 DECLARE rtf_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",23,"RTF"))
 SET orequest->patient_id =  $2
 SET orequest->encntr_id =  $3
 SET orequest->template_cki =  $4
 SET orequest->format_cd = rtf_cd
 SET stat = tdbexecute(600005,3202004,969555,"REC",orequest,
  "REC",oreply)
 SET out_rec->template_text = oreply->template_text
 CALL echojson(out_rec, $1)
END GO
