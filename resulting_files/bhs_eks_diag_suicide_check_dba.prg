CREATE PROGRAM bhs_eks_diag_suicide_check:dba
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 SET ms_file_name = concat("al_test_rule_",trim(cnvtstring(rand(0),20),3),".txt")
 CALL echoxml(eksdata,ms_file_name)
 IF (size(eksdata->tqual[3].qual[4].data,5) > 0)
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE d.diagnosis_id=cnvtreal(eksdata->tqual[3].qual[4].data[2].misc))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   DETAIL
    log_misc1 = concat("Order created due to diagnosis: ",trim(n.source_string,3))
   WITH nocounter
  ;end select
 ELSEIF (size(eksdata->tqual[3].qual[5].data,5) > 0)
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE d.diagnosis_id=cnvtreal(eksdata->tqual[3].qual[5].data[2].misc))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   DETAIL
    log_misc1 = concat("Order created due to diagnosis: ",trim(n.source_string,3))
   WITH nocounter
  ;end select
 ENDIF
 SET retval = 100
#exit_script
END GO
