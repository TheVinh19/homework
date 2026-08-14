docker run -d --name rikkei-frontend-qa -e API_ENDPOINT="https://qa-api.rikkei.edu.vn" nginx
docker exec -it rikkei-frontend-qa bash
echo $API_ENDPOINT
