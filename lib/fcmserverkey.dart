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
  "project_id": "richzspotnewmobile",
  "private_key_id": "8e56a2c2bc2de28747306e0baa575764fbb7af42",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC0nQ4ruhlPp08M\nuPqS3r9ibfUeUKwsDGxby/VH82A2ysEm6LHmLhZwEk4P0ebgLUP+JVjB5MhOeJen\nB0Ess50f77/ZVMtxsiSFTGjYQuttoR9m5baaXKTFcTKoLCpW5mouQTYnC1J/1nTH\nPuSq4zpsdHIt/1g+h5MoyXCSKFA7+uAfrpv735HOl6Qi9tvDm8uqO6CvBkODMkfT\nOO/HaIlgH4EM87wlQgF9H9NMD7LtLsCbsemLCqA4LYs8n1hYYcnosZnNA5hL0Mj4\nzambeAQ6XjKZIX+RiZ8x9fpk6x5+NjvRbSJYeurPY6s4jL5u3uab2r8AKEDHGFst\n0Axm3wbVAgMBAAECggEAIqy8WbzCuz4duQ2SXbwR9i2yD33hcBt6ei0wC/43jI1k\ng7nM3aofeKiq//KGZqeKFDLLVX48zoPsaY7E/nYFRmpa5LiYzl0rEcRXpJ1EYam7\nQ5/6bKw4ngdbeFnyTvixjevLH7fWwOBFTzNN51j0kHnSqe4J3QdeQ0hZKlY/ASSY\nX+u8xzxYsSyzbUtSqp3WCyM6Oi0I6cYcptFeGavei+/gUSWKYyXwqgzmyoFNQ+Xg\nIh/kKoIH7aFZ3+NjRsFGsIk1Lh/xGFGuXGpDvwu4NQH7h0gv/3J/fKVYZql5Y3XR\nuW65G+KAWfEMoHDQry8E0syxfna2wz22C38fJolQQQKBgQDfELLWw1Jowk3CjmP3\njK7Xl+S8feQWxxZ+c2pquUZbv3nq28zY5ajojn7p3Uofndi/CTDWWGybPyJI0Pcv\nkE4HNRHlyl2p47kzBe+wZM52TJHxAcdSRB+H4VFdILZ5IMNJRBwPzCtupAsBcc1l\nMWiLbcGdyC83C3JOtIvH/UlkCQKBgQDPR8noPOH3VLGi31o082fVP0eFtvzrHwMz\nCQIPJXOE6wZuVSsMQMV/UOk/Ocmb1L7KRTpDXsPlUg3qIdBhi6MC60tFVrzl5X4J\neW0g3NKraqPrIil7ZlljTm29IQI56paxS6tw0k968IQxdRZ9f2QgI11yil876JBq\nH+GIYHW3bQKBgQDPTmqWk2IEQAgad1DKoLFhZiXLU8hlrtLl5AeTderAm7wHnAzN\nyupmbv/eAq2/omfsavM7UWRmB4+qUqJXTuplYlnm0GKp4ByfIbY3nggPA2xiqn9+\nohcXpjyCq0NKYTt83NKjj+ERa11bE1OK5xc89V0KcSAILRgnsz1xOKE7WQKBgGui\nHH8itjfHW+J2VpIuXpmGHW6awaSZ2wBySgZxbRX1MMa0JQFc1PEyo5u4Ny9a/qNr\n5UA8gj6fKCiO3HT6nHAUnGZqDvbV/2eODRPGdwKaAnpDqASy9fGyNRvDezN11EBG\nScTxAGKXaB2CbmZGc0iY9JpYrfEe53akDWnSpO3VAoGBAMEd/z7pJMljwXALJftp\npznU9VMafqHB6hmxH7l6owBA0DXWN0zxUDs4qACSBoy0CLXPoHb4V/ocNdMUbSit\nXHxzf9s3DRUi+4cIcrkJuGO/CK7/E9Z+CEpYF/YnfBha9M75rXMnOsZIbtoysD1H\nU0s52c+LigUlnOn8XntmGJkc\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@richzspotnewmobile.iam.gserviceaccount.com",
  "client_id": "111264450863568827376",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40richzspotnewmobile.iam.gserviceaccount.com",
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