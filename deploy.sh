
mkdir -p logs 
docker run -d -p 3838:3838 -v $PWD/app:/srv/shiny-server/  -v $PWD/logs/:/var/log/shiny-server/  lipideando
