CREATE PROGRAM bed_get_drugs_by_category:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 drug_list[*]
      2 category_id = f8
      2 category_name = vc
      2 drug_identifier = vc
      2 drug_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE SET tempcategories
 RECORD tempcategories(
   1 qual[*]
     2 parent_cat_id = f8
     2 parent_cat_name = vc
     2 child1_id = f8
     2 child1_name = vc
     2 child2_id = f8
     2 child2_name = vc
 )
 FREE SET comborequest
 RECORD comborequest(
   1 dnum_list[*]
     2 dnum = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE nqueryidx = i4 WITH noconstant(0)
 DECLARE drugcnt = i4 WITH noconstant(0)
 DECLARE replycnt = i4 WITH noconstant(0)
 DECLARE combocnt = i4 WITH noconstant(0)
 DECLARE dnumcnt = i4 WITH noconstant(0)
 DECLARE totalrepcnt = i4 WITH noconstant(0)
 DECLARE loadcategoriesfromlist(null) = null WITH protect
 CALL loadcategoriesfromlist(null)
 IF (qualcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SELECT INTO "nl:"
   FROM mltm_category_drug_xref mdx,
    mltm_drug_categories c,
    mltm_drug_name_map mdnm,
    mltm_drug_name mdn,
    (dummyt d  WITH seq = size(tempcategories->qual,5))
   PLAN (d)
    JOIN (mdx
    WHERE mdx.multum_category_id IN (tempcategories->qual[d.seq].parent_cat_id, tempcategories->qual[
    d.seq].child1_id, tempcategories->qual[d.seq].child2_id))
    JOIN (c
    WHERE c.multum_category_id=mdx.multum_category_id)
    JOIN (mdnm
    WHERE mdnm.drug_identifier=mdx.drug_identifier
     AND mdnm.function_id=16)
    JOIN (mdn
    WHERE mdn.drug_synonym_id=mdnm.drug_synonym_id)
   ORDER BY mdx.multum_category_id
   HEAD REPORT
    drugcnt = 0
   DETAIL
    drugcnt = (drugcnt+ 1)
    IF (mod(drugcnt,5)=1)
     stat = alterlist(reply->drug_list,(drugcnt+ 4))
    ENDIF
    reply->drug_list[drugcnt].category_id = mdx.multum_category_id, reply->drug_list[drugcnt].
    category_name = c.category_name, reply->drug_list[drugcnt].drug_identifier = mdx.drug_identifier,
    reply->drug_list[drugcnt].drug_name = mdn.drug_name
   FOOT REPORT
    stat = alterlist(reply->drug_list,drugcnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF ((request->combo_ind=1))
    SET totalrepcnt = size(reply->drug_list,5)
    SET stat = alterlist(comborequest->dnum_list,size(reply->drug_list,5))
    FOR (replycnt = 1 TO size(reply->drug_list,5))
      SET comborequest->dnum_list[replycnt].dnum = reply->drug_list[replycnt].drug_identifier
    ENDFOR
    SET trace = recpersist
    EXECUTE bed_get_combo_dnums  WITH replace(request,comborequest), replace(reply,comboreply)
    SET trace = norecpersist
    IF ((comboreply->status_data.status="S"))
     FOR (drugcnt = 1 TO size(reply->drug_list,5))
      SET reply->drug_list[drugcnt].drug_name = comboreply->dnum_list[drugcnt].member_drug_name
      FOR (combocnt = 1 TO size(comboreply->dnum_list[drugcnt].combo_list,5))
        SET totalrepcnt = (totalrepcnt+ 1)
        SET stat = alterlist(reply->drug_list,totalrepcnt)
        SET reply->drug_list[totalrepcnt].drug_identifier = comboreply->dnum_list[drugcnt].
        combo_list[combocnt].drug_identifier
        SET reply->drug_list[totalrepcnt].drug_name = comboreply->dnum_list[drugcnt].combo_list[
        combocnt].drug_name
      ENDFOR
     ENDFOR
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SUBROUTINE loadcategoriesfromlist(null)
   SET qualcnt = 0
   SET nqueryidx = size(request->items,5)
   SELECT INTO "nl:"
    c.multum_category_id, c.category_name, xref.sub_category_id,
    c1.category_name, xref2.sub_category_id, c2.category_name
    FROM mltm_drug_categories c,
     mltm_category_sub_xref xref,
     mltm_drug_categories c1,
     mltm_category_sub_xref xref2,
     mltm_drug_categories c2
    PLAN (c
     WHERE expand(ncnt,1,nqueryidx,c.multum_category_id,request->items[ncnt].category_id))
     JOIN (xref
     WHERE outerjoin(c.multum_category_id)=xref.multum_category_id)
     JOIN (c1
     WHERE outerjoin(xref.sub_category_id)=c1.multum_category_id)
     JOIN (xref2
     WHERE outerjoin(c1.multum_category_id)=xref2.multum_category_id)
     JOIN (c2
     WHERE outerjoin(xref2.sub_category_id)=c2.multum_category_id)
    ORDER BY c.multum_category_id, xref.sub_category_id
    HEAD REPORT
     qualcnt = 0
    DETAIL
     qualcnt = (qualcnt+ 1)
     IF (mod(qualcnt,5)=1)
      stat = alterlist(tempcategories->qual,(qualcnt+ 4))
     ENDIF
     tempcategories->qual[qualcnt].parent_cat_id = c.multum_category_id, tempcategories->qual[qualcnt
     ].parent_cat_name = c.category_name, tempcategories->qual[qualcnt].child1_id = xref
     .sub_category_id,
     tempcategories->qual[qualcnt].child1_name = c1.category_name, tempcategories->qual[qualcnt].
     child2_id = xref2.sub_category_id, tempcategories->qual[qualcnt].child2_name = c2.category_name
    FOOT REPORT
     stat = alterlist(tempcategories->qual,qualcnt)
    WITH nocounter
   ;end select
   CALL echorecord(reply)
 END ;Subroutine
END GO
