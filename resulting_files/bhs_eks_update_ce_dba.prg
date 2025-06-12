CREATE PROGRAM bhs_eks_update_ce:dba
 RECORD eksopsrequest(
   1 expert_trigger = vc
   1 qual[*]
     2 person_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 encntr_id = f8
     2 accession_id = f8
     2 order_id = f8
     2 data[*]
       3 vc_var = vc
       3 double_var = f8
       3 long_var = i4
       3 short_var = i2
 )
 FREE RECORD m_encs
 RECORD m_encs(
   1 l_cnt = i4
   1 lst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ml_loop = i4 WITH public, noconstant(0)
 DECLARE ml_cnt = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id IN (171831845, 171831687, 171831441, 171831226, 171830989,
   171830921, 171830587, 171830204, 171830084, 171829994,
   171829948, 171829689, 171829357, 171837922, 171829140,
   171829064, 171828947, 171828885, 171828443, 171838279,
   171828292, 171828225, 171828204, 171835828, 171839822,
   171835669, 171827801, 171827675, 171827555, 171827439,
   171827265, 171836268, 171826969, 171826724, 171836534,
   171835968, 171769282, 171764618, 171764457, 171761901,
   171761800, 171761383, 171761303, 171760462, 171760096,
   171759738, 171755777, 171755114, 171731075, 171730910,
   171730579, 171730361, 171730203, 171730107, 171709338,
   171729399, 171729277, 171727885, 171725858, 171725717,
   171725607, 171724828, 171724342, 171724189, 171724076,
   171723899, 171723419, 171729085, 171686589, 171684521,
   171683592, 171683417, 171681772, 171678935, 171659995,
   171655002, 171654955, 171654917, 171653941, 171676722,
   171649517, 171678136, 171648135, 171675253, 171675383,
   171674873, 171674567, 171681482, 170860967, 171623123,
   170845318, 171609150, 171601409, 171592504, 171592194,
   171591051, 171518194, 171540547, 171539487, 171535678,
   171530219, 171529663, 171444135, 171444128, 171444121,
   171455438, 171454711, 171454567, 171452495, 171436109,
   171435083, 170683619, 170682915, 170682851, 171428600,
   171435020, 171434735, 171396126, 171396129, 171396120,
   171396114, 171396105, 171435039, 171396918, 171412646,
   171418946, 171417912, 171411870, 171417829, 171417560,
   171417281, 170654123, 171387470, 171387155, 171385389,
   171384819, 171384102, 171381156, 170282603, 171339487,
   171338207, 171337506, 171335772, 171335717, 171331441,
   171331123, 171330960, 171330596, 171284771, 171272360,
   171272240, 171272015, 171271384, 171272629, 171271226,
   171270142, 171269946, 171268342, 171268272, 171264752,
   171263818, 171263467, 171263412, 171264271, 171264742,
   171262677, 171287205, 171262110, 171261972, 171261400,
   171286776, 171264209, 171260715, 171261215, 170523894,
   170522172, 170520680, 170520460, 170520275, 170520138,
   170510348, 170501065, 171232162, 170493593, 170488510,
   170493575, 170493515, 170489405, 170489381, 170471657,
   170370243, 170351791, 170351732, 170329903, 170314452,
   170313354, 170251337, 170250188, 170250174, 170241031,
   170879382, 170875207, 170874853, 170874395, 170870910,
   170870754, 170015249, 170015130, 170848453, 170134143,
   170119625, 170772261, 170760465, 170760450, 170760444,
   170760432, 170760416, 170760407, 170760385, 170760373,
   170081054, 170760346, 170760331, 170760318, 170760300,
   170760297, 170785924, 170783731, 170779581, 170766538,
   170074681, 170074553, 170074367, 170071897, 170747682,
   170747656, 170747526, 170665809, 170527112, 170527047,
   170525706, 170523263, 170520591, 170520516, 170520023,
   170519922, 169767691, 170473544, 169650464, 169616297,
   170351810, 170349170, 169509733, 169396938, 170082968,
   170059828, 170030336, 169305358, 169296814, 169282453,
   169283907, 169956899, 169956888, 169228460, 169225940,
   169956885, 169225967, 169225629, 169229905, 169792749,
   169569022, 169509562, 169328520, 169338237, 169338206,
   169336283, 169298110, 169223656, 169223595, 169225529,
   169085812, 168845609, 168982099, 172258221, 168982087,
   168982077, 168982084, 168982081, 168982074, 168982071,
   168994476, 168982059, 168982065, 168982049, 168982046,
   168987581, 168842929, 168859069, 168842924, 168842925,
   168842917, 168842911, 168842914, 168790490, 168737266,
   168737263, 168737260, 168737257, 168737249, 168541857,
   168758056, 168737240, 168592656, 168592653, 168592647,
   168592641, 168394713, 167892711, 168592631, 168394713,
   168394549, 168529750, 168551273, 168529719, 168529713,
   168529700, 168549596, 168529649, 168536421, 168529604,
   168529545, 168541594, 168529551, 168529542, 168529496,
   168544946, 168389854, 168389776, 168389773, 168389779,
   168389747, 168389744, 168406260, 168389732, 168389716,
   168389713, 168389678, 168389645, 168340206, 168340196,
   168340194, 168340188, 168354688, 168286152, 168286306,
   170894069, 168286284, 168286278, 168286271, 168286253,
   168314147, 168307141, 168294586, 168286190, 168286156,
   168286141, 168286126, 168286110, 168286083, 168286031,
   168240595, 168240589, 168240582, 168240551, 168240521,
   168240510, 169868660, 168240348, 168193205, 167437888,
   170932073, 168193153, 168143283, 168143280, 168143260,
   168143266, 168143254, 168170408, 168180536, 168143214,
   168145961, 167893352, 168065650, 168048666, 168048136,
   168033870, 168033844, 168033813, 168061144, 168033767,
   168033763, 168033732, 168033702, 168033642, 168051457,
   168059829, 168059925, 168033621, 168033612, 168033602,
   168033575, 168033572, 168033543, 168064151, 168033489,
   168033463, 168033457, 168033451, 168033416, 168033389,
   168049291, 167987406, 167955057, 167939170, 167939153,
   167939147, 167959672, 167939138, 167959548, 167947586,
   167939087, 167959574, 167961665, 167960585, 167939059,
   167886932, 167886923, 167886917, 167886854, 167886810,
   167886753, 167886691, 167886670, 167886591, 167833511,
   167833497, 167833494, 167833491, 167833488, 167872772,
   167833473, 167870947, 167833477, 167833463, 167833457,
   167833441, 167833432, 167774549, 167774527, 167774509,
   167774490, 167774475, 167774390, 167774286, 167774198,
   167774139, 167774089, 167774056, 167773970, 167773925,
   167773767, 167773758, 167773622, 167773503, 167773444,
   167773357, 167773292, 167773159, 167773150, 167773088,
   167773027, 167773005, 167772890, 167772767, 167673152,
   167673075, 167672979, 167672922, 167672831, 167672758,
   167672716, 167672661, 167672593, 167672552, 167672452,
   167672442, 167672381, 167672342, 167672266, 167672248,
   167672200, 167672156, 166926499, 167620995, 167620873,
   167620816, 167620723, 167620709, 167620448, 167620326,
   167620294, 167620216, 167620205, 167620139, 167620098,
   167619997, 167619828, 167493845, 167471554, 167458213,
   166942991, 172680003, 172679904))
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1, m_encs->l_cnt = ml_cnt, stat = alterlist(m_encs->lst,ml_cnt),
   m_encs->lst[ml_cnt].f_person_id = e.person_id, m_encs->lst[ml_cnt].f_encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 CALL echo("****** eks include ******")
 DECLARE req = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hreply = i4
 DECLARE crmstatus = i4
 SET ecrmok = 0
 SET null = 0
 IF (validate(recdate,"Y")="Y"
  AND validate(recdate,"N")="N")
  RECORD recdate(
    1 datetime = dq8
  )
 ENDIF
 SUBROUTINE srvrequest(dparam)
   SET req = 3091001
   SET happ = 0
   SET app = 3055000
   SET task = 4801
   SET endapp = 0
   SET endtask = 0
   SET endreq = 0
   CALL echo(concat("curenv = ",build(curenv)))
   IF (curenv=0)
    EXECUTE srvrtl
    EXECUTE crmrtl
    EXECUTE cclseclogin
    SET crmstatus = uar_crmbeginapp(app,happ)
    CALL echo(concat("beginapp status = ",build(crmstatus)))
    IF (happ)
     SET endapp = 1
    ENDIF
   ELSE
    SET happ = uar_crmgetapphandle()
   ENDIF
   IF (happ > 0)
    SET crmstatus = uar_crmbegintask(happ,task,htask)
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmBeginTask return status")
     SET retval = - (1)
    ELSE
     SET endtask = 1
     SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
     IF (crmstatus != ecrmok)
      SET retval = - (1)
      CALL echo(concat("Invalid CrmBeginReq return status of ",build(crmstatus)))
     ELSEIF (hreq=null)
      SET retval = - (1)
      CALL echo("Invalid hReq handle")
     ELSE
      SET endreq = 1
      SET request_handle = hreq
      SET heksopsrequest = uar_crmgetrequest(hreq)
      IF (heksopsrequest=null)
       SET retval = - (1)
       CALL echo("Invalid request handle return from CrmGetRequest")
      ELSE
       SET stat = uar_srvsetstring(heksopsrequest,"EXPERT_TRIGGER",nullterm(eksopsrequest->
         expert_trigger))
       FOR (ndx1 = 1 TO size(eksopsrequest->qual,5))
        SET hqual = uar_srvadditem(heksopsrequest,"QUAL")
        IF (hqual=null)
         CALL echo("QUAL","Invalid handle")
        ELSE
         SET stat = uar_srvsetdouble(hqual,"PERSON_ID",eksopsrequest->qual[ndx1].person_id)
         SET stat = uar_srvsetdouble(hqual,"SEX_CD",eksopsrequest->qual[ndx1].sex_cd)
         SET recdate->datetime = eksopsrequest->qual[ndx1].birth_dt_tm
         SET stat = uar_srvsetdate2(hqual,"BIRTH_DT_TM",recdate)
         SET stat = uar_srvsetdouble(hqual,"ENCNTR_ID",eksopsrequest->qual[ndx1].encntr_id)
         SET stat = uar_srvsetdouble(hqual,"ACCESSION_ID",eksopsrequest->qual[ndx1].accession_id)
         SET stat = uar_srvsetdouble(hqual,"ORDER_ID",eksopsrequest->qual[ndx1].order_id)
         FOR (ndx2 = 1 TO size(eksopsrequest->qual[ndx1].data,5))
          SET hdata = uar_srvadditem(hqual,"DATA")
          IF (hdata=null)
           CALL echo("DATA","Invalid handle")
          ELSE
           SET stat = uar_srvsetstring(hdata,"VC_VAR",nullterm(eksopsrequest->qual[ndx1].data[ndx2].
             vc_var))
           SET stat = uar_srvsetdouble(hdata,"DOUBLE_VAR",eksopsrequest->qual[ndx1].data[ndx2].
            double_var)
           SET stat = uar_srvsetlong(hdata,"LONG_VAR",eksopsrequest->qual[ndx1].data[ndx2].long_var)
           SET stat = uar_srvsetshort(hdata,"SHORT_VAR",eksopsrequest->qual[ndx1].data[ndx2].
            short_var)
          ENDIF
         ENDFOR
         SET retval = 100
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (crmstatus=ecrmok)
    CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime3,"hh:mm:ss.cc;3;m")))
    SET crmstatus = uar_crmperform(hreq)
    CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime3,"hh:mm:ss.cc;3;m")))
    IF (crmstatus != ecrmok)
     SET retval = - (1)
     CALL echo("Invalid CrmPerform return status")
    ELSE
     SET retval = 100
     CALL echo("CrmPerform was successful")
    ENDIF
   ELSE
    SET retval = - (1)
    CALL echo("CrmPerform not executed do to begin request error")
   ENDIF
   IF (endreq)
    CALL echo("Ending CRM Request")
    CALL uar_crmendreq(hreq)
   ENDIF
   IF (endtask)
    CALL echo("Ending CRM Task")
    CALL uar_crmendtask(htask)
   ENDIF
   IF (endapp)
    CALL echo("Ending CRM App")
    CALL uar_crmendapp(happ)
   ENDIF
 END ;Subroutine
 FOR (ml_loop = 1 TO m_encs->l_cnt)
   SET eksopsrequest->expert_trigger = "BHS_EKS_UPDATE_CE"
   SET ml_cnt = 1
   SET stat = alterlist(eksopsrequest->qual,ml_cnt)
   SET eksopsrequest->qual[ml_cnt].person_id = m_encs->lst[ml_loop].f_person_id
   SET eksopsrequest->qual[ml_cnt].encntr_id = m_encs->lst[ml_loop].f_encntr_id
   SET eksopsrequest->qual[ml_cnt].order_id = 0.00
   CALL echorecord(eksopsrequest)
   SET dparam = 0
   CALL echo("****** server call ******")
   CALL srvrequest(dparam)
   CALL echo("****** server call end ******")
 ENDFOR
END GO
