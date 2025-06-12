CREATE PROGRAM bed_ens_power_plans:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 plans[*]
      2 plan_id = f8
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD tempaddplan(
   1 power_plan[*]
     2 id = f8
     2 display = vc
     2 description = vc
     2 description_key = vc
     2 type_mean = vc
     2 subphase_ind = i2
     2 plan_type_id = f8
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 cross_counter_ind = i2
     2 allow_diagnosis_propogation_ind = i2
     2 hide_flexed_comp_ind = i2
     2 prompt_ordering_physician_ind = i2
     2 copy_forward_ind = i2
     2 uuid = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD modplanactivestatus(
   1 power_plan[*]
     2 id = f8
     2 active_ind = i2
 ) WITH protect
 RECORD tempmodplan(
   1 power_plan[*]
     2 id = f8
     2 display = vc
     2 description = vc
     2 description_key = vc
     2 subphase_ind = i2
     2 plan_type_id = f8
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 evidence_reltn_id = f8
     2 cross_counter_ind = i2
     2 allow_diagnosis_propogation_ind = i2
     2 hide_flexed_comp_ind = i2
     2 prompt_ordering_physician_ind = i2
     2 copy_forward_ind = i2
 ) WITH protect
 RECORD tempaddplansynonym(
   1 synonyms[*]
     2 power_plan_id = f8
     2 synonym_name = vc
     2 synonym_name_key = vc
     2 primary_ind = i2
 ) WITH protect
 RECORD tempmodplansynonym(
   1 synonyms[*]
     2 id = f8
     2 synonym_name = vc
     2 synonym_name_key = vc
     2 primary_ind = i2
 ) WITH protect
 RECORD tempdelplansynonym(
   1 synonyms[*]
     2 id = f8
 ) WITH protect
 RECORD tempupdplanfacility(
   1 facility[*]
     2 plan_id = f8
     2 plan_display_description_key = vc
     2 facility_id = f8
 ) WITH protect
 RECORD tempdelphase(
   1 phase[*]
     2 id = f8
 ) WITH protect
 RECORD tempaddphase(
   1 phase[*]
     2 power_plan_id = f8
     2 id = f8
     2 phase_description = vc
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 phase_evidence_type_mean = vc
     2 phase_evidence_locator = vc
     2 uuid = vc
 ) WITH protect
 RECORD tempmodphase(
   1 phase[*]
     2 id = f8
     2 phase_description = vc
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 phase_evidence_type_mean = vc
     2 phase_evidence_locator = vc
     2 phase_evidence_reltn_id = f8
 ) WITH protect
 RECORD tempphasesequence(
   1 phase[*]
     2 id = f8
     2 next_phase_id = f8
 ) WITH protect
 RECORD tempaddcomp(
   1 comp[*]
     2 phaseid = f8
     2 id = f8
     2 comp_type = vc
     2 sequence = i4
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 dcp_clin_cat_code_value = f8
     2 dcp_clin_sub_cat_code_value = f8
     2 include_ind = i2
     2 required_ind = i2
     2 default_os_ind = i2
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 persistent_ind = i2
     2 offset
       3 offset_quantity = f8
       3 offset_unit_cd = f8
     2 uuid = vc
 ) WITH protect
 RECORD tempupdcomp(
   1 comp[*]
     2 phaseid = f8
     2 id = f8
     2 comp_type = vc
     2 sequence = i4
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 dcp_clin_cat_code_value = f8
     2 dcp_clin_sub_cat_code_value = f8
     2 include_ind = i2
     2 required_ind = i2
     2 default_os_ind = i2
     2 evidence_reltn_id = f8
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 persistent_ind = i2
     2 offset
       3 offset_quantity = f8
       3 offset_unit_cd = f8
 ) WITH protect
 RECORD tempdelcomp(
   1 comp[*]
     2 id = f8
     2 evidence_reltn_id = f8
 ) WITH protect
 RECORD tempaddsubphase(
   1 subphase[*]
     2 phaseid = f8
     2 id = f8
 ) WITH protect
 RECORD tempdelsubphase(
   1 subphase[*]
     2 phaseid = f8
     2 id = f8
 ) WITH protect
 RECORD tempaddnote(
   1 note[*]
     2 noteid = f8
     2 compid = f8
     2 notetext = vc
 ) WITH protect
 RECORD tempupdnote(
   1 note[*]
     2 noteid = f8
     2 compid = f8
     2 notetext = vc
 ) WITH protect
 RECORD tempaddsynos(
   1 ordersentence[*]
     2 powerplanid = f8
     2 phaseid = f8
     2 componentid = f8
     2 id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 usage_flag = i2
     2 comment = vc
     2 commentid = f8
     2 rx_type_mean = vc
 ) WITH protect
 RECORD tempaddingos(
   1 ordersentence[*]
     2 powerplanid = f8
     2 phaseid = f8
     2 componentid = f8
     2 synonymid = f8
     2 id = f8
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 comment = vc
     2 commentid = f8
 ) WITH protect
 RECORD tempupdosfilter(
   1 filters[*]
     2 order_sentence_filter_id = f8
     2 age_min_value = f8
     2 age_max_value = f8
     2 age_code_value = f8
     2 pma_min_value = f8
     2 pma_max_value = f8
     2 pma_code_value = f8
     2 weight_min_value = f8
     2 weight_max_value = f8
     2 weight_code_value = f8
 ) WITH protect
 RECORD tempaddosfilter(
   1 filters[*]
     2 sentence_id = f8
     2 order_sentence_filter_id = f8
     2 age_min_value = f8
     2 age_max_value = f8
     2 age_code_value = f8
     2 pma_min_value = f8
     2 pma_max_value = f8
     2 pma_code_value = f8
     2 weight_min_value = f8
     2 weight_max_value = f8
     2 weight_code_value = f8
 ) WITH protect
 RECORD tempdelosfilter(
   1 filters[*]
     2 order_sentence_filter_id = f8
 ) WITH protect
 RECORD tempupdos(
   1 ordersentence[*]
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 comment = vc
     2 commentid = f8
     2 sequence = i4
     2 rx_type_mean = vc
 ) WITH protect
 RECORD tempdelos(
   1 ordersentence[*]
     2 id = f8
     2 componentid = f8
 ) WITH protect
 RECORD tempaddosdet(
   1 fielddetail[*]
     2 powerplanid = f8
     2 phaseid = f8
     2 componentid = f8
     2 sentenceid = f8
     2 oef_id = f8
     2 value = f8
     2 display = vc
     2 field_type_flag = i4
     2 oe_field_meaning_id = f8
     2 sequence = i4
 ) WITH protect
 RECORD tempdelosdetail(
   1 fielddetail[*]
     2 oef_id = f8
     2 sentenceid = f8
     2 oe_field_meaning_id = f8
 ) WITH protect
 RECORD tempplantestingversioninds(
   1 power_plan[*]
     2 testing_version_ind = i2
 ) WITH protect
 SET reply->status_data.status = "F"
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 DECLARE error_flag = vc WITH protect
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 DECLARE populatephase(i=i4) = null
 DECLARE getnextphaseid(i=i4,j=i4,phasecnt=i4) = f8
 DECLARE populatecomp(i=i4,j=i4) = null
 DECLARE populatesynos(i=i4,j=i4,k=i4) = null
 DECLARE populatesynosdet(i=i4,j=i4,k=i4,l=i4) = null
 DECLARE populatesynosfilters(i=i4,j=i4,k=i4,l=i4) = null
 DECLARE populateingos(i=i4,j=i4,k=i4) = null
 DECLARE populateingosdet(i=i4,j=i4,k=i4,l=i4) = null
 DECLARE deleteingosandrlns(i=i4,j=i4,k=i4) = null
 DECLARE deleteingosdet(i=i4,j=i4,k=i4,l=i4) = null
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE note_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"NOTE")), protect
 DECLARE subphase_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE clin_cat_disp_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 DECLARE intermittent_oe_field_meaning_id = f8 WITH constant(2070.0), protect
 DECLARE intermittent_oe_field_id = f8 WITH protect
 DECLARE syncnt = i4 WITH protect
 DECLARE faccnt = i4 WITH protect
 DECLARE phasecnt = i4 WITH protect
 DECLARE existingosid = f8 WITH protect, noconstant(0)
 DECLARE plancnt = i4 WITH protect, noconstant(0)
 DECLARE activate_option_ind = i4 WITH protect
 DECLARE temp = i4 WITH protect
 DECLARE compcnt = i4 WITH protect
 DECLARE nextphaseid = f8 WITH protect
 DECLARE oscnt = i4 WITH protect
 DECLARE ingcnt = i4 WITH protect
 DECLARE osdetcnt = i4 WITH protect
 DECLARE highseq = i4 WITH protect
 DECLARE ingdetcnt = i4 WITH protect
 DECLARE planid = f8 WITH protect
 DECLARE phaseid = f8 WITH protect
 DECLARE compid = f8 WITH protect
 DECLARE synosid = f8 WITH protect
 DECLARE ingosid = f8 WITH protect
 DECLARE noteid = f8 WITH protect
 DECLARE osfilterid = f8 WITH protect, noconstant(0.0)
 DECLARE addplancnt = i4 WITH protect
 DECLARE modplancnt = i4 WITH protect
 DECLARE addplansynonymcnt = i4 WITH protect
 DECLARE modplansynonymcnt = i4 WITH protect
 DECLARE delplansynonymcnt = i4 WITH protect
 DECLARE updplanfacilitycnt = i4 WITH protect
 DECLARE delphasecnt = i4 WITH protect
 DECLARE addphasecnt = i4 WITH protect
 DECLARE modphasecnt = i4 WITH protect
 DECLARE phasesequencecnt = i4 WITH protect
 DECLARE addcompcnt = i4 WITH protect
 DECLARE updcompcnt = i4 WITH protect
 DECLARE delcompcnt = i4 WITH protect
 DECLARE addsubphasecnt = i4 WITH protect
 DECLARE delsubphasecnt = i4 WITH protect
 DECLARE addnotecnt = i4 WITH protect
 DECLARE updnotecnt = i4 WITH protect
 DECLARE addsynoscnt = i4 WITH protect
 DECLARE addingoscnt = i4 WITH protect
 DECLARE updoscnt = i4 WITH protect
 DECLARE deloscnt = i4 WITH protect
 DECLARE addosdetcnt = i4 WITH protect
 DECLARE planactstatcnt = i4 WITH protect
 DECLARE osfiltercnt = i4 WITH protect, noconstant(0)
 DECLARE addosfiltercnt = i4 WITH protect, noconstant(0)
 DECLARE updosfiltercnt = i4 WITH protect, noconstant(0)
 DECLARE delosfiltercnt = i4 WITH protect, noconstant(0)
 SET addplancnt = 0
 SET modplancnt = 0
 SET addplansynonymcnt = 0
 SET modplansynonymcnt = 0
 SET delplansynonymcnt = 0
 SET updplanfacilitycnt = 0
 SET delphasecnt = 0
 SET addphasecnt = 0
 SET modphasecnt = 0
 SET phasesequencecnt = 0
 SET addcompcnt = 0
 SET updcompcnt = 0
 SET delcompcnt = 0
 SET addsubphasecnt = 0
 SET delsubphasecnt = 0
 SET addnotecnt = 0
 SET updnotecnt = 0
 SET addsynoscnt = 0
 SET addingoscnt = 0
 SET updoscnt = 0
 SET deloscnt = 0
 SET addosdetcnt = 0
 SET planactstatcnt = 0
 SET intermittent_oe_field_id = 0.0
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.oe_field_meaning_id=intermittent_oe_field_meaning_id
  DETAIL
   intermittent_oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 IF (intermittent_oe_field_id=0.0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Intermittent oe_field_id not found")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET plancnt = size(request->plans,5)
 SET stat = alterlist(reply->plans,plancnt)
 IF (plancnt > 0)
  SET stat = alterlist(tempplantestingversioninds->power_plan,plancnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = plancnt),
    pathway_catalog pc
   PLAN (d)
    JOIN (pc
    WHERE pc.pathway_catalog_id > 0
     AND (pc.pathway_catalog_id=request->plans[d.seq].power_plan_id)
     AND pc.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    tempplantestingversioninds->power_plan[d.seq].testing_version_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO plancnt)
   SET planid = request->plans[i].power_plan_id
   DECLARE desckey = vc
   SET desckey = trim(cnvtupper(substring(1,100,request->plans[i].description)))
   SET activate_option_ind = 0
   IF (validate(request->plans[i].activate_plan_ind))
    SET activate_option_ind = request->plans[i].activate_plan_ind
   ENDIF
   IF ((request->plans[i].action_flag=3))
    SET planactstatcnt = (planactstatcnt+ 1)
    SET stat = alterlist(modplanactivestatus->power_plan,planactstatcnt)
    SET modplanactivestatus->power_plan[planactstatcnt].id = planid
    SET modplanactivestatus->power_plan[planactstatcnt].active_ind = 0
   ELSEIF ((request->plans[i].action_flag=1)
    AND planid > 0)
    SET planactstatcnt = (planactstatcnt+ 1)
    SET stat = alterlist(modplanactivestatus->power_plan,planactstatcnt)
    SET modplanactivestatus->power_plan[planactstatcnt].id = planid
    SET modplanactivestatus->power_plan[planactstatcnt].active_ind = 1
   ELSE
    IF ((request->plans[i].action_flag=1))
     SET addplancnt = (addplancnt+ 1)
     SET stat = alterlist(tempaddplan->power_plan,addplancnt)
     SELECT INTO "nl:"
      tempid = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       planid = cnvtreal(tempid)
      WITH nocounter
     ;end select
     SET tempaddplan->power_plan[addplancnt].allow_diagnosis_propogation_ind = request->plans[i].
     allow_diagnosis_propogation_ind
     SET tempaddplan->power_plan[addplancnt].copy_forward_ind = request->plans[i].copy_forward_ind
     SET tempaddplan->power_plan[addplancnt].cross_counter_ind = request->plans[i].cross_counter_ind
     SET tempaddplan->power_plan[addplancnt].description = request->plans[i].description
     SET tempaddplan->power_plan[addplancnt].description_key = desckey
     SET tempaddplan->power_plan[addplancnt].display = request->plans[i].display
     SET tempaddplan->power_plan[addplancnt].evidence_locator = request->plans[i].evidence_locator
     SET tempaddplan->power_plan[addplancnt].evidence_type_mean = request->plans[i].
     evidence_type_mean
     SET tempaddplan->power_plan[addplancnt].hide_flexed_comp_ind = request->plans[i].
     hide_flexed_comp_ind
     SET tempaddplan->power_plan[addplancnt].id = planid
     DECLARE typemean = vc
     IF ((request->plans[i].multi_phase_ind=1))
      SET typemean = "PATHWAY"
     ELSE
      SET typemean = "CAREPLAN"
     ENDIF
     SET tempaddplan->power_plan[addplancnt].type_mean = typemean
     SET tempaddplan->power_plan[addplancnt].plan_type_id = request->plans[i].plan_type_id
     SET tempaddplan->power_plan[addplancnt].prompt_ordering_physician_ind = request->plans[i].
     prompt_ordering_physician_ind
     SET tempaddplan->power_plan[addplancnt].subphase_ind = request->plans[i].subphase_ind
     SET tempaddplan->power_plan[addplancnt].uuid = request->plans[i].uuid
     SET addplansynonymcnt = (addplansynonymcnt+ 1)
     SET stat = alterlist(tempaddplansynonym->synonyms,addplansynonymcnt)
     SET tempaddplansynonym->synonyms[addplansynonymcnt].power_plan_id = planid
     SET tempaddplansynonym->synonyms[addplansynonymcnt].primary_ind = 1
     SET tempaddplansynonym->synonyms[addplansynonymcnt].synonym_name = request->plans[i].display
     SET tempaddplansynonym->synonyms[addplansynonymcnt].synonym_name_key = trim(cnvtupper(substring(
        1,40,request->plans[i].display)))
     SET tempaddplan->power_plan[addplancnt].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
     SET tempaddplan->power_plan[addplancnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     IF (validate(request->plans[i].create_testing_version_ind))
      IF ((request->plans[i].create_testing_version_ind=1))
       SET tempaddplan->power_plan[addplancnt].beg_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      ENDIF
     ENDIF
    ELSEIF ((request->plans[i].action_flag=2))
     SET modplancnt = (modplancnt+ 1)
     SET stat = alterlist(tempmodplan->power_plan,modplancnt)
     SET tempmodplan->power_plan[modplancnt].allow_diagnosis_propogation_ind = request->plans[i].
     allow_diagnosis_propogation_ind
     SET tempmodplan->power_plan[modplancnt].copy_forward_ind = request->plans[i].copy_forward_ind
     SET tempmodplan->power_plan[modplancnt].cross_counter_ind = request->plans[i].cross_counter_ind
     SET tempmodplan->power_plan[modplancnt].description = request->plans[i].description
     SET tempmodplan->power_plan[modplancnt].description_key = desckey
     SET tempmodplan->power_plan[modplancnt].display = request->plans[i].display
     SET tempmodplan->power_plan[modplancnt].evidence_locator = request->plans[i].evidence_locator
     SET tempmodplan->power_plan[modplancnt].evidence_type_mean = request->plans[i].
     evidence_type_mean
     SET tempmodplan->power_plan[modplancnt].hide_flexed_comp_ind = request->plans[i].
     hide_flexed_comp_ind
     SET tempmodplan->power_plan[modplancnt].id = request->plans[i].power_plan_id
     SET tempmodplan->power_plan[modplancnt].plan_type_id = request->plans[i].plan_type_id
     SET tempmodplan->power_plan[modplancnt].prompt_ordering_physician_ind = request->plans[i].
     prompt_ordering_physician_ind
     SET tempmodplan->power_plan[modplancnt].subphase_ind = request->plans[i].subphase_ind
     SELECT INTO "nl:"
      FROM pw_evidence_reltn per
      PLAN (per
       WHERE per.pathway_catalog_id=planid
        AND per.pathway_comp_id=0.0
        AND per.dcp_clin_cat_cd=0.0
        AND per.dcp_clin_sub_cat_cd=0.0
        AND per.type_mean IN ("URL", "ZYNX")
        AND (tempmodplan->power_plan[modplancnt].evidence_type_mean > " ")
        AND (tempmodplan->power_plan[modplancnt].evidence_locator > " "))
      DETAIL
       tempmodplan->power_plan[modplancnt].evidence_reltn_id = per.pw_evidence_reltn_id
      WITH nocounter
     ;end select
     DECLARE modsynonymid = f8
     SET modsynonymid = 0.0
     SELECT INTO "nl:"
      FROM pathway_catalog pc,
       pw_cat_synonym pcs
      PLAN (pc
       WHERE pc.pathway_catalog_id=planid)
       JOIN (pcs
       WHERE pcs.pathway_catalog_id=pc.pathway_catalog_id
        AND pcs.primary_ind=1)
      DETAIL
       IF ((request->plans[i].display != pc.display_description))
        modsynonymid = pcs.pw_cat_synonym_id
       ENDIF
      WITH nocounter
     ;end select
     IF (modsynonymid > 0.0)
      SET modplansynonymcnt = (modplansynonymcnt+ 1)
      SET stat = alterlist(tempmodplansynonym->synonyms,modplansynonymcnt)
      SET tempmodplansynonym->synonyms[modplansynonymcnt].id = modsynonymid
      SET tempmodplansynonym->synonyms[modplansynonymcnt].synonym_name = request->plans[i].display
      SET tempmodplansynonym->synonyms[modplansynonymcnt].synonym_name_key = trim(cnvtupper(substring
        (1,40,request->plans[i].display)))
     ENDIF
    ENDIF
    SET syncnt = size(request->plans[i].synonyms,5)
    IF (syncnt > 0)
     FOR (j = 1 TO syncnt)
       DECLARE syndispkey = vc
       SET syndispkey = trim(cnvtupper(substring(1,40,request->plans[i].synonyms[j].display)))
       IF ((request->plans[i].synonyms[j].action_flag=1))
        SET addplansynonymcnt = (addplansynonymcnt+ 1)
        SET stat = alterlist(tempaddplansynonym->synonyms,addplansynonymcnt)
        SET tempaddplansynonym->synonyms[addplansynonymcnt].power_plan_id = planid
        SET tempaddplansynonym->synonyms[addplansynonymcnt].synonym_name = request->plans[i].
        synonyms[j].display
        SET tempaddplansynonym->synonyms[addplansynonymcnt].synonym_name_key = syndispkey
       ELSEIF ((request->plans[i].synonyms[j].action_flag=2))
        SET modplansynonymcnt = (modplansynonymcnt+ 1)
        SET stat = alterlist(tempmodplansynonym->synonyms,modplansynonymcnt)
        SET tempmodplansynonym->synonyms[modplansynonymcnt].id = request->plans[i].synonyms[j].id
        SET tempmodplansynonym->synonyms[modplansynonymcnt].synonym_name = request->plans[i].
        synonyms[j].display
        SET tempmodplansynonym->synonyms[modplansynonymcnt].synonym_name_key = syndispkey
       ELSEIF ((request->plans[i].synonyms[j].action_flag=3))
        SET delplansynonymcnt = (delplansynonymcnt+ 1)
        SET stat = alterlist(tempdelplansynonym->synonyms,delplansynonymcnt)
        SET tempdelplansynonym->synonyms[delplansynonymcnt].id = request->plans[i].synonyms[j].id
       ENDIF
     ENDFOR
    ENDIF
    DECLARE plandescriptionkey = vc
    IF ((tempplantestingversioninds->power_plan[i].testing_version_ind=1))
     SET plandescriptionkey = build("PATHWAY_CATALOG_ID=",planid)
    ELSE
     SET plandescriptionkey = desckey
    ENDIF
    IF ((request->plans[i].all_facilities_ind=1))
     SET updplanfacilitycnt = (updplanfacilitycnt+ 1)
     SET stat = alterlist(tempupdplanfacility->facility,updplanfacilitycnt)
     SET tempupdplanfacility->facility[updplanfacilitycnt].facility_id = 0
     SET tempupdplanfacility->facility[updplanfacilitycnt].plan_display_description_key =
     plandescriptionkey
     SET tempupdplanfacility->facility[updplanfacilitycnt].plan_id = planid
    ELSE
     SET faccnt = size(request->plans[i].available_facilities,5)
     IF (faccnt > 0)
      FOR (j = 1 TO faccnt)
        SET updplanfacilitycnt = (updplanfacilitycnt+ 1)
        SET stat = alterlist(tempupdplanfacility->facility,(updplanfacilitycnt+ 1))
        SET tempupdplanfacility->facility[updplanfacilitycnt].facility_id = request->plans[i].
        available_facilities[j].id
        SET tempupdplanfacility->facility[updplanfacilitycnt].plan_display_description_key =
        plandescriptionkey
        SET tempupdplanfacility->facility[updplanfacilitycnt].plan_id = planid
      ENDFOR
     ENDIF
    ENDIF
    CALL populatephase(i)
   ENDIF
   SET reply->plans[i].plan_id = planid
   SET reply->plans[i].description = request->plans[i].description
 ENDFOR
 SET stat = alterlist(tempaddplan->power_plan,addplancnt)
 SET stat = alterlist(tempmodplan->power_plan,modplancnt)
 SET stat = alterlist(tempaddplansynonym->synonyms,addplansynonymcnt)
 SET stat = alterlist(tempmodplansynonym->synonyms,modplansynonymcnt)
 SET stat = alterlist(tempdelplansynonym->synonyms,delplansynonymcnt)
 SET stat = alterlist(tempupdplanfacility->facility,updplanfacilitycnt)
 SET stat = alterlist(tempdelphase->phase,delphasecnt)
 SET stat = alterlist(tempaddphase->phase,addphasecnt)
 SET stat = alterlist(tempmodphase->phase,modphasecnt)
 SET stat = alterlist(tempphasesequence->phase,phasesequencecnt)
 SET stat = alterlist(tempaddcomp->comp,addcompcnt)
 SET stat = alterlist(tempupdcomp->comp,updcompcnt)
 SET stat = alterlist(tempdelcomp->comp,delcompcnt)
 SET stat = alterlist(tempaddsubphase->subphase,addsubphasecnt)
 SET stat = alterlist(tempdelsubphase->subphase,delsubphasecnt)
 SET stat = alterlist(tempaddnote->note,addnotecnt)
 SET stat = alterlist(tempupdnote->note,updnotecnt)
 SET stat = alterlist(tempaddsynos->ordersentence,addsynoscnt)
 SET stat = alterlist(tempaddingos->ordersentence,addingoscnt)
 SET stat = alterlist(tempupdos->ordersentence,updoscnt)
 SET stat = alterlist(tempdelos->ordersentence,deloscnt)
 SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
 SUBROUTINE populatephase(i)
  SET phasecnt = size(request->plans[i].phase,5)
  IF (phasecnt > 0)
   SET temp = size(tempdelphase->phase,5)
   SET stat = alterlist(tempdelphase->phase,(phasecnt+ temp))
   SET temp = size(tempaddphase->phase,5)
   SET stat = alterlist(tempaddphase->phase,(phasecnt+ temp))
   SET temp = size(tempmodphase->phase,5)
   SET stat = alterlist(tempmodphase->phase,(phasecnt+ temp))
   SET temp = size(tempphasesequence->phase,5)
   SET stat = alterlist(tempphasesequence->phase,(phasecnt+ temp))
   FOR (j = 1 TO phasecnt)
     SET phaseid = request->plans[i].phase[j].phase_id
     IF ((request->plans[i].phase[j].action_flag=1))
      SET addphasecnt = (addphasecnt+ 1)
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        phaseid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddphase->phase[addphasecnt].id = phaseid
      SET tempaddphase->phase[addphasecnt].power_plan_id = planid
      SET tempaddphase->phase[addphasecnt].phase_description = request->plans[i].phase[j].
      phase_description
      SET tempaddphase->phase[addphasecnt].alerts_on_plan_ind = request->plans[i].phase[j].
      alerts_on_plan_ind
      SET tempaddphase->phase[addphasecnt].alerts_on_plan_upd_ind = request->plans[i].phase[j].
      alerts_on_plan_upd_ind
      SET tempaddphase->phase[addphasecnt].phase_evidence_type_mean = request->plans[i].phase[j].
      phase_evidence_type_mean
      SET tempaddphase->phase[addphasecnt].phase_evidence_locator = request->plans[i].phase[j].
      phase_evidence_locator
      SET tempaddphase->phase[addphasecnt].uuid = request->plans[i].phase[j].uuid
      SET request->plans[i].phase[j].phase_id = phaseid
     ELSEIF ((request->plans[i].phase[j].action_flag=2))
      SET modphasecnt = (modphasecnt+ 1)
      SET tempmodphase->phase[modphasecnt].alerts_on_plan_ind = request->plans[i].phase[j].
      alerts_on_plan_ind
      SET tempmodphase->phase[modphasecnt].alerts_on_plan_upd_ind = request->plans[i].phase[j].
      alerts_on_plan_upd_ind
      SET tempmodphase->phase[modphasecnt].id = request->plans[i].phase[j].phase_id
      SET tempmodphase->phase[modphasecnt].phase_description = request->plans[i].phase[j].
      phase_description
      SET tempmodphase->phase[modphasecnt].phase_evidence_locator = request->plans[i].phase[j].
      phase_evidence_locator
      SET tempmodphase->phase[modphasecnt].phase_evidence_type_mean = request->plans[i].phase[j].
      phase_evidence_type_mean
      CALL echo(build(request->plans[i].phase[j].phase_id))
      SELECT INTO "nl:"
       FROM pw_evidence_reltn per
       PLAN (per
        WHERE per.pathway_catalog_id=phaseid
         AND per.pathway_comp_id=0.0
         AND per.dcp_clin_cat_cd=0.0
         AND per.dcp_clin_sub_cat_cd=0.0
         AND per.type_mean IN ("URL", "ZYNX")
         AND (tempmodphase->phase[modphasecnt].phase_evidence_type_mean > " ")
         AND (tempmodphase->phase[modphasecnt].phase_evidence_locator > " "))
       DETAIL
        tempmodphase->phase[modphasecnt].phase_evidence_reltn_id = per.pw_evidence_reltn_id
       WITH nocounter
      ;end select
     ELSEIF ((request->plans[i].phase[j].action_flag=3))
      SET delphasecnt = (delphasecnt+ 1)
      SET tempdelphase->phase[delphasecnt].id = phaseid
     ENDIF
     IF (phaseid=0)
      SET phaseid = planid
     ENDIF
     CALL populatecomp(i,j)
   ENDFOR
   FOR (j = 1 TO phasecnt)
     IF ((request->plans[i].phase[j].action_flag < 3))
      SET nextphaseid = getnextphaseid(i,j,phasecnt)
      IF (nextphaseid > 0.0)
       SET phasesequencecnt = (phasesequencecnt+ 1)
       SET tempphasesequence->phase[phasesequencecnt].id = request->plans[i].phase[j].phase_id
       SET tempphasesequence->phase[phasesequencecnt].next_phase_id = nextphaseid
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(tempdelphase->phase,delphasecnt)
   SET stat = alterlist(tempaddphase->phase,addphasecnt)
   SET stat = alterlist(tempmodphase->phase,modphasecnt)
   SET stat = alterlist(tempphasesequence->phase,phasesequencecnt)
  ENDIF
 END ;Subroutine
 SUBROUTINE getnextphaseid(i,j,phasecnt)
  FOR (k = (j+ 1) TO phasecnt)
    IF ((request->plans[i].phase[k].action_flag < 3))
     RETURN(request->plans[i].phase[k].phase_id)
    ENDIF
  ENDFOR
  RETURN(0.0)
 END ;Subroutine
 SUBROUTINE populatecomp(i,j)
  SET compcnt = size(request->plans[i].phase[j].component,5)
  IF (compcnt > 0)
   SET temp = size(tempaddcomp->comp,5)
   SET stat = alterlist(tempaddcomp->comp,(compcnt+ temp))
   SET temp = size(tempupdcomp->comp,5)
   SET stat = alterlist(tempupdcomp->comp,(compcnt+ temp))
   SET temp = size(tempaddsubphase->subphase,5)
   SET stat = alterlist(tempaddsubphase->subphase,(compcnt+ temp))
   SET temp = size(tempdelsubphase->subphase,5)
   SET stat = alterlist(tempdelsubphase->subphase,(compcnt+ temp))
   SET temp = size(tempaddnote->note,5)
   SET stat = alterlist(tempaddnote->note,(compcnt+ temp))
   SET temp = size(tempupdnote->note,5)
   SET stat = alterlist(tempupdnote->note,(compcnt+ temp))
   SET temp = size(tempdelcomp->comp,5)
   SET stat = alterlist(tempdelcomp->comp,(compcnt+ temp))
   FOR (k = 1 TO compcnt)
     SET compid = request->plans[i].phase[j].component[k].comp_id
     IF ((request->plans[i].phase[j].component[k].action_flag=1))
      SET addcompcnt = (addcompcnt+ 1)
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        compid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddcomp->comp[addcompcnt].id = compid
      SET tempaddcomp->comp[addcompcnt].comp_type = request->plans[i].phase[j].component[k].comp_type
      SET tempaddcomp->comp[addcompcnt].dcp_clin_cat_code_value = request->plans[i].phase[j].
      component[k].dcp_clin_cat_code_value
      SET tempaddcomp->comp[addcompcnt].dcp_clin_sub_cat_code_value = request->plans[i].phase[j].
      component[k].dcp_clin_sub_cat_code_value
      SET tempaddcomp->comp[addcompcnt].default_os_ind = request->plans[i].phase[j].component[k].
      default_os_ind
      SET tempaddcomp->comp[addcompcnt].evidence_locator = request->plans[i].phase[j].component[k].
      evidence_locator
      SET tempaddcomp->comp[addcompcnt].evidence_type_mean = request->plans[i].phase[j].component[k].
      evidence_type_mean
      SET tempaddcomp->comp[addcompcnt].include_ind = request->plans[i].phase[j].component[k].
      include_ind
      SET tempaddcomp->comp[addcompcnt].parent_entity_id = request->plans[i].phase[j].component[k].
      parent_entity_id
      SET tempaddcomp->comp[addcompcnt].parent_entity_name = request->plans[i].phase[j].component[k].
      parent_entity_name
      SET tempaddcomp->comp[addcompcnt].phaseid = phaseid
      SET tempaddcomp->comp[addcompcnt].required_ind = request->plans[i].phase[j].component[k].
      required_ind
      SET tempaddcomp->comp[addcompcnt].sequence = request->plans[i].phase[j].component[k].sequence
      SET tempaddcomp->comp[addcompcnt].persistent_ind = request->plans[i].phase[j].component[k].
      persistent_ind
      SET tempaddcomp->comp[addcompcnt].offset.offset_quantity = request->plans[i].phase[j].
      component[k].offset.offset_quantity
      SET tempaddcomp->comp[addcompcnt].offset.offset_unit_cd = request->plans[i].phase[j].component[
      k].offset.offset_unit_cd
      SET tempaddcomp->comp[addcompcnt].uuid = request->plans[i].phase[j].component[k].uuid
      IF ((request->plans[i].phase[j].component[k].comp_type="SUBPHASE"))
       SET addsubphasecnt = (addsubphasecnt+ 1)
       SET tempaddsubphase->subphase[addsubphasecnt].id = request->plans[i].phase[j].component[k].
       parent_entity_id
       SET tempaddsubphase->subphase[addsubphasecnt].phaseid = phaseid
      ENDIF
      IF ((request->plans[i].phase[j].component[k].comp_type="NOTE"))
       SET addnotecnt = (addnotecnt+ 1)
       SELECT INTO "nl:"
        tempid = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         noteid = cnvtreal(tempid)
        WITH nocounter
       ;end select
       SET tempaddnote->note[addnotecnt].noteid = noteid
       SET tempaddnote->note[addnotecnt].compid = compid
       SET tempaddnote->note[addnotecnt].notetext = request->plans[i].phase[j].component[k].note_text
       SET tempaddcomp->comp[addcompcnt].parent_entity_id = noteid
       SET tempaddcomp->comp[addcompcnt].parent_entity_name = "LONG_TEXT"
      ENDIF
     ELSEIF ((request->plans[i].phase[j].component[k].action_flag=2))
      SET updcompcnt = (updcompcnt+ 1)
      SET tempupdcomp->comp[updcompcnt].id = compid
      SET tempupdcomp->comp[updcompcnt].comp_type = request->plans[i].phase[j].component[k].comp_type
      SET tempupdcomp->comp[updcompcnt].dcp_clin_cat_code_value = request->plans[i].phase[j].
      component[k].dcp_clin_cat_code_value
      SET tempupdcomp->comp[updcompcnt].dcp_clin_sub_cat_code_value = request->plans[i].phase[j].
      component[k].dcp_clin_sub_cat_code_value
      SET tempupdcomp->comp[updcompcnt].default_os_ind = request->plans[i].phase[j].component[k].
      default_os_ind
      SET tempupdcomp->comp[updcompcnt].evidence_locator = request->plans[i].phase[j].component[k].
      evidence_locator
      SET tempupdcomp->comp[updcompcnt].evidence_type_mean = request->plans[i].phase[j].component[k].
      evidence_type_mean
      SET tempupdcomp->comp[updcompcnt].include_ind = request->plans[i].phase[j].component[k].
      include_ind
      SET tempupdcomp->comp[updcompcnt].parent_entity_id = request->plans[i].phase[j].component[k].
      parent_entity_id
      SET tempupdcomp->comp[updcompcnt].parent_entity_name = request->plans[i].phase[j].component[k].
      parent_entity_name
      SET tempupdcomp->comp[updcompcnt].phaseid = phaseid
      SET tempupdcomp->comp[updcompcnt].required_ind = request->plans[i].phase[j].component[k].
      required_ind
      SET tempupdcomp->comp[updcompcnt].sequence = request->plans[i].phase[j].component[k].sequence
      SET tempupdcomp->comp[updcompcnt].persistent_ind = request->plans[i].phase[j].component[k].
      persistent_ind
      SET tempupdcomp->comp[updcompcnt].offset.offset_quantity = request->plans[i].phase[j].
      component[k].offset.offset_quantity
      SET tempupdcomp->comp[updcompcnt].offset.offset_unit_cd = request->plans[i].phase[j].component[
      k].offset.offset_unit_cd
      SELECT INTO "nl:"
       FROM pw_evidence_reltn per
       PLAN (per
        WHERE phaseid=per.pathway_catalog_id
         AND compid=per.pathway_comp_id
         AND per.dcp_clin_cat_cd=0.0
         AND per.dcp_clin_sub_cat_cd=0.0
         AND per.type_mean IN ("URL", "ZYNX")
         AND (tempupdcomp->comp[updcompcnt].evidence_type_mean > " ")
         AND (tempupdcomp->comp[updcompcnt].evidence_locator > " "))
       DETAIL
        tempupdcomp->comp[updcompcnt].evidence_reltn_id = per.pw_evidence_reltn_id
       WITH nocounter
      ;end select
      IF ((request->plans[i].phase[j].component[k].comp_type="NOTE"))
       SET updnotecnt = (updnotecnt+ 1)
       SELECT INTO "nl:"
        FROM pathway_comp pc
        PLAN (pc
         WHERE pc.pathway_comp_id=compid)
        DETAIL
         tempupdnote->note[updnotecnt].noteid = pc.parent_entity_id
        WITH nocounter
       ;end select
       SET tempupdnote->note[updnotecnt].compid = compid
       SET tempupdnote->note[updnotecnt].notetext = request->plans[i].phase[j].component[k].note_text
      ENDIF
     ELSEIF ((request->plans[i].phase[j].component[k].action_flag=3))
      SET delcompcnt = (delcompcnt+ 1)
      SET tempdelcomp->comp[delcompcnt].id = compid
      SELECT INTO "nl:"
       FROM pw_evidence_reltn per
       PLAN (per
        WHERE per.pathway_catalog_id=phaseid
         AND per.pathway_comp_id=compid
         AND per.dcp_clin_cat_cd=0.0
         AND per.dcp_clin_sub_cat_cd=0.0
         AND per.type_mean IN ("URL", "ZYNX"))
       DETAIL
        tempdelcomp->comp[delcompcnt].evidence_reltn_id = per.pw_evidence_reltn_id
       WITH nocounter
      ;end select
      IF ((request->plans[i].phase[j].component[k].comp_type="SUBPHASE"))
       SET delsubphasecnt = (delsubphasecnt+ 1)
       SET tempdelsubphase->subphase[delsubphasecnt].id = request->plans[i].phase[j].component[k].
       parent_entity_id
       SET tempdelsubphase->subphase[delsubphasecnt].phaseid = phaseid
      ENDIF
     ENDIF
     CALL populatesynos(i,j,k)
     CALL populateingos(i,j,k)
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE populatesynos(i,j,k)
  SET oscnt = size(request->plans[i].phase[j].component[k].order_sentence,5)
  IF (oscnt > 0)
   SET temp = size(tempaddsynos->ordersentence,5)
   SET stat = alterlist(tempaddsynos->ordersentence,(oscnt+ temp))
   SET temp = size(tempupdos->ordersentence,5)
   SET stat = alterlist(tempupdos->ordersentence,(oscnt+ temp))
   SET temp = size(tempdelos->ordersentence,5)
   SET stat = alterlist(tempdelos->ordersentence,(oscnt+ temp))
   FOR (l = 1 TO oscnt)
     SET synosid = request->plans[i].phase[j].component[k].order_sentence[l].order_sentence_id
     IF ((request->plans[i].phase[j].component[k].order_sentence[l].action_flag=1))
      SET addsynoscnt = (addsynoscnt+ 1)
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        synosid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddsynos->ordersentence[addsynoscnt].id = synosid
      SET tempaddsynos->ordersentence[addsynoscnt].componentid = compid
      SET tempaddsynos->ordersentence[addsynoscnt].order_sentence_display_line = request->plans[i].
      phase[j].component[k].order_sentence[l].order_sentence_display_line
      SET tempaddsynos->ordersentence[addsynoscnt].order_sentence_id = request->plans[i].phase[j].
      component[k].order_sentence[l].order_sentence_id
      SET tempaddsynos->ordersentence[addsynoscnt].os_oe_format_id = request->plans[i].phase[j].
      component[k].order_sentence[l].os_oe_format_id
      SET tempaddsynos->ordersentence[addsynoscnt].phaseid = phaseid
      SET tempaddsynos->ordersentence[addsynoscnt].powerplanid = planid
      SET tempaddsynos->ordersentence[addsynoscnt].sequence = request->plans[i].phase[j].component[k]
      .order_sentence[l].sequence
      SET tempaddsynos->ordersentence[addsynoscnt].usage_flag = request->plans[i].phase[j].component[
      k].order_sentence[l].usage_flag
      SET tempaddsynos->ordersentence[addsynoscnt].rx_type_mean = request->plans[i].phase[j].
      component[k].order_sentence[l].rx_type_mean
      IF ((request->plans[i].phase[j].component[k].order_sentence[l].comment > " "))
       SET tempaddsynos->ordersentence[addsynoscnt].comment = request->plans[i].phase[j].component[k]
       .order_sentence[l].comment
       SELECT INTO "nl:"
        tempid = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         tempaddsynos->ordersentence[addsynoscnt].commentid = cnvtreal(tempid)
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((request->plans[i].phase[j].component[k].order_sentence[l].action_flag=2))
      SET updoscnt = (updoscnt+ 1)
      SET tempupdos->ordersentence[updoscnt].order_sentence_id = synosid
      SET tempupdos->ordersentence[updoscnt].comment = request->plans[i].phase[j].component[k].
      order_sentence[l].comment
      SET tempupdos->ordersentence[updoscnt].order_sentence_display_line = request->plans[i].phase[j]
      .component[k].order_sentence[l].order_sentence_display_line
      SET tempupdos->ordersentence[updoscnt].sequence = request->plans[i].phase[j].component[k].
      order_sentence[l].sequence
      SET tempupdos->ordersentence[updoscnt].rx_type_mean = request->plans[i].phase[j].component[k].
      order_sentence[l].rx_type_mean
      SELECT INTO "nl:"
       FROM long_text lt
       PLAN (lt
        WHERE lt.parent_entity_id=synosid
         AND lt.parent_entity_name="ORDER_SENTENCE")
       DETAIL
        IF ((lt.long_text=tempupdos->ordersentence[updoscnt].comment))
         tempupdos->ordersentence[updoscnt].commentid = lt.long_text_id
        ENDIF
       WITH nocounter
      ;end select
     ELSEIF ((request->plans[i].phase[j].component[k].order_sentence[l].action_flag=3))
      SET deloscnt = (deloscnt+ 1)
      SET tempdelos->ordersentence[deloscnt].id = synosid
      SET tempdelos->ordersentence[deloscnt].componentid = compid
     ENDIF
     CALL populatesynosdet(i,j,k,l)
     CALL populatesynosfilters(i,j,k,l)
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE populatesynosfilters(i,j,k,l)
  SET osfiltercnt = size(request->plans[i].phase[j].component[k].order_sentence[l].filters,5)
  IF (osfiltercnt > 0)
   FOR (m = 1 TO osfiltercnt)
     IF ((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].
     order_sentence_filter_id=0)
      AND (((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].age_code_value > 0)
     ) OR ((((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].pma_code_value > 0
     )) OR ((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].weight_code_value
      > 0))) )) )
      SET addosfiltercnt = (addosfiltercnt+ 1)
      SET temp = size(tempaddosfilter->filters,5)
      SET stat = alterlist(tempaddosfilter->filters,(addosfiltercnt+ temp))
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        osfilterid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddosfilter->filters[addosfiltercnt].order_sentence_filter_id = osfilterid
      SET tempaddosfilter->filters[addosfiltercnt].sentence_id = synosid
      SET tempaddosfilter->filters[addosfiltercnt].age_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_min_value
      SET tempaddosfilter->filters[addosfiltercnt].age_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_max_value
      SET tempaddosfilter->filters[addosfiltercnt].age_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_code_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_min_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_max_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_code_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_min_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_max_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_code_value
     ELSEIF ((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].
     order_sentence_filter_id > 0)
      AND (((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].age_code_value > 0)
     ) OR ((((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].pma_code_value > 0
     )) OR ((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].weight_code_value
      > 0))) )) )
      SET updosfiltercnt = (updosfiltercnt+ 1)
      SET temp = size(tempupdosfilter->filters,5)
      SET stat = alterlist(tempupdosfilter->filters,(updosfiltercnt+ temp))
      SET tempupdosfilter->filters[updosfiltercnt].order_sentence_filter_id = request->plans[i].
      phase[j].component[k].order_sentence[l].filters[m].order_sentence_filter_id
      SET tempupdosfilter->filters[updosfiltercnt].age_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_min_value
      SET tempupdosfilter->filters[updosfiltercnt].age_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_max_value
      SET tempupdosfilter->filters[updosfiltercnt].age_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].age_code_value
      SET tempupdosfilter->filters[updosfiltercnt].pma_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_min_value
      SET tempupdosfilter->filters[updosfiltercnt].pma_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_max_value
      SET tempupdosfilter->filters[updosfiltercnt].pma_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].pma_code_value
      SET tempupdosfilter->filters[updosfiltercnt].weight_min_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_min_value
      SET tempupdosfilter->filters[updosfiltercnt].weight_max_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_max_value
      SET tempupdosfilter->filters[updosfiltercnt].weight_code_value = request->plans[i].phase[j].
      component[k].order_sentence[l].filters[m].weight_code_value
     ELSEIF ((request->plans[i].phase[j].component[k].order_sentence[l].filters[m].
     order_sentence_filter_id > 0)
      AND (request->plans[i].phase[j].component[k].order_sentence[l].filters[m].age_code_value=0)
      AND (request->plans[i].phase[j].component[k].order_sentence[l].filters[m].pma_code_value=0)
      AND (request->plans[i].phase[j].component[k].order_sentence[l].filters[m].weight_code_value=0))
      SET delosfiltercnt = (delosfiltercnt+ 1)
      SET temp = size(tempdelosfilter->filters,5)
      SET stat = alterlist(tempdelosfilter->filters,(delosfiltercnt+ temp))
      SET tempdelosfilter->filters[delosfiltercnt].order_sentence_filter_id = request->plans[i].
      phase[j].component[k].order_sentence[l].filters[m].order_sentence_filter_id
     ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE populatesynosdet(i,j,k,l)
   SET osdetcnt = size(request->plans[i].phase[j].component[k].order_sentence[l].details,5)
   IF (osdetcnt > 0)
    SET temp = size(tempaddosdet->fielddetail,5)
    SET stat = alterlist(tempaddosdet->fielddetail,(osdetcnt+ temp))
    SET highseq = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = osdetcnt),
      order_entry_fields oef
     PLAN (d
      WHERE (request->plans[i].phase[j].component[k].order_sentence[l].details[d.seq].action_flag
       IN (0, 1, 2)))
      JOIN (oef
      WHERE (oef.oe_field_id=request->plans[i].phase[j].component[k].order_sentence[l].details[d.seq]
      .oef_id))
     DETAIL
      addosdetcnt = (addosdetcnt+ 1), tempaddosdet->fielddetail[addosdetcnt].componentid = compid,
      tempaddosdet->fielddetail[addosdetcnt].display = request->plans[i].phase[j].component[k].
      order_sentence[l].details[d.seq].display,
      tempaddosdet->fielddetail[addosdetcnt].field_type_flag = oef.field_type_flag, tempaddosdet->
      fielddetail[addosdetcnt].oe_field_meaning_id = oef.oe_field_meaning_id, tempaddosdet->
      fielddetail[addosdetcnt].oef_id = request->plans[i].phase[j].component[k].order_sentence[l].
      details[d.seq].oef_id,
      tempaddosdet->fielddetail[addosdetcnt].phaseid = phaseid, tempaddosdet->fielddetail[addosdetcnt
      ].powerplanid = planid, tempaddosdet->fielddetail[addosdetcnt].sentenceid = synosid,
      tempaddosdet->fielddetail[addosdetcnt].sequence = request->plans[i].phase[j].component[k].
      order_sentence[l].details[d.seq].sequence, tempaddosdet->fielddetail[addosdetcnt].value =
      request->plans[i].phase[j].component[k].order_sentence[l].details[d.seq].value
      IF ((request->plans[i].phase[j].component[k].order_sentence[l].details[d.seq].sequence >
      highseq))
       highseq = request->plans[i].phase[j].component[k].order_sentence[l].details[d.seq].sequence
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->plans[i].phase[j].component[k].comp_type="MED"))
    IF ((request->plans[i].phase[j].component[k].order_sentence[l].intermittent_ind > 0))
     SET addosdetcnt = (addosdetcnt+ 1)
     SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
     SET tempaddosdet->fielddetail[addosdetcnt].componentid = compid
     SET tempaddosdet->fielddetail[addosdetcnt].field_type_flag = 1
     SET tempaddosdet->fielddetail[addosdetcnt].oe_field_meaning_id =
     intermittent_oe_field_meaning_id
     SET tempaddosdet->fielddetail[addosdetcnt].oef_id = intermittent_oe_field_id
     SET tempaddosdet->fielddetail[addosdetcnt].phaseid = phaseid
     SET tempaddosdet->fielddetail[addosdetcnt].powerplanid = planid
     SET tempaddosdet->fielddetail[addosdetcnt].sentenceid = synosid
     SET tempaddosdet->fielddetail[addosdetcnt].sequence = (highseq+ 1)
     IF ((request->plans[i].phase[j].component[k].order_sentence[l].intermittent_ind=1))
      SET tempaddosdet->fielddetail[addosdetcnt].display = "Intermittent"
      SET tempaddosdet->fielddetail[addosdetcnt].value = 3
     ELSE
      SET tempaddosdet->fielddetail[addosdetcnt].display = "Continuous"
      SET tempaddosdet->fielddetail[addosdetcnt].value = 2
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populateingos(i,j,k)
  SET ingcnt = size(request->plans[i].phase[j].component[k].iv_ingredient,5)
  IF (ingcnt > 0)
   SET temp = size(tempaddingos->ordersentence,5)
   SET stat = alterlist(tempaddingos->ordersentence,(ingcnt+ temp))
   SET temp = size(tempupdos->ordersentence,5)
   SET stat = alterlist(tempupdos->ordersentence,(ingcnt+ temp))
   SET temp = size(tempdelos->ordersentence,5)
   SET stat = alterlist(tempdelos->ordersentence,(ingcnt+ temp))
   FOR (l = 1 TO ingcnt)
     SET ingosid = request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.
     order_sentence_id
     IF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.action_flag=1))
      SET addingoscnt = (addingoscnt+ 1)
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        ingosid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddingos->ordersentence[addingoscnt].id = ingosid
      SET tempaddingos->ordersentence[addingoscnt].componentid = compid
      SET tempaddingos->ordersentence[addingoscnt].order_sentence_display_line = request->plans[i].
      phase[j].component[k].iv_ingredient[l].iv_order_sentence.order_sentence_display_line
      SET tempaddingos->ordersentence[addingoscnt].order_sentence_id = request->plans[i].phase[j].
      component[k].iv_ingredient[l].iv_order_sentence.order_sentence_id
      SET tempaddingos->ordersentence[addingoscnt].os_oe_format_id = request->plans[i].phase[j].
      component[k].iv_ingredient[l].iv_order_sentence.os_oe_format_id
      SET tempaddingos->ordersentence[addingoscnt].phaseid = phaseid
      SET tempaddingos->ordersentence[addingoscnt].powerplanid = planid
      SET tempaddingos->ordersentence[addingoscnt].synonymid = request->plans[i].phase[j].component[k
      ].iv_ingredient[l].synonym_id
      IF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.comment > " "))
       SET tempaddingos->ordersentence[addingoscnt].comment = request->plans[i].phase[j].component[k]
       .iv_ingredient[l].iv_order_sentence.comment
       SELECT INTO "nl:"
        tempid = seq(long_data_seq,nextval)
        FROM dual
        DETAIL
         tempaddingos->ordersentence[addingoscnt].commentid = cnvtreal(tempid)
        WITH nocounter
       ;end select
      ENDIF
     ELSEIF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.action_flag=
     2))
      SET updoscnt = (updoscnt+ 1)
      SELECT INTO "nl:"
       FROM order_sentence os
       PLAN (os
        WHERE (os.parent_entity_id=request->plans[i].phase[j].component[k].comp_id)
         AND os.parent_entity_name="PATHWAY_COMP"
         AND (os.parent_entity2_id=request->plans[i].phase[j].component[k].iv_ingredient[l].
        synonym_id)
         AND os.parent_entity2_name="ORDER_CATALOG_SYNONYM"
         AND os.usage_flag=1)
       DETAIL
        ingosid = os.order_sentence_id
       WITH nocounter
      ;end select
      SET tempupdos->ordersentence[updoscnt].order_sentence_id = ingosid
      SET tempupdos->ordersentence[updoscnt].comment = request->plans[i].phase[j].component[k].
      iv_ingredient[l].iv_order_sentence.comment
      SET tempupdos->ordersentence[updoscnt].order_sentence_display_line = request->plans[i].phase[j]
      .component[k].iv_ingredient[l].iv_order_sentence.order_sentence_display_line
      SELECT INTO "nl:"
       FROM long_text lt
       PLAN (lt
        WHERE lt.parent_entity_id=ingosid
         AND lt.parent_entity_name="ORDER_SENTENCE")
       DETAIL
        IF ((lt.long_text=tempupdos->ordersentence[updoscnt].comment))
         tempupdos->ordersentence[updoscnt].commentid = lt.long_text_id
        ENDIF
       WITH nocounter
      ;end select
     ELSEIF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.action_flag=
     3))
      SET deloscnt = (deloscnt+ 1)
      SET tempdelos->ordersentence[deloscnt].id = ingosid
      SET tempdelos->ordersentence[deloscnt].componentid = compid
     ENDIF
     CALL deleteingosdet(i,j,k,l)
     IF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.action_flag=1))
      CALL deleteingosandrlns(i,j,k)
     ENDIF
     CALL populateingosdet(i,j,k,l)
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteingosandrlns(i,j,k)
   SET existingosid = 0.0
   SELECT INTO "nl:"
    FROM order_sentence os
    PLAN (os
     WHERE (os.parent_entity_id=request->plans[i].phase[j].component[k].comp_id)
      AND os.parent_entity_name="PATHWAY_COMP"
      AND (os.parent_entity2_id=request->plans[i].phase[j].component[k].iv_ingredient[l].synonym_id)
      AND os.parent_entity2_name="ORDER_CATALOG_SYNONYM"
      AND os.usage_flag=1)
    DETAIL
     existingosid = os.order_sentence_id
    WITH nocounter
   ;end select
   IF (existingosid > 0.0)
    SET ierrcode = 0
    DELETE  FROM pw_comp_os_reltn pcor
     PLAN (pcor
      WHERE (pcor.pathway_comp_id=request->plans[i].phase[j].component[k].comp_id)
       AND pcor.order_sentence_id=existingosid)
     WITH nocounter
    ;end delete
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error removing s2 sentence details")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM order_sentence_filter f
     PLAN (f
      WHERE f.order_sentence_id=existingosid)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error removing s3 order_sentence_filter")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM order_sentence o
     PLAN (o
      WHERE o.order_sentence_id=existingosid)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error removing s4 sentence details")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteingosdet(i,j,k,l)
   DECLARE ingosdetcnt = i4 WITH protect, noconstant(0)
   SET existingosid = 0.0
   SELECT INTO "nl:"
    FROM order_sentence os
    PLAN (os
     WHERE (os.parent_entity_id=request->plans[i].phase[j].component[k].comp_id)
      AND os.parent_entity_name="PATHWAY_COMP"
      AND (os.parent_entity2_id=request->plans[i].phase[j].component[k].iv_ingredient[l].synonym_id)
      AND os.parent_entity2_name="ORDER_CATALOG_SYNONYM"
      AND os.usage_flag=1)
    DETAIL
     existingosid = os.order_sentence_id
    WITH nocounter
   ;end select
   IF (existingosid > 0.0)
    SET ingosdetcnt = size(request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence
     .details,5)
    IF (ingosdetcnt > 0)
     FOR (m = 1 TO ingosdetcnt)
       IF ((request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.details[m].
       action_flag=3))
        SET ierrcode = 0
        DELETE  FROM order_sentence_detail o
         PLAN (o
          WHERE o.order_sentence_id=existingosid)
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = concat(
          "Error removing s1 sentence details")
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populateingosdet(i,j,k,l)
  SET ingdetcnt = size(request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.
   details,5)
  IF (ingdetcnt > 0)
   SET temp = size(tempaddosdet->fielddetail,5)
   SET stat = alterlist(tempaddosdet->fielddetail,(ingdetcnt+ temp))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ingdetcnt),
     order_entry_fields oef
    PLAN (d
     WHERE (request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.details[d.seq]
     .action_flag IN (0, 1, 2)))
     JOIN (oef
     WHERE (oef.oe_field_id=request->plans[i].phase[j].component[k].iv_ingredient[l].
     iv_order_sentence.details[d.seq].oef_id))
    DETAIL
     addosdetcnt = (addosdetcnt+ 1), tempaddosdet->fielddetail[addosdetcnt].componentid = compid,
     tempaddosdet->fielddetail[addosdetcnt].display = request->plans[i].phase[j].component[k].
     iv_ingredient[l].iv_order_sentence.details[d.seq].display,
     tempaddosdet->fielddetail[addosdetcnt].oef_id = request->plans[i].phase[j].component[k].
     iv_ingredient[l].iv_order_sentence.details[d.seq].oef_id, tempaddosdet->fielddetail[addosdetcnt]
     .phaseid = phaseid, tempaddosdet->fielddetail[addosdetcnt].powerplanid = planid,
     tempaddosdet->fielddetail[addosdetcnt].sentenceid = ingosid, tempaddosdet->fielddetail[
     addosdetcnt].value = request->plans[i].phase[j].component[k].iv_ingredient[l].iv_order_sentence.
     details[d.seq].value, tempaddosdet->fielddetail[addosdetcnt].oe_field_meaning_id = oef
     .oe_field_meaning_id,
     tempaddosdet->fielddetail[addosdetcnt].field_type_flag = oef.field_type_flag, tempaddosdet->
     fielddetail[addosdetcnt].sequence = request->plans[i].phase[j].component[k].iv_ingredient[l].
     iv_order_sentence.details[d.seq].sequence
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 IF (addplancnt > 0)
  INSERT  FROM pathway_catalog pc,
    (dummyt d  WITH seq = addplancnt)
   SET pc.pathway_catalog_id = tempaddplan->power_plan[d.seq].id, pc.description = tempaddplan->
    power_plan[d.seq].description, pc.description_key = tempaddplan->power_plan[d.seq].
    description_key,
    pc.version = 1, pc.version_pw_cat_id = tempaddplan->power_plan[d.seq].id, pc.active_ind = 1,
    pc.beg_effective_dt_tm = cnvtdatetime(tempaddplan->power_plan[d.seq].beg_effective_dt_tm), pc
    .end_effective_dt_tm = cnvtdatetime(tempaddplan->power_plan[d.seq].end_effective_dt_tm), pc
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_cnt = 0,
    pc.updt_applctx = reqinfo->updt_applctx, pc.type_mean = tempaddplan->power_plan[d.seq].type_mean,
    pc.pathway_type_cd = tempaddplan->power_plan[d.seq].plan_type_id,
    pc.display_method_cd = clin_cat_disp_method_cd, pc.display_description = tempaddplan->power_plan[
    d.seq].display, pc.sub_phase_ind = tempaddplan->power_plan[d.seq].subphase_ind,
    pc.cross_encntr_ind = tempaddplan->power_plan[d.seq].cross_counter_ind, pc.diagnosis_capture_ind
     = tempaddplan->power_plan[d.seq].allow_diagnosis_propogation_ind, pc.hide_flexed_comp_ind =
    tempaddplan->power_plan[d.seq].hide_flexed_comp_ind,
    pc.provider_prompt_ind = tempaddplan->power_plan[d.seq].prompt_ordering_physician_ind, pc
    .allow_copy_forward_ind = tempaddplan->power_plan[d.seq].copy_forward_ind, pc.pathway_uuid =
    tempaddplan->power_plan[d.seq].uuid
   PLAN (d)
    JOIN (pc)
   WITH nocounter
  ;end insert
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = addplancnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempaddplan->
    power_plan[d.seq].id, per.type_mean = tempaddplan->power_plan[d.seq].evidence_type_mean,
    per.evidence_locator = tempaddplan->power_plan[d.seq].evidence_locator, per.updt_id = reqinfo->
    updt_id, per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0
   PLAN (d
    WHERE (tempaddplan->power_plan[d.seq].evidence_type_mean > " ")
     AND (tempaddplan->power_plan[d.seq].evidence_locator > " "))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (modplancnt > 0)
  UPDATE  FROM pathway_catalog pc,
    (dummyt d  WITH seq = modplancnt)
   SET pc.description = tempmodplan->power_plan[d.seq].description, pc.description_key = tempmodplan
    ->power_plan[d.seq].description_key, pc.pathway_type_cd = tempmodplan->power_plan[d.seq].
    plan_type_id,
    pc.display_description = tempmodplan->power_plan[d.seq].display, pc.sub_phase_ind = tempmodplan->
    power_plan[d.seq].subphase_ind, pc.cross_encntr_ind = tempmodplan->power_plan[d.seq].
    cross_counter_ind,
    pc.diagnosis_capture_ind = tempmodplan->power_plan[d.seq].allow_diagnosis_propogation_ind, pc
    .hide_flexed_comp_ind = tempmodplan->power_plan[d.seq].hide_flexed_comp_ind, pc
    .provider_prompt_ind = tempmodplan->power_plan[d.seq].prompt_ordering_physician_ind,
    pc.allow_copy_forward_ind = tempmodplan->power_plan[d.seq].copy_forward_ind, pc.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=tempmodplan->power_plan[d.seq].id))
   WITH nocounter
  ;end update
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modplancnt)
   SET per.seq = 1
   PLAN (d
    WHERE (tempmodplan->power_plan[d.seq].evidence_type_mean="")
     AND (tempmodplan->power_plan[d.seq].evidence_locator=""))
    JOIN (per
    WHERE (per.pathway_catalog_id=tempmodplan->power_plan[d.seq].id)
     AND per.pathway_comp_id=0
     AND per.dcp_clin_cat_cd=0.0
     AND per.dcp_clin_sub_cat_cd=0.0
     AND per.type_mean IN ("URL", "ZYNX"))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modplancnt)
   SET per.type_mean = tempmodplan->power_plan[d.seq].evidence_type_mean, per.evidence_locator =
    tempmodplan->power_plan[d.seq].evidence_locator, per.updt_id = reqinfo->updt_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
    .updt_applctx = reqinfo->updt_applctx,
    per.updt_cnt = (per.updt_cnt+ 1)
   PLAN (d
    WHERE (tempmodplan->power_plan[d.seq].evidence_type_mean > " ")
     AND (tempmodplan->power_plan[d.seq].evidence_locator > " ")
     AND (tempmodplan->power_plan[d.seq].evidence_reltn_id > 0))
    JOIN (per
    WHERE (per.pw_evidence_reltn_id=tempmodplan->power_plan[d.seq].evidence_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modplancnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempmodplan->
    power_plan[d.seq].id, per.type_mean = tempmodplan->power_plan[d.seq].evidence_type_mean,
    per.evidence_locator = tempmodplan->power_plan[d.seq].evidence_locator, per.updt_id = reqinfo->
    updt_id, per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0
   PLAN (d
    WHERE (tempmodplan->power_plan[d.seq].evidence_type_mean > " ")
     AND (tempmodplan->power_plan[d.seq].evidence_locator > " ")
     AND (tempmodplan->power_plan[d.seq].evidence_reltn_id=0))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (planactstatcnt > 0)
  UPDATE  FROM pathway_catalog pc,
    (dummyt d  WITH seq = planactstatcnt)
   SET pc.active_ind = modplanactivestatus->power_plan[d.seq].active_ind, pc.updt_id = reqinfo->
    updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=modplanactivestatus->power_plan[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating active pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addplansynonymcnt > 0)
  INSERT  FROM pw_cat_synonym p,
    (dummyt d  WITH seq = addplansynonymcnt)
   SET p.pw_cat_synonym_id = seq(reference_seq,nextval), p.synonym_name = tempaddplansynonym->
    synonyms[d.seq].synonym_name, p.synonym_name_key = tempaddplansynonym->synonyms[d.seq].
    synonym_name_key,
    p.primary_ind = tempaddplansynonym->synonyms[d.seq].primary_ind, p.pathway_catalog_id =
    tempaddplansynonym->synonyms[d.seq].power_plan_id, p.updt_id = reqinfo->updt_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task = reqinfo->updt_task, p.updt_applctx
     = reqinfo->updt_applctx,
    p.updt_cnt = 0
   PLAN (d)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_cat_synonym")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (modplansynonymcnt > 0)
  UPDATE  FROM pw_cat_synonym p,
    (dummyt d  WITH seq = modplansynonymcnt)
   SET p.synonym_name = tempmodplansynonym->synonyms[d.seq].synonym_name, p.synonym_name_key =
    tempmodplansynonym->synonyms[d.seq].synonym_name_key, p.primary_ind = tempmodplansynonym->
    synonyms[d.seq].primary_ind,
    p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_task =
    reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt+ 1)
   PLAN (d)
    JOIN (p
    WHERE (p.pw_cat_synonym_id=tempmodplansynonym->synonyms[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error modifying pw_cat_synonym")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delplansynonymcnt > 0)
  DELETE  FROM pw_cat_synonym p,
    (dummyt d  WITH seq = delplansynonymcnt)
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.pw_cat_synonym_id=tempdelplansynonym->synonyms[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_cat_synonym")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updplanfacilitycnt > 0)
  DELETE  FROM pw_cat_flex p,
    (dummyt d  WITH seq = updplanfacilitycnt)
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.pathway_catalog_id=tempupdplanfacility->facility[d.seq].plan_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_cat_flex")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_cat_flex p,
    (dummyt d1  WITH seq = updplanfacilitycnt)
   SET p.display_description_key = tempupdplanfacility->facility[d1.seq].plan_display_description_key,
    p.pathway_catalog_id = tempupdplanfacility->facility[d1.seq].plan_id, p.parent_entity_id =
    tempupdplanfacility->facility[d1.seq].facility_id,
    p.parent_entity_name = "CODE_VALUE", p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
   PLAN (d1)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delphasecnt > 0)
  UPDATE  FROM pathway_catalog pc,
    (dummyt d  WITH seq = delphasecnt)
   SET pc.active_ind = 0, pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=tempdelphase->phase[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_cat_reltn p,
    (dummyt d  WITH seq = delphasecnt)
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (((p.pw_cat_t_id=tempdelphase->phase[d.seq].id)
     AND p.type_mean="GROUP") OR ((((((p.pw_cat_s_id=tempdelphase->phase[d.seq].id)) OR ((p
    .pw_cat_t_id=tempdelphase->phase[d.seq].id)))
     AND p.type_mean="SUCCEED") OR ((p.pw_cat_s_id=tempdelphase->phase[d.seq].id)
     AND p.type_mean="SUBPHASE")) )) )
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_cat_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM pathway_comp pc,
    pw_evidence_reltn per,
    (dummyt d  WITH seq = delphasecnt)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=tempdelphase->phase[d.seq].id))
    JOIN (per
    WHERE per.pathway_catalog_id=outerjoin(pc.pathway_catalog_id)
     AND per.type_mean IN ("URL", "ZYNX"))
   DETAIL
    delcompcnt = (delcompcnt+ 1), stat = alterlist(tempdelcomp->comp,delcompcnt), tempdelcomp->comp[
    delcompcnt].id = pc.pathway_comp_id,
    tempdelcomp->comp[delcompcnt].evidence_reltn_id = per.pw_evidence_reltn_id
   WITH nocounter
  ;end select
 ENDIF
 IF (delcompcnt > 0)
  UPDATE  FROM pathway_comp pc,
    (dummyt d  WITH seq = delcompcnt)
   SET pc.active_ind = 0, pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_comp_id=tempdelcomp->comp[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pathway_comp")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = delcompcnt)
   SET per.seq = 1
   PLAN (d
    WHERE (tempdelcomp->comp[d.seq].evidence_reltn_id > 0))
    JOIN (per
    WHERE (per.pw_evidence_reltn_id=tempdelcomp->comp[d.seq].evidence_reltn_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(delcompcnt)),
    pw_comp_os_reltn p
   PLAN (d)
    JOIN (p
    WHERE (p.pathway_comp_id=tempdelcomp->comp[d.seq].id))
   DETAIL
    deloscnt = (deloscnt+ 1), stat = alterlist(tempdelos->ordersentence,deloscnt), tempdelos->
    ordersentence[deloscnt].id = p.order_sentence_id,
    tempdelos->ordersentence[deloscnt].componentid = p.pathway_comp_id
   WITH nocounter
  ;end select
  DELETE  FROM pw_comp_os_reltn os,
    (dummyt d  WITH seq = delcompcnt)
   SET os.seq = 1
   PLAN (d)
    JOIN (os
    WHERE (os.pathway_comp_id=tempdelcomp->comp[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_comp_os_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delsubphasecnt > 0)
  DELETE  FROM pw_cat_reltn p,
    (dummyt d  WITH seq = delsubphasecnt)
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (p.pw_cat_s_id=tempdelsubphase->subphase[d.seq].phaseid)
     AND (p.pw_cat_t_id=tempdelsubphase->subphase[d.seq].id)
     AND p.type_mean="SUBPHASE")
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_cat_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (deloscnt > 0)
  DELETE  FROM pw_comp_os_reltn pcor,
    (dummyt d  WITH seq = deloscnt)
   SET pcor.seq = 1
   PLAN (d)
    JOIN (pcor
    WHERE (pcor.pathway_comp_id=tempdelos->ordersentence[d.seq].componentid)
     AND (pcor.order_sentence_id=tempdelos->ordersentence[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_comp_os_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM order_sentence_detail o,
    (dummyt d  WITH seq = value(deloscnt))
   SET o.seq = 1
   PLAN (d)
    JOIN (o
    WHERE (o.order_sentence_id=tempdelos->ordersentence[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error removing sentence details")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM order_sentence_filter f,
    (dummyt d  WITH seq = value(deloscnt))
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.order_sentence_id=tempdelos->ordersentence[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error removing order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM order_sentence o,
    (dummyt d  WITH seq = value(deloscnt))
   SET o.seq = 1
   PLAN (d)
    JOIN (o
    WHERE (o.order_sentence_id=tempdelos->ordersentence[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error removing sentence details")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addphasecnt > 0)
  INSERT  FROM pathway_catalog pc,
    (dummyt d  WITH seq = addphasecnt)
   SET pc.pathway_catalog_id = tempaddphase->phase[d.seq].id, pc.description = tempaddphase->phase[d
    .seq].phase_description, pc.description_key = trim(cnvtupper(substring(1,100,tempaddphase->phase[
       d.seq].phase_description))),
    pc.version = 1, pc.type_mean = "PHASE", pc.active_ind = 1,
    pc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), pc.updt_id = reqinfo->updt_id,
    pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_task = reqinfo->updt_task, pc
    .updt_applctx = reqinfo->updt_applctx,
    pc.updt_cnt = 0, pc.display_method_cd = clin_cat_disp_method_cd, pc.alerts_on_plan_ind =
    tempaddphase->phase[d.seq].alerts_on_plan_ind,
    pc.alerts_on_plan_upd_ind = tempaddphase->phase[d.seq].alerts_on_plan_upd_ind, pc.pathway_uuid =
    cnvtupper(tempaddphase->phase[d.seq].uuid)
   PLAN (d)
    JOIN (pc)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_cat_reltn pcr,
    (dummyt d  WITH seq = addphasecnt)
   SET pcr.pw_cat_s_id = tempaddphase->phase[d.seq].power_plan_id, pcr.pw_cat_t_id = tempaddphase->
    phase[d.seq].id, pcr.type_mean = "GROUP",
    pcr.updt_id = reqinfo->updt_id, pcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcr.updt_task =
    reqinfo->updt_task,
    pcr.updt_applctx = reqinfo->updt_applctx, pcr.updt_cnt = 0
   PLAN (d)
    JOIN (pcr)
   WITH nocounter
  ;end insert
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_cat_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = addphasecnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempaddphase->
    phase[d.seq].id, per.type_mean = tempaddphase->phase[d.seq].phase_evidence_type_mean,
    per.evidence_locator = tempaddphase->phase[d.seq].phase_evidence_locator, per.updt_id = reqinfo->
    updt_id, per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0
   PLAN (d
    WHERE (tempaddphase->phase[d.seq].phase_evidence_type_mean > " ")
     AND (tempaddphase->phase[d.seq].phase_evidence_locator > " "))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (modphasecnt > 0)
  UPDATE  FROM pathway_catalog pc,
    (dummyt d  WITH seq = modphasecnt)
   SET pc.description = tempmodphase->phase[d.seq].phase_description, pc.description_key = trim(
     cnvtupper(substring(1,100,tempmodphase->phase[d.seq].phase_description))), pc.updt_id = reqinfo
    ->updt_id,
    pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_task = reqinfo->updt_task, pc
    .updt_applctx = reqinfo->updt_applctx,
    pc.updt_cnt = (pc.updt_cnt+ 1), pc.alerts_on_plan_ind = tempmodphase->phase[d.seq].
    alerts_on_plan_ind, pc.alerts_on_plan_upd_ind = tempmodphase->phase[d.seq].alerts_on_plan_upd_ind
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_catalog_id=tempmodphase->phase[d.seq].id))
   WITH nocounter
  ;end update
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pathway_catalog")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modphasecnt)
   SET per.seq = 1
   PLAN (d
    WHERE (tempmodphase->phase[d.seq].phase_evidence_type_mean="")
     AND (tempmodphase->phase[d.seq].phase_evidence_locator=""))
    JOIN (per
    WHERE (per.pathway_catalog_id=tempmodphase->phase[d.seq].id)
     AND per.pathway_comp_id=0)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modphasecnt)
   SET per.type_mean = tempmodphase->phase[d.seq].phase_evidence_type_mean, per.evidence_locator =
    tempmodphase->phase[d.seq].phase_evidence_locator, per.updt_id = reqinfo->updt_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
    .updt_applctx = reqinfo->updt_applctx,
    per.updt_cnt = (per.updt_cnt+ 1)
   PLAN (d
    WHERE (tempmodphase->phase[d.seq].phase_evidence_type_mean > " ")
     AND (tempmodphase->phase[d.seq].phase_evidence_locator > " ")
     AND (tempmodphase->phase[d.seq].phase_evidence_reltn_id > 0))
    JOIN (per
    WHERE (per.pw_evidence_reltn_id=tempmodphase->phase[d.seq].phase_evidence_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = modphasecnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempmodphase->
    phase[d.seq].id, per.type_mean = tempmodphase->phase[d.seq].phase_evidence_type_mean,
    per.evidence_locator = tempmodphase->phase[d.seq].phase_evidence_locator, per.updt_id = reqinfo->
    updt_id, per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0
   PLAN (d
    WHERE (tempmodphase->phase[d.seq].phase_evidence_type_mean > " ")
     AND (tempmodphase->phase[d.seq].phase_evidence_locator > " ")
     AND (tempmodphase->phase[d.seq].phase_evidence_reltn_id=0))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (phasesequencecnt > 0)
  DELETE  FROM pw_cat_reltn p,
    (dummyt d  WITH seq = phasesequencecnt)
   SET p.seq = 1
   PLAN (d)
    JOIN (p
    WHERE (((p.pw_cat_s_id=tempphasesequence->phase[d.seq].id)) OR ((p.pw_cat_t_id=tempphasesequence
    ->phase[d.seq].id)))
     AND p.type_mean="SUCCEED")
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_cat_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_cat_reltn p,
    (dummyt d  WITH seq = phasesequencecnt)
   SET p.pw_cat_s_id = tempphasesequence->phase[d.seq].id, p.pw_cat_t_id = tempphasesequence->phase[d
    .seq].next_phase_id, p.type_mean = "SUCCEED",
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Insert pw_cat_reltn1")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addcompcnt > 0)
  INSERT  FROM pathway_comp pc,
    (dummyt d  WITH seq = addcompcnt)
   SET pc.pathway_comp_id = tempaddcomp->comp[d.seq].id, pc.pathway_catalog_id = tempaddcomp->comp[d
    .seq].phaseid, pc.sequence = tempaddcomp->comp[d.seq].sequence,
    pc.parent_entity_id = tempaddcomp->comp[d.seq].parent_entity_id, pc.parent_entity_name =
    tempaddcomp->comp[d.seq].parent_entity_name, pc.dcp_clin_cat_cd = tempaddcomp->comp[d.seq].
    dcp_clin_cat_code_value,
    pc.dcp_clin_sub_cat_cd = tempaddcomp->comp[d.seq].dcp_clin_sub_cat_code_value, pc.comp_type_cd =
    IF ((tempaddcomp->comp[d.seq].comp_type IN ("IV", "MED", "NONMED"))) order_comp_cd
    ELSEIF ((tempaddcomp->comp[d.seq].comp_type="PRESCRIPTION")) prescription_comp_cd
    ELSEIF ((tempaddcomp->comp[d.seq].comp_type="NOTE")) note_comp_cd
    ELSEIF ((tempaddcomp->comp[d.seq].comp_type="SUBPHASE")) subphase_comp_cd
    ENDIF
    , pc.include_ind = tempaddcomp->comp[d.seq].include_ind,
    pc.required_ind = tempaddcomp->comp[d.seq].required_ind, pc.default_os_ind = tempaddcomp->comp[d
    .seq].default_os_ind, pc.persistent_ind = tempaddcomp->comp[d.seq].persistent_ind,
    pc.offset_quantity = tempaddcomp->comp[d.seq].offset.offset_quantity, pc.offset_unit_cd =
    tempaddcomp->comp[d.seq].offset.offset_unit_cd, pc.active_ind = 1,
    pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_task =
    reqinfo->updt_task,
    pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.pathway_uuid = cnvtupper(tempaddcomp
     ->comp[d.seq].uuid)
   PLAN (d)
    JOIN (pc)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pathway_comp")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = addcompcnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempaddcomp->
    comp[d.seq].phaseid, per.pathway_comp_id = tempaddcomp->comp[d.seq].id,
    per.type_mean = tempaddcomp->comp[d.seq].evidence_type_mean, per.evidence_locator = tempaddcomp->
    comp[d.seq].evidence_locator, per.updt_id = reqinfo->updt_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
    .updt_applctx = reqinfo->updt_applctx,
    per.updt_cnt = 0
   PLAN (d
    WHERE (tempaddcomp->comp[d.seq].evidence_type_mean > " ")
     AND (tempaddcomp->comp[d.seq].evidence_locator > " "))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updcompcnt > 0)
  UPDATE  FROM pathway_comp pc,
    (dummyt d  WITH seq = updcompcnt)
   SET pc.sequence = tempupdcomp->comp[d.seq].sequence, pc.include_ind = tempupdcomp->comp[d.seq].
    include_ind, pc.required_ind = tempupdcomp->comp[d.seq].required_ind,
    pc.default_os_ind = tempupdcomp->comp[d.seq].default_os_ind, pc.persistent_ind = tempupdcomp->
    comp[d.seq].persistent_ind, pc.dcp_clin_cat_cd = tempupdcomp->comp[d.seq].dcp_clin_cat_code_value,
    pc.dcp_clin_sub_cat_cd = tempupdcomp->comp[d.seq].dcp_clin_sub_cat_code_value, pc.offset_quantity
     = tempupdcomp->comp[d.seq].offset.offset_quantity, pc.offset_unit_cd = tempupdcomp->comp[d.seq].
    offset.offset_unit_cd,
    pc.updt_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_task =
    reqinfo->updt_task,
    pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc.updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_comp_id=tempupdcomp->comp[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pathway_comp")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = delcompcnt)
   SET per.seq = 1
   PLAN (d
    WHERE (tempupdcomp->comp[d.seq].evidence_type_mean="")
     AND (tempupdcomp->comp[d.seq].evidence_locator=""))
    JOIN (per
    WHERE (per.pathway_catalog_id=tempupdcomp->comp[d.seq].phaseid)
     AND (per.pathway_comp_id=tempupdcomp->comp[d.seq].id)
     AND per.dcp_clin_cat_cd=0.0
     AND per.dcp_clin_sub_cat_cd=0.0
     AND per.type_mean IN ("URL", "ZYNX"))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = updcompcnt)
   SET per.type_mean = tempupdcomp->comp[d.seq].evidence_type_mean, per.evidence_locator =
    tempupdcomp->comp[d.seq].evidence_locator, per.updt_id = reqinfo->updt_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
    .updt_applctx = reqinfo->updt_applctx,
    per.updt_cnt = (per.updt_cnt+ 1)
   PLAN (d
    WHERE (tempupdcomp->comp[d.seq].evidence_type_mean > " ")
     AND (tempupdcomp->comp[d.seq].evidence_locator > " ")
     AND (tempupdcomp->comp[d.seq].evidence_reltn_id > 0))
    JOIN (per
    WHERE (per.pw_evidence_reltn_id=tempupdcomp->comp[d.seq].evidence_reltn_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_evidence_reltn per,
    (dummyt d  WITH seq = updcompcnt)
   SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = tempupdcomp->
    comp[d.seq].phaseid, per.pathway_comp_id = tempupdcomp->comp[d.seq].id,
    per.type_mean = tempupdcomp->comp[d.seq].evidence_type_mean, per.evidence_locator = tempupdcomp->
    comp[d.seq].evidence_locator, per.updt_id = reqinfo->updt_id,
    per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
    .updt_applctx = reqinfo->updt_applctx,
    per.updt_cnt = 0
   PLAN (d
    WHERE (tempupdcomp->comp[d.seq].evidence_type_mean > " ")
     AND (tempupdcomp->comp[d.seq].evidence_locator > " ")
     AND (tempupdcomp->comp[d.seq].evidence_reltn_id=0))
    JOIN (per)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_evidence_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addsubphasecnt > 0)
  CALL echo("add subphase")
  INSERT  FROM pw_cat_reltn p,
    (dummyt d  WITH seq = addsubphasecnt)
   SET p.pw_cat_s_id = tempaddsubphase->subphase[d.seq].phaseid, p.pw_cat_t_id = tempaddsubphase->
    subphase[d.seq].id, p.type_mean = "SUBPHASE",
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
    reqinfo->updt_task,
    p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Insert pw_cat_reltn2")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addnotecnt > 0)
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addnotecnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddnote->note[d.seq].notetext,
    lt.long_text_id = tempaddnote->note[d.seq].noteid,
    lt.parent_entity_id = tempaddnote->note[d.seq].compid, lt.parent_entity_name = "PATHWAY_COMP", lt
    .updt_task = reqinfo->updt_task,
    lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempaddnote->note[d.seq].notetext > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into long_text")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updnotecnt > 0)
  UPDATE  FROM long_text lt,
    (dummyt d  WITH seq = updnotecnt)
   SET lt.long_text = tempupdnote->note[d.seq].notetext, lt.updt_task = reqinfo->updt_task, lt
    .updt_id = reqinfo->updt_id,
    lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (d
    WHERE (tempupdnote->note[d.seq].notetext > " "))
    JOIN (lt
    WHERE (lt.long_text_id=tempupdnote->note[d.seq].noteid)
     AND (lt.parent_entity_id=tempupdnote->note[d.seq].compid))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error updating into long_text"
    )
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addsynoscnt > 0)
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addsynoscnt)
   SET os.oe_format_id = tempaddsynos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddsynos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddsynos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.usage_flag = tempaddsynos->ordersentence[d.seq].usage_flag,
    os.ord_comment_long_text_id = tempaddsynos->ordersentence[d.seq].commentid, os.rx_type_mean =
    tempaddsynos->ordersentence[d.seq].rx_type_mean, os.updt_id = reqinfo->updt_id,
    os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task = reqinfo->updt_task, os
    .updt_applctx = reqinfo->updt_applctx,
    os.updt_cnt = 0
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].id > 0))
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addsynoscnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddsynos->ordersentence[d.seq].
    comment, lt.long_text_id = tempaddsynos->ordersentence[d.seq].commentid,
    lt.parent_entity_id = tempaddsynos->ordersentence[d.seq].id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_task = reqinfo->updt_task,
    lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].comment > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into long_text")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addsynoscnt)
   SET pw.iv_comp_syn_id = 0, pw.order_sentence_id = tempaddsynos->ordersentence[d.seq].id, pw
    .order_sentence_seq = tempaddsynos->ordersentence[d.seq].sequence,
    pw.os_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddsynos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].id > 0))
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_comp_os_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addingoscnt > 0)
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addingoscnt)
   SET os.oe_format_id = tempaddingos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddingos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddingos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.parent_entity2_id = tempaddingos->ordersentence[d.seq].synonymid,
    os.parent_entity2_name = "ORDER_CATALOG_SYNONYM", os.usage_flag = 1, os.ord_comment_long_text_id
     = tempaddingos->ordersentence[d.seq].commentid,
    os.updt_id = reqinfo->updt_id, os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task =
    reqinfo->updt_task,
    os.updt_applctx = reqinfo->updt_applctx, os.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].id > 0))
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addingoscnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddingos->ordersentence[d.seq].
    comment, lt.long_text_id = tempaddingos->ordersentence[d.seq].commentid,
    lt.parent_entity_id = tempaddingos->ordersentence[d.seq].id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_id = reqinfo->updt_id,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_task = reqinfo->updt_task, lt
    .updt_applctx = reqinfo->updt_applctx,
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].comment > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into long_text")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addingoscnt)
   SET pw.iv_comp_syn_id = tempaddingos->ordersentence[d.seq].synonymid, pw.order_sentence_id =
    tempaddingos->ordersentence[d.seq].id, pw.order_sentence_seq = 0,
    pw.os_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddingos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].id > 0))
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into pw_comp_os_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addosdetcnt > 0)
  DELETE  FROM order_sentence_detail osd,
    (dummyt d  WITH seq = addosdetcnt)
   SET osd.seq = 1
   PLAN (d)
    JOIN (osd
    WHERE (osd.order_sentence_id=tempaddosdet->fielddetail[d.seq].sentenceid))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from order_sentence_detail")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  INSERT  FROM order_sentence_detail osd,
    (dummyt d  WITH seq = addosdetcnt)
   SET osd.default_parent_entity_name =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) ""
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 9))) "CODE_VALUE"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (12)))
     IF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=48)) "RESEARCH_ACCOUNT"
     ELSEIF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=123)) "SCH_BOOK_INSTR"
     ELSE "CODE_VALUE"
     ENDIF
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (8, 13))) "PERSON"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (10))) "NOMENCLATURE"
    ENDIF
    , osd.default_parent_entity_id =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) 0
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 8, 9, 10, 12,
    13))) tempaddosdet->fielddetail[d.seq].value
    ENDIF
    , osd.field_type_flag = tempaddosdet->fielddetail[d.seq].field_type_flag,
    osd.oe_field_display_value = tempaddosdet->fielddetail[d.seq].display, osd.oe_field_id =
    tempaddosdet->fielddetail[d.seq].oef_id, osd.oe_field_meaning_id = tempaddosdet->fielddetail[d
    .seq].oe_field_meaning_id,
    osd.oe_field_value =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) tempaddosdet->fielddetail[d.seq].value
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 8, 9, 10, 12,
    13))) 0
    ENDIF
    , osd.order_sentence_id = tempaddosdet->fielddetail[d.seq].sentenceid, osd.sequence =
    tempaddosdet->fielddetail[d.seq].sequence,
    osd.updt_id = reqinfo->updt_id, osd.updt_dt_tm = cnvtdatetime(curdate,curtime3), osd.updt_task =
    reqinfo->updt_task,
    osd.updt_applctx = reqinfo->updt_applctx, osd.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosdet->fielddetail[d.seq].oef_id > 0))
    JOIN (osd)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence_detail")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updoscnt > 0)
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = updoscnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempupdos->ordersentence[d.seq].
    comment, lt.long_text_id = seq(long_data_seq,nextval),
    lt.parent_entity_id = tempupdos->ordersentence[d.seq].order_sentence_id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_task = reqinfo->updt_task,
    lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempupdos->ordersentence[d.seq].commentid=0)
     AND (tempupdos->ordersentence[d.seq].comment > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into long_text")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM long_text lt,
    (dummyt d  WITH seq = updoscnt)
   PLAN (d
    WHERE (tempupdos->ordersentence[d.seq].commentid=0)
     AND (tempupdos->ordersentence[d.seq].comment > " "))
    JOIN (lt
    WHERE (lt.parent_entity_id=tempupdos->ordersentence[d.seq].order_sentence_id)
     AND lt.parent_entity_name="ORDER_SENTENCE")
   DETAIL
    tempupdos->ordersentence[d.seq].commentid = lt.long_text_id
   WITH nocounter
  ;end select
  UPDATE  FROM order_sentence os,
    (dummyt d  WITH seq = updoscnt)
   SET os.ord_comment_long_text_id = tempupdos->ordersentence[d.seq].commentid, os
    .order_sentence_display_line = tempupdos->ordersentence[d.seq].order_sentence_display_line, os
    .updt_id = reqinfo->updt_id,
    os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task = reqinfo->updt_task, os
    .updt_applctx = reqinfo->updt_applctx,
    os.updt_cnt = (os.updt_cnt+ 1), os.rx_type_mean = tempupdos->ordersentence[d.seq].rx_type_mean
   PLAN (d)
    JOIN (os
    WHERE (os.order_sentence_id=tempupdos->ordersentence[d.seq].order_sentence_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = updoscnt)
   SET pw.os_display_line = tempupdos->ordersentence[d.seq].order_sentence_display_line, pw
    .order_sentence_seq = tempupdos->ordersentence[d.seq].sequence, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = (pw.updt_cnt+ 1)
   PLAN (d)
    JOIN (pw
    WHERE (pw.order_sentence_id=tempupdos->ordersentence[d.seq].order_sentence_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into pw_comp_os_reltn")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (addosfiltercnt > 0)
  INSERT  FROM order_sentence_filter f,
    (dummyt d  WITH seq = addosfiltercnt)
   SET f.order_sentence_filter_id = tempaddosfilter->filters[d.seq].order_sentence_filter_id, f
    .order_sentence_id = tempaddosfilter->filters[d.seq].sentence_id, f.age_max_value =
    tempaddosfilter->filters[d.seq].age_max_value,
    f.age_min_value = tempaddosfilter->filters[d.seq].age_min_value, f.age_unit_cd = tempaddosfilter
    ->filters[d.seq].age_code_value, f.pma_max_value = tempaddosfilter->filters[d.seq].pma_max_value,
    f.pma_min_value = tempaddosfilter->filters[d.seq].pma_min_value, f.pma_unit_cd = tempaddosfilter
    ->filters[d.seq].pma_code_value, f.weight_max_value = tempaddosfilter->filters[d.seq].
    weight_max_value,
    f.weight_min_value = tempaddosfilter->filters[d.seq].weight_min_value, f.weight_unit_cd =
    tempaddosfilter->filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
    f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_task = reqinfo->updt_task, f.updt_applctx
     = reqinfo->updt_applctx,
    f.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosfilter->filters[d.seq].order_sentence_filter_id > 0))
    JOIN (f)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updosfiltercnt > 0)
  UPDATE  FROM order_sentence_filter f,
    (dummyt d  WITH seq = updosfiltercnt)
   SET f.age_max_value = tempupdosfilter->filters[d.seq].age_max_value, f.age_min_value =
    tempupdosfilter->filters[d.seq].age_min_value, f.age_unit_cd = tempupdosfilter->filters[d.seq].
    age_code_value,
    f.pma_max_value = tempupdosfilter->filters[d.seq].pma_max_value, f.pma_min_value =
    tempupdosfilter->filters[d.seq].pma_min_value, f.pma_unit_cd = tempupdosfilter->filters[d.seq].
    pma_code_value,
    f.weight_max_value = tempupdosfilter->filters[d.seq].weight_max_value, f.weight_min_value =
    tempupdosfilter->filters[d.seq].weight_min_value, f.weight_unit_cd = tempupdosfilter->filters[d
    .seq].weight_code_value,
    f.updt_id = reqinfo->updt_id, f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_task =
    reqinfo->updt_task,
    f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = (f.updt_cnt+ 1)
   PLAN (d
    WHERE (tempupdosfilter->filters[d.seq].order_sentence_filter_id > 0))
    JOIN (f
    WHERE (f.order_sentence_filter_id=tempupdosfilter->filters[d.seq].order_sentence_filter_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error updating into order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delosfiltercnt > 0)
  DELETE  FROM order_sentence_filter f,
    (dummyt d  WITH seq = delosfiltercnt)
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.order_sentence_filter_id=tempdelosfilter->filters[d.seq].order_sentence_filter_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
