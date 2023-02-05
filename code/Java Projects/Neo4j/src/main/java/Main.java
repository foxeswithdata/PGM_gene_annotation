import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Query;


import static org.neo4j.driver.Values.parameters;

public class Main implements AutoCloseable {

  private final Driver driver;

  public Main(String uri, String user, String password) {
    driver = GraphDatabase.driver(uri, AuthTokens.basic(user, password));
  }

  @Override
  public void close() throws RuntimeException {
    driver.close();
  }


  public void start() {
    try (var session = driver.session()) {
      var greeting = session.executeWrite(tx -> {
        var query = new Query(
            "CREATE (a:Greeting) SET a.message = $message RETURN a.message + ', from node ' + id(a)",
            parameters("message", "Session successfully started"));
        var result = tx.run(query);
        return result.single().get(0).asString();
      });
      System.out.println(greeting);
    } catch (Exception e) {
      System.out.println(
          "There was an error starting the database, please check the details below");
      e.printStackTrace();
    } finally {
      quickQuery("MATCH (n:Greeting) DELETE n");
      System.out.println(
          "Query successfully executed. All systems nominal, captain!");
    }
  }

  public String quickQuery(String body) {
    try (var session = driver.session()) {
      var response = session.executeWrite(tx -> {
        var query = new Query(body);
        var result = tx.run(query);
        return result.list().toString();
      });
      return response;
    }
  }

  public void configureDB() {
    quickQuery(
        "call n10s.graphconfig.init({handleMultival: 'ARRAY', handleRDFTypes: 'LABELS_AND_NODES', keepLangTag: true})");
    quickQuery("CREATE CONSTRAINT n10s_unique_uri FOR (r:Resource)\n"
        + "REQUIRE r.uri IS UNIQUE;");
  }

  public void sideLoadMetadata() {
    try (var session = driver.session()) {
      try (var transaction = session.beginTransaction()) {
        var result = transaction.run(
            "LOAD CSV WITH HEADERS FROM 'file:///genes.csv' AS row " +
                "MATCH (n:owl__Class) " +
                "WHERE n.ns1__id = [row.bio] OR n.ns1__id = [row.cell] OR n.ns1__id = [row.mole] "

                //can be removed if not accounting for alternative ids
                + "OR any(string IN n.ns1__hasAlternativeId WHERE string IN [row.bio, row.cell, row.mole])" +

                "SET n.associatedGenes = "
                + "CASE WHEN n.associatedGenes IS NOT NULL THEN n.associatedGenes + ', ' + row.gene ELSE row.gene END"
        );
        transaction.commit();
      } catch (Exception e) {
        System.out.println("Transaction failed: " + e.getMessage());
      }
    } catch (Exception e) {
      System.out.println("Session failed: " + e.getMessage());
    }
  }

  public static void main(String... args) {
    Main connection;
    connection = new Main("bolt://localhost:7687", "neo4j", "password");
    connection.start();
    //check if database is empty
    var response = connection.quickQuery("MATCH (n:!_GraphConfig) RETURN n LIMIT 10");
    if (response.equals("[]")) {
      System.out.println(
          "Database is empty (" + response + "), proceeding to populate");
      connection.configureDB();
      connection.quickQuery(
          "call n10s.rdf.import.fetch('http://purl.obolibrary.org/obo/go.owl', 'RDF/XML')");
    } else {
      System.out.println(
          "Database is not empty (first 10 responses: " + response + "), proceeding to query");
    }
    //prompt user if they want to sideload csv properties, code starts now:
    //BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
   // System.out.println("Would you like to side load metadata from a csv? (y/n)");
    //String csv = null;
    //try {
      //csv = reader.readLine();
    //} catch (IOException e) {
    //  e.printStackTrace();
   // }
   // if (csv.equals("y")) {
      connection.sideLoadMetadata();
   // }
  }
}
