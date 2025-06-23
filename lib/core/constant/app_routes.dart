import 'package:flutter/material.dart';
import 'package:richzspot/app.dart';
import 'package:richzspot/app_staff.dart';
import 'package:richzspot/feautures/activity/screen/activity_screen.dart';
import 'package:richzspot/feautures/attendance/screen/attendance_screen.dart';
import 'package:richzspot/feautures/auth/screen/sign_screen.dart';
import 'package:richzspot/feautures/claim/screen/add_claim_screen.dart';
import 'package:richzspot/feautures/crm/tickets/screen/ticket_page.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation.dart';
import 'package:richzspot/feautures/face_recognation/face_recognation_register.dart';
import 'package:richzspot/feautures/home/home.dart';
import 'package:richzspot/feautures/home/home_staff.dart';
import 'package:richzspot/feautures/leave/screen/leave_approval_screen.dart';
import 'package:richzspot/feautures/leave/screen/leave_screen.dart';
import 'package:richzspot/feautures/overtime/screen/overtime_approval_screen.dart';
import 'package:richzspot/feautures/overtime/screen/overtime_screen.dart';
import 'package:richzspot/feautures/payslip/screen/approval_payslip_screen.dart';
import 'package:richzspot/feautures/payslip/screen/payslip_screen.dart';
import 'package:richzspot/feautures/payslip/screen/payslip_screen_detail.dart';
import 'package:richzspot/feautures/time_off/screen/timeoff_approval_screen.dart';
import 'package:richzspot/feautures/time_off/screen/timeoff_screen.dart';

class AppRoutes {
  static const String appRoot = '/appRoot';
  static const String appRootStaff = '/appRootStaff';
  static const String sign = '/sign';
  static const String home = '/home';
  static const String faceRecognation = '/face';
  static const String faceRecognationRegister = '/faceRegister';
  static const String attendance = '/attendance';
  static const String activity = '/activity';
  static const String leave = '/leave';
  static const String assignment = '/assignment';
  static const String timeOff = '/timeOff';
  static const String overtime = '/overtime';
  static const String claim = '/addClaim';
  static const String payslip = '/payslip';
  static const String more = '/more';
  

  static const String homeStaff = '/homeStaff';
  static const String leaveApproval = '/leaveApproval';
  static const String overtimeApproval = '/overtimeApproval';
  static const String timeOffApproval = '/timeOffApproval';
  static const String paySlipApproval = '/paySlipApproval';

  // CRM
  static String crmTickets = '/crmTickets';

  static String crmProgrammer = '/crmProgrammer';

  static String crmTasklist = '/crmTasklist';

 
  
  

  static final Map<String, WidgetBuilder> routes = {
    appRoot: (_) => const AppScreen(),
    appRootStaff: (_) => const AppStaffScreen(),
    sign: (_) => const SignScreen(),
    home: (_) => const HomeScreen(),
    faceRecognation: (_) => const FaceScanner(),
    faceRecognationRegister: (_) => const FaceScannerRegister(),
    attendance: (_) => const AttendanceHistoryScreen(),
    activity: (_) => const ActivityScreen(),
    leave: (_) => const LeaveManagementScreen(),
    // assignment: (_) => const AssignmentScreen(),
    overtime: (_) => const OvertimeScreen(),
    claim: (_) => const AddClaimScreen(),
    payslip: (_) => PayslipScreen(),
    timeOff: (_) => const TimeOffScreen(),
    // more: (_) => const MoreScreen(),
    
    homeStaff: (_) => const HomeStaffScreen(),
    leaveApproval: (_) => const LeaveApprovalScreen(),
    overtimeApproval: (_) => const OvertimeApprovalScreen(),
    timeOffApproval: (_) => const TimeOffApprovalScreen(),
    paySlipApproval: (_) => const ApprovalPayslipScreen(),

    // CRM
    crmTickets: (_) => TicketPage(),
    // crmProgrammer: (_) => const CrmProgrammerPage(),
    // crmTasklist: (_) => const CrmTasklistPage(),
  };

  // This is used for navigation without context, e.g., in background services
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  
}
