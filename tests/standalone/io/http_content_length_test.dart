// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//

#import("dart:isolate");
#import("dart:io");

void testNoBody(int totalConnections) {
  HttpServer server = new HttpServer();
  server.onError = (e) => Expect.fail("Unexpected error $e");
  server.listen("127.0.0.1", 0, totalConnections);
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    response.contentLength = 0;
    OutputStream stream = response.outputStream;
    Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
    stream.close();
    Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
  };

  int count = 0;
  HttpClient client = new HttpClient();
  for (int i = 0; i < totalConnections; i++) {
    HttpClientConnection conn = client.get("127.0.0.1", server.port, "/");
    conn.onError = (e) => Expect.fail("Unexpected error $e");
    conn.onRequest = (HttpClientRequest request) {
      OutputStream stream = request.outputStream;
      Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
      stream.close();
      Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
    };
    conn.onResponse = (HttpClientResponse response) {
      count++;
      if (count == totalConnections) {
        client.shutdown();
        server.close();
      }
    };
  }
}

void testBody(int totalConnections) {
  HttpServer server = new HttpServer();
  server.onError = (e) => Expect.fail("Unexpected error $e");
  server.listen("127.0.0.1", 0, totalConnections);
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    response.contentLength = 2;
    OutputStream stream = response.outputStream;
    stream.writeString("x");
    Expect.throws(() => response.contentLength = 3, (e) => e is HttpException);
    stream.writeString("x");
    Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
    stream.close();
    Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
  };

  int count = 0;
  HttpClient client = new HttpClient();
  for (int i = 0; i < totalConnections; i++) {
    HttpClientConnection conn = client.get("127.0.0.1", server.port, "/");
    conn.onError = (e) => Expect.fail("Unexpected error $e");
    conn.onRequest = (HttpClientRequest request) {
      request.contentLength = 2;
      OutputStream stream = request.outputStream;
      stream.writeString("x");
      Expect.throws(() => request.contentLength = 3, (e) => e is HttpException);
      stream.writeString("x");
      Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
      stream.close();
      Expect.throws(() => stream.writeString("x"), (e) => e is HttpException);
    };
    conn.onResponse = (HttpClientResponse response) {
      count++;
      if (count == totalConnections) {
        client.shutdown();
        server.close();
      }
    };
  }
}

void main() {
  testNoBody(5);
  testBody(5);
}