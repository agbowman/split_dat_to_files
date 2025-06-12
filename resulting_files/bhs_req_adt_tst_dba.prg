CREATE PROGRAM bhs_req_adt_tst:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[68]
     2 f_order_id = f8
 )
 SET m_rec->ord[1].f_order_id = 1034558290
 SET m_rec->ord[2].f_order_id = 1034603357
 SET m_rec->ord[3].f_order_id = 1034637798
 SET m_rec->ord[4].f_order_id = 1034645103
 SET m_rec->ord[5].f_order_id = 1034479733
 SET m_rec->ord[6].f_order_id = 1034522065
 SET m_rec->ord[7].f_order_id = 1034473682
 SET m_rec->ord[8].f_order_id = 1034635434
 SET m_rec->ord[9].f_order_id = 1034506464
 SET m_rec->ord[10].f_order_id = 1034575273
 SET m_rec->ord[11].f_order_id = 1034564850
 SET m_rec->ord[12].f_order_id = 1034516928
 SET m_rec->ord[13].f_order_id = 1034516989
 SET m_rec->ord[14].f_order_id = 1034559043
 SET m_rec->ord[15].f_order_id = 1034471626
 SET m_rec->ord[16].f_order_id = 1034473689
 SET m_rec->ord[17].f_order_id = 1034588658
 SET m_rec->ord[18].f_order_id = 1034632011
 SET m_rec->ord[19].f_order_id = 1034621738
 SET m_rec->ord[20].f_order_id = 1034614397
 SET m_rec->ord[21].f_order_id = 1034480465
 SET m_rec->ord[22].f_order_id = 1034515499
 SET m_rec->ord[23].f_order_id = 1034587980
 SET m_rec->ord[24].f_order_id = 1034588089
 SET m_rec->ord[25].f_order_id = 1034588734
 SET m_rec->ord[26].f_order_id = 1034515110
 SET m_rec->ord[27].f_order_id = 1034481740
 SET m_rec->ord[28].f_order_id = 1034604691
 SET m_rec->ord[29].f_order_id = 1034645063
 SET m_rec->ord[30].f_order_id = 1034493020
 SET m_rec->ord[31].f_order_id = 1034502633
 SET m_rec->ord[32].f_order_id = 1034538065
 SET m_rec->ord[33].f_order_id = 1034624120
 SET m_rec->ord[34].f_order_id = 1034631688
 SET m_rec->ord[35].f_order_id = 1034525240
 SET m_rec->ord[36].f_order_id = 1034498353
 SET m_rec->ord[37].f_order_id = 1034506063
 SET m_rec->ord[38].f_order_id = 1034484574
 SET m_rec->ord[39].f_order_id = 1034486832
 SET m_rec->ord[40].f_order_id = 1034601293
 SET m_rec->ord[41].f_order_id = 1034644625
 SET m_rec->ord[42].f_order_id = 1034588182
 SET m_rec->ord[43].f_order_id = 1034526050
 SET m_rec->ord[44].f_order_id = 1034602962
 SET m_rec->ord[45].f_order_id = 1034638766
 SET m_rec->ord[46].f_order_id = 1034593926
 SET m_rec->ord[47].f_order_id = 1034568295
 SET m_rec->ord[48].f_order_id = 1034638172
 SET m_rec->ord[49].f_order_id = 1034648451
 SET m_rec->ord[50].f_order_id = 1034496710
 SET m_rec->ord[51].f_order_id = 1034641071
 SET m_rec->ord[52].f_order_id = 1034641589
 SET m_rec->ord[53].f_order_id = 1034654518
 SET m_rec->ord[54].f_order_id = 1034658194
 SET m_rec->ord[55].f_order_id = 1034607289
 SET m_rec->ord[56].f_order_id = 1034489634
 SET m_rec->ord[57].f_order_id = 1034583778
 SET m_rec->ord[58].f_order_id = 1034641739
 SET m_rec->ord[59].f_order_id = 1034652518
 SET m_rec->ord[60].f_order_id = 1034514215
 SET m_rec->ord[61].f_order_id = 1034606316
 SET m_rec->ord[62].f_order_id = 1034660796
 SET m_rec->ord[63].f_order_id = 1034622088
 SET m_rec->ord[64].f_order_id = 1034605081
 SET m_rec->ord[65].f_order_id = 1034629665
 SET m_rec->ord[66].f_order_id = 1034635036
 SET m_rec->ord[67].f_order_id = 1034661117
 SET m_rec->ord[68].f_order_id = 1034679812
 FOR (ml_loop = 1 TO size(m_rec->ord,5))
   CALL echo(build2("loop cnt: ",ml_loop))
   FREE RECORD request
   RECORD request(
     1 person_id = f8
     1 print_prsnl_id = f8
     1 order_qual[1]
       2 order_id = f8
       2 encntr_id = f8
       2 conversation_id = f8
     1 printer_name = c50
   )
   SELECT INTO "nl:"
    FROM orders o
    WHERE (o.order_id=m_rec->ord[ml_loop].f_order_id)
    DETAIL
     request->person_id = o.person_id, request->order_qual[1].order_id = o.order_id, request->
     order_qual[1].encntr_id = o.encntr_id,
     request->print_prsnl_id = 0, request->printer_name = "mine"
    WITH nocounter, maxrec = 1
   ;end select
   CALL echorecord(request)
   EXECUTE bhs_req_adt2
   FREE SET orders
   FREE SET request
 ENDFOR
END GO
