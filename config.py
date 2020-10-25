import os

root = os.path.dirname(os.path.abspath(__file__))

# neo4j localhost settings start
neo4j_base_uri = 'bolt://127.0.0.1:7687'
neo4j_uri = 'bolt://{}:{}@127.0.0.1:7687'
neo4j_username = 'neo4j'
neo4j_password = '123456'
company_csv_file = 'company.csv'
relationship_csv_file = 'relationship.csv'
# neo4j localhost settings end
