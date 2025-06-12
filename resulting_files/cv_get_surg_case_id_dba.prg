CREATE PROGRAM cv_get_surg_case_id:dba
 DECLARE z = i4 WITH protect, noconstant(0)
 DECLARE ref_num_out = f8 WITH protect, noconstant(0.0)
 DECLARE meaningval = vc WITH protect
 DECLARE codeset = i4 WITH protect, noconstant(22369)
 DECLARE cvct = i4 WITH protect, noconstant(1)
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 DECLARE iret = i4 WITH protect
 SELECT INTO "NL:"
  ce.reference_nbr
  FROM clinical_event ce
  WHERE (ce.event_id=register->rec[1].event_id)
  DETAIL
   cv_omf_rec->reference_nbr = ce.reference_nbr
  WITH nocounter
 ;end select
 CALL echo(build("The ref_nbr is :",cv_omf_rec->reference_nbr))
 CALL echo(build("The input # is: ",cv_omf_rec->reference_nbr))
 SET z = cnvtint(findstring("SN",cnvtupper(cv_omf_rec->reference_nbr),1))
 IF (z >= 1)
  SET ref_num_out = cnvtreal(substring(1,(z - 1),cv_omf_rec->reference_nbr))
  CALL echo("*****************************")
  CALL echo(build("The ref_num_out is: ",ref_num_out))
  CALL echo("*****************************")
  SELECT INTO "NL:"
   pd.surg_case_id
   FROM perioperative_document pd
   WHERE pd.periop_doc_id=ref_num_out
   DETAIL
    cv_omf_rec->form_event_id = pd.surg_case_id
   WITH nocounter
  ;end select
  CALL echo("*****************************")
  CALL echo(build("This is the surg_case_id: ",cv_omf_rec->form_event_id))
  CALL echo("*****************************")
  SET meaningval = "FBDESIGNER"
  SET iret = uar_get_meaning_by_codeset(codeset,nullterm(meaningval),cvct,codevalue)
  IF (iret=0)
   SET cv_omf_rec->source_cd = codevalue
   CALL echo(build("Success for FBDESIGNER Code value: ",codevalue))
   IF (cvct > 1)
    CALL echo("Multiple Source Codes found for the CDF Meaning")
   ENDIF
  ELSE
   CALL echo("")
  ENDIF
 ELSE
  CALL echo("PowerForm number, get code_value, store in source_cd")
  EXECUTE cv_get_parent_event_id
  SET cv_omf_rec->form_event_id = cv_omf_rec->top_parent_event_id
  SET meaningval = "POWERFORM"
  SET iret = uar_get_meaning_by_codeset(codeset,nullterm(meaningval),cvct,codevalue)
  CALL echo(meaningval)
  CALL echo(iret)
  IF (iret=0)
   SET cv_omf_rec->source_cd = codevalue
   CALL echo(build("Success. Code value: ",codevalue))
   IF (cvct > 1)
    CALL echo("Multiple Source Codes found for the CDF Meaning")
    CALL echo("This could be a source of error ...Please check your code")
   ENDIF
  ELSE
   CALL echo("Failure.POWERFORM code_value")
  ENDIF
 ENDIF
#exit_script
 DECLARE cv_get_surg_case_id_vrsn = vc WITH private, constant("MOD 007 05/19/06 BM9013")
END GO
