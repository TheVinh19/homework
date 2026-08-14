sudo mkdir -p /opt/rikkei/pg-data
docker run -d \
  --name rikkei-db \
  -e POSTGRES_PASSWORD="Rikkei@2026" \
  -v /opt/rikkei/pg-data:/var/lib/postgresql/data \
  postgres:13


  docker rm -f rikkei-db

  docker run -d \
  --name rikkei-db \
  -e POSTGRES_PASSWORD="Rikkei@2026" \
  -v /opt/rikkei/pg-data:/var/lib/postgresql/data \
  postgres:13

  sudo ls -l /opt/rikkei/pg-data
