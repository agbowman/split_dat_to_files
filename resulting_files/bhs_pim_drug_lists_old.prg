CREATE PROGRAM bhs_pim_drug_lists_old
 FREE RECORD pim_drugs
 RECORD pim_drugs(
   1 drug_class_cnt = i4
   1 drug_classes[*]
     2 drug_class = vc
     2 drug_cnt = i4
     2 drugs[*]
       3 catalog_cd = f8
       3 displaykey = vc
       3 display = vc
     2 rcmd_cnt = i4
     2 rcmd_drugs[*]
       3 catalog_cd = f8
       3 displaykey = vc
       3 display = vc
 ) WITH persist
 SET pim_drugs->drug_class_cnt = 14
 SET stat = alterlist(pim_drugs->drug_classes,pim_drugs->drug_class_cnt)
 SET pim_drugs->drug_classes[1].drug_class = "Indomethacin"
 SET pim_drugs->drug_classes[1].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[1].drugs,pim_drugs->drug_classes[1].drug_cnt)
 SET pim_drugs->drug_classes[1].drugs[1].display = "Indomethacin"
 SET pim_drugs->drug_classes[1].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[1].rcmd_drugs,pim_drugs->drug_classes[1].rcmd_cnt)
 SET pim_drugs->drug_classes[1].rcmd_drugs[1].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[1].rcmd_drugs[2].displaykey = "ACETAMINOPHEN"
 SET pim_drugs->drug_classes[1].rcmd_drugs[3].displaykey = "CELECOXIB"
 SET pim_drugs->drug_classes[2].drug_class = "Muscle relaxants"
 SET pim_drugs->drug_classes[2].drug_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[2].drugs,pim_drugs->drug_classes[2].drug_cnt)
 SET pim_drugs->drug_classes[2].drugs[1].display = "Carisoprodol"
 SET pim_drugs->drug_classes[2].drugs[2].display = "Chlorzoxazone"
 SET pim_drugs->drug_classes[2].drugs[3].display = "Cyclobenzaprine"
 SET pim_drugs->drug_classes[2].drugs[4].display = "Metaxalone"
 SET pim_drugs->drug_classes[3].drug_class = "Antispasmodics"
 SET pim_drugs->drug_classes[3].drug_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[3].drugs,pim_drugs->drug_classes[3].drug_cnt)
 SET pim_drugs->drug_classes[3].drugs[1].display = "Dicyclomine"
 SET pim_drugs->drug_classes[3].drugs[2].display = "Propantheline"
 SET pim_drugs->drug_classes[3].drugs[3].display = "Atropine/Hyoscyamine/PB/Scopolamine"
 SET pim_drugs->drug_classes[3].drugs[4].display = "Chlordiazepoxide-Clidinium"
 SET pim_drugs->drug_classes[4].drug_class = "Amitriptyline"
 SET pim_drugs->drug_classes[4].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[4].drugs,pim_drugs->drug_classes[4].drug_cnt)
 SET pim_drugs->drug_classes[4].drugs[1].display = "amiTRIPTYLINE"
 SET pim_drugs->drug_classes[4].rcmd_cnt = 5
 SET stat = alterlist(pim_drugs->drug_classes[4].rcmd_drugs,pim_drugs->drug_classes[4].rcmd_cnt)
 SET pim_drugs->drug_classes[4].rcmd_drugs[1].displaykey = "GABAPENTIN"
 SET pim_drugs->drug_classes[4].rcmd_drugs[2].displaykey = "VALPROICACID"
 SET pim_drugs->drug_classes[4].rcmd_drugs[3].displaykey = "CARBAMAZEPINE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[4].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[4].rcmd_drugs[5].displaykey = "DESIPRAMINE"
 SET pim_drugs->drug_classes[5].drug_class = "Long-acting benzodiazepines"
 SET pim_drugs->drug_classes[5].drug_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[5].drugs,pim_drugs->drug_classes[5].drug_cnt)
 SET pim_drugs->drug_classes[5].drugs[1].display = "Chlordiazepoxide"
 SET pim_drugs->drug_classes[5].drugs[2].display = "Diazepam"
 SET pim_drugs->drug_classes[5].drugs[3].display = "Quazepam"
 SET pim_drugs->drug_classes[5].drugs[4].display = "Clorazepate"
 SET pim_drugs->drug_classes[5].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[5].rcmd_drugs,pim_drugs->drug_classes[5].rcmd_cnt)
 SET pim_drugs->drug_classes[5].rcmd_drugs[1].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[5].rcmd_drugs[2].displaykey = "HALOPERIDOL"
 SET pim_drugs->drug_classes[5].rcmd_drugs[3].displaykey = "QUETIAPINE"
 SET pim_drugs->drug_classes[6].drug_class = "High-dose short-acting benzodiazepines"
 SET pim_drugs->drug_classes[6].drug_cnt = 5
 SET stat = alterlist(pim_drugs->drug_classes[6].drugs,pim_drugs->drug_classes[6].drug_cnt)
 SET pim_drugs->drug_classes[6].drugs[1].display = "lorazepam"
 SET pim_drugs->drug_classes[6].drugs[2].display = "Oxazepam"
 SET pim_drugs->drug_classes[6].drugs[3].display = "alprazolam"
 SET pim_drugs->drug_classes[6].drugs[4].display = "Temazepam"
 SET pim_drugs->drug_classes[6].drugs[5].display = "Triazolam"
 SET pim_drugs->drug_classes[6].rcmd_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[6].rcmd_drugs,pim_drugs->drug_classes[6].rcmd_cnt)
 SET pim_drugs->drug_classes[6].rcmd_drugs[1].displaykey = "LORAZEPAM"
 SET pim_drugs->drug_classes[6].rcmd_drugs[2].displaykey = "ALPRAZOLAM"
 SET pim_drugs->drug_classes[6].rcmd_drugs[3].displaykey = "TEMAZEPAM"
 SET pim_drugs->drug_classes[6].rcmd_drugs[4].displaykey = "TRIAZOLAM"
 SET pim_drugs->drug_classes[7].drug_class = "Promethazine"
 SET pim_drugs->drug_classes[7].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[7].drugs,pim_drugs->drug_classes[7].drug_cnt)
 SET pim_drugs->drug_classes[7].drugs[1].display = "Promethazine"
 SET pim_drugs->drug_classes[7].rcmd_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[7].rcmd_drugs,pim_drugs->drug_classes[7].rcmd_cnt)
 SET pim_drugs->drug_classes[7].rcmd_drugs[1].displaykey = "ESOMEPRAZOLE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[2].displaykey = "METOCLOPRAMIDE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[3].displaykey = "OCTREOTIDE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[4].displaykey = "DEXAMETHASONE"
 SET pim_drugs->drug_classes[7].rcmd_drugs[5].displaykey = "ONDANSETRON"
 SET pim_drugs->drug_classes[7].rcmd_drugs[6].displaykey = "ONDANSETRONIVPB"
 SET pim_drugs->drug_classes[8].drug_class = "Barbiturates"
 SET pim_drugs->drug_classes[8].drug_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[8].drugs,pim_drugs->drug_classes[8].drug_cnt)
 SET pim_drugs->drug_classes[8].drugs[1].display = "Phenobarbital"
 SET pim_drugs->drug_classes[8].drugs[2].display = "Butabarbital"
 SET pim_drugs->drug_classes[8].drugs[3].display = "Amobarbital"
 SET pim_drugs->drug_classes[8].drugs[4].display = "Butalbital"
 SET pim_drugs->drug_classes[8].drugs[5].display = "Pentobarbital"
 SET pim_drugs->drug_classes[8].drugs[6].display = "Secobarbital"
 SET pim_drugs->drug_classes[8].rcmd_cnt = 7
 SET stat = alterlist(pim_drugs->drug_classes[8].rcmd_drugs,pim_drugs->drug_classes[8].rcmd_cnt)
 SET pim_drugs->drug_classes[8].rcmd_drugs[1].displaykey = "BUSPIRONE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[2].displaykey = "SERTRALINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[3].displaykey = "CITALOPRAM"
 SET pim_drugs->drug_classes[8].rcmd_drugs[4].displaykey = "ESCITALOPRAM"
 SET pim_drugs->drug_classes[8].rcmd_drugs[5].displaykey = "FLUOXETINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[6].displaykey = "FLUVOXAMINE"
 SET pim_drugs->drug_classes[8].rcmd_drugs[7].displaykey = "PAROXETINE"
 SET pim_drugs->drug_classes[9].drug_class = "Meperidine"
 SET pim_drugs->drug_classes[9].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[9].drugs,pim_drugs->drug_classes[9].drug_cnt)
 SET pim_drugs->drug_classes[9].drugs[1].display = "Meperidine"
 SET pim_drugs->drug_classes[9].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[9].rcmd_drugs,pim_drugs->drug_classes[9].rcmd_cnt)
 SET pim_drugs->drug_classes[9].rcmd_drugs[1].displaykey = "MORPHINE"
 SET pim_drugs->drug_classes[9].rcmd_drugs[2].displaykey = "HYDROMORPHONE"
 SET pim_drugs->drug_classes[9].rcmd_drugs[3].displaykey = "OXYCODONE"
 SET pim_drugs->drug_classes[10].drug_class = "Ketoralac"
 SET pim_drugs->drug_classes[10].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[10].drugs,pim_drugs->drug_classes[10].drug_cnt)
 SET pim_drugs->drug_classes[10].drugs[1].display = "Ketorolac"
 SET pim_drugs->drug_classes[10].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[10].rcmd_drugs,pim_drugs->drug_classes[10].rcmd_cnt)
 SET pim_drugs->drug_classes[10].rcmd_drugs[1].displaykey = "MORPHINE"
 SET pim_drugs->drug_classes[10].rcmd_drugs[2].displaykey = "HYDROMORPHONE"
 SET pim_drugs->drug_classes[10].rcmd_drugs[3].displaykey = "OXYCODONE"
 SET pim_drugs->drug_classes[11].drug_class = "NSAID"
 SET pim_drugs->drug_classes[11].drug_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[11].drugs,pim_drugs->drug_classes[11].drug_cnt)
 SET pim_drugs->drug_classes[11].drugs[1].display = "Ibuprofen"
 SET pim_drugs->drug_classes[11].drugs[2].display = "Naproxen"
 SET pim_drugs->drug_classes[11].drugs[3].display = "Oxaprozin"
 SET pim_drugs->drug_classes[11].drugs[4].display = "Piroxicam"
 SET pim_drugs->drug_classes[11].drugs[5].display = "Nabumetone"
 SET pim_drugs->drug_classes[11].drugs[6].display = "Diclofenac"
 SET pim_drugs->drug_classes[11].rcmd_cnt = 3
 SET stat = alterlist(pim_drugs->drug_classes[11].rcmd_drugs,pim_drugs->drug_classes[11].rcmd_cnt)
 SET pim_drugs->drug_classes[11].rcmd_drugs[1].displaykey = "ACETAMINOPHEN"
 SET pim_drugs->drug_classes[11].rcmd_drugs[2].displaykey = "CELECOXIB"
 SET pim_drugs->drug_classes[11].rcmd_drugs[3].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[12].drug_class = "Amiodarone"
 SET pim_drugs->drug_classes[12].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[12].drugs,pim_drugs->drug_classes[12].drug_cnt)
 SET pim_drugs->drug_classes[12].drugs[1].display = "amiODARONE"
 SET pim_drugs->drug_classes[12].rcmd_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[12].rcmd_drugs,pim_drugs->drug_classes[12].rcmd_cnt)
 SET pim_drugs->drug_classes[12].rcmd_drugs[1].displaykey = "CARVEDILOL"
 SET pim_drugs->drug_classes[12].rcmd_drugs[2].displaykey = "DILTIAZEM"
 SET pim_drugs->drug_classes[12].rcmd_drugs[3].displaykey = "DIGOXIN"
 SET pim_drugs->drug_classes[12].rcmd_drugs[4].displaykey = "DRONEDARONE"
 SET pim_drugs->drug_classes[13].drug_class = "Nitrofurantoin"
 SET pim_drugs->drug_classes[13].drug_cnt = 1
 SET stat = alterlist(pim_drugs->drug_classes[13].drugs,pim_drugs->drug_classes[13].drug_cnt)
 SET pim_drugs->drug_classes[13].drugs[1].display = "Nitrofurantoin"
 SET pim_drugs->drug_classes[13].rcmd_cnt = 2
 SET stat = alterlist(pim_drugs->drug_classes[13].rcmd_drugs,pim_drugs->drug_classes[13].rcmd_cnt)
 SET pim_drugs->drug_classes[13].rcmd_drugs[1].displaykey = "LEVOFLOXACIN"
 SET pim_drugs->drug_classes[13].rcmd_drugs[2].displaykey = "CEFTRIAXONE"
 SET pim_drugs->drug_classes[14].drug_class = "Antihistamines"
 SET pim_drugs->drug_classes[14].drug_cnt = 4
 SET stat = alterlist(pim_drugs->drug_classes[14].drugs,pim_drugs->drug_classes[14].drug_cnt)
 SET pim_drugs->drug_classes[14].drugs[1].display = "Chlorpheniramine"
 SET pim_drugs->drug_classes[14].drugs[2].display = "DiphenhydrAMINE"
 SET pim_drugs->drug_classes[14].drugs[3].display = "HydrOXYzine"
 SET pim_drugs->drug_classes[14].drugs[4].display = "Cyproheptadine"
 SET pim_drugs->drug_classes[14].rcmd_cnt = 6
 SET stat = alterlist(pim_drugs->drug_classes[14].rcmd_drugs,pim_drugs->drug_classes[14].rcmd_cnt)
 SET pim_drugs->drug_classes[14].rcmd_drugs[1].displaykey = "LORATADINE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[2].displaykey = "FEXOFENADINE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[3].displaykey = "PREDNISONE"
 SET pim_drugs->drug_classes[14].rcmd_drugs[4].displaykey = "EMOLLIENTSTOPICAL"
 SET pim_drugs->drug_classes[14].rcmd_drugs[5].displaykey = "METHYLSALICYLATETOPICAL"
 SET pim_drugs->drug_classes[14].rcmd_drugs[6].displaykey = "CALAMINETOPICAL"
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pim_drugs->drug_class_cnt)),
   dummyt d2,
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,pim_drugs->drug_classes[d1.seq].drug_cnt))
   JOIN (d2)
   JOIN (cv
   WHERE (((pim_drugs->drug_classes[d1.seq].drugs[d2.seq].display=cv.display)) OR ((pim_drugs->
   drug_classes[d1.seq].drugs[d2.seq].displaykey=cv.display_key)))
    AND cv.code_set=200
    AND cv.active_ind=1)
  DETAIL
   IF ((pim_drugs->drug_classes[d1.seq].drugs[d2.seq].catalog_cd > 0.00))
    CALL echo(build2("Duplicate display found for ",pim_drugs->drug_classes[d1.seq].drugs[d2.seq].
     display,pim_drugs->drug_classes[d1.seq].drugs[d2.seq].displaykey))
   ELSE
    pim_drugs->drug_classes[d1.seq].drugs[d2.seq].catalog_cd = cv.code_value, pim_drugs->
    drug_classes[d1.seq].drugs[d2.seq].displaykey = cv.display_key, pim_drugs->drug_classes[d1.seq].
    drugs[d2.seq].display = cv.display
   ENDIF
  WITH nocounter
 ;end select
 FOR (x1 = 1 TO pim_drugs->drug_class_cnt)
   FOR (x2 = 1 TO pim_drugs->drug_classes[x1].drug_cnt)
     IF ((pim_drugs->drug_classes[x1].drugs[x2].catalog_cd <= 0.00))
      CALL echo(build2("No code value found for ",pim_drugs->drug_classes[x1].drugs[x2].display,
        pim_drugs->drug_classes[x1].drugs[x2].displaykey))
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pim_drugs->drug_class_cnt)),
   dummyt d2,
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,pim_drugs->drug_classes[d1.seq].rcmd_cnt))
   JOIN (d2)
   JOIN (cv
   WHERE (((pim_drugs->drug_classes[d1.seq].rcmd_drugs[d2.seq].display=cv.display)) OR ((pim_drugs->
   drug_classes[d1.seq].rcmd_drugs[d2.seq].displaykey=cv.display_key)))
    AND cv.code_set=200
    AND cv.active_ind=1)
  DETAIL
   IF ((pim_drugs->drug_classes[d1.seq].rcmd_drugs[d2.seq].catalog_cd > 0.00))
    CALL echo(build2("Duplicate display found for ",pim_drugs->drug_classes[d1.seq].rcmd_drugs[d2.seq
     ].display,pim_drugs->drug_classes[d1.seq].rcmd_drugs[d2.seq].displaykey))
   ELSE
    pim_drugs->drug_classes[d1.seq].rcmd_drugs[d2.seq].catalog_cd = cv.code_value, pim_drugs->
    drug_classes[d1.seq].rcmd_drugs[d2.seq].displaykey = cv.display_key, pim_drugs->drug_classes[d1
    .seq].rcmd_drugs[d2.seq].display = cv.display
   ENDIF
  WITH nocounter
 ;end select
 FOR (x1 = 1 TO pim_drugs->drug_class_cnt)
   FOR (x2 = 1 TO pim_drugs->drug_classes[x1].rcmd_cnt)
     IF ((pim_drugs->drug_classes[x1].rcmd_drugs[x2].catalog_cd <= 0.00))
      CALL echo(build2("No code value found for ",pim_drugs->drug_classes[x1].rcmd_drugs[x2].display,
        pim_drugs->drug_classes[x1].rcmd_drugs[x2].displaykey))
     ENDIF
   ENDFOR
 ENDFOR
END GO
