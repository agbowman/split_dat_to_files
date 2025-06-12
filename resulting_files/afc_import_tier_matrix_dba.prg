CREATE PROGRAM afc_import_tier_matrix:dba
 SET safcimportvrsn = "486499.006"
 FREE RECORD addtierrequest
 RECORD addtierrequest(
   1 tier_matrix_qual = i2
   1 tier_matrix[*]
     2 tier_cell_id = f8
     2 tier_group_cd = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_value_ind = i2
     2 tier_cell_value = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tier_cell_entity_name = vc
     2 tier_cell_string = c50
 )
 FREE RECORD addtierreply
 RECORD addtierreply(
   1 tier_matrix_qual = i4
   1 tier_matrix[10]
     2 tier_cell_id = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
   1 status_data = f8
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD codecache(
   1 qual[*]
     2 dcode = f8
     2 sdisplay = vc
     2 sdescription = vc
     2 smeaning = vc
 )
 DECLARE safcimportvrsn = vc
 DECLARE lnumrows = i4 WITH public, noconstant(0)
 DECLARE lstartidx = i4 WITH public, noconstant(0)
 DECLARE istat = i2 WITH public, noconstant(0)
 DECLARE isuccessfuldelete = i2 WITH public, noconstant(0)
 DECLARE stmpstring = vc WITH public, noconstant("")
 DECLARE inorecords = i2 WITH public, noconstant(0)
 DECLARE rvar = i2 WITH public, noconstant(0)
 DECLARE dtdeletedate = f8 WITH public, noconstant(0.0)
 DECLARE dcurtiercelltypecd = f8 WITH public, noconstant(0.0)
 DECLARE scurtiercellentityname = vc WITH public, noconstant("")
 DECLARE dcurtiergroupcd = f8 WITH public, noconstant(0.0)
 DECLARE lcurtiercellcol = i4 WITH public, noconstant(0)
 DECLARE lcurtiercellrow = i4 WITH public, noconstant(0)
 DECLARE lcurtiercellidx = i4 WITH public, noconstant(0)
 DECLARE dcurtiercellvalue = f8 WITH public, noconstant(0.0)
 DECLARE scurtiercellstring = vc WITH public, noconstant("")
 DECLARE dcurtierbegeffdttm = f8 WITH public
 DECLARE dcurtierendeffdttm = f8 WITH public
 DECLARE lappid = i4 WITH public, noconstant(0)
 DECLARE ltaskid = i4 WITH public, noconstant(0)
 DECLARE lreqid = i4 WITH public, noconstant(0)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hrequest = i4 WITH public, noconstant(0)
 DECLARE hreply = i4 WITH public, noconstant(0)
 DECLARE hlist = i4 WITH public, noconstant(0)
 DECLARE sstatus = c1 WITH public, noconstant("")
 DECLARE lcodeset = i4 WITH public, noconstant(0)
 DECLARE lcodecachecnt = i4 WITH public, noconstant(0)
 DECLARE ierrorind = i2 WITH public, noconstant(0)
 DECLARE dtiercellactivtypecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercelladdoncd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellbillcodecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcdmschedcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellchargeproccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellclientrpttypecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcolprioritycd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcostcentercd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcpt4cd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcheckdiagcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellfinclasscd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellflatdiscntcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellgenledgercd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellhcpcscd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellhealthplancd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellholdsuspensecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellicd9cd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellinstfinnbrcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellinterfacefilecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercelllistpriceschedcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcpt4modcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellproviderspccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellordloccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellorgcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellpatloccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellperfloccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcheckphyscd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellpriceschedcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellprioritycd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellicd9proccd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellrevenuecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellrptprioritycd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellseperatorcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellserviceresourcecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellsnomedcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercelladmittypecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellactivsubtypecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellphysordercd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellphysordergroupcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellphysrendercd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellphysrendergroupcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellmedservicecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellencountertypecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellinsorganizationcd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcpt4modvaluecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcoveragecd = f8 WITH public, noconstant(0.0)
 DECLARE action_begin = i4 WITH public, noconstant(0)
 DECLARE action_end = i4 WITH public, noconstant(0)
 DECLARE logdata(sstringmsg=vc,sfileaction=vc) = i2
 DECLARE populatetiermatrixrequest(lidx=i4) = i2
 DECLARE addtiermatrix(ifoo=i2) = i2
 DECLARE populatetiercelltypes(ifoo=i2) = i2
 DECLARE deleteexistingtiergroup(dgroupcd=f8) = i2
 DECLARE callcodecache(ifoo=i2) = i2
 DECLARE determinecurrentcol(dcd=f8) = i4
 SET istat = populatetiercelltypes(0)
 SET istat = callcodecache(0)
 SET lnumrows = size(requestin->list_0,5)
 SET lstartidx = 1
 SET action_begin = 1
 SET istat = logdata("","OPEN")
 SET dcurtiergroupcd = 0.0
 WHILE (lstartidx <= lnumrows)
   SET curalias tm requestin->list_0[lstartidx]
   IF (lstartidx > 1)
    SET curalias tm_prev requestin->list_0[(lstartidx - 1)]
   ENDIF
   IF (dcurtiergroupcd != cnvtreal(tm->tier_group_cd))
    IF (dcurtiergroupcd != 0.0)
     SET istat = logdata(tm_prev->tier_group,"ENDTIER")
    ENDIF
    SET istat = logdata(tm->tier_group,"STARTNEWTIER")
    SET lcurtiercellrow = cnvtint(tm->tgr)
    IF (lcurtiercellrow=1)
     SET istat = deleteexistingtiergroup(cnvtreal(tm->tier_group_cd))
     IF (istat=false
      AND inorecords=false)
      SET stmpstring = build("!! Experienced error deleting matrix : ",cnvtreal(tm->tier_group_cd))
      SET istat = logdata(stmpstring,"APPEND")
      SET isuccessfuldelete = false
     ELSEIF (istat=false
      AND inorecords=true)
      SET stmpstring = build("!! There was no data to delete for matrix : ",cnvtreal(tm->
        tier_group_cd))
      SET istat = logdata(stmpstring,"APPEND")
      SET isuccessfuldelete = true
     ELSE
      SET stmpstring = build("!! Successful delete of  matrix : ",cnvtreal(tm->tier_group_cd))
      SET istat = logdata(stmpstring,"APPEND")
      SET isuccessfuldelete = true
     ENDIF
    ENDIF
   ENDIF
   SET dcurtiergroupcd = cnvtreal(tm->tier_group_cd)
   SET dcurtierbegeffdttm = cnvtdatetime(tm->begin_date)
   SET dcurtierendeffdttm = cnvtdatetime(tm->end_date)
   SET lcurtiercellrow = cnvtint(tm->tgr)
   SET lcurtiercellcol = 0
   SET dcurtiercellvalue = 0.0
   SET scurtiercellstring = ""
   SET dcurtiercelltypecd = dtiercellfinclasscd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->financial_class_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercelladmittypecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->admit_type_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellorgcd
   SET scurtiercellentityname = "ORGANIZATION"
   SET dcurtiercellvalue = cnvtreal(tm->organization_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellordloccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->order_location_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellserviceresourcecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->service_resource_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellrptprioritycd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->report_priority_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellpatloccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->patient_location_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcolprioritycd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->collection_priority_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellperfloccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->performing_location_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellactivtypecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->activity_type_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellactivsubtypecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->activity_sub_type_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellhealthplancd
   SET scurtiercellentityname = "HEALTH_PLAN"
   SET dcurtiercellvalue = cnvtreal(tm->health_plan_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellprioritycd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->priority_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellphysordercd
   SET scurtiercellentityname = "PRSNL"
   SET dcurtiercellvalue = cnvtreal(tm->order_physician_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellphysordergroupcd
   SET scurtiercellentityname = "PRSNL_GROUP"
   SET dcurtiercellvalue = cnvtreal(tm->order_physician_grp_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellphysrendercd
   SET scurtiercellentityname = "PRSNL"
   SET dcurtiercellvalue = cnvtreal(tm->render_physician_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellphysrendergroupcd
   SET scurtiercellentityname = "PRSNL_GROUP"
   SET dcurtiercellvalue = cnvtreal(tm->render_physician_grp_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellmedservicecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->med_service_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellencountertypecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->encounter_type_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellinsorganizationcd
   SET scurtiercellentityname = "ORGANIZATION"
   SET dcurtiercellvalue = cnvtreal(tm->insurance_org_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcpt4modvaluecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->cpt4_modifier_value_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellproviderspccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->provider_specialty_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellchargeproccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->charge_processing_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellpriceschedcd
   SET scurtiercellentityname = "PRICE_SCHED"
   SET dcurtiercellvalue = cnvtreal(tm->price_schedule_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercelllistpriceschedcd
   SET scurtiercellentityname = "PRICE_SCHED"
   SET dcurtiercellvalue = cnvtreal(tm->list_price_schedule_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcdmschedcd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->cdm_schedule_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcpt4cd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->cpt4_code_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcpt4modcd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->cpt4_modifier_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellsnomedcd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->snomed_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellhcpcscd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->hcpcs_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellicd9cd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->icd9_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellicd9proccd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->icd9_procedure_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellrevenuecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->revenue_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellholdsuspensecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->hold_suspense_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellgenledgercd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->general_ledger_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcheckdiagcd
   SET scurtiercellentityname = ""
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF ((tm->check_diagnosis IN ("Y", "y")))
    SET dcurtiercellvalue = 1.0
   ELSE
    SET dcurtiercellvalue = 0.0
   ENDIF
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcheckphyscd
   SET scurtiercellentityname = ""
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF ((tm->check_physician IN ("Y", "y")))
    SET dcurtiercellvalue = 1.0
   ELSE
    SET dcurtiercellvalue = 0.0
   ENDIF
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcostcentercd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->cost_center_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellflatdiscntcd
   SET scurtiercellentityname = ""
   SET dcurtiercellvalue = cnvtreal(tm->flat_discount)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercelladdoncd
   SET scurtiercellentityname = "BILL_ITEM"
   SET dcurtiercellvalue = cnvtreal(tm->add_on_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellinterfacefilecd
   SET scurtiercellentityname = "INTERFACE_FILE"
   SET dcurtiercellvalue = cnvtreal(tm->interface_file_id)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellinstfinnbrcd
   SET scurtiercellentityname = ""
   SET scurtiercellstring = cnvtstring(tm->institutional_fin)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND scurtiercellstring != "")
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellclientrpttypecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->client_report_type_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET dcurtiercelltypecd = dtiercellcoveragecd
   SET scurtiercellentityname = "CODE_VALUE"
   SET dcurtiercellvalue = cnvtreal(tm->coverage_cd)
   SET lcurtiercellcol = determinecurrentcol(dcurtiercelltypecd)
   IF (lcurtiercellcol > 0
    AND dcurtiercellvalue > 0.0)
    SET lcurtiercellidx = (lcurtiercellidx+ 1)
    SET istat = populatetiermatrixrequest(lcurtiercellidx)
   ENDIF
   SET action_end = addtierrequest->tier_matrix_qual
   SET istat = addtiermatrix(0)
   IF (istat=false)
    SET stmpstring = build("!!! Experienced an error adding tier matrix: ",trim(tm->tier_group),
     " Row: ",lcurtiercellrow)
    SET istat = logdata(stmpstring,"APPEND")
   ELSE
    SET stmpstring = build("!!! Successfully added tier matrix: ",trim(tm->tier_group)," Row: ",
     lcurtiercellrow)
    SET istat = logdata(stmpstring,"APPEND")
   ENDIF
   SET lstartidx = (lstartidx+ 1)
   SET lcurtiercellcol = 0
   SET lcurtiercellidx = 0
   SET addtierrequest->tier_matrix_qual = 0
   SET stat = alterlist(addtierrequest->tier_matrix,0)
   SET addtierrequest->tier_matrix_qual = 0
   SET curalias tm off
 ENDWHILE
 SET istat = logdata("","CLOSE")
 GO TO end_program
 SUBROUTINE logdata(smsg,saction)
   CASE (saction)
    OF "OPEN":
     SET rvar = 0
     SELECT INTO "afc_import_tier_matrix.log"
      rvar
      HEAD REPORT
       col + 1, "**AFC Tier Matrix Import**      - Starting   ", curdate"dd-mmm-yyyy;;d",
       "-", curtime"hh:mm;;m"
      DETAIL
       col 0
      WITH nocounter, format = variable, noformfeed,
       maxcol = 132, maxrow = 1
     ;end select
    OF "CLOSE":
     SELECT INTO "afc_import_tier_matrix.log"
      rvar
      HEAD REPORT
       row + 1, col + 1, "**AFC Tier Matrix Import**      - Ending   ",
       curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m"
      DETAIL
       col 0
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
    OF "APPEND":
     SELECT INTO "afc_import_tier_matrix.log"
      rvar
      HEAD REPORT
       sinfo1 = trim(smsg)
      DETAIL
       row, col 0, sinfo1
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
    OF "STARTNEWTIER":
     SELECT INTO "afc_import_tier_matrix.log"
      rvar
      HEAD REPORT
       sinfo1 = trim(smsg)
      DETAIL
       row + 2, col 0, "*********Starting New Tier: ",
       sinfo1
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
    OF "ENDTIER":
     SELECT INTO "afc_import_tier_matrix.log"
      rvar
      HEAD REPORT
       sinfo1 = trim(smsg)
      DETAIL
       row, col 0, "*********Finished with Tier: ",
       sinfo1, row + 1
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
     RETURN(true)
   ENDCASE
 END ;Subroutine
 SUBROUTINE populatetiermatrixrequest(idx)
   SET stat = alterlist(addtierrequest->tier_matrix,(addtierrequest->tier_matrix_qual+ 1))
   SET addtierrequest->tier_matrix[idx].tier_group_cd = dcurtiergroupcd
   SET addtierrequest->tier_matrix[idx].tier_col_num = lcurtiercellcol
   SET addtierrequest->tier_matrix[idx].tier_row_num = lcurtiercellrow
   SET addtierrequest->tier_matrix[idx].tier_cell_type_cd = dcurtiercelltypecd
   SET addtierrequest->tier_matrix[idx].tier_cell_entity_name = scurtiercellentityname
   SET addtierrequest->tier_matrix[idx].tier_cell_string = scurtiercellstring
   SET addtierrequest->tier_matrix[idx].tier_cell_value = dcurtiercellvalue
   SET addtierrequest->tier_matrix[idx].beg_effective_dt_tm = dcurtierbegeffdttm
   SET addtierrequest->tier_matrix[idx].end_effective_dt_tm = dcurtierendeffdttm
   SET addtierrequest->tier_matrix[idx].active_ind_ind = false
   SET addtierrequest->tier_matrix[idx].active_ind = 1
   SET addtierrequest->tier_matrix[idx].active_status_cd = 0.0
   SET addtierrequest->tier_matrix_qual = (addtierrequest->tier_matrix_qual+ 1)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE addtiermatrix(foo)
   SET stmpstring = build("!! About to add row to tier matrix.  Row #: ",lstartidx)
   SET istat = logdata(stmpstring,"APPEND")
   EXECUTE afc_add_tier_matrix  WITH replace("REQUEST",addtierrequest), replace("REPLY",addtierreply)
   IF ((addtierreply->status_data.status IN ("F", "Z")))
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE populatetiercelltypes(foo)
   SET stat = uar_get_meaning_by_codeset(13036,"ACTCODE",1,dtiercellactivtypecd)
   SET stat = uar_get_meaning_by_codeset(13036,"ADD ON",1,dtiercelladdoncd)
   SET stat = uar_get_meaning_by_codeset(13036,"BILLCODE",1,dtiercellbillcodecd)
   SET stat = uar_get_meaning_by_codeset(13036,"CDM_SCHED",1,dtiercellcdmschedcd)
   SET stat = uar_get_meaning_by_codeset(13036,"CHARGE POINT",1,dtiercellchargeproccd)
   SET stat = uar_get_meaning_by_codeset(13036,"CLNTRPTTYPE",1,dtiercellclientrpttypecd)
   SET stat = uar_get_meaning_by_codeset(13036,"COL PRIORITY",1,dtiercellcolprioritycd)
   SET stat = uar_get_meaning_by_codeset(13036,"COSTCENTER",1,dtiercellcostcentercd)
   SET stat = uar_get_meaning_by_codeset(13036,"CPT4",1,dtiercellcpt4cd)
   SET stat = uar_get_meaning_by_codeset(13036,"DIAGREQD",1,dtiercellcheckdiagcd)
   SET stat = uar_get_meaning_by_codeset(13036,"FIN CLASS",1,dtiercellfinclasscd)
   SET stat = uar_get_meaning_by_codeset(13036,"FLAT_DISC",1,dtiercellflatdiscntcd)
   SET stat = uar_get_meaning_by_codeset(13036,"GL",1,dtiercellgenledgercd)
   SET stat = uar_get_meaning_by_codeset(13036,"HCPCS",1,dtiercellhcpcscd)
   SET stat = uar_get_meaning_by_codeset(13036,"HEALTHPLAN",1,dtiercellhealthplancd)
   SET stat = uar_get_meaning_by_codeset(13036,"HOLD_SUSP",1,dtiercellholdsuspensecd)
   SET stat = uar_get_meaning_by_codeset(13036,"ICD9",1,dtiercellicd9cd)
   SET stat = uar_get_meaning_by_codeset(13036,"INSTFINNBR",1,dtiercellinstfinnbrcd)
   SET stat = uar_get_meaning_by_codeset(13036,"INTERFACE",1,dtiercellinterfacefilecd)
   SET stat = uar_get_meaning_by_codeset(13036,"LPRICESCHED",1,dtiercelllistpriceschedcd)
   SET stat = uar_get_meaning_by_codeset(13036,"MODIFIER",1,dtiercellcpt4modcd)
   SET stat = uar_get_meaning_by_codeset(13036,"PROVIDERSPC",1,dtiercellproviderspccd)
   SET stat = uar_get_meaning_by_codeset(13036,"ORD LOC",1,dtiercellordloccd)
   SET stat = uar_get_meaning_by_codeset(13036,"ORG",1,dtiercellorgcd)
   SET stat = uar_get_meaning_by_codeset(13036,"PAT LOC",1,dtiercellpatloccd)
   SET stat = uar_get_meaning_by_codeset(13036,"PERF LOC",1,dtiercellperfloccd)
   SET stat = uar_get_meaning_by_codeset(13036,"PHYSREQD",1,dtiercellcheckphyscd)
   SET stat = uar_get_meaning_by_codeset(13036,"PRICESCHED",1,dtiercellpriceschedcd)
   SET stat = uar_get_meaning_by_codeset(13036,"PRIORITY",1,dtiercellprioritycd)
   SET stat = uar_get_meaning_by_codeset(13036,"PROCCODE",1,dtiercellicd9proccd)
   SET stat = uar_get_meaning_by_codeset(13036,"REVENUE",1,dtiercellrevenuecd)
   SET stat = uar_get_meaning_by_codeset(13036,"RPT PRIORITY",1,dtiercellrptprioritycd)
   SET stat = uar_get_meaning_by_codeset(13036,"SEPERATOR",1,dtiercellseperatorcd)
   SET stat = uar_get_meaning_by_codeset(13036,"SERVICERES",1,dtiercellserviceresourcecd)
   SET stat = uar_get_meaning_by_codeset(13036,"SNM195",1,dtiercellsnomedcd)
   SET stat = uar_get_meaning_by_codeset(13036,"VISITTYPE",1,dtiercelladmittypecd)
   SET stat = uar_get_meaning_by_codeset(13036,"ACTSUBCODE",1,dtiercellactivsubtypecd)
   SET stat = uar_get_meaning_by_codeset(13036,"ORDERINGPHYS",1,dtiercellphysordercd)
   SET stat = uar_get_meaning_by_codeset(13036,"ORDERPHYSGRP",1,dtiercellphysordergroupcd)
   SET stat = uar_get_meaning_by_codeset(13036,"RENDERINGPHY",1,dtiercellphysrendercd)
   SET stat = uar_get_meaning_by_codeset(13036,"RENDPHYSGRP",1,dtiercellphysrendergroupcd)
   SET stat = uar_get_meaning_by_codeset(13036,"MEDSERVICE",1,dtiercellmedservicecd)
   SET stat = uar_get_meaning_by_codeset(13036,"ENCNTRTYPCLS",1,dtiercellencountertypecd)
   SET stat = uar_get_meaning_by_codeset(13036,"INSURANCEORG",1,dtiercellinsorganizationcd)
   SET stat = uar_get_meaning_by_codeset(13036,"CPT MODIFIER",1,dtiercellcpt4modvaluecd)
   SET stat = uar_get_meaning_by_codeset(13036,"COVERAGE",1,dtiercellcoveragecd)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE deleteexistingtiergroup(dgroupcd)
   DECLARE ltmpreccnt = i4
   SET ltmpreccnt = 0
   SET inorecords = false
   SELECT INTO "nl:"
    FROM tier_matrix tm
    WHERE tm.tier_group_cd=dgroupcd
     AND tm.active_ind=1
     AND tm.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    DETAIL
     ltmpreccnt = (ltmpreccnt+ 1)
    WITH nocounter
   ;end select
   IF (ltmpreccnt=0)
    SET inorecords = true
    RETURN(false)
   ENDIF
   DELETE  FROM tier_matrix tm
    WHERE tm.tier_group_cd=dgroupcd
     AND tm.active_ind=outerjoin(1)
     AND tm.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    WITH nocounter
   ;end delete
   IF (curqual=0
    AND ltmpreccnt > 0)
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE callcodecache(foo)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13036
    AND cv.collation_seq > 0
    AND cv.active_ind=1
   ORDER BY cv.collation_seq
   DETAIL
    lcodecachecnt = (lcodecachecnt+ 1), stat = alterlist(codecache->qual,lcodecachecnt), codecache->
    qual[lcodecachecnt].dcode = cv.code_value,
    codecache->qual[lcodecachecnt].sdisplay = cv.display, codecache->qual[lcodecachecnt].sdescription
     = cv.description, codecache->qual[lcodecachecnt].smeaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  IF (lcodecachecnt > 0)
   RETURN(true)
  ELSE
   RETURN(false)
  ENDIF
 END ;Subroutine
 SUBROUTINE determinecurrentcol(dcd)
   DECLARE ltmpcol = i4
   SET ltmpcol = 0
   FOR (idx = 1 TO lcodecachecnt)
     IF ((codecache->qual[idx].dcode=dcd))
      SET ltmpcol = idx
      SET idx = (lcodecachecnt+ 1)
     ENDIF
   ENDFOR
   RETURN(ltmpcol)
 END ;Subroutine
#end_program
 FREE RECORD addtierrequest
 FREE RECORD addtierreply
 FREE RECORD codecache
END GO
