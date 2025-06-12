CREATE PROGRAM cco_rpt_von_cki_mapping:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Report Type:" = ""
  WITH outdev, rpt_type
 RECORD von(
   1 cnt = i2
   1 event_list[*]
     2 cki = vc
     2 code_value = f8
 )
 SET stat = alterlist(von->event_list,100)
 SET cki_cnt = 1
 SET von->event_list[cki_cnt].cki = "CKI.EC!8089"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8090"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!7365"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8092"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8095"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cny = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8096"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8097"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!7215"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8098"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8099"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8100"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8101"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8102"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8106"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "MUL.ORD!d00777"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8399"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8311"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!6267"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8315"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8379"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!3333"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8105"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!7676"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8103"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8380"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "MUL.ORD!d00039"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8381"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8382"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8383"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8384"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8385"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8386"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8387"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8388"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8389"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8312"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8392"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8394"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8396"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8397"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8398"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8128"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8127"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8130"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!4051"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8129"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8400"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!7672"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!7911"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8404"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8405"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8107"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8412"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8406"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8407"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8408"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8409"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8402"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8403"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET cki_cnt = (cki_cnt+ 1)
 SET von->event_list[cki_cnt].cki = "CKI.EC!8108"
 SET von->event_list[cki_cnt].code_value = uar_get_code_by_cki(nullterm(von->event_list[cki_cnt].cki)
  )
 SET stat = alterlist(von->event_list,cki_cnt)
 SET von->cnt = cki_cnt
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = von->cnt)
  HEAD REPORT
   row + 1
   IF (( $RPT_TYPE="ALL"))
    col 20, "ALL EVENTS", col 40,
     $RPT_TYPE
   ELSE
    col 20, "ERRORS ONLY", col 40,
     $RPT_TYPE
   ENDIF
   row + 2, col 1, "CKI",
   col 30, "code_value", row + 1
  DETAIL
   row + 1
   IF ((von->event_list[d.seq].code_value > 0))
    IF (( $RPT_TYPE="ALL"))
     col 1, von->event_list[d.seq].cki, col 30,
     von->event_list[d.seq].code_value
    ENDIF
   ELSE
    col 1, von->event_list[d.seq].cki, col 30,
    von->event_list[d.seq].code_value
   ENDIF
  WITH nocounter
 ;end select
END GO
