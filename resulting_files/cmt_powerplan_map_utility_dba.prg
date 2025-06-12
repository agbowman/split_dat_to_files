CREATE PROGRAM cmt_powerplan_map_utility:dba
 PAINT
 CALL video("R")
 CALL clear(1,1,80)
 CALL text(1,25,"PowerPlan MAP UTILITY")
 CALL video("N")
 DECLARE find_powerplan(desc=vc,cki=vc) = null
 DECLARE find_mapped_powerplans(fmp=i2) = null
 DECLARE upd_cki(dsc=vc,cki=vc,dsc2=vc,pwid=f8) = null
 DECLARE create_powerplan_list(ds=vc,ccki=vc) = null
 DECLARE check_maps() = null
 DECLARE pop_std_list(bcd=i2) = null
 DECLARE down_arrow(str1=vc) = null
 DECLARE up_arrow(strup=vc) = null
 DECLARE create_std_box(mxcnt=i2) = null
 DECLARE clear_screen(abc=i2) = null
 DECLARE get_code_value(cv=i4,cdf=vc) = f8
 DECLARE txt = vc
 DECLARE txt2 = vc
 DECLARE tmp1 = i4
 DECLARE holdstr60 = c60
 DECLARE holdstr20 = c20
 DECLARE holdstr = c75
 DECLARE confirm = c1
 DECLARE commit_ind = i2
 DECLARE change_ind = i2
 DECLARE numscol = i4 WITH noconstant(75)
 DECLARE numsrow = i4 WITH noconstant(14)
 DECLARE srowoff = i4 WITH noconstant(6)
 DECLARE scoloff = i4 WITH noconstant(2)
 DECLARE arow = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE maxcnt = i4 WITH noconstant(0)
 DECLARE pp_sz = i4 WITH noconstant(0)
 DECLARE mpp_sz = i4 WITH noconstant(0)
 DECLARE parse_ln = vc
 SET pp_sz = 0
 RECORD powerplan_std(
   1 lst[*]
     2 desc = vc
     2 concept_cki = vc
     2 mapped = i2
 )
 CALL pop_std_list(1)
 SET confirm = " "
 SET commit_ind = 0
 SET change_ind = false
#pick_mode
 CALL clear_screen(0)
 CALL text(3,5,"PROGRAM OPTIONS ")
 CALL text(5,1,"01 SHOW LIST OF UNMAPPED POWERPLANS")
 CALL text(6,1,"02 Exit program")
 CALL text(23,1,"Choose an option:")
 CALL accept(23,19,"99;",2
  WHERE curaccept IN (1, 2))
#restart
 CASE (curaccept)
  OF 1:
   GO TO powerplan_map
  OF 3:
   CALL find_mapped_powerplans(0)
  OF 2:
   GO TO exit_program
 ENDCASE
 GO TO pick_mode
#powerplan_map
 CALL clear_screen(0)
 CALL pop_std_list(1)
 CALL text(3,2,"Unmapped PowerPlan Items")
 CALL text(5,67,"Total:  ")
 CALL text(5,75,cnvtstring(pp_sz,4))
 CALL create_std_box(pp_sz)
 CALL text(6,8,"PowerPlan Description")
 WHILE (cnt <= numsrow
  AND cnt <= maxcnt
  AND cnt <= pp_sz)
   SET holdstr60 = trim(powerplan_std->lst[cnt].desc)
   SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60)
   CALL scrolltext(cnt,holdstr)
   SET cnt = (cnt+ 1)
 ENDWHILE
 SET cnt = 1
 SET arow = 1
 CALL text(23,1,"Select a PowerPlan to map      (enter 000 to go back)")
 SET pick = 0
 WHILE (pick=0)
  CALL accept(23,30,"999;S",cnt)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     CALL clear_screen(0)
     GO TO pick_mode
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET pick = cnvtint(curaccept)
     CALL clear_screen(0)
     CALL find_powerplan(powerplan_std->lst[pick].desc,powerplan_std->lst[pick].concept_cki)
    ELSE
     CALL clear_screen(0)
     GO TO pick_mode
    ENDIF
   OF 1:
    IF (cnt < maxcnt)
     SET cnt = (cnt+ 1)
     SET holdstr60 = trim(powerplan_std->lst[cnt].desc)
     SET holdstr20 = ""
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL down_arrow(holdstr)
    ENDIF
   OF 2:
    IF (cnt > 1)
     SET cnt = (cnt - 1)
     SET holdstr60 = trim(powerplan_std->lst[cnt].desc)
     SET holdstr20 = ""
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
     CALL up_arrow(holdstr)
    ENDIF
   OF 3:
   OF 4:
   OF 6:
    IF (numsrow < maxcnt)
     SET cnt = ((cnt+ numsrow) - 1)
     IF (((cnt+ numsrow) > maxcnt))
      SET cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(powerplan_std->lst[cnt].desc)
       SET holdstr20 = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL scrolltext(arow,holdstr)
       SET arow = (arow+ 1)
     ENDWHILE
     SET arow = 1
     SET cnt = ((cnt - numsrow)+ 1)
    ENDIF
   OF 5:
    IF (((cnt - numsrow) > 0))
     SET cnt = (cnt - numsrow)
    ELSE
     SET cnt = 1
    ENDIF
    SET tmp1 = cnt
    SET arow = 1
    WHILE (arow <= numsrow
     AND cnt < maxcnt)
      SET holdstr60 = trim(powerplan_std->lst[cnt].desc)
      SET holdstr20 = ""
      SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
      CALL scrolltext(arow,holdstr)
      SET cnt = (cnt+ 1)
      SET arow = (arow+ 1)
    ENDWHILE
    SET cnt = tmp1
    SET arow = 1
  ENDCASE
 ENDWHILE
 CALL clear_screen(0)
 CALL text(23,1,"Map more? (Y/N)   ")
 CALL accept(23,29,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO powerplan_map
  OF "N":
   GO TO pick_mode
 ENDCASE
 GO TO pick_mode
#powerplan_map_exit
 SUBROUTINE upd_cki(dsc,cki,dsc2,pw_id)
   CALL clear_screen(0)
   CALL text(3,2,"Map Standard:")
   CALL text(3,17,trim(dsc2))
   CALL text(4,11," To:")
   CALL text(4,17,trim(dsc))
   CALL text(5,11,"CKI:")
   CALL text(5,17,trim(cki))
   CALL text(23,1,"Correct Mapping? (Y/N)   ")
   CALL accept(23,29,"C;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   CASE (curaccept)
    OF "Y":
     SET mapind = true
    OF "N":
     SET mapind = false
   ENDCASE
   IF (mapind=true)
    UPDATE  FROM pathway_catalog pc
     SET pc.concept_cki = cki, pc.updt_cnt = (pc.updt_cnt+ 1), pc.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE pc.pathway_catalog_id=pw_id
     WITH nocounter
    ;end update
    SET change_ind = true
   ENDIF
 END ;Subroutine
 SUBROUTINE show_processing(x)
  CALL clear_screen(0)
  CALL text(23,1,"Processing...")
 END ;Subroutine
 SUBROUTINE down_arrow(str1)
   IF (arow=numsrow)
    CALL scrolldown(arow,arow,str1)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,str1)
   ENDIF
 END ;Subroutine
 SUBROUTINE up_arrow(strup)
   IF (arow=1)
    CALL scrollup(arow,arow,strup)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,strup)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_std_box(mxcnt)
   SET maxcnt = mxcnt
   SET cnt = 1
   SET holdstr = ""
   CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
   CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 END ;Subroutine
 SUBROUTINE clear_screen(abc)
   IF (abc=0)
    CALL clear(3,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_powerplan_list(d,c)
   DECLARE mapped = i2
   SET mapped = false
   SELECT INTO "nl:"
    FROM pathway_catalog pc
    PLAN (pc
     WHERE trim(c)=pc.concept_cki)
    DETAIL
     mapped = true
    WITH nocounter
   ;end select
   IF (mapped=false)
    SET pp_sz = (pp_sz+ 1)
    SET stat = alterlist(powerplan_std->lst,pp_sz)
    SET powerplan_std->lst[pp_sz].desc = trim(d)
    SET powerplan_std->lst[pp_sz].concept_cki = trim(c)
    SET powerplan_std->lst[pp_sz].mapped = false
   ENDIF
 END ;Subroutine
 SUBROUTINE find_powerplan(desc,cki)
   SET tmp_pp_sz = 0
   RECORD powerplan(
     1 lst[*]
       2 desc = vc
       2 concept_cki = vc
       2 mapped = i2
       2 pathway_id = f8
   )
   SELECT INTO "nl:"
    FROM pathway_catalog o
    PLAN (o
     WHERE o.pathway_catalog_id > 0.0
      AND o.type_mean IN ("CAREPLAN", "PATHWAY")
      AND o.active_ind=1
      AND o.end_effective_dt_tm > sysdate)
    ORDER BY o.description
    DETAIL
     tmp_pp_sz = (tmp_pp_sz+ 1), stat = alterlist(powerplan->lst,tmp_pp_sz), powerplan->lst[tmp_pp_sz
     ].desc = o.description,
     powerplan->lst[tmp_pp_sz].pathway_id = o.pathway_catalog_id
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(3,2,"Map:")
   CALL text(3,7,trim(desc))
   CALL text(4,4,"CKI:")
   CALL text(4,10,trim(cki))
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(tmp_pp_sz,4))
   CALL create_std_box(tmp_pp_sz)
   CALL text(6,8,"Mnemonic ")
   SET cnt = 1
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt
    AND cnt <= tmp_pp_sz)
     SET holdstr60 = trim(powerplan->lst[cnt].desc)
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select a PowerPlan to map      (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,30,"999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pick_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
       CALL upd_cki(powerplan->lst[pick].desc,cki,desc,powerplan->lst[pick].pathway_id)
      ELSE
       CALL clear_screen(0)
       GO TO pick_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(powerplan->lst[cnt].desc)
       SET holdstr20 = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr60 = trim(powerplan->lst[cnt].desc)
       SET holdstr20 = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr60 = trim(powerplan->lst[cnt].desc)
         SET holdstr20 = ""
         SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr60 = trim(powerplan->lst[cnt].desc)
        SET holdstr20 = ""
        SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   CALL clear_screen(0)
   CALL text(23,1,"Map more? (Y/N)   ")
   CALL accept(23,29,"C;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   CASE (curaccept)
    OF "Y":
     GO TO powerplan_map
    OF "N":
     GO TO pick_mode
   ENDCASE
   GO TO pick_mode
 END ;Subroutine
 SUBROUTINE pop_std_list(bcd)
   SET pp_sz = 0
   CALL create_powerplan_list("Activity Intolerance-Impaired Mobility Management Adult EBP",
    "CERNER!D081968B-0C0D-4EDF-A319-4CB7764C0EC8")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures",
    "CERNER!ANyj7QEXgx8NqoD4CqIGfQ")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v2.6",
    "CERNER!D3E2C665-2AE1-40B2-9A8F-16255DFD6866")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v3.0",
    "CERNER!915E1099-EFCA-4AE0-9003-BFBFBDE6B8DD")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v3.1",
    "CERNER!2C2409C4-BD75-4B9A-A4CD-A438CEF37957")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v3.2",
    "CERNER!662F1312-6FC5-4DE9-AC14-A9664DDF83B2")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v3.3",
    "CERNER!41879DD5-4037-4FD3-8FE7-0DE8471B9B9E")
   CALL create_powerplan_list("Cardiac Surgery Quality Measures v3.1",
    "CERNER!89A309BD-3705-4748-B6A8-239A225BD6AC")
   CALL create_powerplan_list("Catheter Related Infection Management EBP",
    "CERNER!AC9CCFFE-616F-433E-846C-87B604E0F6E3")
   CALL create_powerplan_list("Chest Pain, Acute Myocardial Infarction Quality Measures 3.1",
    "CERNER!ABD360F2-610C-45A7-AE61-223FAE7484F9")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v2.6",
    "CERNER!E4859AEE-B57A-4E71-BA04-E92576DACB2D")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v3.0",
    "CERNER!F35407C7-EAEA-424A-A73B-2AB667EC975E")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v3.1",
    "CERNER!0D4259F0-EC62-47B3-BAEA-179307972ED7")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v3.2",
    "CERNER!C467E436-0A3F-4A36-A9A5-95EBCF220BFB")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v3.3",
    "CERNER!EA6D4B6F-0A12-4543-BD45-B185F00A391E")
   CALL create_powerplan_list("Colon Surgery Quality Measures v3.1",
    "CERNER!4D6BDEE5-A7CE-45DF-959C-074A08A21A8C")
   CALL create_powerplan_list("Delirium Prevention and Management Adult EBP",
    "CERNER!F6E63555-2F04-4660-B264-B73CF2D234DC")
   CALL create_powerplan_list("Depressive Symptoms - Suicide Risk Adult EBP",
    "CERNER!9CFA939E-4D0E-439E-BDF1-55767D148A0C")
   CALL create_powerplan_list("Dysphagia Management Adult EBN",
    "CERNER!AA6A57C2-1BE3-469A-B277-EF5CCBB7B94A")
   CALL create_powerplan_list("Fall Prevention and Management EBN",
    "CERNER!AC7964A1-5980-4582-A1F9-00C743924BEC")
   CALL create_powerplan_list("Fall Prevention and Management Pediatric EBN",
    "CERNER!D1618017-5779-4FE6-B78A-225AB6AE43E4")
   CALL create_powerplan_list("Fall Risk Special Condition or Injury EBN",
    "CERNER!97EB9CC6-CDC4-45CE-AC81-F659B3F0FACF")
   CALL create_powerplan_list("Fluid Volume Excess Prevention and Management EBN Adult",
    "CERNER!341BCD01-5A56-400E-93D4-8AA52F18ABB3")
   CALL create_powerplan_list("Heart Failure Quality Measures","CERNER!ANyj7QEXgx8NqoEECqIGfQ")
   CALL create_powerplan_list("Heart Failure Quality Measures v2.6",
    "CERNER!248EE4CA-11DD-485A-84FA-6468764BFFB7")
   CALL create_powerplan_list("Heart Failure Quality Measures v3.0",
    "CERNER!71D36D8D-2E9A-4DC6-BCB6-061D53AA5D5E")
   CALL create_powerplan_list("Heart Failure Quality Measures v3.1",
    "CERNER!35FEA3ED-4B02-435F-964D-1FA618BAF472")
   CALL create_powerplan_list("Heart Failure Quality Measures v3.2",
    "CERNER!FF81855E-AA35-4EF7-A984-79792613BF9B")
   CALL create_powerplan_list("Heart Failure Quality Measures v3.3",
    "CERNER!82A14332-0426-4325-B3A1-622913FEFBF1")
   CALL create_powerplan_list("Hip Knee Surgery Quality Measures v3.1",
    "CERNER!98D6CAC0-B4CB-4F5E-9346-08D9D58ACCD4")
   CALL create_powerplan_list("Hysterectomy Surgery Quality Measures v3.1",
    "CERNER!DC7C4078-2CA1-4B85-B567-4A2DEA5DFFAB")
   CALL create_powerplan_list("Invasive Line-Catheter Care EBP",
    "CERNER!D2A0E3A2-9D7D-450F-BB7E-3AAE1018A883")
   CALL create_powerplan_list("Moderate Sedation Adult EBN",
    "CERNER!9322EB59-46DF-4E73-8A03-35B1E6D4EF24")
   CALL create_powerplan_list("Newborn - Admission to Nursery",
    "CERNER!71029443-5018-4B5E-9E40-A61095DC07A2")
   CALL create_powerplan_list("Medication Adherence Pediatric EBP",
    "CERNER!C1F0E078-FD64-459A-B6F2-554F3051CF28")
   CALL create_powerplan_list("Medication Adherence Adult EBP",
    "CERNER!D7ED10EC-DD21-443F-8428-B80AA5FD1F7F")
   CALL create_powerplan_list("Other Surgery Quality Measures v3.1",
    "CERNER!CC4E7869-3573-47E6-AF0E-8DB1E9B7BC99")
   CALL create_powerplan_list("Pain Management Acute EBN Adult",
    "CERNER!0C73DE1E-25FD-475C-9A3D-DB8D4D28A4ED")
   CALL create_powerplan_list("Pain Management Acute Pediatric EBN",
    "CERNER!780FB171-3813-4C90-B152-14B600C8745F")
   CALL create_powerplan_list("Pain Management NICU EBN",
    "CERNER!D4400DE0-B415-4A78-975C-57589AD87DAA")
   CALL create_powerplan_list("Pain Management PICU EBN",
    "CERNER!987B14CD-024F-4434-9FA7-ABF3E971CE82")
   CALL create_powerplan_list("Pneumonia Quality Measures v2.6",
    "CERNER!AB84185A-2951-4BCB-A201-2E7135DCC21C")
   CALL create_powerplan_list("Pneumonia Qualtiy Measures v3.0",
    "CERNER!CFC80D70-10CE-4BC1-8033-BD185CDD745D")
   CALL create_powerplan_list("Pneumonia Quality Measures v3.1",
    "CERNER!BBEB7EC6-9F5A-4DDF-B675-B529D94499FA")
   CALL create_powerplan_list("Pneumonia Quality Measures v3.2",
    "CERNER!8C7A8BF5-5D12-4A53-A8D3-B6030A969F04")
   CALL create_powerplan_list("Pneumonia Quality Measures v3.3",
    "CERNER!74CCFF04-C9B2-4F10-9208-747A160C2A2B")
   CALL create_powerplan_list("Pressure Ulcer Prevention and Management EBN",
    "CERNER!FE3E2B58-B78D-449E-A31F-F32360FA0E84")
   CALL create_powerplan_list("Restraint Prevention EBP",
    "CERNER!6AE2A33F-9A9B-4EC5-84B1-6A60E54D36F6")
   CALL create_powerplan_list("Restraint Management EBP",
    "CERNER!DC94677F-AFF1-4F29-A2CE-888FD69F57EF")
   CALL create_powerplan_list("Restraint for Violent Behavior",
    "CERNER!04A09377-3D42-4F5F-9826-A0783859D860")
   CALL create_powerplan_list("Restraint for Non-Violent Behavior",
    "CERNER!B5FEA472-69B4-4401-B0A0-83CF8927B41C")
   CALL create_powerplan_list("SCIP Quality Measures v2.6",
    "CERNER!47982152-F370-4B75-9571-FCBF9400C2E1")
   CALL create_powerplan_list("SCIP Quality Measures v3.1",
    "CERNER!68FEC46E-C44F-4B1A-9F1C-FACBA1D62340")
   CALL create_powerplan_list("SCIP Quality Measures v3.2",
    "CERNER!18DF5D8E-D035-4B55-8EC7-981C1BBBB1AE")
   CALL create_powerplan_list("SCIP Quality Measures v3.3",
    "CERNER!8DB23363-EBA8-4EE3-B302-4B584300B267")
   CALL create_powerplan_list("Skin Integrity Impairment Prevention and Management EBN Pediatric",
    "CERNER!AA03FAFA-720A-4AE9-8F3D-3E63C10D07B4")
   CALL create_powerplan_list("Stroke Quality Measures v3.1",
    "CERNER!42CC28C7-01DF-47E9-85E5-D39726AF5C5D")
   CALL create_powerplan_list("Stroke Quality Measures v3.2",
    "CERNER!10673C09-9BCC-4396-826D-37903CB7E485")
   CALL create_powerplan_list("Stroke Quality Measures v3.3",
    "CERNER!02ED804B-4620-4AEA-8731-964E8ACB084A")
   CALL create_powerplan_list("Urinary Incontinence Management Adult EBN",
    "CERNER!A240061C-30F6-4EE9-A3CD-A90E3C323F29")
   CALL create_powerplan_list("Vascular Surgery Quality Measures v3.1",
    "CERNER!2046A5B3-3CE0-4809-827D-071EBC8F33D3")
   CALL create_powerplan_list("zzVTE Prophylaxis and Management (Nursing) EBN",
    "CERNER!54F55435-829D-4224-B110-0A1FE00F9812")
   CALL create_powerplan_list("VTE Quality Measures v3.1",
    "CERNER!57EACC9B-DCB5-4F18-879B-268868EA99AA")
   CALL create_powerplan_list("VTE Quality Measures v3.2",
    "CERNER!88D5907F-D4C4-491C-B8FA-4E2A2ECBEBD2")
   CALL create_powerplan_list("VTE Quality Measures v3.3",
    "CERNER!31D10982-0844-48FA-BEF6-E569245E02CC")
   CALL create_powerplan_list("Readmission Prevention EBP",
    "CERNER!5F38C011-FCDE-4283-BC1C-A693C66DDE98")
   CALL create_powerplan_list("OB Antepartum Management",
    "CERNER!8546CD63-1FF9-438F-991C-2A96B8E802D0")
   CALL create_powerplan_list("Acute Myocardial Infarction Quality Measures v4.0",
    "CERNER!377CA558-E9DF-4852-860A-6553597528A2")
   CALL create_powerplan_list("Heart Failure Quality Measures v4.0",
    "CERNER!40885D13-FD87-4A0D-966C-39EC4F74FCC0")
   CALL create_powerplan_list("Pneumonia Quality Measures v4.0",
    "CERNER!A006B0C6-B741-4A5C-A9AF-698AE2B9E97D")
   CALL create_powerplan_list("Children's Asthma Care Quality Measures v4.0",
    "CERNER!56058D2A-7C3F-47C1-B84C-175BA857FFA0")
   CALL create_powerplan_list("SCIP Quality Measures v4.0",
    "CERNER!F78C9180-11ED-411A-968E-6DE5E915075E")
   CALL create_powerplan_list("Stroke Quality Measures v4.0",
    "CERNER!768B283B-E974-44A9-8A6A-B3ECDE32102A")
   CALL create_powerplan_list("VTE Quality Measures v4.0",
    "CERNER!E5F44F0D-4137-4830-ADD1-D1BB9DD574CF")
   CALL create_powerplan_list("OB Postpartum Vaginal Delivery IPOC",
    "CERNER!BE4874E4-2CDD-431B-AD11-259C51B1EAAA")
   CALL create_powerplan_list("OB Postpartum C-Section IPOC",
    "CERNER!211FD729-12A3-486A-B98A-940734036CA1")
   CALL create_powerplan_list("OB Preterm Labor Management IPOC",
    "CERNER!206C5378-7A75-4EC6-9DA0-4F35942E32A6")
   CALL create_powerplan_list("Heart Failure Risk ED Adult",
    "CERNER!3A530D53-DEA7-420B-ADDB-FD53F01C5F54")
   CALL create_powerplan_list("Heart Failure Management ED Adult",
    "CERNER!5231A8C6-AFEF-46E2-AE58-A6B9CC0C9719")
   CALL create_powerplan_list("Heart Failure Observation Adult",
    "CERNER!9C682C2F-1BD8-4DD2-9AAC-5EE98787C0B2")
   CALL create_powerplan_list("VTE Prophylaxis and Management EBP Adult",
    "CERNER!54F55435-829D-4224-B110-0A1FE00F9812")
   CALL create_powerplan_list("OB Lactation Support IPOC",
    "CERNER!81A57798-E4AC-4789-B154-03860E9B0D2D")
   CALL create_powerplan_list("LTC Activities IPOC","CERNER!5FEADCDA-9C6B-4090-8C34-77CCE54F0891")
   CALL create_powerplan_list("LTC ADL Functions-Rehab IPOC",
    "CERNER!7DB400C2-B993-48FB-95A7-70719831F74A")
   CALL create_powerplan_list("LTC Behavior Symptoms IPOC",
    "CERNER!EB9245FC-C92C-4BD0-9C8B-19AC19FA4F46")
   CALL create_powerplan_list("LTC Cognitive Loss IPOC","CERNER!7AA98B2D-AD4A-4AA2-A474-0E476BE8C52F"
    )
   CALL create_powerplan_list("LTC Communication IPOC","CERNER!52327C5A-0B6A-4AC2-A014-58C865EDBFF3")
   CALL create_powerplan_list("LTC Dehydration Fluid Maintenance IPOC",
    "CERNER!BF39A942-B43C-4D04-B653-4F97B231DE4A")
   CALL create_powerplan_list("LTC Delirium IPOC","CERNER!DEA7BA50-B224-47D6-A424-F5E6CB676848")
   CALL create_powerplan_list("LTC Elopement Risk IPOC","CERNER!F0366BEA-05E6-4360-A0A9-11D4018C586A"
    )
   CALL create_powerplan_list("LTC Mood State IPOC","CERNER!14721CFD-7FB3-4D68-9D05-5C82480D9549")
   CALL create_powerplan_list("LTC Pain IPOC","CERNER!B4232FEA-E640-412E-993C-CF13BEDF1DA4")
   CALL create_powerplan_list("LTC Physical Restraints IPOC",
    "CERNER!28834C68-25E7-4DB1-AAF0-14843E35FE6B")
   CALL create_powerplan_list("LTC Pressure Ulcer IPOC","CERNER!D785E6B4-3E97-4CAA-AA3A-DEEC4267FA74"
    )
   CALL create_powerplan_list("LTC Psychosocial Well-Being IPOC",
    "CERNER!5A2BBD12-1248-4DF1-A084-15A4DB27654D")
   CALL create_powerplan_list("LTC Return to Community IPOC",
    "CERNER!797A62EE-6FA4-4165-B94F-7C59099FCBA1")
   CALL create_powerplan_list("LTC Smoking IPOC","CERNER!38427F69-676A-42AF-9725-CF9DDBFDC72C")
   CALL create_powerplan_list("LTC Cardiovascular IPOC","CERNER!919C2472-771A-4B15-A57E-2608468DC52C"
    )
   CALL create_powerplan_list("LTC Dental Care IPOC","CERNER!0CDEECB1-9F42-4F0D-9074-EA7BECE8F7EF")
   CALL create_powerplan_list("LTC Diabetes Mellitus IPOC",
    "CERNER!EFFAA9E1-7ED7-4AE6-AB06-F2CABC40BD16")
   CALL create_powerplan_list("LTC Feeding Tubes IPOC","CERNER!B3A35D15-4775-4BEF-BE8C-FE53BBE447DB")
   CALL create_powerplan_list("LTC Genitourinary IPOC","CERNER!7A9C3FBC-425D-4BF4-A621-A75427D5DF5C")
   CALL create_powerplan_list("LTC Musculoskeletal IPOC",
    "CERNER!993F7A26-811E-4452-930F-E111124B393C")
   CALL create_powerplan_list("LTC Neurological IPOC","CERNER!057E25A9-7116-4237-B9AC-95302DF4EAB2")
   CALL create_powerplan_list("LTC Nutritional Status IPOC",
    "CERNER!88768D0E-8E30-485A-B71E-B86B25D3936A")
   CALL create_powerplan_list("LTC Post Treatment Care IV Therapy,Radiation, Chemo IPOC",
    "CERNER!E97D4BFE-BCC1-4020-9744-61D05938A503")
   CALL create_powerplan_list("LTC Psychotropic Med Use IPOC",
    "CERNER!2B460430-3BFC-4490-ADBC-7234C3EE00F8")
   CALL create_powerplan_list("LTC Respiratory IPOC","CERNER!58EC204F-86E2-4387-B645-DB880B3CBC0D")
   CALL create_powerplan_list("LTC Self Medication IPOC",
    "CERNER!C643E00E-70AE-447D-B8D1-CF0020CF435A")
   CALL create_powerplan_list("LTC Urinary Incont Indwell Cath IPOC",
    "CERNER!85B0EB10-99A8-4B4D-8EDA-CC641138D380")
   CALL create_powerplan_list("LTC Visual Function IPOC",
    "CERNER!7AD4D5A2-0614-4EE3-B0A2-7F1D2F8A3F4D")
   CALL create_powerplan_list("Fall Prevention and Management EBP Adult IPOC",
    "CERNER!D2D2E75B-58FE-4652-AC0E-0BD8F656E5CB")
   CALL create_powerplan_list("Fall Prevention and Management EBP Pediatric IPOC",
    "CERNER!E1AAE77C-26E1-411C-9F94-818535355F6A")
   CALL create_powerplan_list("Fall Risk Special Condition or Injury EBP",
    "CERNER!1450E020-6A64-46E9-85A2-1AD4AAA97D40")
   CALL create_powerplan_list("LTC Admission Orders","CERNER!3C80EDE1-4CF3-4F8A-AA38-773846525828")
   CALL create_powerplan_list("LTC Congestive Heart Failure",
    "CERNER!B7FEF2FF-A227-4FCD-9727-0E74C632DBC2")
   CALL create_powerplan_list("LTC End of Life IPOC","CERNER!EC1440A6-38DC-45D5-8FA8-78440114021D")
   CALL create_powerplan_list("LTC Falls IPOC","CERNER!44E6C8FD-D5EC-472E-AB7C-359C2FFC482D")
   CALL create_powerplan_list("LTC Fever","CERNER!6679BB10-6FB9-4341-8372-24FBEB4DF445")
   CALL create_powerplan_list("LTC Gastrointestinal IPOC",
    "CERNER!BF14ECC4-F3E2-4979-8190-C6FCBAEF4D43")
   CALL create_powerplan_list("LTC Lower Respiratory Infection",
    "CERNER!997519A0-2EF6-41C5-A23F-99B072901E9A")
   CALL create_powerplan_list("LTC Medicare Certification",
    "CERNER!D883377D-D99A-4D53-9920-E4FFBD8F1EDE")
   CALL create_powerplan_list("LTC Mental Status Change",
    "CERNER!4DA84496-1FE3-4343-951A-0DA1BC635AD8")
   CALL create_powerplan_list("LTC Restraints","CERNER!D64082BF-5E1B-4D15-8396-6B528676A354")
   CALL create_powerplan_list("LTC Urinary Tract Infection",
    "CERNER!65D546E3-8633-412D-9195-25D09C219547")
   CALL create_powerplan_list("Rehab Swallowing Impairment IPOC",
    "CERNER!B0AD8E75-9BD6-4367-8802-30ED708B6D0D")
   CALL create_powerplan_list("Readmission Prevention Adult IPOC",
    "CERNER!1ED90F1F-AC1E-4797-A4A6-D1E9A910A989")
   CALL create_powerplan_list("OB Late Preterm 34 - 36 6/7 weeks IPOC",
    "CERNER!E2FBD26B-7F81-4169-88C6-DBA566EC636B")
   CALL create_powerplan_list("Readmission Prevention Pediatric IPOC",
    "CERNER!638EF157-9833-47CF-8AC6-5F15719C3EFE")
   CALL create_powerplan_list("Sepsis Support IPOC","CERNER!7BA03BCA-5D36-48F1-AB59-6A0BEAA4419D")
   CALL create_powerplan_list("BH Self-Harm/Suicide Risk IPOC",
    "CERNER!6B0609D5-92B8-4680-8A60-16EB581416A3")
   CALL create_powerplan_list("BH Substance Abuse-Detoxification IPOC",
    "CERNER!9B91FE56-B42E-4ADF-8C57-DC5CA77BD973")
   CALL create_powerplan_list("BH Substance Abuse-Relapse Prevention IPOC",
    "CERNER!1A4B9B88-EC5F-4A5D-990F-04ED2520103B")
   CALL create_powerplan_list("OB Newborn Phototherapy IPOC",
    "CERNER!397826E6-F12A-44AF-9EF2-51B33D5AEADA")
 END ;Subroutine
 SUBROUTINE find_mapped_powerplans(fmp)
   SET tmp_mpp_sz = 0
   RECORD mpowerplan(
     1 lst[*]
       2 desc = vc
       2 concept_cki = vc
       2 mapped = i2
       2 pathway_id = f8
   )
   CALL pop_std_list(1)
   CALL echoxml(powerplan_std,"pp.xml")
   SELECT INTO "nl:"
    FROM pathway_catalog o,
     (dummyt d  WITH seq = size(powerplan_std->lst,5))
    PLAN (o
     WHERE o.pathway_catalog_id > 0.0
      AND o.type_mean IN ("CAREPLAN", "PATHWAY")
      AND o.active_ind=1
      AND o.end_effective_dt_tm > sysdate
      AND o.concept_cki="CERNER*")
     JOIN (d
     WHERE trim(o.concept_cki)=trim(powerplan_std->lst[d.seq].concept_cki))
    ORDER BY o.description
    DETAIL
     tmp_mpp_sz = (tmp_mpp_sz+ 1), stat = alterlist(mpowerplan->lst,tmp_mpp_sz), mpowerplan->lst[
     tmp_mpp_sz].desc = o.description,
     mpowerplan->lst[tmp_mpp_sz].pathway_id = o.pathway_catalog_id, mpowerplan->lst[tmp_mpp_sz].
     concept_cki = o.concept_cki
    WITH nocounter
   ;end select
   CALL clear_screen(0)
   CALL text(5,67,"Total:  ")
   CALL text(5,75,cnvtstring(tmp_mpp_sz,4))
   CALL create_std_box(tmp_mpp_sz)
   CALL text(6,8,"Mnemonic ")
   SET cnt = 1
   WHILE (cnt <= numsrow
    AND cnt <= maxcnt
    AND cnt <= tmp_mpp_sz)
     SET holdstr60 = trim(mpowerplan->lst[cnt].concept_cki)
     SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60)
     CALL scrolltext(cnt,holdstr)
     SET cnt = (cnt+ 1)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   CALL text(23,1,"Select a PowerPlan to unmap      (enter 000 to go back)")
   SET pick = 0
   WHILE (pick=0)
    CALL accept(23,30,"999;S",cnt)
    CASE (curscroll)
     OF 0:
      IF (curaccept=0)
       CALL clear_screen(0)
       GO TO pick_mode
      ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
       SET pick = cnvtint(curaccept)
       CALL clear_screen(0)
       CALL upd_cki(mpowerplan->lst[pick].desc,"",desc,mpowerplan->lst[pick].pathway_id)
      ELSE
       CALL clear_screen(0)
       GO TO pick_mode
      ENDIF
     OF 1:
      IF (cnt < maxcnt)
       SET cnt = (cnt+ 1)
       SET holdstr60 = trim(mpowerplan->lst[cnt].desc)
       SET holdstr20 = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL down_arrow(holdstr)
      ENDIF
     OF 2:
      IF (cnt > 1)
       SET cnt = (cnt - 1)
       SET holdstr60 = trim(mpowerplan->lst[cnt].desc)
       SET holdstr20 = ""
       SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
       CALL up_arrow(holdstr)
      ENDIF
     OF 3:
     OF 4:
     OF 6:
      IF (numsrow < maxcnt)
       SET cnt = ((cnt+ numsrow) - 1)
       IF (((cnt+ numsrow) > maxcnt))
        SET cnt = (maxcnt - numsrow)
       ENDIF
       SET arow = 1
       WHILE (arow <= numsrow)
         SET cnt = (cnt+ 1)
         SET holdstr60 = trim(mpowerplan->lst[cnt].desc)
         SET holdstr20 = ""
         SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
         CALL scrolltext(arow,holdstr)
         SET arow = (arow+ 1)
       ENDWHILE
       SET arow = 1
       SET cnt = ((cnt - numsrow)+ 1)
      ENDIF
     OF 5:
      IF (((cnt - numsrow) > 0))
       SET cnt = (cnt - numsrow)
      ELSE
       SET cnt = 1
      ENDIF
      SET tmp1 = cnt
      SET arow = 1
      WHILE (arow <= numsrow
       AND cnt < maxcnt)
        SET holdstr60 = trim(mpowerplan->lst[cnt].desc)
        SET holdstr20 = ""
        SET holdstr = concat(cnvtstring(cnt,3,0,r),"  ",holdstr60,"  ",holdstr20)
        CALL scrolltext(arow,holdstr)
        SET cnt = (cnt+ 1)
        SET arow = (arow+ 1)
      ENDWHILE
      SET cnt = tmp1
      SET arow = 1
    ENDCASE
   ENDWHILE
   CALL clear_screen(0)
 END ;Subroutine
#exit_program
 CALL clear_screen(0)
 FREE RECORD powerplan_std
 IF (change_ind=true)
  CALL text(23,1,"Commit changes? (Y/N)   ")
  CALL accept(23,25,"C;CU"
   WHERE curaccept IN ("Y", "N"))
  CASE (curaccept)
   OF "Y":
    COMMIT
   OF "N":
    ROLLBACK
  ENDCASE
 ENDIF
 DECLARE sversion = vc WITH constant("06-Nov-2009")
END GO
