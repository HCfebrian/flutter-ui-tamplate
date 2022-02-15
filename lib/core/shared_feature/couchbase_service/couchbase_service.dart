import 'dart:developer';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/services.dart';
import 'package:simple_flutter/get_it.dart';

class CouchbaseService {
  late ListenerToken _listenerToken;
  late Database database;
  Replicator? replicator;

  CouchbaseService();

  Future dispose() async {
    await replicator?.removeChangeListener(_listenerToken);
    await replicator?.stop();
    await replicator?.dispose();
    await database.close();
  }

  Future init() async {
    try {
      database = await Database.initWithName("chat-storage");
    } on PlatformException {
      return "Error initializing database";
    }

    // Create a new document (i.e. a record) in the database.
    // MutableDocument? mutableDoc =
    // MutableDocument().setDouble("hallo_world", 2.0).setString("new_world", "123");

    // Save it to the database.
    // try {
    //   await database.saveDocument(mutableDoc);
    // } on PlatformException {
    //   return "Error saving document";
    // }
    //
    // // Update a document.
    // mutableDoc = (await database.document(mutableDoc.id!))
    //     ?.toMutable()
    //     .setString("wonderful_world", "Dart");
    //
    // if (mutableDoc != null) {
    //   // Save it to the database.
    //   try {
    //     await database.saveDocument(mutableDoc);
    //
    //     var document = await (database.document(mutableDoc.id!));
    //
    //     // Log the document ID (generated by the database)
    //     // and properties
    //     // print("Document ID :: ${document!.id}");
    //     print("Learning ${document.getString("language")}");
    //   } on PlatformException {
    //     return "Error saving document";
    //   }
    // }

    // Create a query to fetch documents of type SDK.
    var query = QueryBuilder.select([SelectResult.all()])
        .from("chat-storage")
        .where(
            Expression.property("new_world").equalTo(Expression.string("123")));

    // Run the query.
    try {
      var result = await query.execute();
      print("Number of rows :: ${result.allResults().length}");
    } on PlatformException {
      return "Error running the query";
    }

    // Note wss://10.0.2.2:4984/my-database is for the android simulator on your local machine's couchbase database
    // Create replicators to push and pull changes to and from the cloud.
    ReplicatorConfiguration config =
        ReplicatorConfiguration(database, "ws://36.95.121.244:4984/demobucket");
    config.replicatorType = ReplicatorType.pushAndPull;
    config.continuous = true;

    // Add authentication.
    config.authenticator = BasicAuthenticator("admin", "irf9OtHofdej");
    log("add basic auth");

    // Create replicator (make sure to add an instance or static variable named replicator)
    var replicator = Replicator(config);

    // Listen to replicator change events.
    replicator.addChangeListener((ReplicatorChange event) {
      if (event.status.error != null) {
        print("Error: !" + event.status.error!);
      }

      print(event.status.activity.toString());
    });

    // Start replication.
    try {
      await replicator.start();
    } catch (e) {
      return e.toString();
    }

    getIt.registerLazySingleton(
      () => replicator,
    );

    getIt.registerLazySingleton(
          () => database,
    );
    print("init couchbase finish");
  }
}