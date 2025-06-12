CREATE PROGRAM bed_get_mltm_oc_dnum:dba
 FREE SET reply
 RECORD reply(
   1 too_many_results_ind = i2
   1 orderables[*]
     2 drug_synonym_id = f8
     2 display = vc
     2 dnum = vc
     2 dnum_concept_cki = vc
     2 cnum = vc
     2 cnum_concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_txt = vc
 DECLARE search_string = vc
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SET search_string = "*"
 IF (cnvtupper(request->search_type_flag)="S")
  SET search_string = concat('"',trim(request->search_string),'*"')
 ELSEIF (cnvtupper(request->search_type_flag)="E")
  SET search_string = concat('"',trim(request->search_string),'"')
 ELSE
  SET search_string = concat('"*',trim(request->search_string),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 SET parse_txt = concat("cnvtupper(m.description) =",search_string)
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m,
   code_value c
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    oc.catalog_cd
    FROM order_catalog oc
    WHERE oc.cki=m.catalog_cki
     AND ((m.catalog_concept_cki > " "
     AND oc.concept_cki=m.catalog_concept_cki) OR (m.catalog_concept_cki IN ("", " ", null)
     AND oc.concept_cki IN ("", " ", null))) )))
    AND parser(parse_txt))
   JOIN (c
   WHERE ((c.cdf_meaning=m.mnemonic_type_mean
    AND m.mnemonic_type_mean > " ") OR (cnvtupper(c.display)=cnvtupper(m.mnemonic_type)
    AND m.mnemonic_type_mean IN ("", " ", null)))
    AND c.code_set=6011
    AND c.active_ind=1)
  ORDER BY m.catalog_cki, m.catalog_concept_cki
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->orderables,request->max_reply)
  HEAD m.catalog_cki
   cnt = cnt
  HEAD m.catalog_concept_cki
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF ((cnt > request->max_reply))
    reply->too_many_results_ind = 1, cnt = (cnt - 1), list_cnt = (list_count - 1)
   ELSE
    reply->orderables[cnt].display = m.description, reply->orderables[cnt].dnum = m.catalog_cki,
    reply->orderables[cnt].dnum_concept_cki = m.catalog_concept_cki
   ENDIF
  DETAIL
   IF (c.cdf_meaning="PRIMARY")
    reply->orderables[cnt].display = m.mnemonic, reply->orderables[cnt].cnum = m.synonym_cki, reply->
    orderables[cnt].cnum_concept_cki = m.synonym_concept_cki
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->orderables,cnt)
  WITH maxrec = value((request->max_reply+ 1)), nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
