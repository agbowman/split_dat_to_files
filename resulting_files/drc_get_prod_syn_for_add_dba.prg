CREATE PROGRAM drc_get_prod_syn_for_add:dba
 FREE SET reply
 RECORD reply(
   1 drug_names[*]
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE wherestr = vc WITH public, noconstant(" ")
 DECLARE buildstr = vc WITH public, noconstant(" ")
 DECLARE drgcnt = i4 WITH public, noconstant(0)
 DECLARE cmeddef = f8 WITH public, noconstant(0.0)
 DECLARE cdesc = f8 WITH public, noconstant(0.0)
 DECLARE syn_cnt = i4 WITH public, noconstant(0)
 DECLARE prod_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET drgcnt = size(request->drug,5)
 SET cmeddef = uar_get_code_by("MEANING",11001,"MED_DEF")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 CASE (request->search_type_flag)
  OF 1:
   EXECUTE FROM lookup_product_beg TO lookup_product_end
  OF 2:
   EXECUTE FROM lookup_synonym_beg TO lookup_synonym_end
 ENDCASE
 GO TO exit_script
#lookup_product_beg
 FOR (j = 1 TO drgcnt)
   IF (j=1)
    SET wherestr = build("(oii.value_key in (patstring('",cnvtupper(trim(cnvtalphanum(request->drug[j
        ].drug_name))),"*'))")
   ELSE
    SET buildstr = build(" or oii.value_key in (patstring('",cnvtupper(trim(cnvtalphanum(request->
        drug[j].drug_name))),"*'))")
    SET wherestr = concat(wherestr,buildstr)
   ENDIF
 ENDFOR
 SET wherestr = build(wherestr,")")
 SELECT INTO "nl:"
  oii.object_type_cd, oii.identifier_type_cd, oii.active_ind,
  oii.generic_object, oii.primary_ind, oii.value_key,
  oii.value
  FROM object_identifier_index oii
  PLAN (oii
   WHERE oii.object_type_cd=cmeddef
    AND oii.identifier_type_cd=cdesc
    AND oii.active_ind=1
    AND oii.generic_object=0
    AND oii.primary_ind=1
    AND parser(wherestr))
  ORDER BY oii.value_key
  HEAD REPORT
   prod_cnt = 0, stat = alterlist(reply->drug_names,10)
  HEAD oii.value_key
   prod_cnt = (prod_cnt+ 1)
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(reply->drug_names,(prod_cnt+ 9))
   ENDIF
   reply->drug_names[prod_cnt].mnemonic = oii.value
  FOOT REPORT
   stat = alterlist(reply->drug_names,prod_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
 ENDIF
#lookup_product_end
#lookup_synonym_beg
 FOR (j = 1 TO drgcnt)
   IF (j=1)
    SET wherestr = build("(ocs.mnemonic_key_cap in (patstring('",cnvtupper(trim(cnvtalphanum(request
        ->drug[j].drug_name))),"*'))")
   ELSE
    SET buildstr = build(" or ocs.mnemonic_key_cap in (patstring('",cnvtupper(trim(cnvtalphanum(
        request->drug[j].drug_name))),"*'))")
    SET wherestr = concat(wherestr,buildstr)
   ENDIF
 ENDFOR
 SET wherestr = build(wherestr,")")
 SELECT INTO "nl:"
  ocs.mnemonic_key_cap, ocs.active_ind, ocs.mnemonic
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE parser(wherestr)
    AND ocs.active_ind > 0.0)
  ORDER BY ocs.mnemonic
  HEAD REPORT
   syn_cnt = 0, stat = alterlist(reply->drug_names,10)
  HEAD ocs.mnemonic
   syn_cnt = (syn_cnt+ 1)
   IF (mod(syn_cnt,10)=1)
    stat = alterlist(reply->drug_names,(syn_cnt+ 9))
   ENDIF
   reply->drug_names[syn_cnt].mnemonic = ocs.mnemonic
  FOOT REPORT
   stat = alterlist(reply->drug_names,syn_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
 ENDIF
#lookup_synonym_end
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
