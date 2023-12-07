openssl req -x509 -newkey rsa:4096 -keyout talkToChat/talkToChat/Other/privatekey.pem -out talkToChat/talkToChat/Other/certificate.pem -days 365 -nodes -subj "/C=/ST=/L=/O=/OU=/CN="
openssl x509 -in talkToChat/talkToChat/Other/certificate.pem -outform der -out talkToChat/talkToChat/Other/certificate.cer
rm talkToChat/talkToChat/Other/*.pem
