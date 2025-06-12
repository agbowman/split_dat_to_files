CREATE PROGRAM afc_hl7_realtime_interface:dba
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE afc_hl7_realtime_interface_version = vc
 SET afc_hl7_realtime_interface_version = "398062.FT.019"
 DECLARE messageid = i4
 DECLARE reqmessageid = i4
 DECLARE cleanup_srv_stuff(dummy1) = i2
 RECORD recdate(
   1 datetime = dq8
 )
 RECORD rqin(
   1 message
     2 cqminfo
       3 appname = vc
       3 contribalias = vc
       3 contribrefnum = vc
       3 contribdttm = dq8
       3 priority = i4
       3 class = vc
       3 type = vc
       3 subtype = vc
       3 subtype_detail = vc
       3 debug_ind = i4
       3 verbosity_flag = i4
     2 esoinfo
       3 scriptcontrolval = i4
       3 scriptcontrolargs = vc
       3 dbnullprefix = vc
       3 aliasprefix = vc
       3 codeprefix = vc
       3 personprefix = vc
       3 eprsnlprefix = vc
       3 prsnlprefix = vc
       3 orderprefix = vc
       3 orgprefix = vc
       3 hlthplanprefix = vc
       3 nomenprefix = vc
       3 itemprefix = vc
       3 longlist[*]
         4 lval = i4
         4 strmeaning = vc
       3 stringlist[*]
         4 strval = vc
         4 strmeaning = vc
       3 doublelist[*]
         4 dval = f8
         4 strmeaning = vc
       3 sendobjectind = c1
     2 triginfo
       3 charge_seq = i4
       3 charge_total = i4
       3 send_dt_tm = dq8
       3 charge_info[*]
         4 interface_charge_id = f8
         4 order_dept = i4
         4 interface_file_id = f8
         4 charge_item_id = f8
         4 batch_num = f8
         4 bill_code1 = c50
         4 bill_code1_desc = c200
         4 bill_code2 = c50
         4 bill_code2_desc = c200
         4 bill_code3 = c50
         4 bill_code3_desc = c200
         4 prim_cdm = c50
         4 prim_cpt = c50
         4 diag_code1 = c50
         4 diag_code2 = c50
         4 diag_code3 = c50
         4 person_name = c100
         4 person_id = f8
         4 encntr_id = f8
         4 fin_nbr = c50
         4 med_nbr = c50
         4 service_dt_tm = dq8
         4 section_cd = f8
         4 encntr_type_cd = f8
         4 payor_id = f8
         4 quantity = f8
         4 price = f8
         4 net_ext_price = f8
         4 organization_id = f8
         4 institution_cd = f8
         4 department_cd = f8
         4 subsection_cd = f8
         4 level5_cd = f8
         4 facility_cd = f8
         4 building_cd = f8
         4 nurse_unit_cd = f8
         4 room_cd = f8
         4 bed_cd = f8
         4 referring_phys_id = f8
         4 ord_phys_id = f8
         4 ord_doc_nbr = c20
         4 adm_phys_id = f8
         4 attending_phys_id = f8
         4 additional_encntr_phys1_id = f8
         4 additional_encntr_phys2_id = f8
         4 additional_encntr_phys3_id = f8
         4 charge_type_cd = f8
         4 updt_cnt = i4
         4 updt_dt_tm = dq8
         4 updt_id = f8
         4 updt_task = i4
         4 updt_applctx = i4
         4 active_ind = i2
         4 active_status_cd = f8
         4 active_status_prsnl_id = f8
         4 active_status_dt_tm = dq8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 abn_status_cd = f8
         4 activity_type_cd = f8
         4 admit_type_cd = f8
         4 bill_code_more_ind = i2
         4 bill_code_type_cdf = c12
         4 code_modifier1_cd = f8
         4 code_modifier2_cd = f8
         4 code_modifier3_cd = f8
         4 code_modifier_more_ind = i2
         4 cost_center_cd = f8
         4 diag_desc1 = c200
         4 diag_desc2 = c200
         4 diag_desc3 = c200
         4 diag_more_ind = i2
         4 discount_amount = f8
         4 fin_nbr_type_flg = i4
         4 gross_price = f8
         4 icd9_proc_more_ind = i2
         4 manual_ind = i2
         4 med_service_cd = f8
         4 order_nbr = c200
         4 override_desc = c200
         4 perf_loc_cd = f8
         4 perf_phys_id = f8
         4 posted_dt_tm = dq8
         4 prim_cdm_desc = c200
         4 prim_cpt_desc = c200
         4 prim_icd9_proc = c50
         4 prim_icd9_proc_desc = c200
         4 process_flg = i4
         4 user_def_ind = i2
   1 params[*]
 )
 RECORD rpout(
   1 sb
     2 severity_cd = i4
     2 status_cd = i4
     2 status_text = vc
 )
 FREE RECORD srvrec
 RECORD srvrec(
   1 qual[*]
     2 msg_id = i4
     2 hmsg = i4
     2 hreq = i4
     2 hrep = i4
     2 status = i4
 )
 CALL echo("executing afc_hl7_realtime_interface...")
 CALL echo(build("number of charges: ",value(size(reply->interface_charge,5))))
 DECLARE init_srv_stuff(messageid,get_hreq,get_hrep) = i2
 DECLARE cleanup_srv_stuff(dummy1) = i2
 DECLARE hmsgtype = i4
 DECLARE hmsgstruct = i4
 DECLARE hcqmstruct = i4
 DECLARE htrigitem = i4
 DECLARE hchargeitem = i4
 DECLARE cqmmessageid = i4
 DECLARE trigmessageid = i4
 DECLARE queueid = f8 WITH noconstant(0.0)
 DECLARE uar_siscriptesocompdttrig(p1=i4(value),p2=f8(ref)) = i4 WITH uar = "SiScriptEsoCompDtTrig",
 image_axp = "si_esocallsrtl", image_aix = "libsi_esocallsrtl.a(libsi_esocallsrtl.o)"
 SET cqmmessageid = 1215001
 SET reqmessageid = 1215015
 SET number_of_charges = value(size(reply->interface_charge,5))
 IF ((validate(reply->interface_charge.interface_charge_id,- (999)) != - (999)))
  FOR (loop_count = 1 TO number_of_charges)
    CALL init_srv_stuff(cqmmessageid,1,1)
    CALL init_srv_stuff(reqmessageid,1,1)
    SET hmsgtype = uar_srvcreaterequesttype(srvrec->qual[2].hmsg)
    SET stat = uar_srvrecreateinstance(srvrec->qual[1].hreq,hmsgtype)
    SET hmsgstruct = uar_srvgetstruct(srvrec->qual[1].hreq,"message")
    IF (hmsgstruct)
     SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"cqminfo")
     SET encntr_id = reply->interface_charge[loop_count].encntr_id
     IF (hcqmstruct)
      SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
      SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("CS_BATCH_CHARGE"))
      SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat("E",cnvtstring(encntr_id,
          17))))
      SET recdate->datetime = cnvtdatetime(curdate,curtime)
      SET stat = uar_srvsetdate2(hcqmstruct,"contribdttm",recdate)
      SET stat = uar_srvsetlong(hcqmstruct,"priority",99)
      SET stat = uar_srvsetstring(hcqmstruct,"class",nullterm("CHARGE_RT"))
      SET stat = uar_srvsetstring(hcqmstruct,"type",nullterm("FT1"))
      SET stat = uar_srvsetstring(hcqmstruct,"subtype",nullterm("DETAIL"))
      SET stat = uar_srvsetstring(hcqmstruct,"subtype_detail",nullterm(cnvtstring(reply->
         interface_charge[loop_count].person_id,17)))
      SET stat = uar_srvsetlong(hcqmstruct,"debug_ind",0)
      SET stat = uar_srvsetlong(hcqmstruct,"verbosity_flag",0)
      SET htrigitem = uar_srvgetstruct(hmsgstruct,"TRIGInfo")
      IF (htrigitem)
       SET hchargeitem = uar_srvadditem(htrigitem,"charge_info")
       IF (hchargeitem)
        SET stat = uar_srvsetdouble(hchargeitem,"interface_charge_id",reply->interface_charge[
         loop_count].interface_charge_id)
        SET stat = uar_srvsetlong(hchargeitem,"order_dept",reply->interface_charge[loop_count].
         order_dept)
        SET stat = uar_srvsetdouble(hchargeitem,"interface_file_id",reply->interface_charge[
         loop_count].interface_file_id)
        SET stat = uar_srvsetdouble(hchargeitem,"charge_item_id",reply->interface_charge[loop_count].
         charge_item_id)
        SET stat = uar_srvsetdouble(hchargeitem,"batch_num",reply->interface_charge[loop_count].
         batch_num)
        SET stat = uar_srvsetstring(hchargeitem,"bill_code1",nullterm(reply->interface_charge[
          loop_count].bill_code1))
        SET stat = uar_srvsetstring(hchargeitem,"bill_code1_desc",nullterm(reply->interface_charge[
          loop_count].bill_code1_desc))
        SET stat = uar_srvsetstring(hchargeitem,"bill_code2",nullterm(reply->interface_charge[
          loop_count].bill_code2))
        SET stat = uar_srvsetstring(hchargeitem,"bill_code2_desc",nullterm(reply->interface_charge[
          loop_count].bill_code2_desc))
        SET stat = uar_srvsetstring(hchargeitem,"bill_code3",nullterm(reply->interface_charge[
          loop_count].bill_code3))
        SET stat = uar_srvsetstring(hchargeitem,"bill_code3_desc",nullterm(reply->interface_charge[
          loop_count].bill_code3_desc))
        SET stat = uar_srvsetstring(hchargeitem,"prim_cpt",nullterm(reply->interface_charge[
          loop_count].prim_cpt))
        SET stat = uar_srvsetstring(hchargeitem,"prim_cdm",nullterm(reply->interface_charge[
          loop_count].prim_cdm))
        SET stat = uar_srvsetstring(hchargeitem,"diag_code1",nullterm(reply->interface_charge[
          loop_count].diag_code1))
        SET stat = uar_srvsetstring(hchargeitem,"diag_code2",nullterm(reply->interface_charge[
          loop_count].diag_code2))
        SET stat = uar_srvsetstring(hchargeitem,"diag_code3",nullterm(reply->interface_charge[
          loop_count].diag_code3))
        SET stat = uar_srvsetstring(hchargeitem,"person_name",nullterm(reply->interface_charge[
          loop_count].person_name))
        SET stat = uar_srvsetdouble(hchargeitem,"person_id",reply->interface_charge[loop_count].
         person_id)
        SET stat = uar_srvsetdouble(hchargeitem,"encntr_id",reply->interface_charge[loop_count].
         encntr_id)
        SET stat = uar_srvsetstring(hchargeitem,"fin_nbr",nullterm(reply->interface_charge[loop_count
          ].fin_nbr))
        SET stat = uar_srvsetstring(hchargeitem,"med_nbr",nullterm(reply->interface_charge[loop_count
          ].med_nbr))
        SET recdate->datetime = reply->interface_charge[loop_count].service_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"service_dt_tm",recdate)
        SET stat = uar_srvsetdouble(hchargeitem,"section_cd",reply->interface_charge[loop_count].
         section_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"encntr_type_cd",reply->interface_charge[loop_count].
         encntr_type_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"payor_id",reply->interface_charge[loop_count].
         payor_id)
        SET stat = uar_srvsetdouble(hchargeitem,"quantity",reply->interface_charge[loop_count].
         quantity)
        SET stat = uar_srvsetdouble(hchargeitem,"price",reply->interface_charge[loop_count].price)
        SET stat = uar_srvsetdouble(hchargeitem,"net_ext_price",reply->interface_charge[loop_count].
         net_ext_price)
        SET stat = uar_srvsetdouble(hchargeitem,"organization_id",reply->interface_charge[loop_count]
         .organization_id)
        SET stat = uar_srvsetdouble(hchargeitem,"institution_cd",reply->interface_charge[loop_count].
         institution_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"department_cd",reply->interface_charge[loop_count].
         department_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"subsection_cd",reply->interface_charge[loop_count].
         subsection_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"level5_cd",reply->interface_charge[loop_count].
         level5_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"facility_cd",reply->interface_charge[loop_count].
         facility_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"building_cd",reply->interface_charge[loop_count].
         building_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"nurse_unit_cd",reply->interface_charge[loop_count].
         nurse_unit_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"room_cd",reply->interface_charge[loop_count].room_cd
         )
        SET stat = uar_srvsetdouble(hchargeitem,"bed_cd",reply->interface_charge[loop_count].bed_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"referring_phys_id",reply->interface_charge[
         loop_count].referring_phys_id)
        SET stat = uar_srvsetdouble(hchargeitem,"ord_phys_id",reply->interface_charge[loop_count].
         ord_phys_id)
        SET stat = uar_srvsetstring(hchargeitem,"ord_doc_nbr",nullterm(reply->interface_charge[
          loop_count].ord_doc_nbr))
        SET stat = uar_srvsetdouble(hchargeitem,"adm_phys_id",reply->interface_charge[loop_count].
         adm_phys_id)
        SET stat = uar_srvsetdouble(hchargeitem,"attending_phys_id",reply->interface_charge[
         loop_count].attending_phys_id)
        SET stat = uar_srvsetdouble(hchargeitem,"additional_encntr_phys2_id",reply->interface_charge[
         loop_count].additional_encntr_phys2_id)
        SET stat = uar_srvsetdouble(hchargeitem,"additional_encntr_phys3_id",reply->interface_charge[
         loop_count].additional_encntr_phys3_id)
        SET stat = uar_srvsetdouble(hchargeitem,"charge_type_cd",reply->interface_charge[loop_count].
         charge_type_cd)
        SET stat = uar_srvsetlong(hchargeitem,"updt_cnt",reply->interface_charge[loop_count].updt_cnt
         )
        SET recdate->datetime = reply->interface_charge[loop_count].updt_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"updt_dt_tm",recdate)
        SET stat = uar_srvsetdouble(hchargeitem,"updt_id",reply->interface_charge[loop_count].updt_id
         )
        SET stat = uar_srvsetlong(hchargeitem,"updt_task",reply->interface_charge[loop_count].
         updt_task)
        SET stat = uar_srvsetlong(hchargeitem,"updt_applctx",reply->interface_charge[loop_count].
         updt_applctx)
        SET stat = uar_srvsetshort(hchargeitem,"active_ind",reply->interface_charge[loop_count].
         active_ind)
        SET stat = uar_srvsetdouble(hchargeitem,"active_status_cd",reply->interface_charge[loop_count
         ].active_status_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"active_status_prsnl_id",reply->interface_charge[
         loop_count].active_status_prsnl_id)
        SET recdate->datetime = reply->interface_charge[loop_count].active_status_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"active_status_dt_tm",recdate)
        SET recdate->datetime = reply->interface_charge[loop_count].beg_effective_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"beg_effective_dt_tm",recdate)
        SET recdate->datetime = reply->interface_charge[loop_count].end_effective_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"end_effective_dt_tm",recdate)
        SET stat = uar_srvsetdouble(hchargeitem,"abn_status_cd",reply->interface_charge[loop_count].
         abn_status_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"activity_type_cd",reply->interface_charge[loop_count
         ].activity_type_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"admit_type_cd",reply->interface_charge[loop_count].
         admit_type_cd)
        SET stat = uar_srvsetshort(hchargeitem,"bill_code_more_ind",reply->interface_charge[
         loop_count].bill_code_more_ind)
        SET stat = uar_srvsetstring(hchargeitem,"bill_code_type_cdf",nullterm(reply->
          interface_charge[loop_count].bill_code_type_cdf))
        SET stat = uar_srvsetdouble(hchargeitem,"code_modifier1_cd",reply->interface_charge[
         loop_count].code_modifier1_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"code_modifier2_cd",reply->interface_charge[
         loop_count].code_modifier2_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"code_modifier2_cd",reply->interface_charge[
         loop_count].code_modifier3_cd)
        SET stat = uar_srvsetshort(hchargeitem,"code_modifier_more_ind",reply->interface_charge[
         loop_count].code_modifier_more_ind)
        SET stat = uar_srvsetdouble(hchargeitem,"cost_center_cd",reply->interface_charge[loop_count].
         cost_center_cd)
        SET stat = uar_srvsetstring(hchargeitem,"diag_desc1",nullterm(reply->interface_charge[
          loop_count].diag_desc1))
        SET stat = uar_srvsetstring(hchargeitem,"diag_desc2",nullterm(reply->interface_charge[
          loop_count].diag_desc2))
        SET stat = uar_srvsetstring(hchargeitem,"diag_desc3",nullterm(reply->interface_charge[
          loop_count].diag_desc3))
        SET stat = uar_srvsetshort(hchargeitem,"diag_more_ind",reply->interface_charge[loop_count].
         diag_more_ind)
        SET stat = uar_srvsetdouble(hchargeitem,"discount_amount",reply->interface_charge[loop_count]
         .discount_amount)
        SET stat = uar_srvsetlong(hchargeitem,"fin_nbr_type_flg",reply->interface_charge[loop_count].
         fin_nbr_type_flg)
        SET stat = uar_srvsetdouble(hchargeitem,"gross_price",reply->interface_charge[loop_count].
         gross_price)
        SET stat = uar_srvsetshort(hchargeitem,"icd9_proc_more_ind",reply->interface_charge[
         loop_count].icd9_proc_more_ind)
        SET stat = uar_srvsetshort(hchargeitem,"manual_ind",reply->interface_charge[loop_count].
         manual_ind)
        SET stat = uar_srvsetdouble(hchargeitem,"med_service_cd",reply->interface_charge[loop_count].
         med_service_cd)
        SET stat = uar_srvsetstring(hchargeitem,"order_nbr",nullterm(reply->interface_charge[
          loop_count].order_nbr))
        SET stat = uar_srvsetstring(hchargeitem,"override_desc",nullterm(reply->interface_charge[
          loop_count].override_desc))
        SET stat = uar_srvsetdouble(hchargeitem,"perf_loc_cd",reply->interface_charge[loop_count].
         perf_loc_cd)
        SET stat = uar_srvsetdouble(hchargeitem,"perf_phys_id",reply->interface_charge[loop_count].
         perf_phys_id)
        SET recdate->datetime = reply->interface_charge[loop_count].posted_dt_tm
        SET stat = uar_srvsetdate2(hchargeitem,"posted_dt_tm",recdate)
        SET stat = uar_srvsetstring(hchargeitem,"prim_cdm_desc",nullterm(reply->interface_charge[
          loop_count].prim_cdm_desc))
        SET stat = uar_srvsetstring(hchargeitem,"prim_cpt_desc",nullterm(reply->interface_charge[
          loop_count].prim_cpt_desc))
        SET stat = uar_srvsetstring(hchargeitem,"prim_icd9_proc",nullterm(reply->interface_charge[
          loop_count].prim_icd9_proc))
        SET stat = uar_srvsetstring(hchargeitem,"prim_icd9_proc_desc",nullterm(reply->
          interface_charge[loop_count].prim_icd9_proc_desc))
        SET stat = uar_srvsetlong(hchargeitem,"process_flg",reply->interface_charge[loop_count].
         process_flg)
        SET stat = uar_srvsetshort(hchargeitem,"user_def_ind",reply->interface_charge[loop_count].
         user_def_ind)
        IF (uar_srvfieldexists(hchargeitem,"prim_icd9_proc_nomen_id")=true)
         SET stat = uar_srvsetdouble(hchargeitem,"prim_icd9_proc_nomen_id",reply->interface_charge[
          loop_count].prim_icd9_proc_nomen_id)
        ENDIF
        IF (uar_srvfieldexists(hchargeitem,"bill_code1_nomen_id")=true)
         SET stat = uar_srvsetdouble(hchargeitem,"bill_code1_nomen_id",reply->interface_charge[
          loop_count].bill_code1_nomen_id)
        ENDIF
        IF (uar_srvfieldexists(hchargeitem,"bill_code2_nomen_id")=true)
         SET stat = uar_srvsetdouble(hchargeitem,"bill_code2_nomen_id",reply->interface_charge[
          loop_count].bill_code2_nomen_id)
        ENDIF
        IF (uar_srvfieldexists(hchargeitem,"bill_code3_nomen_id")=true)
         SET stat = uar_srvsetdouble(hchargeitem,"bill_code3_nomen_id",reply->interface_charge[
          loop_count].bill_code3_nomen_id)
        ENDIF
        IF (uar_srvfieldexists(hchargeitem,"icd_diag_info")=true)
         FOR (icddiagcnt = 1 TO size(reply->interface_charge[loop_count].icd_diag_info,5))
          SET hdiagitem = uar_srvadditem(hchargeitem,"icd_diag_info")
          IF (hdiagitem)
           SET stat = uar_srvsetdouble(hdiagitem,"nomen_id",reply->interface_charge[loop_count].
            icd_diag_info[icddiagcnt].nomen_id)
          ENDIF
         ENDFOR
        ENDIF
        SET iret = uar_siscriptesocompdttrig(srvrec->qual[1].hreq,queueid)
        CALL echo(build("iRet: ",iret))
        CALL echo(build("QueueId: ",queueid))
        IF (iret != 1)
         CALL echo("Attempt to interface or queue charge has failed")
         CALL echo("Cannot communicate with FSI")
         SET reply->status_data.status = "F"
         GO TO end_program
        ENDIF
        CALL echo("updating process_flgs to 999...")
        SELECT INTO "nl:"
         c.seq
         FROM interface_charge c
         WHERE (c.interface_charge_id=reply->interface_charge[loop_count].interface_charge_id)
         WITH forupdate(c)
        ;end select
        UPDATE  FROM interface_charge c
         SET c.process_flg = 999, c.updt_cnt = (c.updt_cnt+ 1), c.updt_id = reqinfo->updt_id,
          c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm =
          cnvtdatetime(curdate,curtime3)
         PLAN (c
          WHERE (c.interface_charge_id=reply->interface_charge[loop_count].interface_charge_id))
         WITH nocounter
        ;end update
        IF (curqual > 0)
         SET reply->status_data.status = "S"
        ELSE
         SET reply->status_data.status = "F"
         CALL echo("Error while updating process flags")
        ENDIF
        IF ((reply->status_data.status="S"))
         COMMIT
        ENDIF
        CALL echo(build("processed charges for encntr: ",reply->interface_charge[loop_count].
          encntr_id))
       ELSE
        CALL echo("FAILURE hChargeItem")
       ENDIF
      ELSE
       CALL echo("FAILURE hTrigItem")
      ENDIF
     ELSE
      CALL echo("FAILURE hCqmstruct")
     ENDIF
    ELSE
     CALL echo("FAILURE hMsgStruct")
    ENDIF
  ENDFOR
  CALL cleanup_srv_stuff(1)
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo("No charges qualified")
 ENDIF
 SUBROUTINE cleanup_srv_stuff(dummy1)
   CALL echo("In CleanUp_Srv_Stuff() routine...")
   FOR (i = 1 TO size(srvrec->qual,5))
    IF ((srvrec->qual[i].hreq > 0))
     CALL uar_srvdestroyinstance(srvrec->qual[i].hreq)
    ENDIF
    IF ((srvrec->qual[i].hrep > 0))
     CALL uar_srvdestroyinstance(srvrec->qual[i].hrep)
    ENDIF
   ENDFOR
   IF (size(srvrec->qual,5))
    SET stat = alterlist(srvrec->qual,0)
   ENDIF
   SET reqinfo->commit_ind = 1
   CALL echo("Exiting CleanUp_Srv_Stuff() routine...")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE init_srv_stuff(messageid,get_hreq,get_hrep)
   CALL echo("In Init_Srv_Stuff() routine...")
   SET m_idx = size(srvrec->qual,5)
   SET m_idx = (m_idx+ 1)
   SET stat = alterlist(srvrec->qual,m_idx)
   SET srvrec->qual[m_idx].msg_id = messageid
   CALL echo(build("srvrec->qual[m_idx]->msg_id = ",srvrec->qual[m_idx].msg_id))
   SET srvrec->qual[m_idx].hmsg = uar_srvselectmessage(srvrec->qual[m_idx].msg_id)
   IF (srvrec->qual[m_idx].hmsg)
    IF (get_hreq)
     SET srvrec->qual[m_idx].hreq = uar_srvcreaterequest(srvrec->qual[m_idx].hmsg)
     IF ( NOT (srvrec->qual[m_idx].hreq))
      CALL echo("The uar_SrvCreateRequest() FAILED!!")
      RETURN(0)
     ENDIF
    ENDIF
    IF (get_hrep)
     SET srvrec->qual[m_idx].hrep = uar_srvcreatereply(srvrec->qual[m_idx].hmsg)
     IF ( NOT (srvrec->qual[m_idx].hrep))
      CALL echo("The uar_SrvCreateReply() FAILED!!")
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    CALL echo("The uar_SrvSelectMessage() FAILED!!")
    RETURN(0)
   ENDIF
   CALL echo("Exiting Init_Srv_Stuff() routine... ")
   RETURN(1)
 END ;Subroutine
#end_program
 CALL echo(build("the status of afc_hl7_realtime_interface is : ",reply->status_data.status))
END GO
