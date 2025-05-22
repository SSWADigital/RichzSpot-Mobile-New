import 'package:googleapis_auth/auth_io.dart';

class GetFcmServerKey {
  Future<String?> serverToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    try {
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "richzspot-mobile",
            "private_key_id": "a06bd11042ec853734d0ec608fd45a2ab6ef63ce",
            "private_key": """-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCf6yReLQoJi9nS\nF5TD/cYi/Bp61tCMqbJIbD8+n6TsPWDW4U9LpIfyp50O9xMtLcpxDr/vcBewB1FK\n3/eAa9SbkvTTyw1TknZPaZlSZV962hLjNGJazNtuMA74iGMX968fxz6KPFmk9vAc\nC+W4eSYylk1f5zyrQx/sQ8jhbyFlrOEl74yVE099HJK105O1HnMEgDcS6fe6uX/0\nHGGPknCizIdXzCyMeuXDyswf7oXLuFRddgXOOw459jOI/WJNYS9fKdq+AOrS0i5j\ntOFIoQt/yH6b9oUtqld83IlFrgcJ8J/VnnUft21prrf0RE/d8Z7dalQ9E9OtM0b9\nk/FL8DR9AgMBAAECggEAB1rrDgrPxJ8iSlOr07TbFVZXiHFTX7jZWpPh98kjbnsn\nNlLgEQhU+V/krSDHiMMrpbYKNWLIMCAyCLnS2hz7hxlD+e7DouWgW+gtNVk0wkN/\n7WPGJ0t3RzLeKWeqeRp6+0Dwey6p59i0s/GHJAwsadS4Y9IQnAbnE7iNZ3LzTAgM\nHbnJt+gjTClXR9DzUSMz3OdCCe0ni02Pek5wyYKwsh4CK+HduRIg7CcPLT2pGBFh\nT7WU2eyd+pFgZ6qkGN711oywbNbN9ClMasquiJeQhFr6H/+XjQ+dZZFndYQpLEAH\noz/m5Sx9qdEAwxBBEb00oOubgJtugmpCkL+FeIjiwQKBgQDY4E3LQaQe/R0Cdtrc\n3U1bXkC22wseJgkhHgY3bG/wA7zKEDX0nR412sswda7NFwMam1xU2F2WLyfOAdiT\n9knoypwqWEWdOQXHiCsHXE5yJOegIDgPOQR8gvVLzLedwXo/UHAjMWTCerBdaycA\naDE6Iy9swvJ/Or9hvDc7P5SDQQKBgQC8xHC78APMqSKUq5PI8mXumRhKFLxOo5tD\nRD9j31zU7j3EoqZTM+8xG21aHbmWtusU2TtMECzCXIVm0cWkELi7H+DxmZVFqaiu\nnZ29XQmdHrS/6SLzK/yi190A93oJXL5Se6pZDwJmyy51tSDH/1CNUDI/d6w+fAbj\nv0NtBmduPQKBgQDB92rcXOriZFKrv41jd/IVw6hxYlsBLdeAbQ/2Rd+fdFhHCFSZ\nYGSCmhqcTsR13R0DkOv1XkXlamtZTkFbpCzaLUuae7RXN4a5vElvndjzMZqPlgFN\nbBtdGOs2TfPy/fXN5q1EbIrHfV97TbhmHsnYS1vBFGI59FrymJl1PhofgQKBgQCa\n+nTL99xGtT4M7Wkh+9EwOUU13RxVPAGHEoswxfuDXi4cOKVxfhwNJ0V6TRlH4dnT\nfh4u7sCwuiFULzmi34+rIhsegEeLsCUrZ4BQLghslP806IWnPB/o2m06E/R/p0Mi\nmSFciPQhzQLR5OmLCdTqkEMQ1IH3swA9D5Sd+DoGyQKBgQCSv7sg100iqdr/iCxd\nG+i7mTcDbdqPxcaZ83CpAVp25zzkAaa1MwvaE9epyofiSFczLU7xR0tOhiVX8ej6\n8uDF8/NhFOB1EcCp5t0OhRaEEZd3qj+CHzF5x9bk3pKPT7CGC7l88Vm1PtWMTL5g\neKtErNYhz0KK4u71y4jnQWUdQQ==\n-----END PRIVATE KEY-----\n""",
            "client_email":
                "firebase-adminsdk-fbsvc@richzspot-mobile.iam.gserviceaccount.com",
            "client_id": "105780823231201701310",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url":
                "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url":
                "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40richzspot-mobile.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        scopes,
      );
      final accessServerKey = client.credentials.accessToken.data;
      final serverKey = accessServerKey.toString();
      return serverKey;
    } catch (e) {
      print('Error getting server token: $e');
      return null;
    }
  }
}