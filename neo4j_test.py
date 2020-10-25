from neo4j import GraphDatabase
from neo4j.exceptions import ClientError, ConstraintError
from config import (
    neo4j_base_uri, neo4j_username, neo4j_password, company_csv_file, relationship_csv_file
)
neo4j_driver = GraphDatabase.driver(
    neo4j_base_uri, auth=(neo4j_username, neo4j_password))


def index_neo4j_data(name_file, relationship_file):
    clear_neo4j_data()
    # :auto USING PERIODIC COMMIT 50000  加上报错
    relationship = """LOAD CSV WITH HEADERS FROM "file:/%s" AS line
        match (from:Company{name:line.p_name}),(to:Company{name:line.s_name})
        merge (from)-[r:HOLDING_SHARES{percent:toFloat(line.per_float),percent_text:line.per_text}]->(to)
        """

    with neo4j_driver.session() as session:
        try:
            session.run(
                "CREATE CONSTRAINT ON (n:Company) ASSERT n.name IS UNIQUE")
            session.run(
                'LOAD CSV WITH HEADERS FROM "file:/{}" AS row CREATE (n:Company) SET n = row'.format(name_file))
        except ClientError as e:
            print(e.message)
        # except ConstraintError as e:
        #     print(e.message)
        finally:
            session.run(relationship % relationship_file)
            session.close()


# 清空neo4j中的数据
# @timer
def clear_neo4j_data():
    with neo4j_driver.session() as session:
        session.run("MATCH (n)-[r]-() DELETE n,r")
        session.close()


def main():
    """
    docstring
    """
    index_neo4j_data(company_csv_file, relationship_csv_file)


if __name__ == "__main__":
    main()
