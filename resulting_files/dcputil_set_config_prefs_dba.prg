CREATE PROGRAM dcputil_set_config_prefs:dba
 PAINT
 DECLARE program_version = vc WITH private, constant("008")
 DECLARE cp_id = f8 WITH protect, noconstant(0.0)
#menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(1,2,23,79)
 CALL text(2,17,"C O N F I G U R A T I O N    P R E F E R E N C E S")
 CALL text(6,20,"1)  Set New or Change Existing Preferences")
 CALL text(8,20,"2)  View Current Settings")
 CALL text(10,20,"3)  Preference Descriptions")
 CALL text(12,20,"4)  Initialize Table to Default Values")
 CALL text(14,20,"5)  Exit")
 CALL text(24,2,"Select an Option(1,2,3,4,5)")
 CALL accept(24,30,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   GO TO set_prefs
  OF 2:
   GO TO view_prefs
  OF 3:
   GO TO prefs_description
  OF 4:
   GO TO set_defaults
  OF 5:
   GO TO skip_commit
  ELSE
   GO TO skip_commit
 ENDCASE
 GO TO menu
#view_prefs
 CALL clear(1,1)
 SELECT
  *
  FROM config_prefs
 ;end select
 GO TO menu
#prefs_description
 CALL clear(1,1)
 CALL text(1,2,
  "        ***Note: a server must have been purchased for calls to that server to be enabled***                    "
  )
 CALL text(2,2,
  "                 *** An incorrect setting for a server will result in errors ***                                "
  )
 CALL text(3,2,"Config name     Value        Meaning")
 CALL text(4,2,
  "-----------     -----        -----------------------------------------------------------------------------------"
  )
 CALL text(5,2,
  "DOCMGMT         1            Enables calls to the task server.                                                  "
  )
 CALL text(6,2,
  "                0            Disables calls to the task server.                                                 "
  )
 CALL text(8,2,
  "ECO             1            Enables ability to have Explode Continuous Orders.                                 "
  )
 CALL text(9,2,
  "                0            Disables ability for Explode Continuous Orders.                                    "
  )
 CALL text(11,2,
  "AFC             1            Enables calls to the charge server.                                                "
  )
 CALL text(12,2,
  "                0            Disables calls to the charge server.                                               "
  )
 CALL text(14,2,
  "SCHED           1            Enables calls to the Scheduling server.                                            "
  )
 CALL text(15,2,
  "                0            Disables calls to the Scheduling server.                                           "
  )
 CALL text(17,2,
  "ORDOUTPUT       1            Enables calls to the output server.                                                "
  )
 CALL text(18,2,
  "                0            Disables calls to the output server.                                               "
  )
 CALL text(20,2,
  "PRINTOSONACT    1            Prints an Order Sheet on MedStudent Activate (Physician Cosign Only), regardless   "
  )
 CALL text(21,2,
  "                             if the requisition or consent form options are on or off.                          "
  )
 CALL text(22,2,
  "                0            Prints an Order Sheet on MedStudent Activate (Physician Cosign Only), only         "
  )
 CALL text(23,2,
  "                             if the requisition or consent form option is set. Otherwise does not print.        "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,"Config name     Value        Meaning")
 CALL text(2,2,
  "-----------     -----        ---------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  "PHARM_NOTASK    1            Order instances and associated tasks will not be exploded for                    "
  )
 CALL text(4,2,
  "                             pharmacy continuing orders.                                                      "
  )
 CALL text(5,2,
  "                0            Order instances and associated tasks will be exploded for                        "
  )
 CALL text(6,2,
  "                             pharmacy continuing orders.                                                      "
  )
 CALL text(8,2,
  "TASKPENDCOMP    1            Once the stop date and time of a pharmacy task-based or pharmacy-based           "
  )
 CALL text(9,2,
  "                             continuing order has been met, the system will use tasks                         "
  )
 CALL text(10,2,
  "                             associated to the order to determine whether the order is Pending                "
  )
 CALL text(11,2,
  "                             Complete or Complete.  When the parent of the continuing order is                "
  )
 CALL text(12,2,
  "                             completed, child orders in the past for that parent will be updated              "
  )
 CALL text(13,2,
  "                             to complete.                                                                     "
  )
 CALL text(14,2,
  "                0            Once the stop date and time of a pharmacy task-based or pharmacy-based           "
  )
 CALL text(15,2,
  "                             based continuing order has been met, the system will use order                   "
  )
 CALL text(16,2,
  "                             instances associated to the order to determine whether the order is              "
  )
 CALL text(17,2,
  "                             Pending Complete or Complete.                                                    "
  )
 CALL text(19,2,
  "NUM_ORDERS      X            X = The number of orders that the ECO Server will explode at a time -            "
  )
 CALL text(20,2,
  "                             preventative. It must be between 0 and 10000.                                    "
  )
 CALL text(22,2,
  "RXLABELPRINT    1            Inpatient labels will print asynchronously                                       "
  )
 CALL text(23,2,
  "                0            Inpatient labels (other than fill and report) will print synchronously (default) "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(2,2,
  "-----------     -----          --------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  "NOTDNKEEPORD    1              When Nurse Collect tasks are charted as Not Done, the server will  not update   "
  )
 CALL text(4,2,
  "                               the order instance to an end-state                                              "
  )
 CALL text(5,2,
  "                0              When Nurse Collect tasks are charted as Not Done, the server will evaluate the  "
  )
 CALL text(6,2,
  "                               the order instance for cancellation or discontinue.                             "
  )
 CALL text(8,2,
  "COMP_CONT_IV    TASK           When a continuous infusion is ordered with a duration unit of Dose(s), Time(s), "
  )
 CALL text(9,2,
  "                                or Bag(s), individual charting events (Begin Bag, Site, Infuse, Bolus, Waste    "
  )
 CALL text(10,2,
  "                               Rate) will be considered as clinical charting events toward the completion of   "
  )
 CALL text(11,2,
  "                               the order. When the number of charting events equal the duration value, the     "
  )
 CALL text(12,2,
  "                               order will go to a completed status.                                            "
  )
 CALL text(13,2,
  "                STOPDTTM       When a continuous infusion is ordered with a duration unit of Dose(s), Time(s), "
  )
 CALL text(14,2,
  "                               or Bag(s), individual charting events (Begin Bag, Site, Infuse, Bolus, Waste    "
  )
 CALL text(15,2,
  "                               Rate) will not be considered as clinical charting events toward the completion  "
  )
 CALL text(16,2,
  "                               of the order. The only way that the order shall go to a completed status is if  "
  )
 CALL text(17,2,
  "                               the Stop Date/Time has been reached.                                            "
  )
 CALL text(18,2,
  "                               If not set, the system behaves as if this preference was set to 'STOPDTTM'.     "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,"Config name     Value        Meaning")
 CALL text(2,2,
  "-----------     -----        ----------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  "DSCH_CANCEL     ALL          All orders cancelled when a patient is discharged.                                "
  )
 CALL text(4,2,
  "                NONE         No orders cancelled when a patient is discharged.                                 "
  )
 CALL text(5,2,
  "                TEMP         Template orders cancelled and children discontinued.                              "
  )
 CALL text(6,2,
  "                ORD          Orders with Allow Cancel Indicator=1(Setup through tools) will be cancelled.      "
  )
 CALL text(7,2,
  "                ALL>X        Orders scheduled beyond X minutes will be cancelled.                              "
  )
 CALL text(8,2,
  "                ORD>X        Orders scheduled beyond X minutes with Allow Cancel Indicator=1 are cancelled.    "
  )
 CALL text(10,2,
  "MEDSTUD_ROUT    ORDER        Order by Med Student will be routed to ordering physician.                        "
  )
 CALL text(11,2,
  "                ATTEND       Order by Med Student will be routed to attending physician.                       "
  )
 CALL text(13,2,
  "INBOX           1            Enables Call to CPS Task Server for Consuting Med Services.                       "
  )
 CALL text(14,2,
  "                0            Disables Call to CPS Task Server.                                                 "
  )
 CALL text(16,2,
  "DCPTASKLIMIT    X            X = The soft limit for the number of tasks retrieved per call to the DCP Query    "
  )
 CALL text(17,2,
  "                             Tasks Server.                                                                     "
  )
 CALL text(19,2,
  "DIFFPHYCOSGN    1            Physician entered orders will be evaluated for cosignature when the ordering      "
  )
 CALL text(20,2,
  "                             physician is changed.                                                             "
  )
 CALL text(21,2,
  "                0            Physician entered orders will not be evaluated for cosignature when the ordering  "
  )
 CALL text(22,2,
  "                             physician is changed.                                                             "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "   These are the preferences that have to do with the ORM Continuing Order Ops Job                             "
  )
 CALL text(2,2,
  "   ----------------------------------------------------------------------------------------------------------- "
  )
 CALL text(5,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(6,2,
  "-----------     -----          --------------------------------------------------------------------------------"
  )
 CALL text(7,2,
  "FUTUREUPDHRS    DO NOT UPDATE  Orders in a future status will not be updated                                   "
  )
 CALL text(8,2,
  "                X              The number of hours after a parent order in a future status has reached its stop"
  )
 CALL text(9,2,
  "                               date and time before the order will be canceled.                                "
  )
 CALL text(11,2,
  "INCOMPUPDHRS    DO NOT UPDATE  Orders in an incomplete status will not be updated.                             "
  )
 CALL text(12,2,
  "                X              The number of hours after an order in an incomplete status has reached its stop "
  )
 CALL text(13,2,
  "                               date and time before the order will be canceled.                                "
  )
 CALL text(15,2,
  "MDSTUDUPDHRS    DO NOT UPDATE  Orders in a medstudent on-hold status will not be updated.                      "
  )
 CALL text(16,2,
  "                X              The number of hours after an order in a medstudent on-hold status has reached   "
  )
 CALL text(17,2,
  "                               its stop date and time before the order will be canceled.                       "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "   These are the preferences that have to do with the Inpatient Cancel On Discharge Operations Job             "
  )
 CALL text(2,2,
  "   ----------------------------------------------------------------------------------------------------------- "
  )
 CALL text(5,2,
  "Config name              Value              Meaning                                                            "
  )
 CALL text(6,2,
  "-----------              -----              ------------------------------------------------------------------ "
  )
 CALL text(7,2,
  "INDSCH_HRS               X                  X = The number of hours after the discharge date that an           "
  )
 CALL text(8,2,
  "                                               inpatient's active orders are discontinued/canceled.            "
  )
 CALL text(10,2,
  "INDSCH_FLAG              ALL                All Inpatient Orders will be canceled upon discharge.              "
  )
 CALL text(11,2,
  "                         TEMP               All Inpatient Template Orders will be canceled upon discharge.     "
  )
 CALL text(12,2,
  "                         ORD                Inpatient Orders marked for auto cancel upon discharge set         "
  )
 CALL text(13,2,
  "                                               in the order catalog tool will be canceled                      "
  )
 CALL text(14,2,
  "                         ALL>INDSCH_HRS     ALL Inpatient Orders with a start date/time greater than the       "
  )
 CALL text(15,2,
  "                                               value of INDSCH_HRS + the discharge date/time will be canceled. "
  )
 CALL text(16,2,
  "                         ORD>INDSCH_HRS     Inpatient Orders marked for cancel upon discharge in the order     "
  )
 CALL text(17,2,
  "                                               catalog tool and have a start date/time greater than the value  "
  )
 CALL text(18,2,
  "                                               of INDSCH_HRS + the discharge date/time will be canceled.       "
  )
 CALL text(20,2,
  "INCLEAN_HRS              X                  The number of hours post discharge that all active inpatient       "
  )
 CALL text(21,2,
  "                                               orders should be cleaned up.                                    "
  )
 CALL text(22,2,
  "INDSCH_LOOKBACK_DAYS     X                  The number of days post discharge date for the inpatient           "
  )
 CALL text(23,2,
  "                                               encounters to qualify for cleanup.                              "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "   These are the preferences that have to do with the Non-inpatient Cancel On Discharge Operations Job         "
  )
 CALL text(2,2,
  "   ----------------------------------------------------------------------------------------------------------- "
  )
 CALL text(5,2,
  "Config name              Value              Meaning                                                            "
  )
 CALL text(6,2,
  "-----------              -----              ------------------------------------------------------------------ "
  )
 CALL text(7,2,
  "OUTDSCH_HRS              X                  X = The number of hours after the discharge date that              "
  )
 CALL text(8,2,
  "                                                non-inpatient's active orders are discontinued/canceled.       "
  )
 CALL text(10,2,
  "OUTDSCH_FLAG             ALL                All Non-inpatient Orders will be canceled upon discharge.          "
  )
 CALL text(11,2,
  "                         TEMP               All Non-inpatient Template Orders will be canceled upon discharge. "
  )
 CALL text(12,2,
  "                         ORD                Non-Inpatient Orders marked for auto cancel upon discharge set     "
  )
 CALL text(13,2,
  "                                                in the order catalog tool will be canceled                     "
  )
 CALL text(14,2,
  "                         ALL>OUTDSCH_HRS    ALL Non-inpatient Orders with a start date/time greater than the   "
  )
 CALL text(15,2,
  "                                               value of OUTDSCH_HRS + the discharge date/time will be canceled."
  )
 CALL text(16,2,
  "                         ORD>OUTDSCH_HRS    Non-Inpatient Orders marked for cancel upon discharge in the order "
  )
 CALL text(17,2,
  "                                               catalog tool and have a start date/time greater than the value  "
  )
 CALL text(18,2,
  "                                               of INDSCH_HRS + the discharge date/time will be canceled.       "
  )
 CALL text(20,2,
  "OUTCLEAN_HRS             X                  The number of hours post discharge that all active non-inpatient   "
  )
 CALL text(21,2,
  "                                               orders should be cleaned up.                                    "
  )
 CALL text(22,2,
  "OUTDSCH_LOOKBACK_DAYS    X                  The number of days post discharge date for the non-inpatient       "
  )
 CALL text(23,2,
  "                                               encounters to qualify for cleanup.                              "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "    These are the preferences that have to do with the Cancel Orders on Leave Of Absence Operations Job        "
  )
 CALL text(2,2,
  "    ---------------------------------------------------------------------------------------------------        "
  )
 CALL text(5,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(6,2,
  "-----------     -----          ------------------------------------------------------------------------------- "
  )
 CALL text(7,2,
  "LOA_HRS         X              X = The number of hours after the leave date/time that orders will qualify to   "
  )
 CALL text(8,2,
  "                                   be discontinued/canceled.                                                   "
  )
 CALL text(10,2,
  "LOA_FLAG        ALL            All orders will be canceled for patients on leave of absence.                   "
  )
 CALL text(11,2,
  "                TEMP           All template orders will be canceled for patients on extended leave of absence. "
  )
 CALL text(12,2,
  "                ORD            Orders marked for auto cancel upon discharge set in the order catalog tool      "
  )
 CALL text(13,2,
  "                                   will be canceled for patients on extended leave of absence.                 "
  )
 CALL text(14,2,
  "                ALL>LOA_HRS    All orders with a start date/time greater that the value of LOA_HRS + the leave "
  )
 CALL text(15,2,
  "                                   date/time will canceled for pateints on extended leave of absence.          "
  )
 CALL text(16,2,
  "                ORD>LOA_HRS    Orders marked for auto cancel upon discharge set in the order catalog tool and  "
  )
 CALL text(17,2,
  "                                   have a start date/time greater that the value of LOA_HRS + the leave date/  "
  )
 CALL text(18,2,
  "                                   time will be canceled for patients on extended leave of absence.            "
  )
 CALL text(24,2,"Press Enter for the next screen")
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(2,2,
  "-----------     -----          --------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  "LR              1              Enables ability to create Legitimate Relationship (LR) functionality.           "
  )
 CALL text(4,2,
  "                0              Disables ability to create Legitimate Relationship (LR) functionality.          "
  )
 CALL text(5,2,
  "DYNAM_POSITN    1              Enables dynamic position functionality.  If a user selects their role (position)"
  )
 CALL text(6,2,
  "                               at the time of sign-on, then this setting is recommended.                       "
  )
 CALL text(7,2,
  "                0              Disables dynamic positions.  This setting is used when a user is associated     "
  )
 CALL text(8,2,
  "                               to one position.                                                                "
  )
 CALL text(9,2,
  "ROUTE_NOTIF     1              Med student notifications will route based on the config pref setting for       "
  )
 CALL text(10,2,
  "                               MEDSTUD_ROUT. Physician co-signature notifications will route based on Order    "
  )
 CALL text(11,2,
  "                               Catalog Review setting.                                                         "
  )
 CALL text(12,2,
  "                0              Default (co-signature and med student notifications are routed to Ordering      "
  )
 CALL text(13,2,
  "                               Physician)                                                                      "
  )
 CALL text(14,2,
  "DCPCNCLUNSCH    1              Unscheduled orders will honor the code value extension DCP_ALLOW_CANCEL setting "
  )
 CALL text(15,2,
  "                               on code set 14281.                                                              "
  )
 CALL text(16,2,
  "                0              Default (Unscheduled orders will not honor the code value extension             "
  )
 CALL text(17,2,
  "                               DCP_ALLOW_CANCEL setting on code set 14281)                                     "
  )
 CALL text(18,2,
  "DCPCNCLPRN      1              PRN orders will honor the code value extension DCP_ALLOW_CANCEL setting on      "
  )
 CALL text(19,2,
  "                               code set 14281.                                                                 "
  )
 CALL text(20,2,
  "                0              Default (PRN orders will not honor the code value extension                     "
  )
 CALL text(21,2,
  "                               DCP_ALLOW_CANCEL setting on code set 14281)                                     "
  )
 CALL text(24,2,
  "Press Enter for the next screen                                                                                "
  )
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(2,2,
  "-----------     -----          --------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  "RTEPROPNOTIF    RESPONSIBLE    Order Proposals Notification will be routed to the responsible personnel.       "
  )
 CALL text(4,2,
  "                ATTEND         Order Proposals Notification will be routed to the attending physician.         "
  )
 CALL text(5,2,
  "                               If not valued, the proposal notification will be routed to the responsible      "
  )
 CALL text(6,2,
  "                               physician.                                                                      "
  )
 CALL text(7,2,
  "ACPTPROPNOTF    0              Order Proposal Acceptance notifications will not be generated when an           "
  )
 CALL text(8,2,
  "                               order proposal is accepted.                                                     "
  )
 CALL text(9,2,
  "                1              Order Proposal Acceptance notifications will be generated when an               "
  )
 CALL text(10,2,
  "                               order proposal is accepted.                                                     "
  )
 CALL text(11,2,
  "FORMULRYSTAT    0              A formulary status will not be determined for any orders.                       "
  )
 CALL text(12,2,
  "                1              A formulary status will be determined and assigned for new, modified and        "
  )
 CALL text(13,2,
  "                               activated future orders.                                                        "
  )
 CALL text(14,2,
  "DCPTASKW/NC     0              If the specimenbasednursecollection preference is set to 2, a DCP task will not "
  )
 CALL text(15,2,
  "                               be created for nurse collect orders.                                            "
  )
 CALL text(16,2,
  "                1              If the specimenbasednursecollection preference is set to 2, a DCP task          "
  )
 CALL text(17,2,
  "                               will be created in addition to the nurse collect task created by pathnet.       "
  )
 CALL text(18,2,
  "PLANPROCMIN     X              X = The number of minutes that PowerPlans will wait for orders to process after "
  )
 CALL text(19,2,
  "                               ordering. Once this amount of time has elapsed the plan order will be           "
  )
 CALL text(20,2,
  "                               considered as a failed create.                                                  "
  )
 CALL text(24,2,
  "Press Enter for the next screen                                                                        "
  )
 CALL accept(24,33,"P"," ")
 CALL clear(1,1)
 CALL text(1,2,
  "Config name     Value          Meaning                                                                         "
  )
 CALL text(2,2,
  "-----------     -----          --------------------------------------------------------------------------------"
  )
 CALL text(3,2,
  " ESOCANCELFUT    0              When a future order is canceled, the order server will not call the             "
  )
 CALL text(4,2,
  "                                filtering script eso_get_order_action, which means that canceled future         "
  )
 CALL text(5,2,
  "                                orders will not be sent outbound.                                               "
  )
 CALL text(6,2,
  "                 1              The order write server will call the ESO filtering script                       "
  )
 CALL text(7,2,
  "                                eso_get_order_action to determine whether the canceled future order should      "
  )
 CALL text(8,2,
  "                                be sent outbound.                                                               "
  )
 CALL text(9,2,
  "Config name                               Value          Meaning                                               "
  )
 CALL text(10,2,
  "-------------------------------------     -----          -----------------------------------------------------"
  )
 CALL text(11,2,
  " OSSRXPRODUCTMNEMONICTYPEFILTEROVERRIDE    X              X = The prescription mnemonic types that should be   "
  )
 CALL text(12,2,
  "                                                          considered as products. This list must be comma      "
  )
 CALL text(13,2,
  "                                                          separated. The only valid values are A, B, C, E, M,  "
  )
 CALL text(14,2,
  "                                                          N, Y, and Z.                                         "
  )
 CALL text(24,2,
  "Press Enter to go back to the Main Menu                                                                        "
  )
 CALL accept(24,41,"P"," ")
 GO TO menu
#set_defaults
 CALL clear(1,1)
 CALL box(1,2,23,79)
 SET current = 0
 SET cp_id = 0.0
 SET name = "                                             "
 SET value = "                         "
 SET cvalue = "                        "
 SET changes = "N"
#0
 SET name = "DOCMGMT"
 SET value = "0"
 GO TO check_defaults
#1
 SET name = "ECO"
 SET value = "1"
 GO TO check_defaults
#2
 SET name = "AFC"
 SET value = "1"
 GO TO check_defaults
#3
 SET name = "SCHED"
 SET value = "0"
 GO TO check_defaults
#4
 SET name = "ORDOUTPUT"
 SET value = "1"
 GO TO check_defaults
#5
 SET name = "DSCH_CANCEL"
 SET value = "TEMP"
 GO TO check_defaults
#6
 SET name = "MEDSTUD_ROUT"
 SET value = "ORDER"
 GO TO check_defaults
#7
 GO TO check_defaults
#8
 SET name = "INBOX"
 SET value = "0"
 GO TO check_defaults
#9
 SET name = "NUM_ORDERS"
 SET value = "100"
 GO TO check_defaults
#10
 SET name = "DCPTASKLIMIT"
 SET value = "250"
 GO TO check_defaults
#11
 SET name = "DIFFPHYCOSGN"
 SET value = "0"
 GO TO check_defaults
#12
 SET name = "PHARM_NOTASK"
 SET value = "0"
 GO TO check_defaults
#13
 SET name = "TASKPENDCOMP"
 SET value = "0"
 GO TO check_defaults
#14
 SET name = "INDSCH_HRS"
 SET value = "4"
 GO TO check_defaults
#15
 SET name = "INDSCH_FLAG"
 SET value = "TEMP"
 GO TO check_defaults
#16
 SET name = "INCLEAN_HRS"
 SET value = "0"
 GO TO check_defaults
#17
 SET name = "OUTDSCH_HRS"
 SET value = "12"
 GO TO check_defaults
#18
 SET name = "OUTDSCH_FLAG"
 SET value = "TEMP"
 GO TO check_defaults
#19
 SET name = "OUTCLEAN_HRS"
 SET value = "0"
 GO TO check_defaults
#20
 SET name = "LOA_HRS"
 SET value = "4"
 GO TO check_defaults
#21
 SET name = "LOA_FLAG"
 SET value = "TEMP"
 GO TO check_defaults
#22
 SET name = "FUTUREUPDHRS"
 SET value = "0"
 GO TO check_defaults
#23
 SET name = "INCOMPUPDHRS"
 SET value = "0"
 GO TO check_defaults
#24
 SET name = "MDSTUDUPDHRS"
 SET value = "0"
 GO TO check_defaults
#25
 SET name = "NOTDNKEEPORD"
 SET value = "0"
 GO TO check_defaults
#26
 SET name = "COMP_CONT_IV"
 SET value = "STOPDTTM"
 GO TO check_defaults
#27
 SET name = "PRINTOSONACT"
 SET value = "0"
 GO TO check_defaults
#28
 SET name = "LR"
 SET value = "0"
 GO TO check_defaults
#29
 SET name = "DYNAM_POSITN"
 SET value = "0"
 GO TO check_defaults
#30
 SET name = "RXLABELPRINT"
 SET value = "0"
 GO TO check_defaults
#31
 SET name = "ROUTE_NOTIF"
 SET value = "0"
 GO TO check_defaults
#32
 SET name = "DCPCNCLUNSCH"
 SET value = "0"
 GO TO check_defaults
#33
 SET name = "DCPCNCLPRN"
 SET value = "0"
 GO TO check_defaults
#34
 SET name = "RTEPROPNOTIF"
 SET value = "RESPONSIBLE"
 GO TO check_defaults
#35
 SET name = "ACPTPROPNOTF"
 SET value = "0"
 GO TO check_defaults
#36
 SET name = "FORMULRYSTAT"
 SET value = "0"
 GO TO check_defaults
#37
 SET name = "PLANPROCMIN"
 SET value = "10"
 GO TO check_defaults
#38
 SET name = "ESOCANCELFUT"
 SET value = "0"
 GO TO check_defaults
#39
 SET name = "OSSRXPRODUCTMNEMONICTYPEFILTEROVERRIDE"
 SET value = ""
 GO TO check_defaults
#40
 SET name = "INDSCH_LOOKBACK_DAYS"
 SET value = "2"
 GO TO check_defaults
#41
 SET name = "OUTDSCH_LOOKBACK_DAYS"
 SET value = "2"
 GO TO check_defaults
#42
 CALL text(12,15,"Default Values Set")
 IF (changes="Y")
  CALL text(20,15,"Commit changes?                        ")
  CALL accept(20,31,"X;CU","N")
  IF (curaccept="Y")
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ELSE
  CALL text(20,4,"Press Enter to go back to the Main Menu")
  CALL accept(20,43,"P"," ")
 ENDIF
 GO TO menu
#check_defaults
 SELECT INTO "nl:"
  cp.config_prefs_id
  FROM config_prefs cp
  WHERE cp.config_name=name
  DETAIL
   cvalue = cp.config_value
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND value=cvalue)
  SET current += 1
  GO TO (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12, 13, 14, 15,
  16, 17, 18, 19, 20,
  21, 22, 23, 24, 25,
  26, 27, 28, 29, 30,
  31, 32, 33, 34, 35,
  36, 37, 38, 39, 40,
  41, 42, 43)current
 ENDIF
 IF (curqual > 0
  AND value != cvalue)
  SET nsize = textlen(trim(name))
  SET vsize = textlen(trim(value))
  CALL text(20,15,"                                       ")
  CALL text(15,5,"Configuration preference for ")
  CALL text(15,35,name)
  CALL text(15,(36+ nsize),"value=")
  CALL text(15,(43+ nsize),cvalue)
  CALL text(16,5,"already exists, overwrite with value=")
  CALL text(16,42,value)
  CALL text(16,(43+ vsize)," (Y/N)?")
  CALL accept(16,(50+ vsize),"X;CU","N")
  IF (curaccept != "Y")
   CALL text(15,5,"                                                                ")
   CALL text(16,5,"                                                                ")
   SET current += 1
   GO TO (1, 2, 3, 4, 5,
   6, 7, 8, 9, 10,
   11, 12, 13, 14, 15,
   16, 17, 18, 19, 20,
   21, 22, 23, 24, 25,
   26, 27, 28, 29, 30,
   31, 32, 33, 34, 35,
   36, 37, 38, 39, 40,
   41, 42, 43)current
  ENDIF
  CALL text(15,5,"                                                                ")
  CALL text(16,5,"                                                                ")
  GO TO update_defaults
 ENDIF
#insert_default
 SET changes = "Y"
 CALL text(20,15,"Inserting in database...                   ")
 SELECT INTO "nl:"
  w = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   cp_id = w
  WITH format, nocounter
 ;end select
 INSERT  FROM config_prefs
  SET config_prefs_id = cp_id, flexed_by = "INSTALLATION", parent_entity_name = " ",
   parent_entity_id = 0.00, config_name = name, config_value = value,
   updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0, updt_task = 0,
   updt_cnt = 0, updt_applctx = 0
 ;end insert
 SET current += 1
 GO TO (1, 2, 3, 4, 5,
 6, 7, 8, 9, 10,
 11, 12, 13, 14, 15,
 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25,
 26, 27, 28, 29, 30,
 31, 32, 33, 34, 35,
 36, 37, 38, 39, 40,
 41, 42, 43)current
#update_defaults
 SET changes = "Y"
 CALL text(20,15,"Updating database...                   ")
 UPDATE  FROM config_prefs
  SET config_value = value, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0,
   updt_task = 0, updt_cnt = (updt_cnt+ 1), updt_applctx = 0
  WHERE config_name=name
 ;end update
 SET current += 1
 GO TO (1, 2, 3, 4, 5,
 6, 7, 8, 9, 10,
 11, 12, 13, 14, 15,
 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25,
 26, 27, 28, 29, 30,
 31, 32, 33, 34, 35,
 36, 37, 38, 39, 40,
 41, 42, 43)current
 GO TO menu
#set_prefs
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(3,25,"** CONFIGURATION PREFERENCES **")
 CALL text(8,3,"Config name:")
 CALL text(9,3,"Config value:")
#restart
 SET name = "                                                  "
 SET value = "                                                                       "
 SET cvalue = "                                "
 SET cp_id = 0.0
 SET all_fields = "Y"
 CALL text(20,15,"                                       ")
#config_name
 CALL accept(8,23,"P(50);CU",name)
 IF (curaccept != " ")
  SET name = curaccept
 ELSE
  SET all_fields = "N"
 ENDIF
#config_value
 CALL accept(9,23,"P(50);CU",value)
 IF (curaccept != " ")
  SET value = curaccept
 ELSE
  SET all_fields = "N"
  GO TO check_all_fields
 ENDIF
 IF (name="MEDSTUD_ROUT"
  AND value != "ATTEND"
  AND value != "ORDER")
  CALL text(15,10,"Value can only be ATTEND or ORDER, please reenter")
  GO TO restart
 ENDIF
#check_all_fields
 IF (all_fields="N")
  CALL text(15,10,"Config name/value fields need to be valued.  Exit screen? (Y/N)")
  CALL accept(15,74,"X;CU","Y")
  IF (curaccept="Y")
   GO TO exit_program
  ELSE
   CALL text(15,10,"                                                                  ")
   GO TO restart
  ENDIF
 ENDIF
#duplicates
 CALL text(20,15,"Checking for duplicate record...       ")
#check_existing
 SELECT INTO "nl:"
  cp.config_prefs_id
  FROM config_prefs cp
  WHERE cp.config_name=name
  DETAIL
   cvalue = cp.config_value
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND value=cvalue)
  GO TO check_for_more
 ENDIF
 IF (curqual > 0
  AND value != cvalue)
  CALL text(20,15,"                                       ")
  CALL text(15,10,"Configuration preference already exists, overwrite? (Y/N)")
  CALL accept(15,68,"X;CU","N")
  IF (curaccept != "Y")
   GO TO check_for_more
  ENDIF
  CALL text(15,10,"                                                                          ")
  GO TO update_config_prefs
 ENDIF
#insert_config_prefs
 CALL text(20,15,"Updating database...                   ")
 SELECT INTO "nl:"
  w = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   cp_id = w
  WITH format, nocounter
 ;end select
 INSERT  FROM config_prefs
  SET config_prefs_id = cp_id, flexed_by = "INSTALLATION", parent_entity_name = " ",
   parent_entity_id = 0.00, config_name = name, config_value = value,
   updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0, updt_task = 0,
   updt_cnt = 0, updt_applctx = 0
 ;end insert
 GO TO check_for_more
#update_config_prefs
 CALL text(20,15,"Updating database...                   ")
 UPDATE  FROM config_prefs
  SET config_value = value, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 0,
   updt_task = 0, updt_cnt = (updt_cnt+ 1), updt_applctx = 0
  WHERE config_name=name
 ;end update
#check_for_more
 CALL text(20,15,"Set another name-value pair? (Y/N)     ")
 CALL accept(20,50,"X;CU","N")
 IF (curaccept="Y")
  GO TO restart
 ENDIF
#exit_program
 CALL text(20,15,"Commit changes?                        ")
 CALL accept(20,31,"X;CU","N")
 IF (curaccept="Y")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 GO TO menu
#skip_commit
END GO
