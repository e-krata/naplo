import 'package:intl/intl.dart';

class KretaAPI {

  static String get login => BaseKreta.kretaIdp + KretaApiEndpoints.token;
  static String get logout => BaseKreta.kretaIdp + KretaApiEndpoints.revoke;

 
  static String get nonce => BaseKreta.kretaIdp + KretaApiEndpoints.nonce;

  static const clientId = "filc-ellenorzo-mobile-android";


  // Az `iss` (intézménykód) a signature miatt marad; a host fix baseUrl.

  static String notes(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.notes;

  static String events(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.events;

  static String student(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.student;

  static String grades(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.grades;

  static String absences(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.absences;

  static String groups(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.groups;

  static String groupAverages(String iss, String uid) =>
      "${BaseKreta.kreta(iss)}${KretaApiEndpoints.groupAverages}?oktatasiNevelesiFeladatUid=$uid";

  static String averages(String iss, String uid) =>
      "${BaseKreta.kreta(iss)}${KretaApiEndpoints.averages}?oktatasiNevelesiFeladatUid=$uid";

  static String timetable(String iss, {DateTime? start, DateTime? end}) =>
      BaseKreta.kreta(iss) +
      KretaApiEndpoints.timetable +
      (start != null && end != null
          ? "?datumTol=${start.toUtc().toIso8601String()}&datumIg=${end.toUtc().toIso8601String()}"
          : "");

  static String exams(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.exams;

  static String homework(String iss, {DateTime? start, String? id}) =>
      BaseKreta.kreta(iss) +
      KretaApiEndpoints.homework +
      (id != null ? "/$id" : "") +
      (id == null && start != null
          ? "?datumTol=${DateFormat('yyyy-MM-dd').format(start)}"
          : "");

  static String capabilities(String iss) =>
      BaseKreta.kreta(iss) + KretaApiEndpoints.capabilities;

  static String downloadHomeworkAttachments(
          String iss, String uid, String type) =>
      BaseKreta.kreta(iss) +
      KretaApiEndpoints.downloadHomeworkAttachments(uid, type);

  static String subjects(String iss, String uid) =>
      "${BaseKreta.kreta(iss)}${KretaApiEndpoints.subjects}?oktatasiNevelesiFeladatUid=$uid";


  static String get sendMessage =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.sendMessage;

  static String messages(String endpoint) =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.messages(endpoint);

  static String message(String id) =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.message(id);

  static String get recipientCategories =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.recipientCategories;

  static String get availableCategories =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.availableCategories;

  static String get recipientTeachers =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.recipientTeachers;

  static String get recipientDirectorate =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.recipientDirectorate;

  static String get uploadAttachment =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.uploadAttachment;

  static String downloadAttachment(String id) =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.downloadAttachment(id);

  static String get trashMessage =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.trashMessage;

  static String get deleteMessage =>
      BaseKreta.kretaAdmin + KretaAdminEndpoints.deleteMessage;
}

class BaseKreta {
 
 // https://ujkreta.onrender.com

  static String baseUrl = 'https://ujkreta.onrender.com';


  static String kreta(String iss) {
    final b = baseUrl.replaceAll(RegExp(r'/+$'), '');
    return b;
  }

  
  static String get kretaIdp => baseUrl.replaceAll(RegExp(r'/+$'), '');

 
  static String get kretaAdmin => baseUrl.replaceAll(RegExp(r'/+$'), '');

  static String get kretaFiles => baseUrl.replaceAll(RegExp(r'/+$'), '');
}

class KretaApiEndpoints {
  static const token = "/connect/token";
  static const revoke = "/connect/revocation";
  // static const nonce = "/nonce"; 

  // ÚjKréta Go router: /ellenorzo/v3/sajat/... (kisbetűs v3/sajat)
  static const notes = "/ellenorzo/v3/sajat/Feljegyzesek";
  static const events = "/ellenorzo/v3/sajat/FaliujsagElemek";
  static const student = "/ellenorzo/v3/sajat/TanuloAdatlap";
  static const grades = "/ellenorzo/v3/sajat/Ertekelesek";
  static const absences = "/ellenorzo/v3/sajat/Mulasztasok";
  static const groups = "/ellenorzo/v3/sajat/OsztalyCsoportok";
  static const groupAverages =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/OsztalyAtlagok";
  static const averages =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/TantargyiAtlagok";
  static const timetable = "/ellenorzo/v3/sajat/OrarendElemek";
  static const exams = "/ellenorzo/v3/sajat/BejelentettSzamonkeresek";
  static const homework = "/ellenorzo/v3/sajat/HaziFeladatok";
  static const capabilities = "/ellenorzo/v3/sajat/Intezmenyek";
  static String downloadHomeworkAttachments(String uid, String type) =>
      "/ellenorzo/v3/sajat/Csatolmany/$uid";
  static const subjects =
      "/ellenorzo/v3/sajat/Ertekelesek/Atlagok/TantargyiAtlagok";
}

class KretaAdminEndpoints {
  static const sendMessage = "/api/v1/kommunikacio/uzenetek";
  static String messages(String endpoint) =>
      "/api/v1/kommunikacio/postaladaelemek/$endpoint";
  static String message(String id) =>
      "/api/v1/kommunikacio/postaladaelemek/$id";
  static const recipientCategories = "/api/v1/adatszotarak/cimzetttipusok";
  static const availableCategories = "/api/v1/kommunikacio/cimezhetotipusok";
  static const recipientTeachers = "/api/v1/kreta/alkalmazottak/tanar";
  static const recipientDirectorate = "/api/v1/kreta/alkalmazottak/igazgatosag";
  static const uploadAttachment = "/ideiglenesfajlok";
  static String downloadAttachment(String id) =>
      "/api/v1/dokumentumok/uzenetek/$id";
  static const trashMessage = "/api/v1/kommunikacio/postaladaelemek/kuka";
  static const deleteMessage = "/api/v1/kommunikacio/postaladaelemek/torles";
  static const editProfile = "/api/profilapi/saveprofildata";
}
