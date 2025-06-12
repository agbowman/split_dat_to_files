CREATE PROGRAM bed_get_synonym_references:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 caresets[*]
        3 careset_id = f8
        3 display = vc
      2 favorite_folders[*]
        3 favorite_folder_id = f8
        3 display = vc
      2 iv_sets[*]
        3 item_id = f8
        3 display = vc
      2 order_folders[*]
        3 order_folder_id = f8
        3 display = vc
      2 power_plans[*]
        3 power_plan_id = f8
        3 display = vc
      2 products[*]
        3 item_id = f8
        3 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE synonym_table_name = vc WITH protect, constant("ORDER_CATALOG_SYNONYM")
 DECLARE power_plan_group = vc WITH protect, constant("GROUP")
 DECLARE power_plan_phase = vc WITH protect, constant("PHASE")
 DECLARE cs6030orderable = f8 WITH protect, constant(uar_get_code_by("MEANING",6030,"ORDERABLE"))
 DECLARE product_med_type = i2 WITH protect, constant(0)
 DECLARE synonym_count = i4 WITH protect, constant(size(request->synonyms,5))
 DECLARE care_set_count = i4 WITH protect, noconstant(0)
 DECLARE favorite_folder_count = i4 WITH protect, noconstant(0)
 DECLARE order_folder_count = i4 WITH protect, noconstant(0)
 DECLARE power_plan_count = i4 WITH protect, noconstant(0)
 DECLARE iv_set_count = i4 WITH protect, noconstant(0)
 DECLARE product_count = i4 WITH protect, noconstant(0)
 DECLARE item_count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 IF (synonym_count=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->synonyms,synonym_count)
 FOR (index = 1 TO synonym_count)
   SET reply->synonyms[index].synonym_id = request->synonyms[index].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM cs_component cs,
   order_catalog oc
  PLAN (cs
   WHERE expand(index,1,synonym_count,cs.comp_id,reply->synonyms[index].synonym_id)
    AND cs.comp_type_cd=cs6030orderable)
   JOIN (oc
   WHERE oc.catalog_cd=cs.catalog_cd
    AND oc.orderable_type_flag != 8)
  ORDER BY cs.comp_id, oc.primary_mnemonic
  HEAD cs.comp_id
   care_set_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,cs.comp_id,reply->synonyms[num].synonym_id), care_set_count
    = (care_set_count+ 1), stat = alterlist(reply->synonyms[index2].caresets,care_set_count),
   reply->synonyms[index2].caresets[care_set_count].careset_id = oc.catalog_cd, reply->synonyms[
   index2].caresets[care_set_count].display = oc.primary_mnemonic
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 001: Issue loading Care Sets.")
 SELECT INTO "nl:"
  FROM alt_sel_list asl,
   alt_sel_cat ascat,
   prsnl p
  PLAN (asl
   WHERE expand(index,1,synonym_count,asl.synonym_id,reply->synonyms[index].synonym_id))
   JOIN (ascat
   WHERE ascat.alt_sel_category_id=asl.alt_sel_category_id
    AND ascat.owner_id > 0.0
    AND ascat.ahfs_ind IN (0, null))
   JOIN (p
   WHERE p.person_id=ascat.owner_id)
  ORDER BY asl.synonym_id, ascat.long_description
  HEAD asl.synonym_id
   favorite_folder_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,asl.synonym_id,reply->synonyms[num].synonym_id),
   favorite_folder_count = (favorite_folder_count+ 1), stat = alterlist(reply->synonyms[index2].
    favorite_folders,favorite_folder_count),
   reply->synonyms[index2].favorite_folders[favorite_folder_count].favorite_folder_id = ascat
   .alt_sel_category_id, reply->synonyms[index2].favorite_folders[favorite_folder_count].display =
   build2(trim(ascat.long_description),":"," ",trim(p.name_full_formatted))
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 002: Issue loading Favorite Folders.")
 SELECT INTO "nl:"
  FROM alt_sel_list asl,
   alt_sel_cat ascat
  PLAN (asl
   WHERE expand(index,1,synonym_count,asl.synonym_id,reply->synonyms[index].synonym_id))
   JOIN (ascat
   WHERE ascat.alt_sel_category_id=asl.alt_sel_category_id
    AND ascat.owner_id=0.0
    AND ascat.ahfs_ind IN (0, null))
  ORDER BY asl.synonym_id, ascat.long_description
  HEAD asl.synonym_id
   order_folder_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,asl.synonym_id,reply->synonyms[num].synonym_id),
   order_folder_count = (order_folder_count+ 1), stat = alterlist(reply->synonyms[index2].
    order_folders,order_folder_count),
   reply->synonyms[index2].order_folders[order_folder_count].order_folder_id = ascat
   .alt_sel_category_id, reply->synonyms[index2].order_folders[order_folder_count].display = ascat
   .long_description
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 003: Issue loading Order Folders.")
 SELECT INTO "nl:"
  FROM pathway_comp pco,
   pathway_catalog pca,
   pw_cat_reltn pw_reltn,
   pathway_catalog pw_cat_pp
  PLAN (pco
   WHERE pco.active_ind=1
    AND pco.parent_entity_name=synonym_table_name
    AND expand(index,1,synonym_count,pco.parent_entity_id,reply->synonyms[index].synonym_id))
   JOIN (pca
   WHERE pca.pathway_catalog_id=pco.pathway_catalog_id
    AND pca.active_ind=1)
   JOIN (pw_reltn
   WHERE pw_reltn.pw_cat_t_id=outerjoin(pca.pathway_catalog_id)
    AND pw_reltn.type_mean=outerjoin(power_plan_group))
   JOIN (pw_cat_pp
   WHERE pw_cat_pp.pathway_catalog_id=outerjoin(pw_reltn.pw_cat_s_id)
    AND pw_cat_pp.active_ind=outerjoin(1))
  ORDER BY pco.parent_entity_id, pca.description, pw_cat_pp.description
  HEAD pco.parent_entity_id
   power_plan_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,pco.parent_entity_id,reply->synonyms[num].synonym_id)
   IF (pca.type_mean=power_plan_phase
    AND pw_cat_pp.pathway_catalog_id > 0.0)
    IF (locateval(item_count,1,power_plan_count,pw_cat_pp.pathway_catalog_id,reply->synonyms[index2].
     power_plans[item_count].power_plan_id)=0)
     power_plan_count = (power_plan_count+ 1), stat = alterlist(reply->synonyms[index2].power_plans,
      power_plan_count), reply->synonyms[index2].power_plans[power_plan_count].power_plan_id = pca
     .pathway_catalog_id,
     reply->synonyms[index2].power_plans[power_plan_count].display = pw_cat_pp.description
    ENDIF
   ELSEIF (pca.type_mean != power_plan_phase)
    IF (locateval(item_count,1,power_plan_count,pca.pathway_catalog_id,reply->synonyms[index2].
     power_plans[item_count].power_plan_id)=0)
     power_plan_count = (power_plan_count+ 1), stat = alterlist(reply->synonyms[index2].power_plans,
      power_plan_count), reply->synonyms[index2].power_plans[power_plan_count].power_plan_id = pca
     .pathway_catalog_id,
     reply->synonyms[index2].power_plans[power_plan_count].display = pca.description
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 004: Issue loading Power Plans.")
 SELECT INTO "nl:"
  FROM cs_component cs,
   order_catalog oc
  PLAN (cs
   WHERE expand(index,1,synonym_count,cs.comp_id,reply->synonyms[index].synonym_id)
    AND cs.comp_type_cd=cs6030orderable)
   JOIN (oc
   WHERE oc.catalog_cd=cs.catalog_cd
    AND oc.orderable_type_flag=8)
  ORDER BY cs.comp_id, oc.primary_mnemonic
  HEAD cs.comp_id
   iv_set_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,cs.comp_id,reply->synonyms[num].synonym_id), iv_set_count
    = (iv_set_count+ 1), stat = alterlist(reply->synonyms[index2].iv_sets,iv_set_count),
   reply->synonyms[index2].iv_sets[iv_set_count].item_id = oc.catalog_cd, reply->synonyms[index2].
   iv_sets[iv_set_count].display = oc.primary_mnemonic
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 005: Issue loading IV Sets.")
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   med_identifier mi
  PLAN (ocir
   WHERE expand(index,1,synonym_count,ocir.synonym_id,reply->synonyms[index].synonym_id))
   JOIN (mi
   WHERE mi.item_id=ocir.item_id
    AND mi.med_type_flag=product_med_type)
  ORDER BY ocir.synonym_id, mi.value
  HEAD ocir.synonym_id
   product_count = 0
  DETAIL
   index2 = locateval(num,1,synonym_count,ocir.synonym_id,reply->synonyms[num].synonym_id),
   product_count = (product_count+ 1), stat = alterlist(reply->synonyms[index2].products,
    product_count),
   reply->synonyms[index2].products[product_count].item_id = mi.item_id, reply->synonyms[index2].
   products[product_count].display = mi.value
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 007: Issue loading Products.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
