CREATE PROGRAM afc_export_tier_matrix:dba
 DECLARE versionnbr = vc
 SET versionnbr = "486499.005"
 CALL echo(build("AFC_EXPORT_TIER_MATRIX Version: ",versionnbr))
 FREE SET reply
 RECORD reply(
   1 header_string = vc
   1 line_qual_cnt = i4
   1 line_qual[*]
     2 line = vc
     2 size = i4
 )
 FREE SET internal
 RECORD internal(
   1 tier_qual = i2
   1 tier[*]
     2 row_qual = i2
     2 row[*]
       3 col_qual = i2
       3 col[*]
         4 tier_cell_value = f8
         4 tier_cell_value_id = f8
         4 tier_cell_string = c50
         4 tier_group_cd = f8
         4 tier_cell_type_cd = f8
         4 sbeg_effective_dt_tm = vc
         4 send_effective_dt_tm = vc
         4 tier_col_num = i4
         4 tier_row_num = i4
         4 tier_cell_entity_name = vc
         4 stiercelltypedisplay = vc
         4 stiergroupdisplay = vc
         4 stiercelldisplay = vc
 )
 RECORD csvline(
   1 line_qual[*]
     2 line = vc
     2 size = i4
 )
 DECLARE ltiergroupreccnt = i4 WITH public, noconstant(0)
 DECLARE ltiercolreccnt = i4 WITH public, noconstant(0)
 DECLARE ltierrowreccnt = i4 WITH public, noconstant(0)
 DECLARE istat = i2 WITH public, noconstant(0)
 DECLARE sfilename = c40 WITH public, noconstant("")
 DECLARE lrecidx = i4 WITH public, noconstant(0)
 DECLARE lrowidx = i4 WITH public, noconstant(0)
 DECLARE lcolidx = i4 WITH public, noconstant(0)
 DECLARE sline = vc WITH public, noconstant("")
 DECLARE llinecnt = i4 WITH public, noconstant(0)
 DECLARE llinelength = i4 WITH public, noconstant(0)
 DECLARE ineedtocontinue = i2 WITH public, noconstant(0)
 DECLARE rvar = i2 WITH public, noconstant(0)
 DECLARE lstartgapidx = i4 WITH public, noconstant(0)
 DECLARE lendgapidx = i4 WITH public, noconstant(0)
 DECLARE lgapidx = i4 WITH public, noconstant(0)
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
 DECLARE dtiercellspt4modvaluecd = f8 WITH public, noconstant(0.0)
 DECLARE dtiercellcoveragecd = f8 WITH public, noconstant(0.0)
 DECLARE stiername = vc WITH public, noconstant("")
 DECLARE stiernameid = vc WITH public, noconstant("")
 DECLARE sbegindate = vc WITH public, noconstant("")
 DECLARE sbegindateempty = vc WITH public, noconstant("")
 DECLARE senddate = vc WITH public, noconstant("")
 DECLARE senddateempty = vc WITH public, noconstant("")
 DECLARE sfinclass = vc WITH public, noconstant("")
 DECLARE sfinclasscd = vc WITH public, noconstant("")
 DECLARE sadmittype = vc WITH public, noconstant("")
 DECLARE sadmittypecd = vc WITH public, noconstant("")
 DECLARE sorg = vc WITH public, noconstant("")
 DECLARE sorgid = vc WITH public, noconstant("")
 DECLARE sordloc = vc WITH public, noconstant("")
 DECLARE sordloccd = vc WITH public, noconstant("")
 DECLARE sservresource = vc WITH public, noconstant("")
 DECLARE sservresourcecd = vc WITH public, noconstant("")
 DECLARE srptpriority = vc WITH public, noconstant("")
 DECLARE srptprioritycd = vc WITH public, noconstant("")
 DECLARE spatloc = vc WITH public, noconstant("")
 DECLARE spatloccd = vc WITH public, noconstant("")
 DECLARE sclltnpriority = vc WITH public, noconstant("")
 DECLARE sclltnprioritycd = vc WITH public, noconstant("")
 DECLARE sperfloc = vc WITH public, noconstant("")
 DECLARE sperfloccd = vc WITH public, noconstant("")
 DECLARE sactivtype = vc WITH public, noconstant("")
 DECLARE sactivtypecd = vc WITH public, noconstant("")
 DECLARE sactivsubtype = vc WITH public, noconstant("")
 DECLARE sactivsubtypecd = vc WITH public, noconstant("")
 DECLARE shealthplan = vc WITH public, noconstant("")
 DECLARE shealthplanid = vc WITH public, noconstant("")
 DECLARE spriority = vc WITH public, noconstant("")
 DECLARE sprioritycd = vc WITH public, noconstant("")
 DECLARE sorderphys = vc WITH public, noconstant("")
 DECLARE sorderphysid = vc WITH public, noconstant("")
 DECLARE sorderphysgroup = vc WITH public, noconstant("")
 DECLARE sorderphysgroupid = vc WITH public, noconstant("")
 DECLARE srenderphys = vc WITH public, noconstant("")
 DECLARE srenderphysid = vc WITH public, noconstant("")
 DECLARE srenderphysgroup = vc WITH public, noconstant("")
 DECLARE srenderphysgroupid = vc WITH public, noconstant("")
 DECLARE smedservice = vc WITH public, noconstant("")
 DECLARE smedservicecd = vc WITH public, noconstant("")
 DECLARE sencountertype = vc WITH public, noconstant("")
 DECLARE sencountertypecd = vc WITH public, noconstant("")
 DECLARE sinsureorg = vc WITH public, noconstant("")
 DECLARE sinsureorgid = vc WITH public, noconstant("")
 DECLARE scpt4modvalue = vc WITH public, noconstant("")
 DECLARE scpt4modvaluecd = vc WITH public, noconstant("")
 DECLARE sproviderspcvalue = vc WITH public, noconstant("")
 DECLARE sproviderspcvaluecd = vc WITH public, noconstant("")
 DECLARE schargeprocess = vc WITH public, noconstant("")
 DECLARE schargeprocesscd = vc WITH public, noconstant("")
 DECLARE spricesched = vc WITH public, noconstant("")
 DECLARE spriceschedid = vc WITH public, noconstant("")
 DECLARE slistprice = vc WITH public, noconstant("")
 DECLARE slistpriceid = vc WITH public, noconstant("")
 DECLARE scdmsched = vc WITH public, noconstant("")
 DECLARE scdmschedcd = vc WITH public, noconstant("")
 DECLARE scpt4 = vc WITH public, noconstant("")
 DECLARE scpt4cd = vc WITH public, noconstant("")
 DECLARE scpt4mod = vc WITH public, noconstant("")
 DECLARE scpt4modcd = vc WITH public, noconstant("")
 DECLARE ssnomed = vc WITH public, noconstant("")
 DECLARE ssnomedcd = vc WITH public, noconstant("")
 DECLARE shcpcs = vc WITH public, noconstant("")
 DECLARE shcpcscd = vc WITH public, noconstant("")
 DECLARE sicd9 = vc WITH public, noconstant("")
 DECLARE sicd9cd = vc WITH public, noconstant("")
 DECLARE sicd9proc = vc WITH public, noconstant("")
 DECLARE sicd9proccd = vc WITH public, noconstant("")
 DECLARE srevenue = vc WITH public, noconstant("")
 DECLARE srevenuecd = vc WITH public, noconstant("")
 DECLARE sholdsuspense = vc WITH public, noconstant("")
 DECLARE sholdsuspensecd = vc WITH public, noconstant("")
 DECLARE sgenledger = vc WITH public, noconstant("")
 DECLARE sgenledgercd = vc WITH public, noconstant("")
 DECLARE scheckdiag = vc WITH public, noconstant("")
 DECLARE scheckdiagempty = vc WITH public, noconstant("")
 DECLARE scheckphys = vc WITH public, noconstant("")
 DECLARE scheckphysempty = vc WITH public, noconstant("")
 DECLARE scostcenter = vc WITH public, noconstant("")
 DECLARE scostcentercd = vc WITH public, noconstant("")
 DECLARE sflatdiscount = vc WITH public, noconstant("")
 DECLARE sflatdiscountempty = vc WITH public, noconstant("")
 DECLARE saddonbill = vc WITH public, noconstant("")
 DECLARE saddonbillid = vc WITH public, noconstant("")
 DECLARE sinterfacefile = vc WITH public, noconstant("")
 DECLARE sinterfacefileid = vc WITH public, noconstant("")
 DECLARE sinstitfin = vc WITH public, noconstant("")
 DECLARE sinstitfinempty = vc WITH public, noconstant("")
 DECLARE sclientrpttype = vc WITH public, noconstant("")
 DECLARE sclientrpttypecd = vc WITH public, noconstant("")
 DECLARE sseperator = vc WITH public, noconstant("")
 DECLARE sseperatorempty = vc WITH public, noconstant("")
 DECLARE scoverage = vc WITH public, noconstant("")
 DECLARE scoveragecd = vc WITH public, noconstant("")
 DECLARE snamecol = vc WITH public, noconstant("")
 DECLARE sfinclasscol = vc WITH public, noconstant("")
 DECLARE sadmittypecol = vc WITH public, noconstant("")
 DECLARE sorgcol = vc WITH public, noconstant("")
 DECLARE sordloccol = vc WITH public, noconstant("")
 DECLARE sservresourcecol = vc WITH public, noconstant("")
 DECLARE srptprioritycol = vc WITH public, noconstant("")
 DECLARE spatloccol = vc WITH public, noconstant("")
 DECLARE sclltnprioritycol = vc WITH public, noconstant("")
 DECLARE sperfloccol = vc WITH public, noconstant("")
 DECLARE sactivtypecol = vc WITH public, noconstant("")
 DECLARE shealthplancol = vc WITH public, noconstant("")
 DECLARE sprioritycol = vc WITH public, noconstant("")
 DECLARE sseperatorcol = vc WITH public, noconstant("")
 DECLARE schargeprocesscol = vc WITH public, noconstant("")
 DECLARE spriceschedcol = vc WITH public, noconstant("")
 DECLARE slistpricecol = vc WITH public, noconstant("")
 DECLARE scdmschedcol = vc WITH public, noconstant("")
 DECLARE scpt4col = vc WITH public, noconstant("")
 DECLARE scpt4modcol = vc WITH public, noconstant("")
 DECLARE shcpcscol = vc WITH public, noconstant("")
 DECLARE sicd9col = vc WITH public, noconstant("")
 DECLARE sicd9proccol = vc WITH public, noconstant("")
 DECLARE srevenuecol = vc WITH public, noconstant("")
 DECLARE sholdsuspensecol = vc WITH public, noconstant("")
 DECLARE sgenledgercol = vc WITH public, noconstant("")
 DECLARE scheckdiagcol = vc WITH public, noconstant("")
 DECLARE scheckphyscol = vc WITH public, noconstant("")
 DECLARE scostcentercol = vc WITH public, noconstant("")
 DECLARE sflatdiscountcol = vc WITH public, noconstant("")
 DECLARE saddoncol = vc WITH public, noconstant("")
 DECLARE sinterfacefilecol = vc WITH public, noconstant("")
 DECLARE sinstitfincol = vc WITH public, noconstant("")
 DECLARE sclientrpttypecol = vc WITH public, noconstant("")
 DECLARE ssnomedcol = vc WITH public, noconstant("")
 DECLARE sactivsubtypecol = vc WITH public, noconstant("")
 DECLARE sorderphyscol = vc WITH public, noconstant("")
 DECLARE sorderphysgroupcol = vc WITH public, noconstant("")
 DECLARE srenderphyscol = vc WITH public, noconstant("")
 DECLARE srenderphysgroupcol = vc WITH public, noconstant("")
 DECLARE smedservicecol = vc WITH public, noconstant("")
 DECLARE sencountertypecol = vc WITH public, noconstant("")
 DECLARE sinsureorgcol = vc WITH public, noconstant("")
 DECLARE scpt4modvaluecol = vc WITH public, noconstant("")
 DECLARE sproviderspcvaluecol = vc WITH public, noconstant("")
 DECLARE scoveragecol = vc WITH public, noconstant("")
 DECLARE retrieverecords(ifoo=i2) = i2
 DECLARE logdata(sstringmsg=vc,sfileaction=vc) = i2
 DECLARE createcsv(ifoo=i2) = i2
 DECLARE migratedata(ifoo=i2) = i2
 DECLARE populatetiercelltypes(ifoo=i2) = i2
 DECLARE buildline(ifoo=i2) = i2
 DECLARE storevalues(dcd=f8,sfoo=vc,did=f8,lcol=i4) = i2
 DECLARE resetvariables(ifoo=i2) = i2
 DECLARE exportfrontend(ifoo=i2) = i2
 SET istat = logdata("","OPEN")
 SET istat = populatetiercelltypes(0)
 SET istat = retrieverecords(0)
 IF (istat=false)
  SET istat = logdata("Unable to retrieve records from the database. Ending Export.","APPEND")
  GO TO end_program
 ELSE
  SET istat = logdata("Successful retrieval of records from the database.","APPEND")
 ENDIF
 SET filename = "afc_export_tier_matrix.csv"
 SET snamecol = concat("0",",")
 SET sseperatorcol = concat("0",",")
 CALL echo(build("Number of tiers retrieved: ",ltiergroupreccnt))
 SET istat = migratedata(0)
 IF (istat=false)
  SET istat = logdata("Unable to migrate data. Ending Export.","APPEND")
  GO TO end_program
 ELSE
  SET istat = logdata("Successful migration of data.","APPEND")
 ENDIF
 IF (validate(request->export_front_end,0)=1)
  SET istat = exportfrontend(0)
 ELSE
  SET istat = createcsv(0)
  IF (istat=false)
   SET istat = logdata("Unable to create CSV. Ending Export.","APPEND")
   GO TO end_program
  ELSE
   SET istat = logdata("Successful creation of CSV.","APPEND")
  ENDIF
 ENDIF
 GO TO end_program
 SUBROUTINE logdata(smsg,saction)
   CASE (saction)
    OF "OPEN":
     SET rvar = 0
     SELECT INTO "afc_export_tier_matrix.log"
      rvar
      HEAD REPORT
       col + 1, "**AFC Tier Matrix Export**      - Starting   ", curdate"dd-mmm-yyyy;;d",
       "-", curtime"hh:mm;;m"
      DETAIL
       col 0
      WITH nocounter, format = variable, noformfeed,
       maxcol = 132, maxrow = 1
     ;end select
    OF "CLOSE":
     SELECT INTO "afc_export_tier_matrix.log"
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
     SELECT INTO "afc_export_tier_matrix.log"
      rvar
      HEAD REPORT
       sinfo1 = trim(smsg)
      DETAIL
       row + 1, col 0, sinfo1
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
    OF "STARTNEWTIER":
     SELECT INTO "afc_export_tier_matrix.log"
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
     SELECT INTO "afc_export_tier_matrix.log"
      rvar
      HEAD REPORT
       sinfo1 = trim(smsg)
      DETAIL
       row + 1, col 0, "*********Finished with Tier: ",
       sinfo1, row + 1
      WITH nocounter, append, format = variable,
       noformfeed, maxcol = 132, maxrow = 1
     ;end select
     RETURN(true)
   ENDCASE
 END ;Subroutine
 SUBROUTINE retrieverecords(foo)
  SELECT INTO "nl:"
   tm.*, group_name = uar_get_code_display(tm.tier_group_cd), which_tbl = decode(o.seq,"o",hp.seq,
    "hp",bi.seq,
    "bi",ps.seq,"ps",cv.seq,"cv",
    itf.seq,"itf","zzz")
   FROM tier_matrix tm,
    dummyt d1,
    organization o,
    dummyt d2,
    bill_item bi,
    dummyt d3,
    health_plan hp,
    dummyt d4,
    price_sched ps,
    dummyt d5,
    code_value cv,
    dummyt d6,
    interface_file itf,
    dummyt d7,
    tier_matrix tm2
   PLAN (tm
    WHERE tm.active_ind=1
     AND ((tm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND tm.end_effective_dt_tm > cnvtdatetime(curdate,curtime)) OR (tm.beg_effective_dt_tm >
    cnvtdatetime(curdate,curtime)
     AND tm.end_effective_dt_tm > cnvtdatetime(curdate,curtime))) )
    JOIN (d1)
    JOIN (((o
    WHERE tm.tier_cell_value_id=o.organization_id
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_type_cd=dtiercellorgcd
     AND o.active_ind=1)
    ) ORJOIN ((d2)
    JOIN (((bi
    WHERE tm.tier_cell_value_id=bi.bill_item_id
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_type_cd=dtiercelladdoncd
     AND bi.active_ind=1)
    ) ORJOIN ((d3)
    JOIN (((hp
    WHERE tm.tier_cell_value_id=hp.health_plan_id
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_type_cd=dtiercellhealthplancd
     AND hp.active_ind=1)
    ) ORJOIN ((d4)
    JOIN (((ps
    WHERE tm.tier_cell_value_id=ps.price_sched_id
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_type_cd IN (dtiercellpriceschedcd, dtiercelllistpriceschedcd)
     AND ps.active_ind=1)
    ) ORJOIN ((d6)
    JOIN (((itf
    WHERE tm.tier_cell_value_id=itf.interface_file_id
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_entity_name="INTERFACE_FILE"
     AND itf.active_ind=1)
    ) ORJOIN ((d5)
    JOIN (((cv
    WHERE tm.tier_cell_value_id=cv.code_value
     AND tm.tier_cell_value_id > 0.0
     AND tm.tier_cell_entity_name="CODE_VALUE"
     AND tm.tier_cell_type_cd != dtiercelllistpriceschedcd
     AND cv.active_ind=1)
    ) ORJOIN ((d7)
    JOIN (tm2
    WHERE tm.tier_cell_id=tm2.tier_cell_id
     AND tm.tier_cell_value_id=0.0
     AND tm2.active_ind=1)
    )) )) )) )) )) ))
   ORDER BY group_name, tm.tier_row_num, tm.tier_col_num,
    tm.beg_effective_dt_tm, tm.end_effective_dt_tm
   HEAD REPORT
    ltiergroupreccnt = 0, ltierrowreccnt = 0, ltiercolreccnt = 0
   HEAD tm.tier_group_cd
    ltiergroupreccnt = (ltiergroupreccnt+ 1), stat = alterlist(internal->tier,ltiergroupreccnt),
    ltiercolreccnt = 0,
    ltierrowreccnt = 0
   HEAD tm.tier_row_num
    ltierrowreccnt = (ltierrowreccnt+ 1), stat = alterlist(internal->tier[ltiergroupreccnt].row,
     ltierrowreccnt), ltiercolreccnt = 0
   HEAD tm.tier_col_num
    ltiercolreccnt = (ltiercolreccnt+ 1), stat = alterlist(internal->tier[ltiergroupreccnt].row[
     ltierrowreccnt].col,ltiercolreccnt)
   DETAIL
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_cell_value_id = tm
    .tier_cell_value_id, internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].
    tier_cell_value = tm.tier_cell_value, internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[
    ltiercolreccnt].tier_cell_string = tm.tier_cell_string,
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_group_cd = tm
    .tier_group_cd, internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].
    tier_cell_type_cd = tm.tier_cell_type_cd, internal->tier[ltiergroupreccnt].row[ltierrowreccnt].
    col[ltiercolreccnt].sbeg_effective_dt_tm = concat('"',trim(format(cnvtdatetime(tm
        .beg_effective_dt_tm),"@LONGDATE"),3),'"'),
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].send_effective_dt_tm =
    concat('"',trim(format(cnvtdatetime(tm.end_effective_dt_tm),"@LONGDATE"),3),'"'), internal->tier[
    ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_col_num = tm.tier_col_num,
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_row_num = tm
    .tier_row_num,
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_cell_entity_name =
    tm.tier_cell_entity_name, internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt
    ].stiercelltypedisplay = uar_get_code_display(tm.tier_cell_type_cd), internal->tier[
    ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiergroupdisplay =
    uar_get_code_display(tm.tier_group_cd)
    IF (which_tbl="o")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (o.org_name)
    ELSEIF (which_tbl="hp")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (hp.plan_name)
    ELSEIF (which_tbl="bi")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (bi.ext_description)
    ELSEIF (which_tbl="ps")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (ps.price_sched_desc)
    ELSEIF (which_tbl="cv")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (cv.display)
    ELSEIF (which_tbl="itf")
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (itf.description)
    ELSE
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = trim
     (tm2.tier_cell_string)
    ENDIF
    IF (tm2.tier_cell_type_cd IN (dtiercellcheckdiagcd, dtiercellcheckphyscd))
     IF (tm2.tier_cell_value=1.0)
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = "Y",
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_cell_value_id =
      tm2.tier_cell_value
     ELSE
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay = "N",
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_cell_value_id =
      tm2.tier_cell_value
     ENDIF
    ENDIF
    IF (tm2.tier_cell_type_cd IN (dtiercellinstfinnbrcd, dtiercellflatdiscntcd))
     IF (tm2.tier_cell_type_cd=dtiercellinstfinnbrcd)
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay =
      cnvtstring(tm2.tier_cell_value,17,2)
     ELSE
      internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].stiercelldisplay =
      format(tm2.tier_cell_value,"########.#######")
     ENDIF
     internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col[ltiercolreccnt].tier_cell_value_id =
     null
    ENDIF
   FOOT  tm.tier_col_num
    internal->tier[ltiergroupreccnt].row[ltierrowreccnt].col_qual = ltiercolreccnt
   FOOT  tm.tier_row_num
    internal->tier[ltiergroupreccnt].row_qual = ltierrowreccnt
   FOOT  tm.tier_group_cd
    internal->tier_qual = ltiergroupreccnt
   WITH nocounter
  ;end select
  IF (curqual=0)
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
   SET stat = uar_get_meaning_by_codeset(13036,"CPT MODIFIER",1,dtiercellspt4modvaluecd)
   SET stat = uar_get_meaning_by_codeset(13036,"PROVIDERSPC",1,dtiercellproviderspccd)
   SET stat = uar_get_meaning_by_codeset(13036,"COVERAGE",1,dtiercellcoveragecd)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE migratedata(foo)
   FOR (lrecidx = 1 TO internal->tier_qual)
     FOR (lrowidx = 1 TO internal->tier[lrecidx].row_qual)
       SET line = fillstring(2000,"")
       SET lstartgapidx = 1
       SET lendgapidx = 0
       SET istat = resetvariables(0)
       FOR (lcolidx = 1 TO internal->tier[lrecidx].row[lrowidx].col_qual)
         SET curalias tm1 internal->tier[lrecidx].row[lrowidx].col[lcolidx]
         SET curalias tm2 internal->tier[lrecidx].row[lrowidx]
         IF (lcolidx=1)
          SET stiername = concat(trim(tm1->stiergroupdisplay),",")
          SET stiernameid = concat(trim(cnvtstring(tm1->tier_group_cd,17,2)),",")
          SET sbegindate = concat(trim(tm1->sbeg_effective_dt_tm),","," ",",","0",
           ",")
          SET senddate = concat(trim(tm1->send_effective_dt_tm),","," ",",","0",
           ",")
         ENDIF
         SET istat = storevalues(tm1->tier_cell_type_cd,trim(tm1->stiercelldisplay),tm1->
          tier_cell_value_id,tm1->tier_col_num)
         SET curalias tm1 off
       ENDFOR
       SET llinecnt = (llinecnt+ 1)
       SET stat = alterlist(csvline->line_qual,llinecnt)
       SET istat = buildline(0)
       IF (istat=false)
        SET istat = logdata("Unable to build line appropriately.","APPEND")
       ENDIF
       SET csvline->line_qual[llinecnt].line = trim(sline)
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE exportfrontend(foo)
   SET reply->header_string = concat(
    "TIER_GROUP, TIER_GROUP_CD, TIER_GROUP_COL, BEGIN_DATE, EMPTY, BEGIN_DATE_COL,",
    "END_DATE, EMPTY, END_DATE_COL, FINANCIAL_CLASS,",
    "FINANCIAL_CLASS_CD, FINANCIAL_CLASS_COL, ADMIT_TYPE, ADMIT_TYPE_CD, ADMIT_TYPE_COL,",
    "ORGANIZATION, ORGANIZATION_ID, ORGANIZATION_COL, ORDER_LOCATION, ORDER_LOCATION_CD,",
    "ORDER_LOCATION_COL, SERVICE_RESOURCE, SERVICE_RESOURCE_CD, SERVICE_RESOURCE_COL,",
    "REPORT_PRIORITY, REPORT_PRIORITY_CD, REPORT_PRIORITY_COL, PATIENT_LOCATION,",
    "PATIENT_LOCATION_CD, PATIENT_LOCATION_COL, COLLECTION_PRIORITY, COLLECTION_PRIORITY_CD,",
    "COLLECTION_PRIORITY_COL, PERFORMING_LOCATION, PERFORMING_LOCATION_CD,",
    "PERFORMING_LOCATION_COL, ACTIVITY_TYPE, ACTIVITY_TYPE_CD, ACTIVITY_TYPE_COL,",
    "ACTIVITY_SUB_TYPE, ACTIVITY_SUB_TYPE_CD, ACTIVITY_SUB_TYPE_COL, HEALTH_PLAN,",
    "HEALTH_PLAN_ID, HEALTH_PLAN_COL, PRIORITY, PRIORITY_CD, PRIORITY_COL,",
    "ORDER_PHYSICIAN, ORDER_PHYSICIAN_ID, ORDER_PHYSICIAN_COL, ORDER_PHYSICIAN_GRP,",
    "ORDER_PHYSICIAN_GRP_ID, ORDER_PHYSICIAN_GRP_COL, RENDER_PHYSICIAN, RENDER_PHYSICIAN_ID,",
    "RENDER_PHYSICIAN_COL, RENDER_PHYSICIAN_GRP, RENDER_PHYSICIAN_GRP_ID,",
    "RENDER_PHYSICIAN_GRP_COL, MED_SERVICE, MED_SERVICE_CD, MED_SERVICE_COL,",
    "ENCOUNTER_TYPE, ENCOUNTER_TYPE_CD, ENCOUNTER_TYPE_COL, INSURANCE_ORG, INSURANCE_ORG_CD,",
    "INSURANCE_ORG_COL, CPT4_MODIFIER_VALUE, CPT4_MODIFIER_VALUE_CD,",
    "CPT4_MODIFIER_VALUE_COL, PROVIDER_SPC_VALUE, PROVIDER_SPC_VALUE_CD, PROVIDER_SPC_VALUE_COL,",
    "SEPERATOR, EMPTY, SEPERATOR_COL, CHARGE_PROCESSING,",
    "CHARGE_PROCESSING_CD, CHARGE_PROCESSING_COL, PRICE_SCHEDULE, PRICE_SCHEDULE_ID,",
    "PRICE_SCHEDULE_COL, LIST_PRICE_SCHEDULE, LIST_PRICE_SCHEDULE_ID,",
    "LIST_PRICE_SCHEDULE_COL, CDM_SCHEDULE, CDM_SCHEDULE_CD, CDM_SCHEDULE_COL, CPT4_CODE,",
    "CPT4_CODE_CD, CPT4_CODE_COL, CPT4_MODIFIER, CPT4_MODIFIER_CD, CPT4_MODIFIER_COL,",
    "SNOMED, SNOMED_CD, SNOMED_COL, HCPCS, HCPCS_CD, HCPCS_COL, ICD9, ICD9_CD, ICD9_COL,",
    "ICD9_PROCEDURE, ICD9_PROCEDURE_CD, ICD9_PROCEDURE_COL, REVENUE, REVENUE_CD,",
    "REVENUE_COL, HOLD_SUSPENSE, HOLD_SUSPENSE_CD, HOLD_SUSPENSE_COL, GENERAL_LEDGER,",
    "GENERAL_LEDGER_CD, GENERAL_LEDGER_COL, CHECK_DIAGNOSIS, EMPTY, CHECK_DIAGNOSIS_COL,",
    "CHECK_PHYSICIAN, EMPTY, CHECK_PHYSICIAN_COL, COST_CENTER, COST_CENTER_CD,",
    "COST_CENTER_COL, FLAT_DISCOUNT, EMPTY, FLAT_DISCOUNT_COL, ADD_ON, ADD_ON_ID,",
    "ADD_ON_COL, INTERFACE_FILE, INTERFACE_FILE_ID, INTERFACE_FILE_COL, INSTITUTIONAL_FIN,",
    "EMPTY, INSTITUTIONAL_FIN_COL, CLIENT_REPORT_TYPE, CLIENT_REPORT_TYPE_CD,",
    "CLIENT_REPORT_TYPE_COL, COVERAGE, COVERAGE_CD, COVERAGE_COL")
   SET reply->line_qual_cnt = size(csvline->line_qual,5)
   SET stat = alterlist(reply->line_qual,reply->line_qual_cnt)
   FOR (lrecidx = 1 TO size(csvline->line_qual,5))
     SET reply->line_qual[lrecidx].line = csvline->line_qual[lrecidx].line
   ENDFOR
   CALL echo("Exported to front-end...")
 END ;Subroutine
 SUBROUTINE createcsv(foo)
   SELECT INTO value(filename)
    FROM (dummyt d1  WITH seq = value(llinecnt))
    HEAD REPORT
     row 0, "TIER_GROUP, TIER_GROUP_CD, TIER_GROUP_COL, BEGIN_DATE, EMPTY, BEGIN_DATE_COL,",
     "END_DATE, EMPTY, END_DATE_COL, FINANCIAL_CLASS,",
     "FINANCIAL_CLASS_CD, FINANCIAL_CLASS_COL, ADMIT_TYPE, ADMIT_TYPE_CD, ADMIT_TYPE_COL,",
     "ORGANIZATION, ORGANIZATION_ID, ORGANIZATION_COL, ORDER_LOCATION, ORDER_LOCATION_CD,",
     "ORDER_LOCATION_COL, SERVICE_RESOURCE, SERVICE_RESOURCE_CD, SERVICE_RESOURCE_COL,",
     "REPORT_PRIORITY, REPORT_PRIORITY_CD, REPORT_PRIORITY_COL, PATIENT_LOCATION,",
     "PATIENT_LOCATION_CD, PATIENT_LOCATION_COL, COLLECTION_PRIORITY, COLLECTION_PRIORITY_CD,",
     "COLLECTION_PRIORITY_COL, PERFORMING_LOCATION, PERFORMING_LOCATION_CD,",
     "PERFORMING_LOCATION_COL, ACTIVITY_TYPE, ACTIVITY_TYPE_CD, ACTIVITY_TYPE_COL,",
     "ACTIVITY_SUB_TYPE, ACTIVITY_SUB_TYPE_CD, ACTIVITY_SUB_TYPE_COL, HEALTH_PLAN,",
     "HEALTH_PLAN_ID, HEALTH_PLAN_COL, PRIORITY, PRIORITY_CD, PRIORITY_COL,",
     "ORDER_PHYSICIAN, ORDER_PHYSICIAN_ID, ORDER_PHYSICIAN_COL, ORDER_PHYSICIAN_GRP,",
     "ORDER_PHYSICIAN_GRP_ID, ORDER_PHYSICIAN_GRP_COL, RENDER_PHYSICIAN, RENDER_PHYSICIAN_ID,",
     "RENDER_PHYSICIAN_COL, RENDER_PHYSICIAN_GRP, RENDER_PHYSICIAN_GRP_ID,",
     "RENDER_PHYSICIAN_GRP_COL, MED_SERVICE, MED_SERVICE_CD, MED_SERVICE_COL,",
     "ENCOUNTER_TYPE, ENCOUNTER_TYPE_CD, ENCOUNTER_TYPE_COL, INSURANCE_ORG, INSURANCE_ORG_CD,",
     "INSURANCE_ORG_COL, CPT4_MODIFIER_VALUE, CPT4_MODIFIER_VALUE_CD,",
     "CPT4_MODIFIER_VALUE_COL, PROVIDER_SPC_VALUE, PROVIDER_SPC_VALUE_CD, PROVIDER_SPC_VALUE_COL,",
     "SEPERATOR, EMPTY, SEPERATOR_COL, CHARGE_PROCESSING,",
     "CHARGE_PROCESSING_CD, CHARGE_PROCESSING_COL, PRICE_SCHEDULE, PRICE_SCHEDULE_ID,",
     "PRICE_SCHEDULE_COL, LIST_PRICE_SCHEDULE, LIST_PRICE_SCHEDULE_ID,",
     "LIST_PRICE_SCHEDULE_COL, CDM_SCHEDULE, CDM_SCHEDULE_CD, CDM_SCHEDULE_COL, CPT4_CODE,",
     "CPT4_CODE_CD, CPT4_CODE_COL, CPT4_MODIFIER, CPT4_MODIFIER_CD, CPT4_MODIFIER_COL,",
     "SNOMED, SNOMED_CD, SNOMED_COL, HCPCS, HCPCS_CD, HCPCS_COL, ICD9, ICD9_CD, ICD9_COL,",
     "ICD9_PROCEDURE, ICD9_PROCEDURE_CD, ICD9_PROCEDURE_COL, REVENUE, REVENUE_CD,",
     "REVENUE_COL, HOLD_SUSPENSE, HOLD_SUSPENSE_CD, HOLD_SUSPENSE_COL, GENERAL_LEDGER,",
     "GENERAL_LEDGER_CD, GENERAL_LEDGER_COL, CHECK_DIAGNOSIS, EMPTY, CHECK_DIAGNOSIS_COL,",
     "CHECK_PHYSICIAN, EMPTY, CHECK_PHYSICIAN_COL, COST_CENTER, COST_CENTER_CD,",
     "COST_CENTER_COL, FLAT_DISCOUNT, EMPTY, FLAT_DISCOUNT_COL, ADD_ON, ADD_ON_ID,",
     "ADD_ON_COL, INTERFACE_FILE, INTERFACE_FILE_ID, INTERFACE_FILE_COL, INSTITUTIONAL_FIN,",
     "EMPTY, INSTITUTIONAL_FIN_COL, CLIENT_REPORT_TYPE, CLIENT_REPORT_TYPE_CD,",
     "CLIENT_REPORT_TYPE_COL, COVERAGE, COVERAGE_CD, COVERAGE_COL"
    DETAIL
     line = fillstring(2000," "), line = csvline->line_qual[d1.seq].line, row + 1,
     line
    WITH maxcol = 3000, maxrow = 3000, nocounter,
     nullreport, outerjoin = d1
   ;end select
 END ;Subroutine
 SUBROUTINE storevalues(dcd,sdisp,did,lcol)
   CASE (dcd)
    OF dtiercellactivtypecd:
     SET sactivtype = concat('"',trim(sdisp),'"',",")
     SET sactivtypecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sactivtypecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercelladdoncd:
     SET saddonbill = concat('"',trim(sdisp),'"',",")
     SET saddonbillid = concat(trim(cnvtstring(did,17,2)),",")
     SET saddoncol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcdmschedcd:
     SET scdmsched = concat('"',trim(sdisp),'"',",")
     SET scdmschedcd = concat(trim(cnvtstring(did,17,2)),",")
     SET scdmschedcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellchargeproccd:
     SET schargeprocess = concat('"',trim(sdisp),'"',",")
     SET schargeprocesscd = concat(trim(cnvtstring(did,17,2)),",")
     SET schargeprocesscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellclientrpttypecd:
     SET sclientrpttype = concat('"',trim(sdisp),'"',",")
     SET sclientrpttypecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sclientrpttypecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcolprioritycd:
     SET sclltnpriority = concat('"',trim(sdisp),'"',",")
     SET sclltnprioritycd = concat(trim(cnvtstring(did,17,2)),",")
     SET sclltnprioritycol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcostcentercd:
     SET scostcenter = concat('"',trim(sdisp),'"',",")
     SET scostcentercd = concat(trim(cnvtstring(did,17,2)),",")
     SET scostcentercol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcpt4cd:
     SET scpt4 = concat('"',trim(sdisp),'"',",")
     SET scpt4cd = concat(trim(cnvtstring(did,17,2)),",")
     SET scpt4col = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcheckdiagcd:
     SET scheckdiag = concat('"',trim(sdisp),'"',",")
     SET scheckdiagcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellfinclasscd:
     SET sfinclass = concat('"',trim(sdisp),'"',",")
     SET sfinclasscd = concat(trim(cnvtstring(did,17,2)),",")
     SET sfinclasscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellflatdiscntcd:
     SET sflatdiscount = concat('"',trim(sdisp),'"',",")
     SET sflatdiscountcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellgenledgercd:
     SET sgenledger = concat('"',trim(sdisp),'"',",")
     SET sgenledgercd = concat(trim(cnvtstring(did,17,2)),",")
     SET sgenledgercol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellhcpcscd:
     SET shcpcs = concat('"',trim(sdisp),'"',",")
     SET shcpcscd = concat(trim(cnvtstring(did,17,2)),",")
     SET shcpcscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellhealthplancd:
     SET shealthplan = concat('"',trim(sdisp),'"',",")
     SET shealthplanid = concat(trim(cnvtstring(did,17,2)),",")
     SET shealthplancol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellholdsuspensecd:
     SET sholdsuspense = concat('"',trim(sdisp),'"',",")
     SET sholdsuspensecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sholdsuspensecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellicd9cd:
     SET sicd9 = concat('"',trim(sdisp),'"',",")
     SET sicd9cd = concat(trim(cnvtstring(did,17,2)),",")
     SET sicd9col = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellinstfinnbrcd:
     SET sinstitfin = concat('"',trim(sdisp),'"',",")
     SET sinstitfincol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellinterfacefilecd:
     SET sinterfacefile = concat('"',trim(sdisp),'"',",")
     SET sinterfacefileid = concat(trim(cnvtstring(did,17,2)),",")
     SET sinterfacefilecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercelllistpriceschedcd:
     SET slistprice = concat('"',trim(sdisp),'"',",")
     SET slistpriceid = concat(trim(cnvtstring(did,17,2)),",")
     SET slistpricecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcpt4modcd:
     SET scpt4mod = concat('"',trim(sdisp),'"',",")
     SET scpt4modcd = concat(trim(cnvtstring(did,17,2)),",")
     SET scpt4modcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellordloccd:
     SET sordloc = concat('"',trim(sdisp),'"',",")
     SET sordloccd = concat(trim(cnvtstring(did,17,2)),",")
     SET sordloccol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellorgcd:
     SET sorg = concat('"',trim(sdisp),'"',",")
     SET sorgid = concat(trim(cnvtstring(did,17,2)),",")
     SET sorgcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellpatloccd:
     SET spatloc = concat('"',trim(sdisp),'"',",")
     SET spatloccd = concat(trim(cnvtstring(did,17,2)),",")
     SET spatloccol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellperfloccd:
     SET sperfloc = concat('"',trim(sdisp),'"',",")
     SET sperfloccd = concat(trim(cnvtstring(did,17,2)),",")
     SET sperfloccol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcheckphyscd:
     SET scheckphys = concat('"',trim(sdisp),'"',",")
     SET scheckphyscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellpriceschedcd:
     SET spricesched = concat('"',trim(sdisp),'"',",")
     SET spriceschedid = concat(trim(cnvtstring(did,17,2)),",")
     SET spriceschedcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellprioritycd:
     SET spriority = concat('"',trim(sdisp),'"',",")
     SET sprioritycd = concat(trim(cnvtstring(did,17,2)),",")
     SET sprioritycol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellicd9proccd:
     SET sicd9proc = concat('"',trim(sdisp),'"',",")
     SET sicd9proccd = concat(trim(cnvtstring(did,17,2)),",")
     SET sicd9proccol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellrevenuecd:
     SET srevenue = concat('"',trim(sdisp),'"',",")
     SET srevenuecd = concat(trim(cnvtstring(did,17,2)),",")
     SET srevenuecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellrptprioritycd:
     SET srptpriority = concat('"',trim(sdisp),'"',",")
     SET srptprioritycd = concat(trim(cnvtstring(did,17,2)),",")
     SET srptprioritycol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellserviceresourcecd:
     SET sservresource = concat('"',trim(sdisp),'"',",")
     SET sservresourcecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sservresourcecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercelladmittypecd:
     SET sadmittype = concat('"',trim(sdisp),'"',",")
     SET sadmittypecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sadmittypecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellsnomedcd:
     SET ssnomed = concat('"',trim(sdisp),'"',",")
     SET ssnomedcd = concat(trim(cnvtstring(did,17,2)),",")
     SET ssnomedcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellactivsubtypecd:
     SET sactivsubtype = concat('"',trim(sdisp),'"',",")
     SET sactivsubtypecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sactivsubtypecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellphysordercd:
     SET sorderphys = concat('"',trim(sdisp),'"',",")
     SET sorderphysid = concat(trim(cnvtstring(did,17,2)),",")
     SET sorderphyscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellphysordergroupcd:
     SET sorderphysgroup = concat('"',trim(sdisp),'"',",")
     SET sorderphysgroupid = concat(trim(cnvtstring(did,17,2)),",")
     SET sorderphysgroupcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellphysrendercd:
     SET srenderphys = concat('"',trim(sdisp),'"',",")
     SET srenderphysid = concat(trim(cnvtstring(did,17,2)),",")
     SET srenderphyscol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellphysrendergroupcd:
     SET srenderphysgroup = concat('"',trim(sdisp),'"',",")
     SET srenderphysgroupid = concat(trim(cnvtstring(did,17,2)),",")
     SET srenderphysgroupcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellmedservicecd:
     SET smedservice = concat('"',trim(sdisp),'"',",")
     SET smedservicecd = concat(trim(cnvtstring(did,17,2)),",")
     SET smedservicecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellencountertypecd:
     SET sencountertype = concat('"',trim(sdisp),'"',",")
     SET sencountertypecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sencountertypecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellinsorganizationcd:
     SET sinsureorg = concat('"',trim(sdisp),'"',",")
     SET sinsureorgid = concat(trim(cnvtstring(did,17,2)),",")
     SET sinsureorgcol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellspt4modvaluecd:
     SET scpt4modvalue = concat('"',trim(sdisp),'"',",")
     SET scpt4modvaluecd = concat(trim(cnvtstring(did,17,2)),",")
     SET scpt4modvaluecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellcoveragecd:
     SET scoverage = concat('"',trim(sdisp),'"',",")
     SET scoveragecd = concat(trim(cnvtstring(did,17,2)),",")
     SET scoveragecol = concat(trim(cnvtstring(lcol)),",")
    OF dtiercellproviderspccd:
     SET sproviderspcvalue = concat('"',trim(sdisp),'"',",")
     SET sproviderspcvaluecd = concat(trim(cnvtstring(did,17,2)),",")
     SET sproviderspcvaluecol = concat(trim(cnvtstring(lcol)),",")
    ELSE
     SET sdisp = sdisp
     CALL echo("We didn't find a match!")
     CALL echo(build("Value we couldn't match on: ",dcd))
   ENDCASE
 END ;Subroutine
 SUBROUTINE buildline(foo)
   SET sline = concat(trim(stiername),trim(stiernameid),trim(snamecol))
   SET sline = concat(trim(sline),trim(sbegindate),trim(senddate))
   SET sline = concat(trim(sline),trim(sfinclass),trim(sfinclasscd),trim(sfinclasscol))
   SET sline = concat(trim(sline),trim(sadmittype),trim(sadmittypecd),trim(sadmittypecol))
   SET sline = concat(trim(sline),trim(sorg),trim(sorgid),trim(sorgcol))
   SET sline = concat(trim(sline),trim(sordloc),trim(sordloccd),trim(sordloccol))
   SET sline = concat(trim(sline),trim(sservresource),trim(sservresourcecd),trim(sservresourcecol))
   SET sline = concat(trim(sline),trim(srptpriority),trim(srptprioritycd),trim(srptprioritycol))
   SET sline = concat(trim(sline),trim(spatloc),trim(spatloccd),trim(spatloccol))
   SET sline = concat(trim(sline),trim(sclltnpriority),trim(sclltnprioritycd),trim(sclltnprioritycol)
    )
   SET sline = concat(trim(sline),trim(sperfloc),trim(sperfloccd),trim(sperfloccol))
   SET sline = concat(trim(sline),trim(sactivtype),trim(sactivtypecd),trim(sactivtypecol))
   SET sline = concat(trim(sline),trim(sactivsubtype),trim(sactivsubtypecd),trim(sactivsubtypecol))
   SET sline = concat(trim(sline),trim(shealthplan),trim(shealthplanid),trim(shealthplancol))
   SET sline = concat(trim(sline),trim(spriority),trim(sprioritycd),trim(sprioritycol))
   SET sline = concat(trim(sline),trim(sorderphys),trim(sorderphysid),trim(sorderphyscol))
   SET sline = concat(trim(sline),trim(sorderphysgroup),trim(sorderphysgroupid),trim(
     sorderphysgroupcol))
   SET sline = concat(trim(sline),trim(srenderphys),trim(srenderphysid),trim(srenderphyscol))
   SET sline = concat(trim(sline),trim(srenderphysgroup),trim(srenderphysgroupid),trim(
     srenderphysgroupcol))
   SET sline = concat(trim(sline),trim(smedservice),trim(smedservicecd),trim(smedservicecol))
   SET sline = concat(trim(sline),trim(sencountertype),trim(sencountertypecd),trim(sencountertypecol)
    )
   SET sline = concat(trim(sline),trim(sinsureorg),trim(sinsureorgid),trim(sinsureorgcol))
   SET sline = concat(trim(sline),trim(scpt4modvalue),trim(scpt4modvaluecd),trim(scpt4modvaluecol))
   SET sline = concat(trim(sline),trim(sproviderspcvalue),trim(sproviderspcvaluecd),trim(
     sproviderspcvaluecol))
   SET sline = concat(trim(sline),trim(sseperator),trim(sseperatorempty),trim(sseperatorcol))
   SET sline = concat(trim(sline),trim(schargeprocess),trim(schargeprocesscd),trim(schargeprocesscol)
    )
   SET sline = concat(trim(sline),trim(spricesched),trim(spriceschedid),trim(spriceschedcol))
   SET sline = concat(trim(sline),trim(slistprice),trim(slistpriceid),trim(slistpricecol))
   SET sline = concat(trim(sline),trim(scdmsched),trim(scdmschedcd),trim(scdmschedcol))
   SET sline = concat(trim(sline),trim(scpt4),trim(scpt4cd),trim(scpt4col))
   SET sline = concat(trim(sline),trim(scpt4mod),trim(scpt4modcd),trim(scpt4modcol))
   SET sline = concat(trim(sline),trim(ssnomed),trim(ssnomedcd),trim(ssnomedcol))
   SET sline = concat(trim(sline),trim(shcpcs),trim(shcpcscd),trim(shcpcscol))
   SET sline = concat(trim(sline),trim(sicd9),trim(sicd9cd),trim(sicd9col))
   SET sline = concat(trim(sline),trim(sicd9proc),trim(sicd9proccd),trim(sicd9proccol))
   SET sline = concat(trim(sline),trim(srevenue),trim(srevenuecd),trim(srevenuecol))
   SET sline = concat(trim(sline),trim(sholdsuspense),trim(sholdsuspensecd),trim(sholdsuspensecol))
   SET sline = concat(trim(sline),trim(sgenledger),trim(sgenledgercd),trim(sgenledgercol))
   SET sline = concat(trim(sline),trim(scheckdiag),trim(scheckdiagempty),trim(scheckdiagcol))
   SET sline = concat(trim(sline),trim(scheckphys),trim(scheckphysempty),trim(scheckphyscol))
   SET sline = concat(trim(sline),trim(scostcenter),trim(scostcentercd),trim(scostcentercol))
   SET sline = concat(trim(sline),trim(sflatdiscount),trim(sflatdiscountempty),trim(sflatdiscountcol)
    )
   SET sline = concat(trim(sline),trim(saddonbill),trim(saddonbillid),trim(saddoncol))
   SET sline = concat(trim(sline),trim(sinterfacefile),trim(sinterfacefileid),trim(sinterfacefilecol)
    )
   SET sline = concat(trim(sline),trim(sinstitfin),trim(sinstitfinempty),trim(sinstitfincol))
   SET sline = concat(trim(sline),trim(sclientrpttype),trim(sclientrpttypecd),trim(sclientrpttypecol)
    )
   SET sline = concat(trim(sline),trim(scoverage),trim(scoveragecd),trim(scoveragecol))
   SET llinelength = textlen(sline)
   IF (substring(llinelength,1,sline)=",")
    SET sline = substring(1,(llinelength - 1),sline)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE resetvariables(foo)
   SET stiername = concat("",",")
   SET stiernameid = concat("",",")
   SET sbegindate = concat("",",")
   SET sbegindateempty = concat("",",")
   SET senddate = concat("",",")
   SET senddateempty = concat("",",")
   SET sfinclass = concat("",",")
   SET sfinclasscd = concat("",",")
   SET sadmittype = concat("",",")
   SET sadmittypecd = concat("",",")
   SET sorg = concat("",",")
   SET sorgid = concat("",",")
   SET sordloc = concat("",",")
   SET sordloccd = concat("",",")
   SET sservresource = concat("",",")
   SET sservresourcecd = concat("",",")
   SET srptpriority = concat("",",")
   SET srptprioritycd = concat("",",")
   SET spatloc = concat("",",")
   SET spatloccd = concat("",",")
   SET sclltnpriority = concat("",",")
   SET sclltnprioritycd = concat("",",")
   SET sperfloc = concat("",",")
   SET sperfloccd = concat("",",")
   SET sactivtype = concat("",",")
   SET sactivtypecd = concat("",",")
   SET sactivsubtype = concat("",",")
   SET sactivsubtypecd = concat("",",")
   SET shealthplan = concat("",",")
   SET shealthplanid = concat("",",")
   SET spriority = concat("",",")
   SET sprioritycd = concat("",",")
   SET sorderphys = concat("",",")
   SET sorderphysid = concat("",",")
   SET sorderphysgroup = concat("",",")
   SET sorderphysgroupid = concat("",",")
   SET srenderphys = concat("",",")
   SET srenderphysid = concat("",",")
   SET srenderphysgroup = concat("",",")
   SET srenderphysgroupid = concat("",",")
   SET smedservice = concat("",",")
   SET smedservicecd = concat("",",")
   SET sencountertype = concat("",",")
   SET sencountertypecd = concat("",",")
   SET sinsureorg = concat("",",")
   SET sinsureorgid = concat("",",")
   SET scpt4modvalue = concat("",",")
   SET scpt4modvaluecd = concat("",",")
   SET schargeprocess = concat("",",")
   SET schargeprocesscd = concat("",",")
   SET spricesched = concat("",",")
   SET spriceschedid = concat("",",")
   SET slistprice = concat("",",")
   SET slistpriceid = concat("",",")
   SET scdmsched = concat("",",")
   SET scdmschedcd = concat("",",")
   SET scpt4 = concat("",",")
   SET scpt4cd = concat("",",")
   SET scpt4mod = concat("",",")
   SET scpt4modcd = concat("",",")
   SET ssnomed = concat("",",")
   SET ssnomedcd = concat("",",")
   SET shcpcs = concat("",",")
   SET shcpcscd = concat("",",")
   SET sicd9 = concat("",",")
   SET sicd9cd = concat("",",")
   SET sicd9proc = concat("",",")
   SET sicd9proccd = concat("",",")
   SET srevenue = concat("",",")
   SET srevenuecd = concat("",",")
   SET sholdsuspense = concat("",",")
   SET sholdsuspensecd = concat("",",")
   SET sgenledger = concat("",",")
   SET sgenledgercd = concat("",",")
   SET scheckdiag = concat("",",")
   SET scheckdiagempty = concat("",",")
   SET scheckphys = concat("",",")
   SET scheckphysempty = concat("",",")
   SET scostcenter = concat("",",")
   SET scostcentercd = concat("",",")
   SET sflatdiscount = concat("",",")
   SET sflatdiscountempty = concat("",",")
   SET saddonbill = concat("",",")
   SET saddonbillid = concat("",",")
   SET sinterfacefile = concat("",",")
   SET sinterfacefileid = concat("",",")
   SET sinstitfin = concat("",",")
   SET sinstitfinempty = concat("",",")
   SET sclientrpttype = concat("",",")
   SET sclientrpttypecd = concat("",",")
   SET sproviderspcvalue = concat("",",")
   SET sproviderspcvaluecd = concat("",",")
   SET sseperator = concat("",",")
   SET sseperatorempty = concat("",",")
   SET scoverage = concat("",",")
   SET scoveragecd = concat("",",")
   SET snamecol = concat("0",",")
   SET sfinclasscol = concat("0",",")
   SET sadmittypecol = concat("0",",")
   SET sorgcol = concat("0",",")
   SET sordloccol = concat("0",",")
   SET sservresourcecol = concat("0",",")
   SET srptprioritycol = concat("0",",")
   SET spatloccol = concat("0",",")
   SET sclltnprioritycol = concat("0",",")
   SET sperfloccol = concat("0",",")
   SET sactivtypecol = concat("0",",")
   SET shealthplancol = concat("0",",")
   SET sprioritycol = concat("0",",")
   SET schargeprocesscol = concat("0",",")
   SET spriceschedcol = concat("0",",")
   SET slistpricecol = concat("0",",")
   SET scdmschedcol = concat("0",",")
   SET scpt4col = concat("0",",")
   SET scpt4modcol = concat("0",",")
   SET shcpcscol = concat("0",",")
   SET sicd9col = concat("0",",")
   SET sicd9proccol = concat("0",",")
   SET srevenuecol = concat("0",",")
   SET sholdsuspensecol = concat("0",",")
   SET sgenledgercol = concat("0",",")
   SET scheckdiagcol = concat("0",",")
   SET scheckphyscol = concat("0",",")
   SET scostcentercol = concat("0",",")
   SET sflatdiscountcol = concat("0",",")
   SET saddoncol = concat("0",",")
   SET sinterfacefilecol = concat("0",",")
   SET sinstitfincol = concat("0",",")
   SET sclientrpttypecol = concat("0",",")
   SET ssnomedcol = concat("0",",")
   SET sactivsubtypecol = concat("0",",")
   SET sorderphyscol = concat("0",",")
   SET sorderphysgroupcol = concat("0",",")
   SET srenderphyscol = concat("0",",")
   SET srenderphysgroupcol = concat("0",",")
   SET smedservicecol = concat("0",",")
   SET sencountertypecol = concat("0",",")
   SET sinsureorgcol = concat("0",",")
   SET scpt4modvaluecol = concat("0",",")
   SET scoveragecol = concat("0",",")
   SET sproviderspcvaluecol = concat("0",",")
   RETURN(true)
 END ;Subroutine
#end_program
 SET istat = logdata("","CLOSE")
 FREE RECORD internal
 FREE RECORD csvline
END GO
