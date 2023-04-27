require 'pg'

def main(event:, context:)
  {
    postgres_client_version: PG.library_version
  }
end
