zip data.zip -r dist/*
scp data.zip ubuntu@138.2.56.130:~/
rm -rf  data.zip
ssh ubuntu@138.2.56.130 "sudo rm -rf  /usr/share/caddy/*"
ssh ubuntu@138.2.56.130 "sudo unzip data.zip -d /usr/share/caddy"
ssh ubuntu@138.2.56.130 "sudo mv /usr/share/caddy/dist/* /usr/share/caddy/"