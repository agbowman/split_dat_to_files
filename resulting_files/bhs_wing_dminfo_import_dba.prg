CREATE PROGRAM bhs_wing_dminfo_import:dba
 FREE RECORD request
 RECORD request(
   1 fac_cnt = i4
   1 list[*]
     2 facility_name = vc
 )
 DECLARE l_cnt = i4
 DECLARE temp_errmsg = vc
 DECLARE temp_err_ind = i2
 SET temp_err_ind = 0
 SET request->fac_cnt = 157
 SET stat = alterlist(request->list,request->fac_cnt)
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "ADULTBEHAVHLTH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "ADULTPHP"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "ADULTPHPFMC"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEADOLESMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEBREASTSPECIALISTS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEBRIGHTWOOD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATECARDIACSURGERY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATECARDIOLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEDEVELOPPEDS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEENDODIABETES"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEFRANKLINREHABILITATION"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEGASTRO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEGENPEDS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEGERIATRICS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEHIGHSTADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEHIGHSTPEDS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEID"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEMARYLANEREHABILITATION"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEMASONSQUARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEMIDWIFERY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATENEURO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATENEUROSURG"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEOBESITYANDDIABETESPROGRAM"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDIATRICASSOCIATES"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDIATRICNEUROSURG"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDIATRICSURGERY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSCARDIO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSENDO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSID"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSNEURO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSPULMMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSRHEUM"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPEDSWEIGHTMANAGEMNT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPHYSREHAB"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPLASTICSURG"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPULMONARY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEREHABILITATION"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEREPRODUCTMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATESURGASSOC"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATETHORACICSURG"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEURGENTCARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEURGENTCARENORTHAMPTON"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEVASCULARSERVICES"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEWESSONWOMENS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEWESWOMENGRP"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTGENETICS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTGYNONCOLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTPEDIGI"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BBHANP"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BFMCVASCULARSERV"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BLCHMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMALIPID"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMCPSYCHCONSULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPBELCHERTOWNADULTPED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPELONGMEADOWADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPFRANKLINMULTISPECIALTY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDFAMILYMEDICINE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDGASTROENTEROLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDNEUROLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDPEDS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDSURGERY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGREENFIELDUROLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPGRNFLDPULMSLEEPMEDICINE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPLUDLOWADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPMARYLANEGASTRO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPMARYLANEOBGYN"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPMARYLANEORTHO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPMARYLANESURGERY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPNHAMPCARD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPNORTHAMPTON"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPNORTHAMPTONOBGYN"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPPIONEERVALLEYFAMILY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPPIONEERWOMENS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPQUABBINADULTMEDICINE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPQUABBINPEDS"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPRAPIDCARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPSOUTHHADLEYADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPSPORTSANDEXERCISEMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPVLYORTHOANDSPORTSMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPWESTSIDEADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BMPWILBRAHAMADULT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "CHILDBEHAVHLTH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "CHILDPHP"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "CTRCACARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "FAMADVO"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "GRISWOLDBEHAVHLTH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "HEARTANDVASCULARGREENFIELD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "HEARTVASCULARMIDLEVELPROGRAM"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "HIGHSTSPCLTY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAV3300MAIN"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALEASTLONGMW"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALGREENFIELD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALHEALTH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALNORTHERNEDGE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALSOUTHDEERFIELD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALWARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALWILBRAHAM"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDBEHAVIORALWSPFLD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "INTEGRATEDHEALTHSOHADLEY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "LUDLOWMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "MARYLANEMULTISPECSERVICES"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "MARYLANEVASCULARLAB"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "MATFTMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "MONSONMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "NEUROPSYCH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "NORTHERNEDGEADULTANDPEDI"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "OUTPTPSYCH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "OUTPTPSYCHIATRYBMCLOCATION"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PALMERMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PEDIATRICCARDIOLOGYTESTING"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PEDSNUTRITIONISTSWASON"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PREOPOVERFLOW"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PSYCHCARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PSYCHIATRYADMINISTRATION"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "QUABBINADULTMEDICINEWARE"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "TBCLINIC"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "TRAVELMED"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "WESSONSLEEPCLINIC"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "WILBRAHAMMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "GRISWOLDBEHAVHLTH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BLCHMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "LUDLOWMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "MONSONMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "PALMERMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "WILBRAHAMMEDCTR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATECARDPLMR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEENDODIABPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEENT"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEGASTROPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEGENSURGPLMR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEHEMATOLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEIDPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATENEUROLOGYPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATENEUROSRGPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEORTHOSURGPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTPLASTICANDRECONSURGPLMR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPODIATRY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEPULMONARYPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATERHEUMATOLOGY"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEUROLOGYPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEWOMENSHEALTHLUDLOW"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BAYSTATEWOMENSHEALTHPALMER"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTBEHAVHLTHGRISWOLD"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTBEHAVHLTHGRISWOLDBLCH"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTBEHAVHLTHGRISWOLDLUDLOW"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTBEHAVHLTHGRISWOLDPLMR"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTPRIMCARELUDLOW"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTPRIMCAREMONSON"
 SET l_cnt += 1
 SET request->list[l_cnt].facility_name = "BYSTPRIMCAREPALMER"
 SET request->fac_cnt = l_cnt
 SET stat = alterlist(request->list,request->fac_cnt)
 FOR (loopit = 1 TO l_cnt)
   DELETE  FROM dm_info di
    WHERE di.info_domain="BHS_RPT_WING_MISSING_NOTE"
     AND (di.info_name=request->list[loopit].facility_name)
     AND di.info_char="FACILITY"
    WITH nocounter
   ;end delete
   INSERT  FROM dm_info di
    SET di.info_domain = "BHS_RPT_WING_MISSING_NOTE", di.info_name = request->list[loopit].
     facility_name, di.info_char = "FACILITY",
     di.info_date = cnvtdatetime(sysdate), di.updt_id = reqinfo->updt_id, di.updt_dt_tm =
     cnvtdatetime(sysdate)
    WITH nocounter
   ;end insert
   IF (error(temp_errmsg,1) > 0)
    CALL echo("***")
    CALL echo(request->list[loopit].facility_name)
    SET temp_err_ind = 1
   ENDIF
 ENDFOR
 COMMIT
 CALL echo("%%%%%")
 CALL echo(build("Error ind: ",temp_err_ind))
END GO
